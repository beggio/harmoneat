import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../application/notation_sheet_data.dart';
import '../application/notation_sheet_provider.dart';
import 'event_layout_builder.dart';
import 'notation_staff_painter.dart';

const _pitchLetters = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
const _minOctave = 2;
const _maxOctave = 6;
const _timeSigNumerators = [1, 2, 3, 4, 5, 6, 7, 8, 9, 12];
const _timeSigDenominators = [1, 2, 4, 8, 16];

class NotationEditorScreen extends ConsumerWidget {
  const NotationEditorScreen({super.key, required this.sheetId});

  final String sheetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sheetAsync = ref.watch(notationSheetByIdProvider(sheetId));

    return sheetAsync.when(
      data: (sheet) {
        if (sheet == null) {
          // Deleted (e.g. from the sheets list) while this screen was open.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        final data = NotationSheetData.fromJsonString(sheet.data);
        final title = (sheet.title?.isNotEmpty ?? false)
            ? sheet.title!
            : l10n.untitledNotationSheetTitle;

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: l10n.renameNotationSheet,
                onPressed: () => _rename(context, ref, sheet.title ?? ''),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: l10n.addNoteEventLabel,
                onPressed: () => ref
                    .read(notationSheetsRepositoryProvider)
                    .updateData(
                      sheetId,
                      data.withEventAdded(NotationEvent.defaultRest()),
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.deleteNotationSheet,
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _TimeSignatureSelector(
                  numerator: data.timeSigNumerator,
                  denominator: data.timeSigDenominator,
                  onChanged: (newNumerator, newDenominator) => ref
                      .read(notationSheetsRepositoryProvider)
                      .updateData(
                        sheetId,
                        data.withTimeSignature(newNumerator, newDenominator),
                      ),
                ),
              ),
              Expanded(
                child: _NotationStaffView(sheetId: sheetId, data: data),
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
        title: Text(l10n.renameNotationSheet),
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
      await ref
          .read(notationSheetsRepositoryProvider)
          .rename(sheetId, newTitle);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteNotationSheet),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteNotationSheet),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(notationSheetsRepositoryProvider).delete(sheetId);
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }
}

class _TimeSignatureSelector extends StatelessWidget {
  const _TimeSignatureSelector({
    required this.numerator,
    required this.denominator,
    required this.onChanged,
  });

  final int numerator;
  final int denominator;
  final void Function(int numerator, int denominator) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${l10n.timeSignatureLabel}: '),
        DropdownButton<int>(
          value: numerator,
          items: [
            for (final n in _timeSigNumerators)
              DropdownMenuItem(value: n, child: Text('$n')),
          ],
          onChanged: (n) {
            if (n != null) onChanged(n, denominator);
          },
        ),
        const Text(' / '),
        DropdownButton<int>(
          value: denominator,
          items: [
            for (final d in _timeSigDenominators)
              DropdownMenuItem(value: d, child: Text('$d')),
          ],
          onChanged: (d) {
            if (d != null) onChanged(numerator, d);
          },
        ),
      ],
    );
  }
}

/// The scrollable staff: a row of small remove buttons (one per event,
/// mirroring the tab editor's per-beat remove row), then the staff itself
/// — a `NotationStaffPainter` for the visuals with a transparent `InkWell`
/// overlay (same event geometry) handling taps, same pattern as the tab
/// and chord editors.
class _NotationStaffView extends ConsumerWidget {
  const _NotationStaffView({required this.sheetId, required this.data});

  final String sheetId;
  final NotationSheetData data;

