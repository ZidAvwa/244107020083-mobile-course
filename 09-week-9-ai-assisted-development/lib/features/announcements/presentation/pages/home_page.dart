import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => context.go(AppRoutes.debug),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Welcome to Campus Notify'),
            onTap: () => context.go(AppRoutes.announcement('1')),
          ),
        ],
      ),
    );
  }
}
