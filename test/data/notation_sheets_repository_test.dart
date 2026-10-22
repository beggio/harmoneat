import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmoneat/data/database/database.dart';
import 'package:harmoneat/data/repositories/notation_sheets_repository.dart';
import 'package:harmoneat/data/repositories/notes_repository.dart';
import 'package:harmoneat/features/notation/application/notation_sheet_data.dart';
import 'package:harmoneat/platform/app_directories.dart';

void main() {
  test(
    'creating a notation sheet attaches it to the note\'s default part',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final notes = NotesRepository(db, const AppDirectories());
      final sheets = NotationSheetsRepository(db);

      final noteId = await notes.create(title: 'Melody idea');
      final sheet = await sheets.createBlank(noteId);

      final part = await (db.select(
        db.parts,
      )..where((p) => p.noteId.equals(noteId))).getSingle();
      expect(sheet.partId, part.id);

      final data = NotationSheetData.fromJsonString(sheet.data);
      expect(data.events, hasLength(1));
      expect(data.events.first.isRest, isTrue);
      expect(data.timeSigNumerator, 4);
      expect(data.timeSigDenominator, 4);

      await db.close();
    },
  );

  test('rename, edit data, and delete a notation sheet', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final notes = NotesRepository(db, const AppDirectories());
    final sheets = NotationSheetsRepository(db);

    final noteId = await notes.create(title: 'Melody idea');
    final sheet = await sheets.createBlank(noteId);

    await sheets.rename(sheet.id, 'Verse melody');
    final renamed = await sheets.watchById(sheet.id).first;
    expect(renamed!.title, 'Verse melody');

    final data = NotationSheetData.fromJsonString(renamed.data)
        .withEventReplacedAt(
          0,
          const NotationEvent(
            isRest: false,
            pitch: Pitch(letter: 'C', accidental: 1, octave: 4),
            duration: NoteDuration.quarter,
            dotted: true,
          ),
        )
        .withEventAdded(NotationEvent.defaultRest())
        .withTimeSignature(3, 4);
    await sheets.updateData(sheet.id, data);

    final updated = await sheets.watchById(sheet.id).first;
    final updatedData = NotationSheetData.fromJsonString(updated!.data);
    expect(updatedData.events, hasLength(2));
    expect(updatedData.events.first.pitch!.letter, 'C');
    expect(updatedData.events.first.pitch!.accidental, 1);
    expect(updatedData.events.first.dotted, isTrue);
    expect(updatedData.events.first.beats, 1.5);
    expect(updatedData.timeSigNumerator, 3);
    expect(updatedData.timeSigDenominator, 4);

    await sheets.delete(sheet.id);
    final afterDelete = await sheets.watchById(sheet.id).first;
    expect(afterDelete, isNull);

    await db.close();
  });

  test('deleting a note cascades to its notation sheets', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final notes = NotesRepository(db, const AppDirectories());
    final sheets = NotationSheetsRepository(db);

    final noteId = await notes.create(title: 'Melody idea');
    final sheet = await sheets.createBlank(noteId);

    await notes.delete(noteId);

    final remaining = await (db.select(db.notationSheets)).get();
    expect(remaining, isEmpty);
    expect(await sheets.watchById(sheet.id).first, isNull);

    await db.close();
  });
}
