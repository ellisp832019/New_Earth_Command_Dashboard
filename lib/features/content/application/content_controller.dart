import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../projects/application/projects_controller.dart';
import '../data/content_repository.dart';

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return ContentRepository(database);
});

final contentItemsProvider = FutureProvider<List<ContentListItem>>((ref) async {
  await ref.watch(databaseReadyProvider.future);
  return ref.watch(contentRepositoryProvider).getItems();
});

final contentActionsControllerProvider = Provider<ContentActionsController>((
  ref,
) {
  return ContentActionsController(ref);
});

class ContentActionsController {
  ContentActionsController(this._ref);

  final Ref _ref;

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
    final item = await _ref
        .read(contentRepositoryProvider)
        .createItem(
          title: title,
          projectId: projectId,
          platform: platform,
          contentType: contentType,
          status: status,
          draftText: draftText,
          imageNeeded: imageNeeded,
          imagePrompt: imagePrompt,
          notes: notes,
        );

    _ref.invalidate(contentItemsProvider);
    if (projectId != null) {
      _ref.invalidate(projectDetailProvider(projectId));
    }
    return item;
  }
}
