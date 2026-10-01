import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);
    final offline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts (cache-first)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: () => ref.invalidate(postsProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          if (offline)
            Container(
              width: double.infinity,
              color: Colors.orange.shade100,
              padding: const EdgeInsets.all(8),
              child: const Text('Offline mode: showing cached data only'),
            ),
          Expanded(
            child: posts.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) => list.isEmpty
                  ? const Center(
                      child: Text('No cached posts yet. Go online and reload.'))
                  : ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) => ListTile(
                        leading: CircleAvatar(child: Text('${list[i].id}')),
                        title: Text(list[i].title,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(list[i].body,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
