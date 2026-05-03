import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/core/services/seed_data_service.dart';
import 'package:new_earth_command_dashboard/features/settings/data/settings_repository.dart';

void main() {
  test(
    'settings repository loads seeded settings and updates card toggles',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await SeedDataService(database).ensureSeedData();
      final repository = SettingsRepository(database);

      final initial = await repository.getSettings();
      expect(initial.settings.dailyTopTaskLimit, 3);
      expect(initial.settings.showWellbeingCard, isTrue);
      expect(initial.settings.showBusinessCard, isTrue);
      expect(initial.settings.showLearningCard, isTrue);
      expect(initial.settings.showContentCard, isTrue);
      expect(initial.appVersion, '1.0.0+1');

      final updated = await repository.updateDashboardCardVisibility(
        showWellbeingCard: false,
        showContentCard: false,
      );

      expect(updated.showWellbeingCard, isFalse);
      expect(updated.showBusinessCard, isTrue);
      expect(updated.showLearningCard, isTrue);
      expect(updated.showContentCard, isFalse);
    },
  );

  test('settings repository updates theme mode', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await SeedDataService(database).ensureSeedData();
    final repository = SettingsRepository(database);

    final updated = await repository.updateThemeMode('Dark');

    expect(updated.themeMode, 'Dark');
  });
}
