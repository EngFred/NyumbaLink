import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../router/router_key.dart';

/// Handles everything FCM-related on the client side:
///   1. Requesting OS permission (call [requestPermission] after login).
///   2. Fetching the FCM token and posting it to the backend (call [init]).
///   3. Showing a local notification banner when the app is in the foreground.
///   4. Deep-linking to the property detail page when a notification is tapped.
///
/// Correct call order:
///   FcmService().setupForegroundHandler();   // once, in main() after Firebase.initializeApp
///   FcmService().requestPermission();        // once, after the user logs in / registers
///   FcmService().init(dio);                  // after login or when a stored session is restored
///   FcmService().handleInitialMessage();     // once, after runApp() via addPostFrameCallback
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
  static bool _foregroundHandlerSetup =
      false; // ← Prevents duplicate listeners on hot restart

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

  /// Sets up ALL notification tap scenarios plus the foreground message listener.
  ///
  /// Call this once after [Firebase.initializeApp()] in [main()].
  /// Does NOT request permission — that is [requestPermission]'s job.
  ///
  /// Handles three distinct tap scenarios:
  ///   1. Foreground  — app is open; FCM delivers to [onMessage]; we show a local
  ///                    banner and pass [propertyId] as the payload so the tap
  ///                    handler in [_initLocalNotifications] can navigate.
  ///   2. Background  — app is running but backgrounded; the OS shows the system
  ///                    tray notification automatically; [onMessageOpenedApp] fires
  ///                    when the user taps it.
  ///   3. Terminated  — app is fully closed; handled separately in
  ///                    [handleInitialMessage] which must be called after runApp().
  void setupForegroundHandler() {
    if (_foregroundHandlerSetup) return; // ← Guard against duplicate listeners
    _foregroundHandlerSetup = true; // ← Mark as setup before registering

    // ── 1. Foreground: show a local banner ──────────────────────────────────
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      // Extract propertyId from the data payload sent by the backend.
      // The backend always includes { propertyId: '<uuid>' } in the FCM data
      // field alongside the notification title/body.
      final propertyId = message.data['propertyId'] as String?;

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
        // Payload carries propertyId through to onDidReceiveNotificationResponse
        // so the tap handler below can navigate without any extra state.
        payload: propertyId,
      );
    });

    // ── 2. Background tap: app was running in background ────────────────────
    // Fires when the user taps the system tray notification while the app is
    // backgrounded. The app is brought to the foreground and this callback runs.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final propertyId = message.data['propertyId'] as String?;
      if (propertyId != null) _navigateToProperty(propertyId);
    });
  }

  /// Handles the terminated (cold-start) tap scenario.
  ///
  /// When the app is fully closed and the user taps a notification, Flutter
  /// launches from scratch. [getInitialMessage] returns the message that caused
  /// the launch — but only once, and only if the app was opened via a notification.
  ///
  /// Must be called AFTER [runApp()] via [addPostFrameCallback] so that GoRouter
  /// is fully mounted before we attempt to push a new route:
  ///
  /// ```dart
  /// WidgetsBinding.instance.addPostFrameCallback((_) {
  ///   FcmService().handleInitialMessage();
  /// });
  /// ```
  Future<void> handleInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message == null) return;
    final propertyId = message.data['propertyId'] as String?;
    if (propertyId != null) _navigateToProperty(propertyId);
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  /// Navigates to the property detail page for the given [propertyId].
  ///
  /// Uses the global [rootNavigatorKey] to obtain a context outside the widget
  /// tree — necessary because FCM callbacks fire outside any widget lifecycle.
  void _navigateToProperty(String propertyId) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;
    context.push('/properties/$propertyId');
  }

  Future<void> _initLocalNotifications() async {
    if (_localNotificationsInitialised) return;

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      settings: initSettings,
      // Fires when the user taps a foreground local notification banner.
      // The payload is the propertyId set in setupForegroundHandler above.
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final propertyId = response.payload;
        if (propertyId != null && propertyId.isNotEmpty) {
          _navigateToProperty(propertyId);
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    _localNotificationsInitialised = true;
  }
}
