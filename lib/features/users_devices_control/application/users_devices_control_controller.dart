import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/users_devices_control_repository.dart';

final usersDevicesControlRepositoryProvider =
    Provider<UsersDevicesControlRepository>((ref) {
  return const UsersDevicesControlRepository();
});

final usersDevicesControlSnapshotProvider =
    FutureProvider<UsersDevicesControlSnapshot>((ref) async {
  final repository = ref.watch(usersDevicesControlRepositoryProvider);
  return repository.loadSnapshot();
});
