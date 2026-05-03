import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../projects/application/projects_controller.dart';
import '../../tasks/application/tasks_controller.dart';
import '../data/journal_repository.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return JournalRepository(database);
});

final journalEntriesProvider = FutureProvider<List<JournalListEntry>>((
  ref,
) async {
  await ref.watch(databaseReadyProvider.future);
  return ref.watch(journalRepositoryProvider).getEntries();
});

final journalActionsControllerProvider = Provider<JournalActionsController>((
  ref,
) {
  return JournalActionsController(ref);
});

class JournalActionsController {
  JournalActionsController(this._ref);

  final Ref _ref;

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
    final entry = await _ref
        .read(journalRepositoryProvider)
        .createEntry(
          date: date,
          title: title,
          projectId: projectId,
          taskId: taskId,
          category: category,
          whatIWorkedOn: whatIWorkedOn,
          whatILearned: whatILearned,
          nextActions: nextActions,
        );

    _ref.invalidate(journalEntriesProvider);
    if (projectId != null) {
      _ref.invalidate(projectDetailProvider(projectId));
    }
    if (taskId != null) {
      _ref.invalidate(taskProvider(taskId));
    }
    return entry;
  }
}
