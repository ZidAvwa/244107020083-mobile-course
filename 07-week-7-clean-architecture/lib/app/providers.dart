import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/data/token_store.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/notifications/data/push_repository_impl.dart';
import '../features/notifications/domain/repositories/push_repository.dart';
import '../infrastructure/network/api_client.dart';

/// The only place where concrete data-layer classes are constructed.
/// Features read the abstractions below; widgets never create repositories.

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    store: ref.watch(tokenStoreProvider),
    remote: AuthRemoteDataSource(),
  );
});

final apiClientProvider = Provider<Dio>((ref) {
  return buildApiClient(ref.watch(authRepositoryProvider));
});

final pushRepositoryProvider = Provider<PushRepository>((ref) {
  return PushRepositoryImpl(
    messaging: FirebaseMessaging.instance,
    dio: ref.watch(apiClientProvider),
  );
});
