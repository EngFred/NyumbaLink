import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:rentora/features/properties/domain/entities/property_entities.dart';
import 'package:rentora/features/properties/presentation/pages/browse_page.dart';
import 'package:rentora/features/properties/presentation/widgets/browse/featured_hero_card.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class FeaturedCarouselSection extends StatefulWidget {
  const FeaturedCarouselSection({super.key, required this.properties});
  final List<Property> properties;

  @override
  State<FeaturedCarouselSection> createState() =>
      _FeaturedCarouselSectionState();
}

class _FeaturedCarouselSectionState extends State<FeaturedCarouselSection> {
  final _pageCtrl = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    // Only auto-scroll if there's more than one card.
    if (widget.properties.length <= 1) return;

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageCtrl.hasClients) return;
      final next = (_currentPage + 1) % widget.properties.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void _resetAutoScroll() {
    _autoScrollTimer?.cancel();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Section eyebrow label ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 10),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: kFeaturedGold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Gap(8),
                  Text(
                    '🏆  Featured Properties',
                    style: AppTextStyles.labelLg.copyWith(
                      color: kFeaturedGold,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            // ── Carousel ──────────────────────────────────────────────────────
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _pageCtrl,
                // When the user swipes manually, update page state AND
                // reset the timer so it doesn't immediately jump.
                onPageChanged: (i) {
                  setState(() => _currentPage = i);
                  _resetAutoScroll();
                },
                itemCount: widget.properties.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FeaturedHeroCard(property: widget.properties[i]),
                ),
              ),
            ),

            // ── Page indicator dots ────────────────────────────────────────────
            if (widget.properties.length > 1) ...[
              const Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.properties.length, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.grey300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              const Gap(4),
            ],
          ],
        )
        .animate()
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.06, end: 0, duration: 350.ms, curve: Curves.easeOut);
  }
}
