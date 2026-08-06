import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../voice_command_model.dart';
import '../voice_speech_service.dart';
import 'voice_session_controller.dart';

enum VoiceAssistantTurnKind {
  wake,
  briefing,
  wizard,
  dockFollowUp,
  saveConfirmation,
}

class VoiceAssistantTurnPlan {
  const VoiceAssistantTurnPlan({
    required this.kind,
    required this.owner,
    required this.speakingLabel,
    required this.speakingDetail,
    required this.followUpLabel,
    required this.followUpDetail,
    required this.text,
    required this.settings,
    this.response,
    this.tone = VoiceSpeechTone.neutral,
  });

  final VoiceAssistantTurnKind kind;
  final VoiceSessionOwner owner;
  final String speakingLabel;
  final String speakingDetail;
  final String followUpLabel;
  final String followUpDetail;
  final String text;
  final AppSetting settings;
  final VoiceCommandAssistantResponse? response;
  final VoiceSpeechTone tone;
}

class VoiceAssistantTurnCoordinator {
  VoiceAssistantTurnCoordinator(this.ref);

  final Ref ref;

  Future<void> speak(VoiceAssistantTurnPlan plan) async {
    if (!plan.settings.voiceRepliesEnabled || plan.text.trim().isEmpty) {
      return;
    }

    final session = ref.read(voiceSessionProvider.notifier);
    final currentSession = ref.read(voiceSessionProvider);
    if (!currentSession.canBeClaimed && currentSession.owner != plan.owner) {
      return;
    }
    session.beginSpeaking(
      owner: plan.owner,
      label: plan.speakingLabel,
      detail: plan.speakingDetail,
      opacity: 0.72,
    );

    try {
      final service = ref.read(voiceAssistantSpeechServiceProvider);
      final voices = await ref.read(voiceAssistantVoicesProvider.future);
      final selectedVoice = resolveConfiguredVoiceOption(
        voices: voices,
        preferredName: plan.settings.preferredTtsVoiceName,
        preferredLocale: plan.settings.preferredTtsVoiceLocale,
        preferredGender: plan.settings.preferredTtsVoiceGender,
        preferredIdentifier: plan.settings.preferredTtsVoiceIdentifier,
      );
      await service.speak(
        plan.text,
        enabled: true,
        rate: plan.settings.preferredTtsVoiceRate,
        pitch: plan.settings.preferredTtsVoicePitch,
        voice: selectedVoice,
        tone: plan.tone,
      );
    } finally {
      session.beginAwaitingFollowUp(
        owner: plan.owner,
        label: plan.followUpLabel,
        detail: plan.followUpDetail,
        opacity: 0.64,
      );
    }
  }

  Future<void> stop() async {
    await ref.read(voiceAssistantSpeechServiceProvider).stop();
  }
}

final voiceAssistantTurnCoordinatorProvider =
    Provider<VoiceAssistantTurnCoordinator>((ref) {
      return VoiceAssistantTurnCoordinator(ref);
    });
