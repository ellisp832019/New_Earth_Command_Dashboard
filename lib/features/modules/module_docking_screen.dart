import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/dock/dock_position.dart';
import '../../core/modules/module_manifest.dart';
import '../../core/modules/module_status.dart';
import '../../core/routing/route_names.dart';
import 'module_dock_preview.dart';

class ModuleDockingScreen extends StatefulWidget {
  const ModuleDockingScreen({super.key, required this.module});

  final ModuleManifest module;

  @override
  State<ModuleDockingScreen> createState() => _ModuleDockingScreenState();
}

class _ModuleDockingScreenState extends State<ModuleDockingScreen> {
  bool _pinnedLocally = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('${widget.module.name} Docking'),
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
                    'Layout and docking',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preview where this module belongs in the dashboard and keep a local note of the preferred placement.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Pin locally'),
                    subtitle: const Text('Dashboard shortcut only for now'),
                    value: _pinnedLocally,
                    onChanged: (value) {
                      setState(() {
                        _pinnedLocally = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'Pinned locally for layout planning.'
                                : 'Local pin removed.',
                          ),
                        ),
                      );
                    },
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
                  Text('Dock preview', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ModuleDockPreview(
                    module: widget.module,
                    initialPosition: widget.module.defaultDockPosition,
                    showAssistantDockPlaceholder:
                        widget.module.id == 'module_hub',
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
                    'Placement snapshot',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Default dock',
                    value: widget.module.defaultDockPosition.label,
                  ),
                  _InfoRow(
                    label: 'Dockable',
                    value: widget.module.dockable ? 'Yes' : 'No',
                  ),
                  _InfoRow(
                    label: 'Pinned locally',
                    value: _pinnedLocally ? 'Yes' : 'No',
                  ),
                  _InfoRow(
                    label: 'Module status',
                    value: widget.module.status.label,
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
                  Text('Pinned shortcuts', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    widget.module.tags.isEmpty
                        ? 'No shortcut tags are defined yet.'
                        : widget.module.tags.join(' · '),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dock launch surfaced locally.'),
                        ),
                      );
                    },
                    child: const Text('Launch into dock surface'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ModuleOperationsLinkCard(module: widget.module),
        ],
      ),
    );
  }
}

class ModuleOperationsLinkCard extends StatelessWidget {
  const ModuleOperationsLinkCard({super.key, required this.module});

  final ModuleManifest module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Next place to open', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Use operations when you need to refresh the registry or inspect local module paths.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () {
                context.push(RouteNames.moduleHubModuleOperations(module.id));
              },
              child: const Text('Inspect operations'),
            ),
          ],
        ),
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
            width: 140,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
