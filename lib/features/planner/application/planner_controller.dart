import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../dashboard/application/dashboard_controller.dart';
import '../../tasks/application/tasks_controller.dart';
import '../data/daily_plan_repository.dart';

final dailyPlanRepositoryProvider = Provider<DailyPlanRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return DailyPlanRepository(database);
});

final todayPlanProvider = FutureProvider<DailyPlan>((ref) async {
  await ref.watch(databaseReadyProvider.future);
  return ref.watch(dailyPlanRepositoryProvider).getTodayPlan();
});

final plannerTaskOptionsProvider = FutureProvider<List<Task>>((ref) async {
  await ref.watch(databaseReadyProvider.future);
  final tasks = await ref.watch(taskRepositoryProvider).getActiveTasks();

  return tasks
      .where((task) => task.status != 'Done' && task.status != 'Parked')
      .toList();
});

final plannerControllerProvider = Provider<PlannerController>((ref) {
  return PlannerController(ref);
});

class PlannerController {
  PlannerController(this._ref);

  final Ref _ref;

  Future<void> saveMorningIntention(String value) async {
    await _ref.read(dailyPlanRepositoryProvider).updateMorningIntention(value);
    _refreshPlannerData();
  }

  Future<void> saveMainFocus(String value) async {
    await _ref.read(dailyPlanRepositoryProvider).updateMainFocus(value);
    _refreshPlannerData();
  }

  Future<void> saveTopThreeTaskIds(List<String> taskIds) async {
    await _ref.read(dailyPlanRepositoryProvider).saveTopThreeTaskIds(taskIds);
    _refreshPlannerData();
    _ref.invalidate(plannerTaskOptionsProvider);
    _ref.invalidate(tasksProvider);
  }

  void _refreshPlannerData() {
    _ref.invalidate(todayPlanProvider);
    _ref.invalidate(dashboardSnapshotProvider);
  }
}
