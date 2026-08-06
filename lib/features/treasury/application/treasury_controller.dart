import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/treasury_folder_service.dart';

final treasuryFolderServiceProvider = Provider<TreasuryFolderService>((ref) {
  return TreasuryFolderService();
});

final treasuryWorkspaceProvider = FutureProvider<TreasuryWorkspaceSnapshot>((
  ref,
) {
  final service = ref.watch(treasuryFolderServiceProvider);
  return service.loadWorkspace();
});
