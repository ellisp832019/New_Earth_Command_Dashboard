import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/dock/dock_position.dart';
import 'package:new_earth_command_dashboard/core/modules/module_category.dart';
import 'package:new_earth_command_dashboard/core/modules/module_health.dart';
import 'package:new_earth_command_dashboard/core/modules/module_manifest.dart';
import 'package:new_earth_command_dashboard/core/modules/module_permissions.dart';
import 'package:new_earth_command_dashboard/core/modules/module_status.dart';
import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/core/modules/module_navigation.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_models.dart';

void main() {
  test('engineering manifest routes stay aligned with the section enum', () {
    final manifest = jsonDecode(
      File('modules/01_OMEGA_ENGINEERING_STUDIO_MODULE/module_manifest.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;

    expect(manifest['id'], '01_OMEGA_ENGINEERING_STUDIO_MODULE');
    expect(
      modulePackageRoute(
        ModuleManifest(
          id: manifest['id'].toString(),
          name: 'Omega Engineering Studio',
          description: 'Local-first engineering workspace.',
          category: ModuleCategory.voiceHardware,
          version: '0.1.0',
          status: ModuleStatus.enabled,
          enabled: true,
          dockable: true,
          defaultDockPosition: DockPosition.right,
          permissions: const [
            ModulePermission(type: ModulePermissionType.fileRead),
          ],
          installPath: 'modules/01_OMEGA_ENGINEERING_STUDIO_MODULE',
          omegaOsPath: 'OMEGA_OS/MODULES/OMEGA_ENGINEERING_STUDIO',
          health: const ModuleHealthSnapshot(
            state: ModuleHealthState.healthy,
            lastCheckedLabel: 'Now',
            backendStatus: 'Ready locally',
            errors: [],
            warnings: [],
            nextAction: 'None',
          ),
        ),
      ),
      RouteNames.modulePackage('01_OMEGA_ENGINEERING_STUDIO_MODULE'),
    );

    final expectedRoutes = <String>[
      RouteNames.omegaEngineeringStudio,
      for (final section in EngineeringSection.values.skip(1))
        RouteNames.omegaEngineeringStudioSection(section.routeSegment),
    ];

    expect(
      (manifest['routes'] as List<dynamic>).cast<String>(),
      expectedRoutes,
    );

    for (final section in EngineeringSection.values) {
      expect(
        EngineeringSection.fromRouteSegment(section.routeSegment),
        section,
      );
    }
  });
}
