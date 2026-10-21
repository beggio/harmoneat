import 'package:flutter/material.dart';

import '../features/notes/presentation/notes_list_screen.dart';
import '../l10n/app_localizations.dart';

/// Adaptive navigation shell: a `NavigationRail` down the side on
/// desktop/tablet-landscape widths, a bottom `NavigationBar` on narrow
/// widths, switched at Material's ~600dp breakpoint. Phase 1 has a single
/// destination (Notes); Phase 2's Settings screen is a second entry here,
/// not a shell rewrite.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _destinations = [
    _Destination(
      screen: NotesListScreen(),
      icon: Icons.note_alt_outlined,
      selectedIcon: Icons.note_alt,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [l10n.navNotes];
    final body = IndexedStack(
      index: _selectedIndex,
      children: [for (final d in _destinations) d.screen],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) =>
                      setState(() => _selectedIndex = index),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (var i = 0; i < _destinations.length; i++)
                      NavigationRailDestination(
                        icon: Icon(_destinations[i].icon),
                        selectedIcon: Icon(_destinations[i].selectedIcon),
                        label: Text(labels[i]),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            destinations: [
              for (var i = 0; i < _destinations.length; i++)
                NavigationDestination(
                  icon: Icon(_destinations[i].icon),
                  selectedIcon: Icon(_destinations[i].selectedIcon),
                  label: labels[i],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Destination {
  const _Destination({
    required this.screen,
    required this.icon,
    required this.selectedIcon,
  });

  final Widget screen;
  final IconData icon;
  final IconData selectedIcon;
}
