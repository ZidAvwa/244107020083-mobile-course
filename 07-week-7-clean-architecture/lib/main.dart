import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/debug_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'providers/debug_log_provider.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  final log = container.read(debugLogProvider.notifier);

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(); // needs android/app/google-services.json
    registerBackgroundHandler();
    firebaseReady = true;
  } catch (e) {
    log.add('Firebase init failed: $e');
  }

  runApp(UncontrolledProviderScope(
    container: container,
    child: CampusNotifyApp(container: container, firebaseReady: firebaseReady),
  ));
}

class CampusNotifyApp extends StatefulWidget {
  const CampusNotifyApp(
      {super.key, required this.container, required this.firebaseReady});
  final ProviderContainer container;
  final bool firebaseReady;

  @override
  State<CampusNotifyApp> createState() => _CampusNotifyAppState();
}

class _CampusNotifyAppState extends State<CampusNotifyApp> {
  final _refresh = ValueNotifier<int>(0);
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Re-run the redirect whenever auth state changes.
    widget.container.listen(authStateProvider, (_, __) => _refresh.value++);

    _router = GoRouter(
      refreshListenable: _refresh,
      redirect: (context, state) {
        final auth = widget.container.read(authStateProvider);
        if (auth.isLoading && !auth.hasValue) return null;
        final loggedIn = auth.value ?? false;
        final goingLogin = state.matchedLocation == AppRoutes.login;
        if (!loggedIn && !goingLogin) return AppRoutes.login;
        if (loggedIn && goingLogin) return AppRoutes.home;
        return null;
      },
      routes: [
        GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),
        GoRoute(path: AppRoutes.home, builder: (_, __) => const HomePage()),
        GoRoute(path: AppRoutes.debug, builder: (_, __) => const DebugPage()),
        GoRoute(
          path: AppRoutes.announcementPattern,
          builder: (_, s) =>
              AnnouncementPage(id: s.pathParameters['id'] ?? ''),
        ),
      ],
    );

    if (widget.firebaseReady) _setupPush();
  }

  Future<void> _setupPush() async {
    final c = widget.container;
    final log = c.read(debugLogProvider.notifier);
    try {
      final granted = await requestNotificationPermission();
      log.add('Notification permission granted: $granted');
      await initLocalNotifications();

      await initFcmToken(onToken: (token) async {
        log.add('Token received: ${truncateToken(token)}');
        try {
          await c
              .read(apiClientProvider)
              .post('/devices', data: {'fcm_token': token, 'platform': 'android'});
          log.add('Token sent to backend');
        } catch (e) {
          // The campus API URL is a placeholder, so this fails until a
          // real backend exists. The token flow itself still works.
          log.add('Backend call failed (expected with mock URL)');
        }
      });

      listenForeground((route) => _router.go(route));
      await handleTerminated((route) => _router.go(route));
    } catch (e) {
      log.add('Push setup error: $e');
    }
  }

  @override
  void dispose() {
    _refresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Notify',
      routerConfig: _router,
    );
  }
}
