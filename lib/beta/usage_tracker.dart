import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme.dart';
import 'beta_config.dart';

const _usageCountersKey = 'betaUsageCounters';

/// Lightweight local counters for which features testers actually use
/// (e.g. how many tabs/charts/notation sheets they create) — not a
/// full analytics SDK, just enough to attach a usage summary to beta
/// feedback/crash submissions. Every call site that increments a counter
/// is gated by `kBetaBuild`, so in a production build the increments
/// (and this provider) are unreachable and tree-shaken out.
class UsageTrackerNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() {
    _load();
    return const {};
  }

  Future<void> _load() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final stored = prefs.getString(_usageCountersKey);
    if (stored != null) {
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      state = decoded.map((key, value) => MapEntry(key, value as int));
    }
  }

  Future<void> increment(String counterName) async {
    if (!kBetaBuild) return;
    state = {...state, counterName: (state[counterName] ?? 0) + 1};
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_usageCountersKey, jsonEncode(state));
  }

  String summaryText() {
    if (state.isEmpty) return '(no usage recorded yet)';
    final entries = state.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }
}

final usageTrackerProvider =
    NotifierProvider<UsageTrackerNotifier, Map<String, int>>(
      UsageTrackerNotifier.new,
    );
