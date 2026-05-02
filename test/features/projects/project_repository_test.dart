import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/core/services/seed_data_service.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';

void main() {
  test(
    'project repository returns seeded projects in priority-first order',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await SeedDataService(database).ensureSeedData();

      final projects = await ProjectRepository(database).getProjects();

      expect(projects, hasLength(9));
      expect(projects.first.priority, 'High');
      expect(
        projects.map((project) => project.name),
        containsAll([
          'MicroGrow',
          'MicroGrow Field Scanner',
          'New Earth Website',
          'Future Ideas',
        ]),
      );
    },
  );
}
