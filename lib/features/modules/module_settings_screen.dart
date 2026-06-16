import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'application/module_hub_controller.dart';
import '../../core/modules/module_manifest.dart';
import '../../core/routing/route_names.dart';

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

  @override
  void initState() {
    super.initState();
    _localEnabled = widget.module.enabled;
    _notesController = TextEditingController(text: widget.module.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(RouteNames.moduleHub)),
        title: Text('${widget.module.name} Settings'),
      ),
      body: ListView(
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
