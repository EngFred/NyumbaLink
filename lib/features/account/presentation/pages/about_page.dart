import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

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
        backgroundColor: AppColors.background,
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
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
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
                          ),
                        ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
                        const Gap(6),
                        Text(
                          'Find your perfect home in Uganda',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ).animate(delay: 130.ms).fadeIn(duration: 300.ms),
                        const Gap(12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'Version 1.0.0',
                            style: AppTextStyles.labelSm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ).animate(delay: 180.ms).fadeIn(duration: 300.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Content ───────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Mission ──────────────────────────────────────────────
                    _SectionCard(
                      delay: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeader(
                            icon: Icons.flag_outlined,
                            label: 'Our Mission',
                          ),
                          const Gap(12),
                          Text(
                            'Rentora connects Ugandans with quality rental spaces from apartments and houses to hostels and commercial properties. We make the search simple, transparent, and fast so you can focus on settling in, not searching.',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Gap(16),

                    // ── What you can do ──────────────────────────────────────
                    const _SectionCard(
                      delay: 60,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            icon: Icons.star_outline_rounded,
                            label: 'What You Can Do',
                          ),
                          Gap(12),
                          _FeatureRow(
                            icon: Icons.search_rounded,
                            title: 'Browse Listings',
                            subtitle:
                                'Filter by type, price, area, and university proximity.',
                          ),
                          Gap(10),
                          _FeatureRow(
                            icon: Icons.calendar_month_outlined,
                            title: 'Book Online',
                            subtitle:
                                'Submit booking requests and track them in one place.',
                          ),
                          Gap(10),
                          _FeatureRow(
                            icon: Icons.hotel_outlined,
                            title: 'Hostel Rooms',
                            subtitle:
                                'Browse and book individual hostel rooms near universities.',
                          ),
                          Gap(10),
                          _FeatureRow(
                            icon: Icons.favorite_border_rounded,
                            title: 'Save Properties',
                            subtitle:
                                'Save your favourites and sync them across devices.',
                          ),
                          Gap(10),
                          _FeatureRow(
                            icon: Icons.notifications_outlined,
                            title: 'Real-time Alerts',
                            subtitle:
                                'Get notified instantly when bookings are updated.',
                          ),
                        ],
                      ),
                    ),

                    const Gap(16),

                    // ── Contact ──────────────────────────────────────────────
                    _SectionCard(
                      delay: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeader(
                            icon: Icons.support_agent_rounded,
                            label: 'Get in Touch',
                          ),
                          const Gap(12),
                          _ContactTile(
                            icon: Icons.email_outlined,
                            label: 'Email Support',
                            value: 'rentorahouselink@gmail.com',
                            onTap: () =>
                                _launch('mailto:rentorahouselink@gmail.com'),
                          ),
                          // const Divider(
                          //   height: 1,
                          //   color: AppColors.grey100,
                          //   indent: 16,
                          //   endIndent: 16,
                          // ),
                          // _ContactTile(
                          //   icon: Icons.language_rounded,
                          //   label: 'Website',
                          //   value: 'www.rentora.ug',
                          //   onTap: () => _launch('https://rentora.ug'),
                          // ),
                        ],
                      ),
                    ),

                    const Gap(16),

                    // ── Legal ────────────────────────────────────────────────
                    _SectionCard(
                      delay: 180,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeader(
                            icon: Icons.gavel_rounded,
                            label: 'Legal',
                          ),
                          const Gap(4),
                          _LegalTile(
                            label: 'Terms of Service',
                            onTap: () => _launch(
                              'https://rentora-houselink.vercel.app/terms',
                            ),
                          ),
                          const Divider(
                            height: 1,
                            color: AppColors.grey100,
                            indent: 16,
                            endIndent: 16,
                          ),
                          _LegalTile(
                            label: 'Privacy Policy',
                            onTap: () => _launch(
                              'https://rentora-houselink.vercel.app/privacy',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Gap(32),

                    // ── Footer ───────────────────────────────────────────────
                    Center(
                      child: Text(
                        '© ${DateTime.now().year} Rentora Uganda',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHint,
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

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.delay = 0});
  final Widget child;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: child,
        )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.04, end: 0, duration: 300.ms);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: AppColors.primary),
        ),
        const Gap(10),
        Text(label, style: AppTextStyles.h4),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const Gap(12),
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
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const Gap(12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(value, style: AppTextStyles.labelMd),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalTile extends StatelessWidget {
  const _LegalTile({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Text(label, style: AppTextStyles.labelMd),
            const Spacer(),
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
