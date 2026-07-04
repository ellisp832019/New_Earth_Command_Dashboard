import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/core/modules/module_manifest.dart';
import 'package:new_earth_command_dashboard/core/modules/module_navigation.dart';
import 'package:new_earth_command_dashboard/core/modules/module_category.dart';
import 'package:new_earth_command_dashboard/core/modules/module_health.dart';
import 'package:new_earth_command_dashboard/core/modules/module_status.dart';
import 'package:new_earth_command_dashboard/core/dock/dock_position.dart';

ModuleManifest _module({
  required String id,
  required String name,
  required List<String> routes,
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
    routes: routes,
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
  test('module home route resolves to the first registered route', () {
    final module = _module(
      id: 'alpha',
      name: 'Alpha',
      routes: ['/modules/alpha', '/modules/alpha/settings'],
    );

    expect(moduleHomeRoute(module), '/modules/alpha');
    expect(modulePackageRoute(module), RouteNames.modulePackage('alpha'));
  });

  test('module path matching recognizes nested module routes', () {
    final modules = [
      _module(id: 'alpha', name: 'Alpha', routes: ['/modules/alpha']),
      _module(
        id: 'beta',
        name: 'Beta',
        routes: ['/modules/beta', '/modules/beta/settings'],
      ),
    ];

    expect(moduleForPath(modules, '/modules/beta/settings'), modules[1]);
    expect(moduleForPath(modules, '/modules/alpha/projects'), modules[0]);
    expect(
      moduleForPath(modules, RouteNames.modulePackage('beta')),
      modules[1],
    );
    expect(moduleForPath(modules, '/dashboard'), isNull);
  });
}
