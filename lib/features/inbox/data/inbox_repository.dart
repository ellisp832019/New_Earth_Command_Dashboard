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
              ..where((table) => table.isArchived.equals(false))
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

  String? _normalizeText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
