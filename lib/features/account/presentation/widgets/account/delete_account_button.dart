import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

class DeleteAccountButton extends ConsumerWidget {
  const DeleteAccountButton({super.key});

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    // ── Step 1: Warn the user ─────────────────────────────────────────────
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.red,
                size: 22,
              ),
            ),
            const Gap(12),
            const Text('Delete Account'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete your account?',
              style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
            ),
            const Gap(12),
            Text(
              'Your account will be scheduled for permanent deletion. '
              'You have 30 days to contact support at support@rentora.ug '
              'to cancel this request.',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const Gap(12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 16,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      'All your data — bookings, favourites, and profile — will be deleted.',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.red.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Yes, Delete',
              style: AppTextStyles.labelMd.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // ── Step 2: Execute deletion ──────────────────────────────────────────
    final success = await ref.read(authProvider.notifier).deleteAccount();

    if (!context.mounted) return;

    if (success) {
      // Navigate to login — session is gone
      context.go('/login');

      // Small delay to let the route settle before showing the snackbar
      await Future.delayed(const Duration(milliseconds: 300));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.surface,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
                ),
                const Gap(10),
                Expanded(
                  child: Text(
                    'Account deletion scheduled. Check your email for details.',
                    style: AppTextStyles.bodySm,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      final error = ref.read(authProvider).error ?? 'Something went wrong.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(
            error,
            style: AppTextStyles.bodySm.copyWith(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));

    return Center(
      child: TextButton(
        onPressed: isLoading ? null : () => _handleDelete(context, ref),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          splashFactory: NoSplash.splashFactory,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Delete Account',
              style: AppTextStyles.bodySm.copyWith(
                color: Colors.red.withOpacity(0.7),
                decoration: TextDecoration.underline,
                decorationColor: Colors.red.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
