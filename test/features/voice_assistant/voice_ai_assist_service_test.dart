import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/voice_assistant/ai/voice_ai_assist_service.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/ai/openai_voice_ai_assist_service.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/application/voice_ai_assist_controller.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_model.dart';

class _FakeVoiceAiAssistService implements VoiceAiAssistService {
  _FakeVoiceAiAssistService({
    required this.reviewResponse,
    required this.wizardResponse,
    required this.memoryResponse,
    required this.conversationResponse,
  });

  final VoiceAiAssistResponse reviewResponse;
  final VoiceAiAssistResponse wizardResponse;
  final VoiceAiAssistResponse memoryResponse;
  final VoiceAiAssistResponse conversationResponse;

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

  @override
  Future<VoiceAiAssistResponse> conversationTurn(
    VoiceAiAssistRequest request,
  ) async {
    lastRequest = request;
    lastMethod = 'conversation';
    return conversationResponse;
  }
}

class _FakeVoiceAiAssistAdapter implements VoiceAiAssistAdapter {
  _FakeVoiceAiAssistAdapter(this.response);

  final VoiceAiAssistResponse response;

  @override
  Future<VoiceAiAssistResponse> guideWizard(
    VoiceAiAssistRequest request,
  ) async {
    return response;
  }

  @override
  Future<VoiceAiAssistResponse> reviewTranscript(
    VoiceAiAssistRequest request,
  ) async {
    return response;
  }

  @override
  Future<VoiceAiAssistResponse> summarizeMemory(
    VoiceAiAssistRequest request,
  ) async {
    return response;
  }

  @override
  Future<VoiceAiAssistResponse> conversationTurn(
    VoiceAiAssistRequest request,
  ) async {
    return response;
  }
}

