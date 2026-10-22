import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'all_chords_screen.dart';
import 'circle_of_fifths_screen.dart';

/// Standalone reference tools, independent of any note — as opposed to
/// Tab/Chord/Notation, which always belong to one. Just the Circle of
/// Fifths for now; more entries append to this list as they're built.
class ResourcesListScreen extends StatelessWidget {
  const ResourcesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.resourcesScreenTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.donut_large_outlined),
            title: Text(l10n.circleOfFifthsTitle),
            subtitle: Text(l10n.circleOfFifthsSubtitle),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CircleOfFifthsScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.grid_on_outlined),
            title: Text(l10n.allChordsTitle),
            subtitle: Text(l10n.allChordsSubtitle),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AllChordsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
