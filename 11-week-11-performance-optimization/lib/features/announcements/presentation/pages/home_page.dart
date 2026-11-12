import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/announcement_search_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(announcementSearchQueryProvider);
    final announcementsList = ref.watch(announcementSummariesProvider);
    final announcements = ref.watch(searchAnnouncementsProvider)(
      announcements: announcementsList,
      query: query,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        actions: [
          IconButton(
            tooltip: 'Ask AI',
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => context.push(AppRoutes.aiChat),
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => context.push(AppRoutes.debug),
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
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(announcementSearchQueryProvider.notifier)
                              .clear();
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => ref
                  .read(announcementSearchQueryProvider.notifier)
                  .update(value),
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
                          onTap: () => context.push(
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
