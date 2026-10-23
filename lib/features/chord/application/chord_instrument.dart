import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';

const _chordInstrumentKey = 'chordInstrumentSound';

/// The instrument sound used for chord playback — chord-domain, not a
/// general appearance setting, so it lives here rather than in
/// `lib/app/theme.dart` alongside color scheme/text scale/locale.
///
/// Only the guitar variants confirmed (by ear, 2026-10-23) to end cleanly
/// are offered — see BACKLOG.md's "guitar ringing" bug for the other GM
/// guitar programs (Nylon, Jazz, Clean, Palm Muted, Harmonics), which still
/// rang even with the fade-out fix and were removed pending further
/// remediation, and for the "offer every guitar option" feature this is
/// gated behind. `choir` has no real female-voice soundfont yet — it's the
/// GM "Choir Aahs" stand-in — also tracked as a backlog feature.
enum ChordInstrumentSound {
  guitarSteel, // Steel String Guitar (GM program 25) — current default.
  guitarOverdrive,
  guitarDistortion,
  piano,
  choir,
}

class ChordInstrumentNotifier extends Notifier<ChordInstrumentSound> {
  @override
  ChordInstrumentSound build() {
    _load();
    return ChordInstrumentSound.guitarSteel;
  }

  Future<void> _load() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final stored = prefs.getString(_chordInstrumentKey);
    if (stored != null) {
      state = ChordInstrumentSound.values.firstWhere(
        (s) => s.name == stored,
        orElse: () => ChordInstrumentSound.guitarSteel,
      );
    }
  }

  Future<void> setInstrument(ChordInstrumentSound sound) async {
    state = sound;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_chordInstrumentKey, sound.name);
  }
}

final chordInstrumentProvider =
    NotifierProvider<ChordInstrumentNotifier, ChordInstrumentSound>(
      ChordInstrumentNotifier.new,
    );
