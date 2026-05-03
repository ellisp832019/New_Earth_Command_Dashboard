import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/core/services/seed_data_service.dart';
import 'package:new_earth_command_dashboard/features/journal/data/journal_repository.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';
import 'package:new_earth_command_dashboard/features/tasks/data/task_repository.dart';

void main() {
  test(
    'project repository returns seeded projects in priority-first order',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await SeedDataService(database).ensureSeedData();

      final projects = await ProjectRepository(database).getProjects();

      expect(projects, hasLength(9));
      expect(projects.first.priority, 'High');
      expect(
        projects.map((project) => project.name),
        containsAll([
          'MicroGrow',
          'MicroGrow Field Scanner',
          'New Earth Website',
          'Future Ideas',
        ]),
      );
    },
  );

  test('project repository creates and updates a project locally', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = ProjectRepository(database);

    final created = await repository.createProject(
      name: 'Test Project',
      shortDescription: 'A calm first project flow.',
      vision: 'Make project creation feel real.',
      status: 'Active',
      priority: 'High',
      progressPercentage: 25,
      currentMilestone: 'Build first detail screen',
      nextAction: 'Save the first project form',
      notes: 'Notes stay local.',
    );

    expect(created.name, 'Test Project');
    expect(created.progressPercentage, 25);

    final updated = await repository.updateProject(
      projectId: created.projectId,
      name: 'Test Project Updated',
      shortDescription: 'A calmer edited project flow.',
      vision: 'Make project editing feel real.',
      status: 'Paused',
      priority: 'Medium',
      progressPercentage: 55,
      currentMilestone: 'Refine the detail screen',
      nextAction: 'Check edited values',
      notes: 'Updated notes stay local.',
    );

    expect(updated.name, 'Test Project Updated');
    expect(updated.status, 'Paused');
    expect(updated.priority, 'Medium');
    expect(updated.progressPercentage, 55);
    expect(updated.nextAction, 'Check edited values');
  });

  test('project repository loads detail with related tasks', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final projectRepository = ProjectRepository(database);
    final taskRepository = TaskRepository(database);
    final journalRepository = JournalRepository(database);

    final project = await projectRepository.createProject(
      name: 'MicroGrow Diagnostics',
      status: 'Active',
      priority: 'High',
    );

    await taskRepository.createTask(
      title: 'Check diagnostics status card',
      projectId: project.projectId,
      status: 'Planned',
      priority: 'High',
    );
    await taskRepository.createTask(
      title: 'Wait for missing sensor board',
      projectId: project.projectId,
      status: 'Blocked',
      priority: 'Medium',
    );
    await journalRepository.createEntry(
      date: DateTime(2026, 5, 2, 10),
      title: 'Diagnostics progress log',
      projectId: project.projectId,
      category: 'Build Log',
      whatIWorkedOn: 'Tracked the first diagnostics improvements.',
    );

    final detail = await projectRepository.getProjectDetail(project.projectId);

    expect(detail.project.projectId, project.projectId);
    expect(detail.activeTasks, hasLength(1));
    expect(detail.blockedTasks, hasLength(1));
    expect(detail.recentJournalEntries, hasLength(1));
    expect(detail.activeTasks.first.title, 'Check diagnostics status card');
    expect(detail.blockedTasks.first.title, 'Wait for missing sensor board');
    expect(detail.recentJournalEntries.first.title, 'Diagnostics progress log');
    expect(
      detail.recentJournalEntries.first.preview,
      'Tracked the first diagnostics improvements.',
    );
  });

  test(
    'project repository archives a project without removing linked tasks',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final projectRepository = ProjectRepository(database);
      final taskRepository = TaskRepository(database);

      final project = await projectRepository.createProject(
        name: 'Archive Ready Project',
        status: 'Active',
        priority: 'Medium',
      );
      await taskRepository.createTask(
        title: 'Keep this task history',
        projectId: project.projectId,
        status: 'Today',
      );

      final archivedProject = await projectRepository.archiveProject(
        project.projectId,
      );
      final activeProjects = await projectRepository.getProjects();
      final relatedTasks = await (database.select(
        database.tasks,
      )..where((table) => table.projectId.equals(project.projectId))).get();

      expect(archivedProject.isArchived, isTrue);
      expect(
        activeProjects.any((item) => item.projectId == project.projectId),
        isFalse,
      );
      expect(relatedTasks, hasLength(1));
      expect(relatedTasks.first.title, 'Keep this task history');
    },
  );
}
