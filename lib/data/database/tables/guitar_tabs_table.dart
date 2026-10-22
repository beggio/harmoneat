import 'package:drift/drift.dart';

import 'parts_table.dart';

/// A guitar tab belongs to a part (not directly to a note), matching the
/// `chord_charts`/`notations` tables that will FK the same way in later
/// phases. `data` holds JSON-encoded `TabData` (see
/// `lib/features/tab/application/tab_data.dart`) rather than a normalized
/// per-note schema, since tab content is read/written as a whole unit by
/// its own editor, never queried column-by-column.
///
/// Named `GuitarTabs` (not `Tabs`) so Drift's generated row class is
/// `GuitarTab` — a bare `Tab` would collide with Flutter's own
/// `material.dart` `Tab` widget in every file that imports both.
class GuitarTabs extends Table {
  TextColumn get id => text()();
  TextColumn get partId => text().references(Parts, #id)();
  TextColumn get title => text().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  TextColumn get data => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
