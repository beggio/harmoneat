import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmoneat/beta/beta_config.dart';
import 'package:harmoneat/beta/beta_webhook_client.dart';
import 'package:harmoneat/beta/usage_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // These run without `--dart-define=BETA_BUILD=true`, so kBetaBuild is
  // false here — exactly the production configuration. Every guarantee
  // below is what makes the feedback/crash/usage system genuinely inert
  // outside a beta build, not just hidden behind a runtime toggle.

  test('kBetaBuild and the webhook URL default off in a normal build', () {
    expect(kBetaBuild, isFalse);
    expect(kFeedbackWebhookUrl, isEmpty);
  });

  test('usage tracker increments are a no-op outside a beta build', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(usageTrackerProvider.notifier)
        .increment('note_created');

    expect(container.read(usageTrackerProvider), isEmpty);
  });

  test(
    'the webhook client never attempts a network call outside a beta build',
    () async {
      // If this weren't gated, it would try to POST to an empty URL and
      // throw/hang instead of returning promptly.
      final sent = await const BetaWebhookClient().send(
        title: 'test',
        description: 'test',
        fields: const {},
      );
      expect(sent, isFalse);
    },
  );
}
