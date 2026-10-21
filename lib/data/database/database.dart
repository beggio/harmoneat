import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'tables/attachments_table.dart';
import 'tables/instruments_table.dart';
import 'tables/notes_table.dart';
import 'tables/parts_table.dart';

export 'tables/attachments_table.dart';
export 'tables/instruments_table.dart';
export 'tables/notes_table.dart';
export 'tables/parts_table.dart';

part 'database.g.dart';

const guitarInstrumentId = 'instrument-guitar';

@DriftDatabase(tables: [Notes, Attachments, Instruments, Parts])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedGuitarInstrument();
    },
  );

  Future<void> _seedGuitarInstrument() {
    return into(instruments).insert(
      InstrumentsCompanion.insert(
        id: guitarInstrumentId,
        name: 'Guitar',
        tuning: const Value('EADGBE'),
        supportsTab: const Value(true),
        supportsChordChart: const Value(true),
        supportsNotation: const Value(true),
      ),
    );
  }

  /// Creates a note together with its hidden default "Guitar" part.
  Future<String> createNote({String title = ''}) async {
    final noteId = const Uuid().v4();
    final now = DateTime.now();
    await into(notes).insert(
      NotesCompanion.insert(
        id: noteId,
        title: Value(title),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await into(parts).insert(
      PartsCompanion.insert(
        id: const Uuid().v4(),
        noteId: noteId,
        instrumentId: guitarInstrumentId,
        position: const Value(0),
      ),
    );
    return noteId;
  }
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'harmoneat.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
