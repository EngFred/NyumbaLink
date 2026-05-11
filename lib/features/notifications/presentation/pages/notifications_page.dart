import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/notifications_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(notificationsProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = ref.watch(authProvider).isAuthenticated;
    final state = ref.watch(notificationsProvider);

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Notifications', style: AppTextStyles.h4),
            if (isAuth && state.unreadCount > 0)
              Text(
                '${state.unreadCount} unread',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        actions: [
          if (isAuth) ...[
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
              onPressed: () => ref.read(notificationsProvider.notifier).load(),
            ),
            if (state.unreadCount > 0)
              TextButton(
                onPressed: () =>
                    ref.read(notificationsProvider.notifier).markAllAsRead(),
                child: Text(
                  'Read all',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.grey200),
        ),
      ),
      body: isAuth
          ? _AuthenticatedBody(scrollCtrl: _scrollCtrl, state: state)
          : const _UnauthenticatedBody(),
    );
  }
}

// ── Authenticated body ────────────────────────────────────────────────────────

class _AuthenticatedBody extends ConsumerWidget {
  const _AuthenticatedBody({required this.scrollCtrl, required this.state});

  final ScrollController scrollCtrl;
  final NotificationsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const _NotificationsSkeleton();
    }

    if (state.error != null && state.notifications.isEmpty) {
      return _ErrorState(
        message: state.error!,
        onRetry: () => ref.read(notificationsProvider.notifier).load(),
      );
    }

    if (state.notifications.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(notificationsProvider.notifier).load(),
      child: ListView.builder(
        controller: scrollCtrl,
        padding: EdgeInsets.zero,
        itemCount: state.notifications.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.notifications.length) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            );
          }

          final n = state.notifications[index];
          return _NotificationTile(
                notification: n,
                onTap: () {
                  if (!n.isRead) {
                    ref.read(notificationsProvider.notifier).markAsRead(n.id);
                  }
                  if (n.data?['propertyId'] != null) {
                    context.push(
                      AppRoutes.propertyDetailPath(
                        n.data!['propertyId'].toString(),
                      ),
                    );
                  }
                },
                onDismiss: () => ref
                    .read(notificationsProvider.notifier)
                    .deleteNotification(n.id),
              )
              .animate(
                delay: Duration(milliseconds: index < 6 ? index * 45 : 0),
              )
              .fadeIn(duration: 260.ms)
              .slideX(begin: 0.03, end: 0, duration: 260.ms);
        },
      ),
    );
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final dynamic notification; // AppNotification
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  static IconData _iconFor(String type) => switch (type) {
    'BOOKING_CONFIRMED' => Icons.check_circle_outline_rounded,
    'BOOKING_CANCELLED' => Icons.cancel_outlined,
    'COMPLAINT_UPDATED' => Icons.support_agent_rounded,
    'NEW_PROPERTY' => Icons.home_work_outlined,
    'PASSWORD_CHANGED' => Icons.lock_outline_rounded,
    'SYSTEM_ALERT' => Icons.campaign_outlined,
    _ => Icons.notifications_none_rounded,
  };

  static Color _colorFor(String type) => switch (type) {
    'BOOKING_CONFIRMED' => AppColors.success,
    'BOOKING_CANCELLED' => AppColors.error,
    'COMPLAINT_UPDATED' => AppColors.info,
    'NEW_PROPERTY' => AppColors.primary,
    'SYSTEM_ALERT' => AppColors.accent,
    _ => AppColors.grey500,
  };

  @override
  Widget build(BuildContext context) {
    final type = notification.type as String;
    final isUnread = !(notification.isRead as bool);
    final color = _colorFor(type);
    final createdAt = notification.createdAt as DateTime;

    return Dismissible(
      key: Key(notification.id as String),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AppColors.error.withOpacity(0.08),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: 22,
            ),
            const Gap(3),
            Text(
              'Delete',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: isUnread
              ? AppColors.primary50.withOpacity(0.35)
              : AppColors.surface,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon with colored background
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_iconFor(type), color: color, size: 22),
                    ),

                    const Gap(14),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title as String,
                                  style: AppTextStyles.labelLg.copyWith(
                                    fontWeight: isUnread
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Gap(8),
                              Text(
                                timeago.format(createdAt, locale: 'en_short'),
                                style: AppTextStyles.caption.copyWith(
                                  color: isUnread
                                      ? AppColors.primary
                                      : AppColors.textHint,
                                  fontWeight: isUnread
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          const Gap(4),
                          Text(
                            notification.message as String,
                            style: AppTextStyles.bodySm.copyWith(
                              color: isUnread
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Unread dot
                    if (isUnread) ...[
                      const Gap(8),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.grey100, indent: 76),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Unauthenticated body ──────────────────────────────────────────────────────

class _UnauthenticatedBody extends StatelessWidget {
  const _UnauthenticatedBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppColors.primary50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active_outlined,
                    size: 46,
                    color: AppColors.primary,
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.7, 0.7),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 300.ms),

            const Gap(28),

            Text(
              'Stay in the loop',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ).animate(delay: 150.ms).fadeIn(duration: 300.ms),

            const Gap(12),

            Text(
              'Sign in to receive instant alerts when your bookings are approved or when agents respond.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ).animate(delay: 220.ms).fadeIn(duration: 300.ms),

            const Gap(40),

            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.login),
              icon: const Icon(Icons.login_rounded, size: 18),
              label: const Text('Sign In'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ).animate(delay: 300.ms).fadeIn(duration: 300.ms),

            const Gap(12),

            OutlinedButton(
              onPressed: () => context.push(AppRoutes.register),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
              child: const Text('Create an Account'),
            ).animate(delay: 360.ms).fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
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
                  Icons.notifications_off_outlined,
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
          Text("You're all caught up!", style: AppTextStyles.h3),
          const Gap(8),
          Text(
            'No new notifications at the moment.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

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
            Text('Could not load notifications', style: AppTextStyles.h3),
            const Gap(8),
            Text(
              message,
              style: AppTextStyles.bodySm.copyWith(
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

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _NotificationsSkeleton extends StatelessWidget {
  const _NotificationsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        7,
        (i) =>
            Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: AppColors.grey200,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 14,
                              width: 200,
                              decoration: BoxDecoration(
                                color: AppColors.grey200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const Gap(8),
                            Container(
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.grey200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const Gap(4),
                            Container(
                              height: 12,
                              width: 160,
                              decoration: BoxDecoration(
                                color: AppColors.grey200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .animate(delay: Duration(milliseconds: i * 60))
                .shimmer(duration: 1200.ms, color: AppColors.grey100),
      ),
    );
  }
}
