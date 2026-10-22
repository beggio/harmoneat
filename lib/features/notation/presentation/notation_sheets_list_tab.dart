import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../application/notation_sheet_provider.dart';
import 'notation_editor_screen.dart';

/// Lists the notation sheets attached to a note — the "Notation" main tab,
/// as opposed to the toolbar's "Notation" button which creates a new one
/// directly.
class NotationSheetsListTab extends ConsumerWidget {
  const NotationSheetsListTab({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sheetsAsync = ref.watch(notationSheetsProvider(noteId));

    return sheetsAsync.when(
      data: (sheets) {
        if (sheets.isEmpty) {
          return Center(child: Text(l10n.notationSheetsListEmpty));
        }
        return ListView.builder(
          itemCount: sheets.length,
          itemBuilder: (context, index) {
            final sheet = sheets[index];
            final title = (sheet.title?.isNotEmpty ?? false)
                ? sheet.title!
                : l10n.untitledNotationSheetTitle;
            return ListTile(
              leading: const Icon(Icons.music_note_outlined),
              title: Text(title),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NotationEditorScreen(sheetId: sheet.id),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.deleteNotationSheet,
                onPressed: () =>
                    ref.read(notationSheetsRepositoryProvider).delete(sheet.id),
              ),
            );
          },
        );
      },
      error: (error, stack) => Center(child: Text('$error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
