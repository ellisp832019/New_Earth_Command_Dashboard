import 'voice_models.dart';
import 'voice_ai_provider.dart';

class VoiceTranscriptionService {
  const VoiceTranscriptionService({
    this.provider = const MockVoiceAiProvider(),
  });

  final VoiceAiProvider provider;

  Future<VoiceTranscriptionResult> transcribeMock({
    required VoiceSessionMode mode,
    required String prompt,
    required VoiceRuntimeConfig config,
  }) async {
    return provider.transcribe(mode: mode, prompt: prompt, config: config);
  }
}
