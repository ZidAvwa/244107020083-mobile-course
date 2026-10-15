import '../../../../core/failures.dart';
import '../repositories/push_repository.dart';

/// Fetch the current FCM token and register it with the backend.
class RegisterDeviceToken {
  const RegisterDeviceToken(this._repository);
  final PushRepository _repository;

  Future<Failure?> call() async {
    final token = await _repository.getToken();
    if (token == null) return const LocalFailure('No FCM token available');
    return _repository.registerToken(token);
  }
}
