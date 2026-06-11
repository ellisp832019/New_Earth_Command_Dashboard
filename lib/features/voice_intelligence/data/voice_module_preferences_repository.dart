import 'dart:convert';

import '../../../core/database/app_database.dart';
import 'voice_models.dart';

class VoiceModulePreferencesSnapshot {
  const VoiceModulePreferencesSnapshot({
    required this.providerMode,
    required this.featureFlags,
  });

  final VoiceProviderMode providerMode;
  final VoiceFeatureFlags featureFlags;
}

class VoiceModulePreferencesRepository {
  VoiceModulePreferencesRepository(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  static const String _preferenceId = 'voice-module-preferences';

  Future<VoiceModulePreferencesSnapshot?> loadPreferences() async {
    final row = await (_database.select(
      _database.voiceModulePreferences,
    )..where((table) => table.preferenceId.equals(_preferenceId))).getSingleOrNull();

    if (row == null) {
      return null;
    }

    return VoiceModulePreferencesSnapshot(
      providerMode: _providerModeFromLabel(row.providerMode),
      featureFlags: _featureFlagsFromJson(row.featureFlagsJson),
    );
  }

  Future<void> savePreferences({
    required VoiceProviderMode providerMode,
    required VoiceFeatureFlags featureFlags,
  }) async {
    final timestamp = _now();
    await _database
        .into(_database.voiceModulePreferences)
        .insertOnConflictUpdate(
          VoiceModulePreferencesCompanion.insert(
            preferenceId: _preferenceId,
            providerMode: providerMode.name,
            featureFlagsJson: jsonEncode(_featureFlagsToJson(featureFlags)),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );
  }

  Map<String, dynamic> _featureFlagsToJson(VoiceFeatureFlags flags) {
    return <String, dynamic>{
      'voiceNotesEnabled': flags.voiceNotesEnabled,
      'meetingTranscriberEnabled': flags.meetingTranscriberEnabled,
      'dashboardAssistantEnabled': flags.dashboardAssistantEnabled,
      'microgrowReadOnlyEnabled': flags.microgrowReadOnlyEnabled,
      'microgrowVoiceControlEnabled': flags.microgrowVoiceControlEnabled,
      'alwaysOnWakeWordEnabled': flags.alwaysOnWakeWordEnabled,
      'cloudSyncVoiceLogsEnabled': flags.cloudSyncVoiceLogsEnabled,
    };
  }

  VoiceFeatureFlags _featureFlagsFromJson(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return const VoiceFeatureFlags();
    }

    return VoiceFeatureFlags(
      voiceNotesEnabled: decoded['voiceNotesEnabled'] == true,
      meetingTranscriberEnabled: decoded['meetingTranscriberEnabled'] == true,
      dashboardAssistantEnabled: decoded['dashboardAssistantEnabled'] == true,
      microgrowReadOnlyEnabled: decoded['microgrowReadOnlyEnabled'] == true,
      microgrowVoiceControlEnabled:
          decoded['microgrowVoiceControlEnabled'] == true,
      alwaysOnWakeWordEnabled: decoded['alwaysOnWakeWordEnabled'] == true,
      cloudSyncVoiceLogsEnabled: decoded['cloudSyncVoiceLogsEnabled'] == true,
    );
  }

  VoiceProviderMode _providerModeFromLabel(String value) {
    return VoiceProviderMode.values.firstWhere(
      (candidate) => candidate.name == value,
      orElse: () => VoiceProviderMode.mock,
    );
  }
}
