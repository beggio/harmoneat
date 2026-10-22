import 'dart:convert';

/// A single fretted note within a beat, with an optional fretting-hand
/// finger (1 = index, 2 = middle, 3 = ring, 4 = pinky, 5 = thumb) so the
/// editor/renderer can color-code it.
class TabNote {
  const TabNote({required this.fret, this.finger});

  final int fret;
  final int? finger;

  /// Accepts either a bare fret number (older/simple form, finger
  /// unspecified) or `{"fret": n, "finger": n}`, so a tab written before
  /// finger annotations existed still loads.
  factory TabNote.fromJson(dynamic json) {
    if (json is int) return TabNote(fret: json);
    final map = json as Map<String, dynamic>;
    return TabNote(fret: map['fret'] as int, finger: map['finger'] as int?);
  }

  dynamic toJson() {
    if (finger == null) return fret;
    return {'fret': fret, 'finger': finger};
  }

  TabNote withFinger(int? finger) => TabNote(fret: fret, finger: finger);
}

/// One vertical slice of a tab — the note (if any) played on each string at
/// that point, read left to right. More than one non-null note in the same
/// beat = a chord.
class TabBeat {
  const TabBeat({required this.notes});

  /// Index 0 = lowest string (matches the low-to-high order of
  /// `Instrument.tuning`, e.g. `EADGBE`'s index 0 is the low E). `null`
  /// means that string isn't played in this beat.
  final List<TabNote?> notes;

  factory TabBeat.empty(int stringCount) =>
      TabBeat(notes: List<TabNote?>.filled(stringCount, null));

  factory TabBeat.fromJson(List<dynamic> json) {
    return TabBeat(
      notes: json.map((n) => n == null ? null : TabNote.fromJson(n)).toList(),
    );
  }

  List<dynamic> toJson() => notes.map((n) => n?.toJson()).toList();

  TabBeat withNote({required int stringIndex, required TabNote? note}) {
    final updated = List<TabNote?>.from(notes);
    updated[stringIndex] = note;
    return TabBeat(notes: updated);
  }
}

/// The full content of one guitar tab: the tuning it was written for (so
/// rendering doesn't need a live lookup of the instrument row) plus an
/// ordered list of beats.
class TabData {
  const TabData({required this.tuning, required this.beats});

  final List<String> tuning;
  final List<TabBeat> beats;

  static const defaultTuning = ['E', 'A', 'D', 'G', 'B', 'E'];

  factory TabData.blank({List<String> tuning = defaultTuning}) =>
      TabData(tuning: tuning, beats: [TabBeat.empty(tuning.length)]);

  factory TabData.fromJsonString(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return TabData(
      tuning: (map['tuning'] as List<dynamic>).cast<String>(),
      beats: (map['beats'] as List<dynamic>)
          .map((b) => TabBeat.fromJson(b as List<dynamic>))
          .toList(),
    );
  }

  String toJsonString() => jsonEncode({
    'tuning': tuning,
    'beats': beats.map((b) => b.toJson()).toList(),
  });

  /// Swaps the tuning's string names without touching existing beats —
  /// fret numbers stay where they are (no re-transposition), just the
  /// string labels change. All current presets are 6-string, same as the
  /// beats they're applied to.
  TabData withTuning(List<String> newTuning) =>
      TabData(tuning: newTuning, beats: beats);

  TabData withBeatAdded() {
    return TabData(
      tuning: tuning,
      beats: [...beats, TabBeat.empty(tuning.length)],
    );
  }

  TabData withBeatRemovedAt(int index) {
    final updated = List<TabBeat>.from(beats)..removeAt(index);
    if (updated.isEmpty) updated.add(TabBeat.empty(tuning.length));
    return TabData(tuning: tuning, beats: updated);
  }

  TabData withNoteSet({
    required int beatIndex,
    required int stringIndex,
    required TabNote? note,
  }) {
    final updated = List<TabBeat>.from(beats);
    updated[beatIndex] = updated[beatIndex].withNote(
      stringIndex: stringIndex,
      note: note,
    );
    return TabData(tuning: tuning, beats: updated);
  }
}
