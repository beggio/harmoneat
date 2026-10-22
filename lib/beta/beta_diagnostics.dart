import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

/// Basic, non-identifying diagnostic context attached to every beta
/// submission (feedback, crash report, usage summary) — app version, OS
/// name/version, and CPU architecture, so a report is traceable to a
/// build and a machine class without collecting anything about the
/// tester themselves.
class BetaDiagnostics {
  const BetaDiagnostics({
    required this.appVersion,
    required this.platform,
    required this.osVersion,
    required this.architecture,
  });

  final String appVersion;
  final String platform;
  final String osVersion;
  final String architecture;

  static Future<BetaDiagnostics> gather() async {
    final info = await PackageInfo.fromPlatform();
    return BetaDiagnostics(
      appVersion: '${info.version}+${info.buildNumber}',
      platform: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      // `Abi.current()` (dart:ffi) is the one place the Dart SDK exposes
      // CPU architecture directly — e.g. "windowsX64", "macosArm64".
      architecture: Abi.current().toString(),
    );
  }

  Map<String, String> toFields() => {
    'App version': appVersion,
    'Platform': platform,
    'OS version': osVersion,
    'Architecture': architecture,
  };
}
