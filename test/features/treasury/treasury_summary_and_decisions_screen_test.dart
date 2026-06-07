import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/treasury/application/treasury_controller.dart';
import 'package:new_earth_command_dashboard/features/treasury/application/treasury_decisions_controller.dart';
import 'package:new_earth_command_dashboard/features/treasury/application/treasury_monthly_summary_controller.dart';
import 'package:new_earth_command_dashboard/features/treasury/data/treasury_folder_service.dart';
import 'package:new_earth_command_dashboard/features/treasury/presentation/treasury_decisions_board_screen.dart';
import 'package:new_earth_command_dashboard/features/treasury/presentation/treasury_monthly_summary_screen.dart';

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
          count: 6,
          items: <String>['Rent covered'],
          subtitle: 'Enough is settled to keep moving.',
        ),
        TreasuryStateSummary(
          kind: TreasuryStatusKind.watch,
          title: 'Watch',
          count: 2,
          items: <String>['Utilities due next week'],
          subtitle: 'Worth another look soon.',
        ),
        TreasuryStateSummary(
          kind: TreasuryStatusKind.pause,
          title: 'Pause',
          count: 1,
          items: <String>['Hold new purchases'],
          subtitle: 'Keep things still for now.',
        ),
        TreasuryStateSummary(
          kind: TreasuryStatusKind.decision,
          title: 'Decision',
          count: 1,
          items: <String>['Approve project budget'],
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
      weeklyRitualSteps: ['Review the board', 'Capture decisions'],
      lowEnergySteps: ['Open the summary', 'Park anything extra'],
      guidanceNote: 'Ready.',
    );
  }

  TreasuryMonthlySummarySnapshot buildSummary({
    required TreasuryWorkspaceSnapshot workspace,
  }) {
    return TreasuryMonthlySummarySnapshot(
      workspace: workspace,
      generatedAt: DateTime(2026, 5, 28),
      projectSpendTotal: 30,
      topProjectSpends: const [
        TreasuryMonthlyProjectSpendTotal(
          project: 'New Earth Dashboard',
          total: 30,
          entries: 2,
        ),
      ],
      subscriptionTotal: 12.99,
      upcomingSubscriptions: const <TreasuryMonthlySubscriptionEntry>[],
      recentProjectSpendEntries: const <TreasuryMonthlyProjectSpendEntry>[],
      recentDecisions: const [
        TreasuryDecisionRecord(
          date: '2026-05-28',
          decisionNeeded: 'Approve project budget',
          amount: '\u00A3120.00',
          status: 'Decision',
          decision: 'Approved with a small buffer',
          owner: 'Hayley',
          notes: 'Keep the next step calm and simple.',
        ),
      ],
      weeklyReviewDate: '2026-05-28',
      weeklyReviewNote: 'The picture is steady this month.',
      issues: const <String>[],
    );
  }

  testWidgets('treasury monthly summary surfaces a calm overview', (
    tester,
  ) async {
    final workspace = buildWorkspace();
    final summary = buildSummary(workspace: workspace);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          treasuryWorkspaceProvider.overrideWith(
            (ref) async => workspace,
          ),
          treasuryMonthlySummaryProvider.overrideWith(
            (ref) async => summary,
          ),
        ],
        child: const MaterialApp(home: TreasuryMonthlySummaryScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Monthly Summary'), findsWidgets);
    expect(find.textContaining('30.00'), findsWidgets);
    expect(find.textContaining('12.99'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Project spend', skipOffstage: false),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('Project spend'), findsWidgets);
    expect(find.text('Recurring costs'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Decisions register', skipOffstage: false),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('Decisions register'), findsOneWidget);
    expect(find.text('Approve project budget'), findsWidgets);
    expect(find.textContaining('120.00'), findsWidgets);
  });

  testWidgets('treasury decisions board reads like a review queue', (
    tester,
  ) async {
    final workspace = buildWorkspace();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          treasuryWorkspaceProvider.overrideWith(
            (ref) async => workspace,
          ),
          treasuryDecisionRecordsProvider.overrideWith(
            (ref) async => const [
              TreasuryDecisionRecord(
                date: '2026-05-28',
                decisionNeeded: 'Approve project budget',
                amount: '\u00A3120.00',
                status: 'Decision',
                decision: 'Approved with a small buffer',
                owner: 'Hayley',
                notes: 'Keep the next step calm and simple.',
              ),
            ],
          ),
        ],
        child: const MaterialApp(home: TreasuryDecisionsBoardScreen()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Open monthly summary', skipOffstage: false),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('Decision queue'), findsOneWidget);
    expect(
      find.text('1 decision is ready for review in the register.'),
      findsOneWidget,
    );
    expect(find.text('Approve project budget'), findsWidgets);
    expect(find.text('Add decision'), findsWidgets);
    expect(find.text('Open monthly summary'), findsWidgets);
  });
}
