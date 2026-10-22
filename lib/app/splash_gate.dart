import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_version_provider.dart';
import 'shell.dart';
import 'splash_screen.dart';
import 'theme.dart';

/// Decides whether to show the splash screen before the main app shell:
/// always on the first launch of a version that hasn't been seen before,
/// optionally suppressed for later launches of that same version (see
/// `SplashAcknowledgedVersionNotifier`). Dismissing without checking
/// "don't show again" only skips it for the rest of *this* session
/// (tracked locally here, not persisted) — it still comes back next
/// launch unless the box was checked.
class SplashGate extends ConsumerStatefulWidget {
  const SplashGate({super.key});

  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate> {
  bool _dismissedThisSession = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissedThisSession) return const AppShell();

    final versionAsync = ref.watch(appVersionProvider);
    final acknowledgedVersion = ref.watch(splashAcknowledgedVersionProvider);

    return versionAsync.when(
      data: (version) {
        if (acknowledgedVersion == version) {
          return const AppShell();
        }
        return SplashScreen(
          appVersion: version,
          onContinue: (suppressForThisVersion) {
            if (suppressForThisVersion) {
              ref
                  .read(splashAcknowledgedVersionProvider.notifier)
                  .acknowledge(version);
            }
            setState(() => _dismissedThisSession = true);
          },
        );
      },
      // Fail open — a version lookup failure shouldn't block the app.
      error: (error, stack) => const AppShell(),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
