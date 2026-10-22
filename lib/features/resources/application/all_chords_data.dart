/// Every major and minor chord in standard (EADGBE) tuning, generated from
/// the two movable barre shapes plus the handful of standard open-position
/// chords — the same construction real "every chord" guitar references
/// use, verified against the open-shape-derivation rule (confirmed via
/// research): E-shape barre — barre fret on the low E string, G string one
/// fret above the barre, A and D strings two frets above (same fret, one
/// finger bars both); A-shape barre — barre fret on the A string (low E
/// muted), D/G/B strings two frets above the barre (one finger bars all
/// three). Minor versions lower the third: E-shape minor's "two above"
/// note (G string) drops to the barre fret itself; A-shape minor's B
/// string drops to one fret above the barre instead of two.
///
/// Open chords (C/D/E/G/A major, A/D/E minor) use their standard
/// fingerings instead, since that's how guitarists actually play them —
/// a barre shape would be technically equivalent but is never how these
/// are taught or referenced.
library;

import '../../chord/application/chord_chart_data.dart';

const _eShapeMajorStrings = [
  ChordString(fret: 1, finger: 1), // low E — barre
  ChordString(fret: 3, finger: 3), // A — ring (bars with D)
  ChordString(fret: 3, finger: 3), // D — ring (bars with A)
  ChordString(fret: 2, finger: 2), // G — middle
  ChordString(fret: 1, finger: 1), // B — barre
  ChordString(fret: 1, finger: 1), // high E — barre
];

const _eShapeMinorStrings = [
  ChordString(fret: 1, finger: 1), // low E — barre
  ChordString(fret: 3, finger: 3), // A — ring (bars with D)
  ChordString(fret: 3, finger: 3), // D — ring (bars with A)
  ChordString(fret: 1, finger: 1), // G — barre (lowered third)
  ChordString(fret: 1, finger: 1), // B — barre
  ChordString(fret: 1, finger: 1), // high E — barre
];

const _aShapeMajorStrings = [
  ChordString(fret: null), // low E — muted
  ChordString(fret: 1, finger: 1), // A — barre
  ChordString(fret: 3, finger: 3), // D — ring (bars with G, B)
  ChordString(fret: 3, finger: 3), // G — ring (bars with D, B)
  ChordString(fret: 3, finger: 3), // B — ring (bars with D, G)
  ChordString(fret: 1, finger: 1), // high E — barre
];

const _aShapeMinorStrings = [
  ChordString(fret: null), // low E — muted
  ChordString(fret: 1, finger: 1), // A — barre
  ChordString(fret: 3, finger: 3), // D — ring (bars with G)
  ChordString(fret: 3, finger: 3), // G — ring (bars with D)
  ChordString(fret: 2, finger: 2), // B — middle (lowered third)
  ChordString(fret: 1, finger: 1), // high E — barre
];

ChordDiagram _eShapeMajor(int baseFret) =>
    ChordDiagram(name: '', baseFret: baseFret, strings: _eShapeMajorStrings);

ChordDiagram _eShapeMinor(int baseFret) =>
    ChordDiagram(name: '', baseFret: baseFret, strings: _eShapeMinorStrings);

ChordDiagram _aShapeMajor(int baseFret) =>
    ChordDiagram(name: '', baseFret: baseFret, strings: _aShapeMajorStrings);

ChordDiagram _aShapeMinor(int baseFret) =>
    ChordDiagram(name: '', baseFret: baseFret, strings: _aShapeMinorStrings);

const _openC = ChordDiagram(
  name: '',
  strings: [
    ChordString(fret: null),
    ChordString(fret: 3, finger: 3),
    ChordString(fret: 2, finger: 2),
    ChordString(fret: 0),
    ChordString(fret: 1, finger: 1),
    ChordString(fret: 0),
  ],
);

