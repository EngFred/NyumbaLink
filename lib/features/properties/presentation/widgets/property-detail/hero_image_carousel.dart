import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:rentora/features/properties/presentation/widgets/browse/hero_fallback.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/hero_price_overlay.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/hero_scrims.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/property_entities.dart';

/// Auto-scrolling image carousel used in the hero [SliverAppBar].
/// Owns its own timer, page state, and the "View all photos" button.
class HeroImageCarousel extends StatefulWidget {
  const HeroImageCarousel({
    super.key,
    required this.property,
    required this.onPageChanged,
    required this.onViewAllTap,
  });

  final Property property;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onViewAllTap;

  @override
  State<HeroImageCarousel> createState() => _HeroImageCarouselState();
}

class _HeroImageCarouselState extends State<HeroImageCarousel> {
  late final PageController _pageCtrl;
  int _currentIndex = 0;
  int _direction = 1;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    if (widget.property.images.length <= 1) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageCtrl.hasClients) return;
      int next = _currentIndex + _direction;
      if (next >= widget.property.images.length) {
        _direction = -1;
        next = _currentIndex + _direction;
      }
      if (next < 0) {
        _direction = 1;
        next = _currentIndex + _direction;
      }
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

  void _onPageChanged(int i) {
    setState(() => _currentIndex = i);
    _resetAutoScroll();
    widget.onPageChanged(i);
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.property.images;
    final hasMultiple = images.length > 1;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Image page view ──────────────────────────────────────────────
        images.isEmpty
            ? HeroFallback(type: widget.property.type)
            : PageView.builder(
                controller: _pageCtrl,
                onPageChanged: _onPageChanged,
                itemCount: images.length,
                itemBuilder: (_, i) => CachedNetworkImage(
                  imageUrl: images[i].url,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      const ColoredBox(color: AppColors.grey100),
                  errorWidget: (_, __, ___) =>
                      HeroFallback(type: widget.property.type),
                ),
              ),

        // ── Gradient scrims ──────────────────────────────────────────────
        const HeroScrims(),

        // ── "View all photos" / "View photo" button ──────────────────────
        if (images.isNotEmpty)
          Positioned(
            bottom: 22,
            right: 18,
            child: GestureDetector(
              onTap: widget.onViewAllTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white,
                      size: 13,
                    ),
                    const Gap(5),
                    Text(
                      hasMultiple
                          ? 'View all ${images.length} photos'
                          : 'View photo',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ── Price / badges / dots ────────────────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: HeroPriceOverlay(
            property: widget.property,
            dotCount: images.length,
            currentDot: _currentIndex,
            reserveRightSpace: images.isNotEmpty,
          ),
        ),
      ],
    );
  }
}
