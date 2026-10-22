/// The circle of fifths' 12 key signatures, and the shared order in which
/// sharps/flats accumulate as you move around it — verified against
/// standard music-theory references (e.g. Open Music Theory's key
/// signatures chapter): sharps are added clockwise from C in the order
/// F C G D A E B (the mnemonic "Father Charles Goes Down And Ends
/// Battle"), flats are added counterclockwise in the reverse order
/// B E A D G C F.
const sharpOrder = ['F', 'C', 'G', 'D', 'A', 'E', 'B'];
const flatOrder = ['B', 'E', 'A', 'D', 'G', 'C', 'F'];

/// One wedge of the circle: a major key (outer ring) and its relative
/// minor (inner ring, same key signature — a relative minor sits a minor
/// third below its major, equivalently the major scale's 6th degree).
class CircleKey {
  const CircleKey({
    required this.majorName,
    required this.minorName,
    this.sharps = 0,
    this.flats = 0,
  });

  final String majorName;
  final String minorName;
  final int sharps;
  final int flats;

  /// The specific accidental note names for this key, in the standard
  /// order, e.g. 2 sharps -> ['F♯', 'C♯']. The F♯/G♭ wedge (6 of each) is
  /// shown using its sharp spelling here, since [sharps] is checked first.
  List<String> get accidentalNotes => sharps > 0
      ? sharpOrder.take(sharps).map((n) => '$n♯').toList()
      : flatOrder.take(flats).map((n) => '$n♭').toList();
}

/// Clockwise from C at index 0 — each step clockwise is up a perfect
/// fifth (one more sharp / one fewer flat); each step counterclockwise is
/// down a perfect fifth (one more flat / one fewer sharp).
const circleOfFifthsKeys = <CircleKey>[
  CircleKey(majorName: 'C', minorName: 'a'),
  CircleKey(majorName: 'G', minorName: 'e', sharps: 1),
  CircleKey(majorName: 'D', minorName: 'b', sharps: 2),
  CircleKey(majorName: 'A', minorName: 'f♯', sharps: 3),
  CircleKey(majorName: 'E', minorName: 'c♯', sharps: 4),
  CircleKey(majorName: 'B', minorName: 'g♯', sharps: 5),
  CircleKey(majorName: 'F♯/G♭', minorName: 'd♯/e♭', sharps: 6, flats: 6),
  CircleKey(majorName: 'D♭', minorName: 'b♭', flats: 5),
  CircleKey(majorName: 'A♭', minorName: 'f', flats: 4),
  CircleKey(majorName: 'E♭', minorName: 'c', flats: 3),
  CircleKey(majorName: 'B♭', minorName: 'g', flats: 2),
  CircleKey(majorName: 'F', minorName: 'd', flats: 1),
];
