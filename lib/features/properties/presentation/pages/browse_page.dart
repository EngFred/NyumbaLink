import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/enum_helpers.dart';
import '../../domain/entities/property_entities.dart';
import '../../domain/entities/property_filters.dart';
import '../providers/featured_properties_provider.dart';
import '../providers/properties_provider.dart';
import '../providers/saved_properties_provider.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/property_card.dart';
import '../widgets/property_shimmer.dart';
import '../widgets/property_type_filter_bar.dart';

const _kFeaturedGold = Color(0xFFD4A017);

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
          _SearchBar(
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

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
    required this.hasActiveFilters,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, value, __) => TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: AppTextStyles.bodyMd,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search by name or area…',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: AppColors.grey500,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(),
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.grey500,
                            ),
                            onPressed: () {
                              controller.clear();
                              onChanged('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ),
            const Gap(10),
            _FilterButton(hasActive: hasActiveFilters, onTap: onFilterTap),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.hasActive, required this.onTap});
  final bool hasActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: hasActive ? AppColors.primary : AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
              border: hasActive ? null : Border.all(color: AppColors.grey200),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 20,
              color: hasActive ? Colors.white : AppColors.textPrimary,
            ),
          ),
          if (hasActive)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── List ──────────────────────────────────────────────────────────────────────

// Sealed item types for the ListView
sealed class _ListItem {}

class _FeaturedShimmerItem extends _ListItem {} // ← NEW

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
      return _ErrorState(onRetry: onRefresh);
    }

    if (state.properties.isEmpty) {
      return _EmptyState(
        hasFilters: state.filters.hasActiveFilters,
        onClear: onClearFilters,
      );
    }

    final featuredState = ref.watch(featuredPropertiesProvider);
    final isFeaturedLoading = featuredState.isLoading;
    final hasFeaturedCarousel =
        !isFeaturedLoading && featuredState.properties.isNotEmpty;

    // Build flat items list
    final items = <_ListItem>[];

    // Show shimmer while featured data is in flight, real carousel once ready
    if (isFeaturedLoading) {
      items.add(_FeaturedShimmerItem());
    } else if (hasFeaturedCarousel) {
      items.add(_FeaturedCarouselItem());
    }

    items.add(_ResultsHeaderItem(state.total));

    bool addedFeaturedDivider = false;
    bool addedAllDivider = false;

    for (var i = 0; i < state.properties.length; i++) {
      final p = state.properties[i];
      if (p.isFeatured && !addedFeaturedDivider) {
        items.add(_SectionDividerItem(isFeatured: true));
        addedFeaturedDivider = true;
      } else if (!p.isFeatured && !addedAllDivider) {
        items.add(_SectionDividerItem(isFeatured: false));
        addedAllDivider = true;
      }
      items.add(_PropertyItem(p, i));
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
            // ── Featured carousel shimmer ──────────────────────────────────
            _FeaturedShimmerItem() => const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: FeaturedCarouselShimmer(),
            ),

            // ── Featured carousel (real data) ──────────────────────────────
            _FeaturedCarouselItem() => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _FeaturedCarouselSection(
                properties: featuredState.properties,
              ),
            ),

            _ResultsHeaderItem(:final total) => _ResultsHeader(total: total),
            _SectionDividerItem(:final isFeatured) => _SectionLabel(
              isFeatured: isFeatured,
            ),
            _PropertyItem(:final property, :final index) => Padding(
              padding: EdgeInsets.only(
                bottom: index < state.properties.length - 1 ? 16 : 0,
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
                          .toggleSave(property),
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

// ── Featured Hero Carousel ────────────────────────────────────────────────────

class _FeaturedCarouselSection extends StatefulWidget {
  const _FeaturedCarouselSection({required this.properties});
  final List<Property> properties;

  @override
  State<_FeaturedCarouselSection> createState() =>
      _FeaturedCarouselSectionState();
}

class _FeaturedCarouselSectionState extends State<_FeaturedCarouselSection> {
  final _pageCtrl = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Section eyebrow label ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 10),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _kFeaturedGold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Gap(8),
                  Text(
                    '🏆  Featured Properties',
                    style: AppTextStyles.labelLg.copyWith(
                      color: _kFeaturedGold,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            // ── Carousel ──────────────────────────────────────────────────────
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: widget.properties.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _FeaturedHeroCard(property: widget.properties[i]),
                ),
              ),
            ),

            // ── Page indicator dots ────────────────────────────────────────────
            if (widget.properties.length > 1) ...[
              const Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.properties.length, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.grey300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              const Gap(4),
            ],
          ],
        )
        .animate()
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.06, end: 0, duration: 350.ms, curve: Curves.easeOut);
  }
}

