import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../projects/application/projects_controller.dart';
import '../data/business_repository.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return BusinessRepository(database);
});

final businessItemsProvider = FutureProvider<List<BusinessListItem>>((
  ref,
) async {
  await ref.watch(databaseReadyProvider.future);
  return ref.watch(businessRepositoryProvider).getItems();
});

final businessActionsControllerProvider = Provider<BusinessActionsController>((
  ref,
) {
  return BusinessActionsController(ref);
});

class BusinessActionsController {
  BusinessActionsController(this._ref);

  final Ref _ref;

  Future<BusinessOpportunity> createItem({
    required String name,
    String? projectId,
    String? type,
    String status = 'Researching',
    String? companyOrContact,
    DateTime? deadline,
    String? nextAction,
    DateTime? followUpDate,
    String? relatedDocumentLink,
    String? notes,
  }) async {
    final item = await _ref
        .read(businessRepositoryProvider)
        .createItem(
          name: name,
          projectId: projectId,
          type: type,
          status: status,
          companyOrContact: companyOrContact,
          deadline: deadline,
          nextAction: nextAction,
          followUpDate: followUpDate,
          relatedDocumentLink: relatedDocumentLink,
          notes: notes,
        );

    _ref.invalidate(businessItemsProvider);
    if (projectId != null) {
      _ref.invalidate(projectDetailProvider(projectId));
    }
    return item;
  }
}
