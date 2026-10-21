import 'package:drift/drift.dart';

/// Reference table of instruments, so no part of the schema or UI hardcodes
/// "guitar" — v1 seeds exactly one row, more are added later with zero
/// schema change.
class Instruments extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get tuning => text().nullable()();
  BoolColumn get supportsTab => boolean().withDefault(const Constant(false))();
  BoolColumn get supportsChordChart =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get supportsNotation =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
