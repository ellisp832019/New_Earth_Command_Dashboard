import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/voice_ai_assist_service.dart';

final voiceAiAssistServiceProvider = Provider<VoiceAiAssistService>((ref) {
  return const NoOpVoiceAiAssistService();
});

final voiceAiBriefingAssistProvider = FutureProvider.autoDispose
    .family<VoiceAiAssistResponse, VoiceAiAssistRequest>((ref, request) async {
      final service = ref.watch(voiceAiAssistServiceProvider);
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
