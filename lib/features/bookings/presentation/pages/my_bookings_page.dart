import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:rentora/features/bookings/domain/entities/booking_filter.dart';
import 'package:rentora/features/bookings/presentation/widgets/my-booking/booking_card.dart';
import 'package:rentora/features/bookings/presentation/widgets/my-booking/booking_filter_bar.dart';
import 'package:rentora/features/bookings/presentation/widgets/my-booking/bookings_Header.dart';
import 'package:rentora/features/bookings/presentation/widgets/my-booking/bookings_skeleton.dart';
import 'package:rentora/features/bookings/presentation/widgets/my-booking/guest_banner.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_dismiss_background.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/my_bookings_provider.dart';

class MyBookingsPage extends ConsumerStatefulWidget {
  const MyBookingsPage({super.key});

  @override
  ConsumerState<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends ConsumerState<MyBookingsPage> {
  BookingFilter _filter = BookingFilter.all;

  void _showCancelDialog(String id, String token) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Booking', style: AppTextStyles.h3),
        content: Text(
          'Are you sure you want to cancel this booking request? '
          'This action cannot be undone.',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Booking'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(myBookingsProvider.notifier).cancelBooking(id, token);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myBookingsProvider);
    final isAuthenticated = ref.watch(authProvider).isAuthenticated;

    // ── Loading ──────────────────────────────────────────────────────────────
    if (state.isLoading) return const BookingsSkeleton();

    // ── Error (empty list) ───────────────────────────────────────────────────
    if (state.error != null && state.bookings.isEmpty) {
      return AppErrorState(
        message: state.error!,
        onRetry: () => ref.read(myBookingsProvider.notifier).load(),
      );
    }

    // ── Client-side filtering ────────────────────────────────────────────────
    final filtered = switch (_filter) {
      BookingFilter.all => state.bookings,
      BookingFilter.active =>
        state.bookings.where((b) => !b.isCancelled).toList(),
      BookingFilter.cancelled =>
        state.bookings.where((b) => b.isCancelled).toList(),
    };

    return Stack(
      children: [
        RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(myBookingsProvider.notifier).load(),
          child: CustomScrollView(
            slivers: [
              // ── Header ─────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: BookingsHeader(
                  total: state.bookings.length,
                  isAuthenticated: isAuthenticated,
                ).animate().fadeIn(duration: 300.ms),
              ),
              // ── Guest Banner ───────────────────────────────────────────────
              if (!isAuthenticated)
                SliverToBoxAdapter(
                  child: const GuestBanner()
                      .animate(delay: 50.ms)
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.04, end: 0),
                ),
              // ── Filter bar (only when there are bookings) ──────────────────
              if (state.bookings.isNotEmpty)
                SliverToBoxAdapter(
                  child: BookingFilterBar(
                    selected: _filter,
                    bookings: state.bookings,
                    onSelected: (f) => setState(() => _filter = f),
                  ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
                ),
              // ── Empty state ────────────────────────────────────────────────
              if (state.bookings.isEmpty)
                SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: isAuthenticated
                        ? 'No bookings found'
                        : 'Sign in to view bookings',
                    subtitle: isAuthenticated
                        ? 'Your schedule requests and active applications will pop up right here.'
                        : 'Keep tabs on your scheduled property visits and active rental leases.',
                  ),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _filter == BookingFilter.active
                              ? Icons.receipt_long_outlined
                              : Icons.cancel_outlined,
                          size: 48,
                          color: AppColors.grey300,
                        ),
                        const Gap(12),
                        Text(
                          _filter == BookingFilter.active
                              ? 'No active bookings'
                              : 'No cancelled bookings',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // ── Booking list ─────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (context, index) {
                      final booking = filtered[index];
                      return Dismissible(
                        key: ValueKey(booking.id),
                        direction: booking.isCancelled
                            ? DismissDirection.none
                            : DismissDirection.endToStart,
                        background: const AppDismissBackground(
                          icon: Icons.cancel_outlined,
                          label: 'Cancel',
                        ),
                        confirmDismiss: (_) async {
                          _showCancelDialog(
                            booking.id,
                            booking.cancellationToken,
                          );
                          return false;
                        },
                        child:
                            BookingCard(
                                  booking: booking,
                                  isAuthenticated: isAuthenticated,
                                  onCancel: () => _showCancelDialog(
                                    booking.id,
                                    booking.cancellationToken,
                                  ),
                                )
                                .animate(
                                  delay: Duration(
                                    milliseconds: 80 + index * 55,
                                  ),
                                )
                                .fadeIn(duration: 280.ms)
                                .slideY(begin: 0.06, end: 0, duration: 280.ms),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        // ── Cancelling overlay ───────────────────────────────────────────────
        if (state.isCancelling)
          Container(
            color: Colors.black.withOpacity(0.25),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}
