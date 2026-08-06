import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../projects/application/projects_controller.dart';
import '../../tasks/application/tasks_controller.dart';
import '../data/project_repo_bridge_models.dart';
import '../data/project_repo_bridge_service.dart';

final projectRepoBridgeServiceProvider = Provider<ProjectRepoBridgeService>((
  ref,
) {
  final projectRepository = ref.watch(projectRepositoryProvider);
  final taskRepository = ref.watch(taskRepositoryProvider);
  return ProjectRepoBridgeService(
    projectRepository: projectRepository,
    taskRepository: taskRepository,
  );
});

final projectIntelligenceBundleProvider =
    FutureProvider<ProjectRepoBridgeBundle>((ref) async {
      await ref.watch(databaseReadyProvider.future);
      final service = ref.watch(projectRepoBridgeServiceProvider);
      return service.refreshBundle();
    });
