// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HarmoNeat';

  @override
  String get navNotes => 'Notes';

  @override
  String get navSettings => 'Settings';

  @override
  String get notesListEmpty => 'No notes yet. Tap + to create one.';

  @override
  String get notesListTitle => 'Notes';

  @override
  String get newNote => 'New note';

  @override
  String get untitledNote => 'Untitled note';

  @override
  String get deleteNote => 'Delete note';

  @override
  String get renameNote => 'Rename note';

  @override
  String get noteTitleLabel => 'Title';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get noteTextTabLabel => 'Text';

  @override
  String get noteBodyHint => 'Write something...';

  @override
  String get attachmentsTabLabel => 'Attachments';

  @override
  String get attachmentsListEmpty => 'No recordings yet.';

  @override
  String get recordButtonLabel => 'Record';

  @override
  String get stopButtonLabel => 'Stop';

  @override
  String get playButtonLabel => 'Play';

  @override
  String get pauseButtonLabel => 'Pause';

  @override
  String get importAudioLabel => 'Import audio';

  @override
  String get deleteAttachment => 'Delete recording';

  @override
  String get tabButtonLabel => 'Tab';

  @override
  String get chordButtonLabel => 'Chord';

  @override
  String get notationButtonLabel => 'Notation';

  @override
  String comingSoonMessage(String feature) {
    return 'The $feature editor isn\'t built yet — this button is a placeholder.';
  }

  @override
  String get cloudStorageNoticeTitle => 'Audio files may sync to the cloud';

  @override
  String cloudStorageNoticeMessage(String provider) {
    return 'This device stores documents in a $provider folder. Recordings and audio you import in HarmoNeat are saved there too, so they may be uploaded to that account automatically. If you\'d rather keep them local, change where your documents are stored in your OS settings.';
  }

  @override
  String get cloudStorageNoticeAcknowledge => 'Got it';

  @override
  String get cloudStorageNoticeDontShowAgain => 'Don\'t show this again';

  @override
  String get tabsTabLabel => 'Tabs';

  @override
  String get tabsListEmpty =>
      'No guitar tabs yet. Tap Tab in the toolbar to add one.';

  @override
  String get untitledTabTitle => 'Untitled tab';

  @override
  String get renameTab => 'Rename tab';

  @override
  String get deleteTab => 'Delete tab';

  @override
  String get addBeatLabel => 'Add beat';

  @override
  String get removeBeatLabel => 'Remove beat';

  @override
  String get fretDialogTitle => 'Fret';

  @override
  String get clearFretLabel => 'Clear';

  @override
  String get fingerIndexLabel => 'Index';

  @override
  String get fingerMiddleLabel => 'Middle';

  @override
  String get fingerRingLabel => 'Ring';

  @override
  String get fingerPinkyLabel => 'Pinky';

  @override
  String get fingerThumbLabel => 'Thumb';

  @override
  String get assignFingerToggleLabel => 'Assign finger';

  @override
  String get tuningFieldLabel => 'Tuning';

  @override
  String get tuningStandardLabel => 'E';

  @override
  String get tuningEFlatLabel => 'E♭';

  @override
  String get tuningDropDLabel => 'Drop D';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get largePrintLabel => 'Large print';

  @override
  String get colorSchemeSectionLabel => 'Color scheme';

  @override
  String get colorSchemeLightLabel => 'Light';

  @override
  String get colorSchemeDarkHighContrastLabel => 'Dark High Contrast';

  @override
  String get colorSchemeDarkModernLabel => 'Dark Modern';

  @override
  String get colorSchemeUrbanCamoLabel => 'Urban Camo';

  @override
  String get chordChartsTabLabel => 'Chords';

  @override
  String get chordChartsListEmpty =>
      'No chord charts yet. Tap Chord in the toolbar to add one.';

  @override
  String get untitledChordChartTitle => 'Untitled chord chart';

  @override
  String get renameChordChart => 'Rename chord chart';

  @override
  String get deleteChordChart => 'Delete chord chart';

  @override
  String get addChordLabel => 'Add chord';

  @override
  String get removeChordLabel => 'Remove chord';

  @override
  String get untitledChordLabel => 'Untitled';

  @override
  String get chordNameDialogTitle => 'Chord name';
}
