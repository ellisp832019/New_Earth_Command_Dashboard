import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/dashboard/data/dashboard_card_layout.dart';
import 'package:new_earth_command_dashboard/features/dashboard/presentation/dashboard_card_personalization.dart';

void main() {
  testWidgets('personalization copy explains cards and protected Daily Flow', (
    tester,
  ) async {
    await _pumpSheet(tester, DashboardCardLayout.defaults());

    expect(
      find.text(
        'Shows the next practical action that helps move work forward.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Shows key finance and treasury information.'),
      findsOneWidget,
    );
    expect(
      find.text('Provides quick access to core New Earth controls and status.'),
      findsOneWidget,
    );
    expect(
      find.text('Shows supporting tools and operational shortcuts.'),
      findsOneWidget,
    );
    expect(find.text('Presentation only'), findsNothing);
    expect(
      find.text(
        'Always visible - Today Focus, Top 3, projects, capture, and review.',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<Switch>(
            find.byKey(const Key('dashboardCardVisibility-daily_flow')),
          )
          .onChanged,
      isNull,
    );
    expect(find.text('Restore default layout'), findsOneWidget);
    expect(
      find.text(
        'Restores card order and visibility only. Your tasks, projects, and dashboard data stay unchanged.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('personalization surface scrolls safely in a small window', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpSheet(tester, DashboardCardLayout.defaults());

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(
      find.byKey(const Key('dashboardCardPersonalizationResetButton')),
      findsOneWidget,
    );
  });

  testWidgets(
    'reset restores order and visibility without changing other settings',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      const custom = DashboardCardLayout(
        orderedIds: [
          DashboardCardLayout.supportStackId,
          DashboardCardLayout.dailyFlowId,
          DashboardCardLayout.nextStepId,
          DashboardCardLayout.treasuryId,
          DashboardCardLayout.commandCentreId,
        ],
        hiddenIds: {DashboardCardLayout.treasuryId},
      );

      await _pumpSheet(tester, custom, database: database);
      await tester.ensureVisible(
        find.byKey(const Key('dashboardCardPersonalizationResetButton')),
      );
      await tester.tap(
        find.byKey(const Key('dashboardCardPersonalizationResetButton')),
      );
      await tester.pumpAndSettle();

      final layout = DashboardCardLayout.fromJson(
        (await database.select(database.appSettings).getSingle())
            .dashboardCardLayoutJson,
      );
      expect(layout.orderedIds, DashboardCardLayout.defaultOrder);
      expect(layout.hiddenIds, isEmpty);
      expect(
        find.byKey(const Key('dashboardCardMoveUp-daily_flow')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dashboardCardVisibility-treasury')),
        findsOneWidget,
      );
    },
  );
}

Future<void> _pumpSheet(
  WidgetTester tester,
  DashboardCardLayout layout, {
  AppDatabase? database,
}) async {
  final db = database ?? AppDatabase(NativeDatabase.memory());
  if (database == null) {
    addTearDown(db.close);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        databaseReadyProvider.overrideWith((ref) async {}),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: DashboardCardPersonalizationSheet(initialLayout: layout),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
