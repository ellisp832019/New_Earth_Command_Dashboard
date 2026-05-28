import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/asset_csv_service.dart';
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
