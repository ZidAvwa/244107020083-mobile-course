import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  Future<void> _addNote(BuildContext context, WidgetRef ref) async {
    final draft = await showDialog<_NoteDraft>(
      context: context,
      builder: (_) => const _NewNoteDialog(),
    );
    if (draft != null) {
      await ref.read(notesProvider.notifier).add(draft.title, draft.body);
    }
  }

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    if (ref.read(forceOfflineProvider)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('You are offline. Turn offline off to sync.'),
        ),
      );
      return;
    }
    final count = await ref.read(notesProvider.notifier).sync();
    messenger.showSnackBar(SnackBar(content: Text('Synced $count note(s)')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final dirty = ref.watch(dirtyCountProvider).value ?? 0;
    final offline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          const Icon(Icons.wifi_off, size: 18),
          Switch(
            value: offline,
            onChanged: (_) => ref.read(forceOfflineProvider.notifier).toggle(),
          ),
          IconButton(
            tooltip: 'Sync',
            onPressed: () => _sync(context, ref),
            icon: Badge(
              isLabelVisible: dirty > 0,
              label: Text('$dirty'),
              child: const Icon(Icons.sync),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNote(context, ref),
        child: const Icon(Icons.add),
      ),
      body: notes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => list.isEmpty
            ? const Center(child: Text('No notes yet. Tap + to add one.'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final n = list[i];
                  return ListTile(
                    title: Text(n.title),
                    subtitle: Text(n.body),
                    leading: Icon(
                      n.dirty ? Icons.cloud_off : Icons.cloud_done,
                      color: n.dirty ? Colors.orange : Colors.green,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          ref.read(notesProvider.notifier).remove(n.id!),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _NoteDraft {
  const _NoteDraft(this.title, this.body);

  final String title;
  final String body;
}

class _NewNoteDialog extends StatefulWidget {
  const _NewNoteDialog();

  @override
  State<_NewNoteDialog> createState() => _NewNoteDialogState();
}

class _NewNoteDialogState extends State<_NewNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New note'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              autofocus: true,
              validator: (value) =>
                  value?.trim().isNotEmpty == true ? null : 'Title is required',
            ),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: 'Body'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                _NoteDraft(
                  _titleController.text.trim(),
                  _bodyController.text.trim(),
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
