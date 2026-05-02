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

final projectDetailProvider =
    FutureProvider.family<ProjectDetailSnapshot, String>((
      ref,
      projectId,
    ) async {
      await ref.watch(databaseReadyProvider.future);
      return ref.watch(projectRepositoryProvider).getProjectDetail(projectId);
    });

final projectProvider = FutureProvider.family<Project, String>((
  ref,
  projectId,
) async {
  await ref.watch(databaseReadyProvider.future);
  return ref.watch(projectRepositoryProvider).getProject(projectId);
});

final projectActionsControllerProvider = Provider<ProjectActionsController>((
  ref,
) {
  return ProjectActionsController(ref);
});

class ProjectActionsController {
  ProjectActionsController(this._ref);

  final Ref _ref;

  Future<Project> createProject({
    required String name,
    String? shortDescription,
    String? longDescription,
    String? vision,
    required String status,
    required String priority,
    required int progressPercentage,
    String? currentMilestone,
    String? nextAction,
    String? notes,
  }) async {
    final project = await _ref
        .read(projectRepositoryProvider)
        .createProject(
          name: name,
          shortDescription: shortDescription,
          longDescription: longDescription,
          vision: vision,
          status: status,
          priority: priority,
          progressPercentage: progressPercentage,
          currentMilestone: currentMilestone,
          nextAction: nextAction,
          notes: notes,
        );
    _ref.invalidate(projectsProvider);
    _ref.invalidate(projectDetailProvider(project.projectId));
    _ref.invalidate(projectProvider(project.projectId));
    return project;
  }

  Future<Project> updateProject({
    required String projectId,
    required String name,
    String? shortDescription,
    String? longDescription,
    String? vision,
    required String status,
    required String priority,
    required int progressPercentage,
    String? currentMilestone,
    String? nextAction,
    String? notes,
  }) async {
    final project = await _ref
        .read(projectRepositoryProvider)
        .updateProject(
          projectId: projectId,
          name: name,
          shortDescription: shortDescription,
          longDescription: longDescription,
          vision: vision,
          status: status,
          priority: priority,
          progressPercentage: progressPercentage,
          currentMilestone: currentMilestone,
          nextAction: nextAction,
          notes: notes,
        );
    _ref.invalidate(projectsProvider);
    _ref.invalidate(projectDetailProvider(projectId));
    _ref.invalidate(projectProvider(projectId));
    return project;
  }
}
