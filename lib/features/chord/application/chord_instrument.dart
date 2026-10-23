import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';

const _chordInstrumentKey = 'chordInstrumentSound';

/// The instrument sound used for chord playback — chord-domain, not a
/// general appearance setting, so it lives here rather than in
/// `lib/app/theme.dart` alongside color scheme/text scale/locale.
///
/// The `guitar*` variants are a temporary A/B set (see BACKLOG.md's
/// "guitar ringing" bug) — every bank-0 GM guitar program in the bundled
/// soundfont, added so the user can listen to each and remove the ones
/// that don't resolve the trailing-ring artifact.
enum ChordInstrumentSound {
  guitar, // Nylon String Guitar (GM program 24) — original default.
  guitarSteel,
  guitarJazz,
  guitarClean,
  guitarPalmMuted,
  guitarOverdrive,
  guitarDistortion,
  guitarHarmonics,
  piano,
  femaleVoice,
}

class ChordInstrumentNotifier extends Notifier<ChordInstrumentSound> {
  @override
  ChordInstrumentSound build() {
    _load();
    return ChordInstrumentSound.guitar;
  }

  Future<void> _load() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final stored = prefs.getString(_chordInstrumentKey);
    if (stored != null) {
      state = ChordInstrumentSound.values.firstWhere(
        (s) => s.name == stored,
        orElse: () => ChordInstrumentSound.guitar,
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
