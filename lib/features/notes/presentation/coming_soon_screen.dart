import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Placeholder destination for a toolbar action whose editor doesn't exist
/// yet (Tab/Chord/Notation) — lets the button be reachable now without
/// building the editor ahead of its own backlog item.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.featureName});

  final String featureName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(featureName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.comingSoonMessage(featureName),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
