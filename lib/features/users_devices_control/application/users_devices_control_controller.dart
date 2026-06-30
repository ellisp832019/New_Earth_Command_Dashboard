import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/users_devices_control_repository.dart';

final usersDevicesControlRepositoryProvider =
    Provider<UsersDevicesControlRepository>((ref) {
  return UsersDevicesControlRepository(
    database: ref.watch(appDatabaseProvider),
  );
});

final usersDevicesControlSnapshotProvider =
    FutureProvider<UsersDevicesControlSnapshot>((ref) async {
  final repository = ref.watch(usersDevicesControlRepositoryProvider);
  return repository.loadSnapshot();
});

final usersDevicesControlMigrationHealthProvider =
    FutureProvider<UsersDevicesControlMigrationHealthSnapshot>((ref) async {
      final repository = ref.watch(usersDevicesControlRepositoryProvider);
      return repository.loadMigrationHealth();
    });
