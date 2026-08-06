class DefaultProjectSeed {
  const DefaultProjectSeed({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.vision,
    required this.status,
    required this.priority,
    required this.currentMilestone,
    required this.nextAction,
  });

  final String id;
  final String name;
  final String shortDescription;
  final String vision;
  final String status;
  final String priority;
  final String currentMilestone;
  final String nextAction;
}

class DefaultTaskSeed {
  const DefaultTaskSeed({
    required this.id,
    required this.title,
    required this.description,
    required this.projectId,
    required this.category,
    required this.priority,
    required this.status,
  });

  final String id;
  final String title;
  final String description;
  final String projectId;
  final String category;
  final String priority;
  final String status;
}

abstract final class DefaultSeedData {
  static const settingsId = 'default-settings';

  static const projects = [
    DefaultProjectSeed(
      id: 'project-microgrow',
      name: 'MicroGrow',
      shortDescription: 'Smart grow automation platform.',
      vision:
          'Build resilient growing systems that make food production more accessible.',
      status: 'Active',
      priority: 'High',
      currentMilestone: 'Stabilise core diagnostics and v1.0 direction.',
      nextAction: 'Review current MicroGrow build priorities.',
    ),
    DefaultProjectSeed(
      id: 'project-microgrow-field-scanner',
      name: 'MicroGrow Field Scanner',
      shortDescription: 'Field maintenance and diagnostics tool for MicroGrow.',
      vision: 'Make field checks clearer, faster, and easier to act on.',
      status: 'Active',
      priority: 'High',
      currentMilestone: 'Shape the diagnostics screen and testing workflow.',
      nextAction: 'Define the next useful scanner prototype step.',
    ),
    DefaultProjectSeed(
      id: 'project-new-earth-website',
      name: 'New Earth Website',
      shortDescription: 'Public home for New Earth projects and updates.',
      vision: 'Give the mission a clear place to be understood and followed.',
      status: 'Active',
      priority: 'High',
      currentMilestone: 'Clarify site structure and founder journey content.',
      nextAction: 'Choose the next page or section to improve.',
    ),
    DefaultProjectSeed(
      id: 'project-new-earth-living-app',
      name: 'New Earth Living App',
      shortDescription: 'Future companion app for sustainable daily living.',
      vision: 'Turn New Earth principles into simple everyday guidance.',
      status: 'Idea',
      priority: 'Medium',
      currentMilestone: 'Hold the concept without distracting from the MVP.',
      nextAction: 'Park useful ideas in notes until the dashboard is stable.',
    ),
    DefaultProjectSeed(
      id: 'project-smart-growing-systems-book',
      name: 'Smart Growing Systems Book',
      shortDescription: 'Book project for smart growing systems knowledge.',
      vision:
          'Capture practical growing, automation, and systems knowledge in one body of work.',
      status: 'Active',
      priority: 'Medium',
      currentMilestone: 'Collect build notes and chapter seeds.',
      nextAction: 'Capture one useful book note from current build work.',
    ),
    DefaultProjectSeed(
      id: 'project-linkedin-public-awareness',
      name: 'LinkedIn / Public Awareness',
      shortDescription: 'Build-in-public updates and public communication.',
      vision:
          'Share progress in a way that grows trust, awareness, and momentum.',
      status: 'Active',
      priority: 'Medium',
      currentMilestone: 'Turn daily progress into useful public updates.',
      nextAction: 'Draft the next build-in-public post idea.',
    ),
    DefaultProjectSeed(
      id: 'project-business-funding',
      name: 'Business & Funding',
      shortDescription:
          'Funding, income, partnerships, and practical opportunities.',
      vision: 'Keep New Earth financially grounded and able to keep building.',
      status: 'Active',
      priority: 'High',
      currentMilestone: 'Track immediate opportunities and next actions.',
      nextAction: 'Review the most important business follow-up.',
    ),
    DefaultProjectSeed(
      id: 'project-learning-skills',
      name: 'Learning & Skills',
      shortDescription: 'Skills needed to build New Earth well.',
      vision: 'Connect learning directly to practical building.',
      status: 'Active',
      priority: 'Medium',
      currentMilestone: 'Focus learning around the current build slice.',
      nextAction: 'Choose one learning action that supports today.',
    ),
    DefaultProjectSeed(
      id: 'project-future-ideas',
      name: 'Future Ideas',
      shortDescription:
          'A calm parking place for ideas that are not for today.',
      vision:
          'Protect good ideas without letting them overwhelm the current build.',
      status: 'Idea',
      priority: 'Someday',
      currentMilestone: 'Keep future ideas parked and searchable.',
      nextAction: 'Capture ideas here instead of expanding scope today.',
    ),
  ];

