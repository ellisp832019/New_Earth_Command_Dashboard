import 'safety_command_gateway.dart';
import 'voice_ai_provider.dart';
import 'voice_models.dart';

class VoiceAssistantService {
  const VoiceAssistantService({
    this.provider = const MockVoiceAiProvider(),
    required SafetyCommandGateway safetyGateway,
  }) : _safetyGateway = safetyGateway;

  final VoiceAiProvider provider;
  final SafetyCommandGateway _safetyGateway;

  Future<VoiceAssistantResponse> createMockResponse({
    required String message,
    String? activeProject,
  }) async {
    return provider.assist(
      message: message,
      safetyGateway: _safetyGateway,
      activeProject: activeProject,
    );
  }
}
