import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/meeting_summary_service.dart';
import '../data/voice_ai_provider.dart';
import '../data/voice_openai_transport.dart';
import '../data/microgrow_voice_status_service.dart';
import '../data/safety_command_gateway.dart';
import '../data/voice_assistant_service.dart';
import '../data/voice_audit_logger.dart';
import '../data/voice_module_config.dart';
import '../data/voice_models.dart';
import '../data/voice_module_preferences_repository.dart';
import '../data/voice_transcription_service.dart';
import 'voice_session_controller.dart';
import 'voice_thread_controller.dart';

final voiceModuleConfigProvider = Provider<VoiceModuleConfig>((ref) {
  return VoiceModuleConfig.fromEnvironment();
});

class VoiceFeatureFlagsNotifier extends Notifier<VoiceFeatureFlags> {
  bool _hasHydrated = false;
  bool _hasDirtyChanges = false;

  @override
  VoiceFeatureFlags build() {
    unawaited(_hydrate());
    return ref.read(voiceModuleConfigProvider).featureFlags;
  }

  void update(VoiceFeatureFlags flags) {
    state = flags;
    _hasDirtyChanges = true;
    _persist();
  }

  Future<void> _hydrate() async {
    if (_hasHydrated) {
      return;
    }

    _hasHydrated = true;
    final repository = VoiceModulePreferencesRepository(ref.read(appDatabaseProvider));
    final snapshot = await repository.loadPreferences();
    if (snapshot == null || _hasDirtyChanges) {
      return;
    }

    state = snapshot.featureFlags;
    _hasDirtyChanges = false;
  }

  void _persist() {
    unawaited(_save());
  }

  Future<void> _save() async {
    final repository = VoiceModulePreferencesRepository(ref.read(appDatabaseProvider));
    final existing = await repository.loadPreferences();
    await repository.savePreferences(
      providerMode: existing?.providerMode ?? ref.read(voiceProviderModeProvider),
      featureFlags: state,
    );
  }
}

class VoiceProviderModeNotifier extends Notifier<VoiceProviderMode> {
  bool _hasHydrated = false;
  bool _hasDirtyChanges = false;

  @override
  VoiceProviderMode build() {
    unawaited(_hydrate());
    return ref.read(voiceModuleConfigProvider).runtime.providerMode;
  }

  void setMode(VoiceProviderMode mode) {
    state = mode;
    _hasDirtyChanges = true;
    _persist();
  }

  Future<void> _hydrate() async {
    if (_hasHydrated) {
      return;
    }

    _hasHydrated = true;
    final repository = VoiceModulePreferencesRepository(ref.read(appDatabaseProvider));
    final snapshot = await repository.loadPreferences();
    if (snapshot == null || _hasDirtyChanges) {
      return;
    }

    state = snapshot.providerMode;
    _hasDirtyChanges = false;
  }

  void _persist() {
    unawaited(_save());
  }

  Future<void> _save() async {
    final repository = VoiceModulePreferencesRepository(ref.read(appDatabaseProvider));
    final existing = await repository.loadPreferences();
    await repository.savePreferences(
      providerMode: state,
      featureFlags: existing?.featureFlags ?? ref.read(voiceFeatureFlagsProvider),
    );
  }
}

final voiceFeatureFlagsProvider =
    NotifierProvider<VoiceFeatureFlagsNotifier, VoiceFeatureFlags>(
      VoiceFeatureFlagsNotifier.new,
    );

final voiceProviderModeProvider =
    NotifierProvider<VoiceProviderModeNotifier, VoiceProviderMode>(
      VoiceProviderModeNotifier.new,
    );

final voiceAuditLoggerProvider =
    NotifierProvider<VoiceAuditLogger, List<VoiceAuditEntry>>(
      VoiceAuditLogger.new,
    );

final voiceSessionControllerProvider =
    NotifierProvider<VoiceSessionController, VoiceSessionState>(
      VoiceSessionController.new,
    );

final voiceConversationThreadProvider =
    NotifierProvider<VoiceConversationThreadController, VoiceConversationThreadState>(
      VoiceConversationThreadController.new,
    );

final voiceSafetyGatewayProvider = Provider<SafetyCommandGateway>((ref) {
  return const SafetyCommandGateway();
});

final voiceOpenAiTransportProvider = Provider<VoiceOpenAiTransport>((ref) {
  final runtime = ref.watch(voiceModuleConfigProvider).runtime;
  return VoiceOpenAiTransport(apiKey: runtime.apiKey);
});

final voiceAiProviderProvider = Provider<VoiceAiProvider>((ref) {
  final runtime = ref.watch(voiceModuleConfigProvider).runtime;
  if (runtime.canUseOpenAi &&
      runtime.providerMode != VoiceProviderMode.mock) {
    return OpenAiVoiceAiProvider(
      runtimeConfig: runtime,
      transport: ref.watch(voiceOpenAiTransportProvider),
    );
  }

  return const MockVoiceAiProvider();
});

final voiceTranscriptionServiceProvider =
    Provider<VoiceTranscriptionService>((ref) {
  return VoiceTranscriptionService(provider: ref.watch(voiceAiProviderProvider));
});

final voiceMeetingSummaryServiceProvider =
    Provider<MeetingSummaryService>((ref) {
  return MeetingSummaryService(provider: ref.watch(voiceAiProviderProvider));
});

final voiceMicroGrowStatusServiceProvider =
    Provider<MicroGrowVoiceStatusService>((ref) {
  return MicroGrowVoiceStatusService(provider: ref.watch(voiceAiProviderProvider));
});

final voiceAssistantServiceProvider = Provider<VoiceAssistantService>((ref) {
  return VoiceAssistantService(
    provider: ref.watch(voiceAiProviderProvider),
    safetyGateway: ref.read(voiceSafetyGatewayProvider),
  );
});
