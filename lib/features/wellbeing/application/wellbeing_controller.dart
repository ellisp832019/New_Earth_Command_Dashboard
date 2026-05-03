import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/wellbeing_repository.dart';

final wellbeingRepositoryProvider = Provider<WellbeingRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return WellbeingRepository(database);
});

final wellbeingCheckinsProvider = FutureProvider<List<WellbeingCheckin>>((
  ref,
) async {
  await ref.watch(databaseReadyProvider.future);
  return ref.watch(wellbeingRepositoryProvider).getCheckins();
});

final wellbeingActionsControllerProvider = Provider<WellbeingActionsController>(
  (ref) {
    return WellbeingActionsController(ref);
  },
);

class WellbeingActionsController {
  WellbeingActionsController(this._ref);

  final Ref _ref;

  Future<WellbeingCheckin> createCheckin({
    required DateTime date,
    String? energyLevel,
    String? mood,
    String? sleepQuality,
    String? stressLevel,
    required bool movementDone,
    required bool foodWaterOk,
    required bool meditationReflectionDone,
    String? notes,
  }) async {
    final checkin = await _ref
        .read(wellbeingRepositoryProvider)
        .createCheckin(
          date: date,
          energyLevel: energyLevel,
          mood: mood,
          sleepQuality: sleepQuality,
          stressLevel: stressLevel,
          movementDone: movementDone,
          foodWaterOk: foodWaterOk,
          meditationReflectionDone: meditationReflectionDone,
          notes: notes,
        );

    _ref.invalidate(wellbeingCheckinsProvider);
    return checkin;
  }
}
