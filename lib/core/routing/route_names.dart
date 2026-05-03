abstract final class RouteNames {
  static const dashboard = '/dashboard';
  static const projects = '/projects';
  static const newProject = '/projects/new';
  static const tasks = '/tasks';
  static const newTask = '/tasks/new';
  static const planner = '/planner';
  static const more = '/more';
  static const journal = '/journal';
  static const newJournal = '/journal/new';
  static const learning = '/learning';
  static const content = '/content';
  static const business = '/business';
  static const wellbeing = '/wellbeing';
  static const inbox = '/inbox';
  static const settings = '/settings';
  static const voiceAssistant = '/voice-assistant';

  static String projectDetail(String projectId) => '/projects/$projectId';

  static String editProject(String projectId) => '/projects/$projectId/edit';

  static String editTask(String taskId) => '/tasks/$taskId/edit';

  static String editJournal(String journalEntryId) {
    return '/journal/$journalEntryId/edit';
  }

  static String newTaskForProject(String projectId) {
    return Uri(
      path: newTask,
      queryParameters: {'projectId': projectId},
    ).toString();
  }
}
