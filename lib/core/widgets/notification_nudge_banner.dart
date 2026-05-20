import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shows a soft amber banner when the user has denied (or not yet granted)
/// notification permission. Tapping "Enable" deep-links to the OS settings.
///
/// Renders nothing at all when permission is already granted.
class NotificationNudgeBanner extends StatefulWidget {
  const NotificationNudgeBanner({super.key});

  @override
  State<NotificationNudgeBanner> createState() =>
      _NotificationNudgeBannerState();
}

class _NotificationNudgeBannerState extends State<NotificationNudgeBanner> {
  /// null = still checking, true = show banner, false = hide banner
  bool? _show;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (!mounted) return;
    setState(() {
      _show =
          settings.authorizationStatus == AuthorizationStatus.denied ||
          settings.authorizationStatus == AuthorizationStatus.notDetermined;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Don't flash anything while we're checking.
    if (_show != true) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD966).withOpacity(0.7)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFD4A017).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              color: Color(0xFFB8860B),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications are off',
                  style: AppTextStyles.bodySm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7A5C00),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Turn them on to get instant alerts for new listings and available rooms.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () async {
              await AppSettings.openAppSettings(
                type: AppSettingsType.notification,
              );
              // Re-check after the user returns from Settings.
              _checkPermission();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: const Color(0xFFD4A017).withOpacity(0.15),
              foregroundColor: const Color(0xFFB8860B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Enable',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
