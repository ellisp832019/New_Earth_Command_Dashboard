import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../services/seed_data_service.dart';
import '../services/daily_plan_service.dart';
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(appSettings, appSettings.voiceRepliesEnabled);
            await migrator.addColumn(appSettings, appSettings.voiceAssistantEnabled);
            await migrator.addColumn(appSettings, appSettings.preferredTtsVoiceName);
            await migrator.addColumn(appSettings, appSettings.preferredTtsVoiceLocale);
            await migrator.addColumn(appSettings, appSettings.preferredTtsVoiceGender);
            await migrator.addColumn(appSettings, appSettings.preferredTtsVoiceIdentifier);
            await migrator.addColumn(appSettings, appSettings.preferredTtsVoiceRate);
            await migrator.addColumn(appSettings, appSettings.preferredTtsVoicePitch);
          } else if (from < 3) {
            await migrator.addColumn(appSettings, appSettings.voiceAssistantEnabled);
          }
        },
      );
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
  await SeedDataService(database).ensureSeedData();
  await DailyPlanService(database).ensureTodayPlan();
});
