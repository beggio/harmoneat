import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../data/providers.dart';

final notationSheetsProvider = StreamProvider.autoDispose
    .family<List<NotationSheet>, String>((ref, noteId) {
      return ref.watch(notationSheetsRepositoryProvider).watchForNote(noteId);
    });

final notationSheetByIdProvider = StreamProvider.autoDispose
    .family<NotationSheet?, String>((ref, sheetId) {
      return ref.watch(notationSheetsRepositoryProvider).watchById(sheetId);
    });
