import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../dashboard/application/dashboard_controller.dart';
import '../../planner/application/planner_controller.dart';
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

  List<String> _selectedTopTaskIds(DailyPlan todayPlan) {
    return [
      todayPlan.topTask1Id,
      todayPlan.topTask2Id,
      todayPlan.topTask3Id,
    ].whereType<String>().toList();
  }

  void _refreshTaskViews() {
    _ref.invalidate(todayPlanProvider);
    _ref.invalidate(tasksProvider);
    _ref.invalidate(plannerTaskOptionsProvider);
    _ref.invalidate(dashboardSnapshotProvider);
  }
}
