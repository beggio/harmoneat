/// Treble-clef-only staff math (the original roadmap's plan explicitly
/// scoped the notation editor's fallback renderer to "single clef").
/// Positions are expressed as an integer diatonic "step" counted from the
/// bottom line: step 0 = E4 (the bottom line), each +1 is the next line or
/// space up. Even steps are lines, odd steps are spaces — step 4 (B4) is
/// the middle line, step 8 (F5) is the top line.
library;

import 'notation_sheet_data.dart';

const _bottomLineReferenceIndex =
    30; // Pitch(letter: 'E', octave: 4).diatonicIndex

int stepForPitch(Pitch pitch) =>
    pitch.diatonicIndex - _bottomLineReferenceIndex;

/// Stem-direction convention: above the middle line points down; at or
/// below it points up (including the middle line itself, the usual
/// default for instrumental — as opposed to vocal — staves).
bool stemPointsDown(int step) => step > 4;

/// Whether this step lands on a staff *line* position (as opposed to a
/// space) — lines are drawn solid for the 5 in-staff lines, or as short
/// ledger lines when a note's step falls on a line position outside the
/// staff (step < 0 or step > 8).
bool isLineStep(int step) => step % 2 == 0;

/// Every ledger-line step strictly between the staff and this note's step
/// (exclusive of the staff's own top/bottom lines), ascending outward.
List<int> ledgerLineStepsFor(int step) {
  if (step > 8) {
    return [for (var s = 10; s <= step; s += 2) s];
  }
  if (step < 0) {
    return [for (var s = -2; s >= step; s -= 2) s];
  }
  return const [];
}
