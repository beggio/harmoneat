import 'chord_instrument.dart';

/// Abstract audio-playback boundary for chord sounds — keeps every other
/// chord-playback class (the Riverpod controller, the pitch module, UI)
/// decoupled from the concrete audio engine, so only this one interface
/// needs a real device/speakers to exercise.
abstract class ChordSoundEngine {
  /// Loads the soundfont and prepares the given instrument, if not
  /// already loaded — safe to call before every play.
  Future<void> loadIfNeeded(ChordInstrumentSound instrument);

  /// Plays every MIDI note in order (low to high), with a slight
  /// stagger between each — a gentle strum rather than a dead-simultaneous
  /// block chord.
  Future<void> playNotes(List<int> midiNotes);

  /// Stops whatever is currently sounding.
  Future<void> stop();

  void dispose();
}
