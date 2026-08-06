import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/dock/dock_position.dart';
import 'package:new_earth_command_dashboard/core/modules/module_category.dart';
import 'package:new_earth_command_dashboard/core/modules/module_health.dart';
import 'package:new_earth_command_dashboard/core/modules/module_manifest.dart';
import 'package:new_earth_command_dashboard/core/modules/module_permissions.dart';
import 'package:new_earth_command_dashboard/core/modules/module_status.dart';
import 'package:new_earth_command_dashboard/features/modules/module_hub_filtering.dart';

void main() {
  const alpha = ModuleManifest(
    id: 'alpha',
    name: 'Alpha Dock',
    description: 'Alpha module for planning.',
    category: ModuleCategory.projectManagement,
    version: '1.0.0',
    status: ModuleStatus.enabled,
    enabled: true,
    dockable: true,
    defaultDockPosition: DockPosition.left,
    permissions: [
      ModulePermission(type: ModulePermissionType.fileRead),
      ModulePermission(type: ModulePermissionType.fileWrite),
    ],
    installPath: 'modules/alpha',
    omegaOsPath: 'OMEGA_OS/MODULES/ALPHA',
    health: ModuleHealthSnapshot(
      state: ModuleHealthState.healthy,
      lastCheckedLabel: 'Today',
      backendStatus: 'Ready',
      errors: [],
      warnings: [],
      nextAction: 'Keep using it.',
    ),
    tags: ['planning', 'focus'],
  );

  const beta = ModuleManifest(
    id: 'beta',
    name: 'Beta Bridge',
    description: 'Beta module for voice capture.',
    category: ModuleCategory.aiAutomation,
    version: '1.0.0',
    status: ModuleStatus.installed,
    enabled: false,
    dockable: false,
    defaultDockPosition: DockPosition.right,
    permissions: [
      ModulePermission(type: ModulePermissionType.microphone),
      ModulePermission(type: ModulePermissionType.speaker),
    ],
    installPath: 'modules/beta',
    omegaOsPath: 'OMEGA_OS/MODULES/BETA',
    health: ModuleHealthSnapshot(
      state: ModuleHealthState.warning,
      lastCheckedLabel: 'Today',
      backendStatus: 'Waiting',
      errors: [],
      warnings: [],
      nextAction: 'Review permissions.',
    ),
    tags: ['voice', 'assistant'],
  );

  const gamma = ModuleManifest(
    id: 'gamma',
    name: 'Gamma Core',
    description: 'Gamma module for repository analysis.',
    category: ModuleCategory.security,
    version: '1.0.0',
    status: ModuleStatus.planned,
    enabled: false,
    dockable: true,
    defaultDockPosition: DockPosition.fullscreen,
    permissions: [ModulePermission(type: ModulePermissionType.repoAccess)],
    installPath: 'modules/gamma',
    omegaOsPath: 'OMEGA_OS/MODULES/GAMMA',
    health: ModuleHealthSnapshot(
      state: ModuleHealthState.unknown,
      lastCheckedLabel: 'Today',
      backendStatus: 'Planned',
      errors: [],
      warnings: [],
      nextAction: 'Load later.',
    ),
    tags: ['repo', 'search'],
  );

  test('filters modules by search, category, dockability, and permissions', () {
    final filtered = filterAndSortModuleHubModules(
      modules: [alpha, beta, gamma],
      query: 'voice',
      categoryFilter: ModuleCategory.aiAutomation,
      dockableFilter: false,
      permissionFilter: ModulePermissionType.microphone,
    );

    expect(filtered, hasLength(1));
    expect(filtered.single.id, 'beta');
  });

  test('sorts enabled modules first then alphabetically', () {
    final sorted = filterAndSortModuleHubModules(
      modules: [beta, gamma, alpha],
      sortMode: ModuleHubSortMode.enabledFirst,
    );

    expect(sorted.map((module) => module.id), ['alpha', 'beta', 'gamma']);
  });
}
