import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/assets_folder_service.dart';

final assetFolderServiceProvider = Provider<AssetFolderService>((ref) {
  return AssetFolderService();
});

final assetWorkspaceProvider = FutureProvider<AssetWorkspaceSnapshot>((ref) {
  final service = ref.watch(assetFolderServiceProvider);
  return service.loadWorkspace();
});
