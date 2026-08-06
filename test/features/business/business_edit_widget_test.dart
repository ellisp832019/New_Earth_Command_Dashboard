import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/settings/application/settings_controller.dart';
import 'package:new_earth_command_dashboard/features/settings/data/settings_repository.dart';
import 'package:new_earth_command_dashboard/features/business/data/business_repository.dart';
import 'package:new_earth_command_dashboard/features/business/presentation/add_business_opportunity_screen.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';

Widget buildDatabaseBackedTestApp(
  AppDatabase database, {
  required String initialLocation,
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/business',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Business'))),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => AddBusinessOpportunityScreen(
              projectId: state.uri.queryParameters['projectId'],
            ),
          ),
          GoRoute(
            path: ':businessId/edit',
            builder: (context, state) => AddBusinessOpportunityScreen(
              businessId: state.pathParameters['businessId']!,
            ),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWith((ref) => database),
      databaseReadyProvider.overrideWith((ref) async {}),
      settingsSnapshotProvider.overrideWith((ref) async => _testSettings()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
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

SettingsSnapshot _testSettings() {
  return SettingsSnapshot(
    settings: AppSetting(
      settingsId: 'settings-test',
      themeMode: 'Dark',
      defaultDashboardView: 'Dashboard',
      showWellbeingCard: true,
      showBusinessCard: true,
      showLearningCard: true,
      showContentCard: true,
      showProjectsWorkspaceSnapshot: true,
      showDockOverlays: false,
      showBackupGuardianDock: false,
      showTreasuryDock: false,
      showKnowledgeLibraryDock: false,
      showVoiceConversationDock: false,
      showVoicePresenceChip: false,
      showGaiaEmployeeSurface: false,
      dailyTopTaskLimit: 3,
      voiceRepliesEnabled: false,
      voiceAssistantEnabled: false,
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
  );
}

void main() {
  testWidgets('business item opens edit screen, saves changes', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final projectRepository = ProjectRepository(database);
    final businessRepository = BusinessRepository(database);

    final project = await projectRepository.createProject(
      name: 'Edit Project',
      status: 'Active',
      priority: 'High',
      progressPercentage: 1,
    );

    final created = await businessRepository.createItem(
      name: 'Original Opportunity',
      projectId: project.projectId,
      type: 'Job',
      status: 'Researching',
      companyOrContact: 'Original Co',
      nextAction: 'Do initial',
    );

    await tester.pumpWidget(
      buildDatabaseBackedTestApp(
        database,
        initialLocation: '/business/${created.businessOpportunityId}/edit',
      ),
    );
    await pumpUntilIdle(tester);
    await pumpUntilFound(tester, find.text('Edit Opportunity'));

    // Should be on edit screen with prefilled name and save button
    expect(find.text('Edit Opportunity'), findsOneWidget);
    expect(find.byKey(const Key('businessNameField')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('businessNameField')),
      'Updated Opportunity',
    );

    // Save
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveBusinessButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilIdle(tester);
    await tester.tap(find.byKey(const Key('saveBusinessButton')));
    await pumpUntilFound(tester, find.text('Business'));

    // Save returned to the business route and the repository reflects the edit.
    expect(find.text('Business'), findsOneWidget);

    final items = await businessRepository.getItems();
    expect(items.length, 1);
    expect(items.first.item.name, 'Updated Opportunity');
  });

  testWidgets('business edit screen tolerates legacy dropdown values', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final projectRepository = ProjectRepository(database);
    final businessRepository = BusinessRepository(database);

    final project = await projectRepository.createProject(
      name: 'Legacy Project',
      status: 'Active',
      priority: 'Low',
      progressPercentage: 1,
    );

    final created = await businessRepository.createItem(
      name: 'Legacy Opportunity',
      projectId: project.projectId,
      type: 'Other',
      status: 'Won',
      companyOrContact: 'Sahil Kumar',
      nextAction: 'Follow up',
    );

    await tester.pumpWidget(
      buildDatabaseBackedTestApp(
        database,
        initialLocation: '/business/${created.businessOpportunityId}/edit',
      ),
    );
    await pumpUntilIdle(tester);
    await pumpUntilFound(tester, find.text('Edit Opportunity'));

    expect(find.text('Edit Opportunity'), findsOneWidget);
    expect(find.byKey(const Key('businessNameField')), findsOneWidget);
    expect(find.byKey(const Key('businessTypeField')), findsOneWidget);
    expect(find.byKey(const Key('businessStatusField')), findsOneWidget);
  });

  testWidgets(
    'new business opportunity can be created and appears in the list',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final projectRepository = ProjectRepository(database);
      final businessRepository = BusinessRepository(database);

      final project = await projectRepository.createProject(
        name: 'New Opportunity Project',
        status: 'Active',
        priority: 'Medium',
        progressPercentage: 1,
      );

      await tester.pumpWidget(
        buildDatabaseBackedTestApp(database, initialLocation: '/business/new'),
      );
      await pumpUntilIdle(tester);
      await pumpUntilFound(tester, find.text('Add Opportunity'));

      expect(find.text('Add Opportunity'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('businessNameField')),
        'New Opportunity',
      );

      await tester.tap(find.byKey(const Key('businessProjectField')));
      await pumpUntilIdle(tester);
      await tester.tap(find.text(project.name).last);
      await pumpUntilIdle(tester);

      await tester.tap(find.byKey(const Key('businessTypeField')));
      await pumpUntilIdle(tester);
      await tester.tap(find.text('Job').last);
      await pumpUntilIdle(tester);

      await tester.scrollUntilVisible(
        find.byKey(const Key('saveBusinessButton')),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(find.byKey(const Key('saveBusinessButton')));
      await pumpUntilFound(tester, find.text('Business'));

      expect(find.text('Business'), findsOneWidget);

      final items = await businessRepository.getItems();
      expect(items.any((item) => item.item.name == 'New Opportunity'), isTrue);
    },
  );
}
