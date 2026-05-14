import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/detail_row_data.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/enum_helpers.dart';
import '../../../domain/entities/property_entities.dart';

class DetailsGrid extends StatelessWidget {
  const DetailsGrid({super.key, required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    final rows = <DetailRowData>[];

    rows.add(
      DetailRowData(
        icon: PropertyTypeHelper.icon(property.type),
        label: 'Property Type',
        value: PropertyTypeHelper.label(property.type),
      ),
    );
    if (property.billingCycle != null) {
      rows.add(
        DetailRowData(
          icon: Icons.calendar_today_outlined,
          label: 'Billing Cycle',
          value: BillingCycleHelper.full(property.billingCycle),
        ),
      );
    }
    if (property.furnishingStatus != null) {
      rows.add(
        DetailRowData(
          icon: Icons.chair_outlined,
          label: 'Furnishing',
          value: FurnishingHelper.label(property.furnishingStatus!),
        ),
      );
    }
    if (property.floor != null) {
      rows.add(
        DetailRowData(
          icon: Icons.layers_outlined,
          label: 'Floor',
          value: '${property.floor}',
        ),
      );
    }
    if (property.isHostel && property.totalRooms != null) {
      rows.add(
        DetailRowData(
          icon: Icons.hotel_outlined,
          label: 'Total Rooms',
          value: '${property.totalRooms}',
        ),
      );
    }
    if (property.hotelCategory != null) {
      rows.add(
        DetailRowData(
          icon: Icons.star_border_rounded,
          label: 'Category',
          value: property.hotelCategory!,
        ),
      );
    }
    rows.add(
      DetailRowData(
        icon: Icons.location_city_outlined,
        label: 'District',
        value: property.district.name,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Property Details', style: AppTextStyles.h3),
          const Gap(12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: AppColors.grey200,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (_, i) {
                final row = rows[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(row.icon, size: 18, color: AppColors.grey500),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          row.label,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        row.value,
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
