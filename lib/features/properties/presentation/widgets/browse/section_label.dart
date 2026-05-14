import 'package:flutter/material.dart';
import 'package:rentora/features/properties/presentation/pages/browse_page.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.isFeatured});
  final bool isFeatured;

  @override
  Widget build(BuildContext context) {
    final color = isFeatured ? kFeaturedGold : AppColors.textHint;
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
