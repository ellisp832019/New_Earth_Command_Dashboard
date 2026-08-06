import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/backup_guardian_service.dart';

final backupGuardianServiceProvider = Provider<BackupGuardianService>((ref) {
  return BackupGuardianService();
});

final backupGuardianSnapshotProvider = FutureProvider<BackupGuardianSnapshot>((
  ref,
) async {
  return ref.read(backupGuardianServiceProvider).loadSnapshot();
});
