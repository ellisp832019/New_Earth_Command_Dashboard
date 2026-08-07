import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/dock/dock_position.dart';
import 'package:new_earth_command_dashboard/core/modules/module_category.dart';
import 'package:new_earth_command_dashboard/core/modules/module_health.dart';
import 'package:new_earth_command_dashboard/core/modules/module_manifest.dart';
import 'package:new_earth_command_dashboard/core/modules/module_status.dart';
import 'package:new_earth_command_dashboard/core/widgets/module_switcher_dropdown.dart';

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

void main() {
  testWidgets(
    'module switcher dropdown shows the selected module and emits changes',
    (tester) async {
      final modules = [
        _module(id: 'dashboard', name: 'Dashboard', route: '/dashboard'),
        _module(
          id: 'engineering',
          name: 'Omega Engineering Studio',
          route: '/modules/omega-engineering-studio',
        ),
      ];
      ModuleManifest? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ModuleSwitcherDropdown(
                modules: modules,
                selectedModule: modules.first,
                onSelected: (module) {
                  selected = module;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Dashboard'), findsOneWidget);

      await tester.tap(find.byKey(const Key('module-switcher-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Omega Engineering Studio').last);
      await tester.pumpAndSettle();

      expect(selected, same(modules[1]));
    },
  );
}
