import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:new_earth_command_dashboard/app.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/core/services/daily_plan_service.dart';
import 'package:new_earth_command_dashboard/features/dashboard/application/dashboard_controller.dart';
import 'package:new_earth_command_dashboard/features/dashboard/data/dashboard_repository.dart';
import 'package:new_earth_command_dashboard/features/planner/application/planner_controller.dart';
import 'package:new_earth_command_dashboard/features/planner/data/daily_plan_repository.dart';
import 'package:new_earth_command_dashboard/features/projects/application/projects_controller.dart';
import 'package:new_earth_command_dashboard/features/tasks/data/task_repository.dart';
import 'package:new_earth_command_dashboard/features/tasks/application/tasks_controller.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_action_service.dart';

void main() {
  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
        databaseReadyProvider.overrideWith((ref) async {}),
        dashboardSnapshotProvider.overrideWith(
          (ref) async => DashboardSnapshot(
            date: DateTime(2026, 5, 2),
            hasTodayPlan: true,
            activeProjectCount: 9,
            topTasks: const [],
            topTaskTitles: const [],
            mainFocus: null,
            morningIntention: null,
          ),
        ),
        voiceAssistantProjectOptionsProvider.overrideWith(
          (ref) async => const [
            VoiceAssistantProjectOption(
              id: 'project-microgrow',
              name: 'MicroGrow',
            ),
            VoiceAssistantProjectOption(
              id: 'project-new-earth-website',
              name: 'New Earth Website',
            ),
          ],
        ),
        projectsProvider.overrideWith(
          (ref) async => [
            Project(
              projectId: 'project-microgrow',
              name: 'MicroGrow',
              shortDescription: 'Smart grow automation platform.',
              longDescription: null,
              vision: null,
              status: 'Active',
              priority: 'High',
              progressPercentage: 0,
              currentMilestone:
                  'Stabilise core diagnostics and v1.0 direction.',
              nextAction: 'Review current MicroGrow build priorities.',
              startDate: null,
              targetDate: null,
              createdAt: DateTime(2026, 5, 2),
              updatedAt: DateTime(2026, 5, 2),
              notes: null,
              isArchived: false,
            ),
            Project(
              projectId: 'project-new-earth-website',
              name: 'New Earth Website',
              shortDescription:
                  'Public home for New Earth projects and updates.',
              longDescription: null,
              vision: null,
              status: 'Active',
              priority: 'High',
              progressPercentage: 0,
              currentMilestone:
                  'Clarify site structure and founder journey content.',
              nextAction: 'Choose the next page or section to improve.',
              startDate: null,
              targetDate: null,
              createdAt: DateTime(2026, 5, 2),
              updatedAt: DateTime(2026, 5, 2),
              notes: null,
              isArchived: false,
            ),
          ],
        ),
        tasksProvider.overrideWith(
          (ref) async => [
            Task(
              taskId: 'task-1',
              projectId: 'project-microgrow',
              title: 'Review MicroGrow diagnostics',
              description: 'Check the next useful diagnostics step.',
              category: 'Build',
              priority: 'High',
              status: 'Inbox',
              dueDate: null,
              energyLevel: 'Medium',
              estimatedMinutes: null,
              actualMinutes: null,
              createdAt: DateTime(2026, 5, 2, 9),
              updatedAt: DateTime(2026, 5, 2, 9),
              completedAt: null,
              notes: null,
              isTopThree: true,
              isArchived: false,
            ),
            Task(
              taskId: 'task-2',
              projectId: 'project-new-earth-website',
              title: 'Clarify founder journey page',
              description: 'Tighten the next section structure.',
              category: 'Content',
              priority: 'Medium',
              status: 'Planned',
              dueDate: null,
              energyLevel: 'Low',
              estimatedMinutes: null,
              actualMinutes: null,
              createdAt: DateTime(2026, 5, 2, 10),
              updatedAt: DateTime(2026, 5, 2, 10),
              completedAt: null,
              notes: null,
              isTopThree: true,
              isArchived: false,
            ),
          ],
        ),
        plannerTaskOptionsProvider.overrideWith(
          (ref) async => [
            Task(
              taskId: 'task-1',
              projectId: 'project-microgrow',
              title: 'Review MicroGrow diagnostics',
              description: 'Check the next useful diagnostics step.',
              category: 'Build',
              priority: 'High',
              status: 'Inbox',
              dueDate: null,
              energyLevel: 'Medium',
              estimatedMinutes: null,
              actualMinutes: null,
              createdAt: DateTime(2026, 5, 2, 9),
              updatedAt: DateTime(2026, 5, 2, 9),
              completedAt: null,
              notes: null,
              isTopThree: true,
              isArchived: false,
            ),
            Task(
              taskId: 'task-2',
              projectId: 'project-new-earth-website',
              title: 'Clarify founder journey page',
              description: 'Tighten the next section structure.',
              category: 'Content',
              priority: 'Medium',
              status: 'Planned',
              dueDate: null,
              energyLevel: 'Low',
              estimatedMinutes: null,
              actualMinutes: null,
              createdAt: DateTime(2026, 5, 2, 10),
              updatedAt: DateTime(2026, 5, 2, 10),
              completedAt: null,
              notes: null,
              isTopThree: true,
              isArchived: false,
            ),
          ],
        ),
        todayPlanProvider.overrideWith(
          (ref) async => DailyPlan(
            dailyPlanId: 'daily-plan-2026-05-02',
            date: DateTime(2026, 5, 2),
            mainFocus: null,
            focusReason: null,
            morningIntention: null,
            topTask1Id: 'task-1',
            topTask2Id: 'task-2',
            topTask3Id: null,
            learningFocusId: null,
            contentFocusId: null,
            businessFocusId: null,
            wellbeingCheckinId: null,
            eveningReview: null,
            whatMovedForward: null,
            whatWasCompleted: null,
            whatWasLearned: null,
            blockers: null,
            carryForwardNotes: null,
            tomorrowFocus: null,
            createdAt: DateTime(2026, 5, 2),
            updatedAt: DateTime(2026, 5, 2),
          ),
        ),
      ],
      child: const NewEarthCommandDashboardApp(),
    );
  }

  Widget buildDatabaseBackedTestApp(AppDatabase database) {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWith((ref) => database)],
      child: const NewEarthCommandDashboardApp(),
    );
  }

  testWidgets('app shell opens to dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('New Earth Command Dashboard'), findsOneWidget);
    expect(find.text('Today\'s Focus'), findsOneWidget);
    expect(find.text('A blank daily plan is ready for today.'), findsOneWidget);
    expect(find.text('No morning intention set yet.'), findsOneWidget);
    expect(find.text('No Top 3 tasks selected yet.'), findsOneWidget);
    expect(find.text('9 projects are available.'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Planner'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });

  testWidgets('more screen links to supporting screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('More').last);
    await tester.pumpAndSettle();

    expect(find.text('Journal'), findsOneWidget);
    expect(find.text('Learning'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
    expect(find.text('Business'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Voice Assistant'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Wellbeing'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Voice Assistant'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('projects screen shows seeded project cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Projects').last);
    await tester.pumpAndSettle();

    expect(find.text('Projects'), findsAtLeastNWidgets(1));
    expect(find.text('New Earth Projects'), findsOneWidget);
    expect(
      find.text('2 projects are available for the current build view.'),
      findsOneWidget,
    );
    expect(find.text('MicroGrow'), findsOneWidget);
    expect(find.text('New Earth Website'), findsOneWidget);
    expect(find.text('Current Milestone'), findsWidgets);
    expect(find.text('Next Action'), findsWidgets);
  });

  testWidgets('tasks screen shows local task cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();

    expect(find.text('Tasks'), findsAtLeastNWidgets(1));
    expect(find.text('Current Tasks'), findsOneWidget);
    expect(
      find.text('2 tasks are available in the local dashboard.'),
      findsOneWidget,
    );
    expect(find.text('Review MicroGrow diagnostics'), findsOneWidget);
    expect(find.text('Clarify founder journey page'), findsOneWidget);
    expect(find.text('Status: Inbox'), findsOneWidget);
    expect(find.text('Status: Planned'), findsOneWidget);
    expect(find.text('MicroGrow'), findsOneWidget);
    expect(find.text('New Earth Website'), findsOneWidget);
    expect(
      find.text('2 of 3 priority tasks selected for today.'),
      findsOneWidget,
    );
  });

  testWidgets('planner screen shows today plan summary', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Planner').last);
    await tester.pumpAndSettle();

    expect(find.text('Daily Planner'), findsAtLeastNWidgets(1));
    expect(find.text('Today\'s Plan'), findsOneWidget);
    expect(find.text('Morning Intention'), findsOneWidget);
    expect(find.text('Set a calm direction for the day.'), findsOneWidget);
    expect(find.text('Main Focus'), findsOneWidget);
    expect(
      find.text('Choose the one build step that matters most.'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Top 3 Tasks'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Top 3 Tasks'), findsOneWidget);
    expect(find.text('2 of 3 selected'), findsOneWidget);
    expect(find.text('Review MicroGrow diagnostics'), findsOneWidget);
  });

  testWidgets('planner saves main focus and dashboard shows it', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final today = DateTime.now();
    await DailyPlanService(database, now: () => today).ensureTodayPlan();

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Planner').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('plannerMainFocusField')),
      'Finish the planner editing slice',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('plannerMainFocusSaveButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('plannerMainFocusSaveButton')));
    await tester.pumpAndSettle();

    expect(find.text('Main focus saved.'), findsOneWidget);

    await tester.tap(find.text('Dashboard').last);
    await tester.pumpAndSettle();

    expect(find.text('Finish the planner editing slice'), findsOneWidget);
  });

  testWidgets('dashboard quick edit saves focus and planner reflects it', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final today = DateTime.now();
    await DailyPlanService(database, now: () => today).ensureTodayPlan();

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('dashboardFocusEditButton')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('dashboardMainFocusField')),
      'Stabilise today’s dashboard flow',
    );
    await tester.enterText(
      find.byKey(const Key('dashboardMorningIntentionField')),
      'Stay calm and finish one useful step.',
    );
    await tester.tap(find.byKey(const Key('dashboardFocusSaveButton')));
    await tester.pumpAndSettle();

    expect(find.text('Today\'s focus saved.'), findsOneWidget);
    expect(find.text('Stabilise today’s dashboard flow'), findsOneWidget);
    expect(find.text('Stay calm and finish one useful step.'), findsOneWidget);

    await tester.tap(find.text('Planner').last);
    await tester.pumpAndSettle();

    expect(find.text('Stabilise today’s dashboard flow'), findsOneWidget);
    expect(find.text('Stay calm and finish one useful step.'), findsOneWidget);
  });

  testWidgets('planner saves Top 3 tasks and dashboard shows them', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final today = DateTime.now();
    await DailyPlanService(database, now: () => today).ensureTodayPlan();
    final taskRepository = TaskRepository(database, now: () => today);
    final first = await taskRepository.createTask(title: 'Choose calm focus');
    final second = await taskRepository.createTask(
      title: 'Build dashboard data',
    );

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Planner').last);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(Key('plannerTopTask-${first.taskId}')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('plannerTopTask-${first.taskId}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('plannerTopTask-${second.taskId}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('plannerTopThreeSaveButton')));
    await tester.pumpAndSettle();

    expect(find.text('Top 3 tasks saved.'), findsOneWidget);

    await tester.tap(find.text('Dashboard').last);
    await tester.pumpAndSettle();

    expect(find.text('Choose calm focus'), findsOneWidget);
    expect(find.text('Build dashboard data'), findsOneWidget);
  });

  testWidgets('dashboard can remove a Top 3 task', (WidgetTester tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final today = DateTime.now();
    await DailyPlanService(database, now: () => today).ensureTodayPlan();
    final taskRepository = TaskRepository(database, now: () => today);
    final first = await taskRepository.createTask(title: 'Choose calm focus');
    final second = await taskRepository.createTask(
      title: 'Build dashboard data',
    );
    final dailyPlanRepository = DailyPlanRepository(database, now: () => today);
    await dailyPlanRepository.saveTopThreeTaskIds([
      first.taskId,
      second.taskId,
    ]);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(Key('dashboardTopTaskRemove-${first.taskId}')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('dashboardTopTaskRemove-${first.taskId}')));
    await tester.pumpAndSettle();

    expect(find.text('Choose calm focus'), findsNothing);
    expect(find.text('Build dashboard data'), findsOneWidget);

    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();
    expect(
      find.text('1 of 3 priority tasks selected for today.'),
      findsOneWidget,
    );
  });

  testWidgets('tasks screen toggles Top 3 and dashboard reflects it', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final today = DateTime.now();
    await DailyPlanService(database, now: () => today).ensureTodayPlan();
    final taskRepository = TaskRepository(database, now: () => today);
    final first = await taskRepository.createTask(title: 'Choose calm focus');

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('taskTopThreeButton-${first.taskId}')));
    await tester.pumpAndSettle();

    expect(
      find.text('1 of 3 priority tasks selected for today.'),
      findsOneWidget,
    );
    expect(find.text('Remove From Top 3'), findsOneWidget);

    await tester.tap(find.text('Dashboard').last);
    await tester.pumpAndSettle();

    expect(find.text('Choose calm focus'), findsOneWidget);
  });

  testWidgets('tasks screen blocks a fourth Top 3 task', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final today = DateTime.now();
    await DailyPlanService(database, now: () => today).ensureTodayPlan();
    final taskRepository = TaskRepository(database, now: () => today);
    final first = await taskRepository.createTask(title: 'First');
    final second = await taskRepository.createTask(title: 'Second');
    final third = await taskRepository.createTask(title: 'Third');
    final fourth = await taskRepository.createTask(title: 'Fourth');
    final dailyPlanRepository = DailyPlanRepository(database, now: () => today);
    await dailyPlanRepository.saveTopThreeTaskIds([
      first.taskId,
      second.taskId,
      third.taskId,
    ]);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(Key('taskTopThreeButton-${fourth.taskId}')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('taskTopThreeButton-${fourth.taskId}')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'You already have 3 priority tasks for today. Complete, remove, or carry one forward first.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('voice assistant screen opens from more', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('More').last);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Voice Assistant'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Voice Assistant'));
    await tester.pumpAndSettle();

    expect(find.text('Voice Assistant'), findsAtLeastNWidgets(1));
    expect(
      find.text('Speak, review, and turn your words into dashboard actions.'),
      findsOneWidget,
    );
    expect(find.text('Use Mock Transcript'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Related Project'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Related Project'), findsOneWidget);
    expect(find.text('No project selected'), findsOneWidget);
  });
}
