import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../chord/application/chord_chart_data.dart';
import '../../chord/presentation/chord_diagram_painter.dart';

/// A read-only chord diagram, reusing the exact same `ChordDiagramPainter`
/// (and matching geometry/markers) as the chord chart editor, so this
/// reference resource looks identical to the editor's own diagrams rather
/// than a reimplementation that could visually drift from it.
class ChordDiagramPreview extends StatelessWidget {
  const ChordDiagramPreview({
    super.key,
    required this.label,
    required this.diagram,
  });

  final String label;
  final ChordDiagram diagram;

  static const stringSpacing = 24.0;
  static const fretRowHeight = 28.0;
  static const fretRows = 5;
  static const markerSize = 20.0;
  static const edgePadding = 12.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final stringCount = diagram.strings.length;
    final gridWidth = (stringCount - 1) * stringSpacing;
    final gridHeight = fretRows * fretRowHeight;
    final cardWidth = gridWidth + 2 * edgePadding;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(
          height: 16,
          child: diagram.baseFret > 0
              ? Text(
                  l10n.baseFretButtonLabel(diagram.baseFret),
                  style: Theme.of(context).textTheme.labelSmall,
                )
              : null,
        ),
        SizedBox(
          width: cardWidth,
          height: markerSize,
          child: Stack(
            children: [
              for (var s = 0; s < stringCount; s++)
                Positioned(
                  left: edgePadding + s * stringSpacing - markerSize / 2,
                  width: markerSize,
                  height: markerSize,
                  child: Center(
                    child: Text(
                      diagram.strings[s].isOpen
                          ? 'O'
                          : (diagram.strings[s].isMuted ? 'X' : ''),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          width: cardWidth,
          height: gridHeight,
          child: Stack(
            children: [
              Positioned(
                left: edgePadding,
                top: 0,
                child: CustomPaint(
                  size: Size(gridWidth, gridHeight),
                  painter: ChordDiagramPainter(
                    strings: diagram.strings,
                    fretRows: fretRows,
                    stringSpacing: stringSpacing,
                    fretRowHeight: fretRowHeight,
                    lineColor: colorScheme.outlineVariant,
                    showNut: diagram.baseFret == 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
