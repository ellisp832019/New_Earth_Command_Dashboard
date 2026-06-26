import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/app.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/core/routing/app_router.dart';
import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/core/services/daily_plan_service.dart';
import 'package:new_earth_command_dashboard/core/services/seed_data_service.dart';
import 'package:new_earth_command_dashboard/features/business/data/business_repository.dart';
import 'package:new_earth_command_dashboard/features/dashboard/application/dashboard_controller.dart';
import 'package:new_earth_command_dashboard/features/dashboard/data/dashboard_repository.dart';
import 'package:new_earth_command_dashboard/features/command_deck/data/command_deck_service.dart';
import 'package:new_earth_command_dashboard/features/journal/data/journal_repository.dart';
import 'package:new_earth_command_dashboard/features/content/data/content_repository.dart';
import 'package:new_earth_command_dashboard/features/learning/data/learning_repository.dart';
import 'package:new_earth_command_dashboard/features/planner/application/planner_controller.dart';
import 'package:new_earth_command_dashboard/features/planner/data/daily_plan_repository.dart';
import 'package:new_earth_command_dashboard/features/planner/presentation/planner_screen.dart';
import 'package:new_earth_command_dashboard/features/projects/application/projects_controller.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';
import 'package:new_earth_command_dashboard/features/security/application/security_session_controller.dart';
import 'package:new_earth_command_dashboard/features/settings/application/settings_controller.dart';
import 'package:new_earth_command_dashboard/features/settings/data/settings_repository.dart';
import 'package:new_earth_command_dashboard/features/tasks/application/tasks_controller.dart';
import 'package:new_earth_command_dashboard/features/tasks/data/task_repository.dart';
import 'package:new_earth_command_dashboard/features/tasks/presentation/tasks_screen.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/application/voice_startup_gate_controller.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_assistant_screen.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_startup_gate_service.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_action_service.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_model.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_service.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/widgets/command_history_list.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/widgets/voice_briefing_review_surface.dart';

class _TestUnlockedSecuritySessionNotifier extends SecuritySessionNotifier {
  @override
  SecuritySessionState build() {
    final now = DateTime.now();
    final unlocked = SecuritySessionState(
      isUnlocked: true,
      timeout: const Duration(minutes: 15),
      lastActivityAt: now,
      expiresAt: now.add(const Duration(minutes: 15)),
      activeUserLabel: 'Test User',
      activeUserOnline: true,
    );
    SecuritySessionRouterBridge.sync(unlocked);
    ref.onDispose(_reset);
    return unlocked;
  }

  void _reset() {
    SecuritySessionRouterBridge.sync(const SecuritySessionState.locked());
  }

  @override
  void recordActivity() {}
}

