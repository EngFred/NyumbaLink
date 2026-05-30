import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../core/utils/enum_helpers.dart';
import '../../../domain/entities/property_entities.dart';

/// Gold accent used for all featured UI across the properties feature.
const _kFeaturedGold = Color(0xFFD4A017);

/// Pure-presentation property card — zero provider dependencies.
/// The parent is responsible for wiring [isSaved] and [onSaveTap].
class PropertyCard extends StatefulWidget {
  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.isSaved = false,
    this.onSaveTap,
  });

  final Property property;
  final VoidCallback onTap;
  final bool isSaved;
  final VoidCallback? onSaveTap;

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.965,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: _CardBody(
          property: widget.property,
          isSaved: widget.isSaved,
          onSaveTap: widget.onSaveTap,
        ),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.property,
    required this.isSaved,
    this.onSaveTap,
  });

  final Property property;
  final bool isSaved;
  final VoidCallback? onSaveTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ImageHero(
            property: property,
            isSaved: isSaved,
            onSaveTap: onSaveTap,
          ),
          _CardInfo(property: property),
        ],
      ),
    );
  }
}

// ── Hero Image ────────────────────────────────────────────────────────────────
class _ImageHero extends StatelessWidget {
  const _ImageHero({
    required this.property,
    required this.isSaved,
    this.onSaveTap,
  });

  final Property property;
  final bool isSaved;
  final VoidCallback? onSaveTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _PropertyImage(property: property),

          // Bottom gradient for text readability
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.35, 1.0],
                colors: [Colors.transparent, Color(0xDC000000)],
              ),
            ),
          ),

          // Top row: type badge/featured badge + save button + FOR SALE badge
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              children: [
                if (property.isFeatured)
                  const _FeaturedBadge()
                else
                  _TypeBadge(type: property.type),
                const Spacer(),
                // ── NEW: FOR SALE badge ──────────────────────────────────
                if (property.isForSale) ...[const _SaleBadge(), const Gap(6)],
                if (onSaveTap != null)
                  _SaveButton(isSaved: isSaved, onTap: onSaveTap!),
              ],
            ),
          ),

          // Bottom row: price + action button
          Positioned(
            bottom: 12,
            left: 14,
            right: 14,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CurrencyFormatter.format(property.price),
                        style: AppTextStyles.priceMd.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        BillingCycleHelper.full(property.billingCycle),
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── NEW PRO UX: Book/Enquire CTA instead of static Available badge ──
                if (property.isAvailable)
                  const _ActionPill()
                else
                  _StatusPill(status: property.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── NEW: Action Pill CTA ──────────────────────────────────────────────────────
class _ActionPill extends StatelessWidget {
  const _ActionPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Book / Enquire',
            style: AppTextStyles.labelSm.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
          const Gap(6),
          const Icon(
            Icons.arrow_forward_rounded,
            size: 12,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

// ── Featured Badge ────────────────────────────────────────────────────────────
class _FeaturedBadge extends StatelessWidget {
  const _FeaturedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _kFeaturedGold,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kFeaturedGold.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        '★ Featured',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── NEW: Sale Badge ───────────────────────────────────────────────────────────
class _SaleBadge extends StatelessWidget {
  const _SaleBadge();

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF16A34A); // emerald green
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.45),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Text(
        'FOR SALE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _PropertyImage extends StatelessWidget {
  const _PropertyImage({required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    return property.thumbnailUrl != null
        ? CachedNetworkImage(
            imageUrl: property.thumbnailUrl!,
            fit: BoxFit.cover,
            memCacheHeight: 380,
            placeholder: (_, __) => const ColoredBox(color: AppColors.grey100),
            errorWidget: (_, __, ___) => _Fallback(property.type),
          )
        : _Fallback(property.type);
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback(this.type);
  final String type;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary50, AppColors.primary100],
        ),
      ),
      child: Center(
        child: Icon(
          PropertyTypeHelper.icon(type),
          size: 48,
          color: AppColors.primary200,
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.42),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PropertyTypeHelper.icon(type), size: 11, color: Colors.white),
          const Gap(5),
          Text(
            PropertyTypeHelper.label(type),
            style: AppTextStyles.labelSm.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isSaved, required this.onTap});
  final bool isSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 17,
          color: isSaved ? AppColors.error : AppColors.grey500,
        ),
      ),
    );
  }
}

// ── Updated Status Pill ───────────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    // ── Map each status to a label + colour ──────────────────────────────
    final (label, color) = switch (status) {
      'RENTED' => ('Rented', AppColors.grey600),
      'SOLD' => ('Sold', const Color(0xFFD97706)), // amber — visually distinct
      _ => ('Unavailable', AppColors.grey600),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
            ),
          ),
          const Gap(6),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Section ──────────────────────────────────────────────────────────────
class _CardInfo extends StatelessWidget {
  const _CardInfo({required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            property.displayTitle,
            style: AppTextStyles.h4,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(5),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 13,
                color: AppColors.grey500,
              ),
              const Gap(3),
              Expanded(
                child: Text(
                  property.locationDisplay,
                  style: AppTextStyles.bodySm,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (!property.isHostel) ...[
            const Gap(10),
            _MetaRow(property: property),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _MetaChip(
          icon: Icons.meeting_room_outlined,
          label:
              '${property.numberOfRooms} ${property.numberOfRooms == 1 ? 'Room' : 'Rooms'}',
        ),
        if (property.floor != null)
          _MetaChip(
            icon: Icons.layers_outlined,
            label: 'Floor ${property.floor}',
          ),
        if (property.amenities != null && property.amenities!.isNotEmpty)
          _MetaChip(icon: Icons.wifi_rounded, label: property.amenities!.first),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.grey500),
          const Gap(4),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.grey700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
