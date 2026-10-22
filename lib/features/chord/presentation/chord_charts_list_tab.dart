import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../application/chord_chart_provider.dart';
import 'chord_editor_screen.dart';

/// Lists the chord charts attached to a note — the "Chords" main tab, as
/// opposed to the toolbar's "Chord" button which creates a new one
/// directly.
class ChordChartsListTab extends ConsumerWidget {
  const ChordChartsListTab({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final chartsAsync = ref.watch(chordChartsProvider(noteId));

    return chartsAsync.when(
      data: (charts) {
        if (charts.isEmpty) {
          return Center(child: Text(l10n.chordChartsListEmpty));
        }
        return ListView.builder(
          itemCount: charts.length,
          itemBuilder: (context, index) {
            final chart = charts[index];
            final title = (chart.title?.isNotEmpty ?? false)
                ? chart.title!
                : l10n.untitledChordChartTitle;
            return ListTile(
              leading: const Icon(Icons.grid_on_outlined),
              title: Text(title),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChordEditorScreen(chartId: chart.id),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.deleteChordChart,
                onPressed: () =>
                    ref.read(chordChartsRepositoryProvider).delete(chart.id),
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
