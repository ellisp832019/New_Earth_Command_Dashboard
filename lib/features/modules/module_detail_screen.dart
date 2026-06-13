import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/dock/dock_position.dart';
import '../../core/modules/module_category.dart';
import '../../core/modules/module_permissions.dart';
import '../../core/modules/module_manifest.dart';
import '../../core/modules/module_status.dart';
import '../../core/routing/route_names.dart';
import 'module_dock_preview.dart';
import 'module_health_panel.dart';
import 'module_logs_panel.dart';

class ModuleDetailScreen extends StatelessWidget {
  const ModuleDetailScreen({super.key, required this.module});

  final ModuleManifest module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(module.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(module.description, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text(module.category.label)),
                      Chip(label: Text(module.status.label)),
                      Chip(label: Text('v${module.version}')),
                      Chip(
                        label: Text(
                          'Enabled: ${module.enabled ? 'Yes' : 'No'}',
                        ),
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
                  Text('Manifest Info', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Module ID', value: module.id),
                  _InfoRow(label: 'Install path', value: module.installPath),
                  _InfoRow(label: 'Omega OS path', value: module.omegaOsPath),
                  _InfoRow(label: 'Version', value: module.version),
                  _InfoRow(label: 'Category', value: module.category.label),
                  _InfoRow(label: 'Current status', value: module.status.label),
                  _InfoRow(
                    label: 'Enabled state',
                    value: module.enabled ? 'Enabled' : 'Disabled',
                  ),
                  _InfoRow(
                    label: 'Dockable',
                    value: module.dockable ? 'Yes' : 'No',
                  ),
                  _InfoRow(
                    label: 'Default dock position',
                    value: module.defaultDockPosition.label,
                  ),
                  _InfoRow(
                    label: 'Permissions',
                    value: '${module.permissions.length} defined',
                  ),
                  _InfoRow(
                    label: 'Tags',
                    value: module.tags.isEmpty
                        ? 'None'
                        : module.tags.join(', '),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ModuleHealthPanel(module: module),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Permissions', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '${module.permissions.length} permission(s) requested.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: module.permissions
                        .map(
                          (permission) => Chip(
                            label: Text(
                              '${permission.label} · ${permission.state.label}',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () {
                      context.push(
                        RouteNames.moduleHubModulePermissions(module.id),
                      );
                    },
                    child: const Text('Open permissions'),
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
                  Text('Dock Options', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(
                    module.dockable
                        ? 'This module can be previewed in multiple dock positions.'
                        : 'This module is treated as a screen-first system core module.',
                  ),
                  const SizedBox(height: 12),
                  ModuleDockPreview(
                    module: module,
                    initialPosition: module.defaultDockPosition,
                    showAssistantDockPlaceholder: module.id == 'module_hub',
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
                    'Settings Placeholder',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('No persisted settings yet.'),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () {
                      context.push(
                        RouteNames.moduleHubModuleSettings(module.id),
                      );
                    },
                    child: const Text('Open settings'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ModuleLogsPanel(module: module),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Omega OS Link Placeholder',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(module.omegaOsPath),
                  const SizedBox(height: 8),
                  const Text(
                    'Wire the real Omega OS record open action later.',
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
                    'Future Backend Notes',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    module.notes.isEmpty
                        ? 'Use this area for backend integration notes later.'
                        : module.notes,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              context.push(RouteNames.moduleHubModulePermissions(module.id));
            },
            child: const Text('Review permissions'),
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
            width: 170,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
