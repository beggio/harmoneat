# Beta testing

HarmoNeat has a beta-only feedback/crash-reporting/usage-tracking system
(`lib/beta/`) that's entirely absent from production builds — not just
disabled at runtime. It's gated by a compile-time flag
(`bool.fromEnvironment('BETA_BUILD')`), so a normal `flutter build` never
includes this code after tree-shaking.

## What it collects

All of it posts to a Discord webhook as an embed, with a local-file
fallback (`beta_submissions.log` in the app's support directory) if the
request fails — nothing a tester sends is lost just because they're
offline.

- **Feedback**: a "Send Feedback" entry on the Settings screen (only
  visible in beta builds) opens a text box; submitting sends the message
  plus app version, platform, and the usage summary below.
- **Crash reports**: uncaught exceptions are caught automatically
  (`lib/beta/crash_reporter.dart`) and reported the same way — no action
  needed from the tester.
- **Usage summary**: lightweight local counters
  (`lib/beta/usage_tracker.dart`) for how many tabs/chord
  charts/notation sheets/notes a tester creates, attached to every
  feedback/crash submission for context.

## Building a beta package

1. Copy `beta.local.json.example` to `beta.local.json` (gitignored —
   never commit it) and fill in your webhook URL.
2. Run `scripts/build_beta.ps1` from the repo root (or `powershell -File
   scripts\build_beta.ps1`). It builds a Windows release with
   `BETA_BUILD=true` and the webhook URL compiled in, then zips
   `build\windows\x64\runner\Release` into `dist\harmoneat-beta-<timestamp>.zip`.
3. Send that zip to testers. They unzip it and run `harmoneat.exe` — no
   installer.

A production build is just the normal `flutter build windows` (or any
other platform) with no `--dart-define` flags — the beta system is
compiled out entirely.
