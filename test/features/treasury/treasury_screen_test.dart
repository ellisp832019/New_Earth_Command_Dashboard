import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/more/presentation/more_screen.dart';
import 'package:new_earth_command_dashboard/features/treasury/application/treasury_controller.dart';
import 'package:new_earth_command_dashboard/features/treasury/data/treasury_folder_service.dart';
import 'package:new_earth_command_dashboard/features/treasury/presentation/treasury_screen.dart';
import 'package:new_earth_command_dashboard/features/treasury/presentation/treasury_settings_screen.dart';

void main() {
  TreasuryWorkspaceSnapshot buildWorkspace() {
    return TreasuryWorkspaceSnapshot(
      configPath: 'config/local_paths.json',
      financeRootPath: 'D:/NEW_EARTH_OMEGA_OS_PACK/17_FINANCE_AND_TREASURY',
      isReady: true,
      issues: const <String>[],
      requiredFolders: TreasuryFolderService.requiredFolders,
      missingFolders: const <String>[],
      missingFiles: const <String>[],
      stateSummaries: [
        TreasuryStateSummary(
          kind: TreasuryStatusKind.safe,
          title: 'Safe',
          count: 4,
          items: const <String>['Rent covered'],
          subtitle: 'Enough is settled to keep moving.',
        ),
        TreasuryStateSummary(
          kind: TreasuryStatusKind.watch,
          title: 'Watch',
          count: 2,
          items: const <String>['Utilities due next week'],
          subtitle: 'Worth another look soon.',
        ),
        TreasuryStateSummary(
          kind: TreasuryStatusKind.pause,
          title: 'Pause',
          count: 1,
          items: const <String>['Hold new purchases'],
          subtitle: 'Keep things still for now.',
        ),
        TreasuryStateSummary(
          kind: TreasuryStatusKind.decision,
          title: 'Decision',
          count: 1,
          items: const <String>['Approve project budget'],
          subtitle: 'One choice is waiting.',
        ),
        TreasuryStateSummary(
          kind: TreasuryStatusKind.future,
          title: 'Future',
          count: 0,
          items: const <String>[],
          subtitle: 'Parking lot for later.',
        ),
        TreasuryStateSummary(
          kind: TreasuryStatusKind.archived,
          title: 'Archived',
          count: 0,
          items: const <String>[],
          subtitle: 'Reference only.',
        ),
      ],
      receiptsToSortCount: 3,
      weeklyRitualSteps: TreasuryFolderService.weeklyRitualSteps,
      lowEnergySteps: TreasuryFolderService.lowEnergySteps,
      guidanceNote: 'Connected.',
    );
  }

  testWidgets('treasury home shows a back button to More', (tester) async {
    final workspace = buildWorkspace();
    final router = GoRouter(
      initialLocation: RouteNames.treasury,
      routes: [
        GoRoute(
          path: RouteNames.more,
          builder: (context, state) => const MoreScreen(),
        ),
        GoRoute(
          path: RouteNames.treasury,
          builder: (context, state) => const TreasuryScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          treasuryWorkspaceProvider.overrideWith((ref) async => workspace),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Module Hub'), findsNothing);
    expect(find.text('Back to More'), findsWidgets);
    expect(find.text('Weekly Pack PDF'), findsOneWidget);

    await tester.tap(find.text('Back to More').first);
    await tester.pumpAndSettle();

    expect(find.text('More'), findsOneWidget);
    expect(find.text('Supporting modules'), findsOneWidget);
  });

  testWidgets(
    'treasury setup routes missing link users to folder link settings',
    (tester) async {
      final workspace = TreasuryWorkspaceSnapshot(
        configPath: 'config/local_paths.json',
        financeRootPath: null,
        isReady: false,
        issues: const <String>[
          'finance_treasury_path is missing from config/local_paths.json.',
        ],
        requiredFolders: TreasuryFolderService.requiredFolders,
        missingFolders: const <String>['00_FINANCE_DASHBOARD'],
        missingFiles: const <String>[
          '00_FINANCE_DASHBOARD/dashboard_state.json',
        ],
        stateSummaries: const <TreasuryStateSummary>[],
        receiptsToSortCount: 0,
        weeklyRitualSteps: TreasuryFolderService.weeklyRitualSteps,
        lowEnergySteps: TreasuryFolderService.lowEnergySteps,
        guidanceNote: 'Waiting for a saved folder path.',
      );

      final router = GoRouter(
        initialLocation: RouteNames.treasury,
        routes: [
          GoRoute(
            path: RouteNames.treasury,
            builder: (context, state) => const TreasuryScreen(),
          ),
          GoRoute(
            path: RouteNames.treasurySettings,
            builder: (context, state) => const TreasurySettingsScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            treasuryWorkspaceProvider.overrideWith((ref) async => workspace),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.scrollUntilVisible(
        find.text('Open folder link settings', skipOffstage: false),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(
        find.text('Open folder link settings', skipOffstage: false),
        findsOneWidget,
      );

      await tester.tap(
        find.text('Open folder link settings', skipOffstage: false),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Treasury settings', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('Setup state', skipOffstage: false), findsOneWidget);
    },
  );

  testWidgets('treasury setup opens a guided wizard when a link exists', (
    tester,
  ) async {
    final workspace = TreasuryWorkspaceSnapshot(
      configPath: 'config/local_paths.json',
      financeRootPath: 'D:/NEW_EARTH_OMEGA_OS_PACK/17_FINANCE_AND_TREASURY',
      isReady: false,
      issues: const <String>['Missing starter files.'],
      requiredFolders: TreasuryFolderService.requiredFolders,
      missingFolders: const <String>['00_FINANCE_DASHBOARD'],
      missingFiles: const <String>[
        '00_FINANCE_DASHBOARD/dashboard_state.json',
        '04_PROJECT_SPEND_TRACKERS/project_spend_tracker.csv',
      ],
      stateSummaries: const <TreasuryStateSummary>[],
      receiptsToSortCount: 0,
      weeklyRitualSteps: TreasuryFolderService.weeklyRitualSteps,
      lowEnergySteps: TreasuryFolderService.lowEnergySteps,
      guidanceNote: 'Waiting for repair.',
    );

    final router = GoRouter(
      initialLocation: RouteNames.treasury,
      routes: [
        GoRoute(
          path: RouteNames.treasury,
          builder: (context, state) => const TreasuryScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          treasuryWorkspaceProvider.overrideWith((ref) async => workspace),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.scrollUntilVisible(
      find.text('Open setup wizard', skipOffstage: false),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    await tester.tap(find.text('Open setup wizard', skipOffstage: false));
    await tester.pumpAndSettle();

    expect(find.text('Treasury setup wizard'), findsOneWidget);
    expect(find.text('Step 1 of 3'), findsOneWidget);
    expect(find.text('Review the folder link'), findsOneWidget);
  });
}
