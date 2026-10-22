import 'package:flutter_test/flutter_test.dart';
import 'package:harmoneat/features/resources/application/circle_of_fifths_data.dart';

void main() {
  test('has exactly 12 keys, clockwise from C with no accidentals', () {
    expect(circleOfFifthsKeys, hasLength(12));
    expect(circleOfFifthsKeys.first.majorName, 'C');
    expect(circleOfFifthsKeys.first.sharps, 0);
    expect(circleOfFifthsKeys.first.flats, 0);
  });

  test('sharp keys accumulate in the F C G D A E B order', () {
    expect(
      circleOfFifthsKeys.firstWhere((k) => k.majorName == 'E').accidentalNotes,
      ['F♯', 'C♯', 'G♯', 'D♯'],
    );
    expect(
      circleOfFifthsKeys.firstWhere((k) => k.majorName == 'B').accidentalNotes,
      ['F♯', 'C♯', 'G♯', 'D♯', 'A♯'],
    );
  });

  test('flat keys accumulate in the B E A D G C F order', () {
    expect(
      circleOfFifthsKeys.firstWhere((k) => k.majorName == 'A♭').accidentalNotes,
      ['B♭', 'E♭', 'A♭', 'D♭'],
    );
    expect(
      circleOfFifthsKeys.firstWhere((k) => k.majorName == 'D♭').accidentalNotes,
      ['B♭', 'E♭', 'A♭', 'D♭', 'G♭'],
    );
  });

  test('relative minors match the well-known major/minor pairs', () {
    final byMajor = {
      for (final k in circleOfFifthsKeys) k.majorName: k.minorName,
    };
    expect(byMajor['C'], 'a');
    expect(byMajor['G'], 'e');
    expect(byMajor['D'], 'b');
    expect(byMajor['A'], 'f♯');
    expect(byMajor['F'], 'd');
    expect(byMajor['B♭'], 'g');
  });
}
