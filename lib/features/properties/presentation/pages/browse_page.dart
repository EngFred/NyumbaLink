import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rentora/features/properties/presentation/utils/property_mapper_ext.dart';
import 'package:rentora/features/properties/presentation/widgets/browse/results_header.dart';
import 'package:rentora/features/properties/presentation/widgets/browse/search_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../domain/entities/property_entities.dart';
import '../../domain/entities/property_filters.dart';
import '../providers/featured_properties_provider.dart';
import '../providers/properties_provider.dart';
import '../providers/saved_properties_provider.dart';
import '../widgets/browse/featured_carousel_section.dart';
import '../widgets/browse/filter_sheet.dart';
import '../widgets/browse/property_card.dart';
import '../widgets/browse/property_shimmer.dart';
import '../widgets/browse/property_type_filter_bar.dart';
import '../widgets/browse/section_label.dart';

const kFeaturedGold = Color(0xFFD4A017);

class BrowsePage extends ConsumerStatefulWidget {
  const BrowsePage({super.key});
  @override
  ConsumerState<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends ConsumerState<BrowsePage> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollCtrl
      ..removeListener(_onScroll)
      ..dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      ref.read(propertiesProvider.notifier).fetchNextPage();
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final current = ref.read(propertiesProvider).filters;
      final trimmed = query.trim();
      ref
          .read(propertiesProvider.notifier)
          .applyFilters(
            trimmed.isEmpty
                ? current.copyWith(clearSearch: true)
                : current.copyWith(search: trimmed),
          );
    });
  }

  Future<void> _openFilters() async {
    final current = ref.read(propertiesProvider).filters;
    final result = await showModalBottomSheet<PropertyFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(current: current),
    );
    if (result != null && mounted) {
      ref.read(propertiesProvider.notifier).applyFilters(result);
    }
  }

  void _clearAll() {
    _searchCtrl.clear();
    ref.read(propertiesProvider.notifier).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(propertiesProvider);
    final filters = state.filters;
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          ExploreSearchBar(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            onFilterTap: _openFilters,
            hasActiveFilters: filters.hasActiveFilters,
          ),
          PropertyTypeFilterBar(
            selected: filters.type,
            onTypeSelected: (type) {
              final updated = type == null
                  ? filters.copyWith(clearType: true)
                  : filters.copyWith(type: type);
              ref.read(propertiesProvider.notifier).applyFilters(updated);
            },
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOut,
              child: state.isLoading
                  ? const PropertyShimmerGrid(key: ValueKey('shimmer'))
                  : _ListView(
                      key: const ValueKey('list'),
                      state: state,
                      scrollController: _scrollCtrl,
                      onRefresh: () =>
                          ref.read(propertiesProvider.notifier).refresh(),
                      onClearFilters: _clearAll,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

sealed class _ListItem {}

class _FeaturedShimmerItem extends _ListItem {}

class _FeaturedCarouselItem extends _ListItem {}

class _ResultsHeaderItem extends _ListItem {
  _ResultsHeaderItem(this.total);
  final int total;
}

class _SectionDividerItem extends _ListItem {
  _SectionDividerItem({required this.isFeatured});
  final bool isFeatured;
}

class _PropertyItem extends _ListItem {
  _PropertyItem(this.property, this.index);
  final Property property;
  final int index;
}

class _FooterItem extends _ListItem {}

class _ListView extends ConsumerWidget {
  const _ListView({
    super.key,
    required this.state,
    required this.scrollController,
    required this.onRefresh,
    required this.onClearFilters,
  });
  final PropertiesState state;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.error != null && state.properties.isEmpty) {
      return AppErrorState(onRetry: onRefresh);
    }
    if (state.properties.isEmpty) {
      return AppEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No matching properties',
        subtitle: 'Try adjustments or reset current filters to start over.',
        buttonLabel: 'Reset All Filters',
        onButtonTap: onClearFilters,
      );
    }

    final featuredState = ref.watch(featuredPropertiesProvider);
    final isFeaturedLoading = featuredState.isLoading;
    final hasFeaturedCarousel =
        !isFeaturedLoading && featuredState.properties.isNotEmpty;

    final nonFeaturedProperties = state.properties
        .where((p) => !p.isFeatured)
        .toList();

    final items = <_ListItem>[];
    if (isFeaturedLoading) {
      items.add(_FeaturedShimmerItem());
    } else if (hasFeaturedCarousel) {
      items.add(_FeaturedCarouselItem());
    }

    items.add(_ResultsHeaderItem(state.total));

    if (nonFeaturedProperties.isNotEmpty) {
      items.add(_SectionDividerItem(isFeatured: false));
      for (var i = 0; i < nonFeaturedProperties.length; i++) {
        items.add(_PropertyItem(nonFeaturedProperties[i], i));
      }
    }

    items.add(_FooterItem());

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      strokeWidth: 2,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return switch (item) {
            _FeaturedShimmerItem() => const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: FeaturedCarouselShimmer(),
            ),
            _FeaturedCarouselItem() => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: FeaturedCarouselSection(
                properties: featuredState.properties,
              ),
            ),
            _ResultsHeaderItem(:final total) => ResultsHeader(total: total),
            _SectionDividerItem(:final isFeatured) => SectionLabel(
              isFeatured: isFeatured,
            ),
            _PropertyItem(:final property, :final index) => Padding(
              padding: EdgeInsets.only(
                bottom: index < nonFeaturedProperties.length - 1 ? 16 : 0,
              ),
              child: RepaintBoundary(
                child: Consumer(
                  builder: (_, ref, __) {
                    final isSaved = ref.watch(
                      savedPropertiesProvider.select(
                        (s) => s.savedList.any((p) => p.id == property.id),
                      ),
                    );
                    return PropertyCard(
                      property: property,
                      onTap: () => context.push('/properties/${property.id}'),
                      isSaved: isSaved,
                      onSaveTap: () => ref
                          .read(savedPropertiesProvider.notifier)
                          .toggleSave(property.toSavedProperty()),
                    );
                  },
                ),
              ),
            ),
            _FooterItem() =>
              state.isLoadingMore
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : const SizedBox(height: 8),
          };
        },
      ),
    );
  }
}
