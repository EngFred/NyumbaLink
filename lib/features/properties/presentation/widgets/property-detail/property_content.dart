import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import 'package:rentora/features/properties/presentation/widgets/property-detail/amenities_section.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/description_section.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/details_grid.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/engagement_stats.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/meta_chips_row.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/property_header.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/property_videos_section.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/sheet_handle.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/similar_properties_section.dart';
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

    // The videos section is shown here only when the property also has images.
    // When there are no images the hero itself already surfaces the videos,
    // so we must not duplicate them in the scrollable content below.
    final showVideosSection = p.images.isNotEmpty && p.videos.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ────────────────────────────────────────────────────
          const SheetHandle(),

          // ── Title + location + listing purpose ────────────────────────
          Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: PropertyHeader(property: p),
              )
              .animate(delay: 60.ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.04, end: 0, duration: 300.ms),

          const Gap(15),

          // ── Meta chips ────────────────────────────────────────────────
          if (_hasMeta(p))
            MetaChipsRow(
              property: p,
            ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

          const Gap(10),
          const Divider(
            indent: 20,
            endIndent: 20,
            height: 1,
            color: AppColors.grey200,
          ),
          const Gap(10),

          // ── Description ───────────────────────────────────────────────
          DescriptionSection(
            description: p.displayDescription,
            expanded: _descExpanded,
            onToggle: () => setState(() => _descExpanded = !_descExpanded),
          ).animate(delay: 140.ms).fadeIn(duration: 300.ms),

          // ── Amenities ─────────────────────────────────────────────────
          if (p.amenities != null && p.amenities!.isNotEmpty) ...[
            const Gap(24),
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

          // ── Videos (only shown when property also has images) ─────────
          if (showVideosSection) ...[
            const Gap(24),
            const Divider(
              indent: 20,
              endIndent: 20,
              height: 1,
              color: AppColors.grey200,
            ),
            const Gap(20),
            PropertyVideosSection(
              videos: p.videos,
            ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
          ],

          // ── Details grid ──────────────────────────────────────────────
          const Gap(24),
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

          // ── Engagement stats ──────────────────────────────────────────
          const Gap(24),
          const Divider(
            indent: 20,
            endIndent: 20,
            height: 1,
            color: AppColors.grey200,
          ),
          EngagementStats(
            property: p,
          ).animate(delay: 260.ms).fadeIn(duration: 300.ms),

          // ── Report button ─────────────────────────────────────────────
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
          const Gap(24),

          // ── Similar properties ────────────────────────────────────────
          const Divider(
            indent: 20,
            endIndent: 20,
            height: 1,
            color: AppColors.grey200,
          ),
          const Gap(24),
          SimilarPropertiesSection(
            property: p,
          ).animate(delay: 300.ms).fadeIn(duration: 350.ms),

          const Gap(48),
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
