# Backlog

## Fixed

- **~~Record button captures nothing from the system microphone~~ — was a display bug,
  not a capture bug (resolved 2026-10-21).** Inspected a recorded file's raw bytes
  directly (`C:\Users\beggi\OneDrive\Documents\attachments\*.wav`): valid WAV header,
  correct `RIFF`/`fmt`/`data` chunk sizes, ~1.7MB of real non-silent 16-bit PCM samples
  (~10s at 44.1kHz stereo) — the microphone was being captured correctly the whole time.
  Root cause was in the UI: `_AttachmentListItem` only loaded a file's real duration
  once the user tapped Play, so every unplayed attachment showed a bare "0:00" that
  looked exactly like an empty recording. Fixed by having
  `AudioPlaybackController.preload()` fetch duration metadata eagerly (no playback
  started) as soon as the list item mounts, and by changing the default-encoder from
  AAC to `AudioEncoder.wav` (ruling out a separate theoretical risk: Windows' AAC
  encoder MFT isn't guaranteed present on every machine).
  - Also noticed along the way: `path_provider`'s "Documents" directory on this machine
    resolves to the OneDrive-redirected path
    (`C:\Users\beggi\OneDrive\Documents\attachments`), not the raw profile Documents
    folder — not a bug, just worth knowing when looking for recorded files by hand.

- **~~Enter/edit free-text note body~~ (shipped 2026-10-21).** Added a "Text" tab
  (`lib/features/notes/presentation/note_body_tab.dart`) alongside Attachments on the
  note detail screen, wired to a new `NotesRepository.updateBody` method with a
  500ms-debounced autosave (not on every keystroke).

## Bugs

## Features

- **~~UI toolbar for note-detail actions~~ (shipped 2026-10-21).** Added
  `lib/features/notes/presentation/note_detail_toolbar.dart` — a persistent bar between
  the TabBar and TabBarView on the note detail screen, visible regardless of which tab
  is active. Moved Record/Import out of `AttachmentsTab` into it, so future
  chord-chart/tab/notation actions have a shared place to live too.

- **~~Cloud-storage notice for audio files, as an acknowledgement dialog~~ (shipped
  2026-10-21).** Added `AppDirectories.detectCloudSyncProvider()`
  (`lib/platform/app_directories.dart`) to detect OneDrive/Dropbox/iCloud Drive folder
  segments in the resolved documents path, and a `cloudStorageAcknowledgedProvider`
  (`lib/app/theme.dart`, backed by `shared_preferences`) to remember whether the user's
  dismissed the notice. `NoteDetailToolbar._maybeShowCloudStorageNotice` shows a dialog
  the first time Record or Import is tapped when a cloud provider is detected and the
  notice hasn't been acknowledged, with a "Don't show this again" checkbox (checked by
  default) controlling whether the acknowledgement is persisted.

- **"Tab" button in the note-detail toolbar — guitar tab editor.** Tapping it creates a
  new blank guitar tab (standard tablature notation — see
  https://eddiesguitars.com/what-is-guitar-tablature/ for the format: six horizontal
  lines per string, fret numbers placed on them to show individual notes and chords
  read left to right). Users need to add individual notes and chords onto the tab, and
  change, edit, delete, and add further tabs for the same note. This is Phase 4 of the
  original roadmap (`chord_chart`/`tabs`/`notation` tables already FK'd to `parts` in
  the schema; plan called for a hand-rolled `CustomPainter` editor/renderer rather than
  a third-party package) — this entry is the concrete trigger to build it.

- **~~"Chord" button in the note-detail toolbar — chord chart editor~~ (shipped
  2026-10-22).** Tapping it creates a blank chord chart and opens
  `lib/features/chord/presentation/chord_editor_screen.dart`: an ordered, horizontally
  scrollable sequence of named chord diagrams (`ChordChartData`/`ChordDiagram`/
  `ChordString` in `chord_chart_data.dart`), each rendered as a standard diagram —
  vertical string lines, horizontal fret lines via `ChordDiagramPainter`, "O"/"X"
  markers above the nut for open/muted strings, and colored dots for fretted notes with
  the same optional 1-5 finger assignment and tuning dropdown (E / E♭ / Drop D) as the
  Tab editor. New `chord_charts` Drift table (schema v3) FK'd to `parts`, mirroring
  `guitar_tabs`; a "Chords" list tab was added to the note detail screen alongside
  Tabs, and note deletion now cascades to chord charts too. Follow-up mods
  (2026-10-22): each diagram has a `baseFret` (default 0 = the nut; shown as "0fr",
  editable via a button next to the chord name) so barre shapes can be drawn higher up
  the neck without the nut emphasis; a `capoFret` dropdown per chart (next to Tuning);
  open/fretted markers on the low/high edge strings no longer get clipped (added
  `edgePadding` margin around the grid); and the O/X mute marker is now a visibly
  bordered, always-tappable box above each string.

