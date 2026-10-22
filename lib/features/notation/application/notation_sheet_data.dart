import 'dart:convert';

/// Supported note/rest durations. Deliberately a small, "simple rhythms"
/// set (no sixteenths, no tuplets) — this is a hand-rolled renderer for
/// jotting down short melodic ideas, not a full engraving program.
enum NoteDuration { whole, half, quarter, eighth }

extension NoteDurationBeats on NoteDuration {
  /// Length in quarter-note beats.
  double get beats => switch (this) {
    NoteDuration.whole => 4.0,
    NoteDuration.half => 2.0,
    NoteDuration.quarter => 1.0,
    NoteDuration.eighth => 0.5,
  };
}

/// A written pitch: a natural letter (A-G), an accidental to display next
/// to the notehead (-1 flat, 0 natural/none, 1 sharp — this editor has no
/// key signature, so every accidental is written explicitly every time it
/// occurs, same as writing in C major/A minor with accidentals as needed),
/// and a scientific-pitch-notation octave (4 = the octave starting at
/// middle C).
class Pitch {
  const Pitch({
    required this.letter,
    this.accidental = 0,
    required this.octave,
  });

  final String letter;
  final int accidental;
  final int octave;

  static const _letterOffsets = {
    'C': 0,
    'D': 1,
    'E': 2,
    'F': 3,
    'G': 4,
    'A': 5,
    'B': 6,
  };

  /// A single integer diatonic index (letter+octave only — accidentals
  /// don't move a note's position on the staff, only its sound) usable to
  /// compute a staff position relative to any reference pitch.
  int get diatonicIndex => octave * 7 + _letterOffsets[letter]!;

  factory Pitch.fromJson(Map<String, dynamic> json) => Pitch(
    letter: json['letter'] as String,
    accidental: json['accidental'] as int,
    octave: json['octave'] as int,
  );

  Map<String, dynamic> toJson() => {
    'letter': letter,
    'accidental': accidental,
    'octave': octave,
  };
}

/// One note, chord-less single pitch, or rest, of a given duration.
class NotationEvent {
  const NotationEvent({
    required this.isRest,
    this.pitch,
    required this.duration,
    this.dotted = false,
  });

  final bool isRest;
  final Pitch? pitch;
  final NoteDuration duration;
  final bool dotted;

  double get beats => duration.beats * (dotted ? 1.5 : 1.0);

  factory NotationEvent.defaultRest() =>
      const NotationEvent(isRest: true, duration: NoteDuration.quarter);

  factory NotationEvent.fromJson(Map<String, dynamic> json) => NotationEvent(
    isRest: json['isRest'] as bool,
    pitch: json['pitch'] == null
        ? null
        : Pitch.fromJson(json['pitch'] as Map<String, dynamic>),
    duration: NoteDuration.values[json['duration'] as int],
    dotted: json['dotted'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'isRest': isRest,
    'pitch': pitch?.toJson(),
    'duration': duration.index,
    'dotted': dotted,
  };
}

/// The full content of one notation sheet: a time signature (used only to
/// place barlines — there's no strict per-measure validation; an event
/// that doesn't divide evenly just pushes the barline after it, rather
/// than being split across the barline) plus a flat, ordered sequence of
/// events. Measures aren't a stored concept — barline positions are
/// derived from cumulative beats at render time, which avoids a whole
/// class of edit-model complexity (splitting/merging measures when events
/// are added or removed).
class NotationSheetData {
  const NotationSheetData({
    required this.timeSigNumerator,
    required this.timeSigDenominator,
    required this.events,
  });

  final int timeSigNumerator;
  final int timeSigDenominator;
  final List<NotationEvent> events;

  double get measureBeats => timeSigNumerator * (4.0 / timeSigDenominator);

  factory NotationSheetData.blank() => NotationSheetData(
    timeSigNumerator: 4,
    timeSigDenominator: 4,
    events: [NotationEvent.defaultRest()],
  );

  factory NotationSheetData.fromJsonString(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return NotationSheetData(
      timeSigNumerator: map['timeSigNumerator'] as int,
      timeSigDenominator: map['timeSigDenominator'] as int,
      events: (map['events'] as List<dynamic>)
          .map((e) => NotationEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String toJsonString() => jsonEncode({
    'timeSigNumerator': timeSigNumerator,
    'timeSigDenominator': timeSigDenominator,
    'events': events.map((e) => e.toJson()).toList(),
  });

  NotationSheetData withTimeSignature(int numerator, int denominator) =>
      NotationSheetData(
        timeSigNumerator: numerator,
        timeSigDenominator: denominator,
        events: events,
      );

  NotationSheetData withEventAdded(NotationEvent event) => NotationSheetData(
    timeSigNumerator: timeSigNumerator,
    timeSigDenominator: timeSigDenominator,
    events: [...events, event],
  );

  NotationSheetData withEventRemovedAt(int index) {
    final updated = List<NotationEvent>.from(events)..removeAt(index);
    if (updated.isEmpty) updated.add(NotationEvent.defaultRest());
    return NotationSheetData(
      timeSigNumerator: timeSigNumerator,
      timeSigDenominator: timeSigDenominator,
      events: updated,
    );
  }

  NotationSheetData withEventReplacedAt(int index, NotationEvent event) {
    final updated = List<NotationEvent>.from(events);
    updated[index] = event;
    return NotationSheetData(
      timeSigNumerator: timeSigNumerator,
      timeSigDenominator: timeSigDenominator,
      events: updated,
    );
  }
}
