import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/color_schemes.dart';
import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';

const _largePrintScale = 1.3;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textScale = ref.watch(textScaleProvider);
    final colorScheme = ref.watch(appColorSchemeProvider);

    final colorSchemeLabels = {
      AppColorScheme.light: l10n.colorSchemeLightLabel,
      AppColorScheme.darkHighContrast: l10n.colorSchemeDarkHighContrastLabel,
      AppColorScheme.darkModern: l10n.colorSchemeDarkModernLabel,
      AppColorScheme.urbanCamo: l10n.colorSchemeUrbanCamoLabel,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsScreenTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.largePrintLabel),
            value: textScale > 1.0,
            onChanged: (enabled) => ref
                .read(textScaleProvider.notifier)
                .setScale(enabled ? _largePrintScale : 1.0),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.colorSchemeSectionLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          RadioGroup<AppColorScheme>(
            groupValue: colorScheme,
            onChanged: (selected) {
              if (selected != null) {
                ref.read(appColorSchemeProvider.notifier).setScheme(selected);
              }
            },
            child: Column(
              children: [
                for (final scheme in AppColorScheme.values)
                  RadioListTile<AppColorScheme>(
                    title: Text(colorSchemeLabels[scheme]!),
                    value: scheme,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
