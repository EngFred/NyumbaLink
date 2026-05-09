import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/enum_helpers.dart';
import '../../domain/entities/property_filters.dart';
import '../providers/properties_provider.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/property_card.dart';
import '../widgets/property_shimmer.dart';

class BrowsePage extends ConsumerStatefulWidget {
  const BrowsePage({super.key});

  @override
  ConsumerState<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends ConsumerState<BrowsePage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _activeTypeTab;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(propertiesProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(propertiesProvider);

    final visible = state.properties.where((p) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery) ||
          p.area.toLowerCase().contains(_searchQuery) ||
          p.district.name.toLowerCase().contains(_searchQuery);

      final matchesTab = _activeTypeTab == null || p.type == _activeTypeTab;
      return matchesSearch && matchesTab;
    }).toList();

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            hasActiveFilters: state.filters.hasActiveFilters,
            onChanged: (q) => setState(() => _searchQuery = q.toLowerCase()),
            onFilter: () => _openFilterSheet(state.filters),
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
          _TypeTabBar(
            activeType: _activeTypeTab,
            onSelect: (t) {
              setState(() => _activeTypeTab = t);
            },
          ),
          if (!state.isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Text(
                    _searchQuery.isEmpty && _activeTypeTab == null
                        ? '${state.total} properties'
                        : '${visible.length} results',
                    style: AppTextStyles.bodySm,
                  ),
                  if (state.filters.hasActiveFilters) ...[
                    const Gap(8),
                    GestureDetector(
                      onTap: () {
                        setState(() => _activeTypeTab = null);
                        ref.read(propertiesProvider.notifier).clearFilters();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Filters active',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                            const Gap(4),
                            const Icon(
                              Icons.close_rounded,
                              size: 12,
                              color: AppColors.accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          Expanded(child: _buildBody(state, visible)),
        ],
      ),
    );
  }

  Widget _buildBody(PropertiesState state, List visibleProps) {
    if (state.isLoading) return const PropertyShimmerGrid();

    if (state.error != null && state.properties.isEmpty) {
      return _ErrorState(
        message: state.error!,
        onRetry: () => ref.read(propertiesProvider.notifier).refresh(),
      );
    }

    if (visibleProps.isEmpty) {
      return _EmptyState(
        hasFilters: state.filters.hasActiveFilters || _searchQuery.isNotEmpty,
        onClear: () {
          _searchController.clear();
          setState(() {
            _searchQuery = '';
            _activeTypeTab = null;
          });
          ref.read(propertiesProvider.notifier).clearFilters();
        },
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(propertiesProvider.notifier).refresh(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: visibleProps.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index >= visibleProps.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }
          final property = visibleProps[index];
          return PropertyCard(
            property: property,
            onTap: () =>
                context.push(AppRoutes.propertyDetailPath(property.id)),
          );
        },
      ),
    );
  }

  Future<void> _openFilterSheet(PropertyFilters current) async {
    final result = await showModalBottomSheet<PropertyFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(current: current),
    );
    if (result != null && mounted) {
      setState(() => _activeTypeTab = null);
      ref.read(propertiesProvider.notifier).applyFilters(result);
    }
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.hasActiveFilters,
    required this.onChanged,
    required this.onFilter,
    required this.onClear,
  });
  final TextEditingController controller;
  final bool hasActiveFilters;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Search by name, area...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: onClear,
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.grey300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.grey300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const Gap(10),
          GestureDetector(
            onTap: onFilter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasActiveFilters ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasActiveFilters
                      ? AppColors.primary
                      : AppColors.grey300,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: hasActiveFilters
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeTabBar extends StatelessWidget {
  const _TypeTabBar({required this.activeType, required this.onSelect});

  final String? activeType;
  final ValueChanged<String?> onSelect;

  // Added null to represent the "All" tab
  static const _tabs = [
    null,
    'APARTMENT',
    'HOSTEL',
    'RESIDENTIAL_HOUSE',
    'AIRBNB',
    'OFFICE_SPACE',
    'BUSINESS_SPACE',
    'HOTEL_LODGE',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final t = _tabs[i];
          final selected = activeType == t;

          final label = t == null ? 'All' : PropertyTypeHelper.label(t);
          final icon = t == null
              ? Icons.apps_rounded
              : PropertyTypeHelper.icon(t);

          return GestureDetector(
            onTap: () => onSelect(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.grey300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 13,
                    color: selected ? Colors.white : AppColors.grey600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppTextStyles.labelMd.copyWith(
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
            Icon(
              hasFilters ? Icons.search_off_rounded : Icons.home_work_rounded,
              size: 64,
              color: AppColors.grey300,
            ),
            const Gap(16),
            Text(
              hasFilters
                  ? 'No properties match your filters'
                  : 'No properties available',
              style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const Gap(8),
              Text(
                'Try adjusting your search or filters',
                style: AppTextStyles.bodySm,
                textAlign: TextAlign.center,
              ),
              const Gap(20),
              TextButton(
                onPressed: onClear,
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: AppColors.grey300,
            ),
            const Gap(16),
            Text('Could not load properties', style: AppTextStyles.h4),
            const Gap(8),
            Text(
              message,
              style: AppTextStyles.bodySm,
              textAlign: TextAlign.center,
            ),
            const Gap(20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
