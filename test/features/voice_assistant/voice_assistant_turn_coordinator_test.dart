import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/application/voice_assistant_turn_coordinator.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/application/voice_session_controller.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_speech_service.dart';

class _FakeVoiceAssistantSpeechService extends VoiceAssistantSpeechService {
  String? spokenText;
  bool stopCalled = false;
  VoiceSpeechTone? tone;
  double? rate;
  double? pitch;
  VoiceTtsVoiceOption? voice;
  bool enabled = false;

  @override
  Future<List<VoiceTtsVoiceOption>> loadVoices() async {
    return const <VoiceTtsVoiceOption>[];
  }

  @override
  Future<void> speak(
    String text, {
    required bool enabled,
    double rate = 0.5,
    double pitch = 1.0,
    VoiceTtsVoiceOption? voice,
    VoiceSpeechTone tone = VoiceSpeechTone.neutral,
  }) async {
    spokenText = text;
    this.enabled = enabled;
    this.rate = rate;
    this.pitch = pitch;
    this.voice = voice;
    this.tone = tone;
  }

  @override
  Future<void> stop() async {
    stopCalled = true;
  }
}

AppSetting _testSettings() {
  final now = DateTime.utc(2026, 6, 8, 10, 0);
  return AppSetting(
    settingsId: 'settings-default',
    themeMode: 'System',
    defaultDashboardView: null,
    showWellbeingCard: true,
    showBusinessCard: true,
    showLearningCard: true,
    showContentCard: true,
    showProjectsWorkspaceSnapshot: true,
    showDockOverlays: true,
    showBackupGuardianDock: true,
    showTreasuryDock: true,
    showKnowledgeLibraryDock: true,
    showVoiceConversationDock: true,
    showVoicePresenceChip: true,
    showGaiaEmployeeSurface: false,
    dailyTopTaskLimit: 3,
    voiceRepliesEnabled: true,
    voiceAssistantEnabled: true,
    voiceStartupGateEnabled: false,
    preferredTtsVoiceName: null,
    preferredTtsVoiceLocale: null,
    preferredTtsVoiceGender: null,
    preferredTtsVoiceIdentifier: null,
    preferredTtsVoiceRate: 0.5,
    preferredTtsVoicePitch: 1.0,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  test(
    'voice assistant turn coordinator speaks and returns to follow-up',
    () async {
      final fakeSpeech = _FakeVoiceAssistantSpeechService();
      final container = ProviderContainer(
        overrides: [
          voiceAssistantSpeechServiceProvider.overrideWithValue(fakeSpeech),
        ],
      );
      addTearDown(container.dispose);

      final coordinator = container.read(voiceAssistantTurnCoordinatorProvider);
      final settings = _testSettings();

      await coordinator.speak(
        VoiceAssistantTurnPlan(
          kind: VoiceAssistantTurnKind.briefing,
          owner: VoiceSessionOwner.assistant,
          speakingLabel: 'Assistant speaking',
          speakingDetail: 'Reading back the response',
          followUpLabel: 'Assistant ready',
          followUpDetail: 'Waiting for your next command',
          text: 'Task captured. Next: review the category and save locally.',
          settings: settings,
          tone: VoiceSpeechTone.briefing,
        ),
      );

      expect(fakeSpeech.spokenText, contains('Task captured'));
      expect(fakeSpeech.enabled, isTrue);
      expect(fakeSpeech.rate, 0.5);
      expect(fakeSpeech.pitch, 1.0);
      expect(fakeSpeech.voice, isNull);
      expect(fakeSpeech.tone, VoiceSpeechTone.briefing);
      expect(
        container.read(voiceSessionProvider).owner,
        VoiceSessionOwner.assistant,
      );
      expect(
        container.read(voiceSessionProvider).phase,
        VoiceSessionPhase.awaitingFollowUp,
      );
      expect(container.read(voiceSessionProvider).label, 'Assistant ready');
    },
  );

  test(
    'voice assistant turn coordinator can stop the shared speech engine',
    () async {
      final fakeSpeech = _FakeVoiceAssistantSpeechService();
      final container = ProviderContainer(
        overrides: [
          voiceAssistantSpeechServiceProvider.overrideWithValue(fakeSpeech),
        ],
      );
      addTearDown(container.dispose);

      final coordinator = container.read(voiceAssistantTurnCoordinatorProvider);

      await coordinator.stop();

      expect(fakeSpeech.stopCalled, isTrue);
    },
  );
}
