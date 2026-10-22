import 'dart:convert';

/// One string's state within a chord diagram: `fret == null` means muted
/// ("X" above the nut), `fret == 0` means open ("O" above the nut), and
/// `fret >= 1` means fretted at that row with an optional fretting-hand
/// finger (1 = index ... 5 = thumb, matching the tab editor's convention).
class ChordString {
  const ChordString({required this.fret, this.finger});

  final int? fret;
  final int? finger;

  bool get isMuted => fret == null;
  bool get isOpen => fret == 0;
  bool get isFretted => fret != null && fret! > 0;

  factory ChordString.fromJson(dynamic json) {
    if (json == null) return const ChordString(fret: null);
    if (json is int) return ChordString(fret: json);
    final map = json as Map<String, dynamic>;
    return ChordString(
      fret: map['fret'] as int?,
      finger: map['finger'] as int?,
    );
  }

  dynamic toJson() {
    if (fret == null) return null;
    if (finger == null) return fret;
    return {'fret': fret, 'finger': finger};
  }
}

/// A single named chord within a chart (e.g. "C", "G7"), one entry per
/// string ordered the same way as the chart's `tuning` (index 0 = lowest
/// string).
class ChordDiagram {
  const ChordDiagram({required this.name, required this.strings});

  final String name;
  final List<ChordString> strings;

  factory ChordDiagram.open(int stringCount) => ChordDiagram(
    name: '',
    strings: List<ChordString>.generate(
      stringCount,
      (_) => const ChordString(fret: 0),
    ),
  );

  factory ChordDiagram.fromJson(Map<String, dynamic> json) {
    return ChordDiagram(
      name: json['name'] as String,
      strings: (json['strings'] as List<dynamic>)
          .map(ChordString.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'strings': strings.map((s) => s.toJson()).toList(),
  };

  ChordDiagram withName(String newName) =>
      ChordDiagram(name: newName, strings: strings);

  ChordDiagram withStringSet({
    required int stringIndex,
    required ChordString value,
  }) {
    final updated = List<ChordString>.from(strings);
    updated[stringIndex] = value;
    return ChordDiagram(name: name, strings: updated);
  }
}

/// The full content of one chord chart: the tuning it was written for plus
/// an ordered sequence of named chord diagrams.
class ChordChartData {
  const ChordChartData({required this.tuning, required this.diagrams});

  final List<String> tuning;
  final List<ChordDiagram> diagrams;

  static const defaultTuning = ['E', 'A', 'D', 'G', 'B', 'E'];

  factory ChordChartData.blank({List<String> tuning = defaultTuning}) =>
      ChordChartData(
        tuning: tuning,
        diagrams: [ChordDiagram.open(tuning.length)],
      );

  factory ChordChartData.fromJsonString(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return ChordChartData(
      tuning: (map['tuning'] as List<dynamic>).cast<String>(),
      diagrams: (map['diagrams'] as List<dynamic>)
          .map((d) => ChordDiagram.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  String toJsonString() => jsonEncode({
    'tuning': tuning,
    'diagrams': diagrams.map((d) => d.toJson()).toList(),
  });

  /// Swaps the tuning's string names without touching existing diagrams —
  /// same rationale as `TabData.withTuning`.
  ChordChartData withTuning(List<String> newTuning) =>
      ChordChartData(tuning: newTuning, diagrams: diagrams);

  ChordChartData withDiagramAdded() {
    return ChordChartData(
      tuning: tuning,
      diagrams: [...diagrams, ChordDiagram.open(tuning.length)],
    );
  }

  ChordChartData withDiagramRemovedAt(int index) {
    final updated = List<ChordDiagram>.from(diagrams)..removeAt(index);
    if (updated.isEmpty) updated.add(ChordDiagram.open(tuning.length));
    return ChordChartData(tuning: tuning, diagrams: updated);
  }

  ChordChartData withDiagramNameSet(int index, String name) {
    final updated = List<ChordDiagram>.from(diagrams);
    updated[index] = updated[index].withName(name);
    return ChordChartData(tuning: tuning, diagrams: updated);
  }

  ChordChartData withStringSet({
    required int diagramIndex,
    required int stringIndex,
    required ChordString value,
  }) {
    final updated = List<ChordDiagram>.from(diagrams);
    updated[diagramIndex] = updated[diagramIndex].withStringSet(
      stringIndex: stringIndex,
      value: value,
    );
    return ChordChartData(tuning: tuning, diagrams: updated);
  }
}
