import React from 'react';
import type { UnifiedProjectRecord } from '../src/types';

export function ProjectRepoCard({ project }: { project: UnifiedProjectRecord }) {
  const repo = project.latestRepoStatus;
  const dirtyCount = repo?.dirty_files?.length || 0;
  const todoCount = repo?.todo_markers?.length || 0;
  const docsCount = repo?.docs_found?.length || 0;

  return (
    <article className="rounded-2xl border border-neutral-200 bg-white p-5 shadow-sm dark:border-neutral-800 dark:bg-neutral-950">
      <div className="mb-4 flex items-start justify-between gap-4">
        <div>
          <h3 className="text-lg font-semibold">{project.name}</h3>
          <p className="text-sm text-neutral-500">{project.currentPhase || project.dashboardDescription || 'No phase set yet.'}</p>
        </div>
        <span className="rounded-full border px-3 py-1 text-xs">{project.dashboardStatus}</span>
      </div>

      <div className="grid gap-3 text-sm md:grid-cols-2">
        <div>
          <p className="font-medium">Dashboard</p>
          <p>Tasks: {project.dashboardTasks.length}</p>
          <p>Repo linked: {project.repoLinked ? 'Yes' : 'No'}</p>
        </div>
        <div>
          <p className="font-medium">Repo</p>
          <p>Branch: {repo?.branch || 'Not scanned'}</p>
          <p>Dirty files: {dirtyCount}</p>
          <p>TODO/NEXT: {todoCount}</p>
          <p>Docs found: {docsCount}</p>
        </div>
      </div>

      <div className="mt-4">
        <p className="mb-2 text-sm font-medium">Next actions</p>
        {project.nextActions.length ? (
          <ul className="list-disc space-y-1 pl-5 text-sm text-neutral-700 dark:text-neutral-300">
            {project.nextActions.slice(0, 5).map((action, index) => (
              <li key={`${project.projectId}-action-${index}`}>{action}</li>
            ))}
          </ul>
        ) : (
          <p className="text-sm text-neutral-500">No next actions generated yet.</p>
        )}
      </div>
    </article>
  );
}
