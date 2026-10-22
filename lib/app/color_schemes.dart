import 'package:flutter/material.dart';

/// The four selectable appearance presets. `light` is the original
/// seeded Material 3 scheme; the other three are hand-authored (not
/// `ColorScheme.fromSeed`) because high-contrast and camo palettes need
/// specific, deliberately-chosen tones rather than a single seed color's
/// tonal derivation.
enum AppColorScheme { light, darkHighContrast, darkModern, urbanCamo }

ColorScheme colorSchemeFor(AppColorScheme scheme) {
  switch (scheme) {
    case AppColorScheme.light:
      return ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.light,
      );
    case AppColorScheme.darkHighContrast:
      // Mirrors Windows' built-in "High Contrast Black" theme: pure black
      // background, white text, yellow for primary/selected elements.
      return const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFFFFF00),
        onPrimary: Color(0xFF000000),
        secondary: Color(0xFF00FFFF),
        onSecondary: Color(0xFF000000),
        error: Color(0xFFFF4D4D),
        onError: Color(0xFF000000),
        surface: Color(0xFF000000),
        onSurface: Color(0xFFFFFFFF),
        surfaceContainerHighest: Color(0xFF1A1A1A),
        outline: Color(0xFFFFFFFF),
        outlineVariant: Color(0xFF808080),
      );
    case AppColorScheme.darkModern:
      // Windows 11's dark mode: #202020 chrome, #2C2C2C surfaces, the
      // default Windows accent blue.
      return const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF4CC2FF),
        onPrimary: Color(0xFF00344D),
        secondary: Color(0xFF8AB4C8),
        onSecondary: Color(0xFF00242E),
        error: Color(0xFFFF8A80),
        onError: Color(0xFF4E0002),
        surface: Color(0xFF202020),
        onSurface: Color(0xFFE4E4E4),
        surfaceContainerHighest: Color(0xFF2C2C2C),
        outline: Color(0xFF5B5B5B),
        outlineVariant: Color(0xFF3F3F3F),
      );
    case AppColorScheme.urbanCamo:
      // Olive/khaki/tan camouflage palette.
      return const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF8A8B4C),
        onPrimary: Color(0xFF1A1B0C),
        secondary: Color(0xFFC2B280),
        onSecondary: Color(0xFF2B2616),
        error: Color(0xFFB5532E),
        onError: Color(0xFF1A0C06),
        surface: Color(0xFF2B2B23),
        onSurface: Color(0xFFD9D2A3),
        surfaceContainerHighest: Color(0xFF3B3C30),
        outline: Color(0xFF6B6B4F),
        outlineVariant: Color(0xFF4B4B3A),
      );
  }
}