  static const futureTasks = [
    DefaultTaskSeed(
      id: 'future-task-inbox-triage-queue',
      title: 'Inbox Triage Queue',
      description:
          'Add a faster Inbox workflow so unprocessed items can be converted into tasks, journal entries, content ideas, learning items, or business opportunities in one place.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'Medium',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-inbox-item-preview',
      title: 'Inbox Item Preview',
      description:
          'Show a compact preview for Inbox items with the source text, suggested destination, and quick actions before processing.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'Medium',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-voice-shortcut-templates',
      title: 'Voice Shortcut Templates',
      description:
          'Add natural voice templates like "task", "journal", "business", and "content" so captured speech turns into structured items more reliably.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'Medium',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-voice-capture-history',
      title: 'Voice Capture History',
      description:
          'Keep a searchable list of recent voice captures so repeated ideas can be reused or turned into similar items later.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'Medium',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-smart-task-recommendations',
      title: 'Smart Task Recommendations',
      description:
          'Improve the task suggestion strip so it can recommend the best next action based on status, Top 3, due date, and age.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'High',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-blocker-notes-for-tasks',
      title: 'Blocker Notes for Tasks',
      description:
          'Let blocked tasks store a short blocker note so the reason for delay is visible when the task returns later.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'Medium',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-carry-forward-assistant',
      title: 'Carry Forward Assistant',
      description:
          'Create a carry-forward flow that automatically suggests unfinished Top 3 and blocked tasks for the next day.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'High',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-task-due-date-support',
      title: 'Task Due Date Support',
      description:
          'Add richer due date handling to task creation, editing, filtering, and dashboard surfacing.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'Medium',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-task-priority-review',
      title: 'Task Priority Review',
      description:
          'Add a lightweight review surface for task priority changes so users can quickly keep the list honest.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'Medium',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-cross-module-search',
      title: 'Cross-Module Search',
      description:
          'Add search across Tasks, Journal, Projects, Inbox, Content, Learning, and Business from one place.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'Medium',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-project-timeline-view',
      title: 'Project Timeline View',
      description:
          'Build a timeline for each project that shows linked tasks, journal notes, learning items, content ideas, and business actions.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'Medium',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-project-health-summary',
      title: 'Project Health Summary',
      description:
          'Show a compact project health summary with progress, recent activity, blockers, and next action.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'Medium',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-journal-tagging',
      title: 'Journal Tagging',
      description:
          'Add tags and filters to Journal so build notes can be grouped by topic, module, or project phase.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'Medium',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-content-pipeline-states',
      title: 'Content Pipeline States',
      description:
          'Make Content items easier to move through idea, draft, review, ready, and published states.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'Medium',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-business-follow-up-system',
      title: 'Business Follow-Up System',
      description:
          'Add clearer follow-up tracking for business opportunities, including next contact date, status nudges, and next action prompts.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'High',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-learning-study-plan',
      title: 'Learning Study Plan',
      description:
          'Give Learning items a simple study-plan flow with status, next step, and linked practice task.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'Medium',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-wellbeing-trend-view',
      title: 'Wellbeing Trend View',
      description:
          'Add a simple wellbeing history view so energy, mood, and stress patterns are easier to notice over time.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'Medium',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-settings-export-and-backup',
      title: 'Settings Export and Backup',
      description:
          'Add local export and backup tools so the database can be saved, inspected, or moved safely.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'Medium',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-dashboard-customization',
      title: 'Dashboard Customization',
      description:
          'Allow dashboard cards to be reordered or hidden so the home screen can stay calm and personal.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'Medium',
      status: 'Planned',
    ),
    DefaultTaskSeed(
      id: 'future-task-desktop-voice-hardening',
      title: 'Desktop Voice Hardening',
      description:
          'Strengthen the Windows voice path so microphone capture, focus handling, and fullscreen behavior stay smooth in daily use.',
      projectId: 'project-future-ideas',
      category: 'Planning',
      priority: 'High',
      status: 'Planned',
    ),
  ];
}
