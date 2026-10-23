import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../application/chord_playback_controller.dart';

/// Play/stop button for one chord diagram's voicing — shared by the
/// Chord editor and the read-only "All Chords" reference screen so both
/// look and behave identically rather than duplicating the icon-swap
/// logic (same pattern as `attachments_tab.dart`'s play/pause button).
class ChordPlayButton extends ConsumerWidget {
  const ChordPlayButton({
    super.key,
    required this.playbackKey,
    required this.midiNotes,
  });

  /// A stable, unique identifier for this diagram (e.g. `'$chartId:$index'`).
  final String playbackKey;

  final List<int> midiNotes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isPlaying = ref.watch(chordPlaybackControllerProvider(playbackKey));
    final notifier = ref.read(
      chordPlaybackControllerProvider(playbackKey).notifier,
    );

    return IconButton(
      icon: Icon(
        isPlaying ? Icons.stop_circle : Icons.play_circle_outline,
        size: 20,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      tooltip: isPlaying ? l10n.stopChordLabel : l10n.playChordLabel,
      onPressed: midiNotes.isEmpty
          ? null
          : () => isPlaying ? notifier.stop() : notifier.play(midiNotes),
    );
  }
}
