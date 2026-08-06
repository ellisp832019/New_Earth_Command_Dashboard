import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/projects/application/project_filters.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';

void main() {
  test('filterProjects narrows by status, priority, and search text', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = ProjectRepository(database);

    await repository.createProject(
      name: 'MicroGrow Diagnostics',
      shortDescription: 'Bring the sensors online.',
      status: 'Active',
      priority: 'High',
      currentMilestone: 'Confirm the local wake flow',
      nextAction: 'Review the dashboard transcript',
    );
    await repository.createProject(
      name: 'Website polish',
      shortDescription: 'Tidy up the public-facing pages.',
      status: 'Idea',
      priority: 'Medium',
      currentMilestone: 'Draft new page copy',
      nextAction: 'Open the design notes',
    );

    final projects = await repository.getProjects();
    final filtered = filterProjects(
      projects: projects,
      statusFilter: 'Active',
      priorityFilter: 'High',
      searchQuery: 'transcript',
    );

    expect(filtered, hasLength(1));
    expect(filtered.single.name, 'MicroGrow Diagnostics');
  });

  test('filterProjects searches milestone and next action text', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = ProjectRepository(database);

    await repository.createProject(
      name: 'Field scanner',
      status: 'Researching',
      priority: 'Medium',
      currentMilestone: 'Build the capture tray',
      nextAction: 'Check the sensor alignment',
    );
    await repository.createProject(
      name: 'Grant pack',
      status: 'Drafting',
      priority: 'Low',
      currentMilestone: 'Finish the cover note',
      nextAction: 'Prepare the evidence bundle',
    );

    final projects = await repository.getProjects();
    final filtered = filterProjects(
      projects: projects,
      searchQuery: 'alignment',
    );

    expect(filtered, hasLength(1));
    expect(filtered.single.name, 'Field scanner');
  });
}
