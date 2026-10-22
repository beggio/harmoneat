import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../features/tab/application/tab_data.dart';
import '../database/database.dart';

class GuitarTabsRepository {
  GuitarTabsRepository(this._db);

  final AppDatabase _db;

  Stream<List<GuitarTab>> watchForNote(String noteId) {
    final query =
        _db.select(_db.guitarTabs).join([
            innerJoin(_db.parts, _db.parts.id.equalsExp(_db.guitarTabs.partId)),
          ])
          ..where(_db.parts.noteId.equals(noteId))
          ..orderBy([OrderingTerm.asc(_db.guitarTabs.position)]);

    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(_db.guitarTabs)).toList(),
    );
  }

  Stream<GuitarTab?> watchById(String id) {
    return (_db.select(
      _db.guitarTabs,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<GuitarTab> createBlank(String noteId) async {
    final partId = await _db.defaultPartIdForNote(noteId);
    final id = const Uuid().v4();
    final now = DateTime.now();
    await _db
        .into(_db.guitarTabs)
        .insert(
          GuitarTabsCompanion.insert(
            id: id,
            partId: partId,
            data: TabData.blank().toJsonString(),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (_db.select(
      _db.guitarTabs,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> rename(String id, String title) {
    return (_db.update(_db.guitarTabs)..where((t) => t.id.equals(id))).write(
      GuitarTabsCompanion(
        title: Value(title.isEmpty ? null : title),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateData(String id, TabData data) {
    return (_db.update(_db.guitarTabs)..where((t) => t.id.equals(id))).write(
      GuitarTabsCompanion(
        data: Value(data.toJsonString()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(String id) {
    return (_db.delete(_db.guitarTabs)..where((t) => t.id.equals(id))).go();
  }
}
