import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'splash_gate.dart';
import 'theme.dart';

class HarmoNeatApp extends ConsumerWidget {
  const HarmoNeatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = ref.watch(appColorSchemeProvider);
    final textScale = ref.watch(textScaleProvider);
    final localeOverride = ref.watch(localeOverrideProvider);

    return MaterialApp(
      title: 'HarmoNeat',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(colorScheme),
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
      home: const SplashGate(),
    );
  }
}
