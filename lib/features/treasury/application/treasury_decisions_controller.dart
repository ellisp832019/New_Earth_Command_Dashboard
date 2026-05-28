import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'treasury_controller.dart';
import '../data/treasury_folder_service.dart';

final treasuryDecisionRecordsProvider =
    FutureProvider<List<TreasuryDecisionRecord>>((ref) async {
      final snapshot = await ref.watch(treasuryWorkspaceProvider.future);
      final financeRootPath = snapshot.financeRootPath;
      if (financeRootPath == null) {
        return const <TreasuryDecisionRecord>[];
      }

      return ref
          .read(treasuryFolderServiceProvider)
          .loadDecisionRegister(financeRootPath: financeRootPath);
    });

final treasuryDecisionsControllerProvider =
    Provider<TreasuryDecisionsController>((ref) {
      return TreasuryDecisionsController(ref);
    });

class TreasuryDecisionsController {
  TreasuryDecisionsController(this._ref);

  final Ref _ref;

  Future<TreasuryDecisionSaveResult> saveDecision({
    required String date,
    required String decisionNeeded,
    required String amount,
    required String status,
    required String decision,
    required String owner,
    required String notes,
  }) async {
    final snapshot = await _ref.read(treasuryWorkspaceProvider.future);
    final financeRootPath = snapshot.financeRootPath;
    if (financeRootPath == null) {
      throw StateError('Treasury needs the finance folder linked first.');
    }

    final result = await _ref
        .read(treasuryFolderServiceProvider)
        .saveDecisionRecord(
          financeRootPath: financeRootPath,
          date: date,
          decisionNeeded: decisionNeeded,
          amount: amount,
          status: status,
          decision: decision,
          owner: owner,
          notes: notes,
        );

    _ref.invalidate(treasuryDecisionRecordsProvider);
    _ref.invalidate(treasuryWorkspaceProvider);
    return result;
  }
}
