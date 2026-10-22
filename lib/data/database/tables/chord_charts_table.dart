import 'package:drift/drift.dart';

import 'parts_table.dart';

/// A chord chart belongs to a part, same as `GuitarTabs`. `data` holds
/// JSON-encoded `ChordChartData` (see
/// `lib/features/chord/application/chord_chart_data.dart`) — read/written
/// as a whole unit by its own editor, never queried column-by-column.
class ChordCharts extends Table {
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
