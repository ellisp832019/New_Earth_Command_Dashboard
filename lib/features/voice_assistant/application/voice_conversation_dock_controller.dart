import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../voice_command_model.dart';
import '../voice_command_service.dart';
import 'voice_session_controller.dart';

class VoiceConversationDockState {
  const VoiceConversationDockState({
    required this.visible,
    required this.title,
    required this.summary,
    required this.nextStep,
    required this.transcript,
    required this.isWake,
    this.projectContext,
    this.threadContext,
    this.conversationContext,
  });

  const VoiceConversationDockState.hidden()
    : visible = false,
      title = 'Gaia',
      summary = '',
      nextStep = '',
      transcript = '',
      isWake = false,
      projectContext = null,
      threadContext = null,
      conversationContext = null;

  final bool visible;
  final String title;
  final String summary;
  final String nextStep;
  final String transcript;
  final bool isWake;
  final String? projectContext;
  final String? threadContext;
  final VoiceConversationContext? conversationContext;

  VoiceConversationDockState copyWith({
    bool? visible,
    String? title,
    String? summary,
    String? nextStep,
    String? transcript,
    bool? isWake,
    String? projectContext,
    String? threadContext,
    VoiceConversationContext? conversationContext,
  }) {
    return VoiceConversationDockState(
      visible: visible ?? this.visible,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      nextStep: nextStep ?? this.nextStep,
      transcript: transcript ?? this.transcript,
      isWake: isWake ?? this.isWake,
      projectContext: projectContext ?? this.projectContext,
      threadContext: threadContext ?? this.threadContext,
      conversationContext: conversationContext ?? this.conversationContext,
    );
  }
}

class VoiceConversationDockNotifier
    extends Notifier<VoiceConversationDockState> {
  @override
  VoiceConversationDockState build() =>
      const VoiceConversationDockState.hidden();

  void show({
    required String title,
    required String summary,
    required String nextStep,
    String transcript = '',
    bool isWake = false,
    String? projectContext,
    String? threadContext,
    VoiceConversationContext? conversationContext,
  }) {
    state = VoiceConversationDockState(
      visible: true,
      title: title,
      summary: summary,
      nextStep: nextStep,
      transcript: transcript,
      isWake: isWake,
      projectContext: projectContext,
      threadContext: threadContext,
      conversationContext: conversationContext,
    );
  }

  void hide() {
    state = const VoiceConversationDockState.hidden();
    ref
        .read(voiceSessionProvider.notifier)
        .release(
          owner: VoiceSessionOwner.dock,
          label: 'Gaia idle',
          detail: 'Ready when you are',
        );
  }

  VoiceCommandAssistantResponse? respondToFollowUp(String transcript) {
    final cleanedTranscript = transcript.trim();
    if (cleanedTranscript.isEmpty) {
      return null;
    }

    final service = VoiceCommandService();
    ref
        .read(voiceSessionProvider.notifier)
        .beginProcessing(
          owner: VoiceSessionOwner.dock,
          label: 'Gaia processing',
          detail: 'Shaping the follow-up',
          opacity: 0.72,
        );
    final suggestion = service.suggestCommand(transcript: cleanedTranscript);
    final nextConversationContext = service.buildConversationContext(
      transcript: suggestion.transcript,
      type: suggestion.suggestedType,
      title: suggestion.suggestedTitle,
      projectId: suggestion.suggestedProjectId,
      projectName: suggestion.suggestedProjectName,
      previous: state.conversationContext,
    );
    final response = service.buildAssistantResponse(
      transcript: cleanedTranscript,
      suggestion: suggestion,
      conversationContext: nextConversationContext,
    );

    state = state.copyWith(
      visible: true,
      title: 'Gaia',
      summary: response.summary,
      nextStep: response.nextStep,
      transcript: suggestion.transcript,
      isWake: suggestion.usedWakePhrase || suggestion.isWakeOnly,
      projectContext:
          response.projectContext ?? suggestion.suggestedProjectName,
      threadContext: response.threadContext,
      conversationContext: nextConversationContext,
    );
    ref
        .read(voiceSessionProvider.notifier)
        .beginAwaitingFollowUp(
          owner: VoiceSessionOwner.dock,
          label: 'Gaia ready',
          detail: 'Ask another follow-up',
          opacity: 0.64,
        );
    return response;
  }
}

final voiceConversationDockProvider =
    NotifierProvider<VoiceConversationDockNotifier, VoiceConversationDockState>(
      VoiceConversationDockNotifier.new,
    );
