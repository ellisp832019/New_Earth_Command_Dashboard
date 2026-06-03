import type { RepoSnapshot } from '../types';

export class RepoBridgeService {
  constructor(private readonly snapshots: RepoSnapshot[]) {}

  getAllSnapshots(): RepoSnapshot[] {
    return this.snapshots;
  }

  getSnapshotByRepoId(repoId: string): RepoSnapshot | undefined {
    return this.snapshots.find((snapshot) => snapshot.id === repoId);
  }

  getReposNeedingDocumentation(): RepoSnapshot[] {
    return this.snapshots.filter((snapshot) => !snapshot.docs_found || snapshot.docs_found.length === 0);
  }

  getReposWithUncommittedChanges(): RepoSnapshot[] {
    return this.snapshots.filter((snapshot) => snapshot.dirty_files?.length > 0);
  }

  getRepoHealth(snapshot: RepoSnapshot): 'missing' | 'not_git' | 'dirty' | 'needs_docs' | 'healthy' {
    if (!snapshot.exists) return 'missing';
    if (!snapshot.is_git_repo) return 'not_git';
    if (snapshot.dirty_files?.length) return 'dirty';
    if (!snapshot.docs_found?.length) return 'needs_docs';
    return 'healthy';
  }
}
