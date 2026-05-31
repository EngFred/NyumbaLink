import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:rentora/features/properties/presentation/widgets/property-detail/carousel_dots.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/hero_badge.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/hero_status_badge.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../core/utils/enum_helpers.dart';
import '../../../domain/entities/property_entities.dart';

/// Bottom overlay showing type/status badges, price, billing cycle, and
/// optional pagination dots.
///
/// Returns a plain [Padding] + [Column] — wrap in a [Positioned] inside the
/// hero [Stack] to anchor it to the bottom.
class HeroPriceOverlay extends StatelessWidget {
  const HeroPriceOverlay({
    super.key,
    required this.property,
    this.dotCount = 0,
    this.currentDot = 0,
    this.reserveRightSpace = false,
  });

  final Property property;

  /// Total number of slides. Pass ≤ 1 to suppress dots.
  final int dotCount;
  final int currentDot;

  /// When [true], 140 px of right padding is added to the dots row so a
  /// floating button at `bottom: 22, right: 18` does not overlap them.
  final bool reserveRightSpace;

  @override
  Widget build(BuildContext context) {
    final hasMultiple = dotCount > 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasMultiple) ...[
            Padding(
              padding: EdgeInsets.only(right: reserveRightSpace ? 140.0 : 0.0),
              child: CarouselDots(count: dotCount, current: currentDot),
            ),
            const Gap(14),
          ],
          Row(
            children: [
              HeroBadge(
                icon: PropertyTypeHelper.icon(property.type),
                label: PropertyTypeHelper.singularLabel(property.type),
              ),
              const Gap(8),
              HeroStatusBadge(status: property.status),
            ],
          ),
          const Gap(8),
          Text(
            CurrencyFormatter.format(property.price),
            style: AppTextStyles.priceLg.copyWith(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.0,
              shadows: const [Shadow(blurRadius: 8, color: Colors.black45)],
            ),
          ),
          if (!property.isForSale) ...[
            const Gap(2),
            Text(
              BillingCycleHelper.full(property.billingCycle),
              style: AppTextStyles.labelSm.copyWith(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }
}
