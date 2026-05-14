import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

// ── Token Section ─────────────────────────────────────────────────────────────
class TokenSection extends StatelessWidget {
  const TokenSection({
    super.key,
    required this.token,
    required this.isAuthenticated,
  });

  final String token;
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    if (isAuthenticated && token.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 13,
                  color: AppColors.success,
                ),
                const Gap(5),
                Text(
                  'Secure Booking',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cancellation Token',
          style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
        ),
        const Gap(2),
        Text(
          token.isEmpty ? '––' : token,
          style: AppTextStyles.labelLg.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
