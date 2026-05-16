import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rentora/features/account/presentation/widgets/account/guest_view.dart';
import 'package:rentora/features/account/presentation/widgets/account/profile_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  String _initials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.length > 1
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : parts[0][0].toUpperCase();
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log Out', style: AppTextStyles.h3),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
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
    final auth = ref.watch(authProvider);

    // Determine the baseline content layer
    final Widget baseContent;
    if (auth.isAuthenticated && auth.user != null) {
      baseContent = ProfileView(
        user: auth.user!,
        initials: _initials(auth.user!.name),
        onLogout: () => _confirmLogout(context, ref),
      );
    } else {
      baseContent = const GuestView();
    }

    return Stack(
      children: [
        // ── Main Content Layer ──────────────────────────────────────────────
        baseContent,

        // ── Premium Loading Overlay Layer ───────────────────────────────────
        if (auth.isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing:
                  true, // Thoroughly blocks all taps on the underlying view
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                  child: Container(
                    color: Colors.black.withOpacity(
                      0.25,
                    ), // Smooth, dark overlay tint
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
