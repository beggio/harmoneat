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

- **~~Guitar chord playback rings at the end of the note instead of cutting off
  cleanly~~ (resolved 2026-10-23).** Reported by the
  user after confirming the piano/guitar/voice silence fix; re-confirmed
  afterward that piano and voice both stop cleanly and only guitar rings.
  Investigated via a throwaway diagnostic (`flutter test` loading the real
  bundled `.sf2` and dumping every bank-0 guitar-family preset's zone data):
  found **no structural difference** between guitar/piano/choir — all three use
  continuously-looping sample zones, and the existing stop path
  (`SoundFontPlayer.stopMixerOutput()` → `allNotesOff(releaseDuration: Duration.zero)`
  → an immediate `SoLoud.stop()` per handle) should hard-kill every instrument's
  voices identically. Most likely explanation: a real recorded guitar pluck has
  an audible, resonant decay baked into the sample itself, and SoLoud's abrupt
  amplitude cutoff on that kind of waveform is what reads as a "ring" — piano/
  choir samples apparently don't have the same audible artifact when cut the
  same way.
  - **Fix applied**: `SoundfontChordSoundEngine.stop()` now branches on
    instrument — any guitar variant fades to silence over 1.5s via
    `SoundFontPlayer.allNotesOff(releaseDuration: Duration(milliseconds: 1500))`
    (the library's own envelope-release fade, not an abrupt stop) instead of
    `stopMixerOutput()`'s hard cut; piano/choir keep the instant stop since
    they weren't reported as ringing.
  - **User listening test (2026-10-23) — result**: with the fade applied to all
    8 GM guitar-family programs, only **Steel String (25), Overdrive (29), and
    Distortion (30)** actually end cleanly — Nylon (24, the original default),
    Jazz (26), Clean (27), Palm Muted (28), and Harmonics (31) still ring even
    with the same 1.5s fade. This is a real datapoint for eventually fixing the
    other five: whatever makes Steel/Overdrive/Distortion's samples cut cleanly
    isn't just "has a fade" (all 8 had one) — it's something about those three
    samples specifically (worth comparing their zone/envelope data again
    against the five that still ring, next time this gets picked back up).
  - **Removed from the selectable instrument list** (2026-10-23): Nylon, Jazz,
    Clean, Palm Muted, and Harmonics — `ChordInstrumentSound` now only offers
    Steel/Overdrive/Distortion as guitar options; Steel is the new default
    (replacing Nylon). Not deleted from scope — see the "offer every guitar
    option" feature below, which this bug's resolution is blocked on.
  - Choir also switched to the same 1.5s fade-to-zero on stop (previously
    instant-stop like piano) to eliminate its own harsh cutoff — not a ring
    like guitar, just an abrupt end.
  - **Reopened (2026-10-23, same day) — fade did not actually fix it.** Fresh
    listening test on the rebuilt app (Steel/Overdrive/Distortion guitars +
    choir, all with the 1.5s fade) found **all four still exhibit the noise
    at the end of playback**; piano does not and never has. This means the
    round-2 "Steel/Overdrive/Distortion end cleanly" result did not hold up
    under further listening — treat that earlier finding as superseded.
    User's hypothesis was that this is a looping artifact (guitar/choir loop,
    piano supposedly doesn't). **That's not supported by the evidence
    already gathered**: the zone-data diagnostic above found piano *also*
    uses continuous looping with valid loop points — so looping alone can't
    be what distinguishes piano from the others. The one real difference
    that does line up with the data: piano has always used the instant
    `stopMixerOutput()` hard-stop and has never rung, while guitar and choir
    are the only two instruments routed through the 1.5s
    `allNotesOff(releaseDuration:)` fade path — and both still ring with it.
    That correlation (fade/release path present → noise present) is a better
    fit than looping, but is itself unconfirmed at the code level — no root
    cause has actually been isolated yet. Next time this is picked up: try
    reverting the fade and hard-stopping guitar/choir exactly like piano to
    see if the noise disappears or is unrelated to the fade mechanism
    entirely.
  - **Resolved (2026-10-23, same day).** Tried the hard-stop experiment:
    reverted guitar/choir to the exact same instant `stopMixerOutput()` path
    piano has always used. Result was initially reported as "still noisy,
    same as before" — but on further listening with every instrument
    hard-stopped identically, the user confirmed they all sound correct.
    This rules out the stop mechanism (fade vs. instant) as the cause
    either way, since both produced the same result. Kept the hard stop for
    all instruments (removed the now-pointless 1.5s fade code entirely —
    see `SoundfontChordSoundEngine.stop()`) since it's simpler and sounds
    the same as the fade did. See the new "less terse end-of-playback"
    feature below for the actual remaining ask (abrupt-but-correct vs.
    smooth).

- **Find a genuinely less terse way to end chord playback.** All instruments
  currently hard-stop instantly (`SoundFontPlayer.stopMixerOutput()`) — this
  is correct/acceptable per the user's listening test (2026-10-23), but it's
  still an abrupt cutoff rather than a natural-sounding end. A naive 1.5s
  linear release fade (`allNotesOff(releaseDuration:)`) was tried and made no
  audible difference, so simply re-adding that isn't the fix — worth
  investigating a shorter/differently-shaped envelope, or whether the
  perceived abruptness is actually about *when* in the waveform playback
  stops (e.g. not at a zero-crossing) rather than *how fast* it fades.

- **Offer every GM guitar-family program as a chord-playback option, gated on
  audio quality.** Feature, not yet done: Nylon, Jazz, Clean, Palm Muted, and
  Harmonics were removed from the instrument picker above because they still
  ring at the end of playback even with a 1.5s fade-to-zero; Steel, Overdrive,
  and Distortion don't. The goal remains having all 8 bank-0 guitar programs
  selectable, but each one only goes back in once its audio actually ends
  cleanly — re-add individually as each is fixed, not as a block.

- **Source a real female-voice soundfont.** Feature, not yet done: the
  "Choir" chord-playback option (`ChordInstrumentSound.choir`) is General
  MIDI's "Choir Aahs" — a mixed-voice patch, not a true female voice. Renamed
  from "Female Voice" to "Choir" (2026-10-23) so the label matches what it
  actually is instead of overclaiming. Needs an actual female-voice sample
  library sourced and bundled (same build-time-fetch mechanism as the main
  soundfont, if it's large) before a real "Female Voice" option can return.

- **~~Chord playback sounds wrong on piano/guitar, and (separately) all three
  instruments went silent~~ (fixed 2026-10-23, confirmed by user re-test — all three
  instruments now play correctly).** Two distinct, now-fixed bugs stacked on top of
  each other:
  1. **Bank-vs-program mismatch.** Guitar was silent; piano played a fixed
     drum-like sound regardless of pitch. Confirmed with real data — a throwaway
     `flutter test` loaded the bundled soundfont and printed its preset table
     (plain `dart run` can't do this: `soundfont_kit` transitively needs `dart:ui`,
     Flutter-only). Found `bank=128 program=0 "Standard"` (a drum kit) sorting
     *before* `bank=0 program=0 "Grand Piano"`, and `bank=8 program=24 "Ukulele"`
     sorting before `bank=0 program=24 "Nylon String Guitar"`. The GM program
     lookup matched by `program` number only, not `bank`. Fixed by requiring
     `bank == 0` in `selectPreset` (`soundfont_chord_sound_engine.dart`), covered by
     `test/features/chord/soundfont_chord_sound_engine_test.dart` (fake presets, no
     real soundfont needed).
  2. **All three instruments then went totally silent after fix #1** — including
     female voice, which explains why it had been silent from the start; it was
     never a separate bug. Root cause confirmed via a side-by-side diagnostic
     (`flutter test` loading both the bundled `.sf3` and the raw `.sf2` and
     printing each sample's parsed loop points): `soundfont_kit` 1.1.1 mis-parses
     loop points for Ogg Vorbis-compressed (`.sf3`) samples — e.g. the guitar
     sample's `loopStart` came out as `-20043507` (should be `62185`, confirmed
     against the same sample in the uncompressed `.sf2`). It reuses the SF2
     header's raw `start`/`startloop` sample-point fields for ogg samples without
     converting compressed-byte offsets to decoded-PCM-frame offsets, so
     `SoLoud.playScheduled`'s loop-region validation threw
     `Invalid argument (loopingStartOffsetAt): Must not be negative` on every
     single note, for every instrument, every time. Fixed by switching the bundled
     soundfont from `assets/audio/MuseScore_General.sf3` (39.9MB, broken) to
     `assets/audio/MuseScore_General.sf2` (215MB, uncompressed, confirmed correct
     loop points) — `pubspec.yaml` and `soundfont_chord_sound_engine.dart` updated
     accordingly.

  **Consequence needing a decision**: the working `.sf2` is 215MB, over GitHub's
  100MB-per-file limit — committing it as a normal tracked file will be rejected.
  It needs Git LFS (already installed locally: `git-lfs/3.7.1`) tracking it before
  it can be committed/pushed. Not yet set up or committed — flagged here rather
  than done silently, since it's a standing repo-infrastructure change.
  Alternative, not yet attempted: trim the `.sf2` down to just the 3 GM programs
  actually used (guitar/piano/choir) with a soundfont editor (e.g. Polyphone) to
  get back under 100MB without needing LFS at all — deferred since no such tool is
  set up in this environment yet.

## Features

- **Add a Caporio Software copyright disclaimer to the splash screen and Settings
  page.** Likely a small static text addition near the existing splash branding
  (`lib/` splash screen widget) and somewhere on `settings_screen.dart` (e.g. near
  the bottom, similar to an "About" footer) — exact wording/placement not yet
  decided. Confirmed still absent from the splash screen as of 2026-10-23 (never
  implemented, not a regression) — this item being unresolved is why; it will stay
  absent in a production build too until it's actually built, since a release
  build just compiles whatever's in the source.

- **Lyric authoring tool, styled like a Markdown wiki's code block.** A new content
  type for a note's Text tab: a distinct "lyric block" that visually stands apart
  from surrounding plain text — similar to how a fenced code block is set off from
  prose in a Markdown wiki — rather than just another paragraph. Visual direction:
  looks like a sheet of paper floating over the rest of the note, with a drop
  shadow, not just a background-color/border treatment. Needs its own editing
  affordance (inserting/removing a lyric block within `note_body_tab.dart`'s text,
  or a new sibling block type) and rendering; scope/data model not yet decided —
  whether it's inline Markdown-style syntax inside the existing note body or a
  separate structured block (more consistent with how Chord/Tab/Notation are their
  own tables) is an open design question.

- **Major UI aesthetic/style pass before production.** Current UI is functional and
  good enough for testing (stock Material 3 widgets, default spacing/elevation,
  minimal custom styling beyond the color schemes and font choice) but needs a real
  beautification/polish pass before shipping — layout, spacing, iconography,
  animations/transitions, and overall visual identity, not just color/font, across
  every screen (Notes, note detail tabs, Chord/Tab/Notation editors, Resources,
  Settings). Scope and specific direction not yet decided.

- **Show a version indicator in the bottom-right corner of the Settings page.**
  The app version is already read via `package_info_plus` for the splash screen's
  version check (`app_version_provider.dart`) — reuse that provider to render a
  small, unobtrusive label (e.g. `v1.0.0+3`) anchored to the bottom-right of
  `settings_screen.dart` rather than fetching it separately.

- **Import tablature from a standard file format.** Investigate whether there's a
  widely-used tab file format worth supporting (e.g. Guitar Pro's `.gp*`/`.gpx`,
  the plain-text ASCII-tab convention, or MusicXML's tablature support) and, if
  one exists with a tractable parser, add an import path into a note's Tab
  editor (`lib/features/tab/`) alongside the existing manual tab-entry flow —
  so a tab doesn't have to be hand-typed if the user already has a file for it.

- **Security test framework to catch committed credentials, PII, or webhook URLs.**
  The beta-testing webhook URL is already handled by convention
  (`beta.local.json`, gitignored, with a `.example` template — see
  `scripts/build_beta.ps1`), but that relies on every contributor following the
  convention by hand. Add an automated check (e.g. a pre-commit hook and/or a
  CI/test-suite step using a secret-scanning tool or a small custom regex scan)
  that fails if a commit/PR introduces anything that looks like an API key,
  webhook URL, access token, or personally identifiable information, so a
  mistake doesn't depend on someone remembering to check `git status` by hand.

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

- **~~"Tab" button in the note-detail toolbar — guitar tab editor~~ (shipped, date not
  recorded — confirmed already built 2026-10-23).** Tapping it creates a new guitar
  tab and opens `lib/features/tab/presentation/tab_editor_screen.dart`, rendered via
  `tab_staff_painter.dart` (standard six-line tablature). Backed by
  `guitarTabsRepositoryProvider`/`guitar_tabs_provider.dart` and `tab_data.dart`, wired
  into the note-detail toolbar alongside Chord/Notation. This entry had been sitting in
  Features as "not yet built" past the point it actually shipped — corrected here
  rather than left stale.

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

- **~~Beta builds no longer share a database with the dev install~~ (shipped
  2026-10-22).** The first packaged build opened the same `harmoneat.sqlite` as the
  regular dev app (on Windows, `getApplicationSupportDirectory()` resolves by app
  identity, not by which copy of the exe is running), so the user's day-to-day test
  notes showed up in what was meant to be a fresh beta package. `_openConnection` in
  `lib/data/database/database.dart` now picks `harmoneat_beta.sqlite` instead of
  `harmoneat.sqlite` whenever `kBetaBuild` is true — a different file, so a beta
  build always starts genuinely empty, on this machine or any tester's. Verified by
  rebuilding the package and confirming the new file is freshly created at launch
  and byte-for-byte different from the dev database.
  - **Follow-up caveat (same day):** a re-test on this dev machine still showed an
    "Untitled note" after a brand-new extraction of the zip. Traced it by querying
    the beta database directly (`package:sqlite3`, no CLI tool needed) — the note
    was real, created during an earlier smoke-test run, and the zip itself contains
    no database file (confirmed via `unzip -l`). Root cause: `harmoneat_beta.sqlite`
    is keyed by app identity in `%APPDATA%`, not by which folder the zip was
    extracted to, so *any* beta build run previously on this same machine leaves
    behind a file that *every later* beta build here reuses — a fresh unzip looks
    like a fresh install but isn't, on a machine that's run one before. Deleted the
    stray file and confirmed a truly clean run shows no notes. Documented as a
    permanent caveat in `BETA_TESTING.md` (testing "does a new install start empty"
    needs either a different machine or deleting that file first).

- **~~Chord playback — "full audio sampling integration"~~ (shipped 2026-10-22).**
  Every chord diagram (both in the Chord editor and the read-only "All Chords"
  reference) now has a play button that plays its *actual fingered voicing* — e.g.
  open C major plays C, E, G, C, E (low to high), not an abstract "C major triad" —
  via `lib/features/chord/application/chord_pitch.dart`, pure-Dart chromatic MIDI
  math that also makes `capoFret` functional for the first time anywhere in the app
  (every sounding note raised by the capo's fret count). Guitar/Piano/Female Voice
  (GM Choir Aahs, the standard stand-in — no true "female voice" GM instrument
  exists) are selectable in Settings, default Guitar, persisted the same way as
  color scheme. **Spike outcome**: `soundfont_kit` (pure-Dart SF2/SF3 reader+player
  on `flutter_soloud`) checked out — its own official example app demonstrates
  exactly this polyphonic-chord use case (sequential `playPreset` calls that
  overlap/sustain together), confirmed against the actual package source (not just
  docs) for exact API names (`Preset`, not `SoundFontPreset`; `SoundFontFile.fromAsset`
  simpler than manual `rootBundle` loading). No fallback needed. Bundled asset: the
  user's own copy of MuseScore's MIT-licensed `MuseScore_General.sf3` (~40MB
  compressed; the 215MB uncompressed `.sf2` wasn't bundled, kept local only) — I
  can't autonomously download binary assets from unverified web sources, so asked
  the user to source it rather than guessing a download link. A real design decision
  (not previously documented anywhere): `baseFret`'s row-relative fret encoding
  (`ChordString.fret`) does **not** apply to open strings (`fret == 0`) — those are
  always absolute fret 0 regardless of `baseFret`, since they're drawn as "O" above
  the nut, not as a grid row; caught this via a dedicated test case before it could
  silently mis-price an edge-case voicing. Covered by
  `test/features/chord/chord_pitch_test.dart` (9 cases, including the open-C
  acceptance example, a capo case, Drop D, and the open-string-in-a-barre edge case).
  Caught and fixed two real bugs during integration: a `ChordPlaybackController`
  that called `ref.read` inside `onDispose` (Riverpod forbids this; only surfaced
  once a test actually used a real `ProviderScope` and tore it down), and a
  `RenderFlex` overflow from the new play button's default 48×48 tap target not
  fitting narrow diagram cards. **Not yet confirmed**: actual audio output — I
  cannot click buttons or hear sound myself; the app launches cleanly and all
  static/unit verification passes, but the real play-and-listen check is the user's
  to do.
