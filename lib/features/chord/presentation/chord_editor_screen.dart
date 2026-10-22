import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/music/tuning_presets.dart';
import '../../../shared/music/tuning_selector.dart';
import '../../tab/application/finger_colors.dart';
import '../application/chord_chart_data.dart';
import '../application/chord_chart_provider.dart';
import 'capo_selector.dart';
import 'chord_diagram_painter.dart';

enum _StringDialogResult { save, clear }

class ChordEditorScreen extends ConsumerWidget {
  const ChordEditorScreen({super.key, required this.chartId});

  final String chartId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final chartAsync = ref.watch(chordChartByIdProvider(chartId));

    return chartAsync.when(
      data: (chart) {
        if (chart == null) {
          // Deleted (e.g. from the chord charts list) while this screen
          // was open.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        final data = ChordChartData.fromJsonString(chart.data);
        final title = (chart.title?.isNotEmpty ?? false)
            ? chart.title!
            : l10n.untitledChordChartTitle;

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: l10n.renameChordChart,
                onPressed: () => _rename(context, ref, chart.title ?? ''),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: l10n.addChordLabel,
                onPressed: () => ref
                    .read(chordChartsRepositoryProvider)
                    .updateData(chartId, data.withDiagramAdded()),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.deleteChordChart,
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 8,
                  children: [
                    TuningSelector(
                      tuning: data.tuning,
                      onChanged: (preset) => ref
                          .read(chordChartsRepositoryProvider)
                          .updateData(
                            chartId,
                            data.withTuning(preset.stringNames),
                          ),
                    ),
                    CapoSelector(
                      capoFret: data.capoFret,
                      onChanged: (fret) => ref
                          .read(chordChartsRepositoryProvider)
                          .updateData(chartId, data.withCapoFret(fret)),
                    ),
                  ],
                ),
              ),
              const _FingerLegend(),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (
                        var diagramIndex = 0;
                        diagramIndex < data.diagrams.length;
                        diagramIndex++
                      )
                        _ChordDiagramCard(
                          chartId: chartId,
                          data: data,
                          diagramIndex: diagramIndex,
                        ),
                    ],
                  ),
                ),
              ),
            ],
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
    String currentTitle,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentTitle);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renameChordChart),
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
      await ref.read(chordChartsRepositoryProvider).rename(chartId, newTitle);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteChordChart),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteChordChart),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(chordChartsRepositoryProvider).delete(chartId);
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }
}

