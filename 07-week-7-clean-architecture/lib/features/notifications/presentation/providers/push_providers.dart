import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../domain/usecases/register_device_token.dart';

final registerDeviceTokenProvider = Provider(
    (ref) => RegisterDeviceToken(ref.watch(pushRepositoryProvider)));

/// Current FCM token, then every rotation (onTokenRefresh).
final fcmTokenProvider = StreamProvider<String?>((ref) async* {
  final repository = ref.watch(pushRepositoryProvider);
  yield await repository.getToken();
  yield* repository.tokenRefreshes;
});
