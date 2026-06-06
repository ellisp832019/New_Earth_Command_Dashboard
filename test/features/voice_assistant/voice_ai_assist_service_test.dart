import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/voice_assistant/ai/voice_ai_assist_service.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/application/voice_ai_assist_controller.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_model.dart';

class _FakeVoiceAiAssistService implements VoiceAiAssistService {
  _FakeVoiceAiAssistService({
    required this.reviewResponse,
    required this.wizardResponse,
    required this.memoryResponse,
  });

  final VoiceAiAssistResponse reviewResponse;
  final VoiceAiAssistResponse wizardResponse;
  final VoiceAiAssistResponse memoryResponse;

  VoiceAiAssistRequest? lastRequest;
  String? lastMethod;

  @override
  Future<VoiceAiAssistResponse> reviewTranscript(
    VoiceAiAssistRequest request,
  ) async {
    lastRequest = request;
    lastMethod = 'review';
    return reviewResponse;
  }

  @override
  Future<VoiceAiAssistResponse> guideWizard(
    VoiceAiAssistRequest request,
  ) async {
    lastRequest = request;
    lastMethod = 'wizard';
    return wizardResponse;
  }

  @override
  Future<VoiceAiAssistResponse> summarizeMemory(
    VoiceAiAssistRequest request,
  ) async {
    lastRequest = request;
    lastMethod = 'memory';
    return memoryResponse;
  }
}

void main() {
  test('voice ai assist provider returns the local adapter stub', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final service = container.read(voiceAiAssistServiceProvider);

    expect(service, isA<LocalVoiceAiAssistService>());
  });

  test('voice ai assist stub returns tuned review guidance', () async {
    const service = NoOpVoiceAiAssistService();

    final response = await service.reviewTranscript(
      const VoiceAiAssistRequest(
        transcript: 'Review the dashboard cards and tighten the wording.',
        selectedType: VoiceCommandType.task,
        conversationContext: VoiceConversationContext(
          label: 'Project',
          summary: 'Dashboard voice workflow',
          type: VoiceCommandType.task,
          projectName: 'MicroGrow',
          title: 'Dashboard cards',
          transcript: 'Review the dashboard cards and tighten the wording.',
          entryCount: 2,
        ),
      ),
    );

    expect(response.summary, contains('task stays connected'));
    expect(response.summary, contains('remembered thread'));
    expect(response.nextStep, contains('Confirm the category, priority, and owner'));
    expect(response.suggestedTitle, 'Dashboard cards');
    expect(response.suggestedType, VoiceCommandType.task);
    expect(response.hints, contains('Local AI adapter active.'));
    expect(response.hints, contains('Review-first mode.'));
    expect(response.hints, contains('Inferred type: Task'));
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
            title: 'Dashboard voice workflow',
            transcript: 'Follow up with the dashboard voice workflow.',
            entryCount: 3,
          ),
        ),
      );

      expect(wizardResponse.summary, contains('detail step'));
      expect(wizardResponse.summary, contains('project'));
      expect(wizardResponse.nextStep, contains('Answer with only the details needed'));
      expect(wizardResponse.suggestedTitle, 'create the first milestone');
      expect(wizardResponse.hints, contains('Local AI adapter active.'));
      expect(wizardResponse.hints, contains('Current step: Details'));
      expect(memoryResponse.summary, contains('MicroGrow'));
      expect(memoryResponse.summary, contains('Latest entry'));
      expect(memoryResponse.nextStep, contains('Reopen the project flow'));
      expect(memoryResponse.hints, contains('Remembered thread is available.'));
      expect(memoryResponse.hints, contains('3 saved entries'));
      expect(memoryResponse.hints, contains('Latest entry: Follow up with the dashboard voice workflow.'));
    },
  );

  test(
    'voice ai briefing provider routes wizard, memory, and review requests',
    () async {
      final fakeService = _FakeVoiceAiAssistService(
        reviewResponse: const VoiceAiAssistResponse(
          summary: 'review summary',
          nextStep: 'review next',
        ),
        wizardResponse: const VoiceAiAssistResponse(
          summary: 'wizard summary',
          nextStep: 'wizard next',
        ),
        memoryResponse: const VoiceAiAssistResponse(
          summary: 'memory summary',
          nextStep: 'memory next',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          voiceAiAssistServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      final wizardResponse = await container
          .read(
            voiceAiBriefingAssistProvider(
              const VoiceAiAssistRequest(
                transcript: 'Project: create the next milestone.',
                prompt: 'Which project should this belong to?',
                selectedType: VoiceCommandType.project,
                wizardStep: VoiceWizardStep.project,
              ),
            ).future,
          );
      expect(fakeService.lastMethod, 'wizard');
      expect(wizardResponse.summary, 'wizard summary');

      final memoryResponse = await container
          .read(
            voiceAiBriefingAssistProvider(
              const VoiceAiAssistRequest(
                transcript: '',
                conversationContext: VoiceConversationContext(
                  label: 'Project',
                  summary: 'Dashboard voice workflow',
                  type: VoiceCommandType.project,
                  projectName: 'MicroGrow',
                ),
              ),
            ).future,
          );
      expect(fakeService.lastMethod, 'memory');
      expect(memoryResponse.summary, 'memory summary');

      final reviewResponse = await container
          .read(
            voiceAiBriefingAssistProvider(
              const VoiceAiAssistRequest(
                transcript: 'Review the dashboard cards and tighten the wording.',
                selectedType: VoiceCommandType.task,
              ),
            ).future,
          );
      expect(fakeService.lastMethod, 'review');
      expect(reviewResponse.summary, 'review summary');
    },
  );
}
