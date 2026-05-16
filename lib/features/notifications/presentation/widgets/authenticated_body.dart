import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rentora/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:rentora/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:rentora/features/notifications/presentation/widgets/notifications_skeleton.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';

class AuthenticatedBody extends ConsumerWidget {
  const AuthenticatedBody({
    super.key,
    required this.scrollCtrl,
    required this.state,
  });
  final ScrollController scrollCtrl;
  final NotificationsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const NotificationsSkeleton();
    }

    if (state.error != null && state.notifications.isEmpty) {
      return AppErrorState(
        message: state.error!,
        onRetry: () => ref.read(notificationsProvider.notifier).load(),
      );
    }

    if (state.notifications.isEmpty) {
      return const AppEmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'All caught up!',
        subtitle:
            'When you get messages, updates or alerts, they will appear right here.',
      );
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
          return NotificationTile(
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
