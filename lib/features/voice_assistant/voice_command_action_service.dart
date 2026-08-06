import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../business/application/business_controller.dart';
import '../business/data/business_repository.dart';
import '../content/application/content_controller.dart';
import '../content/data/content_repository.dart';
import '../dashboard/application/dashboard_controller.dart';
import '../inbox/application/inbox_controller.dart';
import '../journal/application/journal_controller.dart';
import '../projects/application/projects_controller.dart';
import '../projects/data/project_repository.dart';
import '../tasks/data/task_repository.dart';
import '../tasks/application/tasks_controller.dart';
import 'voice_command_model.dart';

class VoiceCommandActionService {
  VoiceCommandActionService(
    this._database, {
    TaskRepository? taskRepository,
    ProjectRepository? projectRepository,
    ContentRepository? contentRepository,
    BusinessRepository? businessRepository,
    Uuid? uuid,
    DateTime Function()? now,
  }) : _taskRepository = taskRepository ?? TaskRepository(_database, now: now),
       _projectRepository =
           projectRepository ?? ProjectRepository(_database, now: now),
       _contentRepository =
           contentRepository ?? ContentRepository(_database, now: now),
       _businessRepository =
           businessRepository ?? BusinessRepository(_database, now: now),
       _uuid = uuid ?? const Uuid(),
       _now = now ?? DateTime.now;

  final AppDatabase _database;
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  final ContentRepository _contentRepository;
  final BusinessRepository _businessRepository;
  final Uuid _uuid;
  final DateTime Function() _now;

  Future<void> saveCommand({
    required String transcript,
    required VoiceCommandType type,
    String? projectId,
    String? titleOverride,
    VoiceCommandSuggestion? suggestion,
  }) async {
    switch (type) {
      case VoiceCommandType.task:
        await _saveAsTask(
          transcript,
          projectId: projectId,
          titleOverride: titleOverride,
          suggestion: suggestion,
        );
      case VoiceCommandType.project:
        await _saveAsProject(
          transcript,
          titleOverride: titleOverride,
          suggestion: suggestion,
        );
      case VoiceCommandType.journalEntry:
        await _saveAsJournalEntry(
          transcript,
          projectId: projectId,
          titleOverride: titleOverride,
          suggestion: suggestion,
        );
      case VoiceCommandType.contentIdea:
        await _saveAsContentIdea(
          transcript,
          projectId: projectId,
          titleOverride: titleOverride,
          suggestion: suggestion,
        );
      case VoiceCommandType.businessOpportunity:
        await _saveAsBusinessOpportunity(
          transcript,
          projectId: projectId,
          titleOverride: titleOverride,
          suggestion: suggestion,
        );
      case VoiceCommandType.idea:
        await _saveAsIdea(
          transcript,
          projectId: projectId,
          titleOverride: titleOverride,
        );
      case VoiceCommandType.codexPrompt:
        throw UnsupportedError(
          'Codex prompts should be reviewed manually before use.',
        );
    }
  }

  Future<void> _saveAsTask(
    String transcript, {
    String? projectId,
    String? titleOverride,
    VoiceCommandSuggestion? suggestion,
  }) async {
    final cleanTranscript = transcript.trim();
    await _taskRepository.createTask(
      title: _resolvedTitle(
        titleOverride,
        fallback: _titleFromTranscript(cleanTranscript),
      ),
      projectId: projectId,
      description: cleanTranscript,
      category: suggestion?.extractedTaskCategory ?? 'Admin',
      priority: suggestion?.extractedTaskPriority ?? 'Medium',
      status: 'Inbox',
      notes: 'Captured from the Voice Assistant.',
    );
  }

  Future<void> _saveAsProject(
    String transcript, {
    String? titleOverride,
    VoiceCommandSuggestion? suggestion,
  }) async {
    final cleanTranscript = transcript.trim();
    await _projectRepository.createProject(
      name: _resolvedTitle(
        titleOverride,
        fallback: _prefixedTitle(
          prefix: 'Voice project',
          transcript: cleanTranscript,
        ),
      ),
      shortDescription: cleanTranscript,
      longDescription: cleanTranscript,
      vision: suggestion?.extractedProjectVision,
      status: suggestion?.extractedProjectStatus ?? 'Idea',
      priority: suggestion?.extractedProjectPriority ?? 'Medium',
      progressPercentage: 0,
      currentMilestone: null,
      nextAction: suggestion?.extractedProjectNextAction ?? cleanTranscript,
      notes: suggestion?.extractedProjectNotes ?? 'Captured from the Voice Assistant.',
    );
  }

