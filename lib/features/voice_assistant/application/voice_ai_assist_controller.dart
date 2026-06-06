import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/voice_ai_assist_service.dart';

final voiceAiAssistAdapterProvider = Provider<VoiceAiAssistAdapter>((ref) {
  return const LocalVoiceAiAssistService();
});

final voiceAiAssistServiceProvider = Provider<VoiceAiAssistService>((ref) {
  final adapter = ref.read(voiceAiAssistAdapterProvider);
  if (adapter is VoiceAiAssistService) {
    return adapter;
  }
  return const LocalVoiceAiAssistService();
});

final voiceAiBriefingAssistProvider = FutureProvider.autoDispose
    .family<VoiceAiAssistResponse, VoiceAiAssistRequest>((ref, request) async {
      final service = ref.watch(voiceAiAssistAdapterProvider);
      final trimmedPrompt = request.prompt?.trim();
      final trimmedTranscript = request.transcript.trim();
      final hasMemory =
          request.conversationContext != null &&
          request.conversationContext!.hasMemory;

      if (trimmedPrompt?.isNotEmpty == true || request.wizardStep != null) {
        return service.guideWizard(request);
      }

      if (hasMemory && trimmedTranscript.isEmpty) {
        return service.summarizeMemory(request);
      }

      return service.reviewTranscript(request);
    });