- **~~"Notation" button in the note-detail toolbar — standard notation editor~~ (shipped
  2026-10-22).** Researched `crisp_notation` (pub.dev) before committing, per the
  original plan: MIT/OFL, hit-testing/selection/drag support, but no documented
  authoring API and still an immature, low-adoption dependency — went straight to the
  plan's own fallback instead of spiking it live. Tapping Notation creates a blank sheet
  and opens `lib/features/notation/presentation/notation_editor_screen.dart`: a
  continuous treble-clef staff (`NotationStaffPainter`, hand-rolled `CustomPainter`, no
  SMuFL font) rendering a flat, ordered sequence of notes/rests
  (`NotationSheetData`/`NotationEvent`/`Pitch` in `notation_sheet_data.dart`) with
  correct note-head shapes (open for whole/half, filled for quarter/eighth + flag),
  duration-proportional spacing, ledger lines, engraving-correct stem direction (above
  the middle line down, at/below it up — verified against real engraving references,
  see `staff_geometry.dart`), and a time-signature selector that places barlines by
  cumulative beats (no key signatures or chords — scoped to single clef, single-note
  melodic line, simple rhythms, consistent with the plan's stated fallback). New
  `notation_sheets` table (schema v4), mirroring `guitar_tabs`/`chord_charts`; a
  "Notation" list tab was added to the note detail screen, and note deletion cascades
  to notation sheets too. The now-redundant `ComingSoonScreen` placeholder (no toolbar
  button pointed at it anymore) was deleted.

- **~~Accessibility/appearance settings: large-print toggle, substitute monospace
  default font, and four selectable color schemes~~ (shipped 2026-10-22).** Added a
  Settings destination to the nav shell (`lib/features/settings/presentation/
  settings_screen.dart`) with a large-print switch (drives the existing
  `textScaleProvider` to 1.3x) and a radio list for `AppColorScheme`
  (`lib/app/color_schemes.dart`): Light, Dark High Contrast (Windows' High Contrast
  Black palette), Dark Modern (Windows 11 dark mode), and Urban Camo (olive/khaki/tan).
  Replaced the old unused `ThemeModeNotifier`/`AccentColorNotifier` scaffolding in
  `lib/app/theme.dart` with a single persisted `appColorSchemeProvider`. Andale Mono
  itself is a licensed Monotype font Flutter can't reference by OS name — substituted
  JetBrains Mono (via the `google_fonts` package) as the default UI font everywhere
  until a licensed Andale Mono file is supplied to swap in.

- **~~Resources section + first resource: interactive Circle of Fifths~~ (shipped
  2026-10-22).** Added a third nav destination, `lib/features/resources/`, for
  standalone reference tools independent of any note (unlike Tab/Chord/Notation).
  Researched the circle before building it: order of sharps (F C G D A E B, clockwise)
  and flats (B E A D G C F, counterclockwise) verified against Open Music Theory;
  relative minor = major scale's 6th degree, same key signature, shown on an inner
  ring. `circle_of_fifths_data.dart` derives each key's specific accidentals
  programmatically from the verified sharp/flat order rather than a hand-typed table
  (covered by `circle_of_fifths_data_test.dart`). The interactive diagram
  (`circle_of_fifths_screen.dart`) arranges 12 major/minor button pairs by trigonometry
  around two rings; selecting a key also highlights its dominant (V, one step
  clockwise) and subdominant (IV, one step counterclockwise) and shows the key
  signature in a details panel below.

- **~~Second resource: every major and minor chord, reference chart~~ (shipped
  2026-10-22).** Researched the standard construction before building it: the two
  movable barre shapes (E-shape, rooted on the low E string; A-shape, rooted on the A
  string, low E muted) verified against documented formulas, each confirmed with a
  minor variant that lowers the third by one fret. 8 of the 24 chords (C/D/E/G/A
  major, A/D/E minor) use their standard open-position fingerings instead, since
  that's how they're actually played/taught, not the barre equivalent.
  `all_chords_data.dart` generates all 24 from just those two shape formulas plus the
  8 open shapes (covered by `all_chords_data_test.dart`, including a check that
  shifting a barre shape up one fret shifts every real fret by exactly one). Renders
  via a new `ChordDiagramPreview` widget (`lib/features/resources/presentation/`) that
  reuses the chord editor's own `ChordDiagramPainter` directly — same look, same
  finger-color legend — just without the tap-to-edit interactivity.

- **~~Beta-testing feedback/crash/usage collection + packaging~~ (shipped
  2026-10-22).** Added `lib/beta/`, gated entirely by a compile-time
  `bool.fromEnvironment('BETA_BUILD')` constant — a production build with no
  `--dart-define` flags tree-shakes the whole system out, not just hides it at
  runtime. In a beta build: a "Send Feedback" entry on Settings, automatic uncaught-
  exception reporting (`crash_reporter.dart`), and local usage counters
  (`usage_tracker.dart`, incremented at note/tab/chord-chart/notation-sheet creation)
  attached to every submission. Everything posts to a Discord webhook as an embed
  (`beta_webhook_client.dart`), falling back to a local `beta_submissions.log` file on
  failure so nothing's lost offline. `scripts/build_beta.ps1` builds a release Windows
  package with the flag and webhook URL (read from the gitignored `beta.local.json`,
  never committed) baked in, then zips it to `dist/` for sending to testers — see
  `BETA_TESTING.md`. Tests lock in that the whole system is genuinely inert without
  the build flag (`test/beta/beta_gating_test.dart`): no network calls, no counter
  writes.

- **~~Splash screen (app name/version, pre-production disclaimer, feedback
  instructions) on launch~~ (shipped 2026-10-22).** `SplashGate`
  (`lib/app/splash_gate.dart`) sits in front of `AppShell` as the app's `home`:
  compares the installed version (`app_version_provider.dart`, via
  `package_info_plus`) against the last version the splash was suppressed for
  (`splashAcknowledgedVersionProvider` in `theme.dart`, persisted). It always shows at
  least once per version; a "don't show this again for this version" checkbox
  (default checked) suppresses it for *later* launches of that same version only — a
  new version always shows it again regardless of a prior suppression. Feedback
  instructions on the splash point to Settings → Send Feedback in a beta build, or a
  generic message otherwise, since that button doesn't exist outside one. Covered by
  `test/app/splash_acknowledged_version_test.dart`; `test/widget_test.dart` updated to
  dismiss the splash before asserting on the notes list.

- **~~Real logo in the splash screen and a small version in the app headers~~ (shipped
  2026-10-22).** The user provided the HarmoNeat wordmark logo as PNG/GIF/TIFF
  exports; used the PNG (the only one of the three Flutter's image decoder actually
  supports — TIFF isn't decodable at all, GIF would've meant a lossy 256-color
  palette for a smooth gradient mark). Generated `assets/images/logo_icon.png` by
  cropping just the swirl/treble-clef mark out of the full wordmark (excluding the
  "HarmoNeat"/"Caporio Software" text, illegible at header-icon size) with a one-off
  script using the `image` pub package, added as a leading icon on the Notes/
  Resources/Settings AppBars (`AppLogoIcon`, `lib/app/app_logo_icon.dart`) — removed
  the script and temporary dependency once the crop looked right. Follow-up: the user
  then added an animated GIF version of the logo reveal
  (`assets/images/splash_animation.gif`); swapped it in as the splash screen's hero
  image in place of the static PNG — Flutter's `Image` widget animates multi-frame
  GIFs with no extra plumbing needed.

- **~~"HarmoNeat" color scheme, derived from the logo's own palette~~ (shipped
  2026-10-22).** Added a 5th `AppColorScheme` (`lib/app/color_schemes.dart`) sampled
  directly from pixel colors in the logo artwork (via a one-off script, removed after)
  rather than eyeballed: dark navy background (`#0A0F1A`), the swirl's cyan
  (`#2ED3DF`) as primary and its gold (`#F9DB93`) as secondary, near-white text
  (`#ECEFF4`), with a muted teal (`#3F9A9B`) sampled from the swirl itself for
  outlines. Selectable from Settings alongside Light/Dark High Contrast/Dark Modern/
  Urban Camo. Follow-up: made it the default scheme for new installs (previously
  Light), in `AppColorSchemeNotifier.build()` and its corrupt-data fallback.

- **~~First packaged test distribution~~ (shipped 2026-10-22).** Added
  `TESTER_README.md` (pre-production disclaimer, how to run it with no installer,
  how to send feedback, what to try) and updated `scripts/build_beta.ps1` to bundle
  it into the zip as `README.md` (staged in a temp folder first, so it doesn't end
  up sitting in the actual Flutter build output directory). Ran the script to build
  `dist/harmoneat-beta-20261022-132654.zip` (31.7MB, release Windows build with the
  beta feedback/crash/usage system compiled in) and smoke-tested the extracted
  `harmoneat.exe` standalone — launches and stays running outside of `flutter run`,
  confirming the packaged build is actually viable, not just the dev-mode one.
