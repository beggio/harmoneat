import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../data/providers.dart';

final guitarTabsProvider = StreamProvider.autoDispose
    .family<List<GuitarTab>, String>((ref, noteId) {
      return ref.watch(guitarTabsRepositoryProvider).watchForNote(noteId);
    });

final guitarTabByIdProvider = StreamProvider.autoDispose
    .family<GuitarTab?, String>((ref, tabId) {
      return ref.watch(guitarTabsRepositoryProvider).watchById(tabId);
    });
