import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class ProjectRepository {
  ProjectRepository(this._database);

  final AppDatabase _database;

  Future<List<Project>> getProjects() async {
    final projects =
        await (_database.select(_database.projects)
              ..where((table) => table.isArchived.equals(false))
              ..orderBy([(table) => OrderingTerm.asc(table.name)]))
            .get();

    projects.sort((left, right) {
      final priorityCompare = _priorityRank(
        left.priority,
      ).compareTo(_priorityRank(right.priority));
      if (priorityCompare != 0) {
        return priorityCompare;
      }

      return left.name.compareTo(right.name);
    });

    return projects;
  }

  int _priorityRank(String priority) => switch (priority) {
    'High' => 0,
    'Medium' => 1,
    'Low' => 2,
    _ => 3,
  };
}
