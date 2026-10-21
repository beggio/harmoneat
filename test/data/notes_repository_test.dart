import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmoneat/data/database/database.dart';
import 'package:harmoneat/data/repositories/notes_repository.dart';
import 'package:harmoneat/platform/app_directories.dart';

void main() {
  test('create, rename, and delete a note', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = NotesRepository(db, const AppDirectories());

    final id = await repo.create(title: 'My first note');
    final notes = await repo.watchAll().first;
    expect(notes, hasLength(1));
    expect(notes.single.title, 'My first note');

    await repo.rename(id, 'Renamed');
    final renamed = await repo.watchById(id).first;
    expect(renamed!.title, 'Renamed');

    await repo.delete(id);
    final afterDelete = await repo.watchAll().first;
    expect(afterDelete, isEmpty);

    await db.close();
  });

  test('creating a note auto-creates its default Guitar part', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = NotesRepository(db, const AppDirectories());

    final id = await repo.create(title: 'Riff idea');
    final parts =
        await (db.select(db.parts)..where((p) => p.noteId.equals(id))).get();

    expect(parts, hasLength(1));
    expect(parts.single.instrumentId, guitarInstrumentId);

    await db.close();
  });
}
