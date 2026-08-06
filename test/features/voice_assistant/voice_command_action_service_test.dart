import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';
import 'package:new_earth_command_dashboard/features/tasks/data/task_repository.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_action_service.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_model.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_service.dart';
import 'package:uuid/uuid.dart';

void main() {
  test('save as task creates a local task record', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final service = VoiceCommandActionService(
      database,
      taskRepository: TaskRepository(database, now: () => DateTime(2026, 5, 2)),
      uuid: const Uuid(),
      now: () => DateTime(2026, 5, 2, 9),
    );

    await service.saveCommand(
      transcript: 'Review the dashboard data cards and tighten the wording.',
      type: VoiceCommandType.task,
      projectId: 'project-microgrow',
    );

    final tasks = await database.select(database.tasks).get();

    expect(tasks, hasLength(1));
    expect(tasks.single.status, 'Inbox');
    expect(tasks.single.projectId, 'project-microgrow');
    expect(
      tasks.single.title,
      'Review the dashboard data cards and tighten the wording.',
    );
    expect(tasks.single.description, contains('tighten the wording'));
    expect(tasks.single.notes, 'Captured from the Voice Assistant.');
  });

  test('save as task uses structured title override when provided', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final service = VoiceCommandActionService(
      database,
      taskRepository: TaskRepository(database, now: () => DateTime(2026, 5, 2)),
      uuid: const Uuid(),
      now: () => DateTime(2026, 5, 2, 9, 30),
    );

    await service.saveCommand(
      transcript:
          'Review the dashboard data cards and tighten the wording before the next pass.',
      type: VoiceCommandType.task,
      projectId: 'project-microgrow',
      titleOverride: 'Review dashboard data cards',
    );

    final tasks = await database.select(database.tasks).get();

    expect(tasks, hasLength(1));
    expect(tasks.single.title, 'Review dashboard data cards');
  });

  test('save as task uses extracted category and priority', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final commandService = VoiceCommandService();
    final suggestion = commandService.suggestCommand(
      transcript: 'Task: urgent build fix for the dashboard cards.',
    );
    final service = VoiceCommandActionService(
      database,
      taskRepository: TaskRepository(database, now: () => DateTime(2026, 5, 2)),
      uuid: const Uuid(),
      now: () => DateTime(2026, 5, 2, 9, 45),
    );

    await service.saveCommand(
      transcript: suggestion.transcript,
      type: suggestion.suggestedType,
      titleOverride: suggestion.suggestedTitle,
      suggestion: suggestion,
    );

    final tasks = await database.select(database.tasks).get();

    expect(tasks.single.category, 'Build');
    expect(tasks.single.priority, 'High');
  });

  test('save as project creates a local project record', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final commandService = VoiceCommandService();
    final suggestion = commandService.suggestCommand(
      transcript:
          'Project: Launch the dashboard voice workflow. Vision: make capture feel guided. Next action: define the first milestone.',
    );
    final service = VoiceCommandActionService(
      database,
      projectRepository: ProjectRepository(
        database,
        now: () => DateTime(2026, 5, 2),
      ),
      uuid: const Uuid(),
      now: () => DateTime(2026, 5, 2, 9, 50),
    );

    await service.saveCommand(
      transcript: suggestion.transcript,
      type: suggestion.suggestedType,
      titleOverride: suggestion.suggestedTitle,
      suggestion: suggestion,
    );

    final projects = await database.select(database.projects).get();

    expect(projects, hasLength(1));
    expect(projects.single.status, 'Active');
    expect(projects.single.priority, 'Medium');
    expect(projects.single.vision, contains('make capture feel guided'));
    expect(projects.single.nextAction, contains('first milestone'));
  });

  test('save as journal entry creates a reflection entry', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final service = VoiceCommandActionService(
      database,
      now: () => DateTime(2026, 5, 2, 10),
    );

    await service.saveCommand(
      transcript: 'Today I connected the first safe voice bridge screen.',
      type: VoiceCommandType.journalEntry,
      projectId: 'project-new-earth-website',
    );

    final entries = await database.select(database.journalEntries).get();

    expect(entries, hasLength(1));
    expect(entries.single.projectId, 'project-new-earth-website');
    expect(entries.single.category, 'Reflection');
    expect(entries.single.whatIWorkedOn, contains('first safe voice bridge'));
    expect(entries.single.tags, 'voice');
  });

  test('save as idea creates an inbox future idea', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final service = VoiceCommandActionService(
      database,
      now: () => DateTime(2026, 5, 2, 11),
    );

    await service.saveCommand(
      transcript: 'Future idea: use voice to start the morning planning flow.',
      type: VoiceCommandType.idea,
      projectId: 'project-future-ideas',
    );

    final ideas = await database.select(database.inboxItems).get();

    expect(ideas, hasLength(1));
    expect(ideas.single.projectId, 'project-future-ideas');
    expect(ideas.single.type, 'Future Idea');
    expect(ideas.single.body, contains('morning planning flow'));
    expect(ideas.single.status, 'New');
  });

  test('save as content idea creates a local content item', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final service = VoiceCommandActionService(
      database,
      now: () => DateTime(2026, 5, 2, 11, 30),
    );

    await service.saveCommand(
      transcript:
          'Draft a short build update about the new voice capture flow.',
      type: VoiceCommandType.contentIdea,
      projectId: 'project-new-earth-website',
    );

    final items = await database.select(database.contentItems).get();

    expect(items, hasLength(1));
    expect(items.single.projectId, 'project-new-earth-website');
    expect(items.single.contentType, 'Project Update');
    expect(items.single.status, 'Idea');
    expect(items.single.draftText, contains('voice capture flow'));
    expect(items.single.notes, 'Captured from the Voice Assistant.');
  });

  test(
    'save as content idea uses extracted platform and content type',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final commandService = VoiceCommandService();
      final suggestion = commandService.suggestCommand(
        transcript:
            'Content: Draft a LinkedIn update about the voice workflow.',
      );
      final service = VoiceCommandActionService(
        database,
        now: () => DateTime(2026, 5, 2, 11, 35),
      );

      await service.saveCommand(
        transcript: suggestion.transcript,
        type: suggestion.suggestedType,
        titleOverride: suggestion.suggestedTitle,
        suggestion: suggestion,
      );

      final items = await database.select(database.contentItems).get();

      expect(items.single.platform, 'LinkedIn');
      expect(items.single.contentType, 'LinkedIn Post');
    },
  );

  test('save as business opportunity creates a local business item', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final service = VoiceCommandActionService(
      database,
      now: () => DateTime(2026, 5, 2, 11, 45),
    );

    await service.saveCommand(
      transcript: 'Follow up with a local partner about MicroGrow pilots.',
      type: VoiceCommandType.businessOpportunity,
      projectId: 'project-microgrow',
    );

    final items = await database.select(database.businessOpportunities).get();

    expect(items, hasLength(1));
    expect(items.single.projectId, 'project-microgrow');
    expect(items.single.type, 'Business Idea');
    expect(items.single.status, 'Researching');
    expect(items.single.nextAction, contains('MicroGrow pilots'));
    expect(items.single.notes, 'Captured from the Voice Assistant.');
  });

  test('save as business opportunity uses extracted business fields', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final commandService = VoiceCommandService();
    final suggestion = commandService.suggestCommand(
      transcript: 'Business: Follow up with OpenAI about the partnership.',
    );
    final service = VoiceCommandActionService(
      database,
      now: () => DateTime(2026, 5, 2, 11, 50),
    );

    await service.saveCommand(
      transcript: suggestion.transcript,
      type: suggestion.suggestedType,
      titleOverride: suggestion.suggestedTitle,
      suggestion: suggestion,
    );

    final items = await database.select(database.businessOpportunities).get();

    expect(items.single.type, 'Partnership');
    expect(items.single.status, 'Follow-up Needed');
    expect(items.single.companyOrContact, 'OpenAI about the partnership');
  });

  test('project options return active projects in name order', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final now = DateTime(2026, 5, 2, 12);
    await database
        .into(database.projects)
        .insert(
          ProjectsCompanion.insert(
            projectId: 'project-zeta',
            name: 'Zeta Project',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.projects)
        .insert(
          ProjectsCompanion.insert(
            projectId: 'project-alpha',
            name: 'Alpha Project',
            createdAt: now,
            updatedAt: now,
          ),
        );

    final service = VoiceCommandActionService(database, now: () => now);
    final options = await service.getProjectOptions();

    expect(options.map((project) => project.name).toList(), [
      'Alpha Project',
      'Zeta Project',
    ]);
  });
}
