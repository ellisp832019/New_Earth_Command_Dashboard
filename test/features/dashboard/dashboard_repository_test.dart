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
    },
  );
}