const _openD = ChordDiagram(
  name: '',
  strings: [
    ChordString(fret: null),
    ChordString(fret: null),
    ChordString(fret: 0),
    ChordString(fret: 2, finger: 1),
    ChordString(fret: 3, finger: 3),
    ChordString(fret: 2, finger: 2),
  ],
);

const _openE = ChordDiagram(
  name: '',
  strings: [
    ChordString(fret: 0),
    ChordString(fret: 2, finger: 2),
    ChordString(fret: 2, finger: 3),
    ChordString(fret: 1, finger: 1),
    ChordString(fret: 0),
    ChordString(fret: 0),
  ],
);

const _openG = ChordDiagram(
  name: '',
  strings: [
    ChordString(fret: 3, finger: 2),
    ChordString(fret: 2, finger: 1),
    ChordString(fret: 0),
    ChordString(fret: 0),
    ChordString(fret: 0),
    ChordString(fret: 3, finger: 3),
  ],
);

const _openA = ChordDiagram(
  name: '',
  strings: [
    ChordString(fret: null),
    ChordString(fret: 0),
    ChordString(fret: 2, finger: 1),
    ChordString(fret: 2, finger: 2),
    ChordString(fret: 2, finger: 3),
    ChordString(fret: 0),
  ],
);

const _openAm = ChordDiagram(
  name: '',
  strings: [
    ChordString(fret: null),
    ChordString(fret: 0),
    ChordString(fret: 2, finger: 2),
    ChordString(fret: 2, finger: 3),
    ChordString(fret: 1, finger: 1),
    ChordString(fret: 0),
  ],
);

const _openDm = ChordDiagram(
  name: '',
  strings: [
    ChordString(fret: null),
    ChordString(fret: null),
    ChordString(fret: 0),
    ChordString(fret: 2, finger: 2),
    ChordString(fret: 3, finger: 3),
    ChordString(fret: 1, finger: 1),
  ],
);

const _openEm = ChordDiagram(
  name: '',
  strings: [
    ChordString(fret: 0),
    ChordString(fret: 2, finger: 2),
    ChordString(fret: 2, finger: 3),
    ChordString(fret: 0),
    ChordString(fret: 0),
    ChordString(fret: 0),
  ],
);

/// One root's major and minor chord, as shown side by side on the
/// resource screen.
class ChordRoot {
  const ChordRoot({
    required this.rootName,
    required this.major,
    required this.minor,
  });

  final String rootName;
  final ChordDiagram major;
  final ChordDiagram minor;
}

/// Chromatic order starting at C — the conventional order for an "every
/// chord" reference chart (as opposed to the Circle of Fifths resource,
/// which is deliberately ordered by fifths instead).
final allChords = <ChordRoot>[
  ChordRoot(rootName: 'C', major: _openC, minor: _aShapeMinor(3)),
  ChordRoot(rootName: 'C♯/D♭', major: _aShapeMajor(4), minor: _aShapeMinor(4)),
  ChordRoot(rootName: 'D', major: _openD, minor: _openDm),
  ChordRoot(rootName: 'D♯/E♭', major: _aShapeMajor(6), minor: _aShapeMinor(6)),
  ChordRoot(rootName: 'E', major: _openE, minor: _openEm),
  ChordRoot(rootName: 'F', major: _eShapeMajor(1), minor: _eShapeMinor(1)),
  ChordRoot(rootName: 'F♯/G♭', major: _eShapeMajor(2), minor: _eShapeMinor(2)),
  ChordRoot(rootName: 'G', major: _openG, minor: _eShapeMinor(3)),
  ChordRoot(rootName: 'G♯/A♭', major: _eShapeMajor(4), minor: _eShapeMinor(4)),
  ChordRoot(rootName: 'A', major: _openA, minor: _openAm),
  ChordRoot(rootName: 'A♯/B♭', major: _aShapeMajor(1), minor: _aShapeMinor(1)),
  ChordRoot(rootName: 'B', major: _aShapeMajor(2), minor: _aShapeMinor(2)),
];
