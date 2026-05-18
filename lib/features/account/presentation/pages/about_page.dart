import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:rentora/features/account/presentation/widgets/about/section_header.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/about/action_tile.dart';
import '../widgets/about/animated_section.dart';
import '../widgets/about/feature_row.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!success) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // Use surface color for a seamless, flat look instead of a darker background
        backgroundColor: AppColors.surface,
        body: CustomScrollView(
          slivers: [
            // ── Hero ──────────────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.primary,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF5BA8F5),
                        AppColors.primary,
                        Color(0xFF1A3A6B),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Gap(48),
                        // Logo
                        Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 24,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.asset(
                                  'assets/images/no_bg.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.home_rounded,
                                    size: 48,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .scale(
                              begin: const Offset(0.7, 0.7),
                              duration: 500.ms,
                              curve: Curves.elasticOut,
                            )
                            .fadeIn(duration: 300.ms),
                        const Gap(16),
                        Text(
                          'Rentora',
                          style: AppTextStyles.h1.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
                        const Gap(6),
                        Text(
                          'Find your perfect home in Uganda',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate(delay: 130.ms).fadeIn(duration: 300.ms),
                        const Gap(10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            'Version 1.0.0',
                            style: AppTextStyles.labelSm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ).animate(delay: 180.ms).fadeIn(duration: 300.ms),
                        const Gap(8),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Content ───────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 64),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            onTap: () =>
                                _launch('mailto:rentorahouselink@gmail.com'),
                          ),
                          const Gap(8),
                          ActionTile(
                            icon: Icons.gavel_rounded,
                            label: 'Terms of Service',
                            onTap: () => _launch(
                              'https://rentora-houselink.vercel.app/terms',
                            ),
                          ),
                          const Gap(8),
                          ActionTile(
                            icon: Icons.privacy_tip_outlined,
                            label: 'Privacy Policy',
                            onTap: () => _launch(
                              'https://rentora-houselink.vercel.app/privacy',
                            ),
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
            ),
          ],
        ),
      ),
    );
  }
}

/// A soft, modern divider
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: AppColors.grey100);
  }
}
