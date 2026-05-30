import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import 'package:rentora/features/properties/presentation/widgets/property-detail/amenities_section.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/description_section.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/details_grid.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/engagement_stats.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/meta_chips_row.dart';
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

          // ── Title + Location + Listing Purpose ───────────────────────────
          Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  padding: p.isFeatured
                      ? const EdgeInsets.only(left: 14)
                      : EdgeInsets.zero,
                  decoration: p.isFeatured
                      ? const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFFD4A017),
                              width: 3.5,
                            ),
                          ),
                        )
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (p.isFeatured) ...[
                        const Text(
                          '★ FEATURED LISTING',
                          style: TextStyle(
                            color: Color(0xFFD4A017),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const Gap(6),
                      ],
                      Text(
                        p.displayTitle,
                        style: AppTextStyles.h1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(8),

                      // ── University (HOSTEL only) ──────────────────────────
                      if (p.university != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.school_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const Gap(6),
                            Expanded(
                              child: Text(
                                p.university!.name,
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Gap(6),
                      ],

                      // ── Location ──────────────────────────────────────────
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: AppColors.accent,
                          ),
                          const Gap(6),
                          Expanded(
                            child: Text(
                              p.locationDisplay,
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      // ── Listing purpose pill ─────────────────────────
                      const Gap(10),
                      _ListingPurposePill(listingPurpose: p.listingPurpose),
                    ],
                  ),
                ),
              )
              .animate(delay: 60.ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.04, end: 0, duration: 300.ms),

          const Gap(15),

          // ── Meta chips ────────────────────────────────────────────────────
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

          // ── Description ───────────────────────────────────────────────────
          DescriptionSection(
            description: p.description,
            expanded: _descExpanded,
            onToggle: () => setState(() => _descExpanded = !_descExpanded),
          ).animate(delay: 140.ms).fadeIn(duration: 300.ms),

          // ── Amenities ─────────────────────────────────────────────────────
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

          // ── NEW: Property Videos ──────────────────────────────────────────
          if (p.videos.isNotEmpty) ...[
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

          // ── Details grid ──────────────────────────────────────────────────
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

          // ── Engagement stats ──────────────────────────────────────────────
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

          // ── Report button ─────────────────────────────────────────────────
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

          // ── Similar Properties ────────────────────────────────────────────
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

class _ListingPurposePill extends StatelessWidget {
  const _ListingPurposePill({required this.listingPurpose});
  final String listingPurpose;

  @override
  Widget build(BuildContext context) {
    final isForSale = listingPurpose == 'SALE';

    const saleColor = Color(0xFF16A34A); // emerald green

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isForSale
            ? saleColor.withOpacity(0.10)
            : AppColors.primary.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isForSale
              ? saleColor.withOpacity(0.35)
              : AppColors.primary.withOpacity(0.28),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isForSale ? Icons.sell_outlined : Icons.home_outlined,
            size: 12,
            color: isForSale ? saleColor : AppColors.primary,
          ),
          const Gap(5),
          Text(
            isForSale ? 'For Sale' : 'For Rent',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: isForSale ? saleColor : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
