import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dock/dock_position.dart';
import '../../core/modules/module_event_bus.dart';
import '../../core/modules/module_manifest.dart';
import '../../core/modules/module_status.dart';
import '../../core/routing/route_names.dart';
import 'application/module_hub_controller.dart';
import 'module_dock_preview.dart';
import 'widgets/module_workspace_shell.dart';

class ModuleDockingScreen extends ConsumerStatefulWidget {
  const ModuleDockingScreen({super.key, required this.module});

  final ModuleManifest module;

  @override
  ConsumerState<ModuleDockingScreen> createState() =>
      _ModuleDockingScreenState();
}

class _ModuleDockingScreenState extends ConsumerState<ModuleDockingScreen> {
  late DockPosition _selectedPosition;
  bool _pinnedLocally = false;

  @override
  void initState() {
    super.initState();
    final savedPosition = ref
        .read(moduleHubStateRepositoryProvider)
        .loadDockLayoutState()
        .positionFor(widget.module.id);
    _selectedPosition = savedPosition ?? widget.module.defaultDockPosition;
  }

  Future<void> _saveDockPosition(DockPosition position) async {
    await ref
        .read(moduleHubStateRepositoryProvider)
        .saveDockPosition(widget.module.id, position);
    ref
        .read(moduleEventBusProvider)
        .publish(
          ModuleEvent(
            moduleId: widget.module.id,
            type: ModuleEventType.dockPositionChanged,
            timestamp: DateTime.now(),
            message: 'Dock position saved locally.',
            details: <String, dynamic>{'position': position.name},
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modules = ref.watch(moduleHubModulesProvider);

    return ModuleWorkspaceShell(
      module: widget.module,
      modules: modules,
      title: '${widget.module.name} Docking',
      subtitle: 'Layout and docking',
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
                    module: widget.module.copyWith(
                      defaultDockPosition: _selectedPosition,
                    ),
                    initialPosition: _selectedPosition,
                    showAssistantDockPlaceholder:
                        widget.module.id == 'module_hub',
                    onPositionChanged: (position) {
                      setState(() {
                        _selectedPosition = position;
                      });
                      unawaited(_saveDockPosition(position));
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
                  Text(
                    'Placement snapshot',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Default dock',
                    value: _selectedPosition.label,
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
              'Use operations when you need to refresh the local module view or inspect local module paths.',
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
