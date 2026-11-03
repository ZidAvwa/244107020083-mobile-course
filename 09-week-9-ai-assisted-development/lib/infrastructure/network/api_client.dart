import 'package:dio/dio.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';

/// Dio client. Depends only on the [AuthRepository] contract, never on
/// secure storage or the concrete repository.
Dio buildApiClient(AuthRepository auth) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://example-campus-api.test',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final access = await auth.readAccessToken();
      if (access != null) {
        options.headers['Authorization'] = 'Bearer $access';
      }
      handler.next(options);
    },
    onError: (e, handler) async {
      final alreadyRetried = e.requestOptions.extra['retried'] == true;
      if (e.response?.statusCode == 401 && !alreadyRetried) {
        final result = await auth.refreshAccessToken();
        if (result.access == null) {
          await auth.logout(); // refresh dead too -> force re-login
          return handler.next(e);
        }
        final options = e.requestOptions
          ..extra['retried'] = true // retry exactly once
          ..headers['Authorization'] = 'Bearer ${result.access}';
        try {
          return handler.resolve(await dio.fetch(options));
        } on DioException catch (retryError) {
          return handler.next(retryError);
        }
      }
      handler.next(e);
    },
  ));
  return dio;
}
