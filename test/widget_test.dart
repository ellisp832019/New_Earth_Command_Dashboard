import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/app.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/core/routing/app_router.dart';
import 'package:new_earth_command_dashboard/core/services/daily_plan_service.dart';
import 'package:new_earth_command_dashboard/core/services/seed_data_service.dart';
import 'package:new_earth_command_dashboard/features/business/data/business_repository.dart';
import 'package:new_earth_command_dashboard/features/dashboard/application/dashboard_controller.dart';
import 'package:new_earth_command_dashboard/features/dashboard/data/dashboard_repository.dart';
import 'package:new_earth_command_dashboard/features/inbox/data/inbox_repository.dart';
import 'package:new_earth_command_dashboard/features/journal/data/journal_repository.dart';
import 'package:new_earth_command_dashboard/features/content/data/content_repository.dart';
import 'package:new_earth_command_dashboard/features/learning/data/learning_repository.dart';
import 'package:new_earth_command_dashboard/features/planner/application/planner_controller.dart';
import 'package:new_earth_command_dashboard/features/planner/data/daily_plan_repository.dart';
import 'package:new_earth_command_dashboard/features/projects/application/projects_controller.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';
import 'package:new_earth_command_dashboard/features/settings/application/settings_controller.dart';
import 'package:new_earth_command_dashboard/features/settings/data/settings_repository.dart';
import 'package:new_earth_command_dashboard/features/tasks/application/tasks_controller.dart';
import 'package:new_earth_command_dashboard/features/tasks/data/task_repository.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_action_service.dart';
import 'package:new_earth_command_dashboard/features/wellbeing/data/wellbeing_repository.dart';

