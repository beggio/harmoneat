import 'dart:math';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../application/circle_of_fifths_data.dart';

/// Interactive circle of fifths: major keys on the outer ring, their
/// relative minors on the inner ring, same key signature per wedge.
/// Selecting a key also highlights its dominant (V, one step clockwise)
/// and subdominant (IV, one step counterclockwise) — the circle's layout
/// makes these functional-harmony relationships visually adjacent, which
/// is the whole point of the diagram.
class CircleOfFifthsScreen extends StatefulWidget {
  const CircleOfFifthsScreen({super.key});

  @override
  State<CircleOfFifthsScreen> createState() => _CircleOfFifthsScreenState();
}

class _CircleOfFifthsScreenState extends State<CircleOfFifthsScreen> {
  int? _selectedIndex;

  static const _diagramSize = 360.0;
  static const _outerRadius = 140.0;
  static const _innerRadius = 88.0;
  static const _majorButtonSize = 62.0;
  static const _minorButtonSize = 48.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.circleOfFifthsTitle)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            SizedBox(
              width: _diagramSize,
              height: _diagramSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(_diagramSize, _diagramSize),
                    painter: _RingGuidesPainter(
                      outerRadius: _outerRadius,
                      innerRadius: _innerRadius,
                      color: colorScheme.outlineVariant,
                    ),
                  ),
                  for (var i = 0; i < circleOfFifthsKeys.length; i++) ...[
                    _keyButton(context, index: i, isMajor: true),
                    _keyButton(context, index: i, isMajor: false),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _DetailsPanel(selectedIndex: _selectedIndex),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _keyButton(
    BuildContext context, {
    required int index,
    required bool isMajor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final key = circleOfFifthsKeys[index];
    final label = isMajor ? key.majorName : key.minorName;
    final size = isMajor ? _majorButtonSize : _minorButtonSize;
    final radius = isMajor ? _outerRadius : _innerRadius;

    final angle = (index * 30 - 90) * pi / 180;
    final dx = radius * cos(angle);
    final dy = radius * sin(angle);

    final isSelected = _selectedIndex == index;
    final isDominant =
        _selectedIndex != null && index == (_selectedIndex! + 1) % 12;
    final isSubdominant =
        _selectedIndex != null && index == (_selectedIndex! - 1 + 12) % 12;

    Color background;
    Color foreground;
    if (isSelected) {
      background = colorScheme.primary;
      foreground = colorScheme.onPrimary;
    } else if (isDominant) {
      background = colorScheme.tertiaryContainer;
      foreground = colorScheme.onTertiaryContainer;
    } else if (isSubdominant) {
      background = colorScheme.secondaryContainer;
      foreground = colorScheme.onSecondaryContainer;
    } else {
      background = colorScheme.surfaceContainerHighest;
      foreground = colorScheme.onSurface;
    }

    return Positioned(
      left: _diagramSize / 2 + dx - size / 2,
      top: _diagramSize / 2 + dy - size / 2,
      width: size,
      height: size,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => setState(() => _selectedIndex = index),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: foreground,
                  fontWeight: isMajor ? FontWeight.bold : FontWeight.normal,
                  fontSize: isMajor ? 13 : 11,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingGuidesPainter extends CustomPainter {
  const _RingGuidesPainter({
    required this.outerRadius,
    required this.innerRadius,
    required this.color,
  });

  final double outerRadius;
  final double innerRadius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, outerRadius, paint);
    canvas.drawCircle(center, innerRadius, paint);
  }

  @override
  bool shouldRepaint(covariant _RingGuidesPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({required this.selectedIndex});

  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final index = selectedIndex;
    if (index == null) {
      return Text(
        l10n.selectKeyPrompt,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      );
    }

    final key = circleOfFifthsKeys[index];
    final subdominant = circleOfFifthsKeys[(index - 1 + 12) % 12];
    final dominant = circleOfFifthsKeys[(index + 1) % 12];

    final accidentalCount = key.sharps > 0 ? key.sharps : key.flats;
    final keySignature = accidentalCount == 0
        ? l10n.noAccidentalsValue
        : l10n.accidentalSummaryLabel(
            accidentalCount,
            key.sharps > 0
                ? (accidentalCount == 1 ? l10n.sharpSingular : l10n.sharpPlural)
                : (accidentalCount == 1 ? l10n.flatSingular : l10n.flatPlural),
            key.accidentalNotes.join(', '),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${key.majorName} major / ${key.minorName} minor',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text('${l10n.keySignatureLabel}: $keySignature'),
        const SizedBox(height: 4),
        Text('${l10n.relativeMinorLabel}: ${key.minorName}'),
        const SizedBox(height: 12),
        Text(
          '${l10n.subdominantLabel}: ${l10n.subdominantHint(subdominant.majorName)}',
        ),
        Text('${l10n.dominantLabel}: ${l10n.dominantHint(dominant.majorName)}'),
      ],
    );
  }
}
