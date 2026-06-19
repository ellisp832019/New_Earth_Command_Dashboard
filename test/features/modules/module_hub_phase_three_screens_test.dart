import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/dock/dock_position.dart';
import 'package:new_earth_command_dashboard/core/modules/module_category.dart';
import 'package:new_earth_command_dashboard/core/modules/module_health.dart';
import 'package:new_earth_command_dashboard/core/modules/module_manifest.dart';
import 'package:new_earth_command_dashboard/core/modules/module_permissions.dart';
import 'package:new_earth_command_dashboard/core/modules/module_status.dart';
import 'package:new_earth_command_dashboard/features/modules/module_governance_screen.dart';
import 'package:new_earth_command_dashboard/features/modules/module_operations_screen.dart';

void main() {
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

  testWidgets('module operations screen refreshes the registry locally', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: ModuleOperationsScreen(module: module),
        ),
      ),
    );

    expect(find.text('Module operations'), findsOneWidget);
    expect(find.text('Refresh registry'), findsOneWidget);
    expect(find.text('Inspect settings'), findsOneWidget);
    expect(find.text('Inspect permissions'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.text('Refresh registry'));
    await tester.pump();
    expect(find.text('Registry refreshed locally.'), findsOneWidget);
  });

  testWidgets('module governance screen surfaces approvals and risk checks', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: ModuleGovernanceScreen(module: module),
      ),
    );

    expect(find.text('Safety and governance'), findsOneWidget);
    expect(find.text('Validation checklist'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    expect(find.text('Inspect permissions'), findsOneWidget);
    expect(find.text('Open operations'), findsOneWidget);
    expect(find.text('Inspect docking'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Risk surface'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Risk surface'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Audit trail placeholder'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Audit trail placeholder'), findsOneWidget);
  });
}
