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
  static const newLearning = '/learning/new';
  static const content = '/content';
  static const newContent = '/content/new';
  static const business = '/business';
  static const newBusiness = '/business/new';
  static const wellbeing = '/wellbeing';
  static const newWellbeing = '/wellbeing/new';
  static const inbox = '/inbox';
  static const newInbox = '/inbox/new';
  static const settings = '/settings';
  static const voiceAssistant = '/voice-assistant';

  static String projectDetail(String projectId) => '/projects/$projectId';

  static String editProject(String projectId) => '/projects/$projectId/edit';

  static String editTask(String taskId) => '/tasks/$taskId/edit';

  static String editJournal(String journalEntryId) {
    return '/journal/$journalEntryId/edit';
  }

  static String editLearning(String learningItemId) {
    return '/learning/$learningItemId/edit';
  }

  static String editContent(String contentItemId) {
    return '/content/$contentItemId/edit';
  }

  static String newTaskForProject(String projectId) {
    return Uri(
      path: newTask,
      queryParameters: {'projectId': projectId},
    ).toString();
  }
}
