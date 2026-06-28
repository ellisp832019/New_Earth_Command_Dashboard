import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/core/services/daily_plan_service.dart';
import 'package:new_earth_command_dashboard/core/services/seed_data_service.dart';
import 'package:new_earth_command_dashboard/features/dashboard/data/dashboard_repository.dart';
import 'package:new_earth_command_dashboard/features/planner/data/daily_plan_repository.dart';
import 'package:new_earth_command_dashboard/features/tasks/data/task_repository.dart';

void main() {
  test(
    'dashboard repository loads today plan and seeded project count',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final today = DateTime(2026, 5, 2, 8);
      await SeedDataService(database).ensureSeedData();
      await DailyPlanService(database, now: () => today).ensureTodayPlan();

      final snapshot = await DashboardRepository(
        database,
        now: () => today,
      ).loadTodaySnapshot();

      expect(snapshot.date, DateTime(2026, 5, 2));
      expect(snapshot.hasTodayPlan, isTrue);
      expect(snapshot.activeProjectCount, 9);
      expect(snapshot.topTaskTitles, isEmpty);
      expect(snapshot.topTasks, isEmpty);
      expect(snapshot.nextStepTitle, 'Next useful move');
      expect(snapshot.nextStepSummary, startsWith('Continue '));
      expect(snapshot.nextStepReason, contains('project context'));
    },
  );

  test(
    'dashboard repository loads Top 3 task titles in selection order',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final today = DateTime(2026, 5, 2, 8);
      await DailyPlanService(database, now: () => today).ensureTodayPlan();
      var minute = 0;
      final taskRepository = TaskRepository(
        database,
        now: () => DateTime(2026, 5, 2, 9, minute++),
      );
      final dailyPlanRepository = DailyPlanRepository(
        database,
        now: () => today,
      );
      final first = await taskRepository.createTask(title: 'Choose calm focus');
      final second = await taskRepository.createTask(
        title: 'Build dashboard data',
      );

      await dailyPlanRepository.saveTopThreeTaskIds([
        first.taskId,
        second.taskId,
      ]);

      final snapshot = await DashboardRepository(
        database,
        now: () => DateTime(2026, 5, 2),
      ).loadTodaySnapshot();

      expect(snapshot.topTaskTitles, [
        'Choose calm focus',
        'Build dashboard data',
      ]);
      expect(snapshot.topTasks, hasLength(2));
      expect(snapshot.topTasks.first.taskId, first.taskId);
      expect(snapshot.topTasks.first.status, 'Inbox');
      expect(snapshot.nextStepTitle, 'Next useful move');
      expect(snapshot.nextStepSummary, 'Start with Choose calm focus.');
      expect(
        snapshot.nextStepReason,
        'It is already in the Top 3, so it is the clearest local move.',
      );
    },
  );

  test(
    'dashboard repository prefers tomorrow focus after evening review is saved',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final today = DateTime(2026, 5, 2, 20);
      await DailyPlanService(database, now: () => today).ensureTodayPlan();
      final dailyPlanRepository = DailyPlanRepository(
        database,
        now: () => today,
      );

      await dailyPlanRepository.updateTomorrowFocus(
        'Start with the next calm dashboard pass.',
      );
      await dailyPlanRepository.updateEveningReview(
        movedForward: 'Closed the day without losing the thread.',
        completed: 'Saved the handoff state.',
        learned: 'A visible handoff reduces restart friction.',
        blockers: '',
      );

      final snapshot = await DashboardRepository(
        database,
        now: () => today,
      ).loadTodaySnapshot();

      expect(snapshot.hasEveningReview, isTrue);
      expect(snapshot.nextStepTitle, 'Tomorrow is already lined up');
      expect(
        snapshot.nextStepSummary,
        'Start with the next calm dashboard pass.',
      );
      expect(snapshot.nextStepReason, contains('next useful move is waiting'));
    },
  );

  test(
    'dashboard repository falls back to carry forward notes before generic guidance',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final today = DateTime(2026, 5, 2, 20);
      await DailyPlanService(database, now: () => today).ensureTodayPlan();
      await DailyPlanRepository(
        database,
        now: () => today,
      ).updateCarryForwardNotes(
        'Carry forward the project cleanup before adding anything new.',
      );

      final snapshot = await DashboardRepository(
        database,
        now: () => today,
      ).loadTodaySnapshot();

      expect(snapshot.nextStepTitle, 'Pick up the handoff gently');
      expect(
        snapshot.nextStepSummary,
        'Carry forward the project cleanup before adding anything new.',
      );
      expect(snapshot.nextStepReason, contains('carry-forward note'));
    },
  );
}
