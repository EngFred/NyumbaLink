import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/property_filters.dart';
import '../providers/properties_provider.dart';
import '../providers/saved_properties_provider.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/property_card.dart';
import '../widgets/property_shimmer.dart';
import '../widgets/property_type_filter_bar.dart';

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
          // ── Search + filter button ───────────────────────────────────────
          _SearchBar(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            onFilterTap: _openFilters,
            hasActiveFilters: filters.hasActiveFilters,
          ),
          // ── Horizontal type filter ───────────────────────────────────────
          PropertyTypeFilterBar(
            selected: filters.type,
            onTypeSelected: (type) {
              final updated = type == null
                  ? filters.copyWith(clearType: true)
                  : filters.copyWith(type: type);
              ref.read(propertiesProvider.notifier).applyFilters(updated);
            },
          ),
          // ── Content ───────────────────────────────────────────────────────
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

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      strokeWidth: 2,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        // +1 for the results header; +1 for the footer
        itemCount: state.properties.length + 2,
        itemBuilder: (context, index) {
          // Header
          if (index == 0) {
            return _ResultsHeader(total: state.total);
          }

          final i = index - 1;

          // Footer / load-more indicator
          if (i >= state.properties.length) {
            return state.isLoadingMore
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : const SizedBox(height: 8);
          }

          final property = state.properties[i];
          return Padding(
            padding: EdgeInsets.only(
              bottom: i < state.properties.length - 1 ? 16 : 0,
            ),
            // RepaintBoundary isolates repaints to only the changed card
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
          );
        },
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
