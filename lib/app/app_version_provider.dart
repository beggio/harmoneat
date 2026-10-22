import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The installed build's version string (e.g. "1.0.0+1") — used by the
/// splash screen to detect "a new version was just installed" and by
/// beta diagnostics (`lib/beta/beta_diagnostics.dart`).
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version}+${info.buildNumber}';
});
