import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/module_hub_controller.dart';
import '../../core/modules/module_manifest.dart';
import '../../core/modules/module_permissions.dart';
import 'widgets/module_workspace_shell.dart';

class ModulePermissionsScreen extends ConsumerStatefulWidget {
  const ModulePermissionsScreen({super.key, required this.module});

  final ModuleManifest module;

  @override
  ConsumerState<ModulePermissionsScreen> createState() =>
      _ModulePermissionsScreenState();
}

class _ModulePermissionsScreenState
    extends ConsumerState<ModulePermissionsScreen> {
  late final Map<ModulePermissionType, ModulePermissionState> _states;

  @override
  void initState() {
    super.initState();
    _states = {
      for (final permission in widget.module.permissions)
        permission.type: permission.state,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modules = ref.watch(moduleHubModulesProvider);
    final enabledCount = _states.values
        .where((state) => state == ModulePermissionState.allowed)
        .length;
    final askCount = _states.values
        .where((state) => state == ModulePermissionState.askEveryTime)
        .length;
    final disabledCount = _states.values
        .where((state) => state == ModulePermissionState.disabled)
        .length;

    return ModuleWorkspaceShell(
      module: widget.module,
      modules: modules,
      title: '${widget.module.name} Permissions',
      subtitle: 'Local controls and permission review',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Permission summary',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Local UI state only. Permission gating comes later.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('$enabledCount allowed')),
                      Chip(label: Text('$askCount ask every time')),
                      Chip(label: Text('$disabledCount disabled')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.module.permissions.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'This module does not request any permissions yet.',
                ),
              ),
            )
          else
            ...widget.module.permissions.map((permission) {
              final state = _states[permission.type] ?? permission.state;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              permission.label,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          Chip(label: Text(state.label)),
                        ],
                      ),
                      if (permission.notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(permission.notes),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ModulePermissionState.values
                            .map(
                              (value) => ChoiceChip(
                                label: Text(value.label),
                                selected: state == value,
                                onSelected: (_) {
                                  setState(() {
                                    _states[permission.type] = value;
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
