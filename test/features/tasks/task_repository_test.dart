import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/core/services/task_selection_service.dart';
import 'package:new_earth_command_dashboard/features/tasks/data/task_repository.dart';

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
}
