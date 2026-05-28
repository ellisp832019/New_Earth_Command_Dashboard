import 'package:flutter_riverpod/flutter_riverpod.dart';

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
