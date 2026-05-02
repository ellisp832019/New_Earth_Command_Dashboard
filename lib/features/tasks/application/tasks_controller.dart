import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return TaskRepository(database);
});

final tasksProvider = FutureProvider<List<Task>>((ref) async {
  await ref.watch(databaseReadyProvider.future);
  return ref.watch(taskRepositoryProvider).getActiveTasks();
});
