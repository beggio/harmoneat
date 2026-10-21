import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../data/providers.dart';

final notesListProvider = StreamProvider.autoDispose<List<Note>>((ref) {
  return ref.watch(notesRepositoryProvider).watchAll();
});
