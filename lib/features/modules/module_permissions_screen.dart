import 'package:flutter/material.dart';

import '../../core/modules/module_manifest.dart';
import '../../core/modules/module_permissions.dart';

class ModulePermissionsScreen extends StatefulWidget {
  const ModulePermissionsScreen({super.key, required this.module});

  final ModuleManifest module;

  @override
  State<ModulePermissionsScreen> createState() =>
      _ModulePermissionsScreenState();
}

class _ModulePermissionsScreenState extends State<ModulePermissionsScreen> {
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

    return Scaffold(
      appBar: AppBar(title: Text('${widget.module.name} Permissions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Local UI state only. Permission gating comes later.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
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
