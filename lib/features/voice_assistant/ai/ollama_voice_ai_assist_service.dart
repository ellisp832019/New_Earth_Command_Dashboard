import 'dart:io';

import 'openai_voice_ai_assist_service.dart';

class OllamaVoiceAiAssistService extends OpenAIVoiceAiAssistService {
  OllamaVoiceAiAssistService({super.httpClient, String? model, String? baseUrl})
    : super(
        apiKey: null,
        model:
            model ??
            Platform.environment['VOICE_OLLAMA_MODEL'] ??
            Platform.environment['OLLAMA_MODEL'] ??
            'qwen2.5:7b',
        baseUrl:
            baseUrl ??
            Platform.environment['VOICE_OLLAMA_URL'] ??
            Platform.environment['OLLAMA_URL'] ??
            'http://localhost:11434/v1',
        allowMissingApiKey: true,
      );
}
