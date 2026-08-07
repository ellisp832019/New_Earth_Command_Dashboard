import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/dock/dock_position.dart';
import 'package:new_earth_command_dashboard/core/modules/module_category.dart';
import 'package:new_earth_command_dashboard/core/modules/module_health.dart';
import 'package:new_earth_command_dashboard/core/modules/module_manifest.dart';
import 'package:new_earth_command_dashboard/core/modules/module_permissions.dart';
import 'package:new_earth_command_dashboard/core/modules/module_status.dart';
import 'package:new_earth_command_dashboard/features/modules/module_dock_preview.dart';

void main() {
  testWidgets('module dock preview reports dock position changes', (
    tester,
  ) async {
    DockPosition? reportedPosition;

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
      permissions: [ModulePermission(type: ModulePermissionType.fileRead)],
      installPath: 'modules/alpha_module',
      omegaOsPath: 'OMEGA_OS/MODULES/ALPHA_MODULE',
      health: ModuleHealthSnapshot(
        state: ModuleHealthState.warning,
        lastCheckedLabel: '2 minutes ago',
        backendStatus: 'Local shell healthy',
        errors: <String>[],
        warnings: <String>[],
        nextAction: 'Connect the backend health feed.',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Material(
          child: ModuleDockPreview(
            module: module,
            onPositionChanged: (position) {
              reportedPosition = position;
            },
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.widgetWithText(ChoiceChip, 'Right'), findsOneWidget);
    expect(find.text('Start Placeholder'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Bottom'));
    await tester.pump();

    expect(reportedPosition, DockPosition.bottom);
  });
}
