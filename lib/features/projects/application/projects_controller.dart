import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return ProjectRepository(database);
});

final projectsProvider = FutureProvider<List<Project>>((ref) async {
  await ref.watch(databaseReadyProvider.future);
  return ref.watch(projectRepositoryProvider).getProjects();
});
