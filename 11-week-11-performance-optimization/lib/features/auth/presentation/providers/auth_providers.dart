import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../domain/usecases/get_session.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';

// Domain layer: use cases receive the abstraction, not an implementation.
final loginUseCaseProvider =
    Provider((ref) => Login(ref.watch(authRepositoryProvider)));
final logoutUseCaseProvider =
    Provider((ref) => Logout(ref.watch(authRepositoryProvider)));
final getSessionUseCaseProvider =
    Provider((ref) => GetSession(ref.watch(authRepositoryProvider)));

// Presentation layer: state for the UI and the route guard.
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
