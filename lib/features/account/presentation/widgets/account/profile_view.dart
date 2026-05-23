import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rentora/features/account/presentation/widgets/account/delete_account_button.dart';
import 'package:rentora/features/account/presentation/widgets/account/logout_button.dart';
import 'package:rentora/features/account/presentation/widgets/account/section_label.dart';
import 'package:rentora/features/account/presentation/widgets/account/settings_card.dart';
import 'package:rentora/features/account/presentation/widgets/account/settings_tile.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../auth/domain/entities/auth_entities.dart';
import 'profile_header.dart';

import '../../../../../core/providers/app_version_provider.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({
    super.key,
    required this.user,
    required this.initials,
    required this.onLogout,
    required this.onAreaAlerts,
  });

  final AuthUser user;
  final String initials;
  final VoidCallback onLogout;
  final VoidCallback onAreaAlerts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch live app version
    final version = ref.watch(appVersionProvider).valueOrNull ?? '...';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          ProfileHeader(
            user: user,
            initials: initials,
          ).animate().fadeIn(duration: 400.ms),

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
                          onTap: user.isSocialAuth
                              ? () {} // Disabled action
                              : () => context.push('/change-password'),
                        ),
                      ],
                    )
                    .animate(delay: 80.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.04, end: 0),

                if (user.isSocialAuth) ...[
                  const Gap(10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: AppColors.textHint.withOpacity(0.8),
                        ),
                        const Gap(6),
                        Expanded(
                          child: Text(
                            'Password changes are disabled because you signed in with a social account.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textHint,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
                ],

                const Gap(24),

                const SectionLabel('Support'),
                const Gap(10),
                SettingsCard(
                      tiles: [
                        SettingsTile(
                          icon: Icons.notifications_active_outlined,
                          label: 'Area Alerts',
                          onTap: onAreaAlerts,
                        ),
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
                            'v$version',
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

                LogoutButton(
                  onTap: onLogout,
                ).animate(delay: 180.ms).fadeIn(duration: 300.ms),
                const Gap(12),

                const DeleteAccountButton()
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
