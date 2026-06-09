import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/voice_ai_assist_service.dart';
import '../ai/openai_voice_ai_assist_service.dart';

enum VoiceAiProviderMode { local, openAi }

final voiceAiLocalStubProvider = Provider<VoiceAiAssistService>((ref) {
  return const LocalVoiceAiAssistService();
});

final voiceAiOpenAiProvider = Provider<OpenAIVoiceAiAssistService>((ref) {
  final service = OpenAIVoiceAiAssistService();
  ref.onDispose(service.dispose);
  return service;
});

final voiceAiProviderModeProvider = Provider<VoiceAiProviderMode>((ref) {
  final providerValue = Platform.environment['VOICE_AI_PROVIDER']
      ?.trim()
      .toLowerCase();
  final apiKey = Platform.environment['OPENAI_API_KEY']?.trim();

  if (providerValue == 'openai' && apiKey != null && apiKey.isNotEmpty) {
    return VoiceAiProviderMode.openAi;
  }

  return VoiceAiProviderMode.local;
});

final voiceAiAssistAdapterProvider = Provider<VoiceAiAssistAdapter>((ref) {
  final mode = ref.watch(voiceAiProviderModeProvider);
  return switch (mode) {
    VoiceAiProviderMode.openAi => ref.read(voiceAiOpenAiProvider),
    VoiceAiProviderMode.local => ref.read(voiceAiLocalStubProvider),
  };
});

final voiceAiAssistServiceProvider = Provider<VoiceAiAssistService>((ref) {
  final adapter = ref.read(voiceAiAssistAdapterProvider);
  if (adapter is VoiceAiAssistService) {
    return adapter;
  }
  return ref.read(voiceAiLocalStubProvider);
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
