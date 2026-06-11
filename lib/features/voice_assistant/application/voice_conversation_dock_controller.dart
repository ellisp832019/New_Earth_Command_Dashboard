import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routing/route_names.dart';
import '../../voice_intelligence/application/voice_module_providers.dart';
import '../../voice_intelligence/application/voice_thread_controller.dart';
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
    _syncSharedConversationThread(
      summary: summary,
      nextStep: nextStep,
      transcript: transcript,
      conversationContext: conversationContext,
      isWake: isWake,
      projectContext: projectContext,
      threadContext: threadContext,
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
    _syncSharedConversationThread(
      summary: response.summary,
      nextStep: response.nextStep,
      transcript: suggestion.transcript,
      conversationContext: nextConversationContext,
      isWake: suggestion.usedWakePhrase || suggestion.isWakeOnly,
      projectContext:
          response.projectContext ?? suggestion.suggestedProjectName,
      threadContext: response.threadContext,
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

  void _syncSharedConversationThread({
    required String summary,
    required String nextStep,
    required String transcript,
    required bool isWake,
    VoiceConversationContext? conversationContext,
    String? projectContext,
    String? threadContext,
  }) {
    final thread = ref.read(voiceConversationThreadProvider.notifier);
    thread.rememberThread(
      threadTitle: 'Voice Assistant',
      summary: summary,
      nextStep: nextStep,
      resumeRoute: RouteNames.voiceConversation,
      latestCaptureLabel:
          conversationContext?.latestEntryLabel ?? 'Legacy follow-up',
      latestCapturePreview:
          conversationContext?.latestEntryPreview ?? transcript,
      lastThingYouSaid: transcript,
      reviewPrompt: isWake
          ? 'Review the wake-triggered assistant reply before saving.'
          : 'Review the legacy assistant reply before saving.',
      prompts: [
        const VoiceConversationPrompt(
          label: 'Open shared conversation',
          description: 'Switch into the calm shared voice thread.',
          route: RouteNames.voiceConversation,
        ),
        const VoiceConversationPrompt(
          label: 'Return home',
          description: 'Go back to the voice hub.',
          route: RouteNames.voice,
        ),
        if (threadContext != null && threadContext.isNotEmpty)
          const VoiceConversationPrompt(
            label: 'Open legacy assistant',
            description: 'Continue in the legacy assistant surface.',
            route: RouteNames.voiceAssistant,
          ),
      ],
      isFresh: false,
    );
    thread.pinCurrentTurn(
      title: 'Legacy dock turn',
      body: summary,
      note: 'This is the latest reply from the dock.',
    );
  }
}

final voiceConversationDockProvider =
    NotifierProvider<VoiceConversationDockNotifier, VoiceConversationDockState>(
      VoiceConversationDockNotifier.new,
    );
