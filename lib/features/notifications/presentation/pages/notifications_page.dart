import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the authentication state
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: authState.isAuthenticated
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications_active_outlined,
                    size: 64,
                    color: AppColors.grey300,
                  ),
                  const Gap(16),
                  Text('Coming Soon', style: AppTextStyles.h3),
                  const Gap(8),
                  Text(
                    'Your notifications will appear here.',
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
            )
          : _buildUnauthenticatedView(context),
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.primary50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const Gap(32),
            Text(
              'Stay in the loop',
              style: AppTextStyles.h1,
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            Text(
              'Sign in to receive instant alerts when your booking requests are approved, or when landlords reply to your complaints.',
              style: AppTextStyles.bodyLg.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(48),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.login),
              child: const Text('Sign in'),
            ),
            const Gap(16),
            OutlinedButton(
              onPressed: () => context.push(AppRoutes.register),
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
