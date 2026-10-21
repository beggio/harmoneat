import 'package:drift/drift.dart';

import 'instruments_table.dart';
import 'notes_table.dart';

/// Indirection between a note and its musical content. v1 auto-creates one
/// hidden default part per note so every note behaves like a single-part
/// note today, while the schema already supports a note holding multiple
/// parts (a band/ensemble arrangement) without a future migration.
class Parts extends Table {
  TextColumn get id => text()();
  TextColumn get noteId => text().references(Notes, #id)();
  TextColumn get instrumentId => text().references(Instruments, #id)();
  TextColumn get name => text().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
