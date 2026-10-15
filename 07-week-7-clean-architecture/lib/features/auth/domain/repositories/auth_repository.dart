import '../../../../core/failures.dart';
import '../entities/auth_session.dart';

/// Contract only. Implementations live in the data layer.
abstract class AuthRepository {
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  });

  /// Uses the stored refresh token; stores and returns the new access token.
  Future<({String? access, Failure? failure})> refreshAccessToken();

  Future<String?> readAccessToken();

  Future<bool> hasSession();

  /// Clears the stored session. Returns a failure if clearing failed.
  Future<Failure?> logout();
}
