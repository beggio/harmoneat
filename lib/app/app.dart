import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'shell.dart';
import 'theme.dart';

class HarmoNeatApp extends ConsumerWidget {
  const HarmoNeatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final accentColor = ref.watch(accentColorProvider);
    final textScale = ref.watch(textScaleProvider);
    final localeOverride = ref.watch(localeOverrideProvider);

    return MaterialApp(
      title: 'HarmoNeat',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: buildTheme(brightness: Brightness.light, seedColor: accentColor),
      darkTheme: buildTheme(
        brightness: Brightness.dark,
        seedColor: accentColor,
      ),
      locale: localeOverride,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        );
      },
      home: const AppShell(),
    );
  }
}
