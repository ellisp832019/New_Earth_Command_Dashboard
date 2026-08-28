import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/features/dashboard/application/dashboard_controller.dart';
import 'package:new_earth_command_dashboard/features/dashboard/data/dashboard_card_layout.dart';
import 'package:new_earth_command_dashboard/features/dashboard/data/dashboard_repository.dart';
import 'package:new_earth_command_dashboard/features/dashboard/presentation/dashboard_screen.dart';
import 'package:new_earth_command_dashboard/features/treasury/application/treasury_controller.dart';
import 'package:new_earth_command_dashboard/features/treasury/data/treasury_folder_service.dart';

void main() {
  testWidgets(
    'unavailable Treasury snapshot shows unavailable metrics on a usable Dashboard',
    (tester) async {
      await _pumpDashboard(
        tester,
        loadTreasury: (ref) async =>
            throw StateError('Treasury dependency unavailable'),
      );

      expect(find.text('Choose one clear move for today'), findsOneWidget);
      expect(find.text('Setup needed'), findsOneWidget);
      expect(
        find.text('Receipts are unavailable until the folder is linked.'),
        findsOneWidget,
      );
      expect(
        find.textContaining('folder link needs attention first'),
        findsOneWidget,
      );
      expect(find.text('Unavailable'), findsNWidgets(4));
      expect(find.text('0'), findsNothing);
      expect(find.text('Ready'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('valid Treasury snapshot preserves genuine zero metrics', (
    tester,
  ) async {
    await _pumpDashboard(
      tester,
      loadTreasury: (ref) async => _zeroTreasurySnapshot(),
    );

    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Unavailable'), findsNothing);
    expect(find.text('0'), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required Future<TreasuryWorkspaceSnapshot> Function(Ref ref) loadTreasury,
}) async {
  tester.view.physicalSize = const Size(1440, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dashboardSnapshotProvider.overrideWith(
          (ref) async => _dashboardSnapshot(),
        ),
        treasuryWorkspaceProvider.overrideWith(loadTreasury),
      ],
      child: const MaterialApp(home: DashboardScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

DashboardSnapshot _dashboardSnapshot() => DashboardSnapshot(
  date: DateTime(2026, 8, 28),
  hasTodayPlan: false,
  activeProjectCount: 7,
  activeProjects: const [],
  topTasks: const [],
  topTaskTitles: const [],
  nextStepTitle: 'Choose one clear move',
  nextStepSummary: 'Dashboard remains available.',
  nextStepReason: 'Local Dashboard data is available.',
  nextStepActionType: DashboardNextStepActionType.planner,
  nextStepActionLabel: 'Open Planner',
  showWellbeingCard: false,
  showBusinessCard: false,
  showLearningCard: false,
  showContentCard: false,
  energyLabel: 'Not set',
  hasEveningReview: false,
  cardLayout: const DashboardCardLayout(
    orderedIds: [DashboardCardLayout.treasuryId],
    hiddenIds: <String>{},
  ),
);

TreasuryWorkspaceSnapshot _zeroTreasurySnapshot() =>
    const TreasuryWorkspaceSnapshot(
      configPath: 'config/local_paths.json',
      financeRootPath: 'D:/NEW_EARTH_OMEGA_OS_PACK/17_FINANCE_AND_TREASURY',
      isReady: true,
      issues: <String>[],
      requiredFolders: <String>[],
      missingFolders: <String>[],
      missingFiles: <String>[],
      stateSummaries: <TreasuryStateSummary>[],
      receiptsToSortCount: 0,
      weeklyRitualSteps: <String>[],
      lowEnergySteps: <String>[],
      guidanceNote: 'Ready.',
    );
