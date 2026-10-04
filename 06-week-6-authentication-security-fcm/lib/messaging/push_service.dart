import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Placeholder for the push-notification lab. Not wired into main.dart yet.
class PushService {
  final _fcm = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _fcm.requestPermission();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _local.initialize(
      settings: const InitializationSettings(android: android),
    );
  }

  Future<String?> getToken() => _fcm.getToken();
}
