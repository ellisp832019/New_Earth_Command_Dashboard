import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/modules/module_manifest.dart';
import '../../core/modules/module_navigation.dart';
import 'application/module_hub_controller.dart';
import 'widgets/module_workspace_shell.dart';

class ModuleSettingsScreen extends ConsumerStatefulWidget {
  const ModuleSettingsScreen({super.key, required this.module});

  final ModuleManifest module;

  @override
  ConsumerState<ModuleSettingsScreen> createState() =>
      _ModuleSettingsScreenState();
}

class _ModuleSettingsScreenState extends ConsumerState<ModuleSettingsScreen> {
  late bool _localEnabled;
  late final TextEditingController _notesController;
  late ModuleLaunchTarget _launchTarget;

  @override
  void initState() {
    super.initState();
    _localEnabled = widget.module.enabled;
    _notesController = TextEditingController(text: widget.module.notes);
    _launchTarget = ref
        .read(moduleHubStateRepositoryProvider)
        .loadLaunchTarget(widget.module.id);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modules = ref.watch(moduleHubModulesProvider);

    return ModuleWorkspaceShell(
      module: widget.module,
      modules: modules,
      title: '${widget.module.name} Settings',
      subtitle: 'Local placeholders and notes',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Settings are local placeholders for now.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            title: const Text('Enabled'),
            subtitle: const Text('Persisted locally'),
            value: _localEnabled,
            onChanged: (value) {
              setState(() {
                _localEnabled = value;
              });
              ref
                  .read(moduleHubModulesProvider.notifier)
                  .setModuleEnabled(widget.module.id, value);
            },
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Launch preference', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Choose where this module opens from the module selector.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ModuleLaunchTarget>(
                    segments: const [
                      ButtonSegment<ModuleLaunchTarget>(
                        value: ModuleLaunchTarget.home,
                        label: Text('Home'),
                        icon: Icon(Icons.home_outlined),
                      ),
                      ButtonSegment<ModuleLaunchTarget>(
                        value: ModuleLaunchTarget.package,
                        label: Text('Package'),
                        icon: Icon(Icons.widgets_outlined),
                      ),
                    ],
                    selected: <ModuleLaunchTarget>{_launchTarget},
                    onSelectionChanged: (selection) async {
                      if (selection.isEmpty) {
                        return;
                      }

                      final next = selection.first;
                      setState(() {
                        _launchTarget = next;
                      });
                      await ref
                          .read(moduleHubStateRepositoryProvider)
                          .saveLaunchTarget(widget.module.id, next);
                    },
                    showSelectedIcon: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
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
                    'Future backend notes',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connect manifest persistence, module startup state, and live settings when the backend phase begins.',
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
