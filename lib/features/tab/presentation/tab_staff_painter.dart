import 'package:flutter/material.dart';

import '../application/finger_colors.dart';
import '../application/tab_data.dart';

/// Renders the horizontal string lines, per-beat divider ticks, and fret
/// numbers for a tab. Each fret number is colored by its assigned finger
/// (see `finger_colors.dart`). Tap handling lives in a separate widget
/// overlay in `TabEditorScreen` — this painter is purely visual.
class TabStaffPainter extends CustomPainter {
  const TabStaffPainter({
    required this.beats,
    required this.stringCount,
    required this.beatWidth,
    required this.rowHeight,
    required this.lineColor,
    required this.backgroundColor,
  });

  final List<TabBeat> beats;
  final int stringCount;
  final double beatWidth;
  final double rowHeight;
  final Color lineColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final stringLinePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    final dividerPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    for (var row = 0; row < stringCount; row++) {
      final y = rowHeight / 2 + row * rowHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), stringLinePaint);
    }

    for (var beatIndex = 0; beatIndex <= beats.length; beatIndex++) {
      final x = beatIndex * beatWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), dividerPaint);
    }

    for (var beatIndex = 0; beatIndex < beats.length; beatIndex++) {
      final beat = beats[beatIndex];
      final x = beatIndex * beatWidth;
      for (var stringIndex = 0; stringIndex < stringCount; stringIndex++) {
        final note = beat.notes[stringIndex];
        if (note == null) continue;

        final displayRow = stringCount - 1 - stringIndex;
        final y = rowHeight / 2 + displayRow * rowHeight;
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${note.fret}',
            style: TextStyle(
              color: colorForFinger(note.finger),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final center = Offset(x + beatWidth / 2, y);
        canvas.drawRect(
          Rect.fromCenter(
            center: center,
            width: textPainter.width + 6,
            height: textPainter.height + 2,
          ),
          Paint()..color = backgroundColor,
        );
        textPainter.paint(
          canvas,
          center - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant TabStaffPainter oldDelegate) {
    return oldDelegate.beats != beats ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
