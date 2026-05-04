import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/business/data/business_repository.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';
import 'package:new_earth_command_dashboard/core/services/seed_data_service.dart';
import 'package:new_earth_command_dashboard/core/routing/app_router.dart';

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

    appRouter.go('/business');
    await tester.pumpAndSettle();

    // Open the business item card
    final cardKey = Key('businessItemCard-${created.businessOpportunityId}');
    expect(find.byKey(cardKey), findsOneWidget);
    await tester.tap(find.byKey(cardKey));
    await tester.pumpAndSettle();

    // Should be on edit screen with prefilled name
    expect(find.text('Edit Opportunity'), findsOneWidget);
    expect(find.byKey(const Key('businessNameField')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('businessNameField')), 'Updated Opportunity');

    // Save
    await tester.scrollUntilVisible(find.byKey(const Key('saveBusinessButton')), 200);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveBusinessButton')));
    await tester.pumpAndSettle();

    // Back on list and updated name is visible
    expect(find.text('Updated Opportunity'), findsOneWidget);

    final items = await businessRepository.getItems();
    expect(items.length, 1);
    expect(items.first.item.name, 'Updated Opportunity');
  });
}
