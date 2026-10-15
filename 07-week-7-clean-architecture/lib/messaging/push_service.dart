import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../routes.dart';

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
  await subscribeCampusTopic();
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

/// Foreground: the system shows NO banner, so display one via a local
/// notification. Background tap: onMessageOpenedApp.
void listenForeground(void Function(String route) go) {
  FirebaseMessaging.onMessage.listen((message) async {
    final route = routeFromMessage(message.data);
    const androidDetails = AndroidNotificationDetails(
      'announcement',
      'Campus Announcements',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _local.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Announcement',
      body: message.notification?.body ?? '',
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: route,
    );
  });

  // Background -> tapped.
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    go(routeFromMessage(message.data));
  });
}

/// Terminated -> opened from a notification. Call once the router is ready.
Future<void> handleTerminated(void Function(String route) go) async {
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) go(routeFromMessage(initial.data));
  final pending = pendingDeepLink;
  if (pending != null) {
    pendingDeepLink = null;
    go(pending);
  }
}

Future<void> subscribeCampusTopic() =>
    FirebaseMessaging.instance.subscribeToTopic('campus-announcement');

Future<void> unsubscribeCampusTopic() =>
    FirebaseMessaging.instance.unsubscribeFromTopic('campus-announcement');

/// Truncated token for screenshots: first 12 chars + "...".
String truncateToken(String? token) {
  if (token == null) return '(no token)';
  return token.length <= 12 ? token : '${token.substring(0, 12)}...';
}