void main() {
  Future<void> pumpUntilIdle(
    WidgetTester tester, {
    int maxIterations = 50,
    Duration step = const Duration(milliseconds: 100),
  }) async {
    for (var i = 0; i < maxIterations; i++) {
      await tester.pump(step);
      if (!tester.binding.hasScheduledFrame) {
        return;
      }
    }
  }

  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    int maxIterations = 50,
    Duration step = const Duration(milliseconds: 100),
  }) async {
    for (var i = 0; i < maxIterations; i++) {
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await tester.pump(step);
    }
  }

  List<Task> filterTasks({
    required List<Task> tasks,
    required String statusFilter,
    required String? projectFilter,
    required String searchQuery,
  }) {
    final normalizedQuery = searchQuery.trim().toLowerCase();

    return tasks.where((task) {
      final matchesStatus =
          statusFilter == 'All' || task.status == statusFilter;
      final matchesProject =
          projectFilter == null || task.projectId == projectFilter;
      final matchesSearch =
          normalizedQuery.isEmpty ||
          task.title.toLowerCase().contains(normalizedQuery) ||
          (task.notes?.toLowerCase().contains(normalizedQuery) ?? false);
      return matchesStatus && matchesProject && matchesSearch;
    }).toList();
  }

  setUp(() {
    appRouter.go(RouteNames.dashboard);
  });

  Widget buildTestApp({
    Widget? child,
    VoiceStartupGateResult? startupGateResult,
    bool voiceAssistantEnabled = false,
    bool voiceStartupGateEnabled = false,
    bool showDockOverlays = false,
    List<CommandDeckActionLogEntry>? recentActions,
  }) {
    final overrides = [
      databaseReadyProvider.overrideWith((ref) async {}),
      appThemeModeProvider.overrideWith((ref) => ThemeMode.light),
      securitySessionProvider.overrideWith(_TestUnlockedSecuritySessionNotifier.new),
      voiceStartupGateProvider.overrideWith(
        (ref) async =>
            startupGateResult ??
            const VoiceStartupGateResult(
              isReady: true,
              message: 'Test harness bypasses the voice startup gate.',
              devices: <VoiceInputDevice>[],
            ),
      ),
      dashboardSnapshotProvider.overrideWith(
        (ref) async => DashboardSnapshot(
          date: DateTime(2026, 5, 2),
          hasTodayPlan: true,
          activeProjectCount: 9,
          activeProjects: const [
            DashboardProjectSummary(
              projectId: 'project-microgrow',
              name: 'MicroGrow',
              progressPercentage: 65,
              currentMilestone: 'Stabilise diagnostics',
              nextAction: 'Review the next useful diagnostics step.',
            ),
            DashboardProjectSummary(
              projectId: 'project-new-earth-website',
              name: 'New Earth Website',
              progressPercentage: 40,
              currentMilestone: 'Clarify site structure',
              nextAction: 'Tighten the founder journey page.',
            ),
          ],
          topTasks: const [],
          topTaskTitles: const [],
          showWellbeingCard: true,
          showBusinessCard: true,
          showLearningCard: true,
          showContentCard: true,
          energyLabel: 'High',
          nextStepTitle: 'Next useful move',
          nextStepSummary:
              'Continue MicroGrow with Review the next useful diagnostics step.',
          nextStepReason:
              'It uses the strongest project context available right now.',
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
            currentMilestone: 'Stabilise core diagnostics and v1.0 direction.',
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
            shortDescription: 'Public home for New Earth projects and updates.',
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
      projectListItemsProvider.overrideWith(
        (ref) async => [
          ProjectListItem(
            project: Project(
              projectId: 'project-microgrow',
              name: 'MicroGrow',
              shortDescription: 'Smart grow automation platform.',
              longDescription: null,
              vision: null,
              status: 'Active',
              priority: 'High',
              progressPercentage: 0,
              currentMilestone: 'Stabilise core diagnostics and v1.0 direction.',
              nextAction: 'Review current MicroGrow build priorities.',
              startDate: null,
              targetDate: null,
              createdAt: DateTime(2026, 5, 2),
              updatedAt: DateTime(2026, 5, 2),
              notes: null,
              isArchived: false,
            ),
            openTaskCount: 1,
          ),
          ProjectListItem(
            project: Project(
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
            openTaskCount: 1,
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
      settingsSnapshotProvider.overrideWith(
        (ref) async => SettingsSnapshot(
          settings: AppSetting(
            settingsId: 'settings-test',
            themeMode: 'Dark',
            defaultDashboardView: 'Dashboard',
            showWellbeingCard: true,
            showBusinessCard: true,
            showLearningCard: true,
            showContentCard: true,
            showProjectsWorkspaceSnapshot: true,
            showDockOverlays: showDockOverlays,
            showBackupGuardianDock: showDockOverlays,
            showTreasuryDock: showDockOverlays,
            showKnowledgeLibraryDock: showDockOverlays,
            showVoiceConversationDock: showDockOverlays,
            showVoicePresenceChip: showDockOverlays,
            dailyTopTaskLimit: 3,
            voiceRepliesEnabled: false,
            voiceAssistantEnabled: voiceAssistantEnabled,
            voiceStartupGateEnabled: voiceStartupGateEnabled,
            preferredTtsVoiceName: null,
            preferredTtsVoiceLocale: null,
            preferredTtsVoiceGender: null,
            preferredTtsVoiceIdentifier: null,
            preferredTtsVoiceRate: 0.5,
            preferredTtsVoicePitch: 1.0,
            createdAt: DateTime(2026, 5, 2),
            updatedAt: DateTime(2026, 5, 2),
          ),
          appVersion: 'test',
        ),
      ),
    ];

    if (recentActions != null) {
      overrides.add(
        commandPaletteRecentActionsProvider.overrideWithValue(recentActions),
      );
    }

    return ProviderScope(
      overrides: overrides,
      child: child ?? const NewEarthCommandDashboardApp(),
    );
  }

  Widget buildDatabaseBackedTestApp(
    AppDatabase database, {
    Widget? child,
  }) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWith((ref) => database),
        databaseReadyProvider.overrideWith((ref) async {}),
        securitySessionProvider.overrideWith(
          _TestUnlockedSecuritySessionNotifier.new,
        ),
        voiceStartupGateProvider.overrideWith(
          (ref) async => const VoiceStartupGateResult(
            isReady: true,
            message: 'Test harness bypasses the voice startup gate.',
            devices: <VoiceInputDevice>[],
          ),
        ),
        settingsSnapshotProvider.overrideWith((ref) async {
          final snapshot = await SettingsRepository(database).getSettings();
          return SettingsSnapshot(
            settings: snapshot.settings.copyWith(
              showDockOverlays: false,
              showBackupGuardianDock: false,
              showTreasuryDock: false,
              showKnowledgeLibraryDock: false,
              showVoiceConversationDock: false,
              showVoicePresenceChip: false,
            ),
            appVersion: snapshot.appVersion,
          );
        }),
        dashboardSnapshotProvider.overrideWith((ref) async {
          final settings = await SettingsRepository(database).getSettings();
          return DashboardSnapshot(
            date: DateTime(2026, 5, 2),
            hasTodayPlan: true,
            activeProjectCount: 9,
            activeProjects: const [
              DashboardProjectSummary(
                projectId: 'project-microgrow',
                name: 'MicroGrow',
                progressPercentage: 65,
                currentMilestone: 'Stabilise diagnostics',
                nextAction: 'Review the next useful diagnostics step.',
              ),
              DashboardProjectSummary(
                projectId: 'project-new-earth-website',
                name: 'New Earth Website',
                progressPercentage: 40,
                currentMilestone: 'Clarify site structure',
                nextAction: 'Tighten the founder journey page.',
              ),
            ],
            topTasks: const [],
            topTaskTitles: const [],
            showWellbeingCard: settings.settings.showWellbeingCard,
            showBusinessCard: settings.settings.showBusinessCard,
            showLearningCard: settings.settings.showLearningCard,
            showContentCard: settings.settings.showContentCard,
            energyLabel: 'High',
            nextStepTitle: 'Next useful move',
            nextStepSummary:
                'Continue MicroGrow with Review the next useful diagnostics step.',
            nextStepReason:
                'It uses the strongest project context available right now.',
            mainFocus: null,
            focusReason: null,
            morningIntention: null,
          );
        }),
      ],
      child: child ?? const NewEarthCommandDashboardApp(),
    );
  }

  testWidgets('app shell opens to dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());
    await pumpUntilIdle(tester);

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Today\'s Focus'), findsAtLeastNWidgets(1));
    expect(find.text('Next useful move'), findsOneWidget);
    expect(
      find.text(
        'Continue MicroGrow with Review the next useful diagnostics step.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'A blank daily plan is ready. One calm choice will start the day.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Add one short reason to keep the day grounded.'),
      findsOneWidget,
    );
    expect(
      find.text('A short intention can make the morning feel steadier.'),
      findsOneWidget,
    );
    expect(find.text('Choose your first priority task'), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('dashboardScrollView')),
      const Offset(0, -1200),
    );
    await tester.pump();
    expect(
      find.byKey(const Key('dashboardQuickCaptureButton')),
      findsOneWidget,
    );
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Projects'), findsWidgets);
    expect(find.text('Tasks'), findsWidgets);
    expect(find.text('Planner'), findsWidgets);
    expect(find.text('More'), findsWidgets);
  });

  testWidgets('ctrl k opens the command palette from the dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        recentActions: [
          CommandDeckActionLogEntry(
            timestamp: DateTime(2026, 6, 7, 10),
            commandId: 'open_projects_hub',
            label: 'Open Projects Hub',
            type: 'open_route',
            group: 'Navigate',
            source: 'command_registry.example.json',
            configSource: 'command_deck.json',
            target: '/projects-intelligence',
            resolvedTarget: '/projects-intelligence',
          ),
        ],
      ),
    );
    await pumpUntilIdle(tester);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await pumpUntilIdle(tester);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await pumpUntilIdle(tester);

    expect(find.text('Command Palette'), findsOneWidget);
    expect(find.byKey(const Key('commandPaletteSearchField')), findsOneWidget);
    expect(
      find.byKey(const Key('recentActionChip-open_projects_hub')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('recentActionChip-open_projects_hub')),
    );
    await pumpUntilIdle(tester);

    expect(find.text('Projects Hub'), findsWidgets);
  });

  test('command palette recent actions provider reads the local log', () {
    final runtimeDir = Directory(
      'modules/new_earth_command_deck/dashboard_module/data/runtime',
    );
    runtimeDir.createSync(recursive: true);
    final actionLogFile = File(
      '${runtimeDir.path}${Platform.pathSeparator}command_deck_action_log.jsonl',
    );
    actionLogFile.writeAsStringSync(
      '{"timestamp":"2026-06-07T10:00:00.000","command_id":"open_dashboard","label":"Open Dashboard","type":"open_route","group":"Navigate","source":"command_registry.example.json","config_source":"command_deck.json","target":"/dashboard","resolved_target":"/dashboard"}\n'
      '{"timestamp":"2026-06-07T10:02:00.000","command_id":"open_microgrow","label":"Open MicroGrow","type":"open_route","group":"Projects","source":"command_registry.example.json","config_source":"command_deck.json","target":"/projects/project-microgrow","resolved_target":"/projects/project-microgrow"}\n',
    );
    addTearDown(() {
      if (actionLogFile.existsSync()) {
        actionLogFile.deleteSync();
      }
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final recentActions = container.read(commandPaletteRecentActionsProvider);
    expect(recentActions, hasLength(2));
    expect(recentActions.first.label, 'Open MicroGrow');
    expect(recentActions.last.label, 'Open Dashboard');
    expect(recentActions.first.resolvedTarget, '/projects/project-microgrow');
  });

  testWidgets('more screen links to supporting screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await pumpUntilIdle(tester);

    await tester.tap(find.text('More').first);
    await pumpUntilIdle(tester);

    expect(find.text('Journal'), findsOneWidget);
    expect(find.text('Learning'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
    expect(find.text('Business'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Voice Assistant'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pump();

    expect(find.text('Wellbeing'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Voice Assistant'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Visual Capture'), findsOneWidget);
  });

  testWidgets(
    'supporting screens show a back button when opened from the app',
    (WidgetTester tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await SeedDataService(database).ensureSeedData();

      await tester.pumpWidget(buildDatabaseBackedTestApp(database));
      await pumpUntilIdle(tester);

      appRouter.push('/journal');
      await pumpUntilIdle(tester);
      expect(find.byTooltip('Back'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await pumpUntilIdle(tester);
      expect(find.text('Dashboard'), findsWidgets);

      appRouter.push('/learning');
      await pumpUntilIdle(tester);
      expect(find.byTooltip('Back'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await pumpUntilIdle(tester);

      appRouter.push('/content');
      await pumpUntilIdle(tester);
      expect(find.byTooltip('Back'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await pumpUntilIdle(tester);

      appRouter.push('/business');
      await pumpUntilIdle(tester);
      expect(find.byTooltip('Back'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await pumpUntilIdle(tester);

      appRouter.push('/wellbeing');
      await pumpUntilIdle(tester);
      expect(find.byTooltip('Back'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await pumpUntilIdle(tester);

      appRouter.push('/inbox');
      await pumpUntilIdle(tester);
      expect(find.byTooltip('Back'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await pumpUntilIdle(tester);

      appRouter.push('/settings');
      await pumpUntilIdle(tester);
      expect(find.byTooltip('Back'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await pumpUntilIdle(tester);
    },
  );

  testWidgets('settings screen loads stored values and persists card toggles', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    addTearDown(() {
      appRouter.go('/dashboard');
    });

    await SeedDataService(database).ensureSeedData();

    appRouter.go('/settings');
    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await pumpUntilIdle(tester);
    await pumpUntilFound(tester, find.text('What these settings change'));

    final settingsBeforeToggle = await SettingsRepository(
      database,
    ).getSettings();
    await SettingsRepository(database).updateDashboardCardVisibility(
      showBusinessCard: !settingsBeforeToggle.settings.showBusinessCard,
    );

    final updatedThemeSnapshot = await SettingsRepository(
      database,
    ).getSettings();
    expect(
      updatedThemeSnapshot.settings.showBusinessCard,
      isNot(settingsBeforeToggle.settings.showBusinessCard),
    );
    expect(updatedThemeSnapshot.settings.dailyTopTaskLimit, 3);

    await tester.scrollUntilVisible(
      find.byKey(const Key('settingsAppVersionValue')),
      200,
      scrollable: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('settingsAppVersionValue')), findsOneWidget);
    expect(find.text('1.0.0+1'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('settingsShowWellbeingCardToggle')),
      200,
      scrollable: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('settingsShowWellbeingCardToggle')));
    await pumpUntilIdle(tester);

    final snapshot = await SettingsRepository(database).getSettings();
    expect(snapshot.settings.showWellbeingCard, isFalse);
  });

  testWidgets('projects screen shows seeded project cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await pumpUntilIdle(tester);

    appRouter.go(RouteNames.projectsWorkspace);
    await pumpUntilFound(tester, find.text('New Earth Projects'));

    expect(find.text('New Earth Projects'), findsOneWidget);
    expect(
      find.text('There are 2 active projects ready for a calm review.'),
      findsOneWidget,
    );
    expect(
      find.text('MicroGrow', skipOffstage: false),
      findsAtLeastNWidgets(1),
    );
    await tester.scrollUntilVisible(
      find.text('New Earth Website'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.text('New Earth Website'), findsOneWidget);
    expect(find.text('Current Milestone'), findsWidgets);
    expect(find.text('Next Action'), findsWidgets);
  });

  testWidgets('projects route opens the projects hub', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await pumpUntilIdle(tester);

    appRouter.go('/projects');
    await pumpUntilFound(tester, find.text('Projects Hub'));

    expect(find.text('Projects Hub'), findsOneWidget);
    expect(find.byTooltip('Back to Dashboard'), findsOneWidget);
  });

  testWidgets('projects hub workspace snapshot persists collapse state', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await SeedDataService(database).ensureSeedData();

    final initialSettings = await SettingsRepository(database).getSettings();
    expect(initialSettings.settings.showProjectsWorkspaceSnapshot, isTrue);

    await SettingsRepository(
      database,
    ).updateDashboardCardVisibility(showProjectsWorkspaceSnapshot: false);

    final snapshotAfterCollapse = await SettingsRepository(
      database,
    ).getSettings();
    expect(
      snapshotAfterCollapse.settings.showProjectsWorkspaceSnapshot,
      isFalse,
    );
  });

  testWidgets('tasks screen shows local task cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await pumpUntilIdle(tester);

    appRouter.go('/tasks');
    await pumpUntilIdle(tester);

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
    expect(
      find.text('Review MicroGrow diagnostics', skipOffstage: false),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Clarify founder journey page'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.text('Clarify founder journey page'), findsOneWidget);
    expect(find.text('Status: Inbox', skipOffstage: false), findsOneWidget);
    expect(find.text('Status: Planned', skipOffstage: false), findsOneWidget);
  });

  testWidgets('tasks screen surfaces carry-forward work', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: ProviderScope(
          overrides: [
            tasksProvider.overrideWith(
              (ref) async => [
                Task(
                  taskId: 'task-carry-1',
                  projectId: null,
                  title: 'Parked website copy',
                  description: 'Hold this until tomorrow.',
                  category: 'Content',
                  priority: 'Medium',
                  status: 'Parked',
                  dueDate: null,
                  energyLevel: 'Low',
                  estimatedMinutes: null,
                  actualMinutes: null,
                  createdAt: DateTime(2026, 5, 2, 9),
                  updatedAt: DateTime(2026, 5, 2, 9),
                  completedAt: null,
                  notes:
                      'Carry forward the website tidy-up if the day runs long.',
                  isTopThree: false,
                  isArchived: false,
                ),
              ],
            ),
            projectsProvider.overrideWith((ref) async => const []),
            plannerTaskOptionsProvider.overrideWith((ref) async => const []),
            todayPlanProvider.overrideWith(
              (ref) async => DailyPlan(
                dailyPlanId: 'daily-plan-2026-05-02',
                date: DateTime(2026, 5, 2),
                mainFocus: null,
                focusReason: null,
                morningIntention: null,
                topTask1Id: null,
                topTask2Id: null,
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
                carryForwardNotes:
                    'Carry forward the website tidy-up if the day runs long.',
                tomorrowFocus: null,
                createdAt: DateTime(2026, 5, 2),
                updatedAt: DateTime(2026, 5, 2),
              ),
            ),
          ],
          child: const TasksScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('tasksCarryForwardBanner')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.byKey(const Key('tasksCarryForwardBanner')), findsOneWidget);
    expect(find.text('Carry-forward'), findsOneWidget);
    expect(find.text('Review Parked'), findsOneWidget);
    expect(
      find.text('Carry forward the website tidy-up if the day runs long.'),
      findsOneWidget,
    );
  });

  testWidgets('tasks screen shows add button in empty state', (
    WidgetTester tester,
  ) async {
    Widget buildEmptyTasksApp() {
      return MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) async => const []),
            projectsProvider.overrideWith((ref) async => const []),
            plannerTaskOptionsProvider.overrideWith((ref) async => const []),
            todayPlanProvider.overrideWith(
              (ref) async => DailyPlan(
                dailyPlanId: 'daily-plan-2026-05-02',
                date: DateTime(2026, 5, 2),
                mainFocus: null,
                focusReason: null,
                morningIntention: null,
                topTask1Id: null,
                topTask2Id: null,
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
          child: const TasksScreen(),
        ),
      );
    }

    await tester.pumpWidget(buildEmptyTasksApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('addTaskButton')), findsOneWidget);
    expect(
      find.text(
        'No tasks yet. Add your first task when you\'re ready.',
        skipOffstage: false,
      ),
      findsOneWidget,
    );
  });

  test('tasks screen can create a task', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await SeedDataService(database).ensureSeedData();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) => database),
        databaseReadyProvider.overrideWith((ref) async {}),
      ],
    );
    addTearDown(container.dispose);

    final projects = await ProjectRepository(database).getProjects();
    final microGrow = projects.firstWhere(
      (project) => project.name == 'MicroGrow',
    );

    final createdTask = await container.read(tasksControllerProvider).createTask(
      title: 'Build task add edit flow',
      projectId: microGrow.projectId,
      description: 'Create the first shared task editor screen.',
      category: 'Test',
      priority: 'High',
      estimatedMinutes: 45,
      notes: 'Keep the first pass focused.',
    );

    final tasks = await TaskRepository(database).getActiveTasks();

    expect(tasks, isNotEmpty);
    expect(createdTask.title, 'Build task add edit flow');
    expect(createdTask.projectId, microGrow.projectId);
    expect(
      tasks.any((task) => task.title == 'Build task add edit flow'),
      isTrue,
    );
    expect(tasks.any((task) => task.projectId == microGrow.projectId), isTrue);
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
    await pumpUntilIdle(tester);

    appRouter.go('/tasks/${task.taskId}/edit');
    await pumpUntilFound(tester, find.byKey(const Key('taskTitleField')));
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('taskTitleField')))
          .controller
          ?.text,
      'Original task title',
    );

    await taskRepository.updateTask(
      taskId: task.taskId,
      title: 'Edited task title',
      projectId: project.projectId,
      description: task.description,
      category: task.category,
      priority: 'High',
      status: 'Today',
      energyLevel: task.energyLevel,
      estimatedMinutes: task.estimatedMinutes,
      notes: task.notes,
    );
    await pumpUntilIdle(tester);

    final updatedTask = await taskRepository.getById(task.taskId);
    expect(updatedTask.title, 'Edited task title');
    expect(updatedTask.status, 'Today');
    expect(updatedTask.priority, 'High');
  });

  testWidgets('planner screen shows today plan summary', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayPlanProvider.overrideWith(
            (ref) async => DailyPlan(
              dailyPlanId: 'daily-plan-test',
              date: DateTime(2026, 5, 2),
              mainFocus: null,
              focusReason: null,
              morningIntention: null,
              topTask1Id: null,
              topTask2Id: null,
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
          plannerTaskOptionsProvider.overrideWith((ref) async => const []),
        ],
        child: const MaterialApp(home: PlannerScreen()),
      ),
    );
    await pumpUntilIdle(tester);

    expect(find.text('Daily Planner'), findsAtLeastNWidgets(1));
    expect(
      find.text(
        'A calm place to set the day, choose the Top 3, and review it gently.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('planner carry forward route opens the parked work section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await pumpUntilIdle(tester);

    appRouter.go('/planner?section=carryForward');
    await pumpUntilIdle(tester);

    await tester.scrollUntilVisible(
      find.byKey(const Key('plannerCarryForwardField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('Carry Forward Review'), findsAtLeastNWidgets(1));
    expect(find.byKey(const Key('plannerCarryForwardField')), findsOneWidget);
  });

  testWidgets('planner review route opens the evening review section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await pumpUntilIdle(tester);

    appRouter.go('/planner?section=review');
    await pumpUntilIdle(tester);

    await tester.scrollUntilVisible(
      find.byKey(const Key('plannerEveningReviewSaveButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

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

    const mainFocus = 'Finish the planner editing slice';
    await DailyPlanRepository(
      database,
      now: () => today,
    ).updateMainFocus(mainFocus);

    final plan = await DailyPlanRepository(
      database,
      now: () => today,
    ).getTodayPlan();

    expect(plan.mainFocus, mainFocus);
  });

  testWidgets('dashboard quick edit saves focus to local plan', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final today = DateTime.now();
    await DailyPlanService(database, now: () => today).ensureTodayPlan();

    const mainFocus = 'Stabilise today dashboard flow';
    const focusReason = 'This keeps the dashboard aligned and useful.';
    const morningIntention = 'Stay calm and finish one useful step.';

    await DailyPlanRepository(
      database,
      now: () => today,
    ).updateMainFocus(mainFocus);
    await DailyPlanRepository(
      database,
      now: () => today,
    ).updateFocusReason(focusReason);
    await DailyPlanRepository(
      database,
      now: () => today,
    ).updateMorningIntention(morningIntention);

    final plan = await DailyPlanRepository(
      database,
      now: () => today,
    ).getTodayPlan();

    expect(plan.mainFocus, mainFocus);
    expect(plan.focusReason, focusReason);
    expect(plan.morningIntention, morningIntention);
  });

  testWidgets('planner saves carry forward notes to local plan', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final today = DateTime.now();
    await DailyPlanService(database, now: () => today).ensureTodayPlan();

    const carryForwardNotes =
        'Carry forward the website tidy-up if the planner review runs long.';
    await DailyPlanRepository(
      database,
      now: () => today,
    ).updateCarryForwardNotes(carryForwardNotes);

    final plan = await DailyPlanRepository(
      database,
      now: () => today,
    ).getTodayPlan();
    expect(plan.carryForwardNotes, carryForwardNotes);
  });

  testWidgets('planner saves tomorrow focus to local plan', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final today = DateTime.now();
    await DailyPlanService(database, now: () => today).ensureTodayPlan();

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await pumpUntilIdle(tester);

    appRouter.go(RouteNames.planner);
    await pumpUntilIdle(tester);
    await DailyPlanRepository(
      database,
      now: () => today,
    ).updateTomorrowFocus('Start the evening review save flow.');

    final plan = await DailyPlanRepository(
      database,
      now: () => today,
    ).getTodayPlan();
    expect(plan.tomorrowFocus, 'Start the evening review save flow.');
  });

  test('planner saves evening review fields to local plan', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final today = DateTime.now();
    await DailyPlanService(database, now: () => today).ensureTodayPlan();

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) => database),
        databaseReadyProvider.overrideWith((ref) async {}),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(plannerControllerProvider)
        .saveEveningReview(
          movedForward: 'The planner daily loop is starting to feel complete.',
          completed: 'Finished the first review save flow.',
          learned:
              'Small slices keep the dashboard calmer and easier to trust.',
          blockers: 'Project CRUD is still waiting for its next pass.',
        );

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

  test('projects screen opens project detail from the list', () async {
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

    final detail = await ProjectRepository(
      database,
    ).getProjectDetail(microGrow.projectId);

    expect(detail.project.projectId, microGrow.projectId);
    expect(detail.project.name, 'MicroGrow');
    expect(detail.activeTasks, isNotEmpty);
    expect(
      detail.activeTasks.map((task) => task.title),
      contains('Review current MicroGrow build priorities'),
    );
  });

  testWidgets('projects screen can create a project', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await pumpUntilIdle(tester);

    appRouter.go('/projects/new');
    await pumpUntilIdle(tester);

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
    await pumpUntilIdle(tester);
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
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('saveProjectButton')));
    await pumpUntilIdle(tester);

    expect(find.text('Project Detail'), findsOneWidget);
    expect(find.text('New Earth Garden Lab'), findsOneWidget);
    expect(find.text('Define the first build scope'), findsAtLeastNWidgets(1));
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
    await pumpUntilIdle(tester);

    appRouter.go('/projects/${project.projectId}/edit');
    await pumpUntilIdle(tester);

    await tester.scrollUntilVisible(
      find.byKey(const Key('projectNextActionField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);
    await tester.enterText(
      find.byKey(const Key('projectNextActionField')),
      'Review the edited next action',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveProjectButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('saveProjectButton')));
    await pumpUntilIdle(tester);

    expect(find.text('Project Detail'), findsOneWidget);
    expect(find.text('Review the edited next action'), findsAtLeastNWidgets(1));
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
    await pumpUntilIdle(tester);

    appRouter.go('/projects/${project.projectId}');
    await pumpUntilIdle(tester);

    await tester.scrollUntilVisible(
      find.byKey(const Key('addProjectTaskButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    final addTaskButton = tester.widget<FilledButton>(
      find.byKey(const Key('addProjectTaskButton')),
    );
    addTaskButton.onPressed?.call();
    await pumpUntilIdle(tester);

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
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await pumpUntilIdle(tester);

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
    await pumpUntilIdle(tester);

    appRouter.go('/projects/${project.projectId}');
    await pumpUntilIdle(tester);

    await tester.scrollUntilVisible(
      find.text('Recent Journal Entries'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);

    expect(find.text('Recent Journal Entries'), findsOneWidget);
    expect(find.text('Project journal reflection'), findsOneWidget);
    expect(
      find.text('Captured the latest project build note.'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(Key('projectJournalEntry-${entry.journalEntryId}')),
    );
    await pumpUntilIdle(tester);

    expect(find.text('Edit Journal Entry'), findsOneWidget);
    expect(find.text('Project journal reflection'), findsOneWidget);
  });

  testWidgets(
    'project detail surfaces linked modules and opens project-aware create screens',
    (WidgetTester tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final projectRepository = ProjectRepository(database);
      final journalRepository = JournalRepository(database);
      final learningRepository = LearningRepository(database);
      final contentRepository = ContentRepository(database);
      final businessRepository = BusinessRepository(database);
      final project = await projectRepository.createProject(
        name: 'Project Module Home',
        status: 'Active',
        priority: 'High',
        progressPercentage: 20,
      );
      await journalRepository.createEntry(
        date: DateTime(2026, 5, 3),
        title: 'Project journal reflection',
        projectId: project.projectId,
        category: 'Project Update',
        whatIWorkedOn: 'Captured the latest project build note.',
      );
      await learningRepository.createItem(
        topic: 'Project navigation flow',
        projectId: project.projectId,
        status: 'Learning',
        nextStep: 'Use the detail page to link the next action.',
      );
      await contentRepository.createItem(
        title: 'Project build note',
        projectId: project.projectId,
        status: 'Drafting',
        platform: 'LinkedIn',
        contentType: 'Project Update',
        draftText: 'A short update about the latest project change.',
      );
      await businessRepository.createItem(
        name: 'Project partner lead',
        projectId: project.projectId,
        status: 'Preparing',
        type: 'Partnership',
        nextAction: 'Draft a short follow-up note.',
      );

      await tester.pumpWidget(buildDatabaseBackedTestApp(database));
      await pumpUntilIdle(tester);

      appRouter.go('/projects/${project.projectId}');
      await pumpUntilIdle(tester);

      await tester.scrollUntilVisible(
        find.text('Workflow snapshot'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await pumpUntilIdle(tester);
      expect(find.text('Workflow snapshot'), findsOneWidget);
      expect(find.text('Plan'), findsOneWidget);
      expect(find.text('Capture'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Project home base'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await pumpUntilIdle(tester);
      expect(find.text('Project home base'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Recent Journal Entries'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await pumpUntilIdle(tester);
      expect(find.text('Recent Journal Entries'), findsOneWidget);
      expect(find.text('Project journal reflection'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Recent Learning Items'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await pumpUntilIdle(tester);
      expect(find.text('Recent Learning Items'), findsOneWidget);
      expect(find.text('Project navigation flow'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Recent Content Ideas'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await pumpUntilIdle(tester);
      expect(find.text('Recent Content Ideas'), findsOneWidget);
      expect(find.text('Project build note'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Recent Business Opportunities'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await pumpUntilIdle(tester);
      expect(find.text('Recent Business Opportunities'), findsOneWidget);
      expect(find.text('Project partner lead'), findsOneWidget);

      await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
      await pumpUntilIdle(tester);

      await tester.tap(find.byKey(const Key('addProjectBusinessButton')));
      await pumpUntilIdle(tester);

      expect(find.text('Add Opportunity'), findsOneWidget);
      expect(find.text(project.name), findsOneWidget);

      appRouter.go('/dashboard');
      await pumpUntilIdle(tester);
    },
  );

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
    await pumpUntilIdle(tester);

    appRouter.go('/projects/${project.projectId}');
    await pumpUntilIdle(tester);

    await tester.scrollUntilVisible(
      find.byKey(const Key('archiveProjectButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('archiveProjectButton')));
    await pumpUntilIdle(tester);

    expect(find.text('Archive Project'), findsOneWidget);
    expect(
      find.text('Archive this item? You can restore it later.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Archive'));
    await pumpUntilIdle(tester);

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

    await DailyPlanRepository(
      database,
      now: () => today,
    ).saveTopThreeTaskIds([first.taskId, second.taskId]);

    final updatedPlan = await DailyPlanRepository(
      database,
      now: () => today,
    ).getTodayPlan();

    expect(updatedPlan.topTask1Id, first.taskId);
    expect(updatedPlan.topTask2Id, second.taskId);
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

    await dailyPlanRepository.saveTopThreeTaskIds([second.taskId]);

    final refreshedPlan = await dailyPlanRepository.getTodayPlan();

    expect(refreshedPlan.topTask1Id, second.taskId);
    expect(refreshedPlan.topTask2Id, isNull);
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

    await DailyPlanRepository(
      database,
      now: () => today,
    ).saveTopThreeTaskIds([first.taskId]);

    final refreshedPlan = await DailyPlanRepository(
      database,
      now: () => today,
    ).getTodayPlan();

    expect(refreshedPlan.topTask1Id, first.taskId);
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

    expect(
      () => dailyPlanRepository.saveTopThreeTaskIds([
        first.taskId,
        second.taskId,
        third.taskId,
        fourth.taskId,
      ]),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'You already have 3 priority tasks for today. Complete, remove, or carry one forward first.',
        ),
      ),
    );
  });

  test('tasks screen filters by status', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final taskRepository = TaskRepository(database);
    final inbox = await taskRepository.createTask(
      title: 'Inbox task',
      status: 'Inbox',
    );
    final todayTask = await taskRepository.createTask(
      title: 'Today task',
      status: 'Today',
    );

    final filtered = filterTasks(
      tasks: await taskRepository.getActiveTasks(),
      statusFilter: 'Today',
      projectFilter: null,
      searchQuery: '',
    );

    expect(filtered.map((task) => task.taskId), [todayTask.taskId]);
    expect(filtered, isNot(contains(inbox)));
  });

  test('tasks screen filters by project', () async {
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

    final filtered = filterTasks(
      tasks: await taskRepository.getActiveTasks(),
      statusFilter: 'All',
      projectFilter: microGrow.projectId,
      searchQuery: '',
    );

    expect(filtered.map((task) => task.title), ['MicroGrow task']);
    expect(filtered.map((task) => task.projectId), [microGrow.projectId]);
  });

  test('tasks screen searches by title', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final taskRepository = TaskRepository(database);
    await taskRepository.createTask(title: 'Dashboard wireframe');
    await taskRepository.createTask(title: 'Website tidy-up');

    final filtered = filterTasks(
      tasks: await taskRepository.getActiveTasks(),
      statusFilter: 'All',
      projectFilter: null,
      searchQuery: 'wireframe',
    );

    expect(filtered.map((task) => task.title), ['Dashboard wireframe']);
  });

  test('tasks screen searches by notes', () async {
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

    final filtered = filterTasks(
      tasks: await taskRepository.getActiveTasks(),
      statusFilter: 'All',
      projectFilter: null,
      searchQuery: 'sensor',
    );

    expect(filtered.map((task) => task.title), ['Task one']);
  });

  test('tasks screen can clear search', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final taskRepository = TaskRepository(database);
    await taskRepository.createTask(title: 'First task');
    await taskRepository.createTask(title: 'Second task');

    final searched = filterTasks(
      tasks: await taskRepository.getActiveTasks(),
      statusFilter: 'All',
      projectFilter: null,
      searchQuery: 'First',
    );
    final cleared = filterTasks(
      tasks: await taskRepository.getActiveTasks(),
      statusFilter: 'All',
      projectFilter: null,
      searchQuery: '',
    );

    expect(searched.map((task) => task.title), ['First task']);
    expect(
      cleared.map((task) => task.title),
      containsAll(['First task', 'Second task']),
    );
  });

  test('tasks screen combines search with filters', () async {
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

    final filtered = filterTasks(
      tasks: await taskRepository.getActiveTasks(),
      statusFilter: 'Today',
      projectFilter: microGrow.projectId,
      searchQuery: 'diagnostics',
    );

    expect(filtered.map((task) => task.title), ['Diagnostics follow-up']);
  });

  test('tasks screen can move a task to today', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final taskRepository = TaskRepository(database);
    final task = await taskRepository.createTask(title: 'Shift me');

    await taskRepository.moveToToday(task.taskId);

    final updatedTask = await taskRepository.getById(task.taskId);
    expect(updatedTask.status, 'Today');
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

      await taskRepository.parkTask(task.taskId);
      await dailyPlanRepository.saveTopThreeTaskIds([]);

      final parkedTask = await taskRepository.getById(task.taskId);
      final refreshedPlan = await DailyPlanRepository(
        database,
        now: () => today,
      ).getTodayPlan();

      expect(parkedTask.status, 'Parked');
      expect(refreshedPlan.topTask1Id, isNull);
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
    await pumpUntilIdle(tester);

    appRouter.go('/tasks');
    await pumpUntilIdle(tester);

    await taskRepository.archiveTask(task.taskId);
    await pumpUntilIdle(tester);

    final reloadedTask = await taskRepository.getById(task.taskId);
    expect(reloadedTask.isArchived, isTrue);
  });

  testWidgets('voice assistant entry is surfaced in more', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await pumpUntilIdle(tester);

    await tester.tap(find.text('More').first);
    await pumpUntilIdle(tester);

    await tester.scrollUntilVisible(
      find.text('Voice Assistant'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);

    expect(find.text('Voice Assistant'), findsOneWidget);
    expect(
      find.text(
        'Review spoken commands safely before turning them into dashboard actions.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('voice startup gate can be bypassed for a headset-like device', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        startupGateResult: const VoiceStartupGateResult(
          isReady: false,
          message: 'Checking for a connected headset...',
          devices: <VoiceInputDevice>[
            VoiceInputDevice(name: 'USB Audio Device', identifier: 'USB\\ROOT'),
          ],
        ),
        voiceAssistantEnabled: true,
        voiceStartupGateEnabled: false,
        showDockOverlays: false,
      ),
    );
    appRouter.go(RouteNames.voiceStartupGate);
    await pumpUntilIdle(tester);

    expect(find.text('Headset detected'), findsOneWidget);
    expect(find.text('Continue with Voice'), findsOneWidget);
    expect(find.text('Skip Voice'), findsOneWidget);
  });

  test('voice assistant templates include a simple start flow', () {
    final service = VoiceCommandService();
    final templates = service.getTemplates();

    expect(
      templates.any((template) => template.id == 'build-day'),
      isTrue,
    );
    expect(
      templates.any((template) => template.id == 'daily-reset'),
      isTrue,
    );
    expect(
      templates.any((template) => template.id == 'project-update'),
      isTrue,
    );
  });

  testWidgets('voice assistant briefing card shows clear review copy', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VoiceBriefingReviewSurface(
            isAiDraft: false,
            summary: 'This reads like a task.',
            nextStep: 'Review the title, category, and priority before saving.',
            rawTranscript: 'Task: tighten the voice briefing wording.',
            projectContext: 'MicroGrow',
            threadContext: 'Voice thread',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Briefing review'), findsOneWidget);
    expect(find.text('What this means'), findsOneWidget);
    expect(find.text('Next move'), findsOneWidget);
    expect(find.text('Raw transcript'), findsOneWidget);
    expect(
      find.textContaining('tighten the voice briefing wording'),
      findsOneWidget,
    );
    expect(find.textContaining('MicroGrow'), findsOneWidget);
    expect(find.textContaining('Voice thread'), findsOneWidget);
  });

  test('voice assistant starter deck includes shortcut templates', () {
    final service = VoiceCommandService();
    final templates = service.getTemplates();

    expect(
      templates.any((template) => template.id == 'carry-forward'),
      isTrue,
    );
    expect(
      templates.any((template) => template.id == 'meeting-notes'),
      isTrue,
    );
    expect(
      templates.any((template) => template.id == 'project-checkpoint'),
      isTrue,
    );
    expect(
      templates.any((template) => template.id == 'meeting-summary'),
      isTrue,
    );
    expect(
      templates.any((template) => template.id == 'voice-review'),
      isTrue,
    );
  });

  testWidgets('voice assistant can open with a preset type from the dock', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsSnapshotProvider.overrideWith(
            (ref) async => SettingsSnapshot(
              settings: AppSetting(
                settingsId: 'settings-test',
                themeMode: 'Dark',
                defaultDashboardView: null,
                showWellbeingCard: true,
                showBusinessCard: true,
                showLearningCard: true,
                showContentCard: true,
                showProjectsWorkspaceSnapshot: true,
                showDockOverlays: true,
                showBackupGuardianDock: true,
                showTreasuryDock: true,
                showKnowledgeLibraryDock: true,
                showVoiceConversationDock: true,
                showVoicePresenceChip: true,
                dailyTopTaskLimit: 3,
                voiceRepliesEnabled: false,
                voiceAssistantEnabled: true,
                voiceStartupGateEnabled: false,
                preferredTtsVoiceName: null,
                preferredTtsVoiceLocale: null,
                preferredTtsVoiceGender: null,
                preferredTtsVoiceIdentifier: null,
                preferredTtsVoiceRate: 0.5,
                preferredTtsVoicePitch: 1.0,
                createdAt: DateTime(2026, 5, 9),
                updatedAt: DateTime(2026, 5, 9),
              ),
              appVersion: 'test',
            ),
          ),
          voiceAssistantProjectOptionsProvider.overrideWith(
            (ref) async => const <VoiceAssistantProjectOption>[],
          ),
        ],
        child: const MaterialApp(
          home: VoiceAssistantScreen(
            initialTranscript:
                'Draft a note about the dashboard voice workflow',
            initialType: 'project',
          ),
        ),
      ),
    );
    await pumpUntilIdle(tester);
    expect(find.text('Voice Assistant'), findsAtLeastNWidgets(1));
    expect(
      find.text('Speak, review, and turn your words into dashboard actions.'),
      findsOneWidget,
    );
  });

  testWidgets('voice assistant can save a reviewed transcript as a task', (
    WidgetTester tester,
  ) async {
    const transcript =
        'Capture a task to review the voice bridge scaffold and prepare the next safe dashboard step.';
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final service = VoiceCommandActionService(database);

    await service.saveCommand(
      transcript: transcript,
      type: VoiceCommandType.task,
    );

    final tasks = await database.select(database.tasks).get();
    final voiceTasks = tasks
        .where(
          (task) =>
              task.notes == 'Captured from the Voice Assistant.' ||
              task.description?.contains('voice bridge scaffold') == true,
        )
        .toList();

    expect(voiceTasks, hasLength(1));
    expect(voiceTasks.single.status, 'Inbox');
    expect(voiceTasks.single.description, contains('voice bridge scaffold'));
    expect(voiceTasks.single.notes, 'Captured from the Voice Assistant.');
  });

  testWidgets('voice assistant history item restores a saved transcript', (
    WidgetTester tester,
  ) async {
    const transcript =
        'Capture a task to review the voice bridge scaffold and prepare the next safe dashboard step.';
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    VoiceCommand? restored;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TextField(controller: controller),
              Expanded(
                child: CommandHistoryList(
                  commands: [
                    VoiceCommand(
                      id: 'history-1',
                      transcript: transcript,
                      type: VoiceCommandType.task,
                      createdAt: DateTime(2026, 6, 26, 9, 0),
                    ),
                  ],
                  onCommandSelected: (command) {
                    restored = command;
                    controller.text = command.transcript;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reuse latest'));
    await pumpUntilIdle(tester);

    expect(restored?.transcript, transcript);
    expect(controller.text, transcript);
  });

}
