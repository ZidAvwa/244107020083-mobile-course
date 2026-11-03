import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/pages/notes_page.dart';
import 'package:week5_offline_notes/providers.dart';

class _FakeNoteRepository extends NoteRepository {
  final List<Note> notes = [];
  int addCalls = 0;

  @override
  Future<List<Note>> fetchNotes() async => List.of(notes);

  @override
  Future<int> countDirty() async => 0;

  @override
  Future<Note> addNote({required String title, String body = ''}) async {
    addCalls++;
    final note = Note(
      id: addCalls,
      title: title,
      body: body,
      updatedAt: DateTime(2026),
      dirty: true,
    );
    notes.add(note);
    return note;
  }
}

void main() {
  testWidgets('rejects a blank title and saves a trimmed title', (
    WidgetTester tester,
  ) async {
    final repository = _FakeNoteRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [noteRepositoryProvider.overrideWith((ref) => repository)],
        child: const MaterialApp(home: NotesPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Title is required'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(repository.addCalls, 0);
    expect(repository.notes, isEmpty);

    await tester.enterText(find.byType(TextFormField), '  Lecture notes  ');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(repository.addCalls, 1);
    expect(repository.notes.single.title, 'Lecture notes');
    expect(find.text('Lecture notes'), findsOneWidget);
  });
}
