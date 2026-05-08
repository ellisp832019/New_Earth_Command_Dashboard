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

    expect(templates, hasLength(7));
    expect(templates.first.id, 'build-day');
    expect(templates.first.type, VoiceCommandType.task);
    expect(templates.any((template) => template.id == 'codex'), isTrue);
  });

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
    final suggestion = service.suggestCommand(transcript: 'Task: fix the task flow');
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

  test('voice command service builds wizard prompts and transcript pieces', () {
    final service = VoiceCommandService();

    final typePrompt = service.buildWizardPrompt(
      step: VoiceWizardStep.type,
    );
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
