import 'package:flutter/material.dart';

import '../../tab/application/finger_colors.dart';
import '../application/chord_chart_data.dart';

/// Renders one chord diagram's grid: vertical string lines, horizontal
/// fret lines (a thicker line for the nut), and a colored dot per fretted
/// string (colored by its assigned finger — see `finger_colors.dart`).
/// Open/muted markers ("O"/"X" above the nut) and tap handling live in the
/// surrounding widget in `ChordEditorScreen` — this painter is purely
/// visual.
class ChordDiagramPainter extends CustomPainter {
  const ChordDiagramPainter({
    required this.strings,
    required this.fretRows,
    required this.stringSpacing,
    required this.fretRowHeight,
    required this.lineColor,
  });

  final List<ChordString> strings;
  final int fretRows;
  final double stringSpacing;
  final double fretRowHeight;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final stringPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5;
    final fretPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    final nutPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 4;

    final gridWidth = (strings.length - 1) * stringSpacing;
    final gridHeight = fretRows * fretRowHeight;

    for (var s = 0; s < strings.length; s++) {
      final x = s * stringSpacing;
      canvas.drawLine(Offset(x, 0), Offset(x, gridHeight), stringPaint);
    }

    for (var f = 0; f <= fretRows; f++) {
      final y = f * fretRowHeight;
      canvas.drawLine(
        Offset(0, y),
        Offset(gridWidth, y),
        f == 0 ? nutPaint : fretPaint,
      );
    }

    final dotRadius = stringSpacing * 0.3;
    for (var s = 0; s < strings.length; s++) {
      final string = strings[s];
      if (!string.isFretted) continue;
      final x = s * stringSpacing;
      final y = (string.fret! - 0.5) * fretRowHeight;
      canvas.drawCircle(
        Offset(x, y),
        dotRadius,
        Paint()..color = colorForFinger(string.finger),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ChordDiagramPainter oldDelegate) {
    return oldDelegate.strings != strings || oldDelegate.lineColor != lineColor;
  }
}
