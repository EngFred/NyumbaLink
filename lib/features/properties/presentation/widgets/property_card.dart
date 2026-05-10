import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/enum_helpers.dart';
import '../../domain/entities/property_entities.dart';

class PropertyCard extends StatelessWidget {
  const PropertyCard({super.key, required this.property, required this.onTap});

  final Property property;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PropertyImage(property: property),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _TypeChip(type: property.type),
                      const Spacer(),
                      _StatusBadge(status: property.status),
                    ],
                  ),
                  const Gap(8),
                  Text(
                    property.title,
                    style: AppTextStyles.h4,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
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
                          '${property.area}, ${property.district.name}',
                          style: AppTextStyles.bodySm,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CurrencyFormatter.format(property.price),
                              style: AppTextStyles.priceMd,
                            ),
                            Text(
                              BillingCycleHelper.full(property.billingCycle),
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      if (!property.isHostel) _RoomMeta(property: property),
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

class _PropertyImage extends StatelessWidget {
  const _PropertyImage({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: property.thumbnailUrl != null
            ? CachedNetworkImage(
                imageUrl: property.thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.grey100),
                errorWidget: (_, __, ___) => _ImagePlaceholder(property.type),
              )
            : _ImagePlaceholder(property.type),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder(this.type);

  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary50,
      child: Center(
        child: Icon(
          PropertyTypeHelper.icon(type),
          size: 40,
          color: AppColors.primary200,
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(6),
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
            PropertyTypeHelper.label(type),
            style: AppTextStyles.labelSm.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: PropertyStatusHelper.color(status, bg: true),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: PropertyStatusHelper.color(status),
              shape: BoxShape.circle,
            ),
          ),
          const Gap(4),
          Text(
            PropertyStatusHelper.label(status),
            style: AppTextStyles.labelSm.copyWith(
              color: PropertyStatusHelper.color(status),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomMeta extends StatelessWidget {
  const _RoomMeta({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.meeting_room_outlined,
          size: 14,
          color: AppColors.grey500,
        ),
        const Gap(3),
        Text(
          '${property.numberOfRooms} Room${property.numberOfRooms != 1 ? 's' : ''}',
          style: AppTextStyles.labelSm,
        ),
      ],
    );
  }
}
