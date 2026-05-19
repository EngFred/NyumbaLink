import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles everything FCM-related on the client side:
///   1. Requesting permission from the OS.
///   2. Fetching the FCM registration token and posting it to our backend.
///   3. Showing a local notification banner when the app is in the foreground.
///
/// Usage:
///   await FcmService().init(jwtToken);          // after login / on resume
///   FcmService().setupForegroundHandler();       // once, after Firebase.initializeApp
class FcmService {
  static final FcmService _instance = FcmService._();
  factory FcmService() => _instance;
  FcmService._();

  // ── Local notifications plugin (foreground banners) ──────────────────────

  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'rentora_high_importance', // must match the channel configured in AndroidManifest
    'Rentora Alerts',
    description: 'Property listing and area alert notifications',
    importance: Importance.high,
  );

  static bool _localNotificationsInitialised = false;

  // ── Public API ───────────────────────────────────────────────────────────

  /// Call once after the user logs in or when a stored session is restored.
  ///
  /// [dio]  — an already-configured Dio instance (with the Bearer token set).
  /// The method is completely silent on error — it will never throw.
  Future<void> init(Dio dio) async {
    try {
      await _initLocalNotifications();

      // Request OS-level permission (shows the system prompt on first call).
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

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
      // Best-effort — never block the auth flow.
      debugPrint('[FCM] init() failed silently: $e');
    }
  }

  /// Sets up the foreground message listener. Call this once after
  /// [Firebase.initializeApp()] — typically at the end of [main()], or from a
  /// root widget's [initState].
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

    // Create the Android channel once (no-op on subsequent calls).
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    _localNotificationsInitialised = true;
  }
}
