import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'omega_experiment_models.dart';

final omegaExperimentRepositoryProvider = Provider<OmegaExperimentRepository>(
  (ref) => const OmegaExperimentRepository(),
);

final omegaExperimentWorkspaceProvider =
    FutureProvider<OmegaExperimentWorkspace>((ref) {
  return ref.read(omegaExperimentRepositoryProvider).loadWorkspace();
});
