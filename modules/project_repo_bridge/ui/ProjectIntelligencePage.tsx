import React from 'react';
import type { UnifiedProjectRecord } from '../src/types';
import { ProjectRepoCard } from './ProjectRepoCard';

export function ProjectIntelligencePage({ projects }: { projects: UnifiedProjectRecord[] }) {
  const linked = projects.filter((project) => project.repoLinked).length;
  const dirty = projects.filter((project) => (project.latestRepoStatus?.dirty_files?.length || 0) > 0).length;
  const todos = projects.reduce((total, project) => total + (project.latestRepoStatus?.todo_markers?.length || 0), 0);

  return (
    <main className="space-y-6 p-6">
      <section>
        <h1 className="text-2xl font-bold">Projects Intelligence</h1>
        <p className="text-neutral-500">
          A merged view of Dashboard projects, tasks, local repos, Codex handoffs and Omega OS records.
        </p>
      </section>

      <section className="grid gap-4 md:grid-cols-4">
        <StatCard label="Projects" value={projects.length} />
        <StatCard label="Repos linked" value={linked} />
        <StatCard label="Dirty repos" value={dirty} />
        <StatCard label="TODO/NEXT markers" value={todos} />
      </section>

      <section className="grid gap-4 xl:grid-cols-2">
        {projects.map((project) => (
          <ProjectRepoCard key={project.projectId} project={project} />
        ))}
      </section>
    </main>
  );
}

function StatCard({ label, value }: { label: string; value: number }) {
  return (
    <div className="rounded-2xl border border-neutral-200 bg-white p-4 shadow-sm dark:border-neutral-800 dark:bg-neutral-950">
      <p className="text-sm text-neutral-500">{label}</p>
      <p className="text-2xl font-semibold">{value}</p>
    </div>
  );
}
