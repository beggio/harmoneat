import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../audio/presentation/attachments_tab.dart';
import '../../tab/presentation/tabs_list_tab.dart';
import '../application/note_detail_provider.dart';
import 'note_body_tab.dart';
import 'note_detail_toolbar.dart';

class NoteDetailScreen extends ConsumerWidget {
  const NoteDetailScreen({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final noteAsync = ref.watch(noteDetailProvider(noteId));

    return noteAsync.when(
      data: (note) {
        if (note == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.untitledNote)),
          );
        }
        final title = note.title.isEmpty ? l10n.untitledNote : note.title;
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: l10n.renameNote,
                  onPressed: () => _rename(context, ref, note.id, note.title),
                ),
              ],
              bottom: TabBar(
                tabs: [
                  Tab(text: l10n.noteTextTabLabel),
                  Tab(text: l10n.attachmentsTabLabel),
                  Tab(text: l10n.tabsTabLabel),
                ],
              ),
            ),
            body: Column(
              children: [
                NoteDetailToolbar(noteId: note.id),
                Expanded(
                  child: TabBarView(
                    children: [
                      NoteBodyTab(noteId: note.id, initialBody: note.body),
                      AttachmentsTab(noteId: note.id),
                      TabsListTab(noteId: note.id),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      error: (error, stack) => Scaffold(body: Center(child: Text('$error'))),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    String id,
    String currentTitle,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentTitle);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renameNote),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.noteTitleLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (newTitle != null) {
      await ref.read(notesRepositoryProvider).rename(id, newTitle);
    }
  }
}
