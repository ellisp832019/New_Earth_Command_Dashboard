import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dock/dock_layout_state.dart';
import '../../../core/dock/dock_position.dart';
import '../../../core/modules/module_hub_state_repository.dart';
import '../../../core/modules/module_event_bus.dart';
import '../../../core/modules/module_loader.dart';
import '../../../core/modules/module_manifest.dart';

final moduleHubStateRepositoryProvider = Provider<ModuleHubStateRepository>((
  ref,
) {
  return ModuleHubStateRepository();
});

final dockLayoutStateProvider =
    NotifierProvider<DockLayoutController, DockLayoutState>(
      DockLayoutController.new,
    );

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
    ref
        .read(moduleEventBusProvider)
        .publish(
          ModuleEvent(
            moduleId: moduleId,
            type: ModuleEventType.enabledChanged,
            timestamp: DateTime.now(),
            message: enabled
                ? 'Module enabled locally.'
                : 'Module disabled locally.',
            details: <String, dynamic>{'enabled': enabled},
          ),
        );
  }

  Future<void> reload() async {
    state = _loadModules();
    ref
        .read(moduleEventBusProvider)
        .publish(
          ModuleEvent(
            moduleId: 'module_hub',
            type: ModuleEventType.registryReloaded,
            timestamp: DateTime.now(),
            message: 'Module registry refreshed.',
          ),
        );
  }

  List<ModuleManifest> _loadModules() {
    final loader = const ModuleLoader();
    final states = ref
        .read(moduleHubStateRepositoryProvider)
        .loadEnabledStates();
    return loader.load(enabledOverrides: states).all;
  }
}

class DockLayoutController extends Notifier<DockLayoutState> {
  static const Map<String, DockPosition> _defaultPositions = {
    'backup_guardian_dock': DockPosition.left,
    'treasury_dock': DockPosition.bottom,
    'knowledge_library_dock': DockPosition.right,
  };

  static const Map<String, DockAnchor> _defaultAnchors = {
    'backup_guardian_dock': DockAnchor.topLeft,
    'treasury_dock': DockAnchor.bottomLeft,
    'knowledge_library_dock': DockAnchor.middleRight,
  };

  @override
  DockLayoutState build() {
    return ref.read(moduleHubStateRepositoryProvider).loadDockLayoutState();
  }

  Future<void> setPosition(String moduleId, DockPosition position) async {
    state = state.setPosition(moduleId, position);
    await ref.read(moduleHubStateRepositoryProvider).saveDockLayoutState(state);
  }

  Future<void> setFloatingAnchor(String moduleId, DockAnchor anchor) async {
    state = state.setFloatingAnchor(moduleId, anchor);
    await ref.read(moduleHubStateRepositoryProvider).saveDockLayoutState(state);
  }

  Future<void> restoreDefaultLayout() async {
    var next = state;
    for (final entry in _defaultPositions.entries) {
      next = next.setPosition(entry.key, entry.value);
    }
    for (final entry in _defaultAnchors.entries) {
      next = next.setFloatingAnchor(entry.key, entry.value);
    }
    state = next;
    await ref.read(moduleHubStateRepositoryProvider).saveDockLayoutState(state);
  }
}
