import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rentora/features/properties/presentation/widgets/browse/hero_fallback.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/carousel_dots.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/hero_badge.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/hero_status_badge.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../core/utils/enum_helpers.dart';
import '../../../domain/entities/property_entities.dart';

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({
    super.key,
    required this.property,
    required this.onPageChanged,
    required this.onViewAllTap,
  });

  final Property property;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onViewAllTap;

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
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
        // ── Images ──────────────────────────────────────────────────────────
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

        // ── Top scrim ────────────────────────────────────────────────────────
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 120,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xBB000000), Colors.transparent],
              ),
            ),
          ),
        ),

        // ── Bottom scrim ─────────────────────────────────────────────────────
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xEE000000), Colors.transparent],
              ),
            ),
          ),
        ),

        // ── "View all photos" / "View photo" button ───────────────────────────
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

        // ── Bottom overlay: price + badges + dots ────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dots — only when multiple images; leave space for button
                if (hasMultiple) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 140),
                    child: CarouselDots(
                      count: images.length,
                      current: _currentIndex,
                    ),
                  ),
                  const Gap(14),
                ],

                // Type + Status badges
                Row(
                  children: [
                    HeroBadge(
                      icon: PropertyTypeHelper.icon(widget.property.type),
                      label: PropertyTypeHelper.singularLabel(
                        widget.property.type,
                      ),
                    ),
                    const Gap(8),
                    HeroStatusBadge(status: widget.property.status),
                  ],
                ),

                const Gap(8),

                // Price
                // Price
                Text(
                  CurrencyFormatter.format(widget.property.price),
                  style: AppTextStyles.priceLg.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                    shadows: [
                      const Shadow(blurRadius: 8, color: Colors.black45),
                    ],
                  ),
                ),
                // Only show billing cycle for rent listings —
                // sale properties have no recurring cycle.
                if (!widget.property.isForSale) ...[
                  const Gap(2),
                  Text(
                    BillingCycleHelper.full(widget.property.billingCycle),
                    style: AppTextStyles.labelSm.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
