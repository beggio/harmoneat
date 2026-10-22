import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../features/notation/application/notation_sheet_data.dart';
import '../database/database.dart';

class NotationSheetsRepository {
  NotationSheetsRepository(this._db);

  final AppDatabase _db;

  Stream<List<NotationSheet>> watchForNote(String noteId) {
    final query =
        _db.select(_db.notationSheets).join([
            innerJoin(
              _db.parts,
              _db.parts.id.equalsExp(_db.notationSheets.partId),
            ),
          ])
          ..where(_db.parts.noteId.equals(noteId))
          ..orderBy([OrderingTerm.asc(_db.notationSheets.position)]);

    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(_db.notationSheets)).toList(),
    );
  }

  Stream<NotationSheet?> watchById(String id) {
    return (_db.select(
      _db.notationSheets,
    )..where((n) => n.id.equals(id))).watchSingleOrNull();
  }

  Future<NotationSheet> createBlank(String noteId) async {
    final partId = await _db.defaultPartIdForNote(noteId);
    final id = const Uuid().v4();
    final now = DateTime.now();
    await _db
        .into(_db.notationSheets)
        .insert(
          NotationSheetsCompanion.insert(
            id: id,
            partId: partId,
            data: NotationSheetData.blank().toJsonString(),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (_db.select(
      _db.notationSheets,
    )..where((n) => n.id.equals(id))).getSingle();
  }

  Future<void> rename(String id, String title) {
    return (_db.update(
      _db.notationSheets,
    )..where((n) => n.id.equals(id))).write(
      NotationSheetsCompanion(
        title: Value(title.isEmpty ? null : title),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateData(String id, NotationSheetData data) {
    return (_db.update(
      _db.notationSheets,
    )..where((n) => n.id.equals(id))).write(
      NotationSheetsCompanion(
        data: Value(data.toJsonString()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(String id) {
    return (_db.delete(_db.notationSheets)..where((n) => n.id.equals(id))).go();
  }
}
