import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmoneat/app/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'starts unacknowledged, then persists across a fresh container',
    () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(splashAcknowledgedVersionProvider), isNull);
      // Let the provider's initial (fire-and-forget) load settle before
      // calling a setter, so the two can't race.
      await Future<void>.delayed(Duration.zero);
      expect(container.read(splashAcknowledgedVersionProvider), isNull);

      await container
          .read(splashAcknowledgedVersionProvider.notifier)
          .acknowledge('1.0.0+1');
      expect(container.read(splashAcknowledgedVersionProvider), '1.0.0+1');

      // A later launch is a fresh container reading the same persisted
      // preferences — this is what lets the splash gate recognize "this
      // version was already suppressed" on the next run.
      final laterContainer = ProviderContainer();
      addTearDown(laterContainer.dispose);
      laterContainer.read(splashAcknowledgedVersionProvider);
      await Future<void>.delayed(Duration.zero);
      expect(laterContainer.read(splashAcknowledgedVersionProvider), '1.0.0+1');
    },
  );

  test('a different version is not considered acknowledged', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(splashAcknowledgedVersionProvider);
    await Future<void>.delayed(Duration.zero);

    await container
        .read(splashAcknowledgedVersionProvider.notifier)
        .acknowledge('1.0.0+1');

    expect(container.read(splashAcknowledgedVersionProvider), isNot('2.0.0+2'));
  });
}
