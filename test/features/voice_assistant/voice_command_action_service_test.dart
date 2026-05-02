import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/tasks/data/task_repository.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_action_service.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_model.dart';
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
    expect(tasks.single.description, contains('tighten the wording'));
    expect(tasks.single.notes, 'Captured from the Voice Assistant.');
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
