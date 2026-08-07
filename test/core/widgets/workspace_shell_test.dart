import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/dock/dock_position.dart';
import 'package:new_earth_command_dashboard/core/modules/module_category.dart';
import 'package:new_earth_command_dashboard/core/modules/module_health.dart';
import 'package:new_earth_command_dashboard/core/modules/module_manifest.dart';
import 'package:new_earth_command_dashboard/core/modules/module_status.dart';
import 'package:new_earth_command_dashboard/core/widgets/workspace_shell.dart';
import 'package:new_earth_command_dashboard/features/modules/widgets/module_workspace_shell.dart';

void main() {
  testWidgets('workspace shell renders a calm shared frame', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: WorkspaceShell(
          title: 'Company Command Centre',
          subtitle: 'Local-first company operations',
          onBack: () {},
          child: const Center(child: Text('Workspace content')),
        ),
      ),
    );

    expect(find.text('Company Command Centre'), findsOneWidget);
    expect(find.text('Local-first company operations'), findsOneWidget);
    expect(find.text('Workspace content'), findsOneWidget);
  });

  testWidgets('module workspace shell keeps the module selector stable', (
    tester,
  ) async {
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
      permissions: [],
      installPath: 'modules/alpha_module',
      omegaOsPath: 'OMEGA_OS/MODULES/ALPHA_MODULE',
      health: ModuleHealthSnapshot(
        state: ModuleHealthState.healthy,
        lastCheckedLabel: 'just now',
        backendStatus: 'Healthy',
        errors: [],
        warnings: [],
        nextAction: 'Keep going.',
      ),
      tags: ['alpha'],
      notes: '',
    );

    const secondaryModule = ModuleManifest(
      id: 'beta_module',
      name: 'Beta Module',
      description: 'Secondary local control.',
      category: ModuleCategory.systemCore,
      version: '1.0.0',
      status: ModuleStatus.enabled,
      enabled: true,
      dockable: true,
      defaultDockPosition: DockPosition.left,
      permissions: [],
      installPath: 'modules/beta_module',
      omegaOsPath: 'OMEGA_OS/MODULES/BETA_MODULE',
      health: ModuleHealthSnapshot(
        state: ModuleHealthState.healthy,
        lastCheckedLabel: 'just now',
        backendStatus: 'Healthy',
        errors: [],
        warnings: [],
        nextAction: 'Keep going.',
      ),
      tags: ['beta'],
      notes: '',
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: ModuleWorkspaceShell(
            module: module,
            modules: [module, secondaryModule, module],
            title: 'Alpha Module',
            subtitle: 'Calm local control for the alpha workflow.',
            child: const Text('Module body'),
          ),
        ),
      ),
    );

    expect(find.text('Alpha Module'), findsWidgets);
    expect(
      find.text('Calm local control for the alpha workflow.'),
      findsWidgets,
    );
    expect(find.text('Module body'), findsOneWidget);
    expect(find.byKey(const Key('module-switcher-dropdown')), findsOneWidget);
  });
}
