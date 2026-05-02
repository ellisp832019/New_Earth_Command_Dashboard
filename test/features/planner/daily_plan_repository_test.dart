import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/core/services/daily_plan_service.dart';
import 'package:new_earth_command_dashboard/features/planner/data/daily_plan_repository.dart';
import 'package:new_earth_command_dashboard/features/tasks/data/task_repository.dart';

void main() {
  test('daily plan repository returns today plan', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final today = DateTime(2026, 5, 2, 9);
    await DailyPlanService(database, now: () => today).ensureTodayPlan();

    final plan = await DailyPlanRepository(
      database,
      now: () => today,
    ).getTodayPlan();

    expect(plan.dailyPlanId, 'daily-plan-2026-05-02');
    expect(plan.date, DateTime(2026, 5, 2));
  });

  test('daily plan repository saves morning intention for today', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final today = DateTime(2026, 5, 2, 9);
    final repository = DailyPlanRepository(database, now: () => today);
    await DailyPlanService(database, now: () => today).ensureTodayPlan();

    await repository.updateMorningIntention(
      'Focus on one useful build step today.',
    );

    final plan = await repository.getTodayPlan();

    expect(plan.morningIntention, 'Focus on one useful build step today.');
  });

  test('daily plan repository saves main focus for today', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final today = DateTime(2026, 5, 2, 9);
    final repository = DailyPlanRepository(database, now: () => today);
    await DailyPlanService(database, now: () => today).ensureTodayPlan();

    await repository.updateMainFocus('Finish the planner editing slice');

    final plan = await repository.getTodayPlan();

    expect(plan.mainFocus, 'Finish the planner editing slice');
  });

  test(
    'daily plan repository saves top 3 task ids and syncs task flags',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final today = DateTime(2026, 5, 2, 9);
      final repository = DailyPlanRepository(database, now: () => today);
      final taskRepository = TaskRepository(database, now: () => today);
      await DailyPlanService(database, now: () => today).ensureTodayPlan();

      final first = await taskRepository.createTask(title: 'One');
      final second = await taskRepository.createTask(title: 'Two');
      final third = await taskRepository.createTask(title: 'Three');

      await repository.saveTopThreeTaskIds([
        first.taskId,
        second.taskId,
        third.taskId,
      ]);

      final plan = await repository.getTodayPlan();
      final reloadedFirst = await taskRepository.getById(first.taskId);
      final reloadedSecond = await taskRepository.getById(second.taskId);
      final reloadedThird = await taskRepository.getById(third.taskId);

      expect(plan.topTask1Id, first.taskId);
      expect(plan.topTask2Id, second.taskId);
      expect(plan.topTask3Id, third.taskId);
      expect(reloadedFirst.isTopThree, isTrue);
      expect(reloadedSecond.isTopThree, isTrue);
      expect(reloadedThird.isTopThree, isTrue);
    },
  );
}
