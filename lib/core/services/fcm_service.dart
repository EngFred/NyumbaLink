import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles everything FCM-related on the client side:
///   1. Requesting OS permission (call [requestPermission] after login).
///   2. Fetching the FCM token and posting it to the backend (call [init]).
///   3. Showing a local notification banner when the app is in the foreground.
///
/// Correct call order:
///   FcmService().setupForegroundHandler();   // once, in main() after Firebase.initializeApp
///   FcmService().requestPermission();        // once, after the user logs in / registers
///   FcmService().init(dio);                  // after login or when a stored session is restored
class FcmService {
  static final FcmService _instance = FcmService._();
  factory FcmService() => _instance;
  FcmService._();

  // ── Local notifications plugin (foreground banners) ──────────────────────

  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'rentora_high_importance',
    'Rentora Alerts',
    description: 'Property listing and area alert notifications',
    importance: Importance.high,
  );

  static bool _localNotificationsInitialised = false;

  // ── Public API ───────────────────────────────────────────────────────────

  /// Requests OS-level notification permission.
  ///
  /// Call this AFTER the user has logged in or registered — never on splash or
  /// onboarding. That way the user understands WHY the app needs the permission
  /// and is far less likely to deny it.
  ///
  /// On iOS the system prompt only appears once ever; on Android 13+ it appears
  /// once per install. This method is a no-op if already granted or denied.
  Future<void> requestPermission() async {
    try {
      final current = await FirebaseMessaging.instance
          .getNotificationSettings();

      // Already settled — don't re-prompt.
      if (current.authorizationStatus == AuthorizationStatus.authorized ||
          current.authorizationStatus == AuthorizationStatus.provisional ||
          current.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('[FCM] requestPermission() failed silently: $e');
    }
  }

  /// Registers the FCM token with the backend.
  ///
  /// Call this after login or when a stored session is restored.
  /// [dio] must already have the Bearer token configured.
  /// This method is completely silent on error — it will never throw.
  Future<void> init(Dio dio) async {
    try {
      await _initLocalNotifications();

      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[FCM] Permission denied — skipping token registration.');
        return;
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('[FCM] No token returned — skipping registration.');
        return;
      }

      debugPrint('[FCM] Registering token: ${token.substring(0, 20)}…');

      await dio.post<void>(
        '/device-tokens',
        data: {
          'token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        },
      );

      debugPrint('[FCM] Token registered successfully.');
    } catch (e) {
      debugPrint('[FCM] init() failed silently: $e');
    }
  }

  /// Sets up the foreground message listener.
  ///
  /// Call this once after [Firebase.initializeApp()] in [main()].
  /// Does NOT request permission — that is [requestPermission]'s job.
  void setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    });
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    if (_localNotificationsInitialised) return;

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(settings: initSettings);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    _localNotificationsInitialised = true;
  }
}
