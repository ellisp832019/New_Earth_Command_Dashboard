import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/asset_csv_service.dart';
import '../data/asset_change_journal.dart';
import '../data/asset_register_repository.dart';
import '../data/assets_folder_service.dart';

final assetFolderServiceProvider = Provider<AssetFolderService>((ref) {
  return AssetFolderService();
});

final assetRegisterRepositoryProvider = Provider<AssetRegisterRepository>((ref) {
  return ref.watch(assetFolderServiceProvider).registerRepository;
});

final assetWorkspaceProvider = FutureProvider<AssetWorkspaceSnapshot>((ref) {
  final service = ref.watch(assetFolderServiceProvider);
  return service.loadWorkspace();
});

final assetEquipmentRegisterProvider = FutureProvider<AssetCsvTable>((ref) async {
  final workspace = await ref.watch(assetWorkspaceProvider.future);
  if (workspace.assetsRootPath == null) {
    return const AssetCsvTable(
      headers: AssetRegisterRepository.equipmentHeaders,
      rows: <Map<String, String>>[],
    );
  }

  final repository = ref.watch(assetRegisterRepositoryProvider);
  return repository.readEquipmentRegister(workspace.assetsRootPath!);
});

final assetPartsRegisterProvider = FutureProvider<AssetCsvTable>((ref) async {
  final workspace = await ref.watch(assetWorkspaceProvider.future);
  if (workspace.assetsRootPath == null) {
    return const AssetCsvTable(
      headers: AssetRegisterRepository.partsHeaders,
      rows: <Map<String, String>>[],
    );
  }

  final repository = ref.watch(assetRegisterRepositoryProvider);
  return repository.readPartsInventory(workspace.assetsRootPath!);
});

final assetOrdersTrackerProvider = FutureProvider<AssetCsvTable>((ref) async {
  final workspace = await ref.watch(assetWorkspaceProvider.future);
  if (workspace.assetsRootPath == null) {
    return const AssetCsvTable(
      headers: AssetRegisterRepository.ordersHeaders,
      rows: <Map<String, String>>[],
    );
  }

  final repository = ref.watch(assetRegisterRepositoryProvider);
  return repository.readOrdersTracker(workspace.assetsRootPath!);
});

final assetSupplierRegisterProvider = FutureProvider<AssetCsvTable>((ref) async {
  final workspace = await ref.watch(assetWorkspaceProvider.future);
  if (workspace.assetsRootPath == null) {
    return const AssetCsvTable(
      headers: AssetRegisterRepository.supplierHeaders,
      rows: <Map<String, String>>[],
    );
  }

  final repository = ref.watch(assetRegisterRepositoryProvider);
  return repository.readSupplierRegister(workspace.assetsRootPath!);
});

final assetReorderListProvider = FutureProvider<AssetCsvTable>((ref) async {
  final workspace = await ref.watch(assetWorkspaceProvider.future);
  if (workspace.assetsRootPath == null) {
    return const AssetCsvTable(
      headers: AssetRegisterRepository.reorderHeaders,
      rows: <Map<String, String>>[],
    );
  }

  final repository = ref.watch(assetRegisterRepositoryProvider);
  return repository.readReorderList(workspace.assetsRootPath!);
});

final assetMaintenanceLogProvider = FutureProvider<AssetCsvTable>((ref) async {
  final workspace = await ref.watch(assetWorkspaceProvider.future);
  if (workspace.assetsRootPath == null) {
    return const AssetCsvTable(
      headers: AssetRegisterRepository.maintenanceHeaders,
      rows: <Map<String, String>>[],
    );
  }

  final repository = ref.watch(assetRegisterRepositoryProvider);
  return repository.readMaintenanceLog(workspace.assetsRootPath!);
});

