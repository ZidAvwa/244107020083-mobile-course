import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format.dart';
import '../features/notifications/data/push_service.dart';
import '../features/notifications/presentation/providers/debug_log_provider.dart';
import '../features/notifications/presentation/providers/push_providers.dart';
import 'providers.dart';

/// Startup wiring for push. Runs once after the router exists.
/// Token lifecycle, permission and topics use PushRepository; local banners
/// and tap routing use the platform glue in push_service.dart.
Future<void> setupPush({
  required ProviderContainer container,
  required void Function(String route) go,
}) async {
  final log = container.read(debugLogProvider.notifier);
  try {
    final push = container.read(pushRepositoryProvider);

    final granted = await push.requestPermission();
    log.add('Notification permission granted: $granted');

    // Taps must work before any network call can delay them.
    onRouteRequested = go;
    await initLocalNotifications();
    listenForeground(go);
    await handleTerminated(go);

    // Token lifecycle: fetch + send, then watch for rotation.
    log.add('Token received: ${truncateToken(await push.getToken())}');
    final failure = await container.read(registerDeviceTokenProvider)();
    log.add(failure == null
        ? 'Token sent to backend'
        : 'Backend call failed (expected with mock URL)');

    push.tokenRefreshes.listen((token) async {
      log.add('Token refreshed: ${truncateToken(token)}');
      final f = await push.registerToken(token);
      log.add(f == null
          ? 'New token sent to backend'
          : 'Backend call failed (expected with mock URL)');
    });

    final topicFailure = await push.subscribeToTopic('campus-announcement');
    if (topicFailure != null) {
      log.add('Topic subscribe failed: ${topicFailure.message}');
    }
  } catch (e) {
    log.add('Push setup error: $e');
  }
}
