import '../application/notation_sheet_data.dart';
import 'notation_staff_painter.dart';

/// Lays events out left to right with width proportional to duration (a
/// quarter note is twice as wide as an eighth, etc. — spacing reflecting
/// duration is standard engraving practice, not just fixed-width columns),
/// clamped to a minimum so short notes/accidentals/dots don't collide.
/// Barlines are placed wherever cumulative beats exactly reaches a
/// multiple of [measureBeats]; an event that doesn't divide evenly simply
/// pushes the barline to land after it instead of splitting it (see
/// `NotationSheetData`'s class doc for why that's an acceptable
/// simplification here).
List<EventLayout> buildEventLayouts(
  List<NotationEvent> events, {
  required double measureBeats,
  required double pixelsPerBeat,
  required double minEventWidth,
  required double startX,
}) {
  final layouts = <EventLayout>[];
  var x = startX;
  var cumulativeBeats = 0.0;

  for (final event in events) {
    final width = (event.beats * pixelsPerBeat).clamp(
      minEventWidth,
      double.infinity,
    );
    cumulativeBeats += event.beats;
    final remainder = cumulativeBeats % measureBeats;
    final barlineAfter =
        remainder.abs() < 1e-9 || (measureBeats - remainder).abs() < 1e-9;

    layouts.add(
      EventLayout(event: event, x: x, width: width, barlineAfter: barlineAfter),
    );
    x += width;
  }

  return layouts;
}
