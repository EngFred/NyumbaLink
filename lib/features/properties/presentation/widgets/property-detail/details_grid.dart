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
    // 1. Dynamically build the list of details just like your original code
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
          value: FurnishingHelper.label(property.furnishingStatus!), // FIXED
        ),
      );
    }

    if (property.floor != null && property.floor! > 0) {
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
    } else if (!property.isHostel) {
      rows.add(
        DetailRowData(
          icon: Icons.bed_outlined,
          label: 'Total Rooms',
          value: '${property.numberOfRooms}',
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

    // 2. Render the flat, modern UI using the dynamic rows
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property Details',
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(16),

          // Completely unboxed. Just a clean list of details separated by faint dividers.
          ...rows.asMap().entries.map((entry) {
            final isFirst = entry.key == 0;
            final rowData = entry.value;

            return _DetailRow(
              icon: rowData.icon,
              label: rowData.label,
              value: rowData.value,
              isFirst: isFirst,
            );
          }),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isFirst = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isFirst) const Divider(height: 1, color: AppColors.grey100),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textHint),
              const Gap(12),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                value,
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
