import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_earth_command_dashboard/core/dock/dock_position.dart';
import 'package:new_earth_command_dashboard/core/modules/module_category.dart';
import 'package:new_earth_command_dashboard/core/modules/module_health.dart';
import 'package:new_earth_command_dashboard/core/modules/module_hub_state_repository.dart';
import 'package:new_earth_command_dashboard/core/modules/module_manifest.dart';
import 'package:new_earth_command_dashboard/core/modules/module_navigation.dart';
import 'package:new_earth_command_dashboard/core/modules/module_status.dart';
import 'package:new_earth_command_dashboard/features/modules/application/module_hub_controller.dart';
import 'package:new_earth_command_dashboard/features/modules/widgets/module_workspace_shell.dart';

ModuleManifest _module({
  required String id,
  required String name,
  required String route,
}) {
  return ModuleManifest(
    id: id,
    name: name,
    description: '$name module',
    category: ModuleCategory.systemCore,
    version: '0.1.0',
    status: ModuleStatus.enabled,
    enabled: true,
    dockable: true,
    defaultDockPosition: DockPosition.right,
    permissions: const [],
    installPath: 'modules/$id',
    omegaOsPath: 'OMEGA_OS/MODULES/$id',
    routes: [route],
    health: const ModuleHealthSnapshot(
      state: ModuleHealthState.healthy,
      lastCheckedLabel: 'Now',
      backendStatus: 'Ready',
      errors: [],
      warnings: [],
      nextAction: 'None',
    ),
  );
}

class _FakeModuleHubStateRepository extends ModuleHubStateRepository {
  @override
  ModuleLaunchTarget loadLaunchTarget(
    String moduleId, {
    ModuleLaunchTarget fallback = ModuleLaunchTarget.package,
  }) {
    return fallback;
  }

  @override
  Future<void> saveLaunchTarget(
    String moduleId,
    ModuleLaunchTarget target,
  ) async {}
}

void main() {
  testWidgets(
    'module workspace shell stays compact and keeps the title clean',
    (tester) async {
      final module = _module(
        id: 'engineering',
        name: 'Omega Engineering Studio',
        route: '/modules/omega-engineering-studio',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            moduleHubStateRepositoryProvider.overrideWithValue(
              _FakeModuleHubStateRepository(),
            ),
          ],
          child: MaterialApp(
            home: ModuleWorkspaceShell(
              module: module,
              modules: [module],
              title: 'New Earth Command Centre',
              subtitle: 'Local-first command center',
              child: const SizedBox(height: 240),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('New Earth Command Centre'), findsOneWidget);
      expect(find.text('Local-first command center'), findsOneWidget);
      expect(find.byKey(const Key('module-switcher-dropdown')), findsOneWidget);

      final dropdownSize = tester.getSize(
        find.byKey(const Key('module-switcher-dropdown')),
      );
      expect(dropdownSize.width, lessThanOrEqualTo(198));
    },
  );
}
