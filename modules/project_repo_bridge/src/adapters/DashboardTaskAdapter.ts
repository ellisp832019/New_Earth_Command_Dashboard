import type { ExistingDashboardTask, UnifiedTaskRecord } from '../types';

export function normalizeDashboardTask(task: ExistingDashboardTask): UnifiedTaskRecord {
  return {
    id: String(task.id || task.title || task.name || 'unknown_task'),
    title: String(task.title || task.name || 'Untitled task'),
    status: task.status || 'unknown',
    projectId: String(task.projectId || task.project_id || task.project || ''),
    priority: task.priority ? String(task.priority) : undefined,
    raw: task,
  };
}

export function normalizeDashboardTasks(tasks: ExistingDashboardTask[]): UnifiedTaskRecord[] {
  return tasks.map(normalizeDashboardTask);
}
