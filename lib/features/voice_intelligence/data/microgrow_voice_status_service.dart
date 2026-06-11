import 'voice_models.dart';
import 'voice_ai_provider.dart';

class MicroGrowVoiceStatusService {
  const MicroGrowVoiceStatusService({
    this.provider = const MockVoiceAiProvider(),
  });

  final VoiceAiProvider provider;

  Future<MicroGrowVoiceStatusResult> readMockStatus({
    required String query,
  }) async {
    return provider.readMicroGrowStatus(query: query);
  }
}
