import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:rentora/features/bookings/presentation/widgets/my-booking/status_badge.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/booking_entities.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking});

  final SavedBooking booking;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(booking.bookedAt);
    final dateStr = date != null
        ? DateFormat('MMM dd, yyyy').format(date)
        : 'Unknown Date';
    final isCancelled = booking.isCancelled;
    final currencyFormat = NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    );

    return Opacity(
      opacity: isCancelled ? 0.65 : 1.0,
      child: GestureDetector(
        // UX Polish: Now taps navigate to the BOOKING detail, not the property
        onTap: () => context.push(AppRoutes.bookingDetailPath(booking.id)),
        child: Container(
          decoration: BoxDecoration(
            color: isCancelled ? AppColors.grey50 : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey200),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Gap(16),
              // ── Middle: Property Info ───────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child:
                        booking.thumbnailUrl != null &&
                            booking.thumbnailUrl!.isNotEmpty
                        ? Image.network(
                            booking.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.home_work_outlined,
                              color: AppColors.grey400,
                              size: 24,
                            ),
                          )
                        : const Icon(
                            Icons.home_work_outlined,
                            color: AppColors.grey400,
                            size: 24,
                          ),
                  ),
                  const Gap(16),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const Gap(4),
                            Expanded(
                              child: Text(
                                booking.location,
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
                          const Gap(6),
                          Text(
                            currencyFormat.format(booking.price),
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Gap(8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.grey400,
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
