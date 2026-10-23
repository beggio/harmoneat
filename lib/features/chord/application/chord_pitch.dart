/// Computes the real MIDI pitch of every sounding string in a fingered
/// chord shape — pure Dart, no audio engine involved, so this is fully
/// unit-testable without hardware. Deliberately not built on the
/// Notation feature's `Pitch`/diatonic-staff-position system
/// (`lib/features/notation/application/notation_sheet_data.dart`) — that
/// solves a different problem (where a note sits on a staff), not
/// chromatic MIDI-number math.
library;

import 'chord_chart_data.dart';

/// Standard tuning's note name per string, low to high — the reference
/// every other tuning's pitch is computed relative to.
const _standardTuning = ['E', 'A', 'D', 'G', 'B', 'E'];

/// Standard tuning's open-string MIDI notes, low to high: E2 A2 D3 G3 B3
/// E4 (middle C = 60).
const _standardOpenMidi = [40, 45, 50, 55, 59, 64];

const _semitoneFromC = {
  'C': 0,
  'D': 2,
  'E': 4,
  'F': 5,
  'G': 7,
  'A': 9,
  'B': 11,
};

const _noteNamesSharp = [
  'C',
  'C♯',
  'D',
  'D♯',
  'E',
  'F',
  'F♯',
  'G',
  'G♯',
  'A',
  'A♯',
  'B',
];

/// Parses a note name (e.g. `'E'`, `'E♭'`, `'C♯'`, or the ASCII `'Eb'`/
/// `'C#'` fallbacks) to a 0-11 pitch class. Octave-independent — none of
/// this app's tuning data stores octave.
int _semitoneClass(String noteName) {
  if (noteName.isEmpty) {
    throw ArgumentError('empty note name');
  }
  final letter = noteName[0].toUpperCase();
  final base = _semitoneFromC[letter];
  if (base == null) {
    throw ArgumentError('unknown note letter in "$noteName"');
  }
  var semitone = base;
  for (final accidental in noteName.substring(1).split('')) {
    if (accidental == '♯' || accidental == '#') semitone += 1;
    if (accidental == '♭' || accidental == 'b') semitone -= 1;
  }
  return ((semitone % 12) + 12) % 12;
}

/// Chromatic distance from [from] to [to], wrapped to the nearest
/// direction (so e.g. E→D is -2, not +10) — real tuning deviations from
/// standard are always small steps, never multi-octave.
int semitoneOffsetBetween(String from, String to) {
  final diff = (_semitoneClass(to) - _semitoneClass(from)) % 12;
  return diff > 6 ? diff - 12 : diff;
}

/// The open-string MIDI note for [stringIndex] in a given [tuning],
/// computed as standard tuning's reference note at that index plus the
/// chromatic offset between standard's note name there and the actual
/// tuning's. Only defined for 6-string tunings (every tuning preset in
/// this app is 6-string today).
int openStringMidi(List<String> tuning, int stringIndex) {
  if (stringIndex < 0 || stringIndex >= _standardOpenMidi.length) {
    throw RangeError(
      'stringIndex $stringIndex out of range for a 6-string reference',
    );
  }
  final offset = semitoneOffsetBetween(
    _standardTuning[stringIndex],
    tuning[stringIndex],
  );
  return _standardOpenMidi[stringIndex] + offset;
}

/// The real fret position from the nut for a diagram's string — `fret`
/// is stored as a grid row relative to `baseFret`, not always the
/// absolute fret (see `ChordDiagram`'s doc comment). Only call this for
/// a non-muted string.
///
/// An open string (`fret == 0`) is always absolute fret 0, regardless of
/// `baseFret` — it's drawn as an "O" above the nut, not as a grid dot, so
/// it was never subject to the baseFret-relative-row encoding to begin
/// with. Only `fret >= 1` (an actual grid row) gets the `baseFret`
/// translation.
int absoluteFretFromNut(ChordDiagram diagram, int stringIndex) {
  final fret = diagram.strings[stringIndex].fret!;
  if (fret == 0) return 0;
  return diagram.baseFret == 0 ? fret : diagram.baseFret + fret - 1;
}

/// MIDI notes (low to high) for every unmuted string of [diagram], given
/// an explicit [tuning] and [capoFret] — used by callers that don't have
/// a full `ChordChartData` (e.g. the Resources "All Chords" reference,
/// which only has raw `ChordDiagram`s in implied standard tuning).
/// Duplicates are expected (e.g. open C major: C, E, G, C, E). A capo
/// raises every sounding note by `capoFret` semitones — standard capo
/// physics, and the first real consumer of that field anywhere in the
/// app.
List<int> chordMidiNotesFor(
  List<String> tuning,
  int? capoFret,
  ChordDiagram diagram,
) {
  final notes = <int>[];
  for (var i = 0; i < diagram.strings.length; i++) {
    final string = diagram.strings[i];
    if (string.isMuted) continue;
    final midi =
        openStringMidi(tuning, i) +
        absoluteFretFromNut(diagram, i) +
        (capoFret ?? 0);
    notes.add(midi);
  }
  return notes;
}

/// Convenience overload for callers that do have a full `ChordChartData`
/// (the chord editor).
List<int> chordMidiNotes(ChordChartData data, ChordDiagram diagram) =>
    chordMidiNotesFor(data.tuning, data.capoFret, diagram);

/// Note name (no octave) for a MIDI number — for legible test
/// assertions and debugging, e.g. `['C','E','G','C','E']` rather than
/// raw MIDI numbers.
String midiToNoteName(int midi) {
  final pitchClass = ((midi % 12) + 12) % 12;
  return _noteNamesSharp[pitchClass];
}
