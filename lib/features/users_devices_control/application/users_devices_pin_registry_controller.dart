import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/users_devices_pin_registry_service.dart';

final usersDevicesPinRegistryProvider =
    Provider<UsersDevicesPinRegistryService>((ref) {
      return UsersDevicesPinRegistryService(
        database: ref.watch(appDatabaseProvider),
      );
    });

final usersDevicesPinRegistrySnapshotProvider =
    FutureProvider<UsersDevicesPinRegistrySnapshot>((ref) async {
      return ref.read(usersDevicesPinRegistryProvider).loadSnapshot();
    });
