import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/inbox_repository.dart';

final inboxRepositoryProvider = Provider<InboxRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return InboxRepository(database);
});

final inboxItemsProvider = FutureProvider<List<InboxListItem>>((ref) async {
  await ref.watch(databaseReadyProvider.future);
  return ref.watch(inboxRepositoryProvider).getItems();
});

final inboxActionsControllerProvider = Provider<InboxActionsController>((ref) {
  return InboxActionsController(ref);
});

class InboxActionsController {
  InboxActionsController(this._ref);

  final Ref _ref;

  Future<InboxItem> createItem({
    String? title,
    String? body,
    String? type,
    String? projectId,
    String status = 'New',
  }) async {
    final item = await _ref
        .read(inboxRepositoryProvider)
        .createItem(
          title: title,
          body: body,
          type: type,
          projectId: projectId,
          status: status,
        );

    _ref.invalidate(inboxItemsProvider);
    return item;
  }
}
