import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../data/providers.dart';

final chordChartsProvider = StreamProvider.autoDispose
    .family<List<ChordChart>, String>((ref, noteId) {
      return ref.watch(chordChartsRepositoryProvider).watchForNote(noteId);
    });

final chordChartByIdProvider = StreamProvider.autoDispose
    .family<ChordChart?, String>((ref, chartId) {
      return ref.watch(chordChartsRepositoryProvider).watchById(chartId);
    });
