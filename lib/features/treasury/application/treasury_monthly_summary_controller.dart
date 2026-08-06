import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/treasury_folder_service.dart';
import 'treasury_controller.dart';

final treasuryMonthlySummaryProvider =
    FutureProvider<TreasuryMonthlySummarySnapshot>((ref) async {
      final service = ref.watch(treasuryFolderServiceProvider);
      final workspace = await ref.watch(treasuryWorkspaceProvider.future);
      return service.loadMonthlySummary(workspace: workspace);
    });
