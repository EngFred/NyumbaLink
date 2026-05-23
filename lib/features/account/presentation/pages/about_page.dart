import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/about/section_header.dart';
import '../widgets/about/action_tile.dart';
import '../widgets/about/animated_section.dart';
import '../widgets/about/feature_row.dart';

import '../../../../core/providers/app_version_provider.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!success) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch live app version
    final version = ref.watch(appVersionProvider).valueOrNull ?? '...';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: AppColors.textPrimary,
            onPressed: () => context.pop(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 64),
          children: [
            // ── Clean Hero Header ─────────────────────────────────────────────
            Column(
              children: [
                Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/no_bg.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.home_rounded,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(),
                const Gap(16),
                Text(
                  'Rentora',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ).animate(delay: 60.ms).fadeIn(duration: 300.ms),
                const Gap(4),
                Text(
                  'Find your perfect home in Uganda',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
                const Gap(12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Version $version',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ).animate(delay: 140.ms).fadeIn(duration: 300.ms),
              ],
            ),

            const Gap(40),

            // ── Mission ──────────────────────────────────────────────
            AnimatedSection(
              delay: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(label: 'Our Mission'),
                  const Gap(16),
                  Text(
                    'Rentora connects Ugandans with quality rental spaces — from apartments and houses to hostels and commercial properties. We make the search simple, transparent, and fast so you can focus on settling in, not searching.',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.7,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(32),
            const _Divider(),
            const Gap(32),

            // ── What you can do ──────────────────────────────────────
            const AnimatedSection(
              delay: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(label: 'What You Can Do'),
                  Gap(24),
                  FeatureRow(
                    icon: Icons.search_rounded,
                    title: 'Browse Listings',
                    subtitle:
                        'Filter by type, price, area, and university proximity.',
                  ),
                  Gap(20),
                  FeatureRow(
                    icon: Icons.calendar_month_outlined,
                    title: 'Book Online',
                    subtitle:
                        'Submit booking requests and track them in one place.',
                  ),
                  Gap(20),
                  FeatureRow(
                    icon: Icons.hotel_outlined,
                    title: 'Hostel Rooms',
                    subtitle:
                        'Browse and book individual hostel rooms near universities.',
                  ),
                  Gap(20),
                  FeatureRow(
                    icon: Icons.favorite_border_rounded,
                    title: 'Save Properties',
                    subtitle:
                        'Save your favourites and sync them across devices.',
                  ),
                  Gap(20),
                  FeatureRow(
                    icon: Icons.notifications_outlined,
                    title: 'Real-time Alerts',
                    subtitle:
                        'Get notified instantly when bookings are updated.',
                  ),
                ],
              ),
            ),
            const Gap(32),
            const _Divider(),
            const Gap(32),

            // ── Contact & Legal ──────────────────────────────────────
            AnimatedSection(
              delay: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(label: 'Support & Legal'),
                  const Gap(16),
                  ActionTile(
                    icon: Icons.email_outlined,
                    label: 'Contact Support',
                    onTap: () => _launch('mailto:rentorahouselink@gmail.com'),
                  ),
                  const Gap(8),
                  ActionTile(
                    icon: Icons.gavel_rounded,
                    label: 'Terms of Service',
                    onTap: () =>
                        _launch('https://rentora-houselink.vercel.app/terms'),
                  ),
                  const Gap(8),
                  ActionTile(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    onTap: () =>
                        _launch('https://rentora-houselink.vercel.app/privacy'),
                  ),
                ],
              ),
            ),
            const Gap(48),

            // ── Footer ───────────────────────────────────────────────
            Center(
              child: Text(
                '© ${DateTime.now().year} Rentora Uganda',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textHint,
                  letterSpacing: 0.3,
                ),
              ),
            ).animate(delay: 240.ms).fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: AppColors.grey100);
  }
}