  static const lineSpacing = 10.0;
  static const bottomLineY = 140.0;
  static const staffCanvasHeight = 280.0;
  static const pixelsPerBeat = 32.0;
  static const minEventWidth = 28.0;
  static const startX = 48.0;
  static const removeButtonSize = 24.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final layouts = buildEventLayouts(
      data.events,
      measureBeats: data.measureBeats,
      pixelsPerBeat: pixelsPerBeat,
      minEventWidth: minEventWidth,
      startX: startX,
    );
    final totalWidth = layouts.isEmpty
        ? startX
        : layouts.last.x + layouts.last.width + 16;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: removeButtonSize,
                child: Stack(
                  children: [
                    for (var i = 0; i < layouts.length; i++)
                      Positioned(
                        left:
                            layouts[i].x +
                            layouts[i].width / 2 -
                            removeButtonSize / 2,
                        width: removeButtonSize,
                        height: removeButtonSize,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 14),
                          tooltip: l10n.removeNoteEventLabel,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: removeButtonSize,
                            minHeight: removeButtonSize,
                          ),
                          onPressed: () => ref
                              .read(notationSheetsRepositoryProvider)
                              .updateData(sheetId, data.withEventRemovedAt(i)),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: totalWidth,
                height: staffCanvasHeight,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(totalWidth, staffCanvasHeight),
                      painter: NotationStaffPainter(
                        layouts: layouts,
                        lineSpacing: lineSpacing,
                        bottomLineY: bottomLineY,
                        lineColor: colorScheme.outline,
                        noteColor: colorScheme.onSurface,
                      ),
                    ),
                    for (var i = 0; i < layouts.length; i++)
                      Positioned(
                        left: layouts[i].x,
                        top: 0,
                        width: layouts[i].width,
                        height: staffCanvasHeight,
                        child: InkWell(
                          onTap: () => _editEvent(context, ref, i),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editEvent(
    BuildContext context,
    WidgetRef ref,
    int eventIndex,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final current = data.events[eventIndex];
    var isRest = current.isRest;
    var letter = current.pitch?.letter ?? 'C';
    var accidental = current.pitch?.accidental ?? 0;
    var octave = current.pitch?.octave ?? 4;
    var duration = current.duration;
    var dotted = current.dotted;

    final durationLabels = {
      NoteDuration.whole: l10n.durationWholeLabel,
      NoteDuration.half: l10n.durationHalfLabel,
      NoteDuration.quarter: l10n.durationQuarterLabel,
      NoteDuration.eighth: l10n.durationEighthLabel,
    };
    final accidentalLabels = {
      -1: l10n.accidentalFlatLabel,
      0: l10n.accidentalNaturalLabel,
      1: l10n.accidentalSharpLabel,
    };

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.noteEventDialogTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  value: isRest,
                  onChanged: (value) => setState(() => isRest = value ?? false),
                  title: Text(l10n.restToggleLabel),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                Opacity(
                  opacity: isRest ? 0.4 : 1,
                  child: IgnorePointer(
                    ignoring: isRest,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('${l10n.pitchLetterLabel}: '),
                            DropdownButton<String>(
                              value: letter,
                              items: [
                                for (final l in _pitchLetters)
                                  DropdownMenuItem(value: l, child: Text(l)),
                              ],
                              onChanged: (value) =>
                                  setState(() => letter = value ?? letter),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('${l10n.accidentalLabel}: '),
                            DropdownButton<int>(
                              value: accidental,
                              items: [
                                for (final entry in accidentalLabels.entries)
                                  DropdownMenuItem(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  ),
                              ],
                              onChanged: (value) => setState(
                                () => accidental = value ?? accidental,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('${l10n.octaveLabel}: '),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: octave > _minOctave
                                  ? () => setState(() => octave -= 1)
                                  : null,
                            ),
                            Text('$octave'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: octave < _maxOctave
                                  ? () => setState(() => octave += 1)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: durationLabels.entries.map((entry) {
                    return ChoiceChip(
                      label: Text(entry.value),
                      selected: duration == entry.key,
                      onSelected: (_) => setState(() => duration = entry.key),
                    );
                  }).toList(),
                ),
                CheckboxListTile(
                  value: dotted,
                  onChanged: (value) => setState(() => dotted = value ?? false),
                  title: Text(l10n.dottedLabel),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );

    if (saved != true) return;

    final event = NotationEvent(
      isRest: isRest,
      pitch: isRest
          ? null
          : Pitch(letter: letter, accidental: accidental, octave: octave),
      duration: duration,
      dotted: dotted,
    );

    await ref
        .read(notationSheetsRepositoryProvider)
        .updateData(sheetId, data.withEventReplacedAt(eventIndex, event));
  }
}
