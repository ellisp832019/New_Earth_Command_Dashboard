import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/content/data/content_repository.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';

void main() {
  test('content repository creates and loads linked content items', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final projectRepository = ProjectRepository(database);
    final contentRepository = ContentRepository(database);
    final project = await projectRepository.createProject(
      name: 'Content Project',
      status: 'Active',
      priority: 'High',
      progressPercentage: 12,
    );

    final createdItem = await contentRepository.createItem(
      title: 'Building the New Earth Command Dashboard',
      projectId: project.projectId,
      platform: 'LinkedIn',
      contentType: 'Project Update',
      status: 'Drafting',
      draftText: 'A short build-in-public update.',
      imageNeeded: true,
      imagePrompt: 'A focused dashboard workspace at night.',
      notes: 'Keep the first post practical and grounded.',
    );
    final items = await contentRepository.getItems();

    expect(createdItem.title, 'Building the New Earth Command Dashboard');
    expect(items, hasLength(1));
    expect(items.first.item.title, 'Building the New Earth Command Dashboard');
    expect(items.first.item.platform, 'LinkedIn');
    expect(items.first.item.contentType, 'Project Update');
    expect(items.first.item.status, 'Drafting');
    expect(items.first.item.imageNeeded, isTrue);
    expect(items.first.projectName, 'Content Project');
  });
}
