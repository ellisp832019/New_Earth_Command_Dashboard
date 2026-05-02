import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/app.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';

void main() {
  Widget buildTestApp() {
    return ProviderScope(
      overrides: [databaseReadyProvider.overrideWith((ref) async {})],
      child: const NewEarthCommandDashboardApp(),
    );
  }

  testWidgets('app shell opens to dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('New Earth Command Dashboard'), findsOneWidget);
    expect(find.text('Today\'s Focus'), findsOneWidget);
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

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    expect(find.text('Journal'), findsOneWidget);
    expect(find.text('Learning'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
    expect(find.text('Business'), findsOneWidget);

    await tester.drag(find.byType(Scrollable), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Wellbeing'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
