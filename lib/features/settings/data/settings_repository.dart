import 'package:drift/drift.dart';

import '../../../core/constants/app_build_info.dart';
import '../../../core/constants/default_seed_data.dart';
import '../../../core/database/app_database.dart';
import '../../dashboard/data/dashboard_card_layout.dart';

class SettingsSnapshot {
  const SettingsSnapshot({required this.settings, required this.appVersion});

  final AppSetting settings;
  final String appVersion;
}

class SettingsRepository {
  SettingsRepository(this._database);

  final AppDatabase _database;

  Future<SettingsSnapshot> getSettings() async {
    final settings = await _getOrCreateSettings();

    return SettingsSnapshot(settings: settings, appVersion: appBuildVersion);
  }

  Future<AppSetting> updateDashboardCardVisibility({
    bool? showWellbeingCard,
    bool? showBusinessCard,
    bool? showLearningCard,
    bool? showContentCard,
    bool? showProjectsWorkspaceSnapshot,
  }) async {
    final settings = await _getOrCreateSettings();
    final timestamp = DateTime.now();

    await (_database.update(
      _database.appSettings,
    )..where((table) => table.settingsId.equals(settings.settingsId))).write(
      AppSettingsCompanion(
        showWellbeingCard: showWellbeingCard == null
            ? const Value.absent()
            : Value(showWellbeingCard),
        showBusinessCard: showBusinessCard == null
            ? const Value.absent()
            : Value(showBusinessCard),
        showLearningCard: showLearningCard == null
            ? const Value.absent()
            : Value(showLearningCard),
        showContentCard: showContentCard == null
            ? const Value.absent()
            : Value(showContentCard),
        showProjectsWorkspaceSnapshot: showProjectsWorkspaceSnapshot == null
            ? const Value.absent()
            : Value(showProjectsWorkspaceSnapshot),
        updatedAt: Value(timestamp),
      ),
    );

    return _getOrCreateSettings();
  }

