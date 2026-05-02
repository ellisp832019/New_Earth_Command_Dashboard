import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';

class TaskListCard extends StatelessWidget {
  const TaskListCard({
    super.key,
    required this.task,
    required this.projectName,
  });

  final Task task;
  final String? projectName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                task.status == 'Done'
                    ? Icons.check_circle_outline
                    : Icons.radio_button_unchecked,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TaskBadge(label: 'Status: ${task.status}'),
                      _TaskBadge(label: 'Priority: ${task.priority}'),
                      if (projectName != null) _TaskBadge(label: projectName!),
                    ],
                  ),
                  if (task.description != null) ...[
                    const SizedBox(height: 12),
                    Text(task.description!, style: theme.textTheme.bodyMedium),
                  ],
                  if (task.energyLevel != null || task.category != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      [
                        if (task.category != null) 'Category: ${task.category}',
                        if (task.energyLevel != null)
                          'Energy: ${task.energyLevel}',
                      ].join('   '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskBadge extends StatelessWidget {
  const _TaskBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label, style: theme.textTheme.bodySmall),
      ),
    );
  }
}
