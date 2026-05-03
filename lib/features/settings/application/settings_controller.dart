import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../dashboard/application/dashboard_controller.dart';
import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return SettingsRepository(database);
});

final settingsSnapshotProvider = FutureProvider<SettingsSnapshot>((ref) async {
  await ref.watch(databaseReadyProvider.future);
  return ref.watch(settingsRepositoryProvider).getSettings();
});

final settingsControllerProvider = Provider<SettingsController>((ref) {
  return SettingsController(ref);
});

class SettingsController {
  SettingsController(this._ref);

  final Ref _ref;

  Future<void> setShowWellbeingCard(bool value) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateDashboardCardVisibility(showWellbeingCard: value);
    _invalidate();
  }

  Future<void> setShowBusinessCard(bool value) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateDashboardCardVisibility(showBusinessCard: value);
    _invalidate();
  }

  Future<void> setShowLearningCard(bool value) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateDashboardCardVisibility(showLearningCard: value);
    _invalidate();
  }

  Future<void> setShowContentCard(bool value) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateDashboardCardVisibility(showContentCard: value);
    _invalidate();
  }

  void _invalidate() {
    _ref.invalidate(settingsSnapshotProvider);
    _ref.invalidate(dashboardSnapshotProvider);
  }
}
