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
  String get colorSchemeHarmoNeatLabel => 'HarmoNeat';

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

  @override
  String get capoSelectorLabel => 'Capo';

  @override
  String get capoNoneLabel => 'No capo';

  @override
  String capoFretOptionLabel(int fret) {
    return 'Fret $fret';
  }

  @override
  String get baseFretDialogTitle => 'Base fret';

  @override
  String baseFretButtonLabel(int fret) {
    return '${fret}fr';
  }

  @override
  String get notationSheetsTabLabel => 'Notation';

  @override
  String get notationSheetsListEmpty =>
      'No notation sheets yet. Tap Notation in the toolbar to add one.';

  @override
  String get untitledNotationSheetTitle => 'Untitled sheet';

  @override
  String get renameNotationSheet => 'Rename sheet';

  @override
  String get deleteNotationSheet => 'Delete sheet';

  @override
  String get addNoteEventLabel => 'Add note';

  @override
  String get removeNoteEventLabel => 'Remove note';

  @override
  String get timeSignatureLabel => 'Time signature';

  @override
  String get restToggleLabel => 'Rest';

  @override
  String get pitchLetterLabel => 'Letter';

  @override
  String get accidentalLabel => 'Accidental';

  @override
  String get accidentalFlatLabel => 'Flat';

  @override
  String get accidentalNaturalLabel => 'Natural';

  @override
  String get accidentalSharpLabel => 'Sharp';

  @override
  String get octaveLabel => 'Octave';

  @override
  String get durationWholeLabel => 'Whole';

  @override
  String get durationHalfLabel => 'Half';

  @override
  String get durationQuarterLabel => 'Quarter';

  @override
  String get durationEighthLabel => 'Eighth';

  @override
  String get dottedLabel => 'Dotted';

  @override
  String get noteEventDialogTitle => 'Note';

  @override
  String get navResources => 'Resources';

  @override
  String get resourcesScreenTitle => 'Resources';

  @override
  String get circleOfFifthsTitle => 'Circle of Fifths';

  @override
  String get circleOfFifthsSubtitle =>
      'Key signatures, relative minors, and closely related keys';

  @override
  String get selectKeyPrompt => 'Tap a key to see its details';

  @override
  String get relativeMinorLabel => 'Relative minor';

  @override
  String get keySignatureLabel => 'Key signature';

  @override
  String get noAccidentalsValue => 'No sharps or flats';

  @override
  String accidentalSummaryLabel(int count, String unit, String notes) {
    return '$count $unit: $notes';
  }

  @override
  String get subdominantLabel => 'Subdominant (IV)';

  @override
  String get dominantLabel => 'Dominant (V)';

  @override
  String subdominantHint(String key) {
    return '$key — one step counterclockwise';
  }

  @override
  String dominantHint(String key) {
    return '$key — one step clockwise';
  }

  @override
  String get sharpSingular => 'sharp';

  @override
  String get sharpPlural => 'sharps';

  @override
  String get flatSingular => 'flat';

  @override
  String get flatPlural => 'flats';

  @override
  String get allChordsTitle => 'All Major & Minor Chords';

  @override
  String get allChordsSubtitle =>
      'Every major and minor chord in standard tuning';

  @override
  String get betaSectionLabel => 'Beta Testing';

  @override
  String get betaDisclosureMessage =>
      'This beta build sends feedback and crash reports to the developer to help improve the app.';

  @override
  String get sendFeedbackLabel => 'Send Feedback';

  @override
  String get feedbackDialogTitle => 'Send Feedback';

  @override
  String get feedbackFieldHint =>
      'Bugs, confusing bits, anything on your mind...';

  @override
  String get feedbackSentMessage => 'Thanks! Feedback sent.';

  @override
  String get feedbackSavedLocallyMessage =>
      'Couldn\'t reach the server — saved locally instead.';

  @override
  String splashVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get splashDisclaimerMessage =>
      'This is pre-production software under active development. Expect bugs, missing features, and changes between versions.';

  @override
  String get splashFeedbackPromptBeta =>
      'Found a bug or have feedback? Open Settings → Send Feedback to report it directly from the app.';

  @override
  String get splashFeedbackPromptDefault =>
      'Found a bug or have feedback? Please let the developer know.';

  @override
  String get splashDontShowAgainLabel =>
      'Don\'t show this again for this version';

  @override
  String get splashContinueLabel => 'Continue';

  @override
  String get chordInstrumentSectionLabel => 'Chord Playback Sound';

  @override
  String get chordInstrumentGuitarSteelLabel => 'Guitar (Steel)';

  @override
  String get chordInstrumentGuitarOverdriveLabel => 'Guitar (Overdrive)';

  @override
  String get chordInstrumentGuitarDistortionLabel => 'Guitar (Distortion)';

  @override
  String get chordInstrumentPianoLabel => 'Piano';

  @override
  String get chordInstrumentChoirLabel => 'Choir';

  @override
  String get playChordLabel => 'Play chord';

  @override
  String get stopChordLabel => 'Stop';
}
