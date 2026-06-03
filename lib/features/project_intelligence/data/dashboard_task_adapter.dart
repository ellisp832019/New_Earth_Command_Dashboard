import '../../../core/database/app_database.dart';
import 'project_repo_bridge_models.dart';

class DashboardTaskAdapter {
  const DashboardTaskAdapter();

  // Adapter-specific: only translate the existing Drift task row into the
  // bridge's read-only unified record shape.
  UnifiedTaskRecord fromTask(Task task) {
    return UnifiedTaskRecord(
      id: task.taskId,
      title: task.title,
      status: task.status,
      projectId: task.projectId,
      priority: task.priority,
    );
  }
}
