import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../business/application/business_controller.dart';
import '../../content/application/content_controller.dart';
import '../../dashboard/application/dashboard_controller.dart';
import '../../journal/application/journal_controller.dart';
import '../../learning/application/learning_controller.dart';
import '../../projects/application/projects_controller.dart';
import '../../tasks/application/tasks_controller.dart';
import '../data/inbox_repository.dart';

final inboxRepositoryProvider = Provider<InboxRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return InboxRepository(database);
});

final inboxItemsProvider = FutureProvider<List<InboxListItem>>((ref) async {
  await ref.watch(databaseReadyProvider.future);
  return ref.watch(inboxRepositoryProvider).getItems();
});

final inboxRecentlyProcessedProvider = FutureProvider<List<InboxListItem>>((
  ref,
) async {
  await ref.watch(databaseReadyProvider.future);
  return ref.watch(inboxRepositoryProvider).getRecentlyProcessedItems();
});

final inboxActionsControllerProvider = Provider<InboxActionsController>((ref) {
  return InboxActionsController(ref);
});

class InboxActionsController {
  InboxActionsController(this._ref);

  final Ref _ref;

  Future<InboxItem> createItem({
    String? title,
    String? body,
    String? type,
    String? projectId,
    String status = 'New',
  }) async {
    final item = await _ref
        .read(inboxRepositoryProvider)
        .createItem(
          title: title,
          body: body,
          type: type,
          projectId: projectId,
          status: status,
        );

    _ref.invalidate(inboxItemsProvider);
    return item;
  }

  Future<InboxItem> parkItem(String inboxItemId) async {
    final item = await _ref.read(inboxRepositoryProvider).parkItem(inboxItemId);
    _refreshInboxViews();
    return item;
  }

  Future<InboxItem> returnToNewQueue(String inboxItemId) async {
    final item = await _ref
        .read(inboxRepositoryProvider)
        .returnToNewQueue(inboxItemId);
    _refreshInboxViews();
    return item;
  }

  Future<Task> convertToTask(String inboxItemId) async {
    final inboxItem = await _ref
        .read(inboxRepositoryProvider)
        .getById(inboxItemId);
    final title = _captureTitle(inboxItem);
    final task = await _ref
        .read(tasksControllerProvider)
        .createTask(
          title: title,
          projectId: inboxItem.projectId,
          description: _captureBody(inboxItem),
          category: _taskCategoryForInboxType(inboxItem.type),
          priority: 'Medium',
          status: 'Inbox',
          notes: _conversionNotes(inboxItem),
        );

    await _ref
        .read(inboxRepositoryProvider)
        .markProcessed(
          inboxItemId: inboxItemId,
          convertedToType: 'Task',
          convertedToId: task.taskId,
        );
    _refreshInboxViews(projectId: inboxItem.projectId);
    _ref.invalidate(taskProvider(task.taskId));
    return task;
  }

  Future<JournalEntry> convertToJournalEntry(String inboxItemId) async {
    final inboxItem = await _ref
        .read(inboxRepositoryProvider)
        .getById(inboxItemId);
    final title = _captureTitle(inboxItem);
    final entry = await _ref
        .read(journalActionsControllerProvider)
        .createEntry(
          date: DateTime.now(),
          title: title,
          projectId: inboxItem.projectId,
          category: _journalCategoryForInboxType(inboxItem.type),
          whatIWorkedOn: _captureBody(inboxItem),
          nextActions: _conversionNotes(inboxItem),
        );

    await _ref
        .read(inboxRepositoryProvider)
        .markProcessed(
          inboxItemId: inboxItemId,
          convertedToType: 'JournalEntry',
          convertedToId: entry.journalEntryId,
        );
    _refreshInboxViews(projectId: inboxItem.projectId);
    _ref.invalidate(journalEntryProvider(entry.journalEntryId));
    return entry;
  }

  Future<ContentItem> convertToContentItem(String inboxItemId) async {
    final inboxItem = await _ref
        .read(inboxRepositoryProvider)
        .getById(inboxItemId);
    final item = await _ref
        .read(contentActionsControllerProvider)
        .createItem(
          title: _captureTitle(inboxItem),
          projectId: inboxItem.projectId,
          status: 'Idea',
          draftText: _captureBody(inboxItem),
          notes: _conversionNotes(inboxItem),
        );

    await _ref
        .read(inboxRepositoryProvider)
        .markProcessed(
          inboxItemId: inboxItemId,
          convertedToType: 'ContentItem',
          convertedToId: item.contentItemId,
        );
    _refreshInboxViews(projectId: inboxItem.projectId);
    _ref.invalidate(contentItemProvider(item.contentItemId));
    return item;
  }

