import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../data/providers.dart';

final attachmentsProvider = StreamProvider.autoDispose
    .family<List<Attachment>, String>((ref, noteId) {
      return ref.watch(attachmentsRepositoryProvider).watchForNote(noteId);
    });
