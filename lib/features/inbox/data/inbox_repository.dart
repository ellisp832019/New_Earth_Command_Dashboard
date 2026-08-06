import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class InboxListItem {
  const InboxListItem({required this.item, this.projectName});

  final InboxItem item;
  final String? projectName;
}

class InboxRepository {
  InboxRepository(this._database, {Uuid? uuid, DateTime Function()? now})
    : _uuid = uuid ?? const Uuid(),
      _now = now ?? DateTime.now;

  final AppDatabase _database;
  final Uuid _uuid;
  final DateTime Function() _now;

  Future<List<InboxListItem>> getItems() async {
    final items =
        await (_database.select(_database.inboxItems)
              ..where(
                (table) =>
                    table.isArchived.equals(false) &
                    table.status.isIn(const ['New', 'Parked']),
              )
              ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
            .get();

    if (items.isEmpty) {
      return const [];
    }

    final projectIds = items
        .map((item) => item.projectId)
        .whereType<String>()
        .toSet()
        .toList();

    final projects = projectIds.isEmpty
        ? const <Project>[]
        : await (_database.select(
            _database.projects,
          )..where((table) => table.projectId.isIn(projectIds))).get();

    final projectNames = {
      for (final project in projects) project.projectId: project.name,
    };

    return items
        .map(
          (item) => InboxListItem(
            item: item,
            projectName: item.projectId == null
                ? null
                : projectNames[item.projectId],
          ),
        )
        .toList();
  }

  Future<List<InboxListItem>> getRecentlyProcessedItems({int limit = 3}) async {
    final items =
        await (_database.select(_database.inboxItems)
              ..where(
                (table) =>
                    table.isArchived.equals(false) &
                    table.status.equals('Processed'),
              )
              ..orderBy([(table) => OrderingTerm.desc(table.processedAt)])
              ..limit(limit))
            .get();

    if (items.isEmpty) {
      return const [];
    }

    final projectIds = items
        .map((item) => item.projectId)
        .whereType<String>()
        .toSet()
        .toList();

    final projects = projectIds.isEmpty
        ? const <Project>[]
        : await (_database.select(
            _database.projects,
          )..where((table) => table.projectId.isIn(projectIds))).get();

    final projectNames = {
      for (final project in projects) project.projectId: project.name,
    };

    return items
        .map(
          (item) => InboxListItem(
            item: item,
            projectName: item.projectId == null
                ? null
                : projectNames[item.projectId],
          ),
        )
        .toList();
  }

  Future<InboxItem> createItem({
    String? title,
    String? body,
    String? type,
    String? projectId,
    String status = 'New',
  }) async {
    final timestamp = _now();
    final inboxItemId = 'inbox-${_uuid.v4()}';

    await _database
        .into(_database.inboxItems)
        .insert(
          InboxItemsCompanion.insert(
            inboxItemId: inboxItemId,
            title: Value(_normalizeText(title)),
            body: Value(_normalizeText(body)),
            type: Value(_normalizeText(type)),
            projectId: Value(projectId),
            status: Value(status),
            createdAt: timestamp,
          ),
        );

    return getById(inboxItemId);
  }

  Future<InboxItem> getById(String inboxItemId) {
    return (_database.select(
      _database.inboxItems,
    )..where((table) => table.inboxItemId.equals(inboxItemId))).getSingle();
  }

  Future<InboxItem> updateItem({
    required String inboxItemId,
    String? title,
    String? body,
    String? type,
    String? projectId,
    String? status,
    DateTime? processedAt,
    String? convertedToType,
    String? convertedToId,
    bool? isArchived,
  }) async {
    await (_database.update(
      _database.inboxItems,
    )..where((table) => table.inboxItemId.equals(inboxItemId))).write(
      InboxItemsCompanion(
        title: title == null
            ? const Value.absent()
            : Value(_normalizeText(title)),
        body: body == null ? const Value.absent() : Value(_normalizeText(body)),
        type: type == null ? const Value.absent() : Value(_normalizeText(type)),
        projectId: projectId == null ? const Value.absent() : Value(projectId),
        status: status == null ? const Value.absent() : Value(status),
        processedAt: processedAt == null
            ? const Value.absent()
            : Value(processedAt),
        convertedToType: convertedToType == null
            ? const Value.absent()
            : Value(_normalizeText(convertedToType)),
        convertedToId: convertedToId == null
            ? const Value.absent()
            : Value(convertedToId),
        isArchived: isArchived == null
            ? const Value.absent()
            : Value(isArchived),
      ),
    );

    return getById(inboxItemId);
  }

  Future<InboxItem> markProcessed({
    required String inboxItemId,
    required String convertedToType,
    required String convertedToId,
  }) {
    return updateItem(
      inboxItemId: inboxItemId,
      status: 'Processed',
      processedAt: _now(),
      convertedToType: convertedToType,
      convertedToId: convertedToId,
    );
  }

  Future<InboxItem> parkItem(String inboxItemId) {
    return updateItem(inboxItemId: inboxItemId, status: 'Parked');
  }

  Future<InboxItem> returnToNewQueue(String inboxItemId) {
    return updateItem(inboxItemId: inboxItemId, status: 'New');
  }

  String? _normalizeText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
