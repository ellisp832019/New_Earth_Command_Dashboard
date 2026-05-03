import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/journal/data/journal_repository.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';
import 'package:new_earth_command_dashboard/features/tasks/data/task_repository.dart';

void main() {
  test(
    'journal repository creates and loads entries with linked labels',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final projectRepository = ProjectRepository(database);
      final taskRepository = TaskRepository(database);
      final journalRepository = JournalRepository(database);

      final project = await projectRepository.createProject(
        name: 'Journal Test Project',
        status: 'Active',
        priority: 'High',
        progressPercentage: 10,
      );
      final task = await taskRepository.createTask(
        title: 'Journal linked task',
        projectId: project.projectId,
        status: 'Today',
      );

      final createdEntry = await journalRepository.createEntry(
        date: DateTime(2026, 5, 2, 15, 30),
        title: 'First build log',
        projectId: project.projectId,
        taskId: task.taskId,
        category: 'Build Log',
        whatIWorkedOn: 'Built the first real journal flow.',
        whatILearned: 'The local data shape is holding together.',
        nextActions: 'Add edit support later.',
      );
      final entries = await journalRepository.getEntries();

      expect(createdEntry.title, 'First build log');
      expect(entries, hasLength(1));
      expect(entries.first.entry.title, 'First build log');
      expect(entries.first.projectName, 'Journal Test Project');
      expect(entries.first.taskTitle, 'Journal linked task');
      expect(entries.first.preview, 'Built the first real journal flow.');
      expect(entries.first.entry.date, DateTime(2026, 5, 2));
    },
  );

  test('journal repository updates an existing entry locally', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final journalRepository = JournalRepository(database);
    final createdEntry = await journalRepository.createEntry(
      date: DateTime(2026, 5, 2),
      title: 'Original journal title',
      category: 'Build Log',
      whatIWorkedOn: 'Original worked on text.',
    );

    final updatedEntry = await journalRepository.updateEntry(
      journalEntryId: createdEntry.journalEntryId,
      date: DateTime(2026, 5, 3),
      title: 'Updated journal title',
      category: 'Reflection',
      whatIWorkedOn: 'Updated worked on text.',
      whatILearned: 'A calmer edit flow matters.',
      nextActions: 'Keep the journal alive.',
    );

    expect(updatedEntry.title, 'Updated journal title');
    expect(updatedEntry.category, 'Reflection');
    expect(updatedEntry.whatIWorkedOn, 'Updated worked on text.');
    expect(updatedEntry.whatILearned, 'A calmer edit flow matters.');
    expect(updatedEntry.nextActions, 'Keep the journal alive.');
    expect(updatedEntry.date, DateTime(2026, 5, 3));
  });
}
