import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../platform/app_directories.dart';
import '../database/database.dart';

class AttachmentsRepository {
  AttachmentsRepository(this._db, this._dirs);

  final AppDatabase _db;
  final AppDirectories _dirs;

  Stream<List<Attachment>> watchForNote(String noteId) {
    return (_db.select(_db.attachments)
          ..where((a) => a.noteId.equals(noteId))
          ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
        .watch();
  }

  /// Registers a file that is already sitting inside the attachments
  /// directory (e.g. one the recorder just wrote directly) — no copy.
  Future<Attachment> registerFile({
    required String noteId,
    required String absolutePath,
    required AttachmentSource source,
    String? originalFileName,
    int? durationMs,
  }) async {
    final id = const Uuid().v4();
    final relativePath = await _dirs.relativize(absolutePath);
    await _db
        .into(_db.attachments)
        .insert(
          AttachmentsCompanion.insert(
            id: id,
            noteId: noteId,
            filePath: relativePath,
            originalFileName: Value(originalFileName),
            durationMs: Value(durationMs),
            source: source,
            createdAt: DateTime.now(),
          ),
        );
    return (_db.select(
      _db.attachments,
    )..where((a) => a.id.equals(id))).getSingle();
  }

  /// Copies an externally-picked file (e.g. an imported voice memo) into
  /// the attachments directory, then registers it.
  Future<Attachment> importFile({
    required String noteId,
    required File sourceFile,
  }) async {
    final attachmentsDir = await _dirs.attachmentsDirectory();
    final id = const Uuid().v4();
    final extension = p.extension(sourceFile.path);
    final destFile = File(p.join(attachmentsDir.path, '$id$extension'));
    await sourceFile.copy(destFile.path);
    return registerFile(
      noteId: noteId,
      absolutePath: destFile.path,
      source: AttachmentSource.imported,
      originalFileName: p.basename(sourceFile.path),
    );
  }

  Future<String> absolutePath(Attachment attachment) {
    return _dirs.resolve(attachment.filePath);
  }

  Future<void> delete(Attachment attachment) async {
    final absolutePath = await _dirs.resolve(attachment.filePath);
    final file = File(absolutePath);
    if (await file.exists()) {
      await file.delete();
    }
    await (_db.delete(
      _db.attachments,
    )..where((a) => a.id.equals(attachment.id))).go();
  }
}
