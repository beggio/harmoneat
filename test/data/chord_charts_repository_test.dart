import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmoneat/data/database/database.dart';
import 'package:harmoneat/data/repositories/chord_charts_repository.dart';
import 'package:harmoneat/data/repositories/notes_repository.dart';
import 'package:harmoneat/features/chord/application/chord_chart_data.dart';
import 'package:harmoneat/platform/app_directories.dart';

void main() {
  test(
    'creating a chord chart attaches it to the note\'s default part',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final notes = NotesRepository(db, const AppDirectories());
      final charts = ChordChartsRepository(db);

      final noteId = await notes.create(title: 'Song idea');
      final chart = await charts.createBlank(noteId);

      final part = await (db.select(
        db.parts,
      )..where((p) => p.noteId.equals(noteId))).getSingle();
      expect(chart.partId, part.id);

      final data = ChordChartData.fromJsonString(chart.data);
      expect(data.diagrams, hasLength(1));
      expect(data.tuning, ChordChartData.defaultTuning);
      expect(
        data.diagrams.first.strings,
        everyElement(predicate((ChordString s) => s.isOpen)),
      );

      await db.close();
    },
  );

  test('rename, edit data, and delete a chord chart', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final notes = NotesRepository(db, const AppDirectories());
    final charts = ChordChartsRepository(db);

    final noteId = await notes.create(title: 'Song idea');
    final chart = await charts.createBlank(noteId);

    await charts.rename(chart.id, 'Verse progression');
    final renamed = await charts.watchById(chart.id).first;
    expect(renamed!.title, 'Verse progression');

    final data = ChordChartData.fromJsonString(renamed.data)
        .withStringSet(
          diagramIndex: 0,
          stringIndex: 0,
          value: const ChordString(fret: 3, finger: 1),
        )
        .withDiagramNameSet(0, 'C')
        .withDiagramAdded();
    await charts.updateData(chart.id, data);

    final updated = await charts.watchById(chart.id).first;
    final updatedData = ChordChartData.fromJsonString(updated!.data);
    expect(updatedData.diagrams, hasLength(2));
    expect(updatedData.diagrams.first.name, 'C');
    expect(updatedData.diagrams.first.strings.first.fret, 3);
    expect(updatedData.diagrams.first.strings.first.finger, 1);

    await charts.delete(chart.id);
    final afterDelete = await charts.watchById(chart.id).first;
    expect(afterDelete, isNull);

    await db.close();
  });

  test('deleting a note cascades to its chord charts', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final notes = NotesRepository(db, const AppDirectories());
    final charts = ChordChartsRepository(db);

    final noteId = await notes.create(title: 'Song idea');
    final chart = await charts.createBlank(noteId);

    await notes.delete(noteId);

    final remaining = await (db.select(db.chordCharts)).get();
    expect(remaining, isEmpty);
    expect(await charts.watchById(chart.id).first, isNull);

    await db.close();
  });
}
