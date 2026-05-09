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

class MyBookingsPage extends ConsumerWidget {
  const MyBookingsPage({super.key});

  void _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    String id,
    String token,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Cancel Booking', style: AppTextStyles.h3),
        content: Text(
          'Are you sure you want to cancel this booking request? This action cannot be undone.',
          style: AppTextStyles.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Booking'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myBookingsProvider);
    final isAuthenticated = ref.watch(authProvider).isAuthenticated;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const Gap(16),
            Text(
              state.error!,
              style: AppTextStyles.bodySm,
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            ElevatedButton(
              onPressed: () => ref.read(myBookingsProvider.notifier).load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.bookings.isEmpty && isAuthenticated) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              size: 64,
              color: AppColors.grey300,
            ),
            const Gap(16),
            Text('No bookings yet', style: AppTextStyles.h3),
            const Gap(8),
            Text(
              'Your property requests will appear here.',
              style: AppTextStyles.bodySm,
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => ref.read(myBookingsProvider.notifier).load(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            // Add 1 to length if NOT authenticated, to make room for the banner
            itemCount: state.bookings.length + (isAuthenticated ? 0 : 1),
            separatorBuilder: (_, __) => const Gap(16),
            itemBuilder: (context, index) {
              // ── GUEST BANNER ──
              if (!isAuthenticated && index == 0) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary200),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        color: AppColors.primary,
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You are browsing as a guest',
                              style: AppTextStyles.labelMd,
                            ),
                            const Gap(4),
                            Text(
                              'Sign in to safely back up your bookings across devices.',
                              style: AppTextStyles.bodySm,
                            ),
                            const Gap(8),
                            GestureDetector(
                              onTap: () => context.push(AppRoutes.register),
                              child: Text(
                                'Create Account',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Adjust the index if the banner is taking up index 0
              final b = state.bookings[isAuthenticated ? index : index - 1];
              final date = DateTime.tryParse(b.bookedAt);
              final dateStr = date != null
                  ? DateFormat('MMM dd, yyyy').format(date)
                  : 'Unknown Date';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dateStr, style: AppTextStyles.caption),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: b.isCancelled
                                ? AppColors.errorLight
                                : AppColors.primary50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            b.isCancelled ? 'CANCELLED' : 'REQUESTED',
                            style: AppTextStyles.labelSm.copyWith(
                              color: b.isCancelled
                                  ? AppColors.error
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),
                    Text(b.propertyTitle, style: AppTextStyles.h4),
                    if (b.roomNumber != null) ...[
                      const Gap(4),
                      Text('Room ${b.roomNumber}', style: AppTextStyles.bodySm),
                    ],
                    const Gap(16),
                    const Divider(),
                    const Gap(12),
                    if (!b.isCancelled)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Only show the raw token UI to guests. Logged in users
                              // use the authenticated delete route securely behind the scenes.
                              if (b.cancellationToken.isNotEmpty) ...[
                                Text('Token', style: AppTextStyles.caption),
                                Text(
                                  b.cancellationToken,
                                  style: AppTextStyles.labelMd.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  'Secure Booking',
                                  style: AppTextStyles.caption,
                                ),
                                const Icon(
                                  Icons.lock_outline,
                                  size: 16,
                                  color: AppColors.success,
                                ),
                              ],
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => _showCancelDialog(
                              context,
                              ref,
                              b.id,
                              b.cancellationToken,
                            ),
                            icon: const Icon(
                              Icons.cancel_outlined,
                              color: AppColors.error,
                              size: 18,
                            ),
                            label: Text(
                              'Cancel',
                              style: AppTextStyles.buttonSm.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'This request was cancelled by you.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        if (state.isCancelling)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
