import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_logo_icon.dart';
import '../../../beta/beta_config.dart';
import '../../../beta/usage_tracker.dart';
import '../../../data/database/database.dart';
import '../../../data/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../application/notes_list_provider.dart';
import 'note_detail_screen.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notesAsync = ref.watch(notesListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppLogoIcon(),
        title: Text(l10n.notesListTitle),
      ),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return Center(child: Text(l10n.notesListEmpty));
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final title = note.title.isEmpty ? l10n.untitledNote : note.title;
              return ListTile(
                title: Text(title),
                subtitle: Text(note.updatedAt.toLocal().toString()),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NoteDetailScreen(noteId: note.id),
                  ),
                ),
                onLongPress: () => _confirmDelete(context, ref, note),
              );
            },
          );
        },
        error: (error, stack) => Center(child: Text('$error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.newNote,
        onPressed: () async {
          final id = await ref.read(notesRepositoryProvider).create();
          if (kBetaBuild) {
            ref.read(usageTrackerProvider.notifier).increment('note_created');
          }
          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => NoteDetailScreen(noteId: id)),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteNote),
        content: Text(note.title.isEmpty ? l10n.untitledNote : note.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteNote),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(notesRepositoryProvider).delete(note.id);
    }
  }
}
