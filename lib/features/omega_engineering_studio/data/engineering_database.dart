import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'engineering_database.g.dart';

class EngineeringSnapshotRecords extends Table {
  TextColumn get snapshotId => text()();

  TextColumn get payload => text()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {snapshotId};
}

@DriftDatabase(tables: [EngineeringSnapshotRecords])
class EngineeringLocalDatabase extends _$EngineeringLocalDatabase {
  EngineeringLocalDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  Future<String> snapshotFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, 'omega_engineering_studio_snapshot.db');
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = File(await _snapshotDbPath());
    return NativeDatabase.createInBackground(file);
  });
}

Future<String> _snapshotDbPath() async {
  final directory = await getApplicationDocumentsDirectory();
  return path.join(directory.path, 'omega_engineering_studio.db');
}
