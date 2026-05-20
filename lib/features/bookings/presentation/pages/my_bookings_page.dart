import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:rentora/core/widgets/guest_banner.dart';
import 'package:rentora/features/bookings/domain/entities/booking_filter.dart';
import 'package:rentora/features/bookings/presentation/widgets/my-booking/booking_card.dart';
import 'package:rentora/features/bookings/presentation/widgets/my-booking/booking_filter_bar.dart';
import 'package:rentora/features/bookings/presentation/widgets/my-booking/bookings_Header.dart';
import 'package:rentora/features/bookings/presentation/widgets/my-booking/bookings_skeleton.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myBookingsProvider);
    final isAuthenticated = ref.watch(authProvider).isAuthenticated;

    if (state.isLoading) return const BookingsSkeleton();

    if (state.error != null && state.bookings.isEmpty) {
      return AppErrorState(
        message: state.error!,
        onRetry: () => ref.read(myBookingsProvider.notifier).load(),
      );
    }

    final filtered = switch (_filter) {
      BookingFilter.all => state.bookings,
      BookingFilter.active =>
        state.bookings.where((b) => !b.isCancelled).toList(),
      BookingFilter.cancelled =>
        state.bookings.where((b) => b.isCancelled).toList(),
    };

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () => ref.read(myBookingsProvider.notifier).load(),
        child: CustomScrollView(
          slivers: [
            SliverSafeArea(
              bottom: false,
              sliver: SliverToBoxAdapter(
                child: BookingsHeader(
                  total: state.bookings.length,
                  isAuthenticated: isAuthenticated,
                ).animate().fadeIn(duration: 300.ms),
              ),
            ),
            if (!isAuthenticated)
              SliverToBoxAdapter(
                child:
                    const GuestBanner(
                          title: 'Browsing as a guest',
                          subtitle:
                              'Sign in to back up your bookings across all your devices.',
                          icon: Icons.cloud_off_rounded,
                          marginBottom: 8.0,
                        )
                        .animate(delay: 50.ms)
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.04, end: 0),
              ),
            if (state.bookings.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: BookingFilterBar(
                    selected: _filter,
                    bookings: state.bookings,
                    onSelected: (f) => setState(() => _filter = f),
                  ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
                ),
              ),
            if (state.bookings.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: isAuthenticated
                      ? 'No bookings yet'
                      : 'Sign in to view bookings',
                  subtitle: isAuthenticated
                      ? 'Your property requests and applications will appear here.'
                      : 'Keep tabs on your scheduled visits and leases.',
                ),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
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
                      const Gap(16),
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
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  MediaQuery.of(context).padding.bottom + 100,
                ),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Gap(16),
                  itemBuilder: (context, index) {
                    final booking = filtered[index];
                    return BookingCard(booking: booking)
                        .animate(delay: Duration(milliseconds: 40 + index * 40))
                        .fadeIn(duration: 300.ms)
                        .slideY(
                          begin: 0.04,
                          end: 0,
                          duration: 300.ms,
                          curve: Curves.easeOut,
                        );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
