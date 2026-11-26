import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../features/auth/data/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/data/token_store.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/get_session.dart';
import '../features/auth/domain/usecases/login.dart';
import '../features/auth/domain/usecases/logout.dart';

// NOTE: Lab 2 keeps this file in place so the app still compiles.
// Lab 3 moves it to features/auth/presentation/providers and splits DI.

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final authRepositoryProvider = Provider<AuthRepository>((ref) =>
    AuthRepositoryImpl(
      store: ref.watch(tokenStoreProvider),
      remote: AuthRemoteDataSource(),
    ));

final apiClientProvider = Provider<Dio>(
    (ref) => buildApiClient(ref.watch(authRepositoryProvider)));

final loginUseCaseProvider =
    Provider((ref) => Login(ref.watch(authRepositoryProvider)));
final logoutUseCaseProvider =
    Provider((ref) => Logout(ref.watch(authRepositoryProvider)));
final getSessionUseCaseProvider =
    Provider((ref) => GetSession(ref.watch(authRepositoryProvider)));

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(getSessionUseCaseProvider)();

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(loginUseCaseProvider)(email: email, password: password);
      if (result.failure != null) throw result.failure!;
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider)();
    ref.invalidateSelf();
  }
}