final assetLocationRegisterProvider = FutureProvider<AssetCsvTable>((ref) async {
  final workspace = await ref.watch(assetWorkspaceProvider.future);
  if (workspace.assetsRootPath == null) {
    return const AssetCsvTable(
      headers: AssetRegisterRepository.locationHeaders,
      rows: <Map<String, String>>[],
    );
  }

  final repository = ref.watch(assetRegisterRepositoryProvider);
  return repository.readLocationRegister(workspace.assetsRootPath!);
});

final assetValuationSummaryProvider = FutureProvider<AssetCsvTable>((ref) async {
  final workspace = await ref.watch(assetWorkspaceProvider.future);
  if (workspace.assetsRootPath == null) {
    return const AssetCsvTable(
      headers: AssetRegisterRepository.valuationHeaders,
      rows: <Map<String, String>>[],
    );
  }

  final repository = ref.watch(assetRegisterRepositoryProvider);
  return repository.readValuationSummary(workspace.assetsRootPath!);
});

final assetQrLabelRegisterProvider = FutureProvider<AssetCsvTable>((ref) async {
  final workspace = await ref.watch(assetWorkspaceProvider.future);
  if (workspace.assetsRootPath == null) {
    return const AssetCsvTable(
      headers: AssetRegisterRepository.qrLabelHeaders,
      rows: <Map<String, String>>[],
    );
  }

  final repository = ref.watch(assetRegisterRepositoryProvider);
  return repository.readQrLabelRegister(workspace.assetsRootPath!);
});

final assetChangeJournalEntriesProvider =
    FutureProvider<List<AssetChangeJournalEntry>>((ref) async {
  final workspace = await ref.watch(assetWorkspaceProvider.future);
  if (workspace.assetsRootPath == null) {
    return <AssetChangeJournalEntry>[];
  }

  final repository = ref.watch(assetRegisterRepositoryProvider);
  final table = await repository.readChangeJournal(workspace.assetsRootPath!);
  return table.rows
      .map(AssetChangeJournalEntry.fromCsvRow)
      .toList(growable: false);
});

final assetSyncStatusProvider = FutureProvider<AssetSyncStatus>((ref) async {
  final workspace = await ref.watch(assetWorkspaceProvider.future);
  if (workspace.assetsRootPath == null) {
    return const AssetSyncStatus(
      isConnected: false,
      entryCount: 0,
      conflictCount: 0,
      lastChangeAt: null,
      lastWriterLabel: 'No asset journal yet',
      statusLabel: 'Journal not linked',
    );
  }

  final entries = await ref.watch(assetChangeJournalEntriesProvider.future);
  final lastEntry = entries.isNotEmpty ? entries.last : null;

  return AssetSyncStatus(
    isConnected: true,
    entryCount: entries.length,
    conflictCount: 0,
    lastChangeAt: lastEntry?.timestamp,
    lastWriterLabel: lastEntry?.userLabel.isNotEmpty == true
        ? lastEntry!.userLabel
        : 'No writer recorded yet',
    statusLabel: entries.isEmpty ? 'Journal ready' : 'Journal active',
  );
});

