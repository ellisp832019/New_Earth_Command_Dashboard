import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/treasury/application/treasury_budget_pots_controller.dart';
import 'package:new_earth_command_dashboard/features/treasury/data/treasury_folder_service.dart';

void main() {
  test('TreasuryBudgetPotsSnapshot derives calm pots from monthly summary', () {
    final workspace = TreasuryWorkspaceSnapshot(
      configPath: 'config/local_paths.json',
      financeRootPath: 'D:/NEW_EARTH_OMEGA_OS_PACK/17_FINANCE_AND_TREASURY',
      isReady: true,
      issues: const <String>[],
      requiredFolders: TreasuryFolderService.requiredFolders,
      missingFolders: const <String>[],
      missingFiles: const <String>[],
      stateSummaries: const [
        TreasuryStateSummary(
          kind: TreasuryStatusKind.safe,
          title: 'Safe',
          count: 1,
          items: <String>['Rent'],
          subtitle: 'Safe items',
        ),
        TreasuryStateSummary(
          kind: TreasuryStatusKind.watch,
          title: 'Watch',
          count: 2,
          items: <String>['Utilities', 'Insurance'],
          subtitle: 'Watch items',
        ),
        TreasuryStateSummary(
          kind: TreasuryStatusKind.pause,
          title: 'Pause',
          count: 3,
          items: <String>['New purchases'],
          subtitle: 'Pause items',
        ),
        TreasuryStateSummary(
          kind: TreasuryStatusKind.decision,
          title: 'Decision',
          count: 4,
          items: <String>['Project budget'],
          subtitle: 'Decision items',
        ),
        TreasuryStateSummary(
          kind: TreasuryStatusKind.future,
          title: 'Future',
          count: 5,
          items: <String>['Growth ideas'],
          subtitle: 'Future items',
        ),
        TreasuryStateSummary(
          kind: TreasuryStatusKind.archived,
          title: 'Archived',
          count: 6,
          items: <String>['Old note'],
          subtitle: 'Archived items',
        ),
      ],
      receiptsToSortCount: 0,
      weeklyRitualSteps: TreasuryFolderService.weeklyRitualSteps,
      lowEnergySteps: TreasuryFolderService.lowEnergySteps,
      guidanceNote: 'Everything is calm.',
    );

    final summary = TreasuryMonthlySummarySnapshot(
      workspace: workspace,
      generatedAt: DateTime(2026, 5, 28),
      projectSpendTotal: 120,
      topProjectSpends: const <TreasuryMonthlyProjectSpendTotal>[],
      subscriptionTotal: 30,
      upcomingSubscriptions: const <TreasuryMonthlySubscriptionEntry>[],
      recentProjectSpendEntries: const <TreasuryMonthlyProjectSpendEntry>[],
      recentDecisions: const <TreasuryDecisionRecord>[],
      weeklyReviewDate: '2026-05-28',
      weeklyReviewNote: 'The picture is steady.',
      issues: const <String>[],
    );

    final pots = TreasuryBudgetPotsSnapshot.fromMonthlySummary(summary);

    expect(pots.pots, hasLength(6));
    expect(pots.pots.first.title, 'Safe to Spend');
    expect(pots.pots.first.itemCount, 1);
    expect(pots.pots[1].itemCount, 2);
    expect(pots.pots[3].title, 'Decision Pot');
    expect(pots.projectSpendTotal, 120);
    expect(pots.subscriptionTotal, 30);
    expect(pots.issues, isEmpty);
  });
}
