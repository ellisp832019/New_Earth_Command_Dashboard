import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class ContentListItem {
  const ContentListItem({required this.item, this.projectName});

  final ContentItem item;
  final String? projectName;
}

class ContentRepository {
  ContentRepository(this._database, {Uuid? uuid, DateTime Function()? now})
    : _uuid = uuid ?? const Uuid(),
      _now = now ?? DateTime.now;

  final AppDatabase _database;
  final Uuid _uuid;
  final DateTime Function() _now;

  Future<List<ContentListItem>> getItems() async {
    final items =
        await (_database.select(_database.contentItems)
              ..where((table) => table.isArchived.equals(false))
              ..orderBy([
                (table) => OrderingTerm.desc(table.updatedAt),
                (table) => OrderingTerm.desc(table.createdAt),
              ]))
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
          (item) => ContentListItem(
            item: item,
            projectName: item.projectId == null
                ? null
                : projectNames[item.projectId],
          ),
        )
        .toList();
  }

  Future<ContentItem> createItem({
    required String title,
    String? projectId,
    String? platform,
    String? contentType,
    String status = 'Idea',
    String? draftText,
    bool imageNeeded = false,
    String? imagePrompt,
    String? notes,
  }) async {
    final timestamp = _now();
    final contentItemId = 'content-${_uuid.v4()}';

    await _database
        .into(_database.contentItems)
        .insert(
          ContentItemsCompanion.insert(
            contentItemId: contentItemId,
            title: title.trim(),
            projectId: Value(projectId),
            platform: Value(_normalizeText(platform)),
            contentType: Value(_normalizeText(contentType)),
            status: Value(status),
            draftText: Value(_normalizeText(draftText)),
            imageNeeded: Value(imageNeeded),
            imagePrompt: Value(_normalizeText(imagePrompt)),
            notes: Value(_normalizeText(notes)),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );

    return getById(contentItemId);
  }

  Future<ContentItem> updateItem({
    required String contentItemId,
    required String title,
    String? projectId,
    String? platform,
    String? contentType,
    String status = 'Idea',
    String? draftText,
    bool imageNeeded = false,
    String? imagePrompt,
    String? notes,
  }) async {
    await (_database.update(
      _database.contentItems,
    )..where((table) => table.contentItemId.equals(contentItemId))).write(
      ContentItemsCompanion(
        title: Value(title.trim()),
        projectId: Value(projectId),
        platform: Value(_normalizeText(platform)),
        contentType: Value(_normalizeText(contentType)),
        status: Value(status),
        draftText: Value(_normalizeText(draftText)),
        imageNeeded: Value(imageNeeded),
        imagePrompt: Value(_normalizeText(imagePrompt)),
        notes: Value(_normalizeText(notes)),
        updatedAt: Value(_now()),
      ),
    );

    return getById(contentItemId);
  }

  Future<ContentItem> getById(String contentItemId) {
    return (_database.select(
      _database.contentItems,
    )..where((table) => table.contentItemId.equals(contentItemId))).getSingle();
  }

  String? _normalizeText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
