import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/voice_assistant/ai/voice_ai_assist_service.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/application/voice_ai_assist_controller.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_model.dart';

void main() {
  test('voice ai assist provider returns the safe local stub', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final service = container.read(voiceAiAssistServiceProvider);

    expect(service, isA<NoOpVoiceAiAssistService>());
  });

  test('voice ai assist stub returns calm fallback guidance', () async {
    const service = NoOpVoiceAiAssistService();

    final response = await service.reviewTranscript(
      const VoiceAiAssistRequest(
        transcript: 'Review the dashboard cards and tighten the wording.',
        selectedType: VoiceCommandType.task,
        wizardStep: VoiceWizardStep.review,
      ),
    );

    expect(response.summary, contains('not connected yet'));
    expect(response.nextStep, contains('confirm the type, title, and project'));
    expect(response.suggestedTitle, 'Review the dashboard cards and tighten');
    expect(response.suggestedType, VoiceCommandType.task);
    expect(response.hints, contains('Wizard step: Review'));
  });

  test(
    'voice ai assist stub keeps wizard and memory help local-safe',
    () async {
      const service = NoOpVoiceAiAssistService();

      final wizardResponse = await service.guideWizard(
        const VoiceAiAssistRequest(
          transcript: 'Project: create the first milestone.',
          prompt: 'What is the next step?',
          wizardStep: VoiceWizardStep.details,
          selectedType: VoiceCommandType.project,
        ),
      );
      final memoryResponse = await service.summarizeMemory(
        const VoiceAiAssistRequest(
          transcript: 'Follow up with the dashboard voice workflow.',
          conversationContext: VoiceConversationContext(
            label: 'Project',
            summary: 'Dashboard voice workflow',
            type: VoiceCommandType.project,
            projectName: 'MicroGrow',
          ),
        ),
      );

      expect(wizardResponse.summary, contains('not connected yet'));
      expect(wizardResponse.hints, contains('Current step: Details'));
      expect(memoryResponse.summary, contains('thread can still be reviewed'));
      expect(memoryResponse.hints, contains('Thread memory is available.'));
    },
  );
}
