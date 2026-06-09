import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_speech_service.dart';

void main() {
  test('voice speech provider defaults to local tts', () {
    final mode = resolveVoiceSpeechProviderMode(environment: const {});

    expect(mode, VoiceSpeechProviderMode.localTts);
  });

  test('voice speech provider switches to openai realtime when requested', () {
    final mode = resolveVoiceSpeechProviderMode(
      environment: const {'VOICE_SPEECH_PROVIDER': 'openai_realtime'},
    );

    expect(mode, VoiceSpeechProviderMode.openAiRealtime);
  });

  test('voice speech provider accepts hyphenated openai realtime values', () {
    final mode = resolveVoiceSpeechProviderMode(
      environment: const {'VOICE_SPEECH_PROVIDER': 'openai-realtime'},
    );

    expect(mode, VoiceSpeechProviderMode.openAiRealtime);
  });

  test('voice speech normalization keeps rate and pitch in a calm band', () {
    expect(normalizeVoiceSpeechRate(0.1), 0.46);
    expect(normalizeVoiceSpeechRate(0.5), 0.5);
    expect(normalizeVoiceSpeechRate(0.9), 0.56);
    expect(normalizeVoiceSpeechPitch(0.2), 0.96);
    expect(normalizeVoiceSpeechPitch(1.0), 1.0);
    expect(normalizeVoiceSpeechPitch(1.5), 1.04);
  });

  test('voice speech normalization removes noisy spacing', () {
    expect(
      normalizeAssistantSpeechText('  Calm   reply\n\nnext step  '),
      'Calm reply next step',
    );
  });
}
