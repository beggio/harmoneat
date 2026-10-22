import 'package:flutter/material.dart';

import '../beta/beta_config.dart';
import '../l10n/app_localizations.dart';

/// Shown at least once per installed version (see `SplashGate`): app
/// name/version, a pre-production disclaimer, and how to send feedback.
/// The "don't show again" checkbox only suppresses it for *later*
/// launches of this same version — a new version always shows it again.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.appVersion,
    required this.onContinue,
  });

  final String appVersion;

  /// Called with whether the checkbox was checked, i.e. whether to
  /// persist the suppression for this version.
  final ValueChanged<bool> onContinue;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _dontShowAgain = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    // Flutter's Image widget animates multi-frame GIFs
                    // automatically — no extra plumbing needed.
                    child: Image.asset(
                      'assets/images/splash_animation.gif',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.splashVersionLabel(widget.appVersion),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.splashDisclaimerMessage,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    kBetaBuild
                        ? l10n.splashFeedbackPromptBeta
                        : l10n.splashFeedbackPromptDefault,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CheckboxListTile(
                    value: _dontShowAgain,
                    onChanged: (value) =>
                        setState(() => _dontShowAgain = value ?? true),
                    title: Text(l10n.splashDontShowAgainLabel),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => widget.onContinue(_dontShowAgain),
                    child: Text(l10n.splashContinueLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
