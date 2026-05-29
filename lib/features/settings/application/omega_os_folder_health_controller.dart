import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/omega_os_folder_health_service.dart';

final omegaOsFolderHealthServiceProvider = Provider<OmegaOsFolderHealthService>(
  (ref) {
    return OmegaOsFolderHealthService();
  },
);

final omegaOsFolderHealthSnapshotProvider =
    FutureProvider<OmegaOsFolderHealthSnapshot>((ref) {
      final service = ref.watch(omegaOsFolderHealthServiceProvider);
      return service.loadSnapshot();
    });
