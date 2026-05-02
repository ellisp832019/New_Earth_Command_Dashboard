import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/constants/default_seed_data.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/core/services/seed_data_service.dart';

void main() {
  test('database opens and creates MVP tables', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await database.customSelect('SELECT 1').getSingle();

    final tables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
        )
        .map((row) => row.read<String>('name'))
        .get();

    expect(
      tables,
      containsAll([
        'app_settings',
        'business_opportunities',
        'content_items',
        'daily_plans',
        'inbox_items',
        'journal_entries',
        'learning_items',
        'projects',
        'tasks',
        'wellbeing_checkins',
      ]),
    );
  });

  test('seed data creates default projects and settings once', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final seedDataService = SeedDataService(database);

    await seedDataService.ensureSeedData();
    await seedDataService.ensureSeedData();

    final projects = await database.select(database.projects).get();
    final settings = await database.select(database.appSettings).get();

    expect(projects, hasLength(DefaultSeedData.projects.length));
    expect(
      projects.map((project) => project.name),
      containsAll(DefaultSeedData.projects.map((project) => project.name)),
    );
    expect(settings, hasLength(1));
    expect(settings.single.settingsId, DefaultSeedData.settingsId);
    expect(settings.single.dailyTopTaskLimit, 3);
  });

  test('seed data keeps existing projects and adds missing defaults', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final now = DateTime.now();
    await database
        .into(database.projects)
        .insert(
          ProjectsCompanion.insert(
            projectId: 'custom-project',
            name: 'Custom Project',
            createdAt: now,
            updatedAt: now,
          ),
        );

    await SeedDataService(database).ensureSeedData();

    final projects = await database.select(database.projects).get();

    expect(projects, hasLength(DefaultSeedData.projects.length + 1));
    expect(
      projects.map((project) => project.name),
      containsAll(['Custom Project', 'MicroGrow', 'Future Ideas']),
    );
  });
}
