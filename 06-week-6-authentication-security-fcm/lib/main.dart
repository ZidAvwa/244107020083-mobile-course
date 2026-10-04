import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase.initializeApp() + PushService().init() go here in the push lab.
  final container = ProviderContainer();
  runApp(UncontrolledProviderScope(
    container: container,
    child: CampusNotifyApp(container: container),
  ));
}

class CampusNotifyApp extends StatefulWidget {
  const CampusNotifyApp({super.key, required this.container});
  final ProviderContainer container;

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
    widget.container
        .listen(authStateProvider, (_, __) => _refresh.value++);

    _router = GoRouter(
      refreshListenable: _refresh,
      redirect: (context, state) {
        final auth = widget.container.read(authStateProvider);
        if (auth.isLoading && !auth.hasValue) return null;
        final loggedIn = auth.value ?? false;
        final goingLogin = state.matchedLocation == '/login';
        if (!loggedIn && !goingLogin) return '/login';
        if (loggedIn && goingLogin) return '/';
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/', builder: (_, __) => const HomePage()),
        GoRoute(
          path: '/announcement/:id',
          builder: (_, s) =>
              AnnouncementPage(id: s.pathParameters['id'] ?? ''),
        ),
      ],
    );
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
