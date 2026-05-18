import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class FeatureRow extends StatelessWidget {
  const FeatureRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(4),
              Text(
                subtitle,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
