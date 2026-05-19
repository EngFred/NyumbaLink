import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class UnauthenticatedView extends StatelessWidget {
  const UnauthenticatedView({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 48,
              color: AppColors.grey400,
            ),
            const Gap(16),
            Text('Sign in required', style: AppTextStyles.h4),
            const Gap(8),
            Text(
              'Log in to manage your area notification alerts.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Gap(24),
            ElevatedButton(onPressed: onLogin, child: const Text('Sign In')),
          ],
        ),
      ),
    );
  }
}
