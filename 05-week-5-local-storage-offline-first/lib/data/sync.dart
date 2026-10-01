import 'repositories/note_repository.dart';

/// Simulated upload of dirty notes. Returns how many notes were synced.
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  // Simulate upload: in a real project, send each dirty note
  // to the REST API here, then mark it clean on a 2xx response.
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}
