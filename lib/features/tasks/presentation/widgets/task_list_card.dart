import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';

class TaskListCard extends StatelessWidget {
  const TaskListCard({
    super.key,
    required this.task,
    required this.projectName,
    required this.onTopThreeToggle,
    required this.onTap,
    required this.onMoveToToday,
    required this.onMarkDone,
    required this.onPark,
  });

  final Task task;
  final String? projectName;
  final Future<void> Function() onTopThreeToggle;
  final VoidCallback onTap;
  final Future<void> Function() onMoveToToday;
  final Future<void> Function() onMarkDone;
  final Future<void> Function() onPark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        key: Key('taskCard-${task.taskId}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                        if (projectName != null)
                          _TaskBadge(label: projectName!),
                      ],
                    ),
                    if (task.description != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        task.description!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    if (task.energyLevel != null || task.category != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        [
                          if (task.category != null)
                            'Category: ${task.category}',
                          if (task.energyLevel != null)
                            'Energy: ${task.energyLevel}',
                        ].join('   '),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (task.status != 'Today' && task.status != 'Done')
                          OutlinedButton.icon(
                            key: Key('taskMoveToTodayButton-${task.taskId}'),
                            onPressed: onMoveToToday,
                            icon: const Icon(Icons.today_outlined),
                            label: const Text('Move To Today'),
                          ),
                        if (task.status != 'Done')
                          FilledButton.tonalIcon(
                            key: Key('taskDoneButton-${task.taskId}'),
                            onPressed: onMarkDone,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Mark Done'),
                          ),
                        if (task.status != 'Parked')
                          OutlinedButton.icon(
                            key: Key('taskParkButton-${task.taskId}'),
                            onPressed: onPark,
                            icon: const Icon(Icons.inventory_2_outlined),
                            label: const Text('Park'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        key: Key('taskTopThreeButton-${task.taskId}'),
                        onPressed: onTopThreeToggle,
                        icon: Icon(
                          task.isTopThree
                              ? Icons.filter_3
                              : Icons.filter_3_outlined,
                        ),
                        label: Text(
                          task.isTopThree
                              ? 'Remove From Top 3'
                              : 'Mark As Top 3',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
