import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/app.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/core/routing/app_router.dart';
import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/business/data/business_repository.dart';
import 'package:new_earth_command_dashboard/features/content/data/content_repository.dart';
import 'package:new_earth_command_dashboard/features/dashboard/application/dashboard_controller.dart';
import 'package:new_earth_command_dashboard/features/dashboard/data/dashboard_repository.dart';
import 'package:new_earth_command_dashboard/features/inbox/data/inbox_repository.dart';
import 'package:new_earth_command_dashboard/features/journal/data/journal_repository.dart';
import 'package:new_earth_command_dashboard/features/learning/data/learning_repository.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';
import 'package:new_earth_command_dashboard/features/security/application/security_session_controller.dart';
import 'package:new_earth_command_dashboard/features/settings/application/settings_controller.dart';
import 'package:new_earth_command_dashboard/features/settings/data/settings_repository.dart';
import 'package:new_earth_command_dashboard/features/tasks/data/task_repository.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/application/voice_startup_gate_controller.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_startup_gate_service.dart';
import 'package:new_earth_command_dashboard/features/wellbeing/data/wellbeing_repository.dart';

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
      activeDeviceLabel: 'TEST_DEVICE',
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

Future<Project> createMicroGrowProject(AppDatabase database) {
  return ProjectRepository(database).createProject(
    name: 'MicroGrow',
    shortDescription: 'Test harness project',
    status: 'Active',
    priority: 'High',
    currentMilestone: 'Stabilise diagnostics',
    nextAction: 'Keep the next useful step visible.',
  );
}

Widget buildDatabaseBackedTestApp(AppDatabase database, {Widget? child}) {
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
          hasEveningReview: false,
          nextStepTitle: 'Next useful move',
          nextStepSummary:
              'Continue MicroGrow with Review the next useful diagnostics step.',
          nextStepReason:
              'It uses the strongest project context available right now.',
          nextStepActionType: DashboardNextStepActionType.projectDetail,
          nextStepActionLabel: 'Open Project',
          nextStepProjectId: 'project-microgrow',
          mainFocus: null,
          focusReason: null,
          morningIntention: null,
        );
      }),
    ],
    child: child ?? const NewEarthCommandDashboardApp(),
  );
}

