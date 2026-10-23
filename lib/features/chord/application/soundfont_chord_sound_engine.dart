import 'dart:async';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:soundfont_kit/soundfont_kit.dart';

import 'chord_instrument.dart';
import 'chord_sound_engine.dart';

const _soundfontAssetPath = 'assets/audio/MuseScore_General.sf2';

/// General MIDI program numbers (0-indexed) for the three selectable
/// chord-playback instruments. "Female voice" has no dedicated GM
/// instrument — Choir Aahs is the standard stand-in (confirmed
/// acceptable for v1).
const _gmProgramFor = {
  ChordInstrumentSound.guitar: 24, // Nylon String Guitar
  ChordInstrumentSound.guitarSteel: 25, // Steel String Guitar
  ChordInstrumentSound.guitarJazz: 26, // Jazz Guitar
  ChordInstrumentSound.guitarClean: 27, // Clean Guitar
  ChordInstrumentSound.guitarPalmMuted: 28, // Palm Muted Guitar
  ChordInstrumentSound.guitarOverdrive: 29, // Overdrive Guitar
  ChordInstrumentSound.guitarDistortion: 30, // Distortion Guitar
  ChordInstrumentSound.guitarHarmonics: 31, // Guitar Harmonics
  ChordInstrumentSound.piano: 0, // Acoustic Grand Piano
  ChordInstrumentSound.femaleVoice: 52, // Choir Aahs
};

/// A gentle strum rather than a dead-simultaneous block chord.
const _strumStagger = Duration(milliseconds: 20);

/// How long a played chord sounds before auto-stopping (decided with the
/// user — synthesized notes have no natural "end" the way a recorded
/// file does).
const _playbackDuration = Duration(milliseconds: 1800);

/// Every guitar-family GM program the user is A/B-testing for the
/// trailing-ring bug (see BACKLOG.md) — all of these fade out rather than
/// hard-cut, since the guitar samples themselves loop/sustain and an
/// abrupt stop is what produces the audible ring.
const _guitarVariants = {
  ChordInstrumentSound.guitar,
  ChordInstrumentSound.guitarSteel,
  ChordInstrumentSound.guitarJazz,
  ChordInstrumentSound.guitarClean,
  ChordInstrumentSound.guitarPalmMuted,
  ChordInstrumentSound.guitarOverdrive,
  ChordInstrumentSound.guitarDistortion,
  ChordInstrumentSound.guitarHarmonics,
};

/// Guitar's stop fades out instead of cutting off abruptly, for a clean
/// end instead of the ring an instant stop produces.
const _guitarFadeDuration = Duration(milliseconds: 1500);

/// Finds the bank-0 (standard GM melodic bank) preset matching
/// [programNumber], falling back to the first available preset if the
/// soundfont doesn't have one — rather than silently playing nothing.
/// Pulled out as its own pure function so the bank-vs-program bug this
/// fixed (see `loadIfNeeded`'s call site) stays covered by a unit test
/// without needing a real soundfont file.
Preset? selectPreset(List<Preset> presets, int programNumber) {
  for (final preset in presets) {
    if (preset.bank == 0 && preset.program == programNumber) {
      return preset;
    }
  }
  return presets.isNotEmpty ? presets.first : null;
}

/// Real chord playback via `soundfont_kit` (a pure-Dart SF2/SF3 reader
/// and player built on `flutter_soloud`). Loads the bundled General MIDI
/// soundfont once and keeps one `SoundFontPlayer` for the process
/// lifetime — reparsing the ~40MB soundfont per play would be wasteful.
class SoundfontChordSoundEngine implements ChordSoundEngine {
  SoundFontFile? _soundFont;
  SoundFontPlayer? _player;
  ChordInstrumentSound? _loadedInstrument;
  Preset? _preset;

  @override
  Future<void> loadIfNeeded(ChordInstrumentSound instrument) async {
    if (!SoLoud.instance.isInitialized) {
      await SoLoud.instance.init();
      SoLoud.instance.setMaxActiveVoiceCount(128);
    }

    if (_soundFont == null) {
      _soundFont = await SoundFontFile.fromAsset(_soundfontAssetPath);
      _player = _soundFont!.createPlayer();
    }

    if (_loadedInstrument == instrument) return;

    // Bank 0 is the standard GM melodic bank — matching by `program`
    // alone is wrong, since other banks reuse the same program numbers
    // for unrelated sounds (confirmed against the actual bundled
    // soundfont's preset table: program 0 on bank 128 is a *drum kit*
    // ("Standard"), not Acoustic Grand Piano, and bank 128 appeared
    // *before* the real bank-0 piano preset in file order — an
    // unfiltered first-match search silently played drums instead).
    _preset = selectPreset(_soundFont!.presets, _gmProgramFor[instrument]!);
    _loadedInstrument = instrument;
  }

  @override
  Future<void> playNotes(List<int> midiNotes) async {
    final preset = _preset;
    final player = _player;
    if (preset == null || player == null) return;

    for (final key in midiNotes) {
      unawaited(player.playPreset(preset, key: key, velocity: 100));
      if (key != midiNotes.last) {
        await Future.delayed(_strumStagger);
      }
    }

    // Awaited (not fire-and-forget) so a caller's `await playNotes(...)`
    // genuinely spans the whole sounding duration — e.g.
    // ChordPlaybackController uses this to know when to flip its
    // "currently playing" state back off.
    await Future.delayed(_playbackDuration);
    await stop();
  }

  @override
  Future<void> stop() async {
    final player = _player;
    if (player == null) return;
    if (_guitarVariants.contains(_loadedInstrument)) {
      await player.allNotesOff(releaseDuration: _guitarFadeDuration);
    } else {
      await player.stopMixerOutput();
    }
  }

  @override
  void dispose() {
    _player?.stopMixerOutput();
  }
}
