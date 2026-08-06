import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/voice_ai_assist_service.dart';
import '../ai/ollama_voice_ai_assist_service.dart';
import '../ai/openai_voice_ai_assist_service.dart';
import '../../voice_intelligence/data/voice_usb_config_discovery.dart';

enum VoiceAiProviderMode { local, ollama, openAi }

final voiceAiLocalStubProvider = Provider<VoiceAiAssistService>((ref) {
  return const LocalVoiceAiAssistService();
});

final voiceAiOpenAiProvider = Provider<OpenAIVoiceAiAssistService>((ref) {
  final service = OpenAIVoiceAiAssistService();
  ref.onDispose(service.dispose);
  return service;
});

final voiceAiOllamaProvider = Provider<OllamaVoiceAiAssistService>((ref) {
  final env = _resolvedVoiceEnvironment();
  final service = OllamaVoiceAiAssistService(
    model: env['VOICE_OLLAMA_MODEL'] ?? env['OLLAMA_MODEL'],
    baseUrl: env['VOICE_OLLAMA_URL'] ?? env['OLLAMA_URL'],
  );
  ref.onDispose(service.dispose);
  return service;
});

final voiceAiProviderModeProvider = Provider<VoiceAiProviderMode>((ref) {
  final env = _resolvedVoiceEnvironment();
  final providerValue =
      env['VOICE_AI_PROVIDER']?.trim().toLowerCase() ??
      env['VOICE_PROVIDER']?.trim().toLowerCase();
  final apiKey = env['OPENAI_API_KEY']?.trim();

  if (providerValue == 'local' || providerValue == 'mock') {
    return VoiceAiProviderMode.local;
  }

  if (providerValue == 'ollama') {
    return VoiceAiProviderMode.ollama;
  }

  final ollamaConfigured =
      env['VOICE_OLLAMA_URL']?.trim().isNotEmpty == true ||
      env['OLLAMA_URL']?.trim().isNotEmpty == true ||
      env['VOICE_OLLAMA_MODEL']?.trim().isNotEmpty == true ||
      env['OLLAMA_MODEL']?.trim().isNotEmpty == true;
  if (ollamaConfigured) {
    return VoiceAiProviderMode.ollama;
  }

  if (providerValue == 'openai' && apiKey != null && apiKey.isNotEmpty) {
    return VoiceAiProviderMode.openAi;
  }

  return VoiceAiProviderMode.local;
});

final voiceAiAssistAdapterProvider = Provider<VoiceAiAssistAdapter>((ref) {
  final mode = ref.watch(voiceAiProviderModeProvider);
  return switch (mode) {
    VoiceAiProviderMode.openAi => ref.read(voiceAiOpenAiProvider),
    VoiceAiProviderMode.ollama => ref.read(voiceAiOllamaProvider),
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

final voiceAiConversationAssistProvider = FutureProvider.autoDispose
    .family<VoiceAiAssistResponse, VoiceAiAssistRequest>((ref, request) async {
      final service = ref.watch(voiceAiAssistAdapterProvider);
      return service.conversationTurn(request);
    });

Map<String, String> _resolvedVoiceEnvironment() {
  final platformEnvironment = Platform.environment;
  final usbEnvironment = VoiceUsbConfigDiscovery.discoverOllamaEnvironment(
    environment: platformEnvironment,
  );
  return <String, String>{
    ...usbEnvironment,
    ...platformEnvironment,
  };
}
