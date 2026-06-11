import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

enum VoiceProviderMode { mock, openAi, realtimeLater }

enum VoiceSessionMode { voiceNote, meeting, assistant, microgrowStatus }

enum VoiceRiskLevel { low, medium, high, blocked }

class VoiceFeatureFlags {
  const VoiceFeatureFlags({
    this.voiceNotesEnabled = true,
    this.meetingTranscriberEnabled = true,
    this.dashboardAssistantEnabled = true,
    this.microgrowReadOnlyEnabled = true,
    this.microgrowVoiceControlEnabled = false,
    this.alwaysOnWakeWordEnabled = false,
    this.cloudSyncVoiceLogsEnabled = false,
  });

  final bool voiceNotesEnabled;
  final bool meetingTranscriberEnabled;
  final bool dashboardAssistantEnabled;
  final bool microgrowReadOnlyEnabled;
  final bool microgrowVoiceControlEnabled;
  final bool alwaysOnWakeWordEnabled;
  final bool cloudSyncVoiceLogsEnabled;

  VoiceFeatureFlags copyWith({
    bool? voiceNotesEnabled,
    bool? meetingTranscriberEnabled,
    bool? dashboardAssistantEnabled,
    bool? microgrowReadOnlyEnabled,
    bool? microgrowVoiceControlEnabled,
    bool? alwaysOnWakeWordEnabled,
    bool? cloudSyncVoiceLogsEnabled,
  }) {
    return VoiceFeatureFlags(
      voiceNotesEnabled: voiceNotesEnabled ?? this.voiceNotesEnabled,
      meetingTranscriberEnabled:
          meetingTranscriberEnabled ?? this.meetingTranscriberEnabled,
      dashboardAssistantEnabled:
          dashboardAssistantEnabled ?? this.dashboardAssistantEnabled,
      microgrowReadOnlyEnabled:
          microgrowReadOnlyEnabled ?? this.microgrowReadOnlyEnabled,
      microgrowVoiceControlEnabled:
          microgrowVoiceControlEnabled ?? this.microgrowVoiceControlEnabled,
      alwaysOnWakeWordEnabled:
          alwaysOnWakeWordEnabled ?? this.alwaysOnWakeWordEnabled,
      cloudSyncVoiceLogsEnabled:
          cloudSyncVoiceLogsEnabled ?? this.cloudSyncVoiceLogsEnabled,
    );
  }
}

class VoiceRuntimeConfig {
  const VoiceRuntimeConfig({
    required this.providerMode,
    required this.apiKey,
    required this.transcriptionModel,
    required this.realtimeModel,
    required this.ttsModel,
  });

  final VoiceProviderMode providerMode;
  final String? apiKey;
  final String transcriptionModel;
  final String realtimeModel;
  final String ttsModel;

  bool get hasApiKey => apiKey?.trim().isNotEmpty == true;
  bool get canUseOpenAi =>
      providerMode != VoiceProviderMode.mock && hasApiKey;

  factory VoiceRuntimeConfig.fromEnvironment() {
    final platformEnvironment = kIsWeb ? const <String, String>{} : Platform.environment;

    final providerName = platformEnvironment['VOICE_PROVIDER']?.toLowerCase();
    final providerMode = switch (providerName) {
      'openai' => VoiceProviderMode.openAi,
      'realtime' => VoiceProviderMode.realtimeLater,
      _ => VoiceProviderMode.mock,
    };

    return VoiceRuntimeConfig(
      providerMode: providerMode,
      apiKey: platformEnvironment['OPENAI_API_KEY'],
      transcriptionModel:
          platformEnvironment['VOICE_TRANSCRIPTION_MODEL'] ?? 'gpt-4o-mini-transcribe',
      realtimeModel:
          platformEnvironment['VOICE_REALTIME_MODEL'] ?? 'gpt-realtime-2',
      ttsModel: platformEnvironment['VOICE_TTS_MODEL'] ?? 'tts-1',
    );
  }
}

class VoiceSessionRecord {
  const VoiceSessionRecord({
    required this.id,
    required this.startedAt,
    required this.mode,
    required this.status,
    this.endedAt,
    this.transcript,
    this.summary,
    this.linkedProject,
    this.savedTo,
  });

  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final VoiceSessionMode mode;
  final String? transcript;
  final String? summary;
  final String? linkedProject;
  final String? savedTo;
  final String status;
}

class VoiceTranscriptionResult {
  const VoiceTranscriptionResult({
    required this.transcript,
    required this.durationSeconds,
    required this.mode,
    required this.providerLabel,
    this.notes = '',
  });

  final String transcript;
  final int durationSeconds;
  final VoiceSessionMode mode;
  final String providerLabel;
  final String notes;
}

class VoiceCommandAction {
  const VoiceCommandAction({
    required this.type,
    required this.status,
    this.description,
  });

  final String type;
  final String status;
  final String? description;
}

class VoiceAssistantResponse {
  const VoiceAssistantResponse({
    required this.reply,
    required this.intents,
    required this.actions,
    required this.spokenReply,
    required this.safetyDecision,
  });

  final String reply;
  final List<String> intents;
  final List<VoiceCommandAction> actions;
  final String spokenReply;
  final SafetyDecision safetyDecision;
}

class MeetingSummaryResult {
  const MeetingSummaryResult({
    required this.summary,
    required this.decisions,
    required this.actions,
    required this.risks,
    required this.followUps,
  });

  final String summary;
  final List<String> decisions;
  final List<String> actions;
  final List<String> risks;
  final List<String> followUps;
}

class MicroGrowVoiceStatusResult {
  const MicroGrowVoiceStatusResult({
    required this.nodeOnline,
    required this.temperatureC,
    required this.humidityPercent,
    required this.relays,
    required this.warnings,
    required this.querySummary,
  });

  final bool nodeOnline;
  final double? temperatureC;
  final double? humidityPercent;
  final Map<String, bool> relays;
  final List<String> warnings;
  final String querySummary;
}

class SafetyCommandRequest {
  const SafetyCommandRequest({
    required this.rawText,
    required this.intent,
    this.parameters = const <String, Object?>{},
  });

  final String rawText;
  final String intent;
  final Map<String, Object?> parameters;
}

class SafetyDecision {
  const SafetyDecision({
    required this.allowed,
    required this.riskLevel,
    required this.requiresConfirmation,
    required this.reason,
  });

  final bool allowed;
  final VoiceRiskLevel riskLevel;
  final bool requiresConfirmation;
  final String reason;
}

class VoiceAuditEntry {
  const VoiceAuditEntry({
    required this.id,
    required this.timestamp,
    required this.section,
    required this.userText,
    required this.intent,
    required this.safetyDecision,
    required this.resultSummary,
  });

  final String id;
  final DateTime timestamp;
  final String section;
  final String userText;
  final String intent;
  final SafetyDecision safetyDecision;
  final String resultSummary;
}
