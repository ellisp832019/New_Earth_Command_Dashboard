import type { ExistingDashboardProject } from '../types';

export interface NormalizedDashboardProject {
  id: string;
  name: string;
  status: string;
  description: string;
  raw: ExistingDashboardProject;
}

export function normalizeDashboardProject(project: ExistingDashboardProject): NormalizedDashboardProject {
  const idSource = project.id || project.title || project.name || 'unknown_project';
  const id = String(idSource).toLowerCase().replace(/\s+/g, '_');

  return {
    id,
    name: String(project.name || project.title || id),
    status: String(project.status || 'unknown'),
    description: String(project.description || ''),
    raw: project,
  };
}

export function normalizeDashboardProjects(projects: ExistingDashboardProject[]): NormalizedDashboardProject[] {
  return projects.map(normalizeDashboardProject);
}
