import type { UnifiedProjectRecord } from '../types';

export class UnifiedProjectService {
  constructor(private readonly projects: UnifiedProjectRecord[]) {}

  all(): UnifiedProjectRecord[] {
    return this.projects;
  }

  active(): UnifiedProjectRecord[] {
    return this.projects.filter((project) => String(project.dashboardStatus).toLowerCase() === 'active');
  }

  withRepos(): UnifiedProjectRecord[] {
    return this.projects.filter((project) => project.repoLinked);
  }

  needingCodexHandoff(): UnifiedProjectRecord[] {
    return this.projects.filter((project) => project.codexHandoffReady);
  }

  withUncommittedChanges(): UnifiedProjectRecord[] {
    return this.projects.filter((project) => (project.latestRepoStatus?.dirty_files?.length || 0) > 0);
  }
}
