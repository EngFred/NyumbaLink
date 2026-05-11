import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/my_bookings_provider.dart';

// ── Filter Enum ───────────────────────────────────────────────────────────────

enum _BookingFilter { all, active, cancelled }

// ── Page ──────────────────────────────────────────────────────────────────────

class MyBookingsPage extends ConsumerStatefulWidget {
  const MyBookingsPage({super.key});

  @override
  ConsumerState<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends ConsumerState<MyBookingsPage> {
  _BookingFilter _filter = _BookingFilter.all;

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
    if (state.isLoading) return const _BookingsSkeleton();

    // ── Error (empty list) ───────────────────────────────────────────────────
    if (state.error != null && state.bookings.isEmpty) {
      return _ErrorState(
        message: state.error!,
        onRetry: () => ref.read(myBookingsProvider.notifier).load(),
      );
    }

    // ── Client-side filtering ────────────────────────────────────────────────
    final filtered = switch (_filter) {
      _BookingFilter.all => state.bookings,
      _BookingFilter.active =>
        state.bookings.where((b) => !b.isCancelled).toList(),
      _BookingFilter.cancelled =>
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
                child: _BookingsHeader(
                  total: state.bookings.length,
                  isAuthenticated: isAuthenticated,
                ).animate().fadeIn(duration: 300.ms),
              ),

              // ── Guest Banner ───────────────────────────────────────────────
              if (!isAuthenticated)
                SliverToBoxAdapter(
                  child: _GuestBanner()
                      .animate(delay: 50.ms)
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.04, end: 0),
                ),

              // ── Filter bar (only when there are bookings) ──────────────────
              if (state.bookings.isNotEmpty)
                SliverToBoxAdapter(
                  child: _BookingFilterBar(
                    selected: _filter,
                    bookings: state.bookings,
                    onSelected: (f) => setState(() => _filter = f),
                  ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
                ),

              // ── Empty state ────────────────────────────────────────────────
              if (state.bookings.isEmpty)
                SliverFillRemaining(
                  child: _EmptyState(isAuthenticated: isAuthenticated),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _filter == _BookingFilter.active
                              ? Icons.receipt_long_outlined
                              : Icons.cancel_outlined,
                          size: 48,
                          color: AppColors.grey300,
                        ),
                        const Gap(12),
                        Text(
                          _filter == _BookingFilter.active
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
                        background: _DismissBackground(),
                        confirmDismiss: (_) async {
                          _showCancelDialog(
                            booking.id,
                            booking.cancellationToken,
                          );
                          return false;
                        },
                        child:
                            _BookingCard(
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

// ── Header ────────────────────────────────────────────────────────────────────

class _BookingsHeader extends StatelessWidget {
  const _BookingsHeader({required this.total, required this.isAuthenticated});

  final int total;
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          if (total > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$total ${total == 1 ? 'booking' : 'bookings'}',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Gap(8),
            Text(
              'found',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ] else
            Text(
              'Your booking requests',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          const Spacer(),
          if (isAuthenticated && total > 0)
            const Icon(
              Icons.cloud_done_outlined,
              size: 18,
              color: AppColors.success,
            ),
        ],
      ),
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _BookingFilterBar extends StatelessWidget {
  const _BookingFilterBar({
    required this.selected,
    required this.bookings,
    required this.onSelected,
  });

  final _BookingFilter selected;
  final List<dynamic> bookings;
  final ValueChanged<_BookingFilter> onSelected;

  int _count(_BookingFilter f) => switch (f) {
    _BookingFilter.all => bookings.length,
    _BookingFilter.active => bookings.where((b) => !b.isCancelled).length,
    _BookingFilter.cancelled => bookings.where((b) => b.isCancelled).length,
  };

  String _label(_BookingFilter f) => switch (f) {
    _BookingFilter.all => 'All',
    _BookingFilter.active => 'Active',
    _BookingFilter.cancelled => 'Cancelled',
  };

  Color _color(_BookingFilter f) => switch (f) {
    _BookingFilter.all => AppColors.primary,
    _BookingFilter.active => AppColors.success,
    _BookingFilter.cancelled => AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: _BookingFilter.values.map((f) {
          final isSel = selected == f;
          final color = _color(f);
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isSel ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isSel
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_count(f)}',
                      style: AppTextStyles.labelLg.copyWith(
                        color: isSel ? Colors.white : AppColors.grey600,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const Gap(1),
                    Text(
                      _label(f),
                      style: AppTextStyles.labelSm.copyWith(
                        color: isSel
                            ? Colors.white.withOpacity(0.85)
                            : AppColors.grey500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Booking Card ──────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  const _BookingCard({
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
                        _StatusBadge(isCancelled: booking.isCancelled as bool),
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
                            child: _TokenSection(
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

// ── Token Section ─────────────────────────────────────────────────────────────

class _TokenSection extends StatelessWidget {
  const _TokenSection({required this.token, required this.isAuthenticated});

  final String token;
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    if (isAuthenticated && token.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 13,
                  color: AppColors.success,
                ),
                const Gap(5),
                Text(
                  'Secure Booking',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cancellation Token',
          style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
        ),
        const Gap(2),
        Text(
          token.isEmpty ? '––' : token,
          style: AppTextStyles.labelLg.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isCancelled});

  final bool isCancelled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isCancelled
            ? AppColors.errorLight
            : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isCancelled ? AppColors.error : AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const Gap(5),
          Text(
            isCancelled ? 'Cancelled' : 'Requested',
            style: AppTextStyles.labelSm.copyWith(
              color: isCancelled ? AppColors.error : AppColors.success,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dismiss Background ────────────────────────────────────────────────────────

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cancel_outlined, color: AppColors.error, size: 22),
          const Gap(4),
          Text(
            'Cancel',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Guest Banner ──────────────────────────────────────────────────────────────

class _GuestBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.07),
            AppColors.accent.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primary50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Browsing as a guest', style: AppTextStyles.labelLg),
                const Gap(4),
                Text(
                  'Sign in to back up your bookings across all your devices.',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const Gap(10),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.register),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create an account',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isAuthenticated});

  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: AppColors.primary50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    size: 44,
                    color: AppColors.primary200,
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.05, 1.05),
                  duration: 1800.ms,
                  curve: Curves.easeInOut,
                ),
            const Gap(24),
            Text(
              'No bookings yet',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const Gap(10),
            Text(
              isAuthenticated
                  ? 'Your property booking requests will appear here once you submit them.'
                  : 'Any booking requests you make will be saved here locally.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            ElevatedButton.icon(
              onPressed: () => context.go('/browse'),
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: const Text('Explore Properties'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 38,
                color: AppColors.error,
              ),
            ),
            const Gap(20),
            Text('Could not load bookings', style: AppTextStyles.h3),
            const Gap(8),
            Text(
              message,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}

// ── Loading Skeleton ──────────────────────────────────────────────────────────

class _BookingsSkeleton extends StatelessWidget {
  const _BookingsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header skeleton
          Container(
            height: 36,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          // Filter bar skeleton
          Container(
            height: 58,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          // Card skeletons
          ...List.generate(
            4,
            (i) => Container(
              height: 130,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
