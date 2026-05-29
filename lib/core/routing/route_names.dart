abstract final class RouteNames {
  static const dashboard = '/dashboard';
  static const assets = '/assets';
  static const assetEquipment = '/assets/equipment';
  static const assetParts = '/assets/parts';
  static const assetLowStock = '/assets/low-stock';
  static const assetRepairSummary = '/assets/repair-summary';
  static const assetProjectSummary = '/assets/project-summary';
  static const assetLocationRegister = '/assets/locations';
  static const assetValuationSummary = '/assets/valuation';
  static const assetQrLabelRegister = '/assets/qr-labels';
  static const assetConflictReview = '/assets/conflicts';
  static const assetQuickCapture = '/assets/quick-capture';
  static const assetSupplierRegister = '/assets/suppliers';
  static const assetMaintenanceLog = '/assets/maintenance';
  static const assetReorderList = '/assets/reorder-list';
  static const assetOrdersTracker = '/assets/orders';
  static const visualCapture = '/assets/visual-capture';
  static const treasury = '/treasury';
  static const treasuryWizard = '/treasury/wizard';
  static const treasuryDecisions = '/treasury/decisions';
  static const treasuryMonthlySummary = '/treasury/monthly-summary';
  static const treasurySettings = '/treasury/settings';
  static const treasuryBudgetPots = '/treasury/budget-pots';
  static const projects = '/projects';
  static const newProject = '/projects/new';
  static const tasks = '/tasks';
  static const newTask = '/tasks/new';
  static const planner = '/planner';
  static const more = '/more';
  static const omegaOsFolderHealth = '/more/omega-os-health';
  static const journal = '/journal';
  static const newJournal = '/journal/new';
  static const learning = '/learning';
  static const newLearning = '/learning/new';
  static const content = '/content';
  static const newContent = '/content/new';
  static const business = '/business';
  static const newBusiness = '/business/new';
  static String editBusiness(String businessId) => '/business/$businessId/edit';
  static const wellbeing = '/wellbeing';
  static const newWellbeing = '/wellbeing/new';
  static const inbox = '/inbox';
  static const newInbox = '/inbox/new';
  static const settings = '/settings';
  static const voiceAssistant = '/voice-assistant';
  static const calmUiDemo = '/dashboard/calm-ui-demo';

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

  static String newJournalForProject(String projectId) {
    return Uri(
      path: newJournal,
      queryParameters: {'projectId': projectId},
    ).toString();
  }

  static String newLearningForProject(String projectId) {
    return Uri(
      path: newLearning,
      queryParameters: {'projectId': projectId},
    ).toString();
  }

  static String newContentForProject(String projectId) {
    return Uri(
      path: newContent,
      queryParameters: {'projectId': projectId},
    ).toString();
  }

  static String newBusinessForProject(String projectId) {
    return Uri(
      path: newBusiness,
      queryParameters: {'projectId': projectId},
    ).toString();
  }

  static String treasuryWizardFor(String flow) {
    return Uri(
      path: treasuryWizard,
      queryParameters: {'flow': flow},
    ).toString();
  }
}
