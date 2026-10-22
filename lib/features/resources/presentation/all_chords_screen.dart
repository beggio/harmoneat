import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../tab/application/finger_colors.dart';
import '../application/all_chords_data.dart';
import 'chord_diagram_preview.dart';

/// Every major and minor chord in standard tuning, for reference — as
/// opposed to the Chord editor, which builds a chord chart attached to a
/// note. Uses the same `ChordDiagramPainter` and finger-color legend as
/// that editor so the two look identical.
class AllChordsScreen extends StatelessWidget {
  const AllChordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.allChordsTitle)),
      body: Column(
        children: [
          const _FingerLegend(),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allChords.length,
              itemBuilder: (context, index) {
                final root = allChords[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        root.rootName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 32,
                        runSpacing: 16,
                        children: [
                          ChordDiagramPreview(
                            label: '${root.rootName} major',
                            diagram: root.major,
                          ),
                          ChordDiagramPreview(
                            label: '${root.rootName} minor',
                            diagram: root.minor,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Same color key as the chord editor's legend, so finger colors mean the
/// same thing in both places.
class _FingerLegend extends StatelessWidget {
  const _FingerLegend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = {
      1: l10n.fingerIndexLabel,
      2: l10n.fingerMiddleLabel,
      3: l10n.fingerRingLabel,
      4: l10n.fingerPinkyLabel,
      5: l10n.fingerThumbLabel,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 4,
        children: labels.entries.map((entry) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colorForFinger(entry.key),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text('${entry.key} ${entry.value}'),
            ],
          );
        }).toList(),
      ),
    );
  }
}
