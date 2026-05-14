import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
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
