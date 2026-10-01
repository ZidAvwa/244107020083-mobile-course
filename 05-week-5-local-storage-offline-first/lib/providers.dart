import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/local/note.dart';
import 'data/post.dart';
import 'data/repositories/note_repository.dart';
import 'data/repositories/post_repository.dart';
import 'data/sync.dart';

// ---------- Repositories ----------
final noteRepositoryProvider = Provider((ref) => NoteRepository());
final postRepositoryProvider = Provider((ref) => PostRepository());

// ---------- Force offline toggle ----------
class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

// ---------- Posts: cache-first ----------
class PostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repo = ref.read(postRepositoryProvider);
    final cached = await repo.readCachedPosts(); // instant
    _refresh(); // background, not awaited
    return cached;
  }

  Future<void> _refresh() async {
    if (ref.read(forceOfflineProvider)) return; // simulated offline
    try {
      final repo = ref.read(postRepositoryProvider);
      await repo.refreshPosts();
      state = AsyncData(await repo.readCachedPosts());
    } catch (_) {
      // offline or failed: keep showing the cache
    }
  }
}

final postsProvider =
    AsyncNotifierProvider<PostsNotifier, List<Post>>(PostsNotifier.new);

// ---------- Notes ----------
class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() => ref.read(noteRepositoryProvider).fetchNotes();

  Future<void> add(String title, String body) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.addNote(title: title, body: body);
    state = AsyncData(await repo.fetchNotes());
  }

  Future<void> remove(int id) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.deleteNote(id);
    state = AsyncData(await repo.fetchNotes());
  }

  /// Runs the simulated sync. Returns how many notes were synced.
  Future<int> sync() async {
    final repo = ref.read(noteRepositoryProvider);
    final count = await syncNotes(repo);
    state = AsyncData(await repo.fetchNotes());
    return count;
  }
}

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

// Dirty badge: recomputed whenever the notes list changes.
final dirtyCountProvider = FutureProvider<int>((ref) {
  ref.watch(notesProvider);
  return ref.read(noteRepositoryProvider).countDirty();
});
