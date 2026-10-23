import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chord_instrument.dart';
import 'chord_sound_engine.dart';
import 'soundfont_chord_sound_engine.dart';

/// One shared engine instance for the process lifetime — the soundfont
/// is expensive to load, so every chord-playback controller reuses the
/// same engine rather than each loading its own copy.
final chordSoundEngineProvider = Provider<ChordSoundEngine>((ref) {
  final engine = SoundfontChordSoundEngine();
  ref.onDispose(engine.dispose);
  return engine;
});

/// Whether a given chord diagram (identified by [playbackKey]) is
/// currently sounding. Riverpod 3 passes a family's argument to the
/// create callback, not to `build()` — same pattern as
/// `AudioPlaybackController`.
class ChordPlaybackController extends Notifier<bool> {
  ChordPlaybackController(this.playbackKey);

  final String playbackKey;

  @override
  bool build() => false;

  Future<void> play(List<int> midiNotes) async {
    if (midiNotes.isEmpty) return;
    final instrument = ref.read(chordInstrumentProvider);
    final engine = ref.read(chordSoundEngineProvider);
    state = true;
    await engine.loadIfNeeded(instrument);
    await engine.playNotes(midiNotes);
    state = false;
  }

  Future<void> stop() async {
    await ref.read(chordSoundEngineProvider).stop();
    state = false;
  }
}

final chordPlaybackControllerProvider =
    NotifierProvider.family<ChordPlaybackController, bool, String>(
      ChordPlaybackController.new,
    );
