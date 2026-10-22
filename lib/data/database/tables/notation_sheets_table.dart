import 'package:drift/drift.dart';

import 'parts_table.dart';

/// A notation sheet belongs to a part, same as `GuitarTabs`/`ChordCharts`.
/// `data` holds JSON-encoded `NotationSheetData` (see
/// `lib/features/notation/application/notation_sheet_data.dart`) — read
/// /written as a whole unit by its own editor, never queried
/// column-by-column.
class NotationSheets extends Table {
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
