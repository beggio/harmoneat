import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'beta_config.dart';

/// Posts beta-testing submissions (feedback, crash reports, usage
/// summaries) to the configured Discord webhook, formatted as a Discord
/// embed (Discord's webhook API only renders its own documented fields —
/// `content`/`embeds`/etc — so this isn't a generic JSON payload).
///
/// If the request fails (offline, webhook down) the submission is
/// appended to a local `beta_submissions.log` file instead of being lost,
/// so nothing a tester sends evaporates just because they're offline at
/// the time.
class BetaWebhookClient {
  const BetaWebhookClient();

  Future<bool> send({
    required String title,
    required String description,
    required Map<String, String> fields,
  }) async {
    if (!kBetaBuild || kFeedbackWebhookUrl.isEmpty) return false;

    final embed = {
      'title': title,
      'description': description,
      'color': 0x5865F2,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'fields': [
        for (final entry in fields.entries)
          {'name': entry.key, 'value': entry.value, 'inline': true},
      ],
    };

    try {
      final response = await http
          .post(
            Uri.parse(kFeedbackWebhookUrl),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'embeds': [embed],
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
    } catch (_) {
      // Fall through to the local save below.
    }

    await _saveLocally(title: title, description: description, fields: fields);
    return false;
  }

  Future<void> _saveLocally({
    required String title,
    required String description,
    required Map<String, String> fields,
  }) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'beta_submissions.log'));
      final line = jsonEncode({
        'title': title,
        'description': description,
        'fields': fields,
        'savedAt': DateTime.now().toIso8601String(),
      });
      await file.writeAsString('$line\n', mode: FileMode.append);
    } catch (_) {
      // Best-effort only — nothing else we can do if even the local
      // disk write fails.
    }
  }
}
