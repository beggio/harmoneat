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

- **"Chord" button in the note-detail toolbar — chord chart editor.** Tapping it
  creates a new blank guitar chord chart (chord diagram notation — see
  https://www.libertyparkmusic.com/read-guitar-chord-diagrams/ for the format: a small
  grid of vertical strings and horizontal frets, with dots marking where fingers go and
  markers for open/muted strings). Users need to add individual notes and chords to it,
  and change, edit, delete, and add further charts for the same note. This is Phase 3
  of the original roadmap (`chord_charts` table already FK'd to `parts` in the schema;
  plan called for a hand-rolled `CustomPainter` editor/renderer rather than a
  third-party package) — this entry is the concrete trigger to build it, alongside the
  "Tab" entry above for Phase 4.

- **"Notation" button in the note-detail toolbar — standard notation editor.** Tapping it
  creates a new blank standard notation sheet. Users need to add individual notes and
  chords to it, and change, edit, delete, and add further sheets for the same note. This
  is Phase 5 of the original roadmap, the hardest of the three content-block phases — the
  plan called for spiking `crisp_notation` first (checking whether its model supports
  authoring, not just display, and confirming its bundled Bravura SMuFL font's OFL license
  is acceptable) before committing, with a constrained hand-rolled `CustomPainter` renderer
  (single clef, simple rhythms) as the fallback if that spike fails. The `notations` table
  is already FK'd to `parts` in the schema — this entry is the concrete trigger to build
  it, alongside the "Tab" and "Chord" entries above for Phases 3-4.

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
