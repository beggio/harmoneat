import 'dart:io';

import 'package:drift/drift.dart';

import '../../platform/app_directories.dart';
import '../database/database.dart';

class NotesRepository {
  NotesRepository(this._db, this._dirs);

  final AppDatabase _db;
  final AppDirectories _dirs;

  Stream<List<Note>> watchAll() {
    return (_db.select(
      _db.notes,
    )..orderBy([(n) => OrderingTerm.desc(n.updatedAt)])).watch();
  }

  Stream<Note?> watchById(String id) {
    return (_db.select(
      _db.notes,
    )..where((n) => n.id.equals(id))).watchSingleOrNull();
  }

  Future<String> create({String title = ''}) => _db.createNote(title: title);

  Future<void> rename(String id, String title) {
    return (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(title: Value(title), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> updateBody(String id, String body) {
    return (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(
        body: Value(body.isEmpty ? null : body),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Deletes a note along with its parts and attachment rows+files. There
  /// are no chord_chart/tab/notation rows yet (added in later phases), so
  /// this cascade only needs to cover attachments and parts for now.
  Future<void> delete(String id) async {
    final noteAttachments = await (_db.select(
      _db.attachments,
    )..where((a) => a.noteId.equals(id))).get();
    for (final attachment in noteAttachments) {
      final absolutePath = await _dirs.resolve(attachment.filePath);
      final file = File(absolutePath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    await _db.transaction(() async {
      await (_db.delete(
        _db.attachments,
      )..where((a) => a.noteId.equals(id))).go();
      await (_db.delete(_db.parts)..where((pt) => pt.noteId.equals(id))).go();
      await (_db.delete(_db.notes)..where((n) => n.id.equals(id))).go();
    });
  }
}
