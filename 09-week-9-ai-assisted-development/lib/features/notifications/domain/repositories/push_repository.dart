import '../../../../core/failures.dart';

/// Contract only. Hides firebase_messaging and the /devices API from callers.
abstract class PushRepository {
  Future<bool> requestPermission();
  Future<String?> getToken();
  Stream<String> get tokenRefreshes;

  /// Sends the token to the backend (POST /devices).
  Future<Failure?> registerToken(String token);

  Future<Failure?> subscribeToTopic(String topic);
  Future<Failure?> unsubscribeFromTopic(String topic);
}
