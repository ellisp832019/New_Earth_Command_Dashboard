import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/dock/dock_position.dart';
import 'package:new_earth_command_dashboard/core/modules/module_category.dart';
import 'package:new_earth_command_dashboard/core/modules/module_health.dart';
import 'package:new_earth_command_dashboard/core/modules/module_manifest.dart';
import 'package:new_earth_command_dashboard/core/modules/module_status.dart';
import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/core/windowing/module_window_service.dart';

ModuleManifest _module() {
  return ModuleManifest(
    id: 'sample_module',
    name: 'Sample Module',
    description: 'Sample module',
    category: ModuleCategory.systemCore,
    version: '0.1.0',
    status: ModuleStatus.enabled,
    enabled: true,
    dockable: true,
    defaultDockPosition: DockPosition.right,
    permissions: const [],
    installPath: 'modules/sample_module',
    omegaOsPath: 'OMEGA_OS/MODULES/SAMPLE_MODULE',
    routes: const ['/modules/sample'],
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
  test('module window service launches the shared package route', () {
    const service = ModuleWindowService();

    expect(
      service.launchRouteForModule(_module()),
      RouteNames.modulePackage('sample_module'),
    );
  });
}
