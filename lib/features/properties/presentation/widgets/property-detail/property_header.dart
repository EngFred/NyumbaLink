import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/property_entities.dart';

/// Property name, location, optional university (hostel-only) and listing-
/// purpose pill. Single responsibility: present the top identity block.
class PropertyHeader extends StatelessWidget {
  const PropertyHeader({super.key, required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    final p = property;

    return Container(
      padding: p.isFeatured ? const EdgeInsets.only(left: 14) : EdgeInsets.zero,
      decoration: p.isFeatured
          ? const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xFFD4A017), width: 3.5),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Featured badge ───────────────────────────────────────────
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

          // ── Title ────────────────────────────────────────────────────
          Text(
            p.displayTitle,
            style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(8),

          // ── University (hostel only) ─────────────────────────────────
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

          // ── Location ─────────────────────────────────────────────────
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

          // ── Listing-purpose pill ─────────────────────────────────────
          const Gap(10),
          ListingPurposePill(listingPurpose: p.listingPurpose),
        ],
      ),
    );
  }
}

// ── Listing-purpose pill ──────────────────────────────────────────────────────

/// "For Rent" / "For Sale" pill badge.
class ListingPurposePill extends StatelessWidget {
  const ListingPurposePill({super.key, required this.listingPurpose});
  final String listingPurpose;

  @override
  Widget build(BuildContext context) {
    final isForSale = listingPurpose == 'SALE';
    const saleColor = Color(0xFF16A34A);

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
