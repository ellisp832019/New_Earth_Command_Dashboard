import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class LearningListItem {
  const LearningListItem({required this.item, this.projectName});

  final LearningItem item;
  final String? projectName;
}

class LearningRepository {
  LearningRepository(this._database, {Uuid? uuid, DateTime Function()? now})
    : _uuid = uuid ?? const Uuid(),
      _now = now ?? DateTime.now;

  final AppDatabase _database;
  final Uuid _uuid;
  final DateTime Function() _now;

  Future<List<LearningListItem>> getItems() async {
    final items =
        await (_database.select(_database.learningItems)
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
          (item) => LearningListItem(
            item: item,
            projectName: item.projectId == null
                ? null
                : projectNames[item.projectId],
          ),
        )
        .toList();
  }

  Future<LearningItem> createItem({
    required String topic,
    String? projectId,
    String? reasonForLearning,
    String? resourceLink,
    String status = 'To Learn',
    String? notes,
    String? nextStep,
    String? skillConfidence,
  }) async {
    final timestamp = _now();
    final learningItemId = 'learning-${_uuid.v4()}';

    await _database
        .into(_database.learningItems)
        .insert(
          LearningItemsCompanion.insert(
            learningItemId: learningItemId,
            topic: topic.trim(),
            projectId: Value(projectId),
            reasonForLearning: Value(_normalizeText(reasonForLearning)),
            resourceLink: Value(_normalizeText(resourceLink)),
            status: Value(status),
            notes: Value(_normalizeText(notes)),
            nextStep: Value(_normalizeText(nextStep)),
            skillConfidence: Value(_normalizeText(skillConfidence)),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );

    return getById(learningItemId);
  }

  Future<LearningItem> getById(String learningItemId) {
    return (_database.select(_database.learningItems)
          ..where((table) => table.learningItemId.equals(learningItemId)))
        .getSingle();
  }

  String? _normalizeText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
