import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/database/database.dart';
import '../../../data/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../audio/application/audio_recorder_controller.dart';
import 'coming_soon_screen.dart';

/// Persistent action bar for a note's detail screen — sits below the
/// TabBar so Record/Import (and later chord-chart/tab/notation actions)
/// stay reachable no matter which tab is active, instead of living inside
/// one tab's content.
class NoteDetailToolbar extends ConsumerWidget {
  const NoteDetailToolbar({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recorderState = ref.watch(audioRecorderControllerProvider);
    final isRecording = recorderState.status == RecorderStatus.recording;

    ref.listen(audioRecorderControllerProvider, (previous, next) {
      final message = next.errorMessage;
      if (message != null && message != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    });

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilledButton.icon(
                  onPressed: isRecording
                      ? () => _stopRecording(ref)
                      : () => _startRecording(context, ref),
                  icon: Icon(isRecording ? Icons.stop : Icons.mic),
                  label: Text(
                    isRecording
                        ? '${l10n.stopButtonLabel} (${formatRecordingDuration(recorderState.elapsed)})'
                        : l10n.recordButtonLabel,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _importAudio(context, ref),
                  icon: const Icon(Icons.file_upload_outlined),
                  label: Text(l10n.importAudioLabel),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      _openComingSoon(context, l10n.tabButtonLabel),
                  icon: const Icon(Icons.piano_outlined),
                  label: Text(l10n.tabButtonLabel),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      _openComingSoon(context, l10n.chordButtonLabel),
                  icon: const Icon(Icons.grid_on_outlined),
                  label: Text(l10n.chordButtonLabel),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      _openComingSoon(context, l10n.notationButtonLabel),
                  icon: const Icon(Icons.music_note_outlined),
                  label: Text(l10n.notationButtonLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openComingSoon(BuildContext context, String featureName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ComingSoonScreen(featureName: featureName),
      ),
    );
  }

  Future<void> _startRecording(BuildContext context, WidgetRef ref) async {
    await _maybeShowCloudStorageNotice(context, ref);
    ref.read(audioRecorderControllerProvider.notifier).start();
  }

  Future<void> _maybeShowCloudStorageNotice(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (ref.read(cloudStorageAcknowledgedProvider)) return;
    final provider = await ref
        .read(appDirectoriesProvider)
        .detectCloudSyncProvider();
    if (provider == null) return;
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context)!;
    var dontShowAgain = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(l10n.cloudStorageNoticeTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.cloudStorageNoticeMessage(provider)),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: dontShowAgain,
                onChanged: (value) =>
                    setState(() => dontShowAgain = value ?? true),
                title: Text(l10n.cloudStorageNoticeDontShowAgain),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (dontShowAgain) {
                  ref
                      .read(cloudStorageAcknowledgedProvider.notifier)
                      .acknowledge();
                }
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.cloudStorageNoticeAcknowledge),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _stopRecording(WidgetRef ref) async {
    final path = await ref
        .read(audioRecorderControllerProvider.notifier)
        .stop();
    if (path != null) {
      await ref
          .read(attachmentsRepositoryProvider)
          .registerFile(
            noteId: noteId,
            absolutePath: path,
            source: AttachmentSource.recorded,
          );
    }
    ref.read(audioRecorderControllerProvider.notifier).reset();
  }

  Future<void> _importAudio(BuildContext context, WidgetRef ref) async {
    await _maybeShowCloudStorageNotice(context, ref);
    final picked = await FilePicker.pickFile(type: FileType.audio);
    final path = picked?.path;
    if (path != null) {
      await ref
          .read(attachmentsRepositoryProvider)
          .importFile(noteId: noteId, sourceFile: File(path));
    }
  }
}
