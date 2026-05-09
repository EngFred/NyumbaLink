import 'package:flutter/material.dart';
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
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // ── AUTO-REFRESH ON OPEN ──
    // This ensures that every time the user navigates to this page,
    // it fetches the latest notifications silently in the background.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationsProvider.notifier).fetchNextPage();
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'BOOKING_CONFIRMED':
        return Icons.check_circle_outline_rounded;
      case 'BOOKING_CANCELLED':
        return Icons.cancel_outlined;
      case 'COMPLAINT_UPDATED':
        return Icons.support_agent_rounded;
      case 'NEW_PROPERTY':
        return Icons.home_work_outlined;
      case 'PASSWORD_CHANGED':
        return Icons.lock_outline_rounded;
      case 'SYSTEM_ALERT':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'BOOKING_CONFIRMED':
        return AppColors.success;
      case 'BOOKING_CANCELLED':
        return AppColors.error;
      case 'COMPLAINT_UPDATED':
        return AppColors.info;
      case 'NEW_PROPERTY':
        return AppColors.primary;
      case 'SYSTEM_ALERT':
        return AppColors.accent;
      default:
        return AppColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final notifState = ref.watch(notificationsProvider);

    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: _buildUnauthenticatedView(context),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          // Explicit refresh button for better UX control
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.read(notificationsProvider.notifier).load(),
          ),
          if (notifState.unreadCount > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllAsRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _buildAuthenticatedView(notifState),
    );
  }

  Widget _buildAuthenticatedView(NotificationsState state) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.notifications.isEmpty) {
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
              onPressed: () => ref.read(notificationsProvider.notifier).load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: AppColors.grey300,
            ),
            const Gap(16),
            Text('All caught up!', style: AppTextStyles.h3),
            const Gap(8),
            Text(
              'You have no notifications at the moment.',
              style: AppTextStyles.bodySm,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(notificationsProvider.notifier).load(),
      child: ListView.separated(
        controller: _scrollController,
        // Remove outer padding to allow edge-to-edge premium design
        padding: EdgeInsets.zero,
        itemCount: state.notifications.length + (state.isLoadingMore ? 1 : 0),
        // Premium subtle divider indented to align with the text
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.grey200,
          indent: 84, // 20 padding + 48 avatar + 16 gap
        ),
        itemBuilder: (context, index) {
          if (index >= state.notifications.length) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final n = state.notifications[index];
          final color = _getColorForType(n.type);
          final isUnread = !n.isRead;

          return Dismissible(
            key: Key(n.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              color: AppColors.error,
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            onDismissed: (_) {
              ref.read(notificationsProvider.notifier).deleteNotification(n.id);
            },
            child: InkWell(
              onTap: () {
                if (isUnread) {
                  ref.read(notificationsProvider.notifier).markAsRead(n.id);
                }
                // Deep link handling
                if (n.data != null && n.data!['propertyId'] != null) {
                  context.push(
                    AppRoutes.propertyDetailPath(
                      n.data!['propertyId'].toString(),
                    ),
                  );
                }
              },
              child: Container(
                // Premium background: subtle blue tint if unread, white if read
                color: isUnread
                    ? AppColors.primary50.withOpacity(0.4)
                    : AppColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium larger avatar
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForType(n.type),
                        color: color,
                        size: 24,
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  n.title,
                                  style: AppTextStyles.labelLg.copyWith(
                                    fontWeight: isUnread
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const Gap(8),
                              Text(
                                timeago.format(n.createdAt, locale: 'en_short'),
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
                            n.message,
                            style: AppTextStyles.bodySm.copyWith(
                              color: isUnread
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUnread) ...[
                      const Gap(12),
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.primary50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const Gap(32),
            Text(
              'Stay in the loop',
              style: AppTextStyles.h1,
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            Text(
              'Sign in to receive instant alerts when your booking requests are approved, or when landlords reply to your complaints.',
              style: AppTextStyles.bodyLg.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(48),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.login),
              child: const Text('Sign in'),
            ),
            const Gap(16),
            OutlinedButton(
              onPressed: () => context.push(AppRoutes.register),
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
