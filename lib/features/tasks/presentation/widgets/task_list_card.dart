import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colours.dart';

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
    required this.onArchive,
  });

  final Task task;
  final String? projectName;
  final Future<void> Function() onTopThreeToggle;
  final VoidCallback onTap;
  final Future<void> Function() onMoveToToday;
  final Future<void> Function() onMarkDone;
  final Future<void> Function() onPark;
  final Future<void> Function() onArchive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: AppColours.darkSurface.withValues(alpha: 0.94),
      child: InkWell(
        key: Key('taskCard-${task.taskId}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  task.status == 'Done'
                      ? Icons.check_circle_outline
                      : Icons.radio_button_unchecked,
                  color: AppColours.darkSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColours.darkText,
                      ),
                    ),
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
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColours.darkMutedText,
                        ),
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
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColours.darkMutedText,
                        ),
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
                        OutlinedButton.icon(
                          key: Key('taskArchiveButton-${task.taskId}'),
                          onPressed: onArchive,
                          icon: const Icon(Icons.archive_outlined),
                          label: const Text('Archive'),
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
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColours.darkSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
