import '../../../core/database/app_database.dart';

List<Project> filterProjects({
  required List<Project> projects,
  String statusFilter = 'All',
  String priorityFilter = 'All',
  String searchQuery = '',
}) {
  final normalizedQuery = searchQuery.trim().toLowerCase();

  return projects.where((project) {
    if (statusFilter != 'All' && project.status != statusFilter) {
      return false;
    }

    if (priorityFilter != 'All' && project.priority != priorityFilter) {
      return false;
    }

    if (normalizedQuery.isEmpty) {
      return true;
    }

    final searchableText = <Object?>[
      project.name,
      project.shortDescription,
      project.longDescription,
      project.vision,
      project.status,
      project.priority,
      project.currentMilestone,
      project.nextAction,
    ].whereType<String>().map((value) => value.toLowerCase()).join(' ');

    return searchableText.contains(normalizedQuery);
  }).toList();
}
