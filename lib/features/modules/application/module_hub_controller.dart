import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/modules/module_hub_state_repository.dart';
import '../../../core/modules/module_loader.dart';
import '../../../core/modules/module_manifest.dart';

final moduleHubStateRepositoryProvider = Provider<ModuleHubStateRepository>((
  ref,
) {
  return ModuleHubStateRepository();
});

final moduleHubModulesProvider =
    NotifierProvider<ModuleHubController, List<ModuleManifest>>(
      ModuleHubController.new,
    );

class ModuleHubController extends Notifier<List<ModuleManifest>> {
  @override
  List<ModuleManifest> build() {
    return _loadModules();
  }

  Future<void> setModuleEnabled(String moduleId, bool enabled) async {
    final current = state;
    final updated = <ModuleManifest>[
      for (final module in current)
        if (module.id == moduleId)
          module.copyWith(enabled: enabled)
        else
          module,
    ];

    state = updated;
    unawaited(
      ref
          .read(moduleHubStateRepositoryProvider)
          .saveEnabledState(moduleId, enabled),
    );
  }

  Future<void> reload() async {
    state = _loadModules();
  }

  List<ModuleManifest> _loadModules() {
    final loader = const ModuleLoader();
    final states = ref
        .read(moduleHubStateRepositoryProvider)
        .loadEnabledStates();
    return loader.load(enabledOverrides: states).all;
  }
}
