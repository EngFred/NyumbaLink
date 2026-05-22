import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:rentora/features/area-alerts/data/datasources/area_alerts_remote_datasource.dart';
import 'package:rentora/features/area-alerts/data/models/area_option.dart';
import 'package:rentora/features/area-alerts/presentation/providers/area_alerts_provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class AreaSearchModal extends ConsumerStatefulWidget {
  const AreaSearchModal({super.key, this.initialArea});

  final AreaOption? initialArea;

  @override
  ConsumerState<AreaSearchModal> createState() => _AreaSearchModalState();
}

class _AreaSearchModalState extends ConsumerState<AreaSearchModal> {
  List<AreaOption> _allAreas = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    try {
      final ds = ref.read(areaAlertsRemoteDataSourceProvider);
      final areas = await ds.getAllAreas();
      if (mounted) {
        setState(() {
          _allAreas = areas;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscribedIds = ref
        .watch(areaAlertsProvider)
        .alerts
        .map((a) => a.areaId)
        .toSet();

    final filtered = _search.isEmpty
        ? _allAreas
        : _allAreas
              .where(
                (a) =>
                    a.name.toLowerCase().contains(_search.toLowerCase()) ||
                    a.districtName.toLowerCase().contains(
                      _search.toLowerCase(),
                    ),
              )
              .toList();

    final Map<String, List<AreaOption>> grouped = {};
    for (final area in filtered) {
      grouped.putIfAbsent(area.districtName, () => []).add(area);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Search Area',
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const CloseButton(color: AppColors.grey500),
                      ],
                    ),
                    const Gap(12),
                    TextField(
                      autofocus:
                          false, // ── PRO UX FIX: Keyboard only shows when user taps ──
                      decoration: InputDecoration(
                        hintText: 'Search by area or district...',
                        hintStyle: const TextStyle(color: AppColors.textHint),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 22,
                          color: AppColors.grey500,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                  ],
                ),
              ),
              const Gap(16),
              const Divider(height: 1, color: AppColors.grey200),

              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : grouped.isEmpty
                    ? Center(
                        child: Text(
                          'No areas found matching "$_search"',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                      )
                    : ListView(
                        controller: scrollController,
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom + 20,
                        ),
                        children: grouped.entries.expand((entry) {
                          return [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                              child: Text(
                                entry.key.toUpperCase(),
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            ...entry.value.map((area) {
                              final isAlreadySubscribed = subscribedIds
                                  .contains(area.id);
                              final isSelected =
                                  widget.initialArea?.id == area.id;

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 4,
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (isSelected || isAlreadySubscribed)
                                        ? AppColors.primary.withOpacity(0.1)
                                        : AppColors.grey50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isAlreadySubscribed
                                        ? Icons.notifications_active_rounded
                                        : Icons.location_on_rounded,
                                    color: (isSelected || isAlreadySubscribed)
                                        ? AppColors.primary
                                        : AppColors.grey400,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  area.name,
                                  style: AppTextStyles.bodyLg.copyWith(
                                    fontWeight:
                                        (isSelected || isAlreadySubscribed)
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: (isSelected || isAlreadySubscribed)
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                trailing: isAlreadySubscribed
                                    ? Text(
                                        'Subscribed',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    : isSelected
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.primary,
                                      )
                                    : null,
                                onTap: isAlreadySubscribed
                                    ? null
                                    : () => Navigator.pop(context, area),
                              );
                            }),
                          ];
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
