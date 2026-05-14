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

class HeroCarousel extends StatelessWidget {
  const HeroCarousel({
    super.key,
    required this.property,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
    required this.onTap,
  });

  final Property property;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Images ──────────────────────────────────────────────────────────
        GestureDetector(
          onTap: onTap,
          child: property.images.isEmpty
              ? HeroFallback(type: property.type)
              : PageView.builder(
                  controller: pageController,
                  onPageChanged: onPageChanged,
                  itemCount: property.images.length,
                  itemBuilder: (_, i) => CachedNetworkImage(
                    imageUrl: property.images[i].url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const ColoredBox(color: AppColors.grey100),
                    errorWidget: (_, __, ___) =>
                        HeroFallback(type: property.type),
                  ),
                ),
        ),

        // ── Top scrim (for button readability) ──────────────────────────────
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

        // ── Bottom scrim (for info readability) ──────────────────────────────
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
                // Dots
                if (property.images.length > 1) ...[
                  CarouselDots(
                    count: property.images.length,
                    current: currentIndex,
                  ),
                  const Gap(14),
                ],

                // Type + Status badges
                Row(
                  children: [
                    HeroBadge(
                      icon: PropertyTypeHelper.icon(property.type),
                      label: PropertyTypeHelper.label(property.type),
                    ),
                    const Gap(8),
                    HeroStatusBadge(status: property.status),
                    if (property.images.length > 1) ...[
                      const Spacer(),
                      Text(
                        '${currentIndex + 1} / ${property.images.length}',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),

                const Gap(8),

                // Price
                Text(
                  CurrencyFormatter.format(property.price),
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
                const Gap(2),
                Text(
                  BillingCycleHelper.full(property.billingCycle),
                  style: AppTextStyles.labelSm.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
