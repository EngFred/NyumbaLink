import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class GuestView extends StatelessWidget {
  const GuestView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Clean Flat Header ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: SafeArea(
              bottom: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.grey100, // Subtle placeholder color
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 32,
                      color: AppColors.grey500,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Guest',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          'Not signed in',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms),

          // ── Content ────────────────────────────────────────────────────────
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
                const Gap(16),
                const _BenefitRow(
                  icon: Icons.receipt_long_outlined,
                  title: 'Track your bookings',
                  subtitle: 'Manage all your requests in one place.',
                ),
                const Gap(16),
                const _BenefitRow(
                  icon: Icons.notifications_outlined,
                  title: 'Real-time notifications',
                  subtitle: 'Get instant alerts on booking updates.',
                ),

                const Gap(48),

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
            color: AppColors.primary.withOpacity(0.08),
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
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.04, end: 0);
  }
}
