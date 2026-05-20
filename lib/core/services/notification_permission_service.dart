import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPermissionService {
  /// Returns true if permission is granted or provisional.
  static Future<bool> isGranted() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Returns true if the user has explicitly denied.
  static Future<bool> isDenied() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.denied;
  }

  /// Returns true if the user hasn't been asked yet.
  static Future<bool> isNotDetermined() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.notDetermined;
  }

  /// Requests the OS-level notification permission.
  /// No-op if already granted or denied — safe to call multiple times.
  static Future<void> requestPermission() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.notDetermined) {
      return;
    }
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Opens the app's notification settings page in the OS.
  static Future<void> openSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }
}
