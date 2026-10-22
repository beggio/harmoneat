/// Shared guitar tuning presets, meant to back the same tuning dropdown on
/// every music form (tab today; chord chart and notation once those
/// editors exist). Tuning lives per content item (a tab, chart, or sheet),
/// not per note or part — a note can hold multiple parts/instruments, and
/// even multiple tabs for the same part can reasonably use different
/// tunings.
enum TuningPreset { standard, eFlat, dropD }

extension TuningPresetStrings on TuningPreset {
  /// Low-to-high string names, matching the index order `TabData.tuning`
  /// (and `Instrument.tuning`) use elsewhere.
  List<String> get stringNames => switch (this) {
    TuningPreset.standard => const ['E', 'A', 'D', 'G', 'B', 'E'],
    TuningPreset.eFlat => const ['E♭', 'A♭', 'D♭', 'G♭', 'B♭', 'E♭'],
    TuningPreset.dropD => const ['D', 'A', 'D', 'G', 'B', 'E'],
  };
}

/// Matches a stored tuning back to the preset it came from, so a dropdown
/// can show the right current selection. Returns `null` for a tuning that
/// doesn't match any known preset (e.g. hand-edited data) — the dropdown
/// should then show no selection rather than guessing wrong.
TuningPreset? matchTuningPreset(List<String> tuning) {
  for (final preset in TuningPreset.values) {
    if (_listEquals(preset.stringNames, tuning)) return preset;
  }
  return null;
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
