import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_earth_command_dashboard/app.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/business/data/business_repository.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';
import 'package:new_earth_command_dashboard/features/settings/application/settings_controller.dart';
import 'package:new_earth_command_dashboard/features/settings/data/settings_repository.dart';
import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
// seed data service not required here
import 'package:new_earth_command_dashboard/core/routing/app_router.dart';

Widget buildDatabaseBackedTestApp(AppDatabase database) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWith((ref) => database),
      databaseReadyProvider.overrideWith((ref) async {}),
      settingsSnapshotProvider.overrideWith((ref) async => _testSettings()),
    ],
    child: const NewEarthCommandDashboardApp(),
  );
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
      dailyTopTaskLimit: 3,
      voiceRepliesEnabled: false,
      voiceAssistantEnabled: false,
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

    appRouter.go(RouteNames.editBusiness(created.businessOpportunityId));
    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveBusinessButton')));
    await tester.pumpAndSettle();

    // Back on list and updated name is visible
    expect(find.text('Updated Opportunity'), findsOneWidget);

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

    appRouter.go(RouteNames.editBusiness(created.businessOpportunityId));
    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

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

      appRouter.go(RouteNames.newBusiness);
      await tester.pumpWidget(buildDatabaseBackedTestApp(database));
      await tester.pumpAndSettle();

      expect(find.text('Add Opportunity'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('businessNameField')),
        'New Opportunity',
      );

      await tester.tap(find.byKey(const Key('businessProjectField')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(project.name).last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('businessTypeField')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Job').last);
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('saveBusinessButton')),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(find.byKey(const Key('saveBusinessButton')));
      await tester.pumpAndSettle();

      expect(find.text('Business'), findsWidgets);
      expect(find.text('New Opportunity'), findsOneWidget);

      final items = await businessRepository.getItems();
      expect(items.any((item) => item.item.name == 'New Opportunity'), isTrue);
    },
  );
}
