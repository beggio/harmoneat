import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/music/tuning_presets.dart';
import '../../../shared/music/tuning_selector.dart';
import '../application/finger_colors.dart';
import '../application/guitar_tabs_provider.dart';
import '../application/tab_data.dart';
import 'tab_staff_painter.dart';

enum _NoteDialogResult { save, clear }

class TabEditorScreen extends ConsumerWidget {
  const TabEditorScreen({super.key, required this.tabId});

  final String tabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tabAsync = ref.watch(guitarTabByIdProvider(tabId));

    return tabAsync.when(
      data: (tab) {
        if (tab == null) {
          // Deleted (e.g. from the tabs list) while this screen was open.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        final data = TabData.fromJsonString(tab.data);
        final title = (tab.title?.isNotEmpty ?? false)
            ? tab.title!
            : l10n.untitledTabTitle;

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: l10n.renameTab,
                onPressed: () => _rename(context, ref, tab.title ?? ''),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: l10n.addBeatLabel,
                onPressed: () => ref
                    .read(guitarTabsRepositoryProvider)
                    .updateData(tabId, data.withBeatAdded()),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.deleteTab,
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TuningSelector(
                  tuning: data.tuning,
                  onChanged: (preset) => ref
                      .read(guitarTabsRepositoryProvider)
                      .updateData(tabId, data.withTuning(preset.stringNames)),
                ),
              ),
              const _FingerLegend(),
              Expanded(
                child: _TabStaff(tabId: tabId, data: data),
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
        title: Text(l10n.renameTab),
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
      await ref.read(guitarTabsRepositoryProvider).rename(tabId, newTitle);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTab),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteTab),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(guitarTabsRepositoryProvider).delete(tabId);
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }
}

/// Small color key for the finger numbers used on fret numbers, so 1-5
/// doesn't require memorizing which color is which.
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

/// The scrollable staff grid: a `TabStaffPainter` for the visuals, with a
/// transparent `InkWell` overlay (same beat/string geometry) handling taps.
class _TabStaff extends ConsumerWidget {
  const _TabStaff({required this.tabId, required this.data});

  final String tabId;
  final TabData data;

  static const beatWidth = 48.0;
  static const rowHeight = 36.0;
  static const leftLabelWidth = 28.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final stringCount = data.tuning.length;
    final staffHeight = stringCount * rowHeight;
    final staffWidth = data.beats.length * beatWidth;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: leftLabelWidth,
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                children: List.generate(stringCount, (displayRow) {
                  final stringIndex = stringCount - 1 - displayRow;
                  return SizedBox(
                    height: rowHeight,
                    child: Center(
                      child: Text(
                        data.tuning[stringIndex],
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(data.beats.length, (beatIndex) {
                      return SizedBox(
                        width: beatWidth,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 14),
                          tooltip: l10n.removeBeatLabel,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                          onPressed: () => ref
                              .read(guitarTabsRepositoryProvider)
                              .updateData(
                                tabId,
                                data.withBeatRemovedAt(beatIndex),
                              ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(
                    width: staffWidth,
                    height: staffHeight,
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size(staffWidth, staffHeight),
                          painter: TabStaffPainter(
                            beats: data.beats,
                            stringCount: stringCount,
                            beatWidth: beatWidth,
                            rowHeight: rowHeight,
                            lineColor: colorScheme.outlineVariant,
                            backgroundColor: colorScheme.surface,
                          ),
                        ),
                        Row(
                          children: List.generate(data.beats.length, (
                            beatIndex,
                          ) {
                            return SizedBox(
                              width: beatWidth,
                              child: Column(
                                children: List.generate(stringCount, (
                                  displayRow,
                                ) {
                                  final stringIndex =
                                      stringCount - 1 - displayRow;
                                  return SizedBox(
                                    height: rowHeight,
                                    child: InkWell(
                                      onTap: () => _editNote(
                                        context,
                                        ref,
                                        beatIndex,
                                        stringIndex,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editNote(
    BuildContext context,
    WidgetRef ref,
    int beatIndex,
    int stringIndex,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final existing = data.beats[beatIndex].notes[stringIndex];
    final controller = TextEditingController(
      text: existing?.fret.toString() ?? '',
    );
    var selectedFinger = existing?.finger;
    // Off by default so entering a plain fret number stays a single-field,
    // single-tap flow; only turned on (and pre-selected) when the note
    // already has a finger assigned.
    var assignFinger = existing?.finger != null;
    final fingerLabels = {
      1: l10n.fingerIndexLabel,
      2: l10n.fingerMiddleLabel,
      3: l10n.fingerRingLabel,
      4: l10n.fingerPinkyLabel,
      5: l10n.fingerThumbLabel,
    };

    final result = await showDialog<_NoteDialogResult>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.fretDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.fretDialogTitle),
              ),
              const SizedBox(height: 16),
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
              onPressed: () => Navigator.pop(context, _NoteDialogResult.clear),
              child: Text(l10n.clearFretLabel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, _NoteDialogResult.save),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;

    TabNote? note;
    if (result == _NoteDialogResult.save) {
      final fret = int.tryParse(controller.text);
      if (fret == null) return;
      note = TabNote(fret: fret, finger: assignFinger ? selectedFinger : null);
    }

    await ref
        .read(guitarTabsRepositoryProvider)
        .updateData(
          tabId,
          data.withNoteSet(
            beatIndex: beatIndex,
            stringIndex: stringIndex,
            note: note,
          ),
        );
  }
}
