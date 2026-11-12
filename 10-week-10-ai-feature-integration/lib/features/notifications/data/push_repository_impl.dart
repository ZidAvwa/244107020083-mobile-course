import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../infrastructure/network/api_errors.dart';
import '../../../core/failures.dart';
import '../domain/repositories/push_repository.dart';

class PushRepositoryImpl implements PushRepository {
  PushRepositoryImpl({required this._messaging, required this._dio});

  final FirebaseMessaging _messaging;
  final Dio _dio;

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true, badge: true, sound: true,
      announcement: false, carPlay: false, criticalAlert: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> getToken() => _messaging.getToken();

  @override
  Stream<String> get tokenRefreshes => _messaging.onTokenRefresh;

  @override
  Future<Failure?> registerToken(String token) async {
    try {
      await _dio.post('/devices', data: {'fcm_token': token, 'platform': 'android'});
      return null;
    } catch (e) {
      return failureFromError(e, otherwise: LocalFailure.new);
    }
  }

  @override
  Future<Failure?> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      return null;
    } catch (e) {
      return failureFromError(e, otherwise: LocalFailure.new);
    }
  }

  @override
  Future<Failure?> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      return null;
    } catch (e) {
      return failureFromError(e, otherwise: LocalFailure.new);
    }
  }
}