void main() {
  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
        databaseReadyProvider.overrideWith((ref) async {}),
        appThemeModeProvider.overrideWith((ref) => ThemeMode.light),
        dashboardSnapshotProvider.overrideWith(
          (ref) async => DashboardSnapshot(
            date: DateTime(2026, 5, 2),
            hasTodayPlan: true,
            activeProjectCount: 9,
            topTasks: const [],
            topTaskTitles: const [],
            showWellbeingCard: true,
            showBusinessCard: true,
            showLearningCard: true,
            showContentCard: true,
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
    await tester.drag(
      find.byKey(const Key('dashboardScrollView')),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('dashboardQuickCaptureButton')),
      findsOneWidget,
    );
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

  testWidgets('settings screen loads stored values and persists card toggles', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await SeedDataService(database).ensureSeedData();

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/settings');
    await tester.pumpAndSettle();

    expect(find.text('Dashboard Preferences'), findsOneWidget);
    expect(find.byKey(const Key('settingsTopTaskLimitValue')), findsOneWidget);
    expect(find.text('3 priority tasks per day'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settingsThemeModeOptionDark')));
    await tester.pumpAndSettle();

    final updatedThemeSnapshot = await SettingsRepository(
      database,
    ).getSettings();
    expect(updatedThemeSnapshot.settings.themeMode, 'Dark');

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);

    await tester.scrollUntilVisible(
      find.byKey(const Key('settingsAppVersionValue')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settingsAppVersionValue')), findsOneWidget);
    expect(find.text('1.0.0+1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settingsShowWellbeingCardToggle')));
    await tester.pumpAndSettle();

    final snapshot = await SettingsRepository(database).getSettings();
    expect(snapshot.settings.showWellbeingCard, isFalse);

    appRouter.go('/dashboard');
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('dashboardScrollView')),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wellbeing'), findsNothing);
    expect(find.text('Business Reminder'), findsOneWidget);
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

  testWidgets('project detail shows linked journal entries and opens edit', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final projectRepository = ProjectRepository(database);
    final journalRepository = JournalRepository(database);
    final project = await projectRepository.createProject(
      name: 'Project Journal Home',
      status: 'Active',
      priority: 'High',
      progressPercentage: 20,
    );
    final entry = await journalRepository.createEntry(
      date: DateTime(2026, 5, 3),
      title: 'Project journal reflection',
      projectId: project.projectId,
      category: 'Project Update',
      whatIWorkedOn: 'Captured the latest project build note.',
    );

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/projects/${project.projectId}');
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Recent Journal Entries'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Recent Journal Entries'), findsOneWidget);
    expect(find.text('Project journal reflection'), findsOneWidget);
    expect(
      find.text('Captured the latest project build note.'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(Key('projectJournalEntry-${entry.journalEntryId}')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Journal Entry'), findsOneWidget);
    expect(find.text('Project journal reflection'), findsOneWidget);
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

  testWidgets('journal screen shows a calm empty state', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/journal');
    await tester.pumpAndSettle();

    expect(find.text('Journal'), findsAtLeastNWidgets(1));
    expect(
      find.text(
        'No journal entries yet. Capture today\'s progress so the journey is not lost.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('journal screen can create a linked entry', (
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
    await taskRepository.createTask(
      title: 'MicroGrow journal task',
      projectId: microGrow.projectId,
      status: 'Today',
    );

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/journal/new');
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('journalTitleField')),
      'Daily build reflection',
    );
    await tester.tap(find.byKey(const Key('journalProjectField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MicroGrow').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('journalTaskField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MicroGrow journal task').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('journalCategoryField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Build Log').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('journalWorkedOnField')),
      'Stitched the first local journal flow into the app.',
    );
    await tester.enterText(
      find.byKey(const Key('journalLearnedField')),
      'The journal can reuse the existing project and task foundations.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('journalNextActionsField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('journalNextActionsField')),
      'Add edit support in a later slice.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveJournalButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveJournalButton')));
    await tester.pumpAndSettle();

    expect(find.text('Journal'), findsAtLeastNWidgets(1));
    expect(find.text('Daily build reflection'), findsOneWidget);
    expect(find.text('MicroGrow'), findsOneWidget);
    expect(find.text('Build Log'), findsOneWidget);

    final entries = await JournalRepository(database).getEntries();
    expect(entries, hasLength(1));
    expect(entries.first.entry.title, 'Daily build reflection');
    expect(entries.first.projectName, 'MicroGrow');
    expect(entries.first.taskTitle, 'MicroGrow journal task');
  });

  testWidgets('learning screen shows a calm empty state', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/learning');
    await tester.pumpAndSettle();

    expect(find.text('Learning'), findsAtLeastNWidgets(1));
    expect(
      find.text(
        'No learning topics yet. Add a skill that will help you build New Earth.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('learning screen can create a linked learning item', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await SeedDataService(database).ensureSeedData();

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/learning');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addLearningItemButton')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('learningTopicField')),
      'Flutter Drift Database',
    );
    await tester.tap(find.byKey(const Key('learningProjectField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MicroGrow').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('learningReasonField')),
      'The dashboard needs calm and reliable local data.',
    );
    await tester.enterText(
      find.byKey(const Key('learningResourceLinkField')),
      'https://drift.simonbinder.eu',
    );
    await tester.tap(find.byKey(const Key('learningStatusField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Learning').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('learningConfidenceField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Medium').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('learningNotesField')),
      'Start with the repository and list flow.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('learningNextStepField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('learningNextStepField')),
      'Wire the screen to local data.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveLearningButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveLearningButton')));
    await tester.pumpAndSettle();

    expect(find.text('Learning'), findsAtLeastNWidgets(1));
    expect(find.text('Flutter Drift Database'), findsOneWidget);
    expect(find.text('MicroGrow'), findsOneWidget);
    expect(find.text('Status: Learning'), findsOneWidget);
    expect(find.text('Confidence: Medium'), findsOneWidget);
    expect(
      find.text('Next Step: Wire the screen to local data.'),
      findsOneWidget,
    );

    final items = await LearningRepository(database).getItems();
    expect(items, hasLength(1));
    expect(items.first.item.topic, 'Flutter Drift Database');
    expect(items.first.projectName, 'MicroGrow');
  });

  testWidgets('learning screen can open and edit an existing topic', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final learningRepository = LearningRepository(database);
    final createdItem = await learningRepository.createItem(
      topic: 'Original learning topic',
      status: 'To Learn',
      nextStep: 'Original next step.',
    );

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/learning');
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(Key('learningItemCard-${createdItem.learningItemId}')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Learning Topic'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('learningTopicField')),
      'Edited learning topic',
    );
    await tester.tap(find.byKey(const Key('learningStatusField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Applied').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('learningConfidenceField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('learningReasonField')),
      'This now supports a real feature slice.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('learningNextStepField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('learningNextStepField')),
      'Reuse the edit pattern elsewhere.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveLearningButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveLearningButton')));
    await tester.pumpAndSettle();

    expect(find.text('Edited learning topic'), findsOneWidget);
    expect(find.text('Status: Applied'), findsOneWidget);
    expect(find.text('Confidence: High'), findsOneWidget);
    expect(
      find.text('Next Step: Reuse the edit pattern elsewhere.'),
      findsOneWidget,
    );

    final updatedItem = await learningRepository.getById(
      createdItem.learningItemId,
    );
    expect(updatedItem.topic, 'Edited learning topic');
    expect(updatedItem.status, 'Applied');
    expect(updatedItem.skillConfidence, 'High');
    expect(
      updatedItem.reasonForLearning,
      'This now supports a real feature slice.',
    );
    expect(updatedItem.nextStep, 'Reuse the edit pattern elsewhere.');
  });

  testWidgets('content screen shows a calm empty state', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/content');
    await tester.pumpAndSettle();

    expect(find.text('Content'), findsAtLeastNWidgets(1));
    expect(
      find.text(
        'No content ideas yet. Turn a build update into your first post idea.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('content screen can create a linked content item', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await SeedDataService(database).ensureSeedData();

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/content');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addContentItemButton')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('contentTitleField')),
      'Building the New Earth Command Dashboard',
    );
    await tester.tap(find.byKey(const Key('contentProjectField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MicroGrow').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('contentPlatformField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LinkedIn').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('contentTypeField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Project Update').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('contentStatusField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Drafting').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('contentDraftTextField')),
      'A grounded build-in-public update for the dashboard.',
    );
    await tester.tap(find.byKey(const Key('contentImageNeededField')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('contentImagePromptField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('contentImagePromptField')),
      'A glowing command dashboard on a night desk.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('contentNotesField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('contentNotesField')),
      'Keep the first public update practical.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveContentButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveContentButton')));
    await tester.pumpAndSettle();

    expect(find.text('Content'), findsAtLeastNWidgets(1));
    expect(
      find.text('Building the New Earth Command Dashboard'),
      findsOneWidget,
    );
    expect(find.text('LinkedIn'), findsOneWidget);
    expect(find.text('MicroGrow'), findsOneWidget);
    expect(find.text('Project Update'), findsOneWidget);
    expect(find.text('Status: Drafting'), findsOneWidget);
    expect(find.text('Image Needed: Yes'), findsOneWidget);

    final items = await ContentRepository(database).getItems();
    expect(items, hasLength(1));
    expect(items.first.item.title, 'Building the New Earth Command Dashboard');
    expect(items.first.projectName, 'MicroGrow');
    expect(items.first.item.imageNeeded, isTrue);
  });

  testWidgets('content screen can open and edit an existing content item', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final contentRepository = ContentRepository(database);
    final createdItem = await contentRepository.createItem(
      title: 'Original content idea',
      status: 'Idea',
      imageNeeded: false,
    );

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/content');
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(Key('contentItemCard-${createdItem.contentItemId}')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Content Idea'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('contentTitleField')),
      'Edited content idea',
    );
    await tester.tap(find.byKey(const Key('contentPlatformField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Website').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('contentTypeField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Technical Update').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('contentStatusField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ready').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('contentDraftTextField')),
      'Edited draft text for the next publishing step.',
    );
    await tester.tap(find.byKey(const Key('contentImageNeededField')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('contentImagePromptField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('contentImagePromptField')),
      'A crisp product dashboard mockup.',
    );
    await tester.enterText(
      find.byKey(const Key('contentNotesField')),
      'Keep the framing practical and grounded.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveContentButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveContentButton')));
    await tester.pumpAndSettle();

    expect(find.text('Edited content idea'), findsOneWidget);
    expect(find.text('Website'), findsOneWidget);
    expect(find.text('Technical Update'), findsOneWidget);
    expect(find.text('Status: Ready'), findsOneWidget);
    expect(find.text('Image Needed: Yes'), findsOneWidget);

    final updatedItem = await contentRepository.getById(
      createdItem.contentItemId,
    );
    expect(updatedItem.title, 'Edited content idea');
    expect(updatedItem.platform, 'Website');
    expect(updatedItem.contentType, 'Technical Update');
    expect(updatedItem.status, 'Ready');
    expect(
      updatedItem.draftText,
      'Edited draft text for the next publishing step.',
    );
    expect(updatedItem.imageNeeded, isTrue);
    expect(updatedItem.imagePrompt, 'A crisp product dashboard mockup.');
    expect(updatedItem.notes, 'Keep the framing practical and grounded.');
  });

  testWidgets('business screen shows a calm empty state', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/business');
    await tester.pumpAndSettle();

    expect(find.text('Business'), findsAtLeastNWidgets(1));
    expect(
      find.text(
        'No business opportunities yet. Add a job, funding idea, grant, contact, or partnership lead.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('business screen can create a linked opportunity', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await SeedDataService(database).ensureSeedData();

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/business');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addBusinessItemButton')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('businessNameField')),
      'AI Architect Role',
    );
    await tester.tap(find.byKey(const Key('businessProjectField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MicroGrow').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('businessTypeField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Job').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('businessStatusField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preparing').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('businessCompanyOrContactField')),
      'OpenAI',
    );
    await tester.enterText(
      find.byKey(const Key('businessNextActionField')),
      'Finalise CV',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('businessRelatedDocumentLinkField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('businessRelatedDocumentLinkField')),
      'https://example.com/cv',
    );
    await tester.enterText(
      find.byKey(const Key('businessNotesField')),
      'Keep the application grounded and sharp.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveBusinessButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveBusinessButton')));
    await tester.pumpAndSettle();

    expect(find.text('Business'), findsAtLeastNWidgets(1));
    expect(find.text('AI Architect Role'), findsOneWidget);
    expect(find.text('Job'), findsOneWidget);
    expect(find.text('MicroGrow'), findsOneWidget);
    expect(find.text('Status: Preparing'), findsOneWidget);
    expect(find.text('Next Step: Finalise CV'), findsOneWidget);

    final items = await BusinessRepository(database).getItems();
    expect(items, hasLength(1));
    expect(items.first.item.name, 'AI Architect Role');
    expect(items.first.projectName, 'MicroGrow');
    expect(items.first.item.companyOrContact, 'OpenAI');
  });

  testWidgets('wellbeing screen shows a calm empty state', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/wellbeing');
    await tester.pumpAndSettle();

    expect(find.text('Wellbeing'), findsAtLeastNWidgets(1));
    expect(
      find.text(
        'No wellbeing check-ins yet. Add a calm check-in so the build stays sustainable.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('wellbeing screen can create a check-in', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/wellbeing');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addWellbeingCheckinButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('wellbeingEnergyField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Low').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('wellbeingMoodField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tired').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('wellbeingSleepQualityField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Medium').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('wellbeingStressField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('wellbeingMovementField')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('wellbeingFoodWaterField')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('wellbeingReflectionField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('wellbeingReflectionField')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('wellbeingNotesField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('wellbeingNotesField')),
      'Keep the day lighter and avoid unnecessary context switching.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveWellbeingButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveWellbeingButton')));
    await tester.pumpAndSettle();

    expect(find.text('Wellbeing'), findsAtLeastNWidgets(1));
    expect(find.text('Energy: Low'), findsOneWidget);
    expect(find.text('Mood: Tired'), findsOneWidget);
    expect(find.text('Stress: High'), findsOneWidget);
    expect(find.text('Workload: Light'), findsOneWidget);

    final checkins = await WellbeingRepository(database).getCheckins();
    expect(checkins, hasLength(1));
    expect(checkins.first.energyLevel, 'Low');
    expect(checkins.first.suggestedWorkload, 'Light');
    expect(checkins.first.movementDone, isTrue);
    expect(checkins.first.foodWaterOk, isTrue);
    expect(checkins.first.meditationReflectionDone, isTrue);
  });

  testWidgets('inbox screen shows a calm empty state', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/inbox');
    await tester.pumpAndSettle();

    expect(find.text('Inbox'), findsAtLeastNWidgets(1));
    expect(
      find.text(
        'No inbox items yet. Capture a thought here so it does not get lost.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('inbox screen can create a linked item', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await SeedDataService(database).ensureSeedData();

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/inbox');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addInboxItemButton')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('inboxTitleField')),
      'Check Flutter navigation package',
    );
    await tester.enterText(
      find.byKey(const Key('inboxBodyField')),
      'Might help the next polish pass.',
    );
    await tester.tap(find.byKey(const Key('inboxTypeField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Learning Note').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('inboxProjectField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MicroGrow').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('inboxStatusField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('inboxStatusField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveInboxButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveInboxButton')));
    await tester.pumpAndSettle();

    expect(find.text('Inbox'), findsAtLeastNWidgets(1));
    expect(
      find.text('Check Flutter navigation package'),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('Learning Note'), findsOneWidget);
    expect(find.text('MicroGrow'), findsOneWidget);
    expect(find.text('Status: New'), findsOneWidget);

    final items = await InboxRepository(database).getItems();
    expect(items, hasLength(1));
    expect(items.first.item.title, 'Check Flutter navigation package');
    expect(items.first.projectName, 'MicroGrow');
  });

  testWidgets('dashboard quick capture saves a new inbox item', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/dashboard');
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const Key('dashboardScrollView')),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dashboardQuickCaptureButton')));
    await tester.pumpAndSettle();

    expect(find.text('Quick Capture'), findsAtLeastNWidgets(1));
    await tester.enterText(
      find.byKey(const Key('dashboardQuickCaptureTitleField')),
      'MicroGrow field note',
    );
    await tester.enterText(
      find.byKey(const Key('dashboardQuickCaptureBodyField')),
      'Check the sensor diagnostics wording later.',
    );
    await tester.tap(find.byKey(const Key('dashboardQuickCaptureTypeField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Idea').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dashboardQuickCaptureSaveButton')));
    await tester.pumpAndSettle();

    final items = await InboxRepository(database).getItems();
    expect(items, hasLength(1));
    expect(items.first.item.title, 'MicroGrow field note');
    expect(
      items.first.item.body,
      'Check the sensor diagnostics wording later.',
    );
    expect(items.first.item.type, 'Idea');
    expect(items.first.item.status, 'New');

    appRouter.go('/inbox');
    await tester.pumpAndSettle();

    expect(find.text('MicroGrow field note'), findsAtLeastNWidgets(1));
    expect(find.text('Idea'), findsOneWidget);
    expect(find.text('Status: New'), findsOneWidget);
  });

  testWidgets('journal screen can open and edit an existing entry', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final journalRepository = JournalRepository(database);
    final createdEntry = await journalRepository.createEntry(
      date: DateTime(2026, 5, 2),
      title: 'Original journal entry',
      category: 'Build Log',
      whatIWorkedOn: 'Original progress note.',
      nextActions: 'Original next step.',
    );

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go('/journal');
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(Key('journalEntryCard-${createdEntry.journalEntryId}')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Journal Entry'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('journalTitleField')),
      'Edited journal entry',
    );
    await tester.enterText(
      find.byKey(const Key('journalWorkedOnField')),
      'Edited progress note.',
    );
    await tester.enterText(
      find.byKey(const Key('journalLearnedField')),
      'Editing journal entries keeps the build history useful.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('journalNextActionsField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('journalNextActionsField')),
      'Use the edit flow again later.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveJournalButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveJournalButton')));
    await tester.pumpAndSettle();

    expect(find.text('Edited journal entry'), findsOneWidget);
    expect(find.text('Edited progress note.'), findsOneWidget);

    final updatedEntry = await journalRepository.getById(
      createdEntry.journalEntryId,
    );
    expect(updatedEntry.title, 'Edited journal entry');
    expect(updatedEntry.whatIWorkedOn, 'Edited progress note.');
    expect(
      updatedEntry.whatILearned,
      'Editing journal entries keeps the build history useful.',
    );
    expect(updatedEntry.nextActions, 'Use the edit flow again later.');
  });
}
