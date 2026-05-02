import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../tasks/data/task_repository.dart';
import 'voice_command_model.dart';

class VoiceAssistantProjectOption {
  const VoiceAssistantProjectOption({required this.id, required this.name});

  final String id;
  final String name;
}

class VoiceCommandActionService {
  VoiceCommandActionService(
    this._database, {
    TaskRepository? taskRepository,
    Uuid? uuid,
    DateTime Function()? now,
  }) : _taskRepository = taskRepository ?? TaskRepository(_database, now: now),
       _uuid = uuid ?? const Uuid(),
       _now = now ?? DateTime.now;

  final AppDatabase _database;
  final TaskRepository _taskRepository;
  final Uuid _uuid;
  final DateTime Function() _now;

  Future<void> saveCommand({
    required String transcript,
    required VoiceCommandType type,
    String? projectId,
  }) async {
    switch (type) {
      case VoiceCommandType.task:
        await _saveAsTask(transcript, projectId: projectId);
      case VoiceCommandType.journalEntry:
        await _saveAsJournalEntry(transcript, projectId: projectId);
      case VoiceCommandType.idea:
        await _saveAsIdea(transcript, projectId: projectId);
      case VoiceCommandType.codexPrompt:
        throw UnsupportedError(
          'Codex prompts should be reviewed manually before use.',
        );
    }
  }

  Future<void> _saveAsTask(String transcript, {String? projectId}) async {
    final cleanTranscript = transcript.trim();
    await _taskRepository.createTask(
      title: _titleFromTranscript(cleanTranscript),
      projectId: projectId,
      description: cleanTranscript,
      category: 'Admin',
      status: 'Inbox',
      notes: 'Captured from the Voice Assistant.',
    );
  }

  Future<void> _saveAsJournalEntry(
    String transcript, {
    String? projectId,
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
            title: _prefixedTitle(
              prefix: 'Voice note',
              transcript: cleanTranscript,
            ),
            category: const Value('Reflection'),
            whatIWorkedOn: Value(cleanTranscript),
            tags: const Value('voice'),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );
  }

  Future<void> _saveAsIdea(String transcript, {String? projectId}) async {
    final cleanTranscript = transcript.trim();
    final timestamp = _now();

    await _database
        .into(_database.inboxItems)
        .insert(
          InboxItemsCompanion.insert(
            inboxItemId: 'inbox-item-${_uuid.v4()}',
            title: Value(
              _prefixedTitle(prefix: 'Idea', transcript: cleanTranscript),
            ),
            body: Value(cleanTranscript),
            type: const Value('Future Idea'),
            projectId: Value(projectId),
            status: const Value('New'),
            createdAt: timestamp,
          ),
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
}

final voiceCommandActionServiceProvider = Provider<VoiceCommandActionService>((
  ref,
) {
  final database = ref.watch(appDatabaseProvider);
  return VoiceCommandActionService(database);
});

final voiceAssistantProjectOptionsProvider =
    FutureProvider<List<VoiceAssistantProjectOption>>((ref) async {
      await ref.watch(databaseReadyProvider.future);
      return ref.read(voiceCommandActionServiceProvider).getProjectOptions();
    });
