import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

import 'app/app.dart';
import 'beta/beta_config.dart';
import 'beta/crash_reporter.dart';
import 'beta/usage_tracker.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux) {
    JustAudioMediaKit.ensureInitialized(windows: true, linux: true);
  }

  // A manually created container (rather than a plain `ProviderScope`) so
  // the crash reporter can read the usage-tracker provider before
  // `runApp` — the same container is then handed to the widget tree via
  // `UncontrolledProviderScope` so both share the same state. Only
  // reachable in beta builds; see `beta/beta_config.dart`.
  final container = ProviderContainer();
  if (kBetaBuild) {
    installBetaCrashReporter(container.read(usageTrackerProvider.notifier));
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const HarmoNeatApp(),
    ),
  );
}
