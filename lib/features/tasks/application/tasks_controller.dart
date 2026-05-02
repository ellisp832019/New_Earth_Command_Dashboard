import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../dashboard/application/dashboard_controller.dart';
import '../../planner/application/planner_controller.dart';
import '../../projects/application/projects_controller.dart';
import '../data/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return TaskRepository(database);
});

final tasksProvider = FutureProvider<List<Task>>((ref) async {
  await ref.watch(databaseReadyProvider.future);
  return ref.watch(taskRepositoryProvider).getActiveTasks();
});

final tasksControllerProvider = Provider<TasksController>((ref) {
  return TasksController(ref);
});

final taskProvider = FutureProvider.family<Task, String>((ref, taskId) async {
  await ref.watch(databaseReadyProvider.future);
  return ref.watch(taskRepositoryProvider).getById(taskId);
});

class TasksController {
  TasksController(this._ref);

  final Ref _ref;

  Future<void> toggleTopThreeTask(String taskId) async {
    final todayPlan = await _ref.read(todayPlanProvider.future);
    final selectedTaskIds = _selectedTopTaskIds(todayPlan);

    final updatedTaskIds = selectedTaskIds.contains(taskId)
        ? selectedTaskIds.where((id) => id != taskId).toList()
        : [...selectedTaskIds, taskId];

    await _ref
        .read(dailyPlanRepositoryProvider)
        .saveTopThreeTaskIds(updatedTaskIds);
    _refreshTaskViews();
  }

  Future<void> removeFromTopThree(String taskId) async {
    final todayPlan = await _ref.read(todayPlanProvider.future);
    final selectedTaskIds = _selectedTopTaskIds(
      todayPlan,
    ).where((id) => id != taskId).toList();

    await _ref
        .read(dailyPlanRepositoryProvider)
        .saveTopThreeTaskIds(selectedTaskIds);
    _refreshTaskViews();
  }

  Future<void> markTaskDone(String taskId) async {
    final todayPlan = await _ref.read(todayPlanProvider.future);
    final selectedTaskIds = _selectedTopTaskIds(todayPlan);
    final isTopTask = selectedTaskIds.contains(taskId);

    await _ref.read(taskRepositoryProvider).markDone(taskId);

    if (isTopTask) {
      await _ref
          .read(dailyPlanRepositoryProvider)
          .saveTopThreeTaskIds(
            selectedTaskIds.where((id) => id != taskId).toList(),
          );
    }

    _refreshTaskViews();
  }

  Future<Task> createTask({
    required String title,
    String? projectId,
    String? description,
    String? category,
    String priority = 'Medium',
    String status = 'Inbox',
    String? energyLevel,
    int? estimatedMinutes,
    String? notes,
  }) async {
    final task = await _ref
        .read(taskRepositoryProvider)
        .createTask(
          title: title,
          projectId: projectId,
          description: description,
          category: category,
          priority: priority,
          status: status,
          energyLevel: energyLevel,
          estimatedMinutes: estimatedMinutes,
          notes: notes,
        );

    _refreshTaskViews(projectIds: {projectId}.whereType<String>().toSet());
    _ref.invalidate(taskProvider(task.taskId));
    return task;
  }

  Future<Task> updateTask({
    required String taskId,
    required String title,
    String? projectId,
    String? description,
    String? category,
    required String priority,
    required String status,
    String? energyLevel,
    int? estimatedMinutes,
    String? notes,
  }) async {
    final existing = await _ref.read(taskRepositoryProvider).getById(taskId);
    final todayPlan = await _ref.read(todayPlanProvider.future);
    final selectedTaskIds = _selectedTopTaskIds(todayPlan);

    final task = await _ref
        .read(taskRepositoryProvider)
        .updateTask(
          taskId: taskId,
          title: title,
          projectId: projectId,
          description: description,
          category: category,
          priority: priority,
          status: status,
          energyLevel: energyLevel,
          estimatedMinutes: estimatedMinutes,
          notes: notes,
        );

    if ((status == 'Done' || status == 'Parked') &&
        selectedTaskIds.contains(taskId)) {
      await _ref
          .read(dailyPlanRepositoryProvider)
          .saveTopThreeTaskIds(
            selectedTaskIds.where((id) => id != taskId).toList(),
          );
    }

    _refreshTaskViews(
      projectIds: {existing.projectId, projectId}.whereType<String>().toSet(),
    );
    _ref.invalidate(taskProvider(taskId));
    return task;
  }

  List<String> _selectedTopTaskIds(DailyPlan todayPlan) {
    return [
      todayPlan.topTask1Id,
      todayPlan.topTask2Id,
      todayPlan.topTask3Id,
    ].whereType<String>().toList();
  }

  void _refreshTaskViews({Set<String> projectIds = const {}}) {
    _ref.invalidate(todayPlanProvider);
    _ref.invalidate(tasksProvider);
    _ref.invalidate(plannerTaskOptionsProvider);
    _ref.invalidate(dashboardSnapshotProvider);
    _ref.invalidate(projectsProvider);
    for (final projectId in projectIds) {
      _ref.invalidate(projectDetailProvider(projectId));
    }
  }
}
