import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/treasury_folder_service.dart';
import 'treasury_monthly_summary_controller.dart';

enum TreasuryBudgetPotKind { safe, watch, pause, decision, future, archived }

class TreasuryBudgetPot {
  const TreasuryBudgetPot({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.itemCount,
    required this.items,
  });

  final TreasuryBudgetPotKind kind;
  final String title;
  final String subtitle;
  final int itemCount;
  final List<String> items;
}

class TreasuryBudgetPotsSnapshot {
  const TreasuryBudgetPotsSnapshot({
    required this.workspace,
    required this.generatedAt,
    required this.projectSpendTotal,
    required this.subscriptionTotal,
    required this.pots,
    required this.issues,
  });

  final TreasuryWorkspaceSnapshot workspace;
  final DateTime generatedAt;
  final double projectSpendTotal;
  final double subscriptionTotal;
  final List<TreasuryBudgetPot> pots;
  final List<String> issues;

  factory TreasuryBudgetPotsSnapshot.fromMonthlySummary(
    TreasuryMonthlySummarySnapshot summary,
  ) {
    final pots = <TreasuryBudgetPot>[
      _buildPot(
        summary,
        TreasuryBudgetPotKind.safe,
        'Safe to Spend',
        'Money that feels settled enough to use calmly.',
      ),
      _buildPot(
        summary,
        TreasuryBudgetPotKind.watch,
        'Watch Buffer',
        'Money or items that deserve a closer look soon.',
      ),
      _buildPot(
        summary,
        TreasuryBudgetPotKind.pause,
        'Pause Reserve',
        'Items to hold until the picture feels steadier.',
      ),
      _buildPot(
        summary,
        TreasuryBudgetPotKind.decision,
        'Decision Pot',
        'Choices waiting for a calm yes or no.',
      ),
      _buildPot(
        summary,
        TreasuryBudgetPotKind.future,
        'Future Investment',
        'Ideas to keep nearby without acting on them yet.',
      ),
      _buildPot(
        summary,
        TreasuryBudgetPotKind.archived,
        'Archived',
        'Old notes kept for reference rather than daily use.',
      ),
    ];

    return TreasuryBudgetPotsSnapshot(
      workspace: summary.workspace,
      generatedAt: summary.generatedAt,
      projectSpendTotal: summary.projectSpendTotal,
      subscriptionTotal: summary.subscriptionTotal,
      pots: pots,
      issues: summary.issues,
    );
  }

  static TreasuryBudgetPot _buildPot(
    TreasuryMonthlySummarySnapshot summary,
    TreasuryBudgetPotKind kind,
    String title,
    String subtitle,
  ) {
    final stateSummary = summary.workspace.stateSummaries.firstWhere(
      (entry) => switch (kind) {
        TreasuryBudgetPotKind.safe => entry.kind == TreasuryStatusKind.safe,
        TreasuryBudgetPotKind.watch => entry.kind == TreasuryStatusKind.watch,
        TreasuryBudgetPotKind.pause => entry.kind == TreasuryStatusKind.pause,
        TreasuryBudgetPotKind.decision =>
          entry.kind == TreasuryStatusKind.decision,
        TreasuryBudgetPotKind.future => entry.kind == TreasuryStatusKind.future,
        TreasuryBudgetPotKind.archived =>
          entry.kind == TreasuryStatusKind.archived,
      },
    );

    return TreasuryBudgetPot(
      kind: kind,
      title: title,
      subtitle: subtitle,
      itemCount: stateSummary.count,
      items: stateSummary.items,
    );
  }
}

final treasuryBudgetPotsProvider = FutureProvider<TreasuryBudgetPotsSnapshot>((
  ref,
) async {
  final summary = await ref.watch(treasuryMonthlySummaryProvider.future);
  return TreasuryBudgetPotsSnapshot.fromMonthlySummary(summary);
});
