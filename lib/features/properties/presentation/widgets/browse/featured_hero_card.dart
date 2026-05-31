import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:rentora/features/properties/domain/entities/property_entities.dart';
import 'package:rentora/features/properties/presentation/widgets/browse/featured_badge.dart';
import 'package:rentora/features/properties/presentation/widgets/browse/hero_fallback.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../core/utils/enum_helpers.dart';

class FeaturedHeroCard extends StatelessWidget {
  const FeaturedHeroCard({super.key, required this.property});
  final Property property;

  String? _shortCycle(String? cycle) {
    if (cycle == null || cycle.isEmpty) return null;
    return switch (cycle.toUpperCase()) {
      'DAILY' => '/day',
      'MONTHLY' => '/mo',
      'QUARTERLY' => '/qtr',
      'FOUR_MONTHS' => '/4mo',
      'BIANNUAL' => '/6mo',
      'ANNUAL' => '/yr',
      'SEMESTER' => '/sem',
      _ => '/${cycle.toLowerCase()}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isForSale = property.isForSale;
    final cycleLabel = _shortCycle(property.billingCycle);

    return GestureDetector(
      onTap: () => context.push('/properties/${property.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background image ──────────────────────────────────────────
            if (property.thumbnailUrl != null)
              CachedNetworkImage(
                imageUrl: property.thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    const ColoredBox(color: AppColors.grey200),
                errorWidget: (_, __, ___) => HeroFallback(type: property.type),
              )
            else
              HeroFallback(type: property.type),

            // ── Dark gradient overlay ─────────────────────────────────────
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.0, 0.55, 1.0],
                  colors: [
                    Color(0xEE000000),
                    Color(0x88000000),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // ── Recommended badge — top left ──────────────────────────────
            const Positioned(top: 12, left: 12, child: FeaturedBadge()),

            // ── Type pill — bottom right (single, clean) ──────────────────
            Positioned(
              bottom: 14,
              right: 14,
              child: _TypePill(type: property.type),
            ),

            // ── Text content — bottom left ────────────────────────────────
            Positioned(
              bottom: 14,
              left: 14,
              right: 90, // breathing room for the single right-side pill
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Title + listing purpose inline ─────────────────────
                  // e.g. "Testing — For Sale"  or  "rental — For Rent"
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: property.displayTitle,
                          style: AppTextStyles.h4.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: isForSale ? ' — For Sale' : ' — For Rent',
                          style: AppTextStyles.h4.copyWith(
                            color: Colors.white60,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Gap(4),

                  // ── Price — no cycle suffix for sale listings ───────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CurrencyFormatter.format(property.price),
                        style: AppTextStyles.priceSm.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!isForSale && cycleLabel != null) ...[
                        const Gap(2),
                        Text(
                          cycleLabel,
                          style: const TextStyle(
                            color: Color(0xAAFFFFFF),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const Gap(3),

                  // ── Location ────────────────────────────────────────────
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 11,
                        color: Colors.white70,
                      ),
                      const Gap(3),
                      Flexible(
                        child: Text(
                          property.locationDisplay,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Property type pill ────────────────────────────────────────────────────────
// Single white pill — unambiguous property category, high contrast on dark card.

class _TypePill extends StatelessWidget {
  const _TypePill({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PropertyTypeHelper.icon(type),
            size: 11,
            color: AppColors.primary,
          ),
          const Gap(4),
          Text(
            PropertyTypeHelper.singularLabel(type),
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
