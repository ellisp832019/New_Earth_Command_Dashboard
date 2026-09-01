import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/modules/module_manifest.dart';
import '../../core/modules/module_status.dart';
import '../../core/routing/route_names.dart';
import 'application/module_hub_controller.dart';
import 'widgets/module_workspace_shell.dart';

class ModuleOperationsScreen extends ConsumerWidget {
  const ModuleOperationsScreen({super.key, required this.module});

  final ModuleManifest module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final modules = ref.watch(moduleHubModulesProvider);

    return ModuleWorkspaceShell(
      module: module,
      modules: modules,
      title: '${module.name} Operations',
      subtitle: module.description,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Module operations', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Keep the local module view current, inspect install paths, and stage module changes safely before any deeper automation arrives.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonal(
                        onPressed: () async {
                          await ref
                              .read(moduleHubModulesProvider.notifier)
                              .reload();
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Registry refreshed locally.'),
                            ),
                          );
                        },
                        child: const Text('Refresh registry'),
                      ),
                      FilledButton.tonal(
                        onPressed: () async {
                          await ref
                              .read(moduleHubModulesProvider.notifier)
                              .reload();
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Module folders rescanned.'),
                            ),
                          );
                        },
                        child: const Text('Rescan folders'),
                      ),
                      FilledButton.tonal(
                        onPressed: () {
                          context.push(
                            RouteNames.moduleHubModuleSettings(module.id),
                          );
                        },
                        child: const Text('Inspect settings'),
                      ),
                      FilledButton.tonal(
                        onPressed: () {
                          context.push(
                            RouteNames.moduleHubModulePermissions(module.id),
                          );
                        },
                        child: const Text('Inspect permissions'),
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
                    'Local install surface',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Install path', value: module.installPath),
                  _InfoRow(label: 'Omega OS path', value: module.omegaOsPath),
                  _InfoRow(label: 'Current state', value: module.status.label),
                  _InfoRow(
                    label: 'Enabled locally',
                    value: module.enabled ? 'Yes' : 'No',
                  ),
                  _InfoRow(
                    label: 'Dockable',
                    value: module.dockable ? 'Yes' : 'No',
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
                    'Import and archive notes',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Install, import, archive, and remove flows stay read-only until a safe confirmation design is ready. This page gives us a structured place to wire them in later.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      Chip(label: Text('Install / Import later')),
                      Chip(label: Text('Archive / Remove later')),
                      Chip(label: Text('Update check later')),
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
                    'Next places to inspect',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonal(
                        onPressed: () {
                          context.push(
                            RouteNames.moduleHubModuleDocking(module.id),
                          );
                        },
                        child: const Text('Docking'),
                      ),
                      FilledButton.tonal(
                        onPressed: () {
                          context.push(
                            RouteNames.moduleHubModuleGovernance(module.id),
                          );
                        },
                        child: const Text('Governance'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
