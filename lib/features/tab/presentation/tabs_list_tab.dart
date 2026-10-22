import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../application/guitar_tabs_provider.dart';
import 'tab_editor_screen.dart';

/// Lists the guitar tabs attached to a note — the "Tabs" main tab, as
/// opposed to the toolbar's "Tab" button which creates a new one directly.
class TabsListTab extends ConsumerWidget {
  const TabsListTab({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tabsAsync = ref.watch(guitarTabsProvider(noteId));

    return tabsAsync.when(
      data: (tabs) {
        if (tabs.isEmpty) {
          return Center(child: Text(l10n.tabsListEmpty));
        }
        return ListView.builder(
          itemCount: tabs.length,
          itemBuilder: (context, index) {
            final tab = tabs[index];
            final title = (tab.title?.isNotEmpty ?? false)
                ? tab.title!
                : l10n.untitledTabTitle;
            return ListTile(
              leading: const Icon(Icons.piano_outlined),
              title: Text(title),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TabEditorScreen(tabId: tab.id),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.deleteTab,
                onPressed: () =>
                    ref.read(guitarTabsRepositoryProvider).delete(tab.id),
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
