import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../platform/app_directories.dart';
import 'database/database.dart';
import 'repositories/attachments_repository.dart';
import 'repositories/chord_charts_repository.dart';
import 'repositories/guitar_tabs_repository.dart';
import 'repositories/notes_repository.dart';

final appDirectoriesProvider = Provider<AppDirectories>(
  (ref) => const AppDirectories(),
);

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(appDirectoriesProvider),
  );
});

final attachmentsRepositoryProvider = Provider<AttachmentsRepository>((ref) {
  return AttachmentsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(appDirectoriesProvider),
  );
});

final guitarTabsRepositoryProvider = Provider<GuitarTabsRepository>((ref) {
  return GuitarTabsRepository(ref.watch(appDatabaseProvider));
});

final chordChartsRepositoryProvider = Provider<ChordChartsRepository>((ref) {
  return ChordChartsRepository(ref.watch(appDatabaseProvider));
});
