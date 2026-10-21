import 'package:drift/drift.dart';

import 'notes_table.dart';

enum AttachmentSource { recorded, imported }

/// FK'd directly to the note (not to a part) — a recording is reference
/// material for the whole note, not tied to one instrument part.
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get noteId => text().references(Notes, #id)();
  TextColumn get filePath => text()();
  TextColumn get originalFileName => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get source => textEnum<AttachmentSource>()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
