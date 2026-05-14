import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

// ── Header ────────────────────────────────────────────────────────────────────
class BookingsHeader extends StatelessWidget {
  const BookingsHeader({
    super.key,
    required this.total,
    required this.isAuthenticated,
  });
  final int total;
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          if (total > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$total ${total == 1 ? 'booking' : 'bookings'}',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Gap(8),
            Text(
              'found',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ] else
            Text(
              'Your booking requests',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          const Spacer(),
          if (isAuthenticated && total > 0)
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
