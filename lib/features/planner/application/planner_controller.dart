import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../dashboard/application/dashboard_controller.dart';
import '../data/daily_plan_repository.dart';

final dailyPlanRepositoryProvider = Provider<DailyPlanRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return DailyPlanRepository(database);
});

final todayPlanProvider = FutureProvider<DailyPlan>((ref) async {
  await ref.watch(databaseReadyProvider.future);
  return ref.watch(dailyPlanRepositoryProvider).getTodayPlan();
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

  void _refreshPlannerData() {
    _ref.invalidate(todayPlanProvider);
    _ref.invalidate(dashboardSnapshotProvider);
  }
}
