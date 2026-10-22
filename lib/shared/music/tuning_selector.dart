import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'tuning_presets.dart';

/// Tuning dropdown meant to appear on every music form that has strings —
/// tab today, chord chart and notation once those editors exist. Shows no
/// selection if the current tuning doesn't match a known preset (e.g.
/// hand-edited data) rather than guessing.
class TuningSelector extends StatelessWidget {
  const TuningSelector({
    super.key,
    required this.tuning,
    required this.onChanged,
  });

  final List<String> tuning;
  final ValueChanged<TuningPreset> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = {
      TuningPreset.standard: l10n.tuningStandardLabel,
      TuningPreset.eFlat: l10n.tuningEFlatLabel,
      TuningPreset.dropD: l10n.tuningDropDLabel,
    };
    final selected = matchTuningPreset(tuning);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${l10n.tuningFieldLabel}: '),
        DropdownButton<TuningPreset>(
          value: selected,
          hint: Text(tuning.join(' ')),
          items: TuningPreset.values
              .map(
                (preset) => DropdownMenuItem(
                  value: preset,
                  child: Text(labels[preset]!),
                ),
              )
              .toList(),
          onChanged: (preset) {
            if (preset != null) onChanged(preset);
          },
        ),
      ],
    );
  }
}
