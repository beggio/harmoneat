import 'package:flutter/material.dart';

/// Fretting-hand finger numbering used throughout the tab editor: 1 = index,
/// 2 = middle, 3 = ring, 4 = pinky, 5 = thumb (fretting with the thumb over
/// the neck, common enough in guitar tab to warrant its own number rather
/// than an afterthought).
const fingerColors = <int, Color>{
  1: Color(0xFF2E7D32), // index — green
  2: Color(0xFF1565C0), // middle — blue
  3: Color(0xFFEF6C00), // ring — orange
  4: Color(0xFF6A1B9A), // pinky — purple
  5: Color(0xFFC62828), // thumb — red
};

/// Color for a note with no finger assigned — distinct from every entry in
/// [fingerColors] so "unspecified" never looks like finger 1.
const unspecifiedFingerColor = Color(0xFF616161);

Color colorForFinger(int? finger) =>
    finger == null ? unspecifiedFingerColor : fingerColors[finger]!;
