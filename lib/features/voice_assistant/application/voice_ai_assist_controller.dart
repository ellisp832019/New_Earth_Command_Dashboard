import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/voice_ai_assist_service.dart';

final voiceAiAssistServiceProvider = Provider<VoiceAiAssistService>((ref) {
  return const NoOpVoiceAiAssistService();
});
