import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../dashboard/application/dashboard_controller.dart';
import '../../dashboard/data/dashboard_card_layout.dart';
import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return SettingsRepository(database);
});

final settingsSnapshotProvider = FutureProvider<SettingsSnapshot>((ref) async {
  await ref.watch(databaseReadyProvider.future);
  return ref.watch(settingsRepositoryProvider).getSettings();
});

final appThemeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsSnapshotProvider);

  return settings.maybeWhen(
    data: (snapshot) => themeModeFromLabel(snapshot.settings.themeMode),
    orElse: () => ThemeMode.system,
  );
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

  Future<void> setShowDockOverlays(bool value) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateDockVisibility(showDockOverlays: value);
    _invalidate();
  }

  Future<void> setShowBackupGuardianDock(bool value) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateDockVisibility(showBackupGuardianDock: value);
    _invalidate();
  }

  Future<void> setShowTreasuryDock(bool value) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateDockVisibility(showTreasuryDock: value);
    _invalidate();
  }

  Future<void> setShowKnowledgeLibraryDock(bool value) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateDockVisibility(showKnowledgeLibraryDock: value);
    _invalidate();
  }

  Future<void> setShowVoiceConversationDock(bool value) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateDockVisibility(showVoiceConversationDock: value);
    _invalidate();
  }

  Future<void> setShowVoicePresenceChip(bool value) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateVoicePresenceVisibility(showVoicePresenceChip: value);
    _invalidate();
  }

  Future<void> setShowGaiaEmployeeSurface(bool value) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateGaiaEmployeeSurfaceVisibility(showGaiaEmployeeSurface: value);
    _invalidate();
  }

  Future<void> setShowProjectsWorkspaceSnapshot(bool value) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateDashboardCardVisibility(showProjectsWorkspaceSnapshot: value);
    _invalidate();
  }

  Future<void> setDashboardCardLayout(DashboardCardLayout layout) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateDashboardCardLayout(layout);
    _invalidate();
  }

  Future<void> setThemeMode(String value) async {
    await _ref.read(settingsRepositoryProvider).updateThemeMode(value);
    _invalidate();
  }

  Future<void> setVoicePreferences({
    bool? voiceRepliesEnabled,
    bool? voiceAssistantEnabled,
    bool? voiceStartupGateEnabled,
    String? preferredTtsVoiceName,
    String? preferredTtsVoiceLocale,
    String? preferredTtsVoiceGender,
    String? preferredTtsVoiceIdentifier,
    double? preferredTtsVoiceRate,
    double? preferredTtsVoicePitch,
  }) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateVoicePreferences(
          voiceRepliesEnabled: voiceRepliesEnabled,
          voiceAssistantEnabled: voiceAssistantEnabled,
          voiceStartupGateEnabled: voiceStartupGateEnabled,
          preferredTtsVoiceName: preferredTtsVoiceName,
          preferredTtsVoiceLocale: preferredTtsVoiceLocale,
          preferredTtsVoiceGender: preferredTtsVoiceGender,
          preferredTtsVoiceIdentifier: preferredTtsVoiceIdentifier,
          preferredTtsVoiceRate: preferredTtsVoiceRate,
          preferredTtsVoicePitch: preferredTtsVoicePitch,
        );
    _invalidate();
  }

  void _invalidate() {
    _ref.invalidate(settingsSnapshotProvider);
    _ref.invalidate(dashboardSnapshotProvider);
  }
}

ThemeMode themeModeFromLabel(String value) {
  switch (value) {
    case 'Light':
      return ThemeMode.light;
    case 'Dark':
      return ThemeMode.dark;
    case 'System':
    default:
      return ThemeMode.system;
  }
}
