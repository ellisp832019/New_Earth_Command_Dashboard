import type { RepoSnapshot, UnifiedProjectRecord, UnifiedTaskRecord } from '../types';
import type { NormalizedDashboardProject } from './DashboardProjectAdapter';

export interface RepoMapping {
  dashboard_project_id: string;
  repo_id: string;
}

export interface RegisteredRepo {
  id: string;
  name: string;
  repo_path: string;
  dashboard_project_id?: string;
  omega_path?: string;
  status?: string;
  type?: string;
  current_phase?: string;
}

export function mapUnifiedProject(params: {
  project: NormalizedDashboardProject;
  tasks: UnifiedTaskRecord[];
  mapping?: RepoMapping;
  registeredRepo?: RegisteredRepo;
  repoSnapshot?: RepoSnapshot;
  mergedAt: string;
}): UnifiedProjectRecord {
  const { project, tasks, mapping, registeredRepo, repoSnapshot, mergedAt } = params;
  const openTasks = tasks.filter((task) => !['done', 'complete', 'completed'].includes(String(task.status).toLowerCase()));
  const nextActions = openTasks.slice(0, 5).map((task) => task.title);

  if (repoSnapshot?.dirty_files?.length) {
    nextActions.push('Review uncommitted repo changes.');
  }

  if (repoSnapshot?.todo_markers?.length) {
    nextActions.push('Convert important TODO/NEXT markers into Dashboard tasks.');
  }

  return {
    projectId: project.id,
    name: project.name,
    dashboardStatus: project.status,
    dashboardDescription: project.description,
    dashboardTasks: tasks,
    repoLinked: Boolean(mapping?.repo_id || registeredRepo?.id),
    repoId: mapping?.repo_id || registeredRepo?.id,
    repoPath: registeredRepo?.repo_path,
    omegaPath: registeredRepo?.omega_path,
    currentPhase: registeredRepo?.current_phase || project.description,
    latestRepoStatus: repoSnapshot,
    nextActions,
    codexHandoffReady: Boolean(mapping?.repo_id || registeredRepo?.id),
    lastMergedAt: mergedAt,
  };
}
