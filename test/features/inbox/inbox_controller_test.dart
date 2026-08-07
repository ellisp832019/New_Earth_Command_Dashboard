import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/business/data/business_repository.dart';
import 'package:new_earth_command_dashboard/features/content/data/content_repository.dart';
import 'package:new_earth_command_dashboard/features/inbox/application/inbox_controller.dart';
import 'package:new_earth_command_dashboard/features/inbox/data/inbox_repository.dart';
import 'package:new_earth_command_dashboard/features/journal/data/journal_repository.dart';
import 'package:new_earth_command_dashboard/features/learning/data/learning_repository.dart';
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
    'inbox actions controller converts an inbox item to a journal entry and processes it',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final projectRepository = ProjectRepository(database);
      final inboxRepository = InboxRepository(database);
      final journalRepository = JournalRepository(database);

      final project = await projectRepository.createProject(
        name: 'Inbox Journal Project',
        status: 'Active',
        priority: 'Medium',
        progressPercentage: 12,
      );

      final inboxItem = await inboxRepository.createItem(
        title: 'Reflect on the calmer dashboard pass',
        body: 'This might become a journal note after triage.',
        type: 'Journal Note',
        projectId: project.projectId,
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
          .convertToJournalEntry(inboxItem.inboxItemId);

      final refreshedInboxItems = await container.read(
        inboxItemsProvider.future,
      );
      final journalEntries = await journalRepository.getEntries();
      final processedItem = await inboxRepository.getById(
        inboxItem.inboxItemId,
      );

      expect(refreshedInboxItems, isEmpty);
      expect(journalEntries, hasLength(1));
      expect(
        journalEntries.single.entry.title,
        'Reflect on the calmer dashboard pass',
      );
      expect(journalEntries.single.entry.projectId, project.projectId);
      expect(
        journalEntries.single.entry.whatIWorkedOn,
        'This might become a journal note after triage.',
      );
      expect(journalEntries.single.entry.category, 'Reflection');
      expect(processedItem.status, 'Processed');
      expect(processedItem.convertedToType, 'JournalEntry');
      expect(
        processedItem.convertedToId,
        journalEntries.single.entry.journalEntryId,
      );
    },
  );

  test(
    'inbox actions controller converts an inbox item to a content idea and processes it',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final projectRepository = ProjectRepository(database);
      final inboxRepository = InboxRepository(database);
      final contentRepository = ContentRepository(database);

      final project = await projectRepository.createProject(
        name: 'Inbox Content Project',
        status: 'Active',
        priority: 'Medium',
        progressPercentage: 8,
      );

      final inboxItem = await inboxRepository.createItem(
        title: 'Draft a softer dashboard update',
        body: 'This should become a content idea after triage.',
        type: 'Content Idea',
        projectId: project.projectId,
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
          .convertToContentItem(inboxItem.inboxItemId);

      final refreshedInboxItems = await container.read(
        inboxItemsProvider.future,
      );
      final contentItems = await contentRepository.getItems();
      final processedItem = await inboxRepository.getById(
        inboxItem.inboxItemId,
      );

      expect(refreshedInboxItems, isEmpty);
      expect(contentItems, hasLength(1));
      expect(contentItems.single.item.title, 'Draft a softer dashboard update');
      expect(contentItems.single.item.projectId, project.projectId);
      expect(
        contentItems.single.item.draftText,
        'This should become a content idea after triage.',
      );
      expect(contentItems.single.item.status, 'Idea');
      expect(processedItem.status, 'Processed');
      expect(processedItem.convertedToType, 'ContentItem');
      expect(
        processedItem.convertedToId,
        contentItems.single.item.contentItemId,
      );
    },
  );

  test(
    'inbox actions controller converts an inbox item to a learning item and processes it',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final projectRepository = ProjectRepository(database);
      final inboxRepository = InboxRepository(database);
      final learningRepository = LearningRepository(database);

      final project = await projectRepository.createProject(
        name: 'Inbox Learning Project',
        status: 'Active',
        priority: 'Medium',
        progressPercentage: 10,
      );

      final inboxItem = await inboxRepository.createItem(
        title: 'Learn the calmer inbox flow',
        body: 'This should become a learning item after triage.',
        type: 'Learning Note',
        projectId: project.projectId,
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
          .convertToLearningItem(inboxItem.inboxItemId);

      final refreshedInboxItems = await container.read(
        inboxItemsProvider.future,
      );
      final learningItems = await learningRepository.getItems();
      final processedItem = await inboxRepository.getById(
        inboxItem.inboxItemId,
      );

      expect(refreshedInboxItems, isEmpty);
      expect(learningItems, hasLength(1));
      expect(learningItems.single.item.topic, 'Learn the calmer inbox flow');
      expect(learningItems.single.item.projectId, project.projectId);
      expect(
        learningItems.single.item.reasonForLearning,
        'This should become a learning item after triage.',
      );
      expect(learningItems.single.item.status, 'To Learn');
      expect(processedItem.status, 'Processed');
      expect(processedItem.convertedToType, 'LearningItem');
      expect(
        processedItem.convertedToId,
        learningItems.single.item.learningItemId,
      );
    },
  );

  test(
    'inbox actions controller converts an inbox item to a business opportunity and processes it',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final projectRepository = ProjectRepository(database);
      final inboxRepository = InboxRepository(database);
      final businessRepository = BusinessRepository(database);

      final project = await projectRepository.createProject(
        name: 'Inbox Business Project',
        status: 'Active',
        priority: 'High',
        progressPercentage: 14,
      );

      final inboxItem = await inboxRepository.createItem(
        title: 'Research a calmer support workflow',
        body: 'This could become a business opportunity after triage.',
        type: 'Business Opportunity',
        projectId: project.projectId,
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
          .convertToBusinessOpportunity(inboxItem.inboxItemId);

      final refreshedInboxItems = await container.read(
        inboxItemsProvider.future,
      );
      final businessItems = await businessRepository.getItems();
      final processedItem = await inboxRepository.getById(
        inboxItem.inboxItemId,
      );

      expect(refreshedInboxItems, isEmpty);
      expect(businessItems, hasLength(1));
      expect(
        businessItems.single.item.name,
        'Research a calmer support workflow',
      );
      expect(businessItems.single.item.projectId, project.projectId);
      expect(
        businessItems.single.item.notes,
        'This could become a business opportunity after triage.',
      );
      expect(businessItems.single.item.status, 'Researching');
      expect(processedItem.status, 'Processed');
      expect(processedItem.convertedToType, 'BusinessOpportunity');
      expect(
        processedItem.convertedToId,
        businessItems.single.item.businessOpportunityId,
      );
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

  test(
    'inbox actions controller can return a parked item to the new queue',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final inboxRepository = InboxRepository(database);

      final inboxItem = await inboxRepository.createItem(
        title: 'Bring this back',
        body: 'This belongs back in the active queue.',
        status: 'Parked',
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
          .returnToNewQueue(inboxItem.inboxItemId);

      final inboxItems = await container.read(inboxItemsProvider.future);
      final refreshedItem = await inboxRepository.getById(
        inboxItem.inboxItemId,
      );

      expect(inboxItems, hasLength(1));
      expect(inboxItems.single.item.status, 'New');
      expect(refreshedItem.status, 'New');
    },
  );
}
