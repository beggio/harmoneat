import 'package:flutter_test/flutter_test.dart';
import 'package:harmoneat/features/notation/application/notation_sheet_data.dart';
import 'package:harmoneat/features/notation/application/staff_geometry.dart';

void main() {
  test('treble clef reference pitches map to the expected staff steps', () {
    // Lines, bottom to top: E4 G4 B4 D5 F5.
    expect(stepForPitch(const Pitch(letter: 'E', octave: 4)), 0);
    expect(stepForPitch(const Pitch(letter: 'G', octave: 4)), 2);
    expect(stepForPitch(const Pitch(letter: 'B', octave: 4)), 4);
    expect(stepForPitch(const Pitch(letter: 'D', octave: 5)), 6);
    expect(stepForPitch(const Pitch(letter: 'F', octave: 5)), 8);
    // Middle C, two ledger lines below the staff.
    expect(stepForPitch(const Pitch(letter: 'C', octave: 4)), -2);
  });

  test('accidentals do not shift a pitch\'s staff position', () {
    const sharp = Pitch(letter: 'F', accidental: 1, octave: 4);
    const natural = Pitch(letter: 'F', octave: 4);
    expect(stepForPitch(sharp), stepForPitch(natural));
  });

  test('stems point down above the middle line, up at or below it', () {
    expect(stemPointsDown(8), isTrue); // top line
    expect(stemPointsDown(5), isTrue); // just above middle
    expect(stemPointsDown(4), isFalse); // middle line itself
    expect(stemPointsDown(0), isFalse); // bottom line
    expect(stemPointsDown(-4), isFalse); // below the staff
  });

  test(
    'ledger lines appear only outside the 5-line staff, every other step',
    () {
      expect(ledgerLineStepsFor(4), isEmpty); // middle line, well within staff
      expect(ledgerLineStepsFor(8), isEmpty); // top line itself, no ledger yet
      expect(ledgerLineStepsFor(9), isEmpty); // space just above top line
      expect(ledgerLineStepsFor(10), [10]); // first ledger line above
      expect(ledgerLineStepsFor(14), [10, 12, 14]);
      expect(ledgerLineStepsFor(0), isEmpty); // bottom line itself
      expect(ledgerLineStepsFor(-1), isEmpty); // space just below bottom line
      expect(ledgerLineStepsFor(-2), [-2]); // middle C's ledger line
      expect(ledgerLineStepsFor(-6), [-2, -4, -6]);
    },
  );
}
