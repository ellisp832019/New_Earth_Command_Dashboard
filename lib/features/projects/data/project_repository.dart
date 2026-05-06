import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class ProjectDetailSnapshot {
  const ProjectDetailSnapshot({
    required this.project,
    required this.activeTasks,
    required this.blockedTasks,
    required this.recentJournalEntries,
    required this.recentLearningItems,
    required this.recentContentItems,
    required this.recentBusinessOpportunities,
    required this.journalEntryCount,
    required this.learningItemCount,
    required this.contentItemCount,
    required this.businessOpportunityCount,
  });

  final Project project;
  final List<Task> activeTasks;
  final List<Task> blockedTasks;
  final List<ProjectLinkedJournalEntry> recentJournalEntries;
  final List<ProjectLinkedLearningItem> recentLearningItems;
  final List<ProjectLinkedContentItem> recentContentItems;
  final List<ProjectLinkedBusinessOpportunity> recentBusinessOpportunities;
  final int journalEntryCount;
  final int learningItemCount;
  final int contentItemCount;
  final int businessOpportunityCount;
}

class ProjectLinkedJournalEntry {
  const ProjectLinkedJournalEntry({
    required this.journalEntryId,
    required this.date,
    required this.title,
    this.category,
    this.preview,
  });

  final String journalEntryId;
  final DateTime date;
  final String title;
  final String? category;
  final String? preview;
}

class ProjectLinkedLearningItem {
  const ProjectLinkedLearningItem({
    required this.learningItemId,
    required this.topic,
    required this.status,
    this.nextStep,
  });

  final String learningItemId;
  final String topic;
  final String status;
  final String? nextStep;
}

class ProjectLinkedContentItem {
  const ProjectLinkedContentItem({
    required this.contentItemId,
    required this.title,
    required this.status,
    this.platform,
    this.preview,
  });

  final String contentItemId;
  final String title;
  final String status;
  final String? platform;
  final String? preview;
}

class ProjectLinkedBusinessOpportunity {
  const ProjectLinkedBusinessOpportunity({
    required this.businessOpportunityId,
    required this.name,
    required this.status,
    this.type,
    this.nextAction,
  });

  final String businessOpportunityId;
  final String name;
  final String status;
  final String? type;
  final String? nextAction;
}

class ProjectRepository {
  ProjectRepository(this._database, {Uuid? uuid, DateTime Function()? now})
    : _uuid = uuid ?? const Uuid(),
      _now = now ?? DateTime.now;

  final AppDatabase _database;
  final Uuid _uuid;
  final DateTime Function() _now;

  Future<List<Project>> getProjects() async {
    final projects =
        await (_database.select(_database.projects)
              ..where((table) => table.isArchived.equals(false))
              ..orderBy([(table) => OrderingTerm.asc(table.name)]))
            .get();

    projects.sort((left, right) {
      final priorityCompare = _priorityRank(
        left.priority,
      ).compareTo(_priorityRank(right.priority));
      if (priorityCompare != 0) {
        return priorityCompare;
      }

      return left.name.compareTo(right.name);
    });

    return projects;
  }

  Future<Project> getProject(String projectId) {
    return (_database.select(
      _database.projects,
    )..where((table) => table.projectId.equals(projectId))).getSingle();
  }

