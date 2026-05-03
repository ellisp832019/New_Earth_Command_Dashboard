import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../projects/application/projects_controller.dart';
import '../data/learning_repository.dart';

final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return LearningRepository(database);
});

final learningItemsProvider = FutureProvider<List<LearningListItem>>((
  ref,
) async {
  await ref.watch(databaseReadyProvider.future);
  return ref.watch(learningRepositoryProvider).getItems();
});

final learningItemProvider = FutureProvider.family<LearningItem, String>((
  ref,
  learningItemId,
) async {
  await ref.watch(databaseReadyProvider.future);
  return ref.watch(learningRepositoryProvider).getById(learningItemId);
});

final learningActionsControllerProvider = Provider<LearningActionsController>((
  ref,
) {
  return LearningActionsController(ref);
});

class LearningActionsController {
  LearningActionsController(this._ref);

  final Ref _ref;

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
    final item = await _ref
        .read(learningRepositoryProvider)
        .createItem(
          topic: topic,
          projectId: projectId,
          reasonForLearning: reasonForLearning,
          resourceLink: resourceLink,
          status: status,
          notes: notes,
          nextStep: nextStep,
          skillConfidence: skillConfidence,
        );

    _ref.invalidate(learningItemsProvider);
    if (projectId != null) {
      _ref.invalidate(projectDetailProvider(projectId));
    }
    return item;
  }

  Future<LearningItem> updateItem({
    required String learningItemId,
    required String topic,
    String? projectId,
    String? reasonForLearning,
    String? resourceLink,
    String status = 'To Learn',
    String? notes,
    String? nextStep,
    String? skillConfidence,
  }) async {
    final existing = await _ref
        .read(learningRepositoryProvider)
        .getById(learningItemId);
    final item = await _ref
        .read(learningRepositoryProvider)
        .updateItem(
          learningItemId: learningItemId,
          topic: topic,
          projectId: projectId,
          reasonForLearning: reasonForLearning,
          resourceLink: resourceLink,
          status: status,
          notes: notes,
          nextStep: nextStep,
          skillConfidence: skillConfidence,
        );

    _ref.invalidate(learningItemsProvider);
    _ref.invalidate(learningItemProvider(learningItemId));

    final projectIds = {existing.projectId, projectId}.whereType<String>();
    for (final linkedProjectId in projectIds) {
      _ref.invalidate(projectDetailProvider(linkedProjectId));
    }

    return item;
  }
}
