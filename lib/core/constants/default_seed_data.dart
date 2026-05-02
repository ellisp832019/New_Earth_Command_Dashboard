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
}
