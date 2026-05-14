import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rentora/features/properties/presentation/providers/saved_properties_provider.dart';
import 'package:rentora/features/properties/presentation/widgets/saved-properties/thumbnail_fallback.dart';
import 'package:rentora/features/properties/presentation/widgets/saved-properties/type_pill.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/currency_formatter.dart';

class SavedPropertyCard extends StatelessWidget {
  const SavedPropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.onRemove,
  });
  final SavedProperty property;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 110,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Thumbnail ────────────────────────────────────────────────
              SizedBox(
                width: 110,
                child: property.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: property.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            const ColoredBox(color: AppColors.grey100),
                        errorWidget: (_, __, ___) =>
                            ThumbnailFallback(type: property.type),
                      )
                    : ThumbnailFallback(type: property.type),
              ),

              // ── Info ──────────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.title,
                            style: AppTextStyles.labelLg,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Gap(4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 11,
                                color: AppColors.accent,
                              ),
                              const Gap(3),
                              Expanded(
                                child: Text(
                                  property.location,
                                  style: AppTextStyles.bodySm,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            CurrencyFormatter.formatShort(property.price),
                            style: AppTextStyles.priceSm,
                          ),
                          TypePill(type: property.type),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
