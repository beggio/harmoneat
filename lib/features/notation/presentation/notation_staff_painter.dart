import 'package:flutter/material.dart';

import '../application/notation_sheet_data.dart';
import '../application/staff_geometry.dart';

/// Horizontal layout of one event, computed once by the editor and handed
/// to the painter alongside the event itself — keeps tap-target geometry
/// (in the editor widget) and paint geometry (here) using the exact same
/// numbers.
class EventLayout {
  const EventLayout({
    required this.event,
    required this.x,
    required this.width,
    required this.barlineAfter,
  });

  final NotationEvent event;
  final double x;
  final double width;

  /// Whether a measure barline is drawn immediately after this event.
  final bool barlineAfter;
}

/// Renders a single continuous treble-clef staff: the 5 lines, a simplified
/// clef mark, noteheads/stems/flags/ledger-lines for pitched notes, rest
/// glyphs, and barlines. A hand-rolled `CustomPainter` rather than a
/// SMuFL/music font, per the original plan's fallback for this phase —
/// see `lib/features/notation/application/staff_geometry.dart` for the
/// pitch-to-staff-position math this draws from.
class NotationStaffPainter extends CustomPainter {
  const NotationStaffPainter({
    required this.layouts,
    required this.lineSpacing,
    required this.bottomLineY,
    required this.lineColor,
    required this.noteColor,
  });

  final List<EventLayout> layouts;
  final double lineSpacing;
  final double bottomLineY;
  final Color lineColor;
  final Color noteColor;

  double get _halfStep => lineSpacing / 2;

  double _yForStep(int step) => bottomLineY - step * _halfStep;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    for (var line = 0; line < 5; line++) {
      final y = _yForStep(line * 2);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    _drawClef(canvas);

    for (final layout in layouts) {
      if (layout.event.isRest) {
        _drawRest(canvas, layout);
      } else {
        _drawNote(canvas, layout);
      }
      if (layout.barlineAfter) {
        canvas.drawLine(
          Offset(layout.x + layout.width, _yForStep(0)),
          Offset(layout.x + layout.width, _yForStep(8)),
          linePaint,
        );
      }
    }
  }

