import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/dock/dock_position.dart';
import 'package:new_earth_command_dashboard/core/modules/module_category.dart';
import 'package:new_earth_command_dashboard/core/modules/module_health.dart';
import 'package:new_earth_command_dashboard/core/modules/module_manifest.dart';
import 'package:new_earth_command_dashboard/core/modules/module_permissions.dart';
import 'package:new_earth_command_dashboard/core/modules/module_status.dart';
import 'package:new_earth_command_dashboard/features/modules/module_docking_screen.dart';

void main() {
  testWidgets('module docking screen keeps the shared shell and tags clean', (
    tester,
  ) async {
    final module = ModuleManifest(
      id: 'alpha_module',
      name: 'Alpha Module',
      description: 'Calm local control for the alpha workflow.',
      category: ModuleCategory.projectManagement,
      version: '1.2.3',
      status: ModuleStatus.enabled,
      enabled: true,
      dockable: true,
      defaultDockPosition: DockPosition.right,
      permissions: const [
        ModulePermission(type: ModulePermissionType.fileRead),
      ],
      installPath: 'modules/alpha_module',
      omegaOsPath: 'OMEGA_OS/MODULES/ALPHA_MODULE',
      health: const ModuleHealthSnapshot(
        state: ModuleHealthState.healthy,
        lastCheckedLabel: 'Now',
        backendStatus: 'Ready locally',
        errors: [],
        warnings: [],
        nextAction: 'None',
      ),
      tags: const ['alpha', 'workflow'],
      notes: '',
    );

    await tester.binding.setSurfaceSize(const Size(1440, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: ModuleDockingScreen(module: module),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Alpha Module Docking'), findsOneWidget);
    expect(find.text('Layout and docking'), findsWidgets);
    expect(find.text('Pinned shortcuts'), findsOneWidget);
    expect(find.text('alpha · workflow'), findsOneWidget);
  });
}
