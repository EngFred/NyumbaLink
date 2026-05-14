import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class SavedHeader extends StatelessWidget {
  const SavedHeader({
    super.key,
    required this.count,
    required this.isAuthenticated,
  });
  final int count;
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          if (count > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count ${count == 1 ? 'property' : 'properties'}',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Gap(8),
            Text(
              'saved',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ] else
            Text(
              'Your saved properties',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          const Spacer(),
          if (isAuthenticated && count > 0)
            const Icon(
              Icons.cloud_done_outlined,
              size: 18,
              color: AppColors.success,
            ),
        ],
      ),
    );
  }
}
