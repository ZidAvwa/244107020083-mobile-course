import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/format.dart';

/// Platform glue for notification DISPLAY and TAP routing.
/// Token, permission and topics go through PushRepository instead.

final _local = FlutterLocalNotificationsPlugin();

/// Deep link received before the router was ready.
String? pendingDeepLink;

/// Set once the router exists; called when a local banner is tapped.
void Function(String route)? onRouteRequested;

/// Runs in a separate isolate when a message arrives while the app is
/// terminated/background. Must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Notification messages are shown by the system automatically.
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      final route = response.payload;
      if (route == null || route.isEmpty) return;
      if (onRouteRequested != null) {
        onRouteRequested!(route);
      } else {
        pendingDeepLink = route;
      }
    },
  );
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
