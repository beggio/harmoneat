import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'tables/attachments_table.dart';
import 'tables/chord_charts_table.dart';
import 'tables/guitar_tabs_table.dart';
import 'tables/instruments_table.dart';
import 'tables/notes_table.dart';
import 'tables/parts_table.dart';

export 'tables/attachments_table.dart';
export 'tables/chord_charts_table.dart';
export 'tables/guitar_tabs_table.dart';
export 'tables/instruments_table.dart';
export 'tables/notes_table.dart';
export 'tables/parts_table.dart';

part 'database.g.dart';

const guitarInstrumentId = 'instrument-guitar';

@DriftDatabase(
  tables: [Notes, Attachments, Instruments, Parts, GuitarTabs, ChordCharts],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedGuitarInstrument();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(guitarTabs);
      }
      if (from < 3) {
        await m.createTable(chordCharts);
      }
    },
  );

  /// The note's single, auto-created default part — every note has
  /// exactly one today (see `createNote` below), so this is the part any
  /// per-note musical content (tabs, and chord charts/notation in their
  /// own phases) attaches to.
  Future<String> defaultPartIdForNote(String noteId) async {
    final part = await (select(
      parts,
    )..where((pt) => pt.noteId.equals(noteId))).getSingle();
    return part.id;
  }

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
