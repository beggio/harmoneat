import 'package:flutter/foundation.dart';

import 'beta_config.dart';
import 'beta_diagnostics.dart';
import 'beta_webhook_client.dart';
import 'usage_tracker.dart';

/// Installs global uncaught-exception hooks that report crashes to the
/// beta webhook automatically — no action needed from the tester. Only
/// ever called when [kBetaBuild] is true (see `main.dart`); the call
/// site itself is the only thing that needs to exist in a production
/// build, and it's gated by a compile-time constant, so the rest of this
/// file is unreachable there.
void installBetaCrashReporter(UsageTrackerNotifier usageTracker) {
  if (!kBetaBuild) return;

  final client = const BetaWebhookClient();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _report(client, usageTracker, details.exceptionAsString(), details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    _report(client, usageTracker, error.toString(), stack);
    return true;
  };
}

Future<void> _report(
  BetaWebhookClient client,
  UsageTrackerNotifier usageTracker,
  String error,
  StackTrace? stack,
) async {
  final diagnostics = await BetaDiagnostics.gather();
  final trimmedStack = stack == null
      ? '(no stack trace)'
      : stack.toString().split('\n').take(10).join('\n');
  await client.send(
    title: 'Beta crash report',
    description: '```\n$error\n\n$trimmedStack\n```',
    fields: {
      ...diagnostics.toFields(),
      'Usage so far': usageTracker.summaryText(),
    },
  );
}
