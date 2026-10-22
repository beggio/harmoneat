import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmoneat/data/database/database.dart';
import 'package:harmoneat/data/repositories/guitar_tabs_repository.dart';
import 'package:harmoneat/data/repositories/notes_repository.dart';
import 'package:harmoneat/features/tab/application/tab_data.dart';
import 'package:harmoneat/platform/app_directories.dart';

void main() {
  test('creating a tab attaches it to the note\'s default part', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final notes = NotesRepository(db, const AppDirectories());
    final tabs = GuitarTabsRepository(db);

    final noteId = await notes.create(title: 'Riff idea');
    final tab = await tabs.createBlank(noteId);

    final part = await (db.select(
      db.parts,
    )..where((p) => p.noteId.equals(noteId))).getSingle();
    expect(tab.partId, part.id);

    final data = TabData.fromJsonString(tab.data);
    expect(data.beats, hasLength(1));
    expect(data.tuning, TabData.defaultTuning);

    await db.close();
  });

  test('rename, edit data, and delete a tab', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final notes = NotesRepository(db, const AppDirectories());
    final tabs = GuitarTabsRepository(db);

    final noteId = await notes.create(title: 'Riff idea');
    final tab = await tabs.createBlank(noteId);

    await tabs.rename(tab.id, 'Intro riff');
    final renamed = await tabs.watchById(tab.id).first;
    expect(renamed!.title, 'Intro riff');

    final data = TabData.fromJsonString(renamed.data)
        .withNoteSet(
          beatIndex: 0,
          stringIndex: 0,
          note: const TabNote(fret: 3, finger: 1),
        )
        .withBeatAdded();
    await tabs.updateData(tab.id, data);

    final updated = await tabs.watchById(tab.id).first;
    final updatedData = TabData.fromJsonString(updated!.data);
    expect(updatedData.beats, hasLength(2));
    expect(updatedData.beats.first.notes.first?.fret, 3);
    expect(updatedData.beats.first.notes.first?.finger, 1);

    await tabs.delete(tab.id);
    final afterDelete = await tabs.watchById(tab.id).first;
    expect(afterDelete, isNull);

    await db.close();
  });

  test('deleting a note cascades to its tabs', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final notes = NotesRepository(db, const AppDirectories());
    final tabs = GuitarTabsRepository(db);

    final noteId = await notes.create(title: 'Riff idea');
    final tab = await tabs.createBlank(noteId);

    await notes.delete(noteId);

    final remaining = await (db.select(db.guitarTabs)).get();
    expect(remaining, isEmpty);
    expect(await tabs.watchById(tab.id).first, isNull);

    await db.close();
  });
}
