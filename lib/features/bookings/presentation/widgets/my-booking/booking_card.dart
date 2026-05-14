import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:rentora/features/bookings/presentation/widgets/my-booking/status_badge.dart';
import 'package:rentora/features/bookings/presentation/widgets/my-booking/token_section.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

// ── Booking Card ──────────────────────────────────────────────────────────────
class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    required this.isAuthenticated,
    required this.onCancel,
  });

  final dynamic booking; // LocalBooking
  final bool isAuthenticated;
  final VoidCallback onCancel;

  Color get _statusColor =>
      booking.isCancelled ? AppColors.error : AppColors.success;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(booking.bookedAt as String);
    final dateStr = date != null
        ? DateFormat('MMM dd, yyyy · h:mm a').format(date)
        : 'Unknown Date';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Status strip ───────────────────────────────────────────────
            Container(width: 5, color: _statusColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Date + Status badge
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: AppColors.grey500,
                        ),
                        const Gap(4),
                        Text(
                          dateStr,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        StatusBadge(isCancelled: booking.isCancelled as bool),
                      ],
                    ),
                    const Gap(10),

                    // Row 2: Property title
                    Text(
                      booking.propertyTitle as String,
                      style: AppTextStyles.h4,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Room number (if any)
                    if ((booking.roomNumber as String?) != null) ...[
                      const Gap(4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.door_back_door_outlined,
                            size: 13,
                            color: AppColors.accent,
                          ),
                          const Gap(4),
                          Text(
                            'Room ${booking.roomNumber}',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const Gap(14),
                    const Divider(height: 1, color: AppColors.grey100),
                    const Gap(12),

                    // Row 3: Token / secure + action
                    if (!booking.isCancelled)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Token display
                          Expanded(
                            child: TokenSection(
                              token: booking.cancellationToken as String,
                              isAuthenticated: isAuthenticated,
                            ),
                          ),
                          const Gap(8),
                          // Cancel button
                          GestureDetector(
                            onTap: onCancel,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.error.withOpacity(0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.cancel_outlined,
                                    size: 14,
                                    color: AppColors.error,
                                  ),
                                  const Gap(5),
                                  Text(
                                    'Cancel',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: AppColors.grey500,
                          ),
                          const Gap(6),
                          Text(
                            'This request was cancelled.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.grey500,
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
    );
  }
}
