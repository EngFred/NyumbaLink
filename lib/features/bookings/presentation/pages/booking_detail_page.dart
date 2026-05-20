import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/my_bookings_provider.dart';
import '../widgets/my-booking/status_badge.dart';
import '../widgets/my-booking/token_section.dart';

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
    final isAuthenticated = ref.watch(authProvider).isAuthenticated;

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
      backgroundColor: AppColors.background,
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
            padding: const EdgeInsets.all(20),
            children: [
              // ── Status Header ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Status',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Gap(4),
                      StatusBadge(isCancelled: booking.isCancelled),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                ],
              ),
              const Gap(32),
              Text('Property Details', style: AppTextStyles.h4),
              const Gap(12),

              // ── Property Info Card ──────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.grey200),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: booking.thumbnailUrl != null
                              ? Image.network(
                                  booking.thumbnailUrl!,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.home_work_outlined,
                                  color: AppColors.grey400,
                                ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.propertyTitle,
                                style: AppTextStyles.h4,
                                maxLines: 2,
                              ),
                              const Gap(6),
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
                                    ),
                                  ),
                                ],
                              ),

                              // ── University display for Hostels ────────────
                              if (booking.universityName != null &&
                                  booking.universityName!.isNotEmpty) ...[
                                const Gap(4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.school_outlined,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    const Gap(4),
                                    Expanded(
                                      child: Text(
                                        booking.universityName!,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              // ── Price and Billing Cycle ───────────────────
                              if (booking.price > 0) ...[
                                const Gap(6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      currencyFormat.format(booking.price),
                                      style: AppTextStyles.labelMd.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      _formatBillingCycle(booking.billingCycle),
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              // ── Room Number Badge (UX Polish) ─────────────
                              if (booking.roomNumber != null &&
                                  booking.roomNumber!.isNotEmpty) ...[
                                const Gap(8),
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
                    const Divider(height: 1, color: AppColors.grey100),
                    const Gap(8),
                    TextButton.icon(
                      onPressed: () => context.push(
                        AppRoutes.propertyDetailPath(booking.propertyId),
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('View Original Listing'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(32),

              // ── Security & Cancellation Token ───────────────────────────────
              if (!booking.isCancelled) ...[
                Text('Booking Security', style: AppTextStyles.h4),
                const Gap(12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: TokenSection(
                    token: booking.cancellationToken,
                    isAuthenticated: isAuthenticated,
                  ),
                ),
                const Gap(48),

                // ── Destructive Action ────────────────────────────────────────
                OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(
                    context,
                    ref,
                    booking.cancellationToken,
                  ),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancel Request'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
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
