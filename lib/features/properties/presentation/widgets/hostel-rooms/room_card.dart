import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rentora/features/properties/presentation/widgets/hostel-rooms/room_status_badge.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../core/utils/enum_helpers.dart';
import '../../../domain/entities/property_entities.dart';

class RoomCard extends StatelessWidget {
  const RoomCard({super.key, required this.room, required this.onBook});
  final HostelRoom room;
  final VoidCallback? onBook;

  Color get _statusColor => switch (room.status) {
    'AVAILABLE' => AppColors.success,
    'OCCUPIED' => AppColors.error,
    'RESERVED' => AppColors.accent,
    'MAINTENANCE' => AppColors.grey500,
    _ => AppColors.grey400,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onBook,
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status strip
              Container(width: 5, color: _statusColor),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Room number + Status badge
                      Row(
                        children: [
                          Text(
                            'Room ${room.roomNumber}',
                            style: AppTextStyles.h3,
                          ),
                          const Spacer(),
                          RoomStatusBadge(status: room.status),
                        ],
                      ),

                      const Gap(8),

                      // Row 2: Type + Floor
                      Row(
                        children: [
                          const Icon(
                            Icons.bed_rounded,
                            size: 14,
                            color: AppColors.grey500,
                          ),
                          const Gap(4),
                          Text(
                            RoomTypeHelper.label(room.type),
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (room.floor != null) ...[
                            const Gap(12),
                            const Icon(
                              Icons.layers_outlined,
                              size: 14,
                              color: AppColors.grey500,
                            ),
                            const Gap(4),
                            Text(
                              'Floor ${room.floor}',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Amenities (if any)
                      if (room.amenities != null &&
                          room.amenities!.isNotEmpty) ...[
                        const Gap(8),
                        Text(
                          room.amenities!.take(3).join(' · '),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textHint,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const Gap(14),

                      // Price + CTA
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                CurrencyFormatter.format(room.price),
                                style: AppTextStyles.priceMd,
                              ),
                              Text(
                                BillingCycleHelper.full(room.billingCycle),
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (room.isAvailable)
                            ElevatedButton(
                              onPressed: onBook,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(80, 36),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                textStyle: AppTextStyles.buttonSm,
                              ),
                              child: const Text('Book'),
                            )
                          else
                            Text(
                              RoomStatusHelper.label(room.status),
                              style: AppTextStyles.labelSm.copyWith(
                                color: _statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
