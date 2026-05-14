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
                          label: 'About NyumbaLink',
                          onTap: () {},
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

                const Gap(40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
