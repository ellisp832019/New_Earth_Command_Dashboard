import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/inbox/application/inbox_controller.dart';
import 'package:new_earth_command_dashboard/features/inbox/data/inbox_repository.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';
import 'package:new_earth_command_dashboard/features/tasks/data/task_repository.dart';

void main() {
  test(
    'inbox actions controller converts an inbox item to a task and processes it',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final projectRepository = ProjectRepository(database);
      final inboxRepository = InboxRepository(database);
      final taskRepository = TaskRepository(database);

      final project = await projectRepository.createProject(
        name: 'Inbox Conversion Project',
        status: 'Active',
        priority: 'High',
        progressPercentage: 5,
      );

      final inboxItem = await inboxRepository.createItem(
        title: 'Review dashboard notes',
        body: 'Could become a task after the next triage pass.',
        type: 'Task',
        projectId: project.projectId,
      );

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) => database),
          databaseReadyProvider.overrideWith((ref) async {}),
        ],
      );
      addTearDown(container.dispose);

      final initialInboxItems = await container.read(inboxItemsProvider.future);
      expect(initialInboxItems, hasLength(1));

      await container
          .read(inboxActionsControllerProvider)
          .convertToTask(inboxItem.inboxItemId);

      final refreshedInboxItems = await container.read(
        inboxItemsProvider.future,
      );
      final tasks = await taskRepository.getActiveTasks();
      final processedItem = await inboxRepository.getById(
        inboxItem.inboxItemId,
      );

      expect(refreshedInboxItems, isEmpty);
      expect(tasks, hasLength(1));
      expect(tasks.single.title, 'Review dashboard notes');
      expect(tasks.single.projectId, project.projectId);
      expect(
        tasks.single.description,
        'Could become a task after the next triage pass.',
      );
      expect(processedItem.status, 'Processed');
      expect(processedItem.convertedToType, 'Task');
      expect(processedItem.convertedToId, tasks.single.taskId);
    },
  );

  test(
    'inbox actions controller parks an item without removing it from inbox',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final inboxRepository = InboxRepository(database);

      final inboxItem = await inboxRepository.createItem(
        title: 'Maybe later',
        body: 'Keep this for a calmer review.',
      );

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) => database),
          databaseReadyProvider.overrideWith((ref) async {}),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(inboxActionsControllerProvider)
          .parkItem(inboxItem.inboxItemId);

      final inboxItems = await container.read(inboxItemsProvider.future);
      final parkedItem = await inboxRepository.getById(inboxItem.inboxItemId);

      expect(inboxItems, hasLength(1));
      expect(inboxItems.single.item.status, 'Parked');
      expect(parkedItem.status, 'Parked');
      expect(parkedItem.convertedToType, isNull);
      expect(parkedItem.convertedToId, isNull);
    },
  );
}
