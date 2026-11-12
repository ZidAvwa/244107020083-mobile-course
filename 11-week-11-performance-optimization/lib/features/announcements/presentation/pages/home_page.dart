import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/announcement_search_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          const _AnnouncementSearchField(),
          const Expanded(child: _AnnouncementsList()),
        ],
      ),
    );
  }
}

class _AnnouncementSearchField extends ConsumerStatefulWidget {
  const _AnnouncementSearchField();

  @override
  ConsumerState<_AnnouncementSearchField> createState() =>
      _AnnouncementSearchFieldState();
}

class _AnnouncementSearchFieldState
    extends ConsumerState<_AnnouncementSearchField> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(announcementSearchQueryProvider);
    return Padding(
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
                    ref.read(announcementSearchQueryProvider.notifier).clear();
                  },
                ),
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) =>
            ref.read(announcementSearchQueryProvider.notifier).update(value),
      ),
    );
  }
}

class _AnnouncementsList extends ConsumerWidget {
  const _AnnouncementsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(announcementSearchQueryProvider);
    final announcements = ref.watch(searchAnnouncementsProvider)(
      announcements: ref.watch(announcementSummariesProvider),
      query: query,
    );

    if (announcements.isEmpty) {
      return const Center(
        child: Text(
          'No announcements found. Try a different search.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        final announcement = announcements[index];
        return ListTile(
          title: Text(announcement.title),
          onTap: () => context.push(AppRoutes.announcement(announcement.id)),
        );
      },
    );
  }
}
