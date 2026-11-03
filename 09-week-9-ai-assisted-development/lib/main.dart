import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/push_bootstrap.dart';
import 'features/announcements/presentation/pages/announcement_page.dart';
import 'features/announcements/presentation/pages/home_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/notifications/data/push_service.dart';
import 'features/notifications/presentation/pages/debug_page.dart';
import 'features/notifications/presentation/providers/debug_log_provider.dart';
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
    widget.container.listen(authStateProvider, (_, _) => _refresh.value++);

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
        GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
        GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
        GoRoute(path: AppRoutes.debug, builder: (_, _) => const DebugPage()),
        GoRoute(
          path: AppRoutes.announcementPattern,
          builder: (_, s) =>
              AnnouncementPage(id: s.pathParameters['id'] ?? ''),
        ),
      ],
    );

    if (widget.firebaseReady) {
      setupPush(container: widget.container, go: (route) => _router.go(route));
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
