import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

const _maxCapoFret = 11;

/// Capo dropdown for a chord chart: `null` means no capo, otherwise the
/// fret it's placed on. One setting for the whole chart — a capo is a
/// physical position on the neck for the whole song, same as tuning is one
/// choice for the whole chart.
class CapoSelector extends StatelessWidget {
  const CapoSelector({
    super.key,
    required this.capoFret,
    required this.onChanged,
  });

  final int? capoFret;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${l10n.capoSelectorLabel}: '),
        DropdownButton<int?>(
          value: capoFret,
          items: [
            DropdownMenuItem(value: null, child: Text(l10n.capoNoneLabel)),
            for (var fret = 1; fret <= _maxCapoFret; fret++)
              DropdownMenuItem(
                value: fret,
                child: Text(l10n.capoFretOptionLabel(fret)),
              ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
