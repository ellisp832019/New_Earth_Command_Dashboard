import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/dock/dock_position.dart';
import 'package:new_earth_command_dashboard/core/modules/module_category.dart';
import 'package:new_earth_command_dashboard/core/modules/module_health.dart';
import 'package:new_earth_command_dashboard/core/modules/module_manifest.dart';
import 'package:new_earth_command_dashboard/core/modules/module_permissions.dart';
import 'package:new_earth_command_dashboard/core/modules/module_status.dart';
import 'package:new_earth_command_dashboard/features/modules/module_detail_screen.dart';

void main() {
  testWidgets(
    'module detail screen surfaces dossier, health, and review sections',
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
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: ModuleDetailScreen(module: module),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Module dossier'), findsOneWidget);
      expect(
        find.text('Calm local control for the alpha workflow.'),
        findsOneWidget,
      );
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.text('Health'), findsOneWidget);
      expect(find.text('2 minutes ago'), findsOneWidget);
      expect(find.text('Connect the backend health feed.'), findsOneWidget);
      expect(find.text('Inspect permissions'), findsOneWidget);
      expect(find.text('Open settings'), findsOneWidget);
      expect(find.text('Open operations'), findsOneWidget);
      expect(find.text('Inspect docking'), findsOneWidget);
      expect(find.text('Review governance'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Manifest info'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Manifest info'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('File Read'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('File Read'), findsOneWidget);
      expect(find.text('Internet Access'), findsOneWidget);
      expect(find.text('Allowed'), findsOneWidget);
      expect(find.text('Ask Every Time'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Permissions review'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Permissions review'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Dock options'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Dock options'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Logs'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Logs'), findsOneWidget);
    },
  );
}
