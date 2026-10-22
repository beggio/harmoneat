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
  const ChordDiagram({
    required this.name,
    required this.strings,
    this.baseFret = 0,
  });

  final String name;
  final List<ChordString> strings;

  /// The absolute fret number row 1 of the grid represents. `0` is the
  /// default — the diagram starts at the nut (fret 0), drawn thick, the
  /// standard open-position look. Anything higher (1+) is a diagram for a
  /// barre/shape played further up the neck, drawn without the nut
  /// emphasis and with a "Nfr" label instead.
  final int baseFret;

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
      baseFret: json['baseFret'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'strings': strings.map((s) => s.toJson()).toList(),
    'baseFret': baseFret,
  };

  ChordDiagram withName(String newName) =>
      ChordDiagram(name: newName, strings: strings, baseFret: baseFret);

  ChordDiagram withBaseFret(int newBaseFret) =>
      ChordDiagram(name: name, strings: strings, baseFret: newBaseFret);

  ChordDiagram withStringSet({
    required int stringIndex,
    required ChordString value,
  }) {
    final updated = List<ChordString>.from(strings);
    updated[stringIndex] = value;
    return ChordDiagram(name: name, strings: updated, baseFret: baseFret);
  }
}

/// The full content of one chord chart: the tuning it was written for plus
/// an ordered sequence of named chord diagrams.
class ChordChartData {
  const ChordChartData({
    required this.tuning,
    required this.diagrams,
    this.capoFret,
  });

  final List<String> tuning;
  final List<ChordDiagram> diagrams;

  /// The fret a capo is placed on for this whole chart, or `null` for no
  /// capo. One setting per chart (not per diagram) — a capo is a physical
  /// position on the neck for the whole song, same as tuning is one choice
  /// for the whole chart.
  final int? capoFret;

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
      capoFret: map['capoFret'] as int?,
    );
  }

  String toJsonString() => jsonEncode({
    'tuning': tuning,
    'diagrams': diagrams.map((d) => d.toJson()).toList(),
    'capoFret': capoFret,
  });

  /// Swaps the tuning's string names without touching existing diagrams —
  /// same rationale as `TabData.withTuning`.
  ChordChartData withTuning(List<String> newTuning) =>
      ChordChartData(tuning: newTuning, diagrams: diagrams, capoFret: capoFret);

  ChordChartData withCapoFret(int? newCapoFret) =>
      ChordChartData(tuning: tuning, diagrams: diagrams, capoFret: newCapoFret);

  ChordChartData withDiagramAdded() {
    return ChordChartData(
      tuning: tuning,
      diagrams: [...diagrams, ChordDiagram.open(tuning.length)],
      capoFret: capoFret,
    );
  }

  ChordChartData withDiagramRemovedAt(int index) {
    final updated = List<ChordDiagram>.from(diagrams)..removeAt(index);
    if (updated.isEmpty) updated.add(ChordDiagram.open(tuning.length));
    return ChordChartData(
      tuning: tuning,
      diagrams: updated,
      capoFret: capoFret,
    );
  }

  ChordChartData withDiagramNameSet(int index, String name) {
    final updated = List<ChordDiagram>.from(diagrams);
    updated[index] = updated[index].withName(name);
    return ChordChartData(
      tuning: tuning,
      diagrams: updated,
      capoFret: capoFret,
    );
  }

  ChordChartData withDiagramBaseFretSet(int index, int baseFret) {
    final updated = List<ChordDiagram>.from(diagrams);
    updated[index] = updated[index].withBaseFret(baseFret);
    return ChordChartData(
      tuning: tuning,
      diagrams: updated,
      capoFret: capoFret,
    );
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
    return ChordChartData(
      tuning: tuning,
      diagrams: updated,
      capoFret: capoFret,
    );
  }
}