final assetValuationOverviewProvider =
    FutureProvider<AssetValuationOverview>((ref) async {
  final equipmentTable = await ref.watch(assetEquipmentRegisterProvider.future);
  final valuationTable = await ref.watch(assetValuationSummaryProvider.future);

  final equipmentById = <String, Map<String, String>>{};
  for (final row in equipmentTable.rows) {
    final assetId = (row['asset_id'] ?? '').trim();
    if (assetId.isNotEmpty) {
      equipmentById[assetId] = row;
    }
  }

  final projects = <String, _AssetValuationProjectAccumulator>{};
  var purchaseCostTotal = 0.0;
  var replacementValueTotal = 0.0;
  var currentEstimatedValueTotal = 0.0;
  var brokenLostValueTotal = 0.0;

  for (final row in valuationTable.rows) {
    final assetId = (row['asset_id'] ?? '').trim();
    final equipment = equipmentById[assetId];
    final projectName = _projectName(equipment?['project']);
    final project = projects.putIfAbsent(
      projectName,
      () => _AssetValuationProjectAccumulator(projectName),
    );

    final purchaseCost = _parseMoney(row['purchase_cost']) ?? 0;
    final replacementValue = _parseMoney(row['replacement_value']) ?? 0;
    final currentValue = _parseMoney(row['current_estimated_value']) ??
        replacementValue;
    final isBroken = _normalizedStatus(equipment?['status']) == 'broken' ||
        _normalizedStatus(equipment?['condition']) == 'broken';

    purchaseCostTotal += purchaseCost;
    replacementValueTotal += replacementValue;
    currentEstimatedValueTotal += currentValue;
    if (isBroken) {
      brokenLostValueTotal += currentValue;
    }

    project.purchaseCostTotal += purchaseCost;
    project.replacementValueTotal += replacementValue;
    project.currentEstimatedValueTotal += currentValue;
    if (isBroken) {
      project.brokenLostValueTotal += currentValue;
    }
    project.items += 1;
  }

  final projectTotals = projects.values
      .map(
        (project) => AssetValuationProjectTotal(
          projectName: project.projectName,
          items: project.items,
          purchaseCostTotal: project.purchaseCostTotal,
          replacementValueTotal: project.replacementValueTotal,
          currentEstimatedValueTotal: project.currentEstimatedValueTotal,
          brokenLostValueTotal: project.brokenLostValueTotal,
        ),
      )
      .toList(growable: false)
    ..sort((a, b) => a.projectName.toLowerCase().compareTo(b.projectName.toLowerCase()));

  return AssetValuationOverview(
    purchaseCostTotal: purchaseCostTotal,
    replacementValueTotal: replacementValueTotal,
    currentEstimatedValueTotal: currentEstimatedValueTotal,
    brokenLostValueTotal: brokenLostValueTotal,
    projectTotals: projectTotals,
    valuationRowCount: valuationTable.rows.length,
  );
});

final assetLowStockPartsProvider =
    FutureProvider<List<Map<String, String>>>((ref) async {
  final table = await ref.watch(assetPartsRegisterProvider.future);
  final repository = ref.watch(assetRegisterRepositoryProvider);
  return repository.filterLowStockParts(table.rows);
});

final assetBrokenRepairEquipmentProvider =
    FutureProvider<List<Map<String, String>>>((ref) async {
  final table = await ref.watch(assetEquipmentRegisterProvider.future);
  final repository = ref.watch(assetRegisterRepositoryProvider);
  return repository.filterBrokenRepairEquipment(table.rows);
});

final assetProjectSummaryProvider =
    FutureProvider<List<AssetProjectSummary>>((ref) async {
  final equipmentTable = await ref.watch(assetEquipmentRegisterProvider.future);
  final partsTable = await ref.watch(assetPartsRegisterProvider.future);

  final projects = <String, _AssetProjectAccumulator>{};

  for (final row in equipmentTable.rows) {
    final projectName = _projectName(row['project']);
    final project = projects.putIfAbsent(
      projectName,
      () => _AssetProjectAccumulator(projectName),
    );
    project.equipmentCount += 1;

    final status = _normalizedStatus(row['status']);
    final condition = _normalizedStatus(row['condition']);
    if (status == 'broken' || status == 'repairing' || condition == 'broken' || condition == 'repairing') {
      project.brokenCount += 1;
    } else if (status == 'available' ||
        status == 'in_use' ||
        status == 'in_storage') {
      project.availableCount += 1;
    } else if (status == 'reorder_needed') {
      project.needsDecisionCount += 1;
    }
  }

  for (final row in partsTable.rows) {
    final projectName = _projectName(row['project']);
    final project = projects.putIfAbsent(
      projectName,
      () => _AssetProjectAccumulator(projectName),
    );
    project.partsCount += 1;

    final status = _normalizedStatus(row['status']);
    final quantity = _parseInt(row['quantity']);
    final minQuantity = _parseInt(row['min_quantity']);
    final isLowStock = status == 'low_stock' ||
        status == 'reorder_needed' ||
        (quantity != null && minQuantity != null && quantity <= minQuantity);
    if (isLowStock) {
      project.lowStockCount += 1;
    }
    if (status == 'reorder_needed') {
      project.needsDecisionCount += 1;
    }
  }

  final summaries = projects.values
      .map(
        (project) => AssetProjectSummary(
          projectName: project.projectName,
          equipmentCount: project.equipmentCount,
          partsCount: project.partsCount,
          availableCount: project.availableCount,
          brokenCount: project.brokenCount,
          lowStockCount: project.lowStockCount,
          needsDecisionCount: project.needsDecisionCount,
          isMixedProject: project.equipmentCount > 0 && project.partsCount > 0,
        ),
      )
      .toList(growable: false)
    ..sort((a, b) => a.projectName.toLowerCase().compareTo(b.projectName.toLowerCase()));

  return summaries;
});

