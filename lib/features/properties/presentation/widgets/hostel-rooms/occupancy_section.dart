import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rentora/features/properties/presentation/widgets/hostel-rooms/occupancy_bar.dart';
import 'package:rentora/features/properties/presentation/widgets/hostel-rooms/stat_card.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/property_entities.dart';

class OccupancySection extends StatelessWidget {
  const OccupancySection({super.key, required this.stats});
  final HostelStats stats;

  @override
  Widget build(BuildContext context) {
    final occupancyPct = stats.total > 0
        ? (stats.occupied + stats.reserved) / stats.total
        : 0.0;
    final availablePct = stats.total > 0 ? stats.available / stats.total : 0.0;
    final maintenancePct = stats.total > 0
        ? stats.maintenance / stats.total
        : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Occupancy Overview', style: AppTextStyles.h4),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: occupancyPct > 0.8
                      ? AppColors.errorLight
                      : AppColors.primary50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(occupancyPct * 100).toStringAsFixed(0)}% occupied',
                  style: AppTextStyles.labelSm.copyWith(
                    color: occupancyPct > 0.8
                        ? AppColors.error
                        : AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const Gap(16),

          // Segmented occupancy bar
          OccupancyBar(
            availablePct: availablePct,
            occupiedPct: occupancyPct,
            maintenancePct: maintenancePct,
          ),

          const Gap(16),

          // Stat pills
          Row(
            children: [
              Expanded(
                child: StatCard(
                  count: stats.total,
                  label: 'Total',
                  color: AppColors.primary,
                ),
              ),
              const Gap(8),
              Expanded(
                child: StatCard(
                  count: stats.available,
                  label: 'Available',
                  color: AppColors.success,
                ),
              ),
              const Gap(8),
              Expanded(
                child: StatCard(
                  count: stats.occupied + stats.reserved,
                  label: 'Occupied',
                  color: AppColors.error,
                ),
              ),
              if (stats.maintenance > 0) ...[
                const Gap(8),
                Expanded(
                  child: StatCard(
                    count: stats.maintenance,
                    label: 'Maint.',
                    color: AppColors.accent,
                  ),
                ),
              ],
            ],
          ),

          // Capacity cap hint
          if (stats.slotsRemaining != null && stats.slotsRemaining! > 0) ...[
            const Gap(12),
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.grey500,
                ),
                const Gap(6),
                Text(
                  '${stats.slotsRemaining} slots remaining before capacity cap',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
