import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../features/chord/application/chord_chart_data.dart';
import '../database/database.dart';

class ChordChartsRepository {
  ChordChartsRepository(this._db);

  final AppDatabase _db;

  Stream<List<ChordChart>> watchForNote(String noteId) {
    final query =
        _db.select(_db.chordCharts).join([
            innerJoin(
              _db.parts,
              _db.parts.id.equalsExp(_db.chordCharts.partId),
            ),
          ])
          ..where(_db.parts.noteId.equals(noteId))
          ..orderBy([OrderingTerm.asc(_db.chordCharts.position)]);

    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(_db.chordCharts)).toList(),
    );
  }

  Stream<ChordChart?> watchById(String id) {
    return (_db.select(
      _db.chordCharts,
    )..where((c) => c.id.equals(id))).watchSingleOrNull();
  }

  Future<ChordChart> createBlank(String noteId) async {
    final partId = await _db.defaultPartIdForNote(noteId);
    final id = const Uuid().v4();
    final now = DateTime.now();
    await _db
        .into(_db.chordCharts)
        .insert(
          ChordChartsCompanion.insert(
            id: id,
            partId: partId,
            data: ChordChartData.blank().toJsonString(),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (_db.select(
      _db.chordCharts,
    )..where((c) => c.id.equals(id))).getSingle();
  }

  Future<void> rename(String id, String title) {
    return (_db.update(_db.chordCharts)..where((c) => c.id.equals(id))).write(
      ChordChartsCompanion(
        title: Value(title.isEmpty ? null : title),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateData(String id, ChordChartData data) {
    return (_db.update(_db.chordCharts)..where((c) => c.id.equals(id))).write(
      ChordChartsCompanion(
        data: Value(data.toJsonString()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(String id) {
    return (_db.delete(_db.chordCharts)..where((c) => c.id.equals(id))).go();
  }
}
