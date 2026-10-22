import 'package:flutter_test/flutter_test.dart';
import 'package:harmoneat/features/chord/application/chord_chart_data.dart';
import 'package:harmoneat/features/resources/application/all_chords_data.dart';

List<int?> _frets(ChordDiagram d) => d.strings.map((s) => s.fret).toList();

void main() {
  test('covers all 12 chromatic roots, each with a major and a minor', () {
    expect(allChords, hasLength(12));
    expect(allChords.map((r) => r.rootName).toSet(), hasLength(12));
    for (final root in allChords) {
      expect(root.major.strings, hasLength(6));
      expect(root.minor.strings, hasLength(6));
    }
  });

  test('open C major matches the standard X32010 fingering', () {
    final c = allChords.firstWhere((r) => r.rootName == 'C').major;
    expect(c.baseFret, 0);
    expect(_frets(c), [null, 3, 2, 0, 1, 0]);
  });

  test('F major is the standard E-shape barre at fret 1 (133211)', () {
    final f = allChords.firstWhere((r) => r.rootName == 'F').major;
    expect(f.baseFret, 1);
    expect(_frets(f), [1, 3, 3, 2, 1, 1]);
  });

  test('B minor is the standard A-shape barre at fret 2 (X24432)', () {
    final bm = allChords.firstWhere((r) => r.rootName == 'B').minor;
    expect(bm.baseFret, 2);
    expect(_frets(bm), [null, 1, 3, 3, 2, 1]); // rows relative to baseFret 2
  });

  test('moving a barre shape up one fret raises every real fret by one', () {
    // F#/Gb major is F major's identical E-shape, one fret higher: every
    // string's real-world fret (baseFret + row - 1) should be exactly 1
    // more than F major's.
    final f = allChords.firstWhere((r) => r.rootName == 'F').major;
    final fSharp = allChords.firstWhere((r) => r.rootName == 'F♯/G♭').major;
    for (var i = 0; i < 6; i++) {
      final fFret = f.strings[i].fret;
      final fSharpFret = fSharp.strings[i].fret;
      if (fFret == null) {
        expect(fSharpFret, isNull);
        continue;
      }
      final fAbsolute = f.baseFret + fFret - 1;
      final fSharpAbsolute = fSharp.baseFret + fSharpFret! - 1;
      expect(fSharpAbsolute, fAbsolute + 1);
    }
  });

  test('minor shapes differ from their major only by the lowered third', () {
    final f = allChords.firstWhere((r) => r.rootName == 'F');
    // Same barre fret, same shuffled strings except the third (G string)
    // drops from the major's "one above the barre" to the barre itself.
    expect(f.minor.baseFret, f.major.baseFret);
    expect(f.minor.strings[3].fret, 1); // G string: barre fret, not +1
    expect(f.major.strings[3].fret, 2); // G string: one above the barre
  });
}
