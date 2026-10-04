import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _local = FlutterLocalNotificationsPlugin();

/// Deep link received from a tapped notification (e.g. "/announcement/3").
String? pendingDeepLink;

/// Runs in a separate isolate when a message arrives while the app is
/// terminated/background. Must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Notification messages are shown by the system automatically.
  // Data-only handling would go here (Firebase.initializeApp() first).
}

Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true, badge: true, sound: true,
    announcement: false, carPlay: false, criticalAlert: false,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      // Foreground banner click -> forward payload to the router.
      pendingDeepLink = response.payload;
    },
  );
}

Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  // 1. Fetch the current token and send it to the backend.
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) await onToken(token);

  // 2. Tokens can change (reinstall, data wipe, security rotation).
  //    This listener is MANDATORY, otherwise the backend keeps a stale token.
  FirebaseMessaging.instance.onTokenRefresh.listen(onToken);

  // 3. Subscribe to the campus topic (e.g. all students of a cohort).
  await FirebaseMessaging.instance.subscribeToTopic('campus-announcement');
}

/// Calls [onOpen] with the "route" data field when the user taps a
/// notification (app in background, or launched from terminated state).
Future<void> listenNotificationTaps(void Function(String route) onOpen) async {
  void handle(RemoteMessage m) {
    final route = m.data['route'];
    if (route is String && route.isNotEmpty) {
      pendingDeepLink = route;
      onOpen(route);
    }
  }

  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) handle(initial);
  FirebaseMessaging.onMessageOpenedApp.listen(handle);
}

/// Truncated token for screenshots: first 12 chars + "...".
String truncateToken(String? token) {
  if (token == null) return '(no token)';
  return token.length <= 12 ? token : '${token.substring(0, 12)}...';
}
