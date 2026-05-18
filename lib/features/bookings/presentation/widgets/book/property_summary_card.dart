import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class PropertySummary extends StatelessWidget {
  const PropertySummary({
    super.key,
    required this.title,
    required this.location,
    required this.price,
    this.billingCycle,
    this.imageUrl,
    this.universityName,
    this.roomNumber,
  });

  final String title;
  final String location;
  final double price;
  final String? billingCycle;
  final String? imageUrl;
  final String? universityName;
  final String? roomNumber;

  String _formatBilling(String? cycle) {
    if (cycle == null || cycle.isEmpty) return '';
    switch (cycle.toUpperCase()) {
      case 'DAILY':
        return '/ day';
      case 'WEEKLY':
        return '/ week';
      case 'MONTHLY':
        return '/ month';
      case 'QUARTERLY':
        return '/ quarter';
      case 'FOUR_MONTHS':
        return '/ 4 months';
      case 'BIANNUAL':
        return '/ half-year';
      case 'ANNUAL':
        return '/ year';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    );
    final billingStr = _formatBilling(billingCycle);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact, beautifully rounded image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 90,
                height: 90,
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(imageUrl!, fit: BoxFit.cover)
                    : Container(
                        color: AppColors.grey100,
                        child: const Icon(
                          Icons.home_work_outlined,
                          color: AppColors.grey400,
                          size: 32,
                        ),
                      ),
              ),
            ),
            const Gap(16),

            // Text Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(6),

                  if (universityName != null && universityName!.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const Gap(6),
                        Expanded(
                          child: Text(
                            universityName!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                  ],

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const Gap(6),
                      Expanded(
                        child: Text(
                          location.isNotEmpty
                              ? location
                              : 'Location unavailable',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const Gap(10),

                  // Same-Row Room Number & Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (roomNumber != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Room $roomNumber',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],

                      // Pushes the price to the right, or keeps it left if there's no room number
                      if (roomNumber != null) const Spacer(),

                      if (price > 0)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              currencyFormat.format(price),
                              style: AppTextStyles.labelLg.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (billingStr.isNotEmpty) ...[
                              const Gap(2),
                              Text(
                                billingStr,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const Gap(24),
        const Divider(height: 1, thickness: 1, color: AppColors.grey200),
      ],
    );
  }
}
