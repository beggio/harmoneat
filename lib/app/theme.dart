import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'themeMode';
const _accentColorKey = 'accentColor';
const _textScaleKey = 'textScale';
const _localeKey = 'locale';
const _cloudStorageAcknowledgedKey = 'cloudStorageAcknowledged';

/// Simple user preferences (theme, accent, text scale, locale) belong here,
/// not in Drift — they're prefs, not structured musical data. The Phase 2
/// Settings screen will call the setters below; Phase 1 just wires the
/// providers so every screen already respects them.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final stored = prefs.getString(_themeModeKey);
    if (stored != null) {
      state = ThemeMode.values.firstWhere(
        (m) => m.name == stored,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_themeModeKey, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class AccentColorNotifier extends Notifier<Color> {
  static const defaultColor = Colors.teal;

  @override
  Color build() {
    _load();
    return defaultColor;
  }

  Future<void> _load() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final stored = prefs.getInt(_accentColorKey);
    if (stored != null) {
      state = Color(stored);
    }
  }

  Future<void> setColor(Color color) async {
    state = color;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setInt(_accentColorKey, color.toARGB32());
  }
}

final accentColorProvider = NotifierProvider<AccentColorNotifier, Color>(
  AccentColorNotifier.new,
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

ThemeData buildTheme({
  required Brightness brightness,
  required Color seedColor,
}) {
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
