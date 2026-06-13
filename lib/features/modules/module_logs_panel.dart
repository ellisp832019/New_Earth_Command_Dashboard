import 'package:flutter/material.dart';

import '../../core/modules/module_manifest.dart';

class ModuleLogsPanel extends StatelessWidget {
  const ModuleLogsPanel({super.key, required this.module});

  final ModuleManifest module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = <_LogEntry>[
      _LogEntry(
        icon: Icons.info_outline,
        title: 'Local shell ready',
        subtitle: 'Placeholder record for ${module.name}.',
      ),
      if (module.health.warnings.isNotEmpty)
        ...module.health.warnings.map(
          (warning) => _LogEntry(
            icon: Icons.warning_amber_outlined,
            title: 'Warning',
            subtitle: warning,
          ),
        ),
      if (module.health.errors.isNotEmpty)
        ...module.health.errors.map(
          (error) => _LogEntry(
            icon: Icons.error_outline,
            title: 'Error',
            subtitle: error,
          ),
        ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Logs', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(
              'Placeholder only. Real live logs come later.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ...entries.map(
              (entry) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(entry.icon),
                title: Text(entry.title),
                subtitle: Text(entry.subtitle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogEntry {
  const _LogEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
