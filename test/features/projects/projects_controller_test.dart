import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/dashboard/application/dashboard_controller.dart';
import 'package:new_earth_command_dashboard/features/projects/application/projects_controller.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';

void main() {
  test(
    'project actions controller refreshes active lists after archive',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = ProjectRepository(database);
      final project = await repository.createProject(
        name: 'Controller Archive Project',
        status: 'Active',
        priority: 'High',
      );

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) => database),
          databaseReadyProvider.overrideWith((ref) async {}),
        ],
      );
      addTearDown(container.dispose);

      final initialProjects = await container.read(projectsProvider.future);
      final initialDashboard = await container.read(
        dashboardSnapshotProvider.future,
      );

      expect(
        initialProjects.any((item) => item.projectId == project.projectId),
        isTrue,
      );
      expect(initialDashboard.activeProjectCount, 1);

      await container
          .read(projectActionsControllerProvider)
          .archiveProject(project.projectId);

      final refreshedProjects = await container.read(projectsProvider.future);
      final refreshedDashboard = await container.read(
        dashboardSnapshotProvider.future,
      );

      expect(
        refreshedProjects.any((item) => item.projectId == project.projectId),
        isFalse,
      );
      expect(refreshedDashboard.activeProjectCount, 0);
    },
  );
}
