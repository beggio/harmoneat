// Downloads large third-party binary assets that ship with the app but are
// not committed to git (see tool/external_assets.json for the manifest).
// Run with: dart run tool/fetch_assets.dart
//
// Safe to run on every build: an asset whose local file already matches the
// manifest's sha256 is skipped with no network call.
// ignore_for_file: avoid_print — this is a CLI script; print is the right tool.

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final manifestFile = File('tool/external_assets.json');
  final manifest = jsonDecode(await manifestFile.readAsString()) as Map;
  final assets = (manifest['assets'] as List).cast<Map>();

  var failed = false;
  for (final asset in assets) {
    final path = asset['path'] as String;
    final url = asset['url'] as String;
    final expectedSha256 = asset['sha256'] as String;
    final file = File(path);

    if (await file.exists() && await _sha256Of(file) == expectedSha256) {
      print('OK (cached): $path');
      continue;
    }

    print('Fetching: $path <- $url');
    try {
      await file.parent.create(recursive: true);
      final downloadPath = '$path.download';
      final downloadFile = File(downloadPath);

      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode} fetching $url');
      }
      await response.stream.pipe(downloadFile.openWrite());

      final actualSha256 = await _sha256Of(downloadFile);
      if (actualSha256 != expectedSha256) {
        await downloadFile.delete();
        throw Exception(
          'sha256 mismatch for $path: expected $expectedSha256, got $actualSha256',
        );
      }

      await downloadFile.rename(path);
      print('OK (downloaded): $path');
    } catch (e) {
      stderr.writeln('FAILED: $path — $e');
      failed = true;
    }
  }

  if (failed) exit(1);
}

Future<String> _sha256Of(File file) async {
  final digest = await sha256.bind(file.openRead()).first;
  return digest.toString();
}
