import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../dashboard/application/dashboard_controller.dart';
import '../../journal/application/journal_controller.dart';
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

  Future<void> saveFocusReason(String value) async {
    await _ref.read(dailyPlanRepositoryProvider).updateFocusReason(value);
    _refreshPlannerData();
  }

  Future<void> clearFocus() async {
    await _ref.read(dailyPlanRepositoryProvider).clearFocus();
    _refreshPlannerData();
  }

  Future<void> saveCarryForwardNotes(String value) async {
    await _ref.read(dailyPlanRepositoryProvider).updateCarryForwardNotes(value);
    _refreshPlannerData();
  }

  Future<void> saveTomorrowFocus(String value) async {
    await _ref.read(dailyPlanRepositoryProvider).updateTomorrowFocus(value);
    _refreshPlannerData();
  }

  Future<void> saveEveningReview({
    required String movedForward,
    required String completed,
    required String learned,
    required String blockers,
  }) async {
    await _ref
        .read(dailyPlanRepositoryProvider)
        .updateEveningReview(
          movedForward: movedForward,
          completed: completed,
          learned: learned,
          blockers: blockers,
        );
    _refreshPlannerData();
  }

  Future<void> createJournalFromEveningReview({
    required String movedForward,
    required String completed,
    required String learned,
    required String blockers,
    required String carryForward,
    required String tomorrowFocus,
  }) async {
    await saveEveningReview(
      movedForward: movedForward,
      completed: completed,
      learned: learned,
      blockers: blockers,
    );

    final todayPlan = await _ref
        .read(dailyPlanRepositoryProvider)
        .getTodayPlan();
    final reviewDate = todayPlan.date;
    final title =
        'Daily Review ${reviewDate.year.toString().padLeft(4, '0')}-${reviewDate.month.toString().padLeft(2, '0')}-${reviewDate.day.toString().padLeft(2, '0')}';

    final workedOnParts = <String>[
      if (movedForward.trim().isNotEmpty)
        'Moved forward: ${movedForward.trim()}',
      if (completed.trim().isNotEmpty) 'Completed: ${completed.trim()}',
      if (blockers.trim().isNotEmpty) 'Blocked by: ${blockers.trim()}',
    ];
    final nextActionParts = <String>[
      if (carryForward.trim().isNotEmpty)
        'Carry forward: ${carryForward.trim()}',
      if (tomorrowFocus.trim().isNotEmpty)
        'Tomorrow focus: ${tomorrowFocus.trim()}',
    ];

    await _ref
        .read(journalActionsControllerProvider)
        .createEntry(
          date: reviewDate,
          title: title,
          category: 'Build Log',
          whatIWorkedOn: workedOnParts.isEmpty
              ? null
              : workedOnParts.join('\n\n'),
          whatILearned: learned.trim().isEmpty ? null : learned.trim(),
          nextActions: nextActionParts.isEmpty
              ? null
              : nextActionParts.join('\n\n'),
        );
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
