import 'package:flutter_test/flutter_test.dart';
import 'package:harmoneat/features/notation/application/notation_sheet_data.dart';
import 'package:harmoneat/features/notation/presentation/event_layout_builder.dart';

const _quarter = NotationEvent(isRest: true, duration: NoteDuration.quarter);
const _eighth = NotationEvent(isRest: true, duration: NoteDuration.eighth);
const _half = NotationEvent(isRest: true, duration: NoteDuration.half);

void main() {
  test('a barline lands after every 4 quarter-beats in 4/4', () {
    final layouts = buildEventLayouts(
      [_quarter, _quarter, _quarter, _quarter, _quarter],
      measureBeats: 4,
      pixelsPerBeat: 32,
      minEventWidth: 1,
      startX: 0,
    );
    expect(layouts.map((l) => l.barlineAfter).toList(), [
      false,
      false,
      false,
      true,
      false,
    ]);
  });

  test('widths are proportional to duration, not fixed', () {
    final layouts = buildEventLayouts(
      [_eighth, _quarter, _half],
      measureBeats: 4,
      pixelsPerBeat: 32,
      minEventWidth: 1,
      startX: 0,
    );
    expect(layouts[0].width, 16); // 0.5 beats
    expect(layouts[1].width, 32); // 1 beat
    expect(layouts[2].width, 64); // 2 beats
  });

  test('an event that overruns a measure just pushes the barline after it', () {
    // 3 quarters (3 beats) then a half note (2 beats) in 4/4: cumulative
    // after the half is 5, which never exactly hits a multiple of 4, so
    // no barline is forced mid-note. It isn't split across the barline —
    // the barline simply doesn't land until cumulative beats reaches the
    // next exact multiple (8, after two more quarters).
    final layouts = buildEventLayouts(
      [_quarter, _quarter, _quarter, _half, _quarter, _quarter, _quarter],
      measureBeats: 4,
      pixelsPerBeat: 32,
      minEventWidth: 1,
      startX: 0,
    );
    expect(layouts.map((l) => l.barlineAfter).toList(), [
      false,
      false,
      false,
      false,
      false,
      false,
      true,
    ]);
  });

  test('event x positions accumulate left to right from startX', () {
    final layouts = buildEventLayouts(
      [_quarter, _quarter],
      measureBeats: 4,
      pixelsPerBeat: 32,
      minEventWidth: 1,
      startX: 48,
    );
    expect(layouts[0].x, 48);
    expect(layouts[1].x, 80);
  });
}