  Future<LearningItem> convertToLearningItem(String inboxItemId) async {
    final inboxItem = await _ref
        .read(inboxRepositoryProvider)
        .getById(inboxItemId);
    final item = await _ref
        .read(learningActionsControllerProvider)
        .createItem(
          topic: _captureTitle(inboxItem),
          projectId: inboxItem.projectId,
          status: 'To Learn',
          reasonForLearning: _captureBody(inboxItem),
          notes: _conversionNotes(inboxItem),
        );

    await _ref
        .read(inboxRepositoryProvider)
        .markProcessed(
          inboxItemId: inboxItemId,
          convertedToType: 'LearningItem',
          convertedToId: item.learningItemId,
        );
    _refreshInboxViews(projectId: inboxItem.projectId);
    _ref.invalidate(learningItemProvider(item.learningItemId));
    return item;
  }

  Future<BusinessOpportunity> convertToBusinessOpportunity(
    String inboxItemId,
  ) async {
    final inboxItem = await _ref
        .read(inboxRepositoryProvider)
        .getById(inboxItemId);
    final item = await _ref
        .read(businessActionsControllerProvider)
        .createItem(
          name: _captureTitle(inboxItem),
          projectId: inboxItem.projectId,
          status: 'Researching',
          notes: _captureBody(inboxItem) ?? _conversionNotes(inboxItem),
        );

    await _ref
        .read(inboxRepositoryProvider)
        .markProcessed(
          inboxItemId: inboxItemId,
          convertedToType: 'BusinessOpportunity',
          convertedToId: item.businessOpportunityId,
        );
    _refreshInboxViews(projectId: inboxItem.projectId);
    _ref.invalidate(businessItemProvider(item.businessOpportunityId));
    return item;
  }

  String _captureTitle(InboxItem item) {
    final title = item.title?.trim();
    if (title != null && title.isNotEmpty) {
      return title;
    }

    final body = item.body?.trim();
    if (body != null && body.isNotEmpty) {
      final firstLine = body.split('\n').first.trim();
      if (firstLine.isNotEmpty) {
        return firstLine;
      }
    }

    return 'Inbox Capture';
  }

  String? _captureBody(InboxItem item) {
    final body = item.body?.trim();
    if (body == null || body.isEmpty) {
      return null;
    }

    return body;
  }

  String _conversionNotes(InboxItem item) {
    final parts = <String>['Converted from Inbox item ${item.inboxItemId}.'];
    final type = item.type?.trim();
    if (type != null && type.isNotEmpty) {
      parts.add('Original type: $type.');
    }

    return parts.join(' ');
  }

  String? _taskCategoryForInboxType(String? type) {
    switch (type?.trim()) {
      case 'Learning Note':
        return 'Learning';
      case 'Content Idea':
        return 'Content';
      case 'Business Opportunity':
        return 'Business';
      case 'Journal Note':
        return 'Admin';
      case 'Future Idea':
      case 'Idea':
        return 'Research';
      case 'Task':
        return 'Build';
      default:
        return null;
    }
  }

  String? _journalCategoryForInboxType(String? type) {
    switch (type?.trim()) {
      case 'Learning Note':
        return 'Learning Note';
      case 'Content Idea':
        return 'Content Seed';
      case 'Business Opportunity':
        return 'Project Update';
      case 'Task':
        return 'Build Log';
      case 'Future Idea':
      case 'Idea':
        return 'Reflection';
      case 'Journal Note':
        return 'Reflection';
      default:
        return 'Reflection';
    }
  }

  void _refreshInboxViews({String? projectId}) {
    _ref.invalidate(inboxItemsProvider);
    _ref.invalidate(inboxRecentlyProcessedProvider);
    _ref.invalidate(dashboardSnapshotProvider);
    if (projectId != null) {
      _ref.invalidate(projectDetailProvider(projectId));
    }
  }
}
