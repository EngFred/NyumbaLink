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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/properties/${property.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
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

            // Dark gradient overlay from bottom
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

            // Featured badge — top left
            const Positioned(top: 12, left: 12, child: FeaturedBadge()),

            // Property type pill — bottom right
            Positioned(
              bottom: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PropertyTypeHelper.icon(property.type),
                      size: 11,
                      color: AppColors.primary,
                    ),
                    const Gap(4),
                    Text(
                      PropertyTypeHelper.label(property.type),
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content — bottom left
            Positioned(
              bottom: 14,
              left: 14,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    property.title,
                    style: AppTextStyles.h4.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(3),
                  Text(
                    CurrencyFormatter.format(property.price),
                    style: AppTextStyles.priceSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(3),
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
                          '${property.area}, ${property.district.name}',
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
