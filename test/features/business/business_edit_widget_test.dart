import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_earth_command_dashboard/app.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/business/data/business_repository.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';
import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
// seed data service not required here
import 'package:new_earth_command_dashboard/core/routing/app_router.dart';

Widget buildDatabaseBackedTestApp(AppDatabase database) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWith((ref) => database)],
    child: const NewEarthCommandDashboardApp(),
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

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go(RouteNames.editBusiness(created.businessOpportunityId));
    await tester.pumpAndSettle();

    // Should be on edit screen with prefilled name and save button
    expect(find.text('Edit Opportunity'), findsOneWidget);
    expect(find.byKey(const Key('businessNameField')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('businessNameField')), 'Updated Opportunity');

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

  testWidgets('new business opportunity can be created and appears in the list', (tester) async {
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

    await tester.pumpWidget(buildDatabaseBackedTestApp(database));
    await tester.pumpAndSettle();

    appRouter.go(RouteNames.newBusiness);
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
  });
}
