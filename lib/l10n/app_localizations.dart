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

  /// Shown on a stub screen for a toolbar action whose editor hasn't been implemented yet.
  ///
  /// In en, this message translates to:
  /// **'The {feature} editor isn\'t built yet — this button is a placeholder.'**
  String comingSoonMessage(String feature);

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
