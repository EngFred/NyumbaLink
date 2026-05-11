import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    if (auth.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (auth.isAuthenticated && auth.user != null) {
      return _ProfileView(
        user: auth.user!,
        initials: _initials(auth.user!.name),
        onLogout: () => _confirmLogout(context, ref),
      );
    }
    return const _GuestView();
  }
}

// ── Authenticated profile ─────────────────────────────────────────────────────

class _ProfileView extends StatelessWidget {
  const _ProfileView({
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
          _ProfileHeader(
            user: user,
            initials: initials,
          ).animate().fadeIn(duration: 400.ms),

          // ── Settings cards ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel('Account'),
                const Gap(10),
                _SettingsCard(
                      tiles: [
                        _SettingsTile(
                          icon: Icons.person_outline_rounded,
                          label: 'Edit Profile',
                          onTap: () => context.push('/edit-profile'),
                        ),
                        _SettingsTile(
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

                const _SectionLabel('Support'),
                const Gap(10),
                _SettingsCard(
                      tiles: [
                        _SettingsTile(
                          icon: Icons.feedback_outlined,
                          label: 'Report an Issue',
                          onTap: () => context.push('/complaint'),
                        ),
                        _SettingsTile(
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
                _LogoutButton(
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.initials});

  final AuthUser user;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF1A3A6B)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const Gap(14),

              Text(
                user.name,
                style: AppTextStyles.h2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(4),
              Text(
                user.email,
                style: AppTextStyles.bodyMd.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const Gap(12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                child: Text(
                  user.role,
                  style: AppTextStyles.labelSm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.labelSm.copyWith(
        color: AppColors.textHint,
        letterSpacing: 1.2,
        fontSize: 11,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.tiles});
  final List<_SettingsTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(tiles.length * 2 - 1, (i) {
          if (i.isOdd) {
            return const Divider(
              height: 1,
              color: AppColors.grey100,
              indent: 52,
            );
          }
          return tiles[i ~/ 2];
        }),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.grey600;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: destructive ? AppColors.errorLight : AppColors.grey100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const Gap(14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelLg.copyWith(
                  color: destructive ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.grey400,
                ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.errorLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
            const Gap(10),
            Text(
              'Log Out',
              style: AppTextStyles.labelLg.copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Guest view ────────────────────────────────────────────────────────────────

class _GuestView extends StatelessWidget {
  const _GuestView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Color(0xFF1A3A6B)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const Gap(14),
                    Text(
                      'Guest',
                      style: AppTextStyles.h2.copyWith(color: Colors.white),
                    ),
                    const Gap(4),
                    Text(
                      'Not signed in',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Gap(8),
                // Benefits
                const _BenefitRow(
                  icon: Icons.cloud_sync_rounded,
                  title: 'Sync across devices',
                  subtitle: 'Access your saved properties anywhere.',
                ),
                const Gap(12),
                const _BenefitRow(
                  icon: Icons.receipt_long_outlined,
                  title: 'Track your bookings',
                  subtitle: 'Manage all your requests in one place.',
                ),
                const Gap(12),
                const _BenefitRow(
                  icon: Icons.notifications_outlined,
                  title: 'Real-time notifications',
                  subtitle: 'Get instant alerts on booking updates.',
                ),
                const Gap(36),
                ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.register),
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: const Text('Create an Account'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
                const Gap(12),
                OutlinedButton(
                  onPressed: () => context.push(AppRoutes.login),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: const Text('Sign In'),
                ).animate(delay: 160.ms).fadeIn(duration: 300.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.labelLg),
              const Gap(2),
              Text(
                subtitle,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.04, end: 0);
  }
}
