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

final assetLowStockPartsProvider =
    FutureProvider<List<Map<String, String>>>((ref) async {
  final table = await ref.watch(assetPartsRegisterProvider.future);
  final repository = ref.watch(assetRegisterRepositoryProvider);
  return repository.filterLowStockParts(table.rows);
});
