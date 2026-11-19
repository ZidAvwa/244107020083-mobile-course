import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/auth/domain/entities/auth_session.dart';
import 'package:campus_notify/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notify/features/auth/domain/usecases/get_session.dart';
import 'package:campus_notify/features/auth/domain/usecases/login.dart';
import 'package:campus_notify/features/notifications/domain/repositories/push_repository.dart';
import 'package:campus_notify/features/notifications/domain/usecases/register_device_token.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.loggedIn = false});
  bool loggedIn;

  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    if (!email.contains('@')) {
      return (session: null, failure: const AuthFailure('Invalid email or password'));
    }
    loggedIn = true;
    return (session: const AuthSession(access: 'a', refresh: 'r'), failure: null);
  }

  @override
  Future<({String? access, Failure? failure})> refreshAccessToken() async =>
      (access: 'new', failure: null);

  @override
  Future<String?> readAccessToken() async => loggedIn ? 'a' : null;

  @override
  Future<bool> hasSession() async => loggedIn;

  @override
  Future<Failure?> logout() async {
    loggedIn = false;
    return null;
  }
}

class FakePushRepository implements PushRepository {
  FakePushRepository({this.token});
  String? token;
  String? registered;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<String?> getToken() async => token;

  @override
  Stream<String> get tokenRefreshes => const Stream.empty();

  @override
  Future<Failure?> registerToken(String token) async {
    registered = token;
    return null;
  }

  @override
  Future<Failure?> subscribeToTopic(String topic) async => null;

  @override
  Future<Failure?> unsubscribeFromTopic(String topic) async => null;
}

void main() {
  test('Login returns a failure for an invalid email', () async {
    final result = await Login(FakeAuthRepository())(email: 'nope', password: '123456');
    expect(result.session, isNull);
    expect(result.failure, isA<AuthFailure>());
  });

  test('Login returns a session and GetSession becomes true', () async {
    final repo = FakeAuthRepository();
    final result = await Login(repo)(email: 'a@b.c', password: '123456');
    expect(result.failure, isNull);
    expect(await GetSession(repo)(), isTrue);
  });

  test('RegisterDeviceToken fails locally when there is no token', () async {
    final failure = await RegisterDeviceToken(FakePushRepository())();
    expect(failure, isA<LocalFailure>());
  });

  test('RegisterDeviceToken sends the token to the repository', () async {
    final repo = FakePushRepository(token: 'abc');
    final failure = await RegisterDeviceToken(repo)();
    expect(failure, isNull);
    expect(repo.registered, 'abc');
  });
}
