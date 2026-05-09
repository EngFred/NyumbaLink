import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/entities/auth_entities.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  /// Extracts the initials from the user's name for the Avatar (e.g., "John Doe" -> "JD")
  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  /// Shows a professional confirmation dialog before logging out
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Log Out', style: AppTextStyles.h3),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: AppTextStyles.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // 1. Loading State
    if (authState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Authenticated State (Logged In)
    if (authState.isAuthenticated && authState.user != null) {
      return _buildProfileView(context, ref, authState.user!);
    }

    // 3. Unauthenticated State (Guest)
    return _buildUnauthenticatedView(context);
  }

  /// The UI shown when the user is successfully logged in.
  Widget _buildProfileView(BuildContext context, WidgetRef ref, AuthUser user) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile Header ──
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary100,
                    child: Text(
                      _getInitials(user.name),
                      style: AppTextStyles.displayMd.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Gap(16),
                  Text(user.name, style: AppTextStyles.h2),
                  const Gap(4),
                  Text(
                    user.email,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Gap(12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Gap(40),
            Text('Account Settings', style: AppTextStyles.h4),
            const Gap(12),

            // ── Settings List ──
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.grey600,
                    ),
                    title: Text('Edit Profile', style: AppTextStyles.labelLg),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.grey400,
                    ),
                    onTap: () => context.push('/edit-profile'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.grey600,
                    ),
                    title: Text(
                      'Change Password',
                      style: AppTextStyles.labelLg,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.grey400,
                    ),
                    onTap: () => context.push(
                      '/change-password',
                    ), // <-- Updated Navigation
                  ),
                ],
              ),
            ),

            const Gap(32),

            // ── Log Out Button ──
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(
                    color: AppColors.errorLight,
                    width: 1.5,
                  ),
                  backgroundColor: AppColors.errorLight.withOpacity(0.3),
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text('Log Out'),
                onPressed: () => _showLogoutDialog(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The UI shown when the user is browsing as a guest.
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
                color: AppColors.accent50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 64,
                color: AppColors.accent,
              ),
            ),
            const Gap(32),
            Text(
              'Unlock everything',
              style: AppTextStyles.h1,
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            Text(
              'Create an account to securely back up your bookings, save properties across devices, and auto-fill your details when booking.',
              style: AppTextStyles.bodyLg.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(48),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.register),
              child: const Text('Create an account'),
            ),
            const Gap(16),
            TextButton(
              onPressed: () => context.push(AppRoutes.login),
              child: const Text('Already have an account? Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
