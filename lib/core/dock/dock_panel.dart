import 'package:flutter/material.dart';

import '../modules/module_health.dart';
import '../modules/module_manifest.dart';
import '../modules/module_status.dart';
import 'dock_position.dart';

class DockPanel extends StatelessWidget {
  const DockPanel({
    super.key,
    required this.module,
    required this.position,
    this.actionLabel = 'Start Placeholder',
    this.onAction,
    this.showAssistantStats = false,
  });

  final ModuleManifest module;
  final DockPosition position;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool showAssistantStats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(module.name, style: theme.textTheme.titleMedium),
                ),
                Chip(label: Text(position.label)),
              ],
            ),
            const SizedBox(height: 8),
            Text(module.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(label: 'Status', value: module.status.label),
                _InfoChip(label: 'Health', value: module.health.state.label),
                _InfoChip(
                  label: 'Dockable',
                  value: module.dockable ? 'Yes' : 'No',
                ),
              ],
            ),
            if (showAssistantStats) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _AssistantDockStats(theme: theme),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(onPressed: onAction, child: Text(actionLabel)),
                OutlinedButton(onPressed: () {}, child: const Text('Settings')),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('View Logs'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _AssistantDockStats extends StatelessWidget {
  const _AssistantDockStats({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI Assistant Dock', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        const Text('Status: offline'),
        const Text('Model: not connected'),
        const Text('STT: not connected'),
        const Text('TTS: not connected'),
        const Text('Backend: not running'),
      ],
    );
  }
}
