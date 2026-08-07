import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/dock/dock_position.dart';
import 'package:new_earth_command_dashboard/core/modules/module_category.dart';
import 'package:new_earth_command_dashboard/core/modules/module_health.dart';
import 'package:new_earth_command_dashboard/core/modules/module_manifest.dart';
import 'package:new_earth_command_dashboard/core/modules/module_permissions.dart';
import 'package:new_earth_command_dashboard/core/modules/module_status.dart';
import 'package:new_earth_command_dashboard/features/modules/module_settings_screen.dart';

void main() {
  testWidgets(
    'module settings screen keeps the shared shell and local controls visible',
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
            home: ModuleSettingsScreen(module: module),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Alpha Module Settings'), findsOneWidget);
      expect(find.text('Local placeholders and notes'), findsOneWidget);
      expect(
        find.text('Settings are local placeholders for now.'),
        findsOneWidget,
      );
      expect(find.text('Enabled'), findsOneWidget);
      expect(find.text('Launch preference'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Future backend notes'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Future backend notes'), findsOneWidget);
    },
  );
}