  /// A simplified treble-clef mark — not a literal G-clef glyph (hand-
  /// drawing one accurately is its own small design project), but a
  /// recognizable stand-in: a tall curl anchored on the G4 line, which is
  /// what a real treble clef marks.
  void _drawClef(Canvas canvas) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final gLineY = _yForStep(2);
    final path = Path()
      ..moveTo(18, gLineY - lineSpacing * 2.6)
      ..cubicTo(2, gLineY - lineSpacing * 2.2, 2, gLineY - 2, 18, gLineY)
      ..cubicTo(
        32,
        gLineY + 2,
        32,
        gLineY + lineSpacing * 1.1,
        16,
        gLineY + lineSpacing * 1.3,
      )
      ..cubicTo(
        4,
        gLineY + lineSpacing * 1.45,
        6,
        gLineY + lineSpacing * 0.6,
        16,
        gLineY + lineSpacing * 0.5,
      );
    canvas.drawPath(path, paint);
  }

  void _drawNote(Canvas canvas, EventLayout layout) {
    final event = layout.event;
    final step = stepForPitch(event.pitch!);
    final headX = layout.x + layout.width / 2;
    final headY = _yForStep(step);
    final stemDown = stemPointsDown(step);

    _drawLedgerLines(canvas, step, headX);

    final headRadiusX = lineSpacing * 0.62;
    final headRadiusY = lineSpacing * 0.42;
    final headPaint = Paint()..color = noteColor;
    final isOpenHead =
        event.duration == NoteDuration.whole ||
        event.duration == NoteDuration.half;
    final headRect = Rect.fromCenter(
      center: Offset(headX, headY),
      width: headRadiusX * 2,
      height: headRadiusY * 2,
    );
    canvas.save();
    canvas.translate(headX, headY);
    canvas.rotate(-0.35);
    canvas.translate(-headX, -headY);
    if (isOpenHead) {
      canvas.drawOval(
        headRect,
        Paint()
          ..color = noteColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    } else {
      canvas.drawOval(headRect, headPaint);
    }
    canvas.restore();

    if (event.duration != NoteDuration.whole) {
      final stemX =
          headX + (stemDown ? -headRadiusX * 0.95 : headRadiusX * 0.95);
      final stemTopY = stemDown
          ? headY + lineSpacing * 3.2
          : headY - lineSpacing * 3.2;
      canvas.drawLine(
        Offset(stemX, headY),
        Offset(stemX, stemTopY),
        Paint()
          ..color = noteColor
          ..strokeWidth = 1.6,
      );
      if (event.duration == NoteDuration.eighth) {
        final flag = Path()..moveTo(stemX, stemTopY);
        if (stemDown) {
          flag.quadraticBezierTo(
            stemX + lineSpacing * 1.1,
            stemTopY + lineSpacing * 0.4,
            stemX + lineSpacing * 0.3,
            stemTopY + lineSpacing * 1.3,
          );
        } else {
          flag.quadraticBezierTo(
            stemX + lineSpacing * 1.1,
            stemTopY - lineSpacing * 0.4,
            stemX + lineSpacing * 0.3,
            stemTopY - lineSpacing * 1.3,
          );
        }
        canvas.drawPath(
          flag,
          Paint()
            ..color = noteColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }
    }

    if (event.dotted) {
      canvas.drawCircle(
        Offset(headX + headRadiusX + 4, headY),
        1.6,
        Paint()..color = noteColor,
      );
    }

    if (event.pitch!.accidental != 0) {
      final symbol = event.pitch!.accidental < 0 ? '♭' : '♯';
      final painter = TextPainter(
        text: TextSpan(
          text: symbol,
          style: TextStyle(color: noteColor, fontSize: lineSpacing * 1.6),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(
          headX - headRadiusX - painter.width - 2,
          headY - painter.height / 2,
        ),
      );
    }
  }

  void _drawLedgerLines(Canvas canvas, int step, double headX) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    for (final ledgerStep in ledgerLineStepsFor(step)) {
      final y = _yForStep(ledgerStep);
      canvas.drawLine(
        Offset(headX - lineSpacing * 0.9, y),
        Offset(headX + lineSpacing * 0.9, y),
        paint,
      );
    }
  }

  /// Rest shapes, approximated (no SMuFL font bundled — see the class
  /// doc). Whole/half rests use the standard "whole hangs below the 4th
  /// line, half sits on the middle line" convention; quarter/eighth rests
  /// use a simplified zigzag/hook stand-in for the real glyphs.
  void _drawRest(Canvas canvas, EventLayout layout) {
    final centerX = layout.x + layout.width / 2;
    final paint = Paint()..color = noteColor;
    final strokePaint = Paint()
      ..color = noteColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    switch (layout.event.duration) {
      case NoteDuration.whole:
        final y = _yForStep(6);
        canvas.drawRect(
          Rect.fromLTWH(
            centerX - lineSpacing * 0.5,
            y,
            lineSpacing,
            lineSpacing * 0.4,
          ),
          paint,
        );
        break;
      case NoteDuration.half:
        final y = _yForStep(4) - lineSpacing * 0.4;
        canvas.drawRect(
          Rect.fromLTWH(
            centerX - lineSpacing * 0.5,
            y,
            lineSpacing,
            lineSpacing * 0.4,
          ),
          paint,
        );
        break;
      case NoteDuration.quarter:
        final topY = _yForStep(6);
        final path = Path()
          ..moveTo(centerX - 3, topY)
          ..lineTo(centerX + 4, topY + lineSpacing * 0.9)
          ..lineTo(centerX - 4, topY + lineSpacing * 1.3)
          ..lineTo(centerX + 3, topY + lineSpacing * 2.2);
        canvas.drawPath(path, strokePaint);
        break;
      case NoteDuration.eighth:
        final topY = _yForStep(5);
        canvas.drawCircle(Offset(centerX + 2, topY), 2, paint);
        final path = Path()
          ..moveTo(centerX + 2, topY)
          ..quadraticBezierTo(
            centerX - 4,
            topY + lineSpacing * 0.6,
            centerX + 2,
            topY + lineSpacing * 1.4,
          );
        canvas.drawPath(path, strokePaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant NotationStaffPainter oldDelegate) {
    return oldDelegate.layouts != layouts || oldDelegate.lineColor != lineColor;
  }
}
