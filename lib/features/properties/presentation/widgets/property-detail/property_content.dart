import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/amenities_section.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/description_section.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/details_grid.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/engagement_stats.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/featured_listing_banner.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/meta_chips_row.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/sheet_handle.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/property_entities.dart';

class PropertyContent extends StatefulWidget {
  const PropertyContent({
    super.key,
    required this.property,
    required this.onEnquire,
    required this.onReport,
  });
  final Property property;
  final VoidCallback onEnquire;
  final VoidCallback onReport;

  @override
  State<PropertyContent> createState() => _PropertyContentState();
}

class _PropertyContentState extends State<PropertyContent> {
  bool _descExpanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          const SheetHandle(),

          // ── Featured banner ─────────────────────────────────────────────
          if (p.isFeatured)
            const FeaturedListingBanner()
                .animate(delay: 30.ms)
                .fadeIn(duration: 280.ms),

          // Title + Location
          Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title, style: AppTextStyles.h1),
                    const Gap(6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        const Gap(4),
                        Expanded(
                          child: Text(
                            '${p.area}, ${p.district.name}',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate(delay: 60.ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.04, end: 0, duration: 300.ms),

          const Gap(16),

          // Meta chips
          if (_hasMeta(p))
            MetaChipsRow(
              property: p,
            ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

          const Gap(16),

          // Divider
          const Divider(
            indent: 20,
            endIndent: 20,
            height: 1,
            color: AppColors.grey200,
          ),

          const Gap(20),

          // Description
          DescriptionSection(
            description: p.description,
            expanded: _descExpanded,
            onToggle: () => setState(() => _descExpanded = !_descExpanded),
          ).animate(delay: 140.ms).fadeIn(duration: 300.ms),

          // Amenities
          if (p.amenities != null && p.amenities!.isNotEmpty) ...[
            const Gap(20),
            const Divider(
              indent: 20,
              endIndent: 20,
              height: 1,
              color: AppColors.grey200,
            ),
            const Gap(20),
            AmenitiesSection(
              amenities: p.amenities!,
            ).animate(delay: 180.ms).fadeIn(duration: 300.ms),
          ],

          // Details grid
          const Gap(20),
          const Divider(
            indent: 20,
            endIndent: 20,
            height: 1,
            color: AppColors.grey200,
          ),
          const Gap(20),
          DetailsGrid(
            property: p,
          ).animate(delay: 220.ms).fadeIn(duration: 300.ms),

          // Engagement stats
          const Gap(20),
          const Divider(
            indent: 20,
            endIndent: 20,
            height: 1,
            color: AppColors.grey200,
          ),
          EngagementStats(
            property: p,
          ).animate(delay: 260.ms).fadeIn(duration: 300.ms),

          // Report button
          const Gap(8),
          Center(
            child: TextButton.icon(
              onPressed: widget.onReport,
              icon: const Icon(
                Icons.flag_outlined,
                size: 16,
                color: AppColors.grey500,
              ),
              label: Text(
                'Report an issue with this property',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.grey500,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.grey400,
                ),
              ),
            ),
          ),

          const Gap(32),
        ],
      ),
    );
  }

  bool _hasMeta(Property p) =>
      !p.isHostel ||
      p.floor != null ||
      p.hotelCategory != null ||
      p.furnishingStatus != null;
}
