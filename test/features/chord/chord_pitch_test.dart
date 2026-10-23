import 'package:flutter_test/flutter_test.dart';
import 'package:harmoneat/features/chord/application/chord_chart_data.dart';
import 'package:harmoneat/features/chord/application/chord_pitch.dart';
import 'package:harmoneat/features/resources/application/all_chords_data.dart';
import 'package:harmoneat/shared/music/tuning_presets.dart';

List<String> _names(List<int> midiNotes) =>
    midiNotes.map(midiToNoteName).toList();

void main() {
  test(
    'open C major plays exactly C, E, G, C, E — the stated acceptance example',
    () {
      final c = allChords.firstWhere((r) => r.rootName == 'C').major;
      final notes = chordMidiNotesFor(
        TuningPreset.standard.stringNames,
        null,
        c,
      );
      expect(_names(notes), ['C', 'E', 'G', 'C', 'E']);
    },
  );

  test('open G major plays G, B, D, G, B, G', () {
    final g = allChords.firstWhere((r) => r.rootName == 'G').major;
    final notes = chordMidiNotesFor(TuningPreset.standard.stringNames, null, g);
    expect(_names(notes), ['G', 'B', 'D', 'G', 'B', 'G']);
  });

  test('F major (E-shape barre, baseFret 1) plays F, C, F, A, C, F', () {
    final f = allChords.firstWhere((r) => r.rootName == 'F').major;
    expect(f.baseFret, 1);
    final notes = chordMidiNotesFor(TuningPreset.standard.stringNames, null, f);
    expect(_names(notes), ['F', 'C', 'F', 'A', 'C', 'F']);
  });

  test('B minor (A-shape barre, baseFret 2) plays B, F♯, B, D, F♯', () {
    final bm = allChords.firstWhere((r) => r.rootName == 'B').minor;
    expect(bm.baseFret, 2);
    final notes = chordMidiNotesFor(
      TuningPreset.standard.stringNames,
      null,
      bm,
    );
    expect(_names(notes), ['B', 'F♯', 'B', 'D', 'F♯']);
  });

  test('Drop D lowers only the low string by two semitones', () {
    expect(
      openStringMidi(TuningPreset.dropD.stringNames, 0),
      openStringMidi(TuningPreset.standard.stringNames, 0) - 2,
    );
    // The rest of the strings are unaffected.
    for (var i = 1; i < 6; i++) {
      expect(
        openStringMidi(TuningPreset.dropD.stringNames, i),
        openStringMidi(TuningPreset.standard.stringNames, i),
      );
    }
  });

  test('a capo raises every sounding note by exactly capoFret semitones', () {
    final c = allChords.firstWhere((r) => r.rootName == 'C').major;
    final tuning = TuningPreset.standard.stringNames;
    final noCapo = chordMidiNotesFor(tuning, null, c);
    final withCapo = chordMidiNotesFor(tuning, 2, c);
    expect(withCapo, noCapo.map((n) => n + 2).toList());
    expect(_names(withCapo), ['D', 'F♯', 'A', 'D', 'F♯']);
  });

  test('muted strings are skipped, not zeroed', () {
    final c = allChords.firstWhere((r) => r.rootName == 'C').major;
    expect(c.strings.first.isMuted, isTrue); // low E muted
    final notes = chordMidiNotesFor(TuningPreset.standard.stringNames, null, c);
    expect(notes, hasLength(5)); // 6 strings, 1 muted
  });

  test('unicode accidentals in a tuning name parse without error', () {
    final tuning = TuningPreset.eFlat.stringNames;
    expect(() => openStringMidi(tuning, 0), returnsNormally);
    expect(
      openStringMidi(tuning, 0),
      openStringMidi(TuningPreset.standard.stringNames, 0) - 1,
    );
  });

  test(
    'an open string inside a baseFret > 0 diagram is still absolute fret 0',
    () {
      final diagram = ChordDiagram(
        name: '',
        baseFret: 3,
        strings: const [
          ChordString(fret: 0), // open, despite baseFret 3
          ChordString(fret: null),
          ChordString(fret: null),
          ChordString(fret: null),
          ChordString(fret: null),
          ChordString(fret: null),
        ],
      );
      expect(absoluteFretFromNut(diagram, 0), 0);
      final notes = chordMidiNotesFor(
        TuningPreset.standard.stringNames,
        null,
        diagram,
      );
      expect(notes, [openStringMidi(TuningPreset.standard.stringNames, 0)]);
    },
  );
}
