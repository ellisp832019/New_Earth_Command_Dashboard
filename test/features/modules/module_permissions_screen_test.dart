import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/dock/dock_position.dart';
import 'package:new_earth_command_dashboard/core/modules/module_category.dart';
import 'package:new_earth_command_dashboard/core/modules/module_health.dart';
import 'package:new_earth_command_dashboard/core/modules/module_manifest.dart';
import 'package:new_earth_command_dashboard/core/modules/module_permissions.dart';
import 'package:new_earth_command_dashboard/core/modules/module_status.dart';
import 'package:new_earth_command_dashboard/features/modules/module_permissions_screen.dart';

void main() {
  testWidgets(
    'module permissions screen keeps the shared shell and local review visible',
    (tester) async {
      const module = ModuleManifest(
        id: 'alpha_module',
        name: 'Alpha Module',
        description: 'Calm local control for the alpha workflow.',
        category: ModuleCategory.projectManagement,
        version: '1.2.3',
        status: ModuleStatus.enabled,
        enabled: true,
        dockable: true,
        defaultDockPosition: DockPosition.right,
        permissions: [
          ModulePermission(
            type: ModulePermissionType.fileRead,
            state: ModulePermissionState.allowed,
            notes: 'Needs local read access to inspect manifests.',
          ),
          ModulePermission(
            type: ModulePermissionType.internetAccess,
            state: ModulePermissionState.askEveryTime,
          ),
          ModulePermission(
            type: ModulePermissionType.shellCommands,
            state: ModulePermissionState.disabled,
          ),
        ],
        installPath: 'modules/alpha_module',
        omegaOsPath: 'OMEGA_OS/MODULES/ALPHA_MODULE',
        health: ModuleHealthSnapshot(
          state: ModuleHealthState.warning,
          lastCheckedLabel: '2 minutes ago',
          backendStatus: 'Local shell healthy',
          errors: ['No critical failures recorded.'],
          warnings: ['Waiting for backend integration.'],
          nextAction: 'Connect the backend health feed.',
        ),
        tags: ['alpha', 'workflow'],
        notes: 'Used for module hub review.',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: ModulePermissionsScreen(module: module),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Alpha Module Permissions'), findsOneWidget);
      expect(find.text('Local controls and permission review'), findsOneWidget);
      expect(find.text('Permission summary'), findsOneWidget);
      expect(find.text('Local UI state only. Permission gating comes later.'), findsOneWidget);
      expect(find.text('File Read'), findsOneWidget);
      expect(find.text('Internet Access'), findsOneWidget);
      expect(find.text('Allowed'), findsWidgets);
      expect(find.text('Ask Every Time'), findsWidgets);
      expect(find.text('Disabled'), findsWidgets);

      await tester.scrollUntilVisible(
        find.text('Shell Commands'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Shell Commands'), findsOneWidget);
    },
  );
}
