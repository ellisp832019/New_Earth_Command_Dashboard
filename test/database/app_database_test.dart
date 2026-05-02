import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';

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
}
