import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  });

  const VoiceConversationDockState.hidden()
    : visible = false,
      title = 'Gaia',
      summary = '',
      nextStep = '',
      transcript = '',
      isWake = false,
      projectContext = null,
      threadContext = null;

  final bool visible;
  final String title;
  final String summary;
  final String nextStep;
  final String transcript;
  final bool isWake;
  final String? projectContext;
  final String? threadContext;

  VoiceConversationDockState copyWith({
    bool? visible,
    String? title,
    String? summary,
    String? nextStep,
    String? transcript,
    bool? isWake,
    String? projectContext,
    String? threadContext,
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
    );
  }

  void hide() {
    state = const VoiceConversationDockState.hidden();
  }
}

final voiceConversationDockProvider =
    NotifierProvider<VoiceConversationDockNotifier, VoiceConversationDockState>(
      VoiceConversationDockNotifier.new,
    );
