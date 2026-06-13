import 'package:flutter/material.dart';

import '../../core/modules/module_health.dart';
import '../../core/modules/module_manifest.dart';

class ModuleHealthPanel extends StatelessWidget {
  const ModuleHealthPanel({super.key, required this.module});

  final ModuleManifest module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final health = module.health;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Health', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _HealthRow(label: 'State', value: health.state.label),
            _HealthRow(label: 'Last checked', value: health.lastCheckedLabel),
            _HealthRow(label: 'Backend status', value: health.backendStatus),
            _HealthRow(
              label: 'Errors',
              value: health.errors.isEmpty
                  ? 'None recorded'
                  : health.errors.join(' | '),
            ),
            _HealthRow(
              label: 'Warnings',
              value: health.warnings.isEmpty
                  ? 'None recorded'
                  : health.warnings.join(' | '),
            ),
            _HealthRow(label: 'Next action', value: health.nextAction),
          ],
        ),
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