  Future<AppSetting> updateDashboardCardLayout(
    DashboardCardLayout layout,
  ) async {
    final settings = await _getOrCreateSettings();
    await (_database.update(
      _database.appSettings,
    )..where((table) => table.settingsId.equals(settings.settingsId))).write(
      AppSettingsCompanion(
        dashboardCardLayoutJson: Value(layout.toJson()),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return _getOrCreateSettings();
  }

  Future<AppSetting> updateDockVisibility({
    bool? showDockOverlays,
    bool? showBackupGuardianDock,
    bool? showTreasuryDock,
    bool? showKnowledgeLibraryDock,
    bool? showVoiceConversationDock,
  }) async {
    final settings = await _getOrCreateSettings();
    final timestamp = DateTime.now();

    await (_database.update(
      _database.appSettings,
    )..where((table) => table.settingsId.equals(settings.settingsId))).write(
      AppSettingsCompanion(
        showDockOverlays: showDockOverlays == null
            ? const Value.absent()
            : Value(showDockOverlays),
        showBackupGuardianDock: showBackupGuardianDock == null
            ? const Value.absent()
            : Value(showBackupGuardianDock),
        showTreasuryDock: showTreasuryDock == null
            ? const Value.absent()
            : Value(showTreasuryDock),
        showKnowledgeLibraryDock: showKnowledgeLibraryDock == null
            ? const Value.absent()
            : Value(showKnowledgeLibraryDock),
        showVoiceConversationDock: showVoiceConversationDock == null
            ? const Value.absent()
            : Value(showVoiceConversationDock),
        updatedAt: Value(timestamp),
      ),
    );

    return _getOrCreateSettings();
  }

  Future<AppSetting> updateVoicePresenceVisibility({
    bool? showVoicePresenceChip,
  }) async {
    final settings = await _getOrCreateSettings();
    final timestamp = DateTime.now();

    await (_database.update(
      _database.appSettings,
    )..where((table) => table.settingsId.equals(settings.settingsId))).write(
      AppSettingsCompanion(
        showVoicePresenceChip: showVoicePresenceChip == null
            ? const Value.absent()
            : Value(showVoicePresenceChip),
        updatedAt: Value(timestamp),
      ),
    );

    return _getOrCreateSettings();
  }

  Future<AppSetting> updateThemeMode(String themeMode) async {
    final settings = await _getOrCreateSettings();
    final timestamp = DateTime.now();

    await (_database.update(
      _database.appSettings,
    )..where((table) => table.settingsId.equals(settings.settingsId))).write(
      AppSettingsCompanion(
        themeMode: Value(themeMode),
        updatedAt: Value(timestamp),
      ),
    );

    return _getOrCreateSettings();
  }

  Future<AppSetting> updateVoicePreferences({
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
    final settings = await _getOrCreateSettings();
    final timestamp = DateTime.now();

    await (_database.update(
      _database.appSettings,
    )..where((table) => table.settingsId.equals(settings.settingsId))).write(
      AppSettingsCompanion(
        voiceRepliesEnabled: voiceRepliesEnabled == null
            ? const Value.absent()
            : Value(voiceRepliesEnabled),
        voiceAssistantEnabled: voiceAssistantEnabled == null
            ? const Value.absent()
            : Value(voiceAssistantEnabled),
        voiceStartupGateEnabled: voiceStartupGateEnabled == null
            ? const Value.absent()
            : Value(voiceStartupGateEnabled),
        preferredTtsVoiceName: Value(preferredTtsVoiceName),
        preferredTtsVoiceLocale: Value(preferredTtsVoiceLocale),
        preferredTtsVoiceGender: Value(preferredTtsVoiceGender),
        preferredTtsVoiceIdentifier: Value(preferredTtsVoiceIdentifier),
        preferredTtsVoiceRate: preferredTtsVoiceRate == null
            ? const Value.absent()
            : Value(preferredTtsVoiceRate),
        preferredTtsVoicePitch: preferredTtsVoicePitch == null
            ? const Value.absent()
            : Value(preferredTtsVoicePitch),
        updatedAt: Value(timestamp),
      ),
    );

    return _getOrCreateSettings();
  }

  Future<AppSetting> updateGaiaEmployeeSurfaceVisibility({
    bool? showGaiaEmployeeSurface,
  }) async {
    final settings = await _getOrCreateSettings();
    final timestamp = DateTime.now();

    await (_database.update(
      _database.appSettings,
    )..where((table) => table.settingsId.equals(settings.settingsId))).write(
      AppSettingsCompanion(
        showGaiaEmployeeSurface: showGaiaEmployeeSurface == null
            ? const Value.absent()
            : Value(showGaiaEmployeeSurface),
        updatedAt: Value(timestamp),
      ),
    );

    return _getOrCreateSettings();
  }

  Future<AppSetting> _getOrCreateSettings() async {
    final existing = await (_database.select(
      _database.appSettings,
    )..limit(1)).getSingleOrNull();

    if (existing != null) {
      return existing;
    }

    final timestamp = DateTime.now();
    await _database
        .into(_database.appSettings)
        .insert(
          AppSettingsCompanion.insert(
            settingsId: DefaultSeedData.settingsId,
            themeMode: const Value('System'),
            defaultDashboardView: const Value('Dashboard'),
            showWellbeingCard: const Value(true),
            showBusinessCard: const Value(true),
            showLearningCard: const Value(true),
            showContentCard: const Value(true),
            showProjectsWorkspaceSnapshot: const Value(true),
            showDockOverlays: const Value(true),
            showBackupGuardianDock: const Value(true),
            showTreasuryDock: const Value(true),
            showKnowledgeLibraryDock: const Value(true),
            showVoiceConversationDock: const Value(true),
            showVoicePresenceChip: const Value(true),
            showGaiaEmployeeSurface: const Value(false),
            dailyTopTaskLimit: const Value(3),
            voiceRepliesEnabled: const Value(true),
            voiceAssistantEnabled: const Value(true),
            voiceStartupGateEnabled: const Value(false),
            preferredTtsVoiceName: const Value(null),
            preferredTtsVoiceLocale: const Value(null),
            preferredTtsVoiceGender: const Value(null),
            preferredTtsVoiceIdentifier: const Value(null),
            preferredTtsVoiceRate: const Value(0.5),
            preferredTtsVoicePitch: const Value(1.0),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );

    return (_database.select(_database.appSettings)..where(
          (table) => table.settingsId.equals(DefaultSeedData.settingsId),
        ))
        .getSingle();
  }
}
