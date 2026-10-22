import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'color_schemes.dart';

const _colorSchemeKey = 'appColorScheme';
const _textScaleKey = 'textScale';
const _localeKey = 'locale';
const _cloudStorageAcknowledgedKey = 'cloudStorageAcknowledged';

/// Simple user preferences (appearance, text scale, locale) belong here,
/// not in Drift — they're prefs, not structured musical data. The Settings
/// screen calls the setters below; every other screen just watches the
/// providers so it already respects whatever's chosen.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

class AppColorSchemeNotifier extends Notifier<AppColorScheme> {
  @override
  AppColorScheme build() {
    _load();
    return AppColorScheme.light;
  }

  Future<void> _load() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final stored = prefs.getString(_colorSchemeKey);
    if (stored != null) {
      state = AppColorScheme.values.firstWhere(
        (s) => s.name == stored,
        orElse: () => AppColorScheme.light,
      );
    }
  }

  Future<void> setScheme(AppColorScheme scheme) async {
    state = scheme;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_colorSchemeKey, scheme.name);
  }
}

final appColorSchemeProvider =
    NotifierProvider<AppColorSchemeNotifier, AppColorScheme>(
      AppColorSchemeNotifier.new,
    );

class TextScaleNotifier extends Notifier<double> {
  @override
  double build() {
    _load();
    return 1.0;
  }

  Future<void> _load() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final stored = prefs.getDouble(_textScaleKey);
    if (stored != null) {
      state = stored;
    }
  }

  Future<void> setScale(double scale) async {
    state = scale;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setDouble(_textScaleKey, scale);
  }
}

final textScaleProvider = NotifierProvider<TextScaleNotifier, double>(
  TextScaleNotifier.new,
);

class LocaleOverrideNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final stored = prefs.getString(_localeKey);
    if (stored != null) {
      state = Locale(stored);
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    if (locale == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, locale.languageCode);
    }
  }
}

final localeOverrideProvider =
    NotifierProvider<LocaleOverrideNotifier, Locale?>(
      LocaleOverrideNotifier.new,
    );

/// Whether the user has already dismissed the cloud-storage acknowledgement
/// dialog, so it only interrupts the first recording/import attempt and
/// never again on this device.
class CloudStorageAcknowledgedNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    state = prefs.getBool(_cloudStorageAcknowledgedKey) ?? false;
  }

  Future<void> acknowledge() async {
    state = true;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(_cloudStorageAcknowledgedKey, true);
  }
}

final cloudStorageAcknowledgedProvider =
    NotifierProvider<CloudStorageAcknowledgedNotifier, bool>(
      CloudStorageAcknowledgedNotifier.new,
    );

/// Stand-in for Andale Mono, which is a licensed Monotype font Flutter
/// can't pick up from the OS by name — it must ship as an embedded font
/// file. JetBrains Mono is a free, visually similar monospace used here
/// until a licensed Andale Mono file is added to `assets/fonts` and swapped
/// in below.
ThemeData buildTheme(AppColorScheme scheme) {
  final colorScheme = colorSchemeFor(scheme);
  final textTheme = GoogleFonts.jetBrainsMonoTextTheme(
    ThemeData(brightness: colorScheme.brightness).textTheme,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
