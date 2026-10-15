import '../../../../core/api_errors.dart';
import '../../../../core/failures.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../auth_remote_data_source.dart';
import '../models/auth_session_model.dart';
import '../token_store.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this._store, required this._remote});

  final TokenStore _store;
  final AuthRemoteDataSource _remote;

  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = AuthSessionModel.fromMap(
        await _remote.login(email: email, password: password),
      );
      await _store.save(access: model.access, refresh: model.refresh);
      return (session: model.toEntity(), failure: null);
    } catch (e) {
      return (
        session: null,
        failure: failureFromError(e, otherwise: AuthFailure.new),
      );
    }
  }

  @override
  Future<({String? access, Failure? failure})> refreshAccessToken() async {
    try {
      final refresh = await _store.readRefresh();
      if (refresh == null || refresh.isEmpty) {
        return (access: null, failure: const AuthFailure('Refresh token missing'));
      }
      final map = await _remote.refresh(refresh);
      final access = map['access'] as String? ?? '';
      if (access.isEmpty) {
        return (access: null, failure: const AuthFailure('Empty access token'));
      }
      await _store.save(access: access, refresh: refresh);
      return (access: access, failure: null);
    } catch (e) {
      return (
        access: null,
        failure: failureFromError(e, otherwise: AuthFailure.new),
      );
    }
  }

  @override
  Future<String?> readAccessToken() => _store.readAccess();

  @override
  Future<bool> hasSession() async => (await _store.readAccess()) != null;

  @override
  Future<Failure?> logout() async {
    try {
      await _store.clear();
      return null;
    } catch (e) {
      return LocalFailure('Failed to clear session: $e');
    }
  }
}
