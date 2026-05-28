import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/treasury_folder_service.dart';
import 'treasury_controller.dart';
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
    this.budgetPotsPath,
    this.editablePots = const <TreasuryBudgetPotRecord>[],
    this.movements = const <TreasuryBudgetPotMovement>[],
  });

  final TreasuryWorkspaceSnapshot workspace;
  final DateTime generatedAt;
  final double projectSpendTotal;
  final double subscriptionTotal;
  final List<TreasuryBudgetPot> pots;
  final List<String> issues;
  final String? budgetPotsPath;
  final List<TreasuryBudgetPotRecord> editablePots;
  final List<TreasuryBudgetPotMovement> movements;

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

class TreasuryBudgetPotsController
    extends AsyncNotifier<TreasuryBudgetPotsSnapshot> {
  @override
  Future<TreasuryBudgetPotsSnapshot> build() async {
    return _loadSnapshot();
  }

  Future<TreasuryBudgetPotsSnapshot> _loadSnapshot() async {
    final service = ref.read(treasuryFolderServiceProvider);
    final workspace = await ref.watch(treasuryWorkspaceProvider.future);
    final summary = await ref.watch(treasuryMonthlySummaryProvider.future);
    final fileState = await service.loadBudgetPotsState(
      workspace: workspace,
      summary: summary,
    );

    return TreasuryBudgetPotsSnapshot(
      workspace: workspace,
      generatedAt: summary.generatedAt,
      projectSpendTotal: summary.projectSpendTotal,
      subscriptionTotal: summary.subscriptionTotal,
      pots: TreasuryBudgetPotsSnapshot.fromMonthlySummary(summary).pots,
      issues: [
        ...summary.issues,
        if (fileState.updatedAt == null)
          'Budget pots file has not been created yet.',
      ],
      budgetPotsPath: workspace.financeRootPath == null
          ? null
          : '${workspace.financeRootPath}/00_FINANCE_DASHBOARD/budget_pots.json',
      editablePots: fileState.pots,
      movements: fileState.movements,
    );
  }

  Future<void> addPot({
    required String title,
    required String notes,
    required double target,
    required TreasuryBudgetPotOwnerGroup ownerGroup,
  }) async {
    final current = await future;
    final financeRootPath = current.workspace.financeRootPath;
    if (financeRootPath == null) {
      return;
    }

    final service = ref.read(treasuryFolderServiceProvider);
    await service.createBudgetPotRecord(
      financeRootPath: financeRootPath,
      workspace: current.workspace,
      summary: await ref.read(treasuryMonthlySummaryProvider.future),
      title: title,
      ownerGroup: ownerGroup,
      notes: notes,
      target: target,
    );
    ref.invalidateSelf();
  }

  Future<void> seedStarterPack({
    required TreasuryBudgetPotOwnerGroup ownerGroup,
    required List<TreasuryBudgetPotSeed> seeds,
  }) async {
    final current = await future;
    final financeRootPath = current.workspace.financeRootPath;
    if (financeRootPath == null) {
      return;
    }

    final service = ref.read(treasuryFolderServiceProvider);
    await service.seedBudgetPotPack(
      financeRootPath: financeRootPath,
      workspace: current.workspace,
      summary: await ref.read(treasuryMonthlySummaryProvider.future),
      ownerGroup: ownerGroup,
      seeds: seeds,
    );
    ref.invalidateSelf();
  }

  Future<void> adjustPot({
    required String potId,
    required double delta,
    required String note,
  }) async {
    final current = await future;
    final financeRootPath = current.workspace.financeRootPath;
    if (financeRootPath == null) {
      return;
    }

    final service = ref.read(treasuryFolderServiceProvider);
    await service.adjustBudgetPotRecord(
      financeRootPath: financeRootPath,
      workspace: current.workspace,
      summary: await ref.read(treasuryMonthlySummaryProvider.future),
      potId: potId,
      delta: delta,
      note: note,
    );
    ref.invalidateSelf();
  }

  Future<void> movePot({
    required String fromPotId,
    required String toPotId,
    required double amount,
    required String note,
  }) async {
    final current = await future;
    final financeRootPath = current.workspace.financeRootPath;
    if (financeRootPath == null) {
      return;
    }

    final service = ref.read(treasuryFolderServiceProvider);
    await service.moveBudgetPotBalance(
      financeRootPath: financeRootPath,
      workspace: current.workspace,
      summary: await ref.read(treasuryMonthlySummaryProvider.future),
      fromPotId: fromPotId,
      toPotId: toPotId,
      amount: amount,
      note: note,
    );
    ref.invalidateSelf();
  }
}

final treasuryBudgetPotsControllerProvider =
    AsyncNotifierProvider<
      TreasuryBudgetPotsController,
      TreasuryBudgetPotsSnapshot
    >(TreasuryBudgetPotsController.new);

final treasuryBudgetPotsProvider = treasuryBudgetPotsControllerProvider;
