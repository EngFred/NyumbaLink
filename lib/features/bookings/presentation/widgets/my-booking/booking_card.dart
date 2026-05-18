import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:rentora/features/bookings/presentation/widgets/my-booking/status_badge.dart';
import 'package:rentora/features/bookings/presentation/widgets/my-booking/token_section.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/booking_entities.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    required this.isAuthenticated,
    required this.onCancel,
  });

  final SavedBooking booking;
  final bool isAuthenticated;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(booking.bookedAt);
    final dateStr = date != null
        ? DateFormat('MMM dd, yyyy · h:mm a').format(date)
        : 'Unknown Date';
    final isCancelled = booking.isCancelled;

    final currencyFormat = NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    );

    return Opacity(
      opacity: isCancelled ? 0.65 : 1.0,
      child: GestureDetector(
        // THIS MAKES THE CARD CLICKABLE
        onTap: () {
          if (booking.propertyId.isNotEmpty) {
            context.push('/p/${booking.propertyId}');
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isCancelled ? AppColors.grey50 : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.grey200 ?? Colors.grey.withOpacity(0.2),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Row: Status & Date ──────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(isCancelled: isCancelled),
                  Text(
                    dateStr,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Gap(16),

              // ── Middle: Property Info ───────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.grey200 ?? Colors.transparent,
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child:
                        booking.thumbnailUrl != null &&
                            booking.thumbnailUrl!.isNotEmpty
                        ? Image.network(
                            booking.thumbnailUrl!,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.home_work_outlined,
                            color: AppColors.grey400,
                            size: 24,
                          ),
                  ),
                  const Gap(14),

                  // Title, Location & Price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.propertyTitle,
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const Gap(4),
                            Expanded(
                              child: Text(
                                booking.location.isNotEmpty
                                    ? booking.location
                                    : 'Location unavailable',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (booking.price > 0) ...[
                          const Gap(4),
                          Text(
                            currencyFormat.format(booking.price),
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        if (booking.roomNumber != null) ...[
                          const Gap(6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Room ${booking.roomNumber}',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(16),
              const Divider(height: 1, thickness: 1, color: AppColors.grey100),
              const Gap(16),

              // ── Bottom: Actions / Token ─────────────────────────────────────
              if (!isCancelled)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TokenSection(
                        token: booking.cancellationToken,
                        isAuthenticated: isAuthenticated,
                      ),
                    ),
                    const Gap(12),
                    TextButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Cancel'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                      size: 16,
                      color: AppColors.textHint,
                    ),
                    const Gap(8),
                    Text(
                      'This request has been cancelled.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
