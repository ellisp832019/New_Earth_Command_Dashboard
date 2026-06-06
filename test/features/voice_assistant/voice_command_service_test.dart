import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_model.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_service.dart';

void main() {
  test('voice command service stores history in newest first order', () {
    var minute = 0;
    final service = VoiceCommandService(
      now: () => DateTime(2026, 5, 2, 9, minute++),
    );

    service.addCommand(
      transcript: 'Save this as a task',
      type: VoiceCommandType.task,
    );
    service.addCommand(
      transcript: 'Turn this into a journal entry',
      type: VoiceCommandType.journalEntry,
    );

    final history = service.getHistory();

    expect(history, hasLength(2));
    expect(history.first.transcript, 'Turn this into a journal entry');
    expect(history.last.transcript, 'Save this as a task');
  });

  test('voice command service exposes starter templates', () {
    final service = VoiceCommandService();
    final templates = service.getTemplates();

    expect(templates, hasLength(17));
    expect(templates.first.id, 'build-day');
    expect(templates.first.type, VoiceCommandType.task);
    expect(
      templates.any((template) => template.id == 'summarize-today'),
      isTrue,
    );
    expect(templates.any((template) => template.id == 'whats-next'), isTrue);
    expect(templates.any((template) => template.id == 'recall-thread'), isTrue);
    expect(templates.any((template) => template.id == 'plan-day'), isTrue);
    expect(templates.any((template) => template.id == 'project'), isTrue);
    expect(templates.any((template) => template.id == 'carry-forward'), isTrue);
    expect(templates.any((template) => template.id == 'meeting-notes'), isTrue);
    expect(
      templates.any((template) => template.id == 'project-checkpoint'),
      isTrue,
    );
    expect(
      templates.any((template) => template.id == 'business-follow-up'),
      isTrue,
    );
    expect(templates.any((template) => template.id == 'quick-review'), isTrue);
    expect(templates.any((template) => template.id == 'codex'), isTrue);
  });

  test('voice command service exposes action macros', () {
    final service = VoiceCommandService();
    final macros = service.buildMacroActions();
    final macroIds = macros.map((action) => action.id).toList();

    expect(macroIds, contains('start-build-day'));
    expect(macroIds, contains('plan-day'));
    expect(macroIds, contains('summarize-today'));
    expect(macroIds, contains('recall-memory'));
    expect(macroIds, contains('whats-next'));
    expect(macroIds, isNot(contains('continue-thread')));
  });

  test('voice command service resolves spoken macro follow-ups', () {
    final service = VoiceCommandService();

    final planAction = service.resolveFollowUpAction(
      transcript: 'Plan my day around this thread.',
    );
    final createProjectAction = service.resolveFollowUpAction(
      transcript: 'Create a project for the dashboard voice workflow.',
    );
    final recallAction = service.resolveFollowUpAction(
      transcript: 'What do you remember about this thread?',
    );

    expect(planAction?.id, 'plan-day');
    expect(createProjectAction?.id, 'load-project');
    expect(recallAction?.id, 'recall-memory');
  });

  test(
    'voice command service keeps the continue thread macro available when memory exists',
    () {
      final service = VoiceCommandService();
      final conversationContext = service.buildConversationContext(
        transcript: 'Create a project for the dashboard voice workflow.',
        type: VoiceCommandType.project,
        title: 'Dashboard voice workflow',
        projectName: 'MicroGrow',
      );

      final macros = service.buildMacroActions(
        conversationContext: conversationContext,
      );
      final followUpAction = service.resolveFollowUpAction(
        transcript: 'Continue thread',
        conversationContext: conversationContext,
      );

      expect(macros.map((action) => action.id), contains('continue-thread'));
      expect(followUpAction?.id, 'continue-thread');
    },
  );

  test('voice command service suggests quick actions for build day', () {
    final service = VoiceCommandService();
    final actions = service.suggestQuickActions(
      transcript: 'Start my build day and review the plan.',
    );

    expect(actions.first.label, 'Open Dashboard');
    expect(actions.map((action) => action.id), contains('load-build-day'));
    expect(actions.map((action) => action.route), contains('/planner'));
  });

  test('voice command service suggests quick actions for tasks', () {
    final service = VoiceCommandService();
    final suggestion = service.suggestCommand(
      transcript: 'Task: fix the task flow',
    );
    final actions = service.suggestQuickActions(
      transcript: suggestion.transcript,
      suggestion: suggestion,
    );

    expect(actions.first.label, 'Open Tasks');
    expect(actions.map((action) => action.templateId), contains('task'));
  });

  test('voice command service builds an assistant reply', () {
    final service = VoiceCommandService();
    final suggestion = service.suggestCommand(
      transcript: 'Business: follow up with Sahil Kumar about the next step',
    );
    final response = service.buildAssistantResponse(
      transcript: suggestion.transcript,
      suggestion: suggestion,
    );

    expect(response.summary, contains('business lead'));
    expect(response.nextStep, contains('contact'));
    expect(response.projectContext, isNull);
  });

  test('voice command service builds a briefing with an ordered sequence', () {
    final service = VoiceCommandService();
    final suggestion = service.suggestCommand(
      transcript: 'Start my build day and review what matters most.',
    );
    final briefing = service.buildBriefing(
      transcript: suggestion.transcript,
      suggestion: suggestion,
    );

    expect(briefing.summary, contains('build-day command'));
    expect(briefing.nextStep, contains('Planner'));
    expect(briefing.actions, isNotEmpty);
    expect(briefing.actions.first.label, contains('Dashboard'));
  });

  test('voice command service builds memory and action planning guidance', () {
    final service = VoiceCommandService(now: () => DateTime(2026, 5, 10, 9, 0));

    service.addCommand(
      transcript: 'Review the dashboard cards',
      type: VoiceCommandType.task,
    );
    service.addCommand(
      transcript: 'Create a project for the dashboard voice workflow',
      type: VoiceCommandType.project,
    );

    final suggestion = service.suggestCommand(
      transcript:
          'Project: What do you remember about this thread and how should I plan it?',
    );
    final briefing = service.buildBriefing(
      transcript: suggestion.transcript,
      suggestion: suggestion,
      conversationContext: const VoiceConversationContext(
        label: 'Project · Dashboard voice workflow',
        summary: 'Continuing the dashboard voice workflow thread.',
        type: VoiceCommandType.project,
        projectName: 'MicroGrow',
        title: 'Dashboard voice workflow',
        transcript:
            'Project: Create a project for the dashboard voice workflow.',
        entryCount: 2,
      ),
    );
    final response = service.buildAssistantResponse(
      transcript: suggestion.transcript,
      suggestion: suggestion,
      conversationContext: const VoiceConversationContext(
        label: 'Project · Dashboard voice workflow',
        summary: 'Continuing the dashboard voice workflow thread.',
        type: VoiceCommandType.project,
        projectName: 'MicroGrow',
        title: 'Dashboard voice workflow',
        transcript:
            'Project: Create a project for the dashboard voice workflow.',
        entryCount: 2,
      ),
    );

    expect(briefing.memorySummary, contains('MicroGrow'));
    expect(
      briefing.memoryHighlights.any(
        (highlight) => highlight.startsWith('Thread:'),
      ),
      isTrue,
    );
    expect(
      briefing.memoryHighlights,
      contains('Latest: Dashboard voice workflow'),
    );
    expect(briefing.plannerSummary, contains('project'));
    expect(briefing.plannerSteps, contains('Open Projects'));
    expect(response.summary, contains('remember'));
    expect(
      briefing.memorySummary,
      contains('Latest entry: Dashboard voice workflow.'),
    );
  });

  test('voice command service builds wizard prompts and transcript pieces', () {
    final service = VoiceCommandService();

    final typePrompt = service.buildWizardPrompt(step: VoiceWizardStep.type);
    final detailPrompt = service.buildWizardPrompt(
      step: VoiceWizardStep.details,
      selectedType: VoiceCommandType.businessOpportunity,
    );
    final projectPiece = service.buildWizardTranscriptPiece(
      step: VoiceWizardStep.project,
      answer: 'MicroGrow',
    );

    expect(typePrompt, contains('What kind of entry'));
    expect(detailPrompt, contains('next action'));
    expect(projectPiece, 'Project: MicroGrow.');
  });

  test('voice command service creates the Codex-safe prompt wrapper', () {
    final service = VoiceCommandService();
    final prompt = service.createCodexPrompt('  Update the dashboard cards  ');

    expect(
      prompt,
      contains('You are working inside the New Earth Dashboard repo.'),
    );
    expect(prompt, contains('User voice command:\nUpdate the dashboard cards'));
    expect(prompt, contains('- Do not delete existing work.'));
    expect(prompt, contains('- Ask for approval before major rewrites.'));
  });

  test('voice command service suggests type, title, and project', () {
    final service = VoiceCommandService();
    final suggestion = service.suggestCommand(
      transcript:
          'Business: Follow up with the MicroGrow partner about the next pilot.',
      projectOptions: const [
        VoiceAssistantProjectOption(id: 'project-microgrow', name: 'MicroGrow'),
      ],
    );

    expect(suggestion.suggestedType, VoiceCommandType.businessOpportunity);
    expect(
      suggestion.transcript,
      'Follow up with the MicroGrow partner about the next pilot.',
    );
    expect(
      suggestion.suggestedTitle,
      'Follow up with the MicroGrow partner about the next pilot',
    );
    expect(suggestion.suggestedProjectId, 'project-microgrow');
    expect(suggestion.usedExplicitType, isTrue);
    expect(suggestion.extractedBusinessType, 'Partnership');
    expect(suggestion.extractedBusinessStatus, 'Follow-up Needed');
    expect(suggestion.extractedBusinessContact, isNull);
  });

  test('voice command service suggests project fields from project capture', () {
    final service = VoiceCommandService();
    final suggestion = service.suggestCommand(
      transcript:
          'Project: Launch the voice assistant project. Vision: make the dashboard feel guided. Next action: define the first milestone.',
    );

    expect(suggestion.suggestedType, VoiceCommandType.project);
    expect(suggestion.extractedProjectStatus, 'Active');
    expect(suggestion.extractedProjectPriority, 'Medium');
    expect(suggestion.extractedProjectVision, 'make the dashboard feel guided');
    expect(
      suggestion.extractedProjectNextAction,
      'define the first milestone.',
    );
  });

  test('voice command service builds a project briefing and wizard prompt', () {
    final service = VoiceCommandService();
    final suggestion = service.suggestCommand(
      transcript: 'Project: create a project for the dashboard voice workflow.',
    );
    final briefing = service.buildBriefing(
      transcript: suggestion.transcript,
      suggestion: suggestion,
    );
    final prompt = service.buildWizardPrompt(
      step: VoiceWizardStep.details,
      selectedType: VoiceCommandType.project,
    );

    expect(briefing.summary, contains('project'));
    expect(briefing.nextStep, contains('first next action'));
    expect(prompt, contains('status, priority, vision, or next action'));
  });

  test('voice command service strips the wake phrase and marks it', () {
    final service = VoiceCommandService();
    final suggestion = service.suggestCommand(
      transcript: 'Hey New Earth, task: review the build-day plan.',
    );

    expect(suggestion.usedWakePhrase, isTrue);
    expect(suggestion.wakePhrase, isNotNull);
    expect(suggestion.transcript, 'review the build-day plan.');
    expect(suggestion.suggestedType, VoiceCommandType.task);
    expect(suggestion.isWakeOnly, isFalse);
  });

  test('voice command service treats a wake-only phrase as a wake trigger', () {
    final service = VoiceCommandService();
    final suggestion = service.suggestCommand(transcript: 'Hey Gaia');

    expect(suggestion.usedWakePhrase, isTrue);
    expect(suggestion.wakePhrase, isNotNull);
    expect(suggestion.transcript, isEmpty);
    expect(suggestion.isWakeOnly, isTrue);
  });

  test('voice command service suggests summary and next-step macros', () {
    final service = VoiceCommandService();
    final summaryActions = service.suggestQuickActions(
      transcript: 'Summarize today and what is next for the dashboard?',
    );
    final nextActions = service.suggestQuickActions(
      transcript: 'What should I do next for the voice project?',
    );

    expect(
      summaryActions.map((action) => action.id),
      contains('summarize-today'),
    );
    expect(summaryActions.map((action) => action.route), contains('/planner'));
    expect(nextActions.map((action) => action.id), contains('open-tasks-next'));
    expect(
      nextActions.map((action) => action.id),
      contains('open-projects-next'),
    );
  });

  test('voice command service responds to help-style questions', () {
    final service = VoiceCommandService();
    final response = service.buildAssistantResponse(
      transcript: 'What can you do for me?',
    );

    expect(response.summary, contains('help with tasks'));
    expect(response.nextStep, contains('create a task'));
  });

  test(
    'voice command service responds to a wake phrase with a real request',
    () {
      final service = VoiceCommandService();
      final suggestion = service.suggestCommand(
        transcript: 'Hey Gaia how are you doing',
      );
      final response = service.buildAssistantResponse(
        transcript: suggestion.transcript,
        suggestion: suggestion,
      );

      expect(suggestion.usedWakePhrase, isTrue);
      expect(suggestion.isWakeOnly, isFalse);
      expect(response.summary, contains('I am here with you'));
      expect(response.summary, isNot(contains('Wake phrase heard')));
    },
  );

  test('voice command service remembers a conversation thread', () {
    final service = VoiceCommandService();
    final firstThread = service.buildConversationContext(
      transcript: 'Follow up with Sahil Kumar about the next pilot.',
      type: VoiceCommandType.businessOpportunity,
      title: 'Follow up with Sahil Kumar',
      projectName: 'MicroGrow',
    );
    final continuedThread = service.buildConversationContext(
      transcript: 'Draft the next follow-up note for Sahil Kumar.',
      type: VoiceCommandType.businessOpportunity,
      title: 'Draft the next follow-up note for Sahil Kumar',
      projectName: 'MicroGrow',
      previous: firstThread,
    );
    final prompt = service.buildWizardPrompt(
      step: VoiceWizardStep.title,
      conversationContext: firstThread,
    );
    final actions = service.suggestQuickActions(
      transcript: 'Draft the next follow-up note for Sahil Kumar.',
      conversationContext: firstThread,
    );

    expect(
      firstThread.label,
      'MicroGrow · Business Opportunity · Follow up with Sahil Kumar',
    );
    expect(firstThread.entryCount, 1);
    expect(continuedThread.entryCount, 2);
    expect(firstThread.summary, contains('Starting a new thread around'));
    expect(continuedThread.summary, contains('Continuing the MicroGrow'));
    expect(prompt, contains('Starting a new thread around'));
    expect(actions.map((action) => action.id), contains('continue-thread'));
  });

  test('voice command service infers journal entry from reflective wording', () {
    final service = VoiceCommandService();
    final suggestion = service.suggestCommand(
      transcript:
          'Today I fixed the Windows voice typing flow and learned why focus matters.',
    );

    expect(suggestion.suggestedType, VoiceCommandType.journalEntry);
    expect(
      suggestion.suggestedTitle,
      'Today I fixed the Windows voice typing flow and learned why focus mat...',
    );
    expect(
      suggestion.extractedJournalWorkedOn,
      'fixed the Windows voice typing flow and learned why focus matters.',
    );
  });

  test('voice command service extracts content platform and type', () {
    final service = VoiceCommandService();
    final suggestion = service.suggestCommand(
      transcript:
          'Content: Draft a LinkedIn update about the new dashboard voice workflow.',
    );

    expect(suggestion.suggestedType, VoiceCommandType.contentIdea);
    expect(suggestion.extractedContentPlatform, 'LinkedIn');
    expect(suggestion.extractedContentType, 'LinkedIn Post');
  });

  test('voice command service extracts planning task category', () {
    final service = VoiceCommandService();
    final suggestion = service.suggestCommand(
      transcript: 'Planning: map out the week and review the build priorities.',
    );

    expect(suggestion.suggestedType, VoiceCommandType.task);
    expect(suggestion.extractedTaskCategory, 'Planning');
  });
}