void main() {
  setUp(() {
    appRouter.go(RouteNames.dashboard);
  });

  testWidgets('journal screen shows a calm empty state', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await pumpUntilIdle(tester);

    appRouter.go('/journal');
    await pumpUntilIdle(tester);

    expect(find.text('Journal'), findsAtLeastNWidgets(1));
    expect(
      find.text(
        'No journal entries yet. Capture today\'s progress when you are ready.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('journal screen can create a linked entry', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final microGrow = await createMicroGrowProject(database);
    final taskRepository = TaskRepository(database);
    await taskRepository.createTask(
      title: 'MicroGrow journal task',
      projectId: microGrow.projectId,
      status: 'Today',
    );

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await pumpUntilIdle(tester);

    appRouter.go('/journal/new');
    await pumpUntilIdle(tester);

    await tester.enterText(
      find.byKey(const Key('journalTitleField')),
      'Daily build reflection',
    );
    await tester.tap(find.byKey(const Key('journalProjectField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('MicroGrow').last);
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('journalTaskField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('MicroGrow journal task').last);
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('journalCategoryField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('Build Log').last);
    await pumpUntilIdle(tester);
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
    await pumpUntilIdle(tester);
    await tester.enterText(
      find.byKey(const Key('journalNextActionsField')),
      'Add edit support in a later slice.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveJournalButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('saveJournalButton')));
    await pumpUntilIdle(tester);

    await tester.scrollUntilVisible(
      find.text('Journal overview'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);

    expect(find.text('Journal overview'), findsOneWidget);
    expect(find.text('Capture what moved today'), findsOneWidget);
    expect(find.text('Link to project or task'), findsOneWidget);
    expect(find.text('Journal'), findsAtLeastNWidgets(1));
    expect(find.text('Daily build reflection'), findsOneWidget);
    expect(find.text('MicroGrow'), findsOneWidget);
    expect(find.text('Build Log'), findsOneWidget);

    final entries = await JournalRepository(database).getEntries();
    expect(entries, hasLength(1));
    expect(entries.first.entry.title, 'Daily build reflection');
    expect(entries.first.projectName, 'MicroGrow');
    expect(entries.first.taskTitle, 'MicroGrow journal task');

    appRouter.go(RouteNames.dashboard);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('learning screen shows a calm empty state', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await pumpUntilIdle(tester);

    appRouter.go('/learning');
    await pumpUntilIdle(tester);

    expect(find.text('Learning'), findsAtLeastNWidgets(1));
    expect(
      find.text('No learning items yet. Add a skill when it feels useful.'),
      findsOneWidget,
    );
  });

  testWidgets('learning screen can create a linked learning item', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await createMicroGrowProject(database);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await pumpUntilIdle(tester);

    appRouter.go('/learning');
    await pumpUntilIdle(tester);
    appRouter.go(RouteNames.newLearning);
    await pumpUntilIdle(tester);
    final formScrollable = find
        .byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        )
        .last;

    await tester.enterText(
      find.byKey(const Key('learningTopicField')),
      'Flutter Drift Database',
    );
    await tester.tap(find.byKey(const Key('learningProjectField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('MicroGrow').last);
    await pumpUntilIdle(tester);
    await tester.enterText(
      find.byKey(const Key('learningReasonField')),
      'The dashboard needs calm and reliable local data.',
    );
    await tester.enterText(
      find.byKey(const Key('learningResourceLinkField')),
      'https://drift.simonbinder.eu',
    );
    await tester.tap(find.byKey(const Key('learningStatusField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('Learning').last);
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('learningConfidenceField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('Medium').last);
    await pumpUntilIdle(tester);
    await tester.enterText(
      find.byKey(const Key('learningNotesField')),
      'Start with the repository and list flow.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('learningNextStepField')),
      200,
      scrollable: formScrollable,
    );
    await pumpUntilIdle(tester);
    await tester.enterText(
      find.byKey(const Key('learningNextStepField')),
      'Wire the screen to local data.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveLearningButton')),
      200,
      scrollable: formScrollable,
    );
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('saveLearningButton')));
    await pumpUntilIdle(tester);

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
    await pumpUntilIdle(tester);

    appRouter.go('/learning');
    await pumpUntilIdle(tester);

    await tester.tap(
      find.byKey(Key('learningItemCard-${createdItem.learningItemId}')),
    );
    await pumpUntilIdle(tester);

    expect(find.text('Edit Learning Topic'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('learningTopicField')),
      'Edited learning topic',
    );
    await tester.tap(find.byKey(const Key('learningStatusField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('Applied').last);
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('learningConfidenceField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('High').last);
    await pumpUntilIdle(tester);
    await tester.enterText(
      find.byKey(const Key('learningReasonField')),
      'This now supports a real feature slice.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('learningNextStepField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);
    await tester.enterText(
      find.byKey(const Key('learningNextStepField')),
      'Reuse the edit pattern elsewhere.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveLearningButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('saveLearningButton')));
    await pumpUntilIdle(tester);

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
    await pumpUntilIdle(tester);

    appRouter.go('/content');
    await pumpUntilIdle(tester);

    expect(find.text('Content'), findsAtLeastNWidgets(1));
    expect(
      find.text('No content yet. Turn a build update into a gentle post idea.'),
      findsOneWidget,
    );
  });

  testWidgets('content screen can create a linked content item', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await createMicroGrowProject(database);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await pumpUntilIdle(tester);

    appRouter.go('/content');
    await pumpUntilIdle(tester);
    appRouter.go(RouteNames.newContent);
    await pumpUntilIdle(tester);

    await tester.enterText(
      find.byKey(const Key('contentTitleField')),
      'Building the New Earth Command Dashboard',
    );
    await tester.tap(find.byKey(const Key('contentProjectField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('MicroGrow').last);
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('contentPlatformField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('LinkedIn').last);
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('contentTypeField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('Project Update').last);
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('contentStatusField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('Drafting').last);
    await pumpUntilIdle(tester);
    await tester.enterText(
      find.byKey(const Key('contentDraftTextField')),
      'A grounded build-in-public update for the dashboard.',
    );
    await tester.tap(find.byKey(const Key('contentImageNeededField')));
    await pumpUntilIdle(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('contentImagePromptField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);
    await tester.enterText(
      find.byKey(const Key('contentImagePromptField')),
      'A glowing command dashboard on a night desk.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('contentNotesField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);
    await tester.enterText(
      find.byKey(const Key('contentNotesField')),
      'Keep the first public update practical.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveContentButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('saveContentButton')));
    await pumpUntilIdle(tester);

    expect(find.text('Content'), findsAtLeastNWidgets(1));
    expect(find.text('Content overview'), findsOneWidget);
    expect(find.text('Capture one post idea'), findsOneWidget);
    expect(find.text('Note if an image will help'), findsOneWidget);
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
    await pumpUntilIdle(tester);

    appRouter.go('/content');
    await pumpUntilIdle(tester);

    await tester.tap(
      find.byKey(Key('contentItemCard-${createdItem.contentItemId}')),
    );
    await pumpUntilIdle(tester);

    expect(find.text('Edit Content Idea'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('contentTitleField')),
      'Edited content idea',
    );
    await tester.tap(find.byKey(const Key('contentPlatformField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('Website').last);
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('contentTypeField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('Technical Update').last);
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('contentStatusField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('Ready').last);
    await pumpUntilIdle(tester);
    await tester.enterText(
      find.byKey(const Key('contentDraftTextField')),
      'Edited draft text for the next publishing step.',
    );
    await tester.tap(find.byKey(const Key('contentImageNeededField')));
    await pumpUntilIdle(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('contentImagePromptField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);
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
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('saveContentButton')));
    await pumpUntilIdle(tester);

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
    await pumpUntilIdle(tester);

    appRouter.go('/business');
    await pumpUntilIdle(tester);

    expect(find.text('Business'), findsAtLeastNWidgets(1));
    expect(
      find.text('No business items yet. Capture a lead when it feels useful.'),
      findsOneWidget,
    );
  });

  testWidgets('business screen can create a linked opportunity', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await createMicroGrowProject(database);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await pumpUntilIdle(tester);

    appRouter.go('/business');
    await pumpUntilIdle(tester);
    appRouter.go(RouteNames.newBusiness);
    await pumpUntilIdle(tester);

    await tester.enterText(
      find.byKey(const Key('businessNameField')),
      'AI Architect Role',
    );
    await tester.tap(find.byKey(const Key('businessProjectField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('MicroGrow').last);
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('businessTypeField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('Job').last);
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('businessStatusField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('Preparing').last);
    await pumpUntilIdle(tester);
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
    await pumpUntilIdle(tester);
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
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('saveBusinessButton')));
    await pumpUntilIdle(tester);

    expect(find.text('Business'), findsAtLeastNWidgets(1));
    expect(find.text('Business overview'), findsOneWidget);
    expect(find.text('Capture one lead'), findsOneWidget);
    expect(find.text('Keep the next action visible'), findsOneWidget);
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
    await pumpUntilIdle(tester);

    appRouter.go('/wellbeing');
    await pumpUntilIdle(tester);

    expect(find.text('Wellbeing'), findsAtLeastNWidgets(1));
    expect(
      find.text(
        'No wellbeing entries yet. Add a calm check-in when you need one.',
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
    await pumpUntilIdle(tester);

    appRouter.go('/wellbeing');
    await pumpUntilIdle(tester);
    appRouter.go(RouteNames.newWellbeing);
    await pumpUntilIdle(tester);

    await tester.tap(find.byKey(const Key('wellbeingEnergyField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('Low').last);
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('wellbeingMoodField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('Tired').last);
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('wellbeingSleepQualityField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('Medium').last);
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('wellbeingStressField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('High').last);
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('wellbeingMovementField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('wellbeingFoodWaterField')));
    await pumpUntilIdle(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('wellbeingReflectionField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('wellbeingReflectionField')));
    await pumpUntilIdle(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('wellbeingNotesField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);
    await tester.enterText(
      find.byKey(const Key('wellbeingNotesField')),
      'Keep the day lighter and avoid unnecessary context switching.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveWellbeingButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('saveWellbeingButton')));
    await pumpUntilIdle(tester);

    expect(find.text('Wellbeing'), findsAtLeastNWidgets(1));
    expect(find.text('Wellbeing overview'), findsOneWidget);
    expect(find.text('Check in honestly'), findsOneWidget);
    expect(find.text('Keep the day sustainable'), findsOneWidget);
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
    await pumpUntilIdle(tester);

    appRouter.go('/inbox');
    await pumpUntilIdle(tester);

    expect(find.text('Inbox'), findsAtLeastNWidgets(1));
    expect(
      find.text(
        'Nothing needs triage yet. Capture a thought here, then review it when you are ready.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('inbox screen can create a linked item', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await createMicroGrowProject(database);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await pumpUntilIdle(tester);

    appRouter.go('/inbox');
    await pumpUntilIdle(tester);
    appRouter.go(RouteNames.newInbox);
    await pumpUntilIdle(tester);

    await tester.enterText(
      find.byKey(const Key('inboxTitleField')),
      'Check Flutter navigation package',
    );
    await tester.enterText(
      find.byKey(const Key('inboxBodyField')),
      'Might help the next polish pass.',
    );
    await tester.tap(find.byKey(const Key('inboxTypeField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('Learning Note').last);
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('inboxProjectField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('MicroGrow').last);
    await pumpUntilIdle(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('inboxStatusField')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('inboxStatusField')));
    await pumpUntilIdle(tester);
    await tester.tap(find.text('New').last);
    await pumpUntilIdle(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveInboxButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('saveInboxButton')));
    await pumpUntilIdle(tester);

    expect(find.text('Inbox'), findsAtLeastNWidgets(1));
    expect(find.text('Inbox triage'), findsOneWidget);
    expect(
      find.text('Check Flutter navigation package'),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('Learning Note'), findsOneWidget);
    expect(find.text('MicroGrow'), findsOneWidget);
    expect(find.text('Status: New'), findsOneWidget);
    expect(find.text('Park to keep for later'), findsOneWidget);

    final items = await InboxRepository(database).getItems();
    expect(items, hasLength(1));
    expect(items.first.item.title, 'Check Flutter navigation package');
    expect(items.first.projectName, 'MicroGrow');
  });

  testWidgets('inbox screen filters parked items and opens the review sheet', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final project = await createMicroGrowProject(database);
    final inboxRepository = InboxRepository(database);

    await inboxRepository.createItem(
      title: 'Fresh capture',
      body: 'Keep this in the new queue.',
      type: 'Idea',
      projectId: project.projectId,
      status: 'New',
    );
    final parkedItem = await inboxRepository.createItem(
      title: 'Parked capture',
      body: 'Review this later when the day is calmer.',
      type: 'Journal Note',
      projectId: project.projectId,
      status: 'Parked',
    );

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await pumpUntilIdle(tester);

    appRouter.go('/inbox');
    await pumpUntilIdle(tester);

    expect(find.text('All 2'), findsOneWidget);
    expect(find.text('New 1'), findsOneWidget);
    expect(find.text('Parked 1'), findsOneWidget);

    await tester.tap(find.text('Parked 1'));
    await pumpUntilIdle(tester);

    expect(find.text('Parked capture'), findsAtLeastNWidgets(1));
    expect(find.text('Fresh capture'), findsNothing);
    expect(
      find.text('Parked items stay here until you move them on'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(Key('reviewInboxItemButton-${parkedItem.inboxItemId}')),
    );
    await pumpUntilIdle(tester);

    expect(
      find.text('Choose the calmest next home for this capture.'),
      findsOneWidget,
    );
    expect(find.text('Convert to Task'), findsOneWidget);
    expect(find.text('Convert to Journal Entry'), findsOneWidget);
    expect(find.text('Other destinations'), findsOneWidget);
  });

  testWidgets('parked inbox item can return to the new queue', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final project = await createMicroGrowProject(database);
    final inboxRepository = InboxRepository(database);

    final parkedItem = await inboxRepository.createItem(
      title: 'Bring me back',
      body: 'This should rejoin the new queue.',
      type: 'Idea',
      projectId: project.projectId,
      status: 'Parked',
    );

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await pumpUntilIdle(tester);

    appRouter.go('/inbox');
    await pumpUntilIdle(tester);

    await tester.tap(find.text('Parked 1'));
    await pumpUntilIdle(tester);

    expect(find.text('Return to New Queue'), findsOneWidget);

    await tester.tap(
      find.byKey(Key('parkInboxItemButton-${parkedItem.inboxItemId}')),
    );
    await pumpUntilIdle(tester);

    expect(
      find.text(
        'Nothing is parked right now. If something is not for today, you can park it here for later review.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('New 1'));
    await pumpUntilIdle(tester);

    expect(find.text('Bring me back'), findsAtLeastNWidgets(1));
    expect(find.text('Status: New'), findsOneWidget);

    final refreshedItem = await inboxRepository.getById(parkedItem.inboxItemId);
    expect(refreshedItem.status, 'New');
  });

  testWidgets('dashboard quick capture saves a new inbox item', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    appRouter.go('/dashboard');
    await tester.pump();
    await tester.pump();

    await pumpUntilIdle(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('dashboardQuickCaptureButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(
      find.byKey(const Key('dashboardQuickCaptureButton')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('dashboardQuickCaptureButton')));
    await pumpUntilIdle(tester);

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
    await pumpUntilIdle(tester);
    await tester.tap(find.text('Idea').last);
    await tester.pump();
    await tester.tap(find.byKey(const Key('dashboardQuickCaptureSaveButton')));
    await pumpUntilIdle(tester);

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
    await pumpUntilIdle(tester);

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
    await pumpUntilIdle(tester);

    appRouter.go('/journal');
    await pumpUntilIdle(tester);

    await tester.tap(
      find.byKey(Key('journalEntryCard-${createdEntry.journalEntryId}')),
    );
    await pumpUntilIdle(tester);

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
    await pumpUntilIdle(tester);
    await tester.enterText(
      find.byKey(const Key('journalNextActionsField')),
      'Use the edit flow again later.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveJournalButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('saveJournalButton')));
    await pumpUntilIdle(tester);

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
