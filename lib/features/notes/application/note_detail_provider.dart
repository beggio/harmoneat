import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../data/providers.dart';

final noteDetailProvider = StreamProvider.autoDispose.family<Note?, String>((
  ref,
  noteId,
) {
  return ref.watch(notesRepositoryProvider).watchById(noteId);
});
