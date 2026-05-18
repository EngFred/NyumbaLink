import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      highlightColor: AppColors.primary.withOpacity(0.05),
      splashColor: AppColors.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textSecondary),
            const Gap(16),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}