/// Small color key for the finger numbers used on fretted dots — same
/// legend as the tab editor's, so the two editors stay visually
/// consistent.
class _FingerLegend extends StatelessWidget {
  const _FingerLegend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = {
      1: l10n.fingerIndexLabel,
      2: l10n.fingerMiddleLabel,
      3: l10n.fingerRingLabel,
      4: l10n.fingerPinkyLabel,
      5: l10n.fingerThumbLabel,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 4,
        children: labels.entries.map((entry) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colorForFinger(entry.key),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text('${entry.key} ${entry.value}'),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// One chord's name, open/muted markers, and fretboard grid. Tapping a
/// string's O/X marker toggles muted/open (clearing any fret); tapping a
/// grid cell sets that string's fret to the tapped row, with an optional
/// finger assignment, same pattern as the tab editor's fret dialog.
class _ChordDiagramCard extends ConsumerWidget {
  const _ChordDiagramCard({
    required this.chartId,
    required this.data,
    required this.diagramIndex,
  });

  final String chartId;
  final ChordChartData data;
  final int diagramIndex;

  static const stringSpacing = 28.0;
  static const fretRowHeight = 32.0;
  static const fretRows = 5;
  static const markerSize = 24.0;

  /// Extra margin on each side of the grid so the open/muted markers and
  /// the finger dots on the low/high (edge) strings aren't cut off —
  /// they're centered *on* the edge string lines, so without this margin
  /// half of each would fall outside the grid's own width.
  static const edgePadding = 14.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final diagram = data.diagrams[diagramIndex];
    final stringCount = diagram.strings.length;
    final gridWidth = (stringCount - 1) * stringSpacing;
    final gridHeight = fretRows * fretRowHeight;
    final cardWidth = gridWidth + 2 * edgePadding;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => _renameDiagram(context, ref, diagram.name),
                child: Text(
                  diagram.name.isEmpty ? l10n.untitledChordLabel : diagram.name,
                ),
              ),
              TextButton(
                onPressed: () => _editBaseFret(context, ref, diagram.baseFret),
                child: Text(l10n.baseFretButtonLabel(diagram.baseFret)),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 14),
                tooltip: l10n.removeChordLabel,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                onPressed: () => ref
                    .read(chordChartsRepositoryProvider)
                    .updateData(
                      chartId,
                      data.withDiagramRemovedAt(diagramIndex),
                    ),
              ),
            ],
          ),
          SizedBox(
            width: cardWidth,
            height: markerSize,
            child: Stack(
              children: [
                for (var s = 0; s < stringCount; s++)
                  Positioned(
                    left: edgePadding + s * stringSpacing - markerSize / 2,
                    width: markerSize,
                    height: markerSize,
                    child: _OpenMuteMarker(
                      string: diagram.strings[s],
                      onTap: () => _toggleOpenMute(ref, diagramIndex, s),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: cardWidth,
            height: gridHeight,
            child: Stack(
              children: [
                Positioned(
                  left: edgePadding,
                  top: 0,
                  child: CustomPaint(
                    size: Size(gridWidth, gridHeight),
                    painter: ChordDiagramPainter(
                      strings: diagram.strings,
                      fretRows: fretRows,
                      stringSpacing: stringSpacing,
                      fretRowHeight: fretRowHeight,
                      lineColor: colorScheme.outlineVariant,
                      showNut: diagram.baseFret == 0,
                    ),
                  ),
                ),
                for (var s = 0; s < stringCount; s++)
                  for (var f = 1; f <= fretRows; f++)
                    Positioned(
                      left: edgePadding + s * stringSpacing - stringSpacing / 2,
                      top: (f - 1) * fretRowHeight,
                      width: stringSpacing,
                      height: fretRowHeight,
                      child: InkWell(
                        onTap: () =>
                            _editString(context, ref, diagramIndex, s, f),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleOpenMute(WidgetRef ref, int diagramIndex, int stringIndex) {
    final diagram = data.diagrams[diagramIndex];
    final current = diagram.strings[stringIndex];
    final next = current.isMuted
        ? const ChordString(fret: 0)
        : const ChordString(fret: null);
    ref
        .read(chordChartsRepositoryProvider)
        .updateData(
          chartId,
          data.withStringSet(
            diagramIndex: diagramIndex,
            stringIndex: stringIndex,
            value: next,
          ),
        );
  }

  Future<void> _renameDiagram(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chordNameDialogTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.chordNameDialogTitle),
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
    if (newName != null) {
      await ref
          .read(chordChartsRepositoryProvider)
          .updateData(chartId, data.withDiagramNameSet(diagramIndex, newName));
    }
  }

  Future<void> _editBaseFret(
    BuildContext context,
    WidgetRef ref,
    int currentBaseFret,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: '$currentBaseFret');
    final newBaseFret = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.baseFretDialogTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.baseFretDialogTitle),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text);
              Navigator.pop(context, parsed == null ? null : max(0, parsed));
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (newBaseFret != null) {
      await ref
          .read(chordChartsRepositoryProvider)
          .updateData(
            chartId,
            data.withDiagramBaseFretSet(diagramIndex, newBaseFret),
          );
    }
  }

  Future<void> _editString(
    BuildContext context,
    WidgetRef ref,
    int diagramIndex,
    int stringIndex,
    int fretRow,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final diagram = data.diagrams[diagramIndex];
    final current = diagram.strings[stringIndex];
    var selectedFinger = current.fret == fretRow ? current.finger : null;
    var assignFinger = selectedFinger != null;
    final fingerLabels = {
      1: l10n.fingerIndexLabel,
      2: l10n.fingerMiddleLabel,
      3: l10n.fingerRingLabel,
      4: l10n.fingerPinkyLabel,
      5: l10n.fingerThumbLabel,
    };

    final result = await showDialog<_StringDialogResult>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.fretDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                value: assignFinger,
                onChanged: (value) =>
                    setState(() => assignFinger = value ?? false),
                title: Text(l10n.assignFingerToggleLabel),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              Opacity(
                opacity: assignFinger ? 1 : 0.4,
                child: Wrap(
                  spacing: 8,
                  children: fingerLabels.entries.map((entry) {
                    final finger = entry.key;
                    final selected = selectedFinger == finger;
                    return ChoiceChip(
                      label: Text('$finger'),
                      tooltip: entry.value,
                      selected: selected,
                      selectedColor: colorForFinger(finger)
                          .withValues(alpha: 0.3),
                      onSelected: !assignFinger
                          ? null
                          : (isSelected) => setState(
                              () => selectedFinger = isSelected ? finger : null,
                            ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, _StringDialogResult.clear),
              child: Text(l10n.clearFretLabel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, _StringDialogResult.save),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;

    final value = result == _StringDialogResult.clear
        ? const ChordString(fret: 0)
        : ChordString(
            fret: fretRow,
            finger: assignFinger ? selectedFinger : null,
          );

    await ref
        .read(chordChartsRepositoryProvider)
        .updateData(
          chartId,
          data.withStringSet(
            diagramIndex: diagramIndex,
            stringIndex: stringIndex,
            value: value,
          ),
        );
  }
}

/// Always shows a bordered box above the string, even when fretted (blank
/// inside), so there's a visibly tappable control for muting/opening a
/// string rather than invisible empty space.
class _OpenMuteMarker extends StatelessWidget {
  const _OpenMuteMarker({required this.string, required this.onTap});

  final ChordString string;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = string.isOpen ? 'O' : (string.isMuted ? 'X' : '');
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
      ),
    );
  }
}
