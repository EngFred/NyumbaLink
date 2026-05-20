import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/my_bookings_provider.dart';
import '../widgets/my-booking/status_badge.dart';

class BookingDetailPage extends ConsumerWidget {
  const BookingDetailPage({super.key, required this.bookingId});

  final String bookingId;

  void _showCancelDialog(BuildContext context, WidgetRef ref, String token) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Booking', style: AppTextStyles.h3),
        content: Text(
          'Are you sure you want to cancel this booking request? This action cannot be undone.',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep Booking',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(myBookingsProvider.notifier)
                  .cancelBooking(bookingId, token);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatBillingCycle(String? cycle) {
    if (cycle == null || cycle.isEmpty) return '';
    switch (cycle.toUpperCase()) {
      case 'DAILY':
        return ' / day';
      case 'MONTHLY':
        return ' / month';
      case 'QUARTERLY':
        return ' / quarter';
      case 'FOUR_MONTHS':
        return ' / 4 months';
      case 'BIANNUAL':
        return ' / 6 months';
      case 'ANNUAL':
        return ' / year';
      case 'SEMESTER':
        return ' / semester';
      default:
        return ' / ${cycle.toLowerCase()}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myBookingsProvider);

    // Find the booking in local state instantly
    final booking = state.bookings.where((b) => b.id == bookingId).firstOrNull;

    if (booking == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(backgroundColor: AppColors.surface),
        body: const Center(child: Text('Booking not found.')),
      );
    }

    final date = DateTime.tryParse(booking.bookedAt);
    final dateStr = date != null
        ? DateFormat('MMMM dd, yyyy · h:mm a').format(date)
        : 'Unknown Date';
    final currencyFormat = NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.surface, // Clean flat background
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Booking Details', style: AppTextStyles.h4),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.grey200),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              // ── 1. Status & Date Header ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Requested on',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Gap(4),
                        Text(dateStr, style: AppTextStyles.labelMd),
                      ],
                    ),
                    StatusBadge(isCancelled: booking.isCancelled),
                  ],
                ),
              ),

              // ── 2. Prominent Property Image ──────────────────────────────────
              if (booking.thumbnailUrl != null)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    booking.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.grey100,
                      child: const Icon(
                        Icons.home_work_outlined,
                        size: 48,
                        color: AppColors.grey400,
                      ),
                    ),
                  ),
                )
              else
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: AppColors.grey100,
                    child: const Icon(
                      Icons.home_work_outlined,
                      size: 48,
                      color: AppColors.grey400,
                    ),
                  ),
                ),

              // ── 3. Property Details (Top-to-bottom flow) ─────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Room Number
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            booking.propertyTitle,
                            style: AppTextStyles.h2.copyWith(height: 1.2),
                          ),
                        ),
                        if (booking.roomNumber != null &&
                            booking.roomNumber!.isNotEmpty) ...[
                          const Gap(12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
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

                    const Gap(16),

                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            booking.location,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // University (Hostels)
                    if (booking.universityName != null &&
                        booking.universityName!.isNotEmpty) ...[
                      const Gap(10),
                      Row(
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const Gap(8),
                          Expanded(
                            child: Text(
                              booking.universityName!,
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const Gap(24),
                    const Divider(height: 1, color: AppColors.grey200),
                    const Gap(24),

                    // Price
                    if (booking.price > 0)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(booking.price),
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              _formatBillingCycle(booking.billingCycle),
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                    const Gap(32),

                    // ── 4. Actions ────────────────────────────────────────────────
                    OutlinedButton.icon(
                      onPressed: () => context.push(
                        AppRoutes.propertyDetailPath(booking.propertyId),
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('View Original Listing'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        side: const BorderSide(color: AppColors.grey300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const Gap(32),

                    // Cancellation Section
                    if (!booking.isCancelled) ...[
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _showCancelDialog(
                            context,
                            ref,
                            booking.cancellationToken,
                          ),
                          icon: const Icon(Icons.cancel_outlined, size: 20),
                          label: const Text(
                            'Cancel Booking Request',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.grey50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grey200),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.textSecondary,
                            ),
                            const Gap(12),
                            Expanded(
                              child: Text(
                                'This booking request has been cancelled and is no longer active.',
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (state.isCancelling)
            Container(
              color: AppColors.surface.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
