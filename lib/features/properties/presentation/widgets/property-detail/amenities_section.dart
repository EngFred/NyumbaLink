import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/string_helpers.dart';

class AmenitiesSection extends StatelessWidget {
  const AmenitiesSection({super.key, required this.amenities});
  final List<String> amenities;

  static IconData _iconFor(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains('wifi') || lower.contains('internet')) {
      return Icons.wifi_rounded;
    }
    if (lower.contains('water')) return Icons.water_drop_outlined;
    if (lower.contains('electric') || lower.contains('power')) {
      return Icons.bolt_outlined;
    }
    if (lower.contains('parking') || lower.contains('car')) {
      return Icons.local_parking_rounded;
    }
    if (lower.contains('security') || lower.contains('guard')) {
      return Icons.security_rounded;
    }
    if (lower.contains('gym') || lower.contains('fitness')) {
      return Icons.fitness_center_rounded;
    }
    if (lower.contains('pool') || lower.contains('swimming')) {
      return Icons.pool_rounded;
    }
    if (lower.contains('tv') || lower.contains('cable')) {
      return Icons.tv_outlined;
    }
    if (lower.contains('gas') || lower.contains('kitchen')) {
      return Icons.kitchen_outlined;
    }
    if (lower.contains('laundry') || lower.contains('washing')) {
      return Icons.local_laundry_service_outlined;
    }
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Amenities', style: AppTextStyles.h3),
          const Gap(12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: amenities.map((a) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_iconFor(a), size: 14, color: AppColors.primary),
                    const Gap(6),
                    Text(
                      a.toSentenceCase(), // ← Applied capitalization
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.grey700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
