import '../../../core/database/app_database.dart';
import 'project_repo_bridge_models.dart';

class DashboardProjectAdapter {
  const DashboardProjectAdapter();

  // Adapter-specific: keep the Dashboard project table as source of truth and
  // project it into a read-only unified intelligence record.
  UnifiedProjectRecord fromProject({
    required Project project,
    required List<UnifiedTaskRecord> dashboardTasks,
    required String mergedAt,
    RepoSnapshot? repoSnapshot,
    String? repoId,
    List<String> nextActions = const <String>[],
    bool codexHandoffReady = false,
  }) {
    return UnifiedProjectRecord(
      projectId: project.projectId,
      name: project.name,
      dashboardStatus: project.status,
      dashboardDescription: project.shortDescription?.trim().isNotEmpty == true
          ? project.shortDescription
          : project.longDescription,
      dashboardTasks: dashboardTasks,
      repoLinked: repoSnapshot?.exists == true,
      repoId: repoId,
      repoPath: repoSnapshot?.repoPath,
      omegaPath: repoSnapshot?.omegaPath,
      currentPhase:
          repoSnapshot?.currentPhase ??
          project.currentMilestone ??
          project.nextAction,
      latestRepoStatus: repoSnapshot,
      nextActions: nextActions,
      codexHandoffReady: codexHandoffReady,
      lastMergedAt: mergedAt,
    );
  }
}
