import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application's title, shown in the OS task switcher and window title.
  ///
  /// In en, this message translates to:
  /// **'HarmoNeat'**
  String get appTitle;

  /// Navigation destination label for the notes list.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get navNotes;

  /// Navigation destination label for the settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Shown in the notes list when there are no notes.
  ///
  /// In en, this message translates to:
  /// **'No notes yet. Tap + to create one.'**
  String get notesListEmpty;

  /// App bar title for the notes list screen.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesListTitle;

  /// Tooltip/label for the button that creates a new note.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get newNote;

  /// Default title shown for a note with no title.
  ///
  /// In en, this message translates to:
  /// **'Untitled note'**
  String get untitledNote;

  /// Action label for deleting a note.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get deleteNote;

  /// Action label for renaming a note.
  ///
  /// In en, this message translates to:
  /// **'Rename note'**
  String get renameNote;

  /// Text field label for a note's title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get noteTitleLabel;

  /// Generic cancel button label.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic save button label.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Tab label for a note's free-text body.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get noteTextTabLabel;

  /// Placeholder shown in the empty note body text field.
  ///
  /// In en, this message translates to:
  /// **'Write something...'**
  String get noteBodyHint;

  /// Tab label for a note's audio attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachmentsTabLabel;

  /// Shown when a note has no audio attachments.
  ///
  /// In en, this message translates to:
  /// **'No recordings yet.'**
  String get attachmentsListEmpty;

  /// Label for the button that starts recording.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get recordButtonLabel;

  /// Label for the button that stops recording or playback.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopButtonLabel;

  /// Label for the button that starts playback of an attachment.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playButtonLabel;

  /// Label for the button that pauses playback.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseButtonLabel;

  /// Label for the action that imports an existing audio file.
  ///
  /// In en, this message translates to:
  /// **'Import audio'**
  String get importAudioLabel;

  /// Action label for deleting an audio attachment.
  ///
  /// In en, this message translates to:
  /// **'Delete recording'**
  String get deleteAttachment;

  /// Label for the toolbar button that creates a new guitar tab.
  ///
  /// In en, this message translates to:
  /// **'Tab'**
  String get tabButtonLabel;

  /// Label for the toolbar button that creates a new chord chart.
  ///
  /// In en, this message translates to:
  /// **'Chord'**
  String get chordButtonLabel;

  /// Label for the toolbar button that creates a new standard notation sheet.
  ///
  /// In en, this message translates to:
  /// **'Notation'**
  String get notationButtonLabel;

  /// Title of the one-time dialog warning that recordings/imports land in a cloud-synced folder.
  ///
  /// In en, this message translates to:
  /// **'Audio files may sync to the cloud'**
  String get cloudStorageNoticeTitle;

  /// Body text of the cloud-storage acknowledgement dialog.
  ///
  /// In en, this message translates to:
  /// **'This device stores documents in a {provider} folder. Recordings and audio you import in HarmoNeat are saved there too, so they may be uploaded to that account automatically. If you\'d rather keep them local, change where your documents are stored in your OS settings.'**
  String cloudStorageNoticeMessage(String provider);

  /// Button label that dismisses the cloud-storage acknowledgement dialog.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get cloudStorageNoticeAcknowledge;

  /// Checkbox label in the cloud-storage acknowledgement dialog that suppresses future showings.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show this again'**
  String get cloudStorageNoticeDontShowAgain;

  /// Tab label for a note's list of guitar tabs.
  ///
  /// In en, this message translates to:
  /// **'Tabs'**
  String get tabsTabLabel;

  /// Shown when a note has no guitar tabs.
  ///
  /// In en, this message translates to:
  /// **'No guitar tabs yet. Tap Tab in the toolbar to add one.'**
  String get tabsListEmpty;

  /// Default title shown for a guitar tab with no title.
  ///
  /// In en, this message translates to:
  /// **'Untitled tab'**
  String get untitledTabTitle;

  /// Action label for renaming a guitar tab.
  ///
  /// In en, this message translates to:
  /// **'Rename tab'**
  String get renameTab;

  /// Action label for deleting a guitar tab.
  ///
  /// In en, this message translates to:
  /// **'Delete tab'**
  String get deleteTab;

  /// Tooltip for the action that appends a new beat/column to a guitar tab.
  ///
  /// In en, this message translates to:
  /// **'Add beat'**
  String get addBeatLabel;

  /// Tooltip for the action that removes one beat/column from a guitar tab.
  ///
  /// In en, this message translates to:
  /// **'Remove beat'**
  String get removeBeatLabel;

  /// Title and field label for the dialog that sets a fret number on a tab string.
  ///
  /// In en, this message translates to:
  /// **'Fret'**
  String get fretDialogTitle;

  /// Button label that clears a fret number back to unplayed.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearFretLabel;

  /// Fretting-hand finger 1.
  ///
  /// In en, this message translates to:
  /// **'Index'**
  String get fingerIndexLabel;

  /// Fretting-hand finger 2.
  ///
  /// In en, this message translates to:
  /// **'Middle'**
  String get fingerMiddleLabel;

  /// Fretting-hand finger 3.
  ///
  /// In en, this message translates to:
  /// **'Ring'**
  String get fingerRingLabel;

  /// Fretting-hand finger 4.
  ///
  /// In en, this message translates to:
  /// **'Pinky'**
  String get fingerPinkyLabel;

  /// Fretting-hand finger 5.
  ///
  /// In en, this message translates to:
  /// **'Thumb'**
  String get fingerThumbLabel;

  /// Toggle in the fret-editing dialog that enables the (otherwise grayed-out) finger picker.
  ///
  /// In en, this message translates to:
  /// **'Assign finger'**
  String get assignFingerToggleLabel;

  /// Label for the tuning dropdown shown on a music form (tab, and later chord chart/notation).
  ///
  /// In en, this message translates to:
  /// **'Tuning'**
  String get tuningFieldLabel;

  /// Standard guitar tuning preset label.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get tuningStandardLabel;

  /// Half-step-down (E flat) guitar tuning preset label.
  ///
  /// In en, this message translates to:
  /// **'E♭'**
  String get tuningEFlatLabel;

  /// Drop D guitar tuning preset label.
  ///
  /// In en, this message translates to:
  /// **'Drop D'**
  String get tuningDropDLabel;

  /// App bar title for the settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// Switch label that enables larger text throughout the app.
  ///
  /// In en, this message translates to:
  /// **'Large print'**
  String get largePrintLabel;

  /// Heading for the color scheme selector on the settings screen.
  ///
  /// In en, this message translates to:
  /// **'Color scheme'**
  String get colorSchemeSectionLabel;

  /// The default light color scheme option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get colorSchemeLightLabel;

  /// A high-contrast dark color scheme, modeled on Windows' built-in High Contrast Black theme.
  ///
  /// In en, this message translates to:
  /// **'Dark High Contrast'**
  String get colorSchemeDarkHighContrastLabel;

  /// A dark color scheme modeled on Windows 11's dark mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Modern'**
  String get colorSchemeDarkModernLabel;

  /// A camouflage-inspired olive/khaki/tan dark color scheme.
  ///
  /// In en, this message translates to:
  /// **'Urban Camo'**
  String get colorSchemeUrbanCamoLabel;

  /// Tab label for a note's list of chord charts.
  ///
  /// In en, this message translates to:
  /// **'Chords'**
  String get chordChartsTabLabel;

  /// Shown when a note has no chord charts.
  ///
  /// In en, this message translates to:
  /// **'No chord charts yet. Tap Chord in the toolbar to add one.'**
  String get chordChartsListEmpty;

  /// Default title shown for a chord chart with no title.
  ///
  /// In en, this message translates to:
  /// **'Untitled chord chart'**
  String get untitledChordChartTitle;

  /// Action label for renaming a chord chart.
  ///
  /// In en, this message translates to:
  /// **'Rename chord chart'**
  String get renameChordChart;

  /// Action label for deleting a chord chart.
  ///
  /// In en, this message translates to:
  /// **'Delete chord chart'**
  String get deleteChordChart;

  /// Tooltip for the action that appends a new chord diagram to a chord chart.
  ///
  /// In en, this message translates to:
  /// **'Add chord'**
  String get addChordLabel;

  /// Tooltip for the action that removes one chord diagram from a chord chart.
  ///
  /// In en, this message translates to:
  /// **'Remove chord'**
  String get removeChordLabel;

  /// Default label shown for a chord diagram with no name.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitledChordLabel;

  /// Title and field label for the dialog that names a chord diagram (e.g. "C", "G7").
  ///
  /// In en, this message translates to:
  /// **'Chord name'**
  String get chordNameDialogTitle;

  /// Label for the capo dropdown on a chord chart.
  ///
  /// In en, this message translates to:
  /// **'Capo'**
  String get capoSelectorLabel;

  /// Capo dropdown option meaning no capo is used.
  ///
  /// In en, this message translates to:
  /// **'No capo'**
  String get capoNoneLabel;

  /// Capo dropdown option naming the fret the capo is placed on.
  ///
  /// In en, this message translates to:
  /// **'Fret {fret}'**
  String capoFretOptionLabel(int fret);

  /// Title and field label for the dialog that sets which fret a chord diagram's first row represents.
  ///
  /// In en, this message translates to:
  /// **'Base fret'**
  String get baseFretDialogTitle;

  /// Button label showing a chord diagram's base fret (e.g. "5fr"), shown when it's higher than the nut.
  ///
  /// In en, this message translates to:
  /// **'{fret}fr'**
  String baseFretButtonLabel(int fret);

  /// Tab label for a note's list of standard notation sheets.
  ///
  /// In en, this message translates to:
  /// **'Notation'**
  String get notationSheetsTabLabel;

  /// Shown when a note has no notation sheets.
  ///
  /// In en, this message translates to:
  /// **'No notation sheets yet. Tap Notation in the toolbar to add one.'**
  String get notationSheetsListEmpty;

  /// Default title shown for a notation sheet with no title.
  ///
  /// In en, this message translates to:
  /// **'Untitled sheet'**
  String get untitledNotationSheetTitle;

  /// Action label for renaming a notation sheet.
  ///
  /// In en, this message translates to:
  /// **'Rename sheet'**
  String get renameNotationSheet;

  /// Action label for deleting a notation sheet.
  ///
  /// In en, this message translates to:
  /// **'Delete sheet'**
  String get deleteNotationSheet;

  /// Tooltip for the action that appends a new note/rest to a notation sheet.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNoteEventLabel;

  /// Tooltip for the action that removes one note/rest from a notation sheet.
  ///
  /// In en, this message translates to:
  /// **'Remove note'**
  String get removeNoteEventLabel;

  /// Label for the time-signature selector on a notation sheet.
  ///
  /// In en, this message translates to:
  /// **'Time signature'**
  String get timeSignatureLabel;

  /// Toggle in the note-editing dialog that makes this event a rest instead of a pitched note.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get restToggleLabel;

  /// Label for the pitch-letter dropdown (A-G) in the note-editing dialog.
  ///
  /// In en, this message translates to:
  /// **'Letter'**
  String get pitchLetterLabel;

  /// Label for the accidental dropdown in the note-editing dialog.
  ///
  /// In en, this message translates to:
  /// **'Accidental'**
  String get accidentalLabel;

  /// Flat accidental option.
  ///
  /// In en, this message translates to:
  /// **'Flat'**
  String get accidentalFlatLabel;

  /// No-accidental option.
  ///
  /// In en, this message translates to:
  /// **'Natural'**
  String get accidentalNaturalLabel;

  /// Sharp accidental option.
  ///
  /// In en, this message translates to:
  /// **'Sharp'**
  String get accidentalSharpLabel;

  /// Label for the octave stepper in the note-editing dialog.
  ///
  /// In en, this message translates to:
  /// **'Octave'**
  String get octaveLabel;

  /// Whole-note duration option.
  ///
  /// In en, this message translates to:
  /// **'Whole'**
  String get durationWholeLabel;

  /// Half-note duration option.
  ///
  /// In en, this message translates to:
  /// **'Half'**
  String get durationHalfLabel;

  /// Quarter-note duration option.
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get durationQuarterLabel;

  /// Eighth-note duration option.
  ///
  /// In en, this message translates to:
  /// **'Eighth'**
  String get durationEighthLabel;

  /// Toggle for a dotted (1.5x length) note/rest in the note-editing dialog.
  ///
  /// In en, this message translates to:
  /// **'Dotted'**
  String get dottedLabel;

  /// Title for the dialog that edits one note/rest on a notation sheet.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteEventDialogTitle;

  /// Navigation destination label for the resources screen.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get navResources;

  /// App bar title for the resources screen.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resourcesScreenTitle;

  /// Title for the interactive circle of fifths tool.
  ///
  /// In en, this message translates to:
  /// **'Circle of Fifths'**
  String get circleOfFifthsTitle;

  /// One-line description shown under the Circle of Fifths entry on the resources list.
  ///
  /// In en, this message translates to:
  /// **'Key signatures, relative minors, and closely related keys'**
  String get circleOfFifthsSubtitle;

  /// Prompt shown on the Circle of Fifths tool before any key is selected.
  ///
  /// In en, this message translates to:
  /// **'Tap a key to see its details'**
  String get selectKeyPrompt;

  /// Label for a key's relative minor on the Circle of Fifths tool.
  ///
  /// In en, this message translates to:
  /// **'Relative minor'**
  String get relativeMinorLabel;

  /// Label for a key's signature (sharps/flats) on the Circle of Fifths tool.
  ///
  /// In en, this message translates to:
  /// **'Key signature'**
  String get keySignatureLabel;

  /// Key signature value shown for C major / A minor, which has no sharps or flats.
  ///
  /// In en, this message translates to:
  /// **'No sharps or flats'**
  String get noAccidentalsValue;

  /// Key signature summary, e.g. "2 sharps: F♯, C♯".
  ///
  /// In en, this message translates to:
  /// **'{count} {unit}: {notes}'**
  String accidentalSummaryLabel(int count, String unit, String notes);

  /// Label for a key's subdominant (IV) neighbor on the Circle of Fifths tool.
  ///
  /// In en, this message translates to:
  /// **'Subdominant (IV)'**
  String get subdominantLabel;

  /// Label for a key's dominant (V) neighbor on the Circle of Fifths tool.
  ///
  /// In en, this message translates to:
  /// **'Dominant (V)'**
  String get dominantLabel;

  /// Explains where the subdominant sits relative to the selected key.
  ///
  /// In en, this message translates to:
  /// **'{key} — one step counterclockwise'**
  String subdominantHint(String key);

  /// Explains where the dominant sits relative to the selected key.
  ///
  /// In en, this message translates to:
  /// **'{key} — one step clockwise'**
  String dominantHint(String key);

  /// Singular unit word for one sharp in a key signature summary.
  ///
  /// In en, this message translates to:
  /// **'sharp'**
  String get sharpSingular;

  /// Plural unit word for multiple sharps in a key signature summary.
  ///
  /// In en, this message translates to:
  /// **'sharps'**
  String get sharpPlural;

  /// Singular unit word for one flat in a key signature summary.
  ///
  /// In en, this message translates to:
  /// **'flat'**
  String get flatSingular;

  /// Plural unit word for multiple flats in a key signature summary.
  ///
  /// In en, this message translates to:
  /// **'flats'**
  String get flatPlural;

  /// Title for the reference chart of every major and minor chord.
  ///
  /// In en, this message translates to:
  /// **'All Major & Minor Chords'**
  String get allChordsTitle;

  /// One-line description shown under the All Chords entry on the resources list.
  ///
  /// In en, this message translates to:
  /// **'Every major and minor chord in standard tuning, shown the same way as the chord chart editor'**
  String get allChordsSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
