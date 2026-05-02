import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'tables/app_settings_table.dart';
import 'tables/business_opportunities_table.dart';
import 'tables/content_items_table.dart';
import 'tables/daily_plans_table.dart';
import 'tables/inbox_items_table.dart';
import 'tables/journal_entries_table.dart';
import 'tables/learning_items_table.dart';
import 'tables/projects_table.dart';
import 'tables/tasks_table.dart';
import 'tables/wellbeing_checkins_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Projects,
    Tasks,
    DailyPlans,
    JournalEntries,
    LearningItems,
    ContentItems,
    BusinessOpportunities,
    WellbeingCheckins,
    InboxItems,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      path.join(directory.path, 'new_earth_command_dashboard.db'),
    );

    return NativeDatabase.createInBackground(file);
  });
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final databaseReadyProvider = FutureProvider<void>((ref) async {
  final database = ref.watch(appDatabaseProvider);
  await database.customSelect('SELECT 1').getSingle();
});
