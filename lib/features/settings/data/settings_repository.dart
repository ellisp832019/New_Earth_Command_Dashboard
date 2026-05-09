import 'package:drift/drift.dart';

import '../../../core/constants/app_build_info.dart';
import '../../../core/constants/default_seed_data.dart';
import '../../../core/database/app_database.dart';

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
            dailyTopTaskLimit: const Value(3),
            voiceRepliesEnabled: const Value(true),
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
