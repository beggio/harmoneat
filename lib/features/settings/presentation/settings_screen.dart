import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_logo_icon.dart';
import '../../../app/color_schemes.dart';
import '../../../app/theme.dart';
import '../../../beta/beta_config.dart';
import '../../../beta/beta_feedback_dialog.dart';
import '../../chord/application/chord_instrument.dart';
import '../../../l10n/app_localizations.dart';

const _largePrintScale = 1.3;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textScale = ref.watch(textScaleProvider);
    final colorScheme = ref.watch(appColorSchemeProvider);
    final chordInstrument = ref.watch(chordInstrumentProvider);

    final colorSchemeLabels = {
      AppColorScheme.light: l10n.colorSchemeLightLabel,
      AppColorScheme.darkHighContrast: l10n.colorSchemeDarkHighContrastLabel,
      AppColorScheme.darkModern: l10n.colorSchemeDarkModernLabel,
      AppColorScheme.urbanCamo: l10n.colorSchemeUrbanCamoLabel,
      AppColorScheme.harmoNeat: l10n.colorSchemeHarmoNeatLabel,
    };

    final chordInstrumentLabels = {
      ChordInstrumentSound.guitar: l10n.chordInstrumentGuitarLabel,
      ChordInstrumentSound.guitarSteel: l10n.chordInstrumentGuitarSteelLabel,
      ChordInstrumentSound.guitarJazz: l10n.chordInstrumentGuitarJazzLabel,
      ChordInstrumentSound.guitarClean: l10n.chordInstrumentGuitarCleanLabel,
      ChordInstrumentSound.guitarPalmMuted:
          l10n.chordInstrumentGuitarPalmMutedLabel,
      ChordInstrumentSound.guitarOverdrive:
          l10n.chordInstrumentGuitarOverdriveLabel,
      ChordInstrumentSound.guitarDistortion:
          l10n.chordInstrumentGuitarDistortionLabel,
      ChordInstrumentSound.guitarHarmonics:
          l10n.chordInstrumentGuitarHarmonicsLabel,
      ChordInstrumentSound.piano: l10n.chordInstrumentPianoLabel,
      ChordInstrumentSound.femaleVoice: l10n.chordInstrumentFemaleVoiceLabel,
    };

    return Scaffold(
      appBar: AppBar(
        leading: const AppLogoIcon(),
        title: Text(l10n.settingsScreenTitle),
      ),
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
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.chordInstrumentSectionLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          RadioGroup<ChordInstrumentSound>(
            groupValue: chordInstrument,
            onChanged: (selected) {
              if (selected != null) {
                ref
                    .read(chordInstrumentProvider.notifier)
                    .setInstrument(selected);
              }
            },
            child: Column(
              children: [
                for (final sound in ChordInstrumentSound.values)
                  RadioListTile<ChordInstrumentSound>(
                    title: Text(chordInstrumentLabels[sound]!),
                    value: sound,
                  ),
              ],
            ),
          ),
          if (kBetaBuild) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                l10n.betaSectionLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l10n.betaDisclosureMessage,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: Text(l10n.sendFeedbackLabel),
              onTap: () => showBetaFeedbackDialog(context, ref),
            ),
          ],
        ],
      ),
    );
  }
}
