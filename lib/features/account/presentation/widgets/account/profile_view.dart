import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:rentora/features/account/presentation/widgets/account/logout_button.dart';
import 'package:rentora/features/account/presentation/widgets/account/section_label.dart';
import 'package:rentora/features/account/presentation/widgets/account/settings_card.dart';
import 'package:rentora/features/account/presentation/widgets/account/settings_tile.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../auth/domain/entities/auth_entities.dart';
import 'profile_header.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
    required this.user,
    required this.initials,
    required this.onLogout,
  });

  final AuthUser user;
  final String initials;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ── Gradient header ──────────────────────────────────────────
          ProfileHeader(
            user: user,
            initials: initials,
          ).animate().fadeIn(duration: 400.ms),

          // ── Settings cards ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Account'),
                const Gap(10),
                SettingsCard(
                      tiles: [
                        SettingsTile(
                          icon: Icons.person_outline_rounded,
                          label: 'Edit Profile',
                          onTap: () => context.push('/edit-profile'),
                        ),
                        SettingsTile(
                          icon: Icons.lock_outline_rounded,
                          label: 'Change Password',
                          onTap: () => context.push('/change-password'),
                        ),
                      ],
                    )
                    .animate(delay: 80.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.04, end: 0),
                const Gap(20),

                const SectionLabel('Support'),
                const Gap(10),
                SettingsCard(
                      tiles: [
                        SettingsTile(
                          icon: Icons.feedback_outlined,
                          label: 'Report an Issue',
                          onTap: () => context.push('/complaint'),
                        ),
                        SettingsTile(
                          icon: Icons.info_outline_rounded,
                          label: 'About Rentora',
                          onTap: () => context.push('/about'),
                          trailing: Text(
                            'v1.0.0',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.grey500,
                            ),
                          ),
                        ),
                      ],
                    )
                    .animate(delay: 130.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.04, end: 0),
                const Gap(32),

                // ── Log out ────────────────────────────────────────────
                LogoutButton(
                  onTap: onLogout,
                ).animate(delay: 180.ms).fadeIn(duration: 300.ms),
                const Gap(12),

                // ── Delete Account (Coming Soon) ───────────────────────
                const _DeleteAccountButton()
                    .animate(delay: 220.ms)
                    .fadeIn(duration: 300.ms),
                const Gap(40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Private low-contrast alternative widget for self-service account deletion.
class _DeleteAccountButton extends StatelessWidget {
  const _DeleteAccountButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.surface,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.grey200),
              ),
              duration: const Duration(seconds: 4),
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Account Deletion Coming Soon',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          'Self-service data removal will be available in the next app update.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
                color: AppColors.textSecondary.withOpacity(0.6),
                decoration: TextDecoration.underline,
                decorationColor: AppColors.grey300,
              ),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Text(
                'Coming Soon',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.grey500,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
