import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/core/services/task_selection_service.dart';
import 'package:new_earth_command_dashboard/features/planner/data/daily_plan_repository.dart';
import 'package:new_earth_command_dashboard/features/tasks/data/task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_earth_command_dashboard/features/tasks/application/tasks_controller.dart';

void main() {
  test('task repository creates and lists active tasks', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = TaskRepository(
      database,
      now: () => DateTime(2026, 5, 2, 10),
    );

    final task = await repository.createTask(
      title: 'Build task repository',
      category: 'Build',
      priority: 'High',
      energyLevel: 'Medium',
      estimatedMinutes: 45,
    );
    final tasks = await repository.getActiveTasks();

    expect(task.title, 'Build task repository');
    expect(task.status, 'Inbox');
    expect(task.priority, 'High');
    expect(task.isTopThree, isFalse);
    expect(tasks, hasLength(1));
  });

  test('task repository marks tasks done and parks tasks calmly', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = TaskRepository(
      database,
      now: () => DateTime(2026, 5, 2, 11),
    );

    final doneTask = await repository.createTask(title: 'Finish foundation');
    final parkedTask = await repository.createTask(title: 'Future idea');
    await repository.setTopThree(doneTask.taskId, isTopThree: true);
    await repository.setTopThree(parkedTask.taskId, isTopThree: true);

    await repository.markDone(doneTask.taskId);
    await repository.parkTask(parkedTask.taskId);

    final reloadedDoneTask = await repository.getById(doneTask.taskId);
    final reloadedParkedTask = await repository.getById(parkedTask.taskId);

    expect(reloadedDoneTask.status, 'Done');
    expect(reloadedDoneTask.completedAt, DateTime(2026, 5, 2, 11));
    expect(reloadedDoneTask.isTopThree, isFalse);
    expect(reloadedParkedTask.status, 'Parked');
    expect(reloadedParkedTask.completedAt, isNull);
    expect(reloadedParkedTask.isTopThree, isFalse);
  });

  test('task repository moves a task to today', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = TaskRepository(
      database,
      now: () => DateTime(2026, 5, 2, 11, 30),
    );

    final task = await repository.createTask(title: 'Shift this into today');

    await repository.moveToToday(task.taskId);

    final reloadedTask = await repository.getById(task.taskId);

    expect(reloadedTask.status, 'Today');
    expect(reloadedTask.updatedAt, DateTime(2026, 5, 2, 11, 30));
  });

  test(
    'task repository archives a task and removes it from active queries',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = TaskRepository(
        database,
        now: () => DateTime(2026, 5, 2, 11, 45),
      );

      final task = await repository.createTask(title: 'Archive me');
      await repository.setTopThree(task.taskId, isTopThree: true);

      await repository.archiveTask(task.taskId);

      final reloadedTask = await repository.getById(task.taskId);
      final activeTasks = await repository.getActiveTasks();

      expect(reloadedTask.isArchived, isTrue);
      expect(reloadedTask.isTopThree, isFalse);
      expect(activeTasks, isEmpty);
    },
  );

  test(
    'task repository updates task fields and clears Top 3 when done',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = TaskRepository(
        database,
        now: () => DateTime(2026, 5, 2, 12),
      );

      final task = await repository.createTask(
        title: 'Original task',
        status: 'Inbox',
      );
      await repository.setTopThree(task.taskId, isTopThree: true);

      final updatedTask = await repository.updateTask(
        taskId: task.taskId,
        title: 'Updated task',
        projectId: 'project-microgrow',
        description: 'A more useful next step.',
        category: 'Build',
        priority: 'High',
        status: 'Done',
        energyLevel: 'High',
        estimatedMinutes: 30,
        notes: 'Keep this grounded.',
      );

      expect(updatedTask.title, 'Updated task');
      expect(updatedTask.projectId, 'project-microgrow');
      expect(updatedTask.description, 'A more useful next step.');
      expect(updatedTask.category, 'Build');
      expect(updatedTask.priority, 'High');
      expect(updatedTask.status, 'Done');
      expect(updatedTask.energyLevel, 'High');
      expect(updatedTask.estimatedMinutes, 30);
      expect(updatedTask.notes, 'Keep this grounded.');
      expect(updatedTask.completedAt, DateTime(2026, 5, 2, 12));
      expect(updatedTask.isTopThree, isFalse);
    },
  );

  test('task selection service enforces the Top 3 task limit', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = TaskRepository(database);
    final service = TaskSelectionService(repository);
    final tasks = [
      await repository.createTask(title: 'One'),
      await repository.createTask(title: 'Two'),
      await repository.createTask(title: 'Three'),
      await repository.createTask(title: 'Four'),
    ];

    await service.addToTopThree(tasks[0].taskId);
    await service.addToTopThree(tasks[1].taskId);
    await service.addToTopThree(tasks[2].taskId);

    expect(
      () => service.addToTopThree(tasks[3].taskId),
      throwsA(isA<StateError>()),
    );
    expect(await repository.getTopThreeTasks(), hasLength(3));
  });

  test('task selection service can remove and replace a Top 3 task', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = TaskRepository(database);
    final service = TaskSelectionService(repository);
    final first = await repository.createTask(title: 'First');
    final second = await repository.createTask(title: 'Second');

    await service.addToTopThree(first.taskId);
    await service.removeFromTopThree(first.taskId);
    await service.addToTopThree(second.taskId);

    final topTasks = await repository.getTopThreeTasks();

    expect(topTasks, hasLength(1));
    expect(topTasks.single.taskId, second.taskId);
  });

  test(
    'tasks controller marks a Top 3 task done and removes it from today plan',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 11);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) => database),
          databaseReadyProvider.overrideWith((ref) async {}),
        ],
      );
      addTearDown(container.dispose);

      final taskRepository = TaskRepository(database, now: () => today);
      final dailyPlanRepository = DailyPlanRepository(
        database,
        now: () => today,
      );
      await database
          .into(database.dailyPlans)
          .insert(
            DailyPlansCompanion.insert(
              dailyPlanId:
                  'daily-plan-${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
              date: DateTime(today.year, today.month, today.day),
              createdAt: today,
              updatedAt: today,
            ),
          );

      final task = await taskRepository.createTask(title: 'Finish foundation');
      await dailyPlanRepository.saveTopThreeTaskIds([task.taskId]);

      await container.read(tasksControllerProvider).markTaskDone(task.taskId);

      final reloadedTask = await taskRepository.getById(task.taskId);
      final plan = await dailyPlanRepository.getTodayPlan();

      expect(reloadedTask.status, 'Done');
      expect(reloadedTask.isTopThree, isFalse);
      expect(plan.topTask1Id, isNull);
    },
  );

  test(
    'tasks controller parks a Top 3 task and removes it from today plan',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 11);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) => database),
          databaseReadyProvider.overrideWith((ref) async {}),
        ],
      );
      addTearDown(container.dispose);

      final taskRepository = TaskRepository(database, now: () => today);
      final dailyPlanRepository = DailyPlanRepository(
        database,
        now: () => today,
      );
      await database
          .into(database.dailyPlans)
          .insert(
            DailyPlansCompanion.insert(
              dailyPlanId:
                  'daily-plan-${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
              date: DateTime(today.year, today.month, today.day),
              createdAt: today,
              updatedAt: today,
            ),
          );

      final task = await taskRepository.createTask(title: 'Park this one');
      await dailyPlanRepository.saveTopThreeTaskIds([task.taskId]);

      await container.read(tasksControllerProvider).parkTask(task.taskId);

      final reloadedTask = await taskRepository.getById(task.taskId);
      final plan = await dailyPlanRepository.getTodayPlan();

      expect(reloadedTask.status, 'Parked');
      expect(reloadedTask.isTopThree, isFalse);
      expect(plan.topTask1Id, isNull);
    },
  );

  test(
    'tasks controller archives a Top 3 task and removes it from today plan',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 11);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) => database),
          databaseReadyProvider.overrideWith((ref) async {}),
        ],
      );
      addTearDown(container.dispose);

      final taskRepository = TaskRepository(database, now: () => today);
      final dailyPlanRepository = DailyPlanRepository(
        database,
        now: () => today,
      );
      await database
          .into(database.dailyPlans)
          .insert(
            DailyPlansCompanion.insert(
              dailyPlanId:
                  'daily-plan-${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
              date: DateTime(today.year, today.month, today.day),
              createdAt: today,
              updatedAt: today,
            ),
          );

      final task = await taskRepository.createTask(title: 'Archive this one');
      await dailyPlanRepository.saveTopThreeTaskIds([task.taskId]);

      await container.read(tasksControllerProvider).archiveTask(task.taskId);

      final reloadedTask = await taskRepository.getById(task.taskId);
      final plan = await dailyPlanRepository.getTodayPlan();

      expect(reloadedTask.isArchived, isTrue);
      expect(reloadedTask.isTopThree, isFalse);
      expect(plan.topTask1Id, isNull);
    },
  );

  test('tasks controller moves tasks into inbox and planned states', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 11);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) => database),
        databaseReadyProvider.overrideWith((ref) async {}),
      ],
    );
    addTearDown(container.dispose);

    final taskRepository = TaskRepository(database, now: () => today);
    final task = await taskRepository.createTask(
      title: 'Smart move me',
      status: 'Today',
    );

    await container.read(tasksControllerProvider).moveTaskToInbox(task.taskId);
    final inboxTask = await taskRepository.getById(task.taskId);
    expect(inboxTask.status, 'Inbox');

    await container
        .read(tasksControllerProvider)
        .moveTaskToPlanned(task.taskId);
    final plannedTask = await taskRepository.getById(task.taskId);
    expect(plannedTask.status, 'Planned');
  });

  test(
    'tasks controller marks top tasks as blocked and removes them from Top 3',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 11);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) => database),
          databaseReadyProvider.overrideWith((ref) async {}),
        ],
      );
      addTearDown(container.dispose);

      final taskRepository = TaskRepository(database, now: () => today);
      final dailyPlanRepository = DailyPlanRepository(
        database,
        now: () => today,
      );
      await database
          .into(database.dailyPlans)
          .insert(
            DailyPlansCompanion.insert(
              dailyPlanId:
                  'daily-plan-${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
              date: DateTime(today.year, today.month, today.day),
              createdAt: today,
              updatedAt: today,
            ),
          );
      final task = await taskRepository.createTask(
        title: 'Smart block me',
        status: 'Today',
      );
      await dailyPlanRepository.saveTopThreeTaskIds([task.taskId]);

      await container
          .read(tasksControllerProvider)
          .markTaskBlocked(task.taskId);

      final blockedTask = await taskRepository.getById(task.taskId);
      expect(blockedTask.status, 'Blocked');
      expect(blockedTask.isTopThree, isFalse);

      final plan = await dailyPlanRepository.getTodayPlan();
      expect(plan.topTask1Id, isNull);
      expect(plan.topTask2Id, isNull);
      expect(plan.topTask3Id, isNull);
    },
  );
}
