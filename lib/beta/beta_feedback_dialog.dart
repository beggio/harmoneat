import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'beta_diagnostics.dart';
import 'beta_webhook_client.dart';
import 'usage_tracker.dart';

/// Opens the beta feedback dialog, gathers diagnostics + the usage
/// summary alongside whatever the tester typed, and sends it to the
/// webhook (falling back to a local save on failure — see
/// `BetaWebhookClient`).
Future<void> showBetaFeedbackDialog(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();

  final message = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.feedbackDialogTitle),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLines: 5,
        decoration: InputDecoration(hintText: l10n.feedbackFieldHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(l10n.save),
        ),
      ],
    ),
  );

  if (message == null || message.trim().isEmpty) return;
  if (!context.mounted) return;

  final usageTracker = ref.read(usageTrackerProvider.notifier);
  final diagnostics = await BetaDiagnostics.gather();
  final sent = await const BetaWebhookClient().send(
    title: 'Beta feedback',
    description: message,
    fields: {
      ...diagnostics.toFields(),
      'Usage so far': usageTracker.summaryText(),
    },
  );

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        sent ? l10n.feedbackSentMessage : l10n.feedbackSavedLocallyMessage,
      ),
    ),
  );
}
