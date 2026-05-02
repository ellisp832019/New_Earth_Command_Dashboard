import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/dashboard_repository.dart';

final dashboardSnapshotProvider = FutureProvider<DashboardSnapshot>((
  ref,
) async {
  await ref.watch(databaseReadyProvider.future);
  final database = ref.watch(appDatabaseProvider);

  return DashboardRepository(database).loadTodaySnapshot();
});
