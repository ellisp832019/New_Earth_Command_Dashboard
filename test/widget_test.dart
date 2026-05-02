import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/app.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/core/routing/app_router.dart';
import 'package:new_earth_command_dashboard/core/services/daily_plan_service.dart';
import 'package:new_earth_command_dashboard/core/services/seed_data_service.dart';
import 'package:new_earth_command_dashboard/features/dashboard/application/dashboard_controller.dart';
import 'package:new_earth_command_dashboard/features/dashboard/data/dashboard_repository.dart';
import 'package:new_earth_command_dashboard/features/planner/application/planner_controller.dart';
import 'package:new_earth_command_dashboard/features/planner/data/daily_plan_repository.dart';
import 'package:new_earth_command_dashboard/features/projects/application/projects_controller.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';
import 'package:new_earth_command_dashboard/features/tasks/application/tasks_controller.dart';
import 'package:new_earth_command_dashboard/features/tasks/data/task_repository.dart';
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
            focusReason: null,
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
    expect(find.text('No focus reason set yet.'), findsOneWidget);
    expect(find.text('No morning intention set yet.'), findsOneWidget);
    expect(find.text('No Top 3 tasks selected yet.'), findsOneWidget);
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
      find.text('2 tasks are visible in the current task view.'),
      findsOneWidget,
    );
    expect(
      find.text('2 of 3 priority tasks selected for today.'),
      findsOneWidget,
    );
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Project Filter'), findsOneWidget);
    expect(find.text('Review MicroGrow diagnostics'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Clarify founder journey page'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Clarify founder journey page'), findsOneWidget);
    expect(find.text('Status: Inbox'), findsOneWidget);
    expect(find.text('Status: Planned'), findsOneWidget);
    expect(find.text('MicroGrow'), findsOneWidget);
    expect(find.text('New Earth Website'), findsOneWidget);
  });

  testWidgets('tasks screen can create a task', (WidgetTester tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await SeedDataService(database).ensureSeedData();

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/tasks/new');
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('taskTitleField')),
      'Build task add edit flow',
    );
    await tester.enterText(
      find.byKey(const Key('taskDescriptionField')),
      'Create the first shared task editor screen.',
    );
    await tester.tap(find.byKey(const Key('taskProjectField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MicroGrow').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('taskCategoryField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Build').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('taskPriorityField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('taskEstimatedMinutesField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('taskEstimatedMinutesField')),
      '45',
    );
    await tester.enterText(
      find.byKey(const Key('taskNotesField')),
      'Keep the first pass focused.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveTaskButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();

    expect(find.text('Tasks'), findsAtLeastNWidgets(1));
    expect(find.text('Build task add edit flow'), findsOneWidget);
    expect(find.text('MicroGrow'), findsOneWidget);

    final tasks = await TaskRepository(database).getActiveTasks();
    expect(
      tasks.any((task) => task.title == 'Build task add edit flow'),
      isTrue,
    );
  });

  testWidgets('tasks screen can edit an existing task', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final projectRepository = ProjectRepository(database);
    final taskRepository = TaskRepository(database);
    final project = await projectRepository.createProject(name: 'Task Project');
    final task = await taskRepository.createTask(
      title: 'Original task title',
      projectId: project.projectId,
      status: 'Inbox',
      priority: 'Medium',
    );

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/tasks/${task.taskId}/edit');
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('taskTitleField')),
      'Edited task title',
    );
    await tester.tap(find.byKey(const Key('taskStatusField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Today').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('taskPriorityField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveTaskButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();

    expect(find.text('Edited task title'), findsOneWidget);
    expect(find.text('Status: Today'), findsOneWidget);
    expect(find.text('Priority: High'), findsOneWidget);
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
      find.text('Why It Matters'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Why It Matters'), findsAtLeastNWidgets(1));
    await tester.scrollUntilVisible(
      find.text('Top 3 Tasks'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Top 3 Tasks'), findsOneWidget);
    expect(find.text('2 of 3 selected'), findsOneWidget);
    expect(find.text('Review MicroGrow diagnostics'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Carry Forward'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Carry Forward'), findsOneWidget);
    expect(
      find.text('Note what should move into tomorrow or be parked calmly.'),
      findsOneWidget,
    );
    expect(find.text('Tomorrow\'s Focus'), findsOneWidget);
    expect(
      find.text('Capture tomorrow\'s likely focus while it is still clear.'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('plannerEveningReviewSaveButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('What moved forward today?'), findsOneWidget);
    expect(find.text('What did I complete?'), findsOneWidget);
    expect(find.text('What did I learn?'), findsOneWidget);
    expect(find.text('What blocked me?'), findsOneWidget);
  });

  testWidgets('planner review route opens the evening review section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    appRouter.go('/planner?section=review');
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('plannerEveningReviewSaveButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Daily Planner'), findsAtLeastNWidgets(1));
    expect(
      find.byKey(const Key('plannerEveningReviewSaveButton')),
      findsOneWidget,
    );
    expect(find.text('What moved forward today?'), findsOneWidget);
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

  testWidgets('dashboard quick edit saves focus to local plan', (
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
      'Stabilise today dashboard flow',
    );
    await tester.enterText(
      find.byKey(const Key('dashboardFocusReasonField')),
      'This keeps the dashboard aligned and useful.',
    );
    await tester.enterText(
      find.byKey(const Key('dashboardMorningIntentionField')),
      'Stay calm and finish one useful step.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('dashboardFocusSaveButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dashboardFocusSaveButton')));
    await tester.pumpAndSettle();

    expect(find.text('Today\'s focus saved.'), findsOneWidget);
    expect(find.text('Stabilise today dashboard flow'), findsOneWidget);

    final plan = await DailyPlanRepository(
      database,
      now: () => today,
    ).getTodayPlan();
    expect(plan.mainFocus, 'Stabilise today dashboard flow');
    expect(plan.focusReason, 'This keeps the dashboard aligned and useful.');
    expect(plan.morningIntention, 'Stay calm and finish one useful step.');
  });

  testWidgets('planner saves carry forward notes to local plan', (
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

    await tester.scrollUntilVisible(
      find.byKey(const Key('plannerCarryForwardField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('plannerCarryForwardField')),
      'Carry forward the website tidy-up if the planner review runs long.',
    );
    await tester.tap(find.byKey(const Key('plannerCarryForwardSaveButton')));
    await tester.pumpAndSettle();

    expect(find.text('Carry forward saved.'), findsOneWidget);

    final plan = await DailyPlanRepository(
      database,
      now: () => today,
    ).getTodayPlan();
    expect(
      plan.carryForwardNotes,
      'Carry forward the website tidy-up if the planner review runs long.',
    );
  });

  testWidgets('planner saves tomorrow focus to local plan', (
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

    await tester.scrollUntilVisible(
      find.byKey(const Key('plannerTomorrowFocusField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('plannerTomorrowFocusField')),
      'Start the evening review save flow.',
    );
    await tester.tap(find.byKey(const Key('plannerTomorrowFocusSaveButton')));
    await tester.pumpAndSettle();

    expect(find.text('Tomorrow\'s focus saved.'), findsOneWidget);

    final plan = await DailyPlanRepository(
      database,
      now: () => today,
    ).getTodayPlan();
    expect(plan.tomorrowFocus, 'Start the evening review save flow.');
  });

  testWidgets('planner saves evening review fields to local plan', (
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

    await tester.scrollUntilVisible(
      find.byKey(const Key('plannerMovedForwardField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('plannerMovedForwardField')),
      'The planner daily loop is starting to feel complete.',
    );
    await tester.enterText(
      find.byKey(const Key('plannerCompletedField')),
      'Finished the first review save flow.',
    );
    await tester.enterText(
      find.byKey(const Key('plannerLearnedField')),
      'Small slices keep the dashboard calmer and easier to trust.',
    );
    await tester.enterText(
      find.byKey(const Key('plannerBlockersField')),
      'Project CRUD is still waiting for its next pass.',
    );
    await tester.tap(find.byKey(const Key('plannerEveningReviewSaveButton')));
    await tester.pumpAndSettle();

    expect(find.text('Evening review saved.'), findsOneWidget);

    final plan = await DailyPlanRepository(
      database,
      now: () => today,
    ).getTodayPlan();
    expect(
      plan.whatMovedForward,
      'The planner daily loop is starting to feel complete.',
    );
    expect(plan.whatWasCompleted, 'Finished the first review save flow.');
    expect(
      plan.whatWasLearned,
      'Small slices keep the dashboard calmer and easier to trust.',
    );
    expect(plan.blockers, 'Project CRUD is still waiting for its next pass.');
    expect(
      plan.eveningReview,
      contains(
        'Moved forward: The planner daily loop is starting to feel complete.',
      ),
    );
  });

  testWidgets('projects screen opens project detail from the list', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await SeedDataService(database).ensureSeedData();
    final projectRepository = ProjectRepository(database);
    final taskRepository = TaskRepository(database);
    final microGrow = (await projectRepository.getProjects()).firstWhere(
      (project) => project.name == 'MicroGrow',
    );
    await taskRepository.createTask(
      title: 'Review current MicroGrow build priorities',
      projectId: microGrow.projectId,
      status: 'Planned',
      priority: 'High',
    );

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Projects').last);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(Key('projectCard-${microGrow.projectId}')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('projectCard-${microGrow.projectId}')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Active Tasks'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Project Detail'), findsOneWidget);
    expect(find.text('Active Tasks'), findsOneWidget);
    expect(
      find.text('Review current MicroGrow build priorities'),
      findsOneWidget,
    );
  });

  testWidgets('projects screen can create a project', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/projects/new');
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('projectNameField')),
      'New Earth Garden Lab',
    );
    await tester.enterText(
      find.byKey(const Key('projectShortDescriptionField')),
      'A practical space for testing local growing systems.',
    );
    await tester.enterText(
      find.byKey(const Key('projectVisionField')),
      'Create a calm place to test ideas before scaling them.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('projectCurrentMilestoneField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('projectCurrentMilestoneField')),
      'Define the first build scope',
    );
    await tester.enterText(
      find.byKey(const Key('projectNextActionField')),
      'Write the first setup checklist',
    );
    await tester.enterText(
      find.byKey(const Key('projectNotesField')),
      'Keep this project grounded and practical.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveProjectButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveProjectButton')));
    await tester.pumpAndSettle();

    expect(find.text('Project Detail'), findsOneWidget);
    expect(find.text('New Earth Garden Lab'), findsOneWidget);
    expect(find.text('Define the first build scope'), findsOneWidget);
  });

  testWidgets('project detail can open edit screen and save changes', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final projectRepository = ProjectRepository(database);
    final project = await projectRepository.createProject(
      name: 'Field Systems Alpha',
      shortDescription: 'Initial diagnostics project.',
      vision: 'Make diagnostics easier to trust in the field.',
      status: 'Active',
      priority: 'High',
      progressPercentage: 20,
      currentMilestone: 'Build the first project detail view',
      nextAction: 'Check the original next action',
    );

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/projects/${project.projectId}/edit');
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('projectNextActionField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('projectNextActionField')),
      'Review the edited next action',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveProjectButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveProjectButton')));
    await tester.pumpAndSettle();

    expect(find.text('Project Detail'), findsOneWidget);
    expect(find.text('Review the edited next action'), findsOneWidget);
  });

  testWidgets('project detail can open task form with project preselected', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final projectRepository = ProjectRepository(database);
    final project = await projectRepository.createProject(
      name: 'Project Linked Task Flow',
      status: 'Active',
      priority: 'High',
      progressPercentage: 0,
    );

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/projects/${project.projectId}');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addProjectTaskButton')));
    await tester.pumpAndSettle();

    expect(find.text('New Task'), findsOneWidget);
    expect(find.text('Project Linked Task Flow'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('taskTitleField')),
      'Add task from project detail',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveTaskButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();

    final createdTask = (await TaskRepository(database).getActiveTasks())
        .firstWhere((task) => task.title == 'Add task from project detail');
    expect(createdTask.projectId, project.projectId);
  });

  testWidgets('project detail can archive a project after confirmation', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final projectRepository = ProjectRepository(database);
    final project = await projectRepository.createProject(
      name: 'Archive Me Calmly',
      status: 'Active',
      priority: 'Medium',
      progressPercentage: 15,
    );

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/projects/${project.projectId}');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('archiveProjectButton')));
    await tester.pumpAndSettle();

    expect(find.text('Archive Project'), findsOneWidget);
    expect(
      find.text('Archive this item? You can restore it later.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Archive'));
    await tester.pumpAndSettle();

    expect(find.text('Project Detail'), findsNothing);
    expect(find.text('Archive Me Calmly'), findsNothing);

    final archivedProject = await projectRepository.getProject(
      project.projectId,
    );
    expect(archivedProject.isArchived, isTrue);
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

    await tester.scrollUntilVisible(
      find.byKey(Key('taskTopThreeButton-${first.taskId}')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
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

  testWidgets('tasks screen filters by status', (WidgetTester tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final taskRepository = TaskRepository(database);
    await taskRepository.createTask(title: 'Inbox task', status: 'Inbox');
    await taskRepository.createTask(title: 'Today task', status: 'Today');

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('taskStatusFilter-Today')));
    await tester.pumpAndSettle();

    expect(find.text('Today task'), findsOneWidget);
    expect(find.text('Inbox task'), findsNothing);
  });

  testWidgets('tasks screen filters by project', (WidgetTester tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await SeedDataService(database).ensureSeedData();
    final projectRepository = ProjectRepository(database);
    final taskRepository = TaskRepository(database);
    final projects = await projectRepository.getProjects();
    final microGrow = projects.firstWhere(
      (project) => project.name == 'MicroGrow',
    );
    final website = projects.firstWhere(
      (project) => project.name == 'New Earth Website',
    );

    await taskRepository.createTask(
      title: 'MicroGrow task',
      projectId: microGrow.projectId,
    );
    await taskRepository.createTask(
      title: 'Website task',
      projectId: website.projectId,
    );

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('taskProjectFilterField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MicroGrow').last);
    await tester.pumpAndSettle();

    expect(find.text('MicroGrow task'), findsOneWidget);
    expect(find.text('Website task'), findsNothing);
  });

  testWidgets('tasks screen searches by title', (WidgetTester tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final taskRepository = TaskRepository(database);
    await taskRepository.createTask(title: 'Dashboard wireframe');
    await taskRepository.createTask(title: 'Website tidy-up');

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('taskSearchField')),
      'wireframe',
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard wireframe'), findsOneWidget);
    expect(find.text('Website tidy-up'), findsNothing);
  });

  testWidgets('tasks screen searches by notes', (WidgetTester tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final taskRepository = TaskRepository(database);
    await taskRepository.createTask(
      title: 'Task one',
      notes: 'Sensor diagnostics follow-up',
    );
    await taskRepository.createTask(
      title: 'Task two',
      notes: 'Website navigation tidy-up',
    );

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('taskSearchField')), 'sensor');
    await tester.pumpAndSettle();

    expect(find.text('Task one'), findsOneWidget);
    expect(find.text('Task two'), findsNothing);
  });

  testWidgets('tasks screen can clear search', (WidgetTester tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final taskRepository = TaskRepository(database);
    await taskRepository.createTask(title: 'First task');
    await taskRepository.createTask(title: 'Second task');

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('taskSearchField')), 'First');
    await tester.pumpAndSettle();
    expect(find.text('Second task'), findsNothing);

    await tester.tap(find.byKey(const Key('clearTaskSearchButton')));
    await tester.pumpAndSettle();

    expect(find.text('First task'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Second task'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Second task'), findsOneWidget);
  });

  testWidgets('tasks screen combines search with filters', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await SeedDataService(database).ensureSeedData();
    final projectRepository = ProjectRepository(database);
    final taskRepository = TaskRepository(database);
    final projects = await projectRepository.getProjects();
    final microGrow = projects.firstWhere(
      (project) => project.name == 'MicroGrow',
    );
    final website = projects.firstWhere(
      (project) => project.name == 'New Earth Website',
    );

    await taskRepository.createTask(
      title: 'Diagnostics follow-up',
      projectId: microGrow.projectId,
      status: 'Today',
      notes: 'Sensor review',
    );
    await taskRepository.createTask(
      title: 'Diagnostics draft',
      projectId: website.projectId,
      status: 'Planned',
      notes: 'Website wording',
    );

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('taskSearchField')),
      'diagnostics',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('taskStatusFilter-Today')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('taskProjectFilterField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MicroGrow').last);
    await tester.pumpAndSettle();

    expect(find.text('Diagnostics follow-up'), findsOneWidget);
    expect(find.text('Diagnostics draft'), findsNothing);
  });

  testWidgets('tasks screen can move a task to today', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final taskRepository = TaskRepository(database);
    final task = await taskRepository.createTask(title: 'Shift me');

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(Key('taskMoveToTodayButton-${task.taskId}')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('taskMoveToTodayButton-${task.taskId}')));
    await tester.pumpAndSettle();

    expect(find.text('Status: Today'), findsOneWidget);
  });

  testWidgets(
    'tasks screen can park a Top 3 task and remove it from today plan',
    (WidgetTester tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final today = DateTime.now();
      await DailyPlanService(database, now: () => today).ensureTodayPlan();
      final taskRepository = TaskRepository(database, now: () => today);
      final task = await taskRepository.createTask(title: 'Park me calmly');
      final dailyPlanRepository = DailyPlanRepository(
        database,
        now: () => today,
      );
      await dailyPlanRepository.saveTopThreeTaskIds([task.taskId]);

      await tester.pumpWidget(buildDatabaseBackedTestApp(database));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tasks').last);
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(Key('taskParkButton-${task.taskId}')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('taskParkButton-${task.taskId}')));
      await tester.pumpAndSettle();

      expect(find.text('Status: Parked'), findsOneWidget);
      expect(
        find.text('0 of 3 priority tasks selected for today.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('tasks screen can archive a task after confirmation', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final taskRepository = TaskRepository(database);
    final task = await taskRepository.createTask(title: 'Archive this task');

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(Key('taskArchiveButton-${task.taskId}')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('taskArchiveButton-${task.taskId}')));
    await tester.pumpAndSettle();

    expect(find.text('Archive Task'), findsOneWidget);
    expect(
      find.text('Archive this task? You can restore it later.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Archive'));
    await tester.pumpAndSettle();

    expect(find.text('Archive this task'), findsNothing);

    final reloadedTask = await taskRepository.getById(task.taskId);
    expect(reloadedTask.isArchived, isTrue);
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