  Future<ProjectDetailSnapshot> getProjectDetail(String projectId) async {
    final project = await getProject(projectId);
    final tasks =
        await (_database.select(_database.tasks)
              ..where(
                (table) =>
                    table.projectId.equals(projectId) &
                    table.isArchived.equals(false),
              )
              ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
            .get();

    final activeTasks = tasks
        .where(
          (task) =>
              task.status != 'Done' &&
              task.status != 'Parked' &&
              task.status != 'Blocked',
        )
        .toList();
    final blockedTasks = tasks
        .where((task) => task.status == 'Blocked')
        .toList();

    final journalEntries =
        await (_database.select(_database.journalEntries)
              ..where(
                (table) =>
                    table.projectId.equals(projectId) &
                    table.isArchived.equals(false),
              )
              ..orderBy([
                (table) => OrderingTerm.desc(table.date),
                (table) => OrderingTerm.desc(table.createdAt),
              ]))
            .get();
    final recentJournalEntries = journalEntries
        .take(3)
        .map(
          (entry) => ProjectLinkedJournalEntry(
            journalEntryId: entry.journalEntryId,
            date: entry.date,
            title: entry.title,
            category: entry.category,
            preview: _journalPreview(entry),
          ),
        )
        .toList();
    final journalEntryCount = journalEntries.length;
    final learningItems =
        await (_database.select(_database.learningItems)
              ..where(
                (table) =>
                    table.projectId.equals(projectId) &
                    table.isArchived.equals(false),
              )
              ..orderBy([
                (table) => OrderingTerm.desc(table.updatedAt),
                (table) => OrderingTerm.desc(table.createdAt),
              ]))
            .get();
    final contentItems =
        await (_database.select(_database.contentItems)
              ..where(
                (table) =>
                    table.projectId.equals(projectId) &
                    table.isArchived.equals(false),
              )
              ..orderBy([
                (table) => OrderingTerm.desc(table.updatedAt),
                (table) => OrderingTerm.desc(table.createdAt),
              ]))
            .get();
    final businessOpportunities =
        await (_database.select(_database.businessOpportunities)
              ..where(
                (table) =>
                    table.projectId.equals(projectId) &
                    table.isArchived.equals(false),
              )
              ..orderBy([
                (table) => OrderingTerm.desc(table.updatedAt),
                (table) => OrderingTerm.desc(table.createdAt),
              ]))
            .get();

    return ProjectDetailSnapshot(
      project: project,
      activeTasks: activeTasks,
      blockedTasks: blockedTasks,
      recentJournalEntries: recentJournalEntries,
      recentLearningItems: learningItems
          .take(3)
          .map(
            (item) => ProjectLinkedLearningItem(
              learningItemId: item.learningItemId,
              topic: item.topic,
              status: item.status,
              nextStep: item.nextStep,
            ),
          )
          .toList(),
      recentContentItems: contentItems
          .take(3)
          .map(
            (item) => ProjectLinkedContentItem(
              contentItemId: item.contentItemId,
              title: item.title,
              status: item.status,
              platform: item.platform,
              preview: _contentPreview(item),
            ),
          )
          .toList(),
      recentBusinessOpportunities: businessOpportunities
          .take(3)
          .map(
            (item) => ProjectLinkedBusinessOpportunity(
              businessOpportunityId: item.businessOpportunityId,
              name: item.name,
              status: item.status,
              type: item.type,
              nextAction: item.nextAction,
            ),
          )
          .toList(),
      journalEntryCount: journalEntryCount,
      learningItemCount: learningItems.length,
      contentItemCount: contentItems.length,
      businessOpportunityCount: businessOpportunities.length,
    );
  }

  Future<Project> createProject({
    required String name,
    String? shortDescription,
    String? longDescription,
    String? vision,
    String status = 'Idea',
    String priority = 'Medium',
    int progressPercentage = 0,
    String? currentMilestone,
    String? nextAction,
    DateTime? startDate,
    DateTime? targetDate,
    String? notes,
  }) async {
    final timestamp = _now();
    final projectId = 'project-${_uuid.v4()}';

    await _database
        .into(_database.projects)
        .insert(
          ProjectsCompanion.insert(
            projectId: projectId,
            name: name.trim(),
            shortDescription: Value(_normalizeText(shortDescription)),
            longDescription: Value(_normalizeText(longDescription)),
            vision: Value(_normalizeText(vision)),
            status: Value(status),
            priority: Value(priority),
            progressPercentage: Value(_normalizeProgress(progressPercentage)),
            currentMilestone: Value(_normalizeText(currentMilestone)),
            nextAction: Value(_normalizeText(nextAction)),
            startDate: Value(startDate),
            targetDate: Value(targetDate),
            createdAt: timestamp,
            updatedAt: timestamp,
            notes: Value(_normalizeText(notes)),
          ),
        );

    return getProject(projectId);
  }

  Future<Project> updateProject({
    required String projectId,
    required String name,
    String? shortDescription,
    String? longDescription,
    String? vision,
    required String status,
    required String priority,
    required int progressPercentage,
    String? currentMilestone,
    String? nextAction,
    DateTime? startDate,
    DateTime? targetDate,
    String? notes,
  }) async {
    await (_database.update(
      _database.projects,
    )..where((table) => table.projectId.equals(projectId))).write(
      ProjectsCompanion(
        name: Value(name.trim()),
        shortDescription: Value(_normalizeText(shortDescription)),
        longDescription: Value(_normalizeText(longDescription)),
        vision: Value(_normalizeText(vision)),
        status: Value(status),
        priority: Value(priority),
        progressPercentage: Value(_normalizeProgress(progressPercentage)),
        currentMilestone: Value(_normalizeText(currentMilestone)),
        nextAction: Value(_normalizeText(nextAction)),
        startDate: Value(startDate),
        targetDate: Value(targetDate),
        notes: Value(_normalizeText(notes)),
        updatedAt: Value(_now()),
      ),
    );

    return getProject(projectId);
  }

  Future<Project> archiveProject(String projectId) async {
    await (_database.update(
      _database.projects,
    )..where((table) => table.projectId.equals(projectId))).write(
      ProjectsCompanion(
        isArchived: const Value(true),
        updatedAt: Value(_now()),
      ),
    );

    return getProject(projectId);
  }

  int _priorityRank(String priority) => switch (priority) {
    'High' => 0,
    'Medium' => 1,
    'Low' => 2,
    _ => 3,
  };

  String? _normalizeText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  int _normalizeProgress(int value) {
    if (value < 0) {
      return 0;
    }
    if (value > 100) {
      return 100;
    }
    return value;
  }

  String? _journalPreview(JournalEntry entry) {
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

  String? _contentPreview(ContentItem item) {
    final candidates = [item.draftText, item.notes, item.imagePrompt];
    for (final candidate in candidates) {
      final trimmed = candidate?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return null;
  }
}
