import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/modules/module_health.dart';
import '../../core/modules/module_manifest.dart';
import '../../core/modules/module_permissions.dart';
import '../../core/routing/route_names.dart';

class ModuleGovernanceScreen extends StatelessWidget {
  const ModuleGovernanceScreen({super.key, required this.module});

  final ModuleManifest module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskyPermissions = _riskyPermissions(module.permissions);
    final checks = _buildChecks(riskyPermissions);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(RouteNames.moduleHub)),
        title: Text('${module.name} Governance'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Safety and governance',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keep module changes explicit, validate the manifest surface, and surface risk before anything destructive or sensitive is wired in.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonal(
                        onPressed: () {
                          context.push(
                            RouteNames.moduleHubModulePermissions(module.id),
                          );
                        },
                        child: const Text('Inspect permissions'),
                      ),
                      FilledButton.tonal(
                        onPressed: () {
                          context.push(
                            RouteNames.moduleHubModuleOperations(module.id),
                          );
                        },
                        child: const Text('Open operations'),
                      ),
                      FilledButton.tonal(
                        onPressed: () {
                          context.push(
                            RouteNames.moduleHubModuleDocking(module.id),
                          );
                        },
                        child: const Text('Inspect docking'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Validation checklist',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...checks.map(
                    (check) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            check.isPassing
                                ? Icons.check_circle_outline
                                : Icons.warning_amber_outlined,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  check.title,
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(check.description),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Risk surface', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    riskyPermissions.isEmpty
                        ? 'No sensitive permissions are flagged right now.'
                        : 'Sensitive permissions should keep a dedicated approval step.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  if (riskyPermissions.isEmpty)
                    const Text('Nothing is flagged for extra approval.')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: riskyPermissions
                          .map(
                            (permission) => Chip(label: Text(permission.label)),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Audit trail placeholder',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  const Text('Module manifest loaded locally.'),
                  const SizedBox(height: 8),
                  const Text('Enabled state restored from the local registry.'),
                  const SizedBox(height: 8),
                  const Text(
                    'Permissions reviewed before any future approval flow.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<ModulePermission> _riskyPermissions(List<ModulePermission> permissions) {
    const sensitiveTypes = {
      ModulePermissionType.browserControl,
      ModulePermissionType.fileWrite,
      ModulePermissionType.internetAccess,
      ModulePermissionType.mouseKeyboardControl,
      ModulePermissionType.shellCommands,
      ModulePermissionType.omegaOsAccess,
      ModulePermissionType.appLaunch,
    };

    return permissions
        .where((permission) => sensitiveTypes.contains(permission.type))
        .toList(growable: false);
  }

  List<_GovernanceCheck> _buildChecks(List<ModulePermission> riskyPermissions) {
    return [
      _GovernanceCheck(
        title: 'Manifest shape',
        description: module.notes.isNotEmpty
            ? 'Notes are present and can guide future review.'
            : 'Add notes so future reviewers know why this module exists.',
        isPassing: module.notes.isNotEmpty,
      ),
      _GovernanceCheck(
        title: 'Health state',
        description: module.health.state == ModuleHealthState.error
            ? 'This module is in an error state and needs review.'
            : 'Current health can be reviewed without opening a backend.',
        isPassing: module.health.state != ModuleHealthState.error,
      ),
      _GovernanceCheck(
        title: 'Permission risk',
        description: riskyPermissions.isEmpty
            ? 'No sensitive permissions are currently flagged.'
            : '${riskyPermissions.length} sensitive permission(s) should be reviewed separately.',
        isPassing: riskyPermissions.isEmpty,
      ),
      _GovernanceCheck(
        title: 'Dock policy',
        description: module.dockable
            ? 'This module can be placed on a dock surface.'
            : 'This module stays screen-first until a dock policy is added.',
        isPassing: true,
      ),
    ];
  }
}

class _GovernanceCheck {
  const _GovernanceCheck({
    required this.title,
    required this.description,
    required this.isPassing,
  });

  final String title;
  final String description;
  final bool isPassing;
}