class _FeaturedHeroCard extends StatelessWidget {
  const _FeaturedHeroCard({required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/properties/${property.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            if (property.thumbnailUrl != null)
              CachedNetworkImage(
                imageUrl: property.thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    const ColoredBox(color: AppColors.grey200),
                errorWidget: (_, __, ___) => _HeroFallback(type: property.type),
              )
            else
              _HeroFallback(type: property.type),

            // Dark gradient overlay from bottom
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.0, 0.55, 1.0],
                  colors: [
                    Color(0xEE000000),
                    Color(0x88000000),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Featured badge — top left
            const Positioned(top: 12, left: 12, child: _FeaturedBadge()),

            // Property type pill — bottom right
            Positioned(
              bottom: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PropertyTypeHelper.icon(property.type),
                      size: 11,
                      color: AppColors.primary,
                    ),
                    const Gap(4),
                    Text(
                      PropertyTypeHelper.label(property.type),
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content — bottom left
            Positioned(
              bottom: 14,
              left: 14,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    property.title,
                    style: AppTextStyles.h4.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(3),
                  Text(
                    CurrencyFormatter.format(property.price),
                    style: AppTextStyles.priceSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 11,
                        color: Colors.white70,
                      ),
                      const Gap(3),
                      Flexible(
                        child: Text(
                          '${property.area}, ${property.district.name}',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary50, AppColors.primary100],
        ),
      ),
      child: Center(
        child: Icon(
          PropertyTypeHelper.icon(type),
          size: 56,
          color: AppColors.primary200,
        ),
      ),
    );
  }
}

// ── Featured badge (private, file-scoped) ─────────────────────────────────────

class _FeaturedBadge extends StatelessWidget {
  const _FeaturedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kFeaturedGold,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kFeaturedGold.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        '★ Featured',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── Section divider label ─────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.isFeatured});
  final bool isFeatured;

  @override
  Widget build(BuildContext context) {
    final color = isFeatured ? _kFeaturedGold : AppColors.textHint;
    final label = isFeatured ? '★  Featured' : 'All Properties';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: color.withOpacity(0.35),
              thickness: 1,
              endIndent: 10,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: color,
              fontWeight: isFeatured ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.4,
            ),
          ),
          Expanded(
            child: Divider(
              color: color.withOpacity(0.35),
              thickness: 1,
              indent: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small components ──────────────────────────────────────────────────────────

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
      child: Text(
        total == 1 ? '1 property found' : '$total properties found',
        style: AppTextStyles.bodySm.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilters, required this.onClear});
  final bool hasFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.primary50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 42,
                color: AppColors.primary200,
              ),
            ),
            const Gap(20),
            Text(
              'No properties found',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              hasFilters
                  ? 'Try removing some filters to see more results.'
                  : 'Check back later for new listings.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const Gap(24),
              OutlinedButton(
                onPressed: onClear,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                ),
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 42,
                color: AppColors.error,
              ),
            ),
            const Gap(20),
            Text(
              "Couldn't load properties",
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'Check your connection and try again.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 32),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
