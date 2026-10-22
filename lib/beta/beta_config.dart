/// Compile-time flags for the beta-testing feedback/crash-log/usage-
/// tracking system. Both are resolved entirely at compile time (`const`
/// from `--dart-define`), so a production build that omits `BETA_BUILD`
/// never even includes this code after tree-shaking — not just a
/// disabled runtime toggle.
///
/// Build a beta test package with:
/// ```
/// flutter build windows --dart-define=BETA_BUILD=true \
///   --dart-define=FEEDBACK_WEBHOOK_URL=(webhook url)
/// ```
/// `scripts/build_beta.ps1` wraps this, reading the URL from a local,
/// gitignored `beta.local.json` so it's never typed on the command line
/// or committed to source control.
const kBetaBuild = bool.fromEnvironment('BETA_BUILD');
const kFeedbackWebhookUrl = String.fromEnvironment('FEEDBACK_WEBHOOK_URL');
