import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/inbox/data/inbox_repository.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';

void main() {
  test('inbox repository creates and loads linked items', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final projectRepository = ProjectRepository(database);
    final inboxRepository = InboxRepository(database);
    final project = await projectRepository.createProject(
      name: 'Inbox Project',
      status: 'Active',
      priority: 'Medium',
      progressPercentage: 3,
    );

    final createdItem = await inboxRepository.createItem(
      title: 'Check Flutter navigation package',
      body: 'Might help the next polish pass.',
      type: 'Learning Note',
      projectId: project.projectId,
      status: 'New',
    );
    final items = await inboxRepository.getItems();

    expect(createdItem.title, 'Check Flutter navigation package');
    expect(items, hasLength(1));
    expect(items.first.item.title, 'Check Flutter navigation package');
    expect(items.first.item.body, 'Might help the next polish pass.');
    expect(items.first.item.type, 'Learning Note');
    expect(items.first.item.status, 'New');
    expect(items.first.projectName, 'Inbox Project');
  });
}
