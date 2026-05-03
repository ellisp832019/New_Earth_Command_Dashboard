import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class JournalListEntry {
  const JournalListEntry({
    required this.entry,
    this.projectName,
    this.taskTitle,
  });

  final JournalEntry entry;
  final String? projectName;
  final String? taskTitle;

  String? get preview {
    final candidates = [
      entry.whatIWorkedOn,
      entry.whatILearned,
      entry.nextActions,
    ];

    for (final candidate in candidates) {
      final trimmed = candidate?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return null;
  }
}

class JournalRepository {
  JournalRepository(this._database, {Uuid? uuid, DateTime Function()? now})
    : _uuid = uuid ?? const Uuid(),
      _now = now ?? DateTime.now;

  final AppDatabase _database;
  final Uuid _uuid;
  final DateTime Function() _now;

  Future<List<JournalListEntry>> getEntries() async {
    final entries =
        await (_database.select(_database.journalEntries)
              ..where((table) => table.isArchived.equals(false))
              ..orderBy([
                (table) => OrderingTerm.desc(table.date),
                (table) => OrderingTerm.desc(table.createdAt),
              ]))
            .get();

    if (entries.isEmpty) {
      return const [];
    }

    final projectIds = entries
        .map((entry) => entry.projectId)
        .whereType<String>()
        .toSet()
        .toList();
    final taskIds = entries
        .map((entry) => entry.taskId)
        .whereType<String>()
        .toSet()
        .toList();

    final projects = projectIds.isEmpty
        ? const <Project>[]
        : await (_database.select(
            _database.projects,
          )..where((table) => table.projectId.isIn(projectIds))).get();
    final tasks = taskIds.isEmpty
        ? const <Task>[]
        : await (_database.select(
            _database.tasks,
          )..where((table) => table.taskId.isIn(taskIds))).get();

    final projectNames = {
      for (final project in projects) project.projectId: project.name,
    };
    final taskTitles = {for (final task in tasks) task.taskId: task.title};

    return entries
        .map(
          (entry) => JournalListEntry(
            entry: entry,
            projectName: entry.projectId == null
                ? null
                : projectNames[entry.projectId],
            taskTitle: entry.taskId == null ? null : taskTitles[entry.taskId],
          ),
        )
        .toList();
  }

  Future<JournalEntry> createEntry({
    required DateTime date,
    required String title,
    String? projectId,
    String? taskId,
    String? category,
    String? whatIWorkedOn,
    String? whatILearned,
    String? nextActions,
  }) async {
    final timestamp = _now();
    final journalEntryId = 'journal-${_uuid.v4()}';

    await _database
        .into(_database.journalEntries)
        .insert(
          JournalEntriesCompanion.insert(
            journalEntryId: journalEntryId,
            date: _dateOnly(date),
            title: title.trim(),
            projectId: Value(projectId),
            taskId: Value(taskId),
            category: Value(_normalizeText(category)),
            whatIWorkedOn: Value(_normalizeText(whatIWorkedOn)),
            whatILearned: Value(_normalizeText(whatILearned)),
            nextActions: Value(_normalizeText(nextActions)),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );

    return getById(journalEntryId);
  }

  Future<JournalEntry> updateEntry({
    required String journalEntryId,
    required DateTime date,
    required String title,
    String? projectId,
    String? taskId,
    String? category,
    String? whatIWorkedOn,
    String? whatILearned,
    String? nextActions,
  }) async {
    await (_database.update(
      _database.journalEntries,
    )..where((table) => table.journalEntryId.equals(journalEntryId))).write(
      JournalEntriesCompanion(
        date: Value(_dateOnly(date)),
        title: Value(title.trim()),
        projectId: Value(projectId),
        taskId: Value(taskId),
        category: Value(_normalizeText(category)),
        whatIWorkedOn: Value(_normalizeText(whatIWorkedOn)),
        whatILearned: Value(_normalizeText(whatILearned)),
        nextActions: Value(_normalizeText(nextActions)),
        updatedAt: Value(_now()),
      ),
    );

    return getById(journalEntryId);
  }

  Future<JournalEntry> getById(String journalEntryId) {
    return (_database.select(_database.journalEntries)
          ..where((table) => table.journalEntryId.equals(journalEntryId)))
        .getSingle();
  }

  String? _normalizeText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