class AssetProjectSummary {
  const AssetProjectSummary({
    required this.projectName,
    required this.equipmentCount,
    required this.partsCount,
    required this.availableCount,
    required this.brokenCount,
    required this.lowStockCount,
    required this.needsDecisionCount,
    required this.isMixedProject,
  });

  final String projectName;
  final int equipmentCount;
  final int partsCount;
  final int availableCount;
  final int brokenCount;
  final int lowStockCount;
  final int needsDecisionCount;
  final bool isMixedProject;
}

class AssetValuationOverview {
  const AssetValuationOverview({
    required this.purchaseCostTotal,
    required this.replacementValueTotal,
    required this.currentEstimatedValueTotal,
    required this.brokenLostValueTotal,
    required this.projectTotals,
    required this.valuationRowCount,
  });

  final double purchaseCostTotal;
  final double replacementValueTotal;
  final double currentEstimatedValueTotal;
  final double brokenLostValueTotal;
  final List<AssetValuationProjectTotal> projectTotals;
  final int valuationRowCount;
}

class AssetValuationProjectTotal {
  const AssetValuationProjectTotal({
    required this.projectName,
    required this.items,
    required this.purchaseCostTotal,
    required this.replacementValueTotal,
    required this.currentEstimatedValueTotal,
    required this.brokenLostValueTotal,
  });

  final String projectName;
  final int items;
  final double purchaseCostTotal;
  final double replacementValueTotal;
  final double currentEstimatedValueTotal;
  final double brokenLostValueTotal;
}

class _AssetProjectAccumulator {
  _AssetProjectAccumulator(this.projectName);

  final String projectName;
  int equipmentCount = 0;
  int partsCount = 0;
  int availableCount = 0;
  int brokenCount = 0;
  int lowStockCount = 0;
  int needsDecisionCount = 0;
}

class _AssetValuationProjectAccumulator {
  _AssetValuationProjectAccumulator(this.projectName);

  final String projectName;
  int items = 0;
  double purchaseCostTotal = 0;
  double replacementValueTotal = 0;
  double currentEstimatedValueTotal = 0;
  double brokenLostValueTotal = 0;
}

class AssetSyncStatus {
  const AssetSyncStatus({
    required this.isConnected,
    required this.entryCount,
    required this.conflictCount,
    required this.lastChangeAt,
    required this.lastWriterLabel,
    required this.statusLabel,
  });

  final bool isConnected;
  final int entryCount;
  final int conflictCount;
  final DateTime? lastChangeAt;
  final String lastWriterLabel;
  final String statusLabel;
}

String _projectName(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? 'Unassigned' : trimmed;
}

String _normalizedStatus(String? value) {
  return (value ?? '').trim().toLowerCase().replaceAll(' ', '_');
}

int? _parseInt(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return null;
  }

  return int.tryParse(trimmed);
}

double? _parseMoney(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return null;
  }

  return double.tryParse(trimmed);
}