  Future<void> _saveAsJournalEntry(
    String transcript, {
    String? projectId,
    String? titleOverride,
    VoiceCommandSuggestion? suggestion,
  }) async {
    final cleanTranscript = transcript.trim();
    final timestamp = _now();

    await _database
        .into(_database.journalEntries)
        .insert(
          JournalEntriesCompanion.insert(
            journalEntryId: 'journal-entry-${_uuid.v4()}',
            projectId: Value(projectId),
            date: timestamp,
            title: _resolvedTitle(
              titleOverride,
              fallback: _prefixedTitle(
                prefix: 'Voice note',
                transcript: cleanTranscript,
              ),
            ),
            category: const Value('Reflection'),
            whatIWorkedOn: Value(
              suggestion?.extractedJournalWorkedOn ?? cleanTranscript,
            ),
            whatILearned: Value(suggestion?.extractedJournalLearned),
            nextActions: Value(suggestion?.extractedJournalNextActions),
            tags: const Value('voice'),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );
  }

  Future<void> _saveAsIdea(
    String transcript, {
    String? projectId,
    String? titleOverride,
  }) async {
    final cleanTranscript = transcript.trim();
    final timestamp = _now();

    await _database
        .into(_database.inboxItems)
        .insert(
          InboxItemsCompanion.insert(
            inboxItemId: 'inbox-item-${_uuid.v4()}',
            title: Value(
              _resolvedTitle(
                titleOverride,
                fallback: _prefixedTitle(
                  prefix: 'Idea',
                  transcript: cleanTranscript,
                ),
              ),
            ),
            body: Value(cleanTranscript),
            type: const Value('Future Idea'),
            projectId: Value(projectId),
            status: const Value('New'),
            createdAt: timestamp,
          ),
        );
  }

  Future<void> _saveAsContentIdea(
    String transcript, {
    String? projectId,
    String? titleOverride,
    VoiceCommandSuggestion? suggestion,
  }) async {
    final cleanTranscript = transcript.trim();
    await _contentRepository.createItem(
      title: _resolvedTitle(
        titleOverride,
        fallback: _prefixedTitle(
          prefix: 'Voice content',
          transcript: cleanTranscript,
        ),
      ),
      projectId: projectId,
      platform: suggestion?.extractedContentPlatform,
      contentType: suggestion?.extractedContentType ?? 'Project Update',
      status: 'Idea',
      draftText: cleanTranscript,
      notes: 'Captured from the Voice Assistant.',
    );
  }

  Future<void> _saveAsBusinessOpportunity(
    String transcript, {
    String? projectId,
    String? titleOverride,
    VoiceCommandSuggestion? suggestion,
  }) async {
    final cleanTranscript = transcript.trim();
    await _businessRepository.createItem(
      name: _resolvedTitle(
        titleOverride,
        fallback: _prefixedTitle(
          prefix: 'Voice lead',
          transcript: cleanTranscript,
        ),
      ),
      projectId: projectId,
      type: suggestion?.extractedBusinessType ?? 'Business Idea',
      status: suggestion?.extractedBusinessStatus ?? 'Researching',
      companyOrContact: suggestion?.extractedBusinessContact,
      nextAction: suggestion?.extractedBusinessNextAction ?? cleanTranscript,
      notes: 'Captured from the Voice Assistant.',
    );
  }

  Future<List<VoiceAssistantProjectOption>> getProjectOptions() async {
    final projects =
        await (_database.select(_database.projects)
              ..where((table) => table.isArchived.equals(false))
              ..orderBy([(table) => OrderingTerm.asc(table.name)]))
            .get();

    return projects
        .map(
          (project) => VoiceAssistantProjectOption(
            id: project.projectId,
            name: project.name,
          ),
        )
        .toList();
  }

  String _titleFromTranscript(String transcript) {
    final normalized = transcript.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 72) {
      return normalized;
    }

    return '${normalized.substring(0, 69).trimRight()}...';
  }

  String _prefixedTitle({required String prefix, required String transcript}) {
    return '$prefix: ${_titleFromTranscript(transcript)}';
  }

  String _resolvedTitle(String? override, {required String fallback}) {
    final trimmedOverride = override?.trim();
    if (trimmedOverride == null || trimmedOverride.isEmpty) {
      return fallback;
    }

    return trimmedOverride;
  }
}

final voiceCommandActionServiceProvider = Provider<VoiceCommandActionService>((
  ref,
) {
  final database = ref.watch(appDatabaseProvider);
  return VoiceCommandActionService(database);
});

final voiceCommandActionsControllerProvider =
    Provider<VoiceCommandActionsController>((ref) {
      return VoiceCommandActionsController(ref);
    });

class VoiceCommandActionsController {
  VoiceCommandActionsController(this._ref);

  final Ref _ref;

  Future<void> saveCommand({
    required String transcript,
    required VoiceCommandType type,
    String? projectId,
    String? titleOverride,
    VoiceCommandSuggestion? suggestion,
  }) async {
    await _ref
        .read(voiceCommandActionServiceProvider)
        .saveCommand(
          transcript: transcript,
          type: type,
          projectId: projectId,
          titleOverride: titleOverride,
          suggestion: suggestion,
        );

    switch (type) {
      case VoiceCommandType.task:
        _ref.invalidate(tasksProvider);
        _ref.invalidate(dashboardSnapshotProvider);
      case VoiceCommandType.project:
        _ref.invalidate(projectsProvider);
        _ref.invalidate(dashboardSnapshotProvider);
      case VoiceCommandType.journalEntry:
        _ref.invalidate(journalEntriesProvider);
      case VoiceCommandType.contentIdea:
        _ref.invalidate(contentItemsProvider);
      case VoiceCommandType.businessOpportunity:
        _ref.invalidate(businessItemsProvider);
      case VoiceCommandType.idea:
        _ref.invalidate(inboxItemsProvider);
      case VoiceCommandType.codexPrompt:
        break;
    }

    if (projectId != null) {
      _ref.invalidate(projectDetailProvider(projectId));
    }
  }
}

final voiceAssistantProjectOptionsProvider =
    FutureProvider<List<VoiceAssistantProjectOption>>((ref) async {
      await ref.watch(databaseReadyProvider.future);
      return ref.read(voiceCommandActionServiceProvider).getProjectOptions();
    });
