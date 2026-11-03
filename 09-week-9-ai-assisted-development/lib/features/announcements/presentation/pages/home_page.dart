import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const _announcements = [(id: '1', title: 'Welcome to Campus Notify')];

  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _normalize(_query);
    final announcements = _announcements.where(
      (announcement) =>
          _normalize(announcement.title).contains(normalizedQuery),
    );

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search announcements',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: announcements.isEmpty
                ? const Center(
                    child: Text(
                      'No announcements found. Try a different search.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView(
                    children: [
                      for (final announcement in announcements)
                        ListTile(
                          title: Text(announcement.title),
                          onTap: () => context.go(
                            AppRoutes.announcement(announcement.id),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

String _normalize(String value) =>
    value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
