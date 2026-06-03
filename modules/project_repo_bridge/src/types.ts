export type DashboardTaskStatus = 'todo' | 'active' | 'blocked' | 'done' | string;

export interface ExistingDashboardProject {
  id: string;
  name?: string;
  title?: string;
  status?: string;
  description?: string;
  [key: string]: unknown;
}

export interface ExistingDashboardTask {
  id: string;
  title?: string;
  name?: string;
  status?: DashboardTaskStatus;
  projectId?: string;
  project_id?: string;
  project?: string;
  priority?: string;
  [key: string]: unknown;
}

export interface UnifiedTaskRecord {
  id: string;
  title: string;
  status: DashboardTaskStatus;
  projectId?: string;
  priority?: string;
  raw?: ExistingDashboardTask;
}

export interface RepoSnapshot {
  id: string;
  name: string;
  repo_path: string;
  dashboard_project_id?: string;
  omega_path?: string;
  status?: string;
  type?: string;
  current_phase?: string;
  exists: boolean;
  is_git_repo: boolean;
  branch?: string;
  latest_commit?: string;
  latest_commit_date?: string;
  tags: string[];
  dirty_files: string[];
  recent_commits: string[];
  docs_found: string[];
  todo_markers: Array<{ file: string; line: number; text: string }>;
  scan_warnings: string[];
  scanned_at: string;
}

export interface UnifiedProjectRecord {
  projectId: string;
  name: string;
  dashboardStatus: string;
  dashboardDescription?: string;
  dashboardTasks: UnifiedTaskRecord[];
  repoLinked: boolean;
  repoId?: string;
  repoPath?: string;
  omegaPath?: string;
  currentPhase?: string;
  latestRepoStatus?: RepoSnapshot;
  nextActions: string[];
  codexHandoffReady: boolean;
  lastMergedAt: string;
}
