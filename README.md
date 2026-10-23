# harmoneat
Repository for the HarmoNeat app

## Setup

```
flutter pub get
dart run tool/fetch_assets.dart
flutter run -d windows
```

`fetch_assets.dart` downloads large third-party binary assets (currently the
bundled General MIDI soundfont) that are too large to commit to git — see
`tool/external_assets.json` for the manifest and
`lib/features/chord/application/soundfont_chord_sound_engine.dart` for what
uses it. Safe to re-run any time; it's a no-op if the local file already
matches the manifest's checksum.