void main() {
  test(
    'voice assistant response contract is shared across local and ai paths',
    () {
      const localResponse = VoiceCommandAssistantResponse(
        summary: 'Local summary',
        nextStep: 'Local next step',
        projectContext: 'MicroGrow',
        threadContext: 'Thread context',
      );
      const aiResponse = VoiceAiAssistResponse(
        summary: 'AI summary',
        nextStep: 'AI next step',
        suggestedTitle: 'Draft title',
        suggestedSummary: 'Draft summary',
        suggestedWizardAnswer: 'Draft wizard answer',
        suggestedType: VoiceCommandType.task,
        hints: ['calm', 'review-first'],
        projectContext: 'MicroGrow',
        threadContext: 'Thread context',
      );

      expect(localResponse, isA<VoiceAssistantResponse>());
      expect(aiResponse, isA<VoiceAssistantResponse>());
      expect(localResponse.projectContext, 'MicroGrow');
      expect(localResponse.threadContext, 'Thread context');
      expect(aiResponse.suggestedTitle, 'Draft title');
      expect(aiResponse.suggestedWizardAnswer, 'Draft wizard answer');
      expect(aiResponse.hints, ['calm', 'review-first']);
    },
  );

  test('voice ai assist provider returns the local adapter stub', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final adapter = container.read(voiceAiAssistAdapterProvider);
    final service = container.read(voiceAiAssistServiceProvider);

    expect(adapter, isA<LocalVoiceAiAssistService>());
    expect(service, isA<LocalVoiceAiAssistService>());
  });

  test('voice ai assist adapter provider can be swapped independently', () {
    final fakeAdapter = _FakeVoiceAiAssistAdapter(
      const VoiceAiAssistResponse(
        summary: 'adapter summary',
        nextStep: 'adapter next',
      ),
    );
    final container = ProviderContainer(
      overrides: [voiceAiAssistAdapterProvider.overrideWithValue(fakeAdapter)],
    );
    addTearDown(container.dispose);

    expect(container.read(voiceAiAssistAdapterProvider), fakeAdapter);
    expect(
      container.read(voiceAiAssistServiceProvider),
      isA<LocalVoiceAiAssistService>(),
    );
  });

  test('voice ai local stub provider can be swapped independently', () {
    const fakeStub = NoOpVoiceAiAssistService();
    final container = ProviderContainer(
      overrides: [voiceAiLocalStubProvider.overrideWithValue(fakeStub)],
    );
    addTearDown(container.dispose);

    expect(container.read(voiceAiLocalStubProvider), fakeStub);
    expect(container.read(voiceAiAssistAdapterProvider), fakeStub);
    expect(container.read(voiceAiAssistServiceProvider), fakeStub);
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
    expect(
      response.nextStep,
      contains('Confirm the category, priority, and owner'),
    );
    expect(response.suggestedTitle, 'Dashboard cards');
    expect(response.suggestedSummary, contains('Review the dashboard cards'));
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
      expect(
        wizardResponse.nextStep,
        contains('Answer with only the details needed'),
      );
      expect(wizardResponse.suggestedTitle, 'create the first milestone');
      expect(
        wizardResponse.suggestedSummary,
        contains('Project: create the first milestone'),
      );
      expect(
        wizardResponse.suggestedWizardAnswer,
        contains('create the first milestone'),
      );
      expect(wizardResponse.hints, contains('Local AI adapter active.'));
      expect(wizardResponse.hints, contains('Current step: Details'));
      expect(memoryResponse.summary, contains('MicroGrow'));
      expect(memoryResponse.summary, contains('Latest entry'));
      expect(memoryResponse.nextStep, contains('Reopen the project flow'));
      expect(
        memoryResponse.suggestedSummary,
        contains('Follow up with the dashboard voice workflow'),
      );
      expect(memoryResponse.hints, contains('Remembered thread is available.'));
      expect(memoryResponse.hints, contains('3 saved entries'));
      expect(
        memoryResponse.hints,
        contains('Latest entry: Follow up with the dashboard voice workflow.'),
      );
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
        conversationResponse: const VoiceAiAssistResponse(
          summary: 'conversation summary',
          nextStep: 'conversation next',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          voiceAiAssistAdapterProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      final wizardResponse = await container.read(
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

      final memoryResponse = await container.read(
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

      final reviewResponse = await container.read(
        voiceAiBriefingAssistProvider(
          const VoiceAiAssistRequest(
            transcript: 'Review the dashboard cards and tighten the wording.',
            selectedType: VoiceCommandType.task,
          ),
        ).future,
      );
      expect(fakeService.lastMethod, 'review');
      expect(reviewResponse.summary, 'review summary');

      final conversationResponse = await container.read(
        voiceAiConversationAssistProvider(
          const VoiceAiAssistRequest(
            transcript: 'Open dashboard',
            conversationContext: VoiceConversationContext(
              label: 'Dashboard',
              summary: 'Shared voice thread',
            ),
          ),
        ).future,
      );
      expect(fakeService.lastMethod, 'conversation');
      expect(conversationResponse.summary, 'conversation summary');
    },
  );

  test('openai voice ai parser keeps partial responses safe', () {
    const fallback = VoiceAiAssistResponse(
      summary: 'Local summary',
      nextStep: 'Local next step',
      suggestedTitle: 'Local title',
      suggestedSummary: 'Local summary draft',
      suggestedWizardAnswer: 'Local wizard answer',
      suggestedType: VoiceCommandType.task,
      hints: ['Local hint'],
    );

    final parsed = parseOpenAiVoiceAiAssistResponse('''
SUMMARY: Assistant heard a task capture.
NEXT_STEP: Confirm the category, priority, and owner.
TITLE: Dashboard follow-up
SUGGESTED_SUMMARY: Review the dashboard cards and tighten the wording.
SUGGESTED_WIZARD_ANSWER: Planning
TYPE: task
HINTS: calm | review-first | local save
''', fallback: fallback);

    expect(parsed.summary, 'Assistant heard a task capture.');
    expect(parsed.nextStep, 'Confirm the category, priority, and owner.');
    expect(parsed.suggestedTitle, 'Dashboard follow-up');
    expect(
      parsed.suggestedSummary,
      'Review the dashboard cards and tighten the wording.',
    );
    expect(parsed.suggestedWizardAnswer, 'Planning');
    expect(parsed.suggestedType, VoiceCommandType.task);
    expect(parsed.hints, ['calm', 'review-first', 'local save']);
  });
}
