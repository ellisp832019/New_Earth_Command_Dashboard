import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colours.dart';

enum _TaskMenuAction {
  edit,
  openProject,
  copyTitle,
  moveToInbox,
  moveToPlanned,
  moveToToday,
  markDone,
  markBlocked,
  park,
  archive,
  toggleTopThree,
}

class TaskListCard extends StatelessWidget {
  const TaskListCard({
    super.key,
    required this.task,
    required this.projectName,
    required this.onTopThreeToggle,
    required this.onTap,
    required this.onMoveToInbox,
    required this.onMoveToPlanned,
    required this.onMoveToToday,
    required this.onMarkDone,
    required this.onBlock,
    required this.onPark,
    required this.onArchive,
    this.onOpenProject,
  });

  final Task task;
  final String? projectName;
  final Future<void> Function() onTopThreeToggle;
  final VoidCallback onTap;
  final Future<void> Function() onMoveToInbox;
  final Future<void> Function() onMoveToPlanned;
  final Future<void> Function() onMoveToToday;
  final Future<void> Function() onMarkDone;
  final Future<void> Function() onBlock;
  final Future<void> Function() onPark;
  final Future<void> Function() onArchive;
  final VoidCallback? onOpenProject;

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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColours.darkText,
                            ),
                          ),
                        ),
                        PopupMenuButton<_TaskMenuAction>(
                          tooltip: 'More actions',
                          icon: const Icon(Icons.more_horiz),
                          onSelected: (action) =>
                              _handleMenuAction(context, action),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: _TaskMenuAction.edit,
                              child: ListTile(
                                dense: true,
                                leading: Icon(Icons.edit_outlined),
                                title: Text('Edit task'),
                              ),
                            ),
                            if (onOpenProject != null)
                              const PopupMenuItem(
                                value: _TaskMenuAction.openProject,
                                child: ListTile(
                                  dense: true,
                                  leading: Icon(Icons.folder_open_outlined),
                                  title: Text('Open project'),
                                ),
                              ),
                            const PopupMenuItem(
                              value: _TaskMenuAction.copyTitle,
                              child: ListTile(
                                dense: true,
                                leading: Icon(Icons.copy_outlined),
                                title: Text('Copy title'),
                              ),
                            ),
                            if (task.status != 'Inbox')
                              const PopupMenuItem(
                                value: _TaskMenuAction.moveToInbox,
                                child: ListTile(
                                  dense: true,
                                  leading: Icon(Icons.inbox_outlined),
                                  title: Text('Move to Inbox'),
                                ),
                              ),
                            if (task.status != 'Planned')
                              const PopupMenuItem(
                                value: _TaskMenuAction.moveToPlanned,
                                child: ListTile(
                                  dense: true,
                                  leading: Icon(Icons.event_note_outlined),
                                  title: Text('Move to Planned'),
                                ),
                              ),
                            if (task.status != 'Today' && task.status != 'Done')
                              const PopupMenuItem(
                                value: _TaskMenuAction.moveToToday,
                                child: ListTile(
                                  dense: true,
                                  leading: Icon(Icons.today_outlined),
                                  title: Text('Move to Today'),
                                ),
                              ),
                            if (task.status != 'Done')
                              const PopupMenuItem(
                                value: _TaskMenuAction.markDone,
                                child: ListTile(
                                  dense: true,
                                  leading: Icon(Icons.check_circle_outline),
                                  title: Text('Mark Done'),
                                ),
                              ),
                            if (task.status != 'Blocked')
                              const PopupMenuItem(
                                value: _TaskMenuAction.markBlocked,
                                child: ListTile(
                                  dense: true,
                                  leading: Icon(Icons.block_outlined),
                                  title: Text('Mark Blocked'),
                                ),
                              ),
                            if (task.status != 'Parked')
                              const PopupMenuItem(
                                value: _TaskMenuAction.park,
                                child: ListTile(
                                  dense: true,
                                  leading: Icon(Icons.inventory_2_outlined),
                                  title: Text('Park'),
                                ),
                              ),
                            const PopupMenuItem(
                              value: _TaskMenuAction.archive,
                              child: ListTile(
                                dense: true,
                                leading: Icon(Icons.archive_outlined),
                                title: Text('Archive'),
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: _TaskMenuAction.toggleTopThree,
                              child: ListTile(
                                dense: true,
                                leading: Icon(Icons.filter_3_outlined),
                                title: Text('Toggle Top 3'),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                    _SmartTaskHint(
                      task: task,
                      onMarkDone: onMarkDone,
                      onBlock: onBlock,
                      onMoveToToday: onMoveToToday,
                      onMoveToInbox: onMoveToInbox,
                      onMoveToPlanned: onMoveToPlanned,
                      onPark: onPark,
                      onArchive: onArchive,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _quickActionButtons(),
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

  Future<void> _handleMenuAction(
    BuildContext context,
    _TaskMenuAction action,
  ) async {
    switch (action) {
      case _TaskMenuAction.edit:
        onTap();
        return;
      case _TaskMenuAction.openProject:
        onOpenProject?.call();
        return;
      case _TaskMenuAction.copyTitle:
        await Clipboard.setData(ClipboardData(text: task.title));
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Task title copied.')));
        return;
      case _TaskMenuAction.moveToInbox:
        await onMoveToInbox();
        return;
      case _TaskMenuAction.moveToPlanned:
        await onMoveToPlanned();
        return;
      case _TaskMenuAction.moveToToday:
        await onMoveToToday();
        return;
      case _TaskMenuAction.markDone:
        await onMarkDone();
        return;
      case _TaskMenuAction.markBlocked:
        await onBlock();
        return;
      case _TaskMenuAction.park:
        await onPark();
        return;
      case _TaskMenuAction.archive:
        await onArchive();
        return;
      case _TaskMenuAction.toggleTopThree:
        await onTopThreeToggle();
        return;
    }
  }
}

class _SmartTaskHint extends StatelessWidget {
  const _SmartTaskHint({
    required this.task,
    required this.onMarkDone,
    required this.onBlock,
    required this.onMoveToToday,
    required this.onMoveToInbox,
    required this.onMoveToPlanned,
    required this.onPark,
    required this.onArchive,
  });

  final Task task;
  final Future<void> Function() onMarkDone;
  final Future<void> Function() onBlock;
  final Future<void> Function() onMoveToToday;
  final Future<void> Function() onMoveToInbox;
  final Future<void> Function() onMoveToPlanned;
  final Future<void> Function() onPark;
  final Future<void> Function() onArchive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = _suggestionFor(task);

    if (data == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.heading,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.detail,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (data.primary != null)
                FilledButton.icon(
                  onPressed: data.primary == _SmartTaskPrimary.moveToToday
                      ? onMoveToToday
                      : data.primary == _SmartTaskPrimary.markDone
                      ? onMarkDone
                      : data.primary == _SmartTaskPrimary.markBlocked
                      ? onBlock
                      : data.primary == _SmartTaskPrimary.moveToInbox
                      ? onMoveToInbox
                      : data.primary == _SmartTaskPrimary.moveToPlanned
                      ? onMoveToPlanned
                      : data.primary == _SmartTaskPrimary.park
                      ? onPark
                      : onArchive,
                  icon: Icon(data.primary!.icon),
                  label: Text(data.primary!.label),
                ),
              if (data.secondary != null)
                OutlinedButton.icon(
                  onPressed: data.secondary == _SmartTaskPrimary.moveToToday
                      ? onMoveToToday
                      : data.secondary == _SmartTaskPrimary.markDone
                      ? onMarkDone
                      : data.secondary == _SmartTaskPrimary.markBlocked
                      ? onBlock
                      : data.secondary == _SmartTaskPrimary.moveToInbox
                      ? onMoveToInbox
                      : data.secondary == _SmartTaskPrimary.moveToPlanned
                      ? onMoveToPlanned
                      : data.secondary == _SmartTaskPrimary.park
                      ? onPark
                      : onArchive,
                  icon: Icon(data.secondary!.icon),
                  label: Text(data.secondary!.label),
                ),
            ],
          ),
        ],
      ),
    );
  }

  _SmartTaskSuggestion? _suggestionFor(Task task) {
    switch (task.status) {
      case 'Inbox':
        return _SmartTaskSuggestion(
          heading: 'Suggested next step: get this onto today\'s radar.',
          detail:
              'Move it into Today if it is ready, or park it if it should wait.',
          primary: _SmartTaskPrimary.moveToToday,
          secondary: _SmartTaskPrimary.moveToPlanned,
        );
      case 'Planned':
        return _SmartTaskSuggestion(
          heading: 'Suggested next step: pull this into focus.',
          detail:
              'Planned work is easier to finish when it becomes visible in Today. Block it if you are waiting on something.',
          primary: _SmartTaskPrimary.moveToToday,
          secondary: _SmartTaskPrimary.markBlocked,
        );
      case 'Today':
        return _SmartTaskSuggestion(
          heading: 'Suggested next step: close the loop or protect the focus.',
          detail: task.isTopThree
              ? 'This is already protected in the Top 3. Finish it when the work is done.'
              : 'If this is one of the three most important tasks, protect it now. Block it if you are waiting on something.',
          primary: _SmartTaskPrimary.markDone,
          secondary: _SmartTaskPrimary.park,
        );
      case 'Blocked':
        return _SmartTaskSuggestion(
          heading: 'Suggested next step: clear the blockage or park it.',
          detail:
              'Use Planned if it needs a revisit, or park it if it is not ready yet.',
          primary: _SmartTaskPrimary.moveToPlanned,
          secondary: _SmartTaskPrimary.park,
        );
      case 'Parked':
        return _SmartTaskSuggestion(
          heading: 'Suggested next step: reopen only if it matters now.',
          detail:
              'Bring it back to Inbox or Today, or archive it if it is truly finished.',
          primary: _SmartTaskPrimary.moveToInbox,
          secondary: _SmartTaskPrimary.moveToToday,
        );
      case 'Done':
        return _SmartTaskSuggestion(
          heading: 'Suggested next step: clear it from the active list.',
          detail:
              'Archive completed work so the active task list stays calm and useful.',
          primary: _SmartTaskPrimary.archive,
        );
      default:
        return _SmartTaskSuggestion(
          heading: 'Suggested next step: move this into a clearer state.',
          detail:
              'The task is active, so choose the smallest move that makes the day clearer, or mark it blocked if it is waiting on someone else.',
          primary: _SmartTaskPrimary.moveToToday,
          secondary: _SmartTaskPrimary.markBlocked,
        );
    }
  }
}

class _SmartTaskSuggestion {
  const _SmartTaskSuggestion({
    required this.heading,
    required this.detail,
    this.primary,
    this.secondary,
  });

  final String heading;
  final String detail;
  final _SmartTaskPrimary? primary;
  final _SmartTaskPrimary? secondary;
}

enum _SmartTaskPrimary {
  moveToToday(Icons.today_outlined, 'Move To Today'),
  markDone(Icons.check_circle_outline, 'Mark Done'),
  markBlocked(Icons.block_outlined, 'Mark Blocked'),
  moveToInbox(Icons.inbox_outlined, 'Move To Inbox'),
  moveToPlanned(Icons.event_note_outlined, 'Move To Planned'),
  park(Icons.inventory_2_outlined, 'Park'),
  archive(Icons.archive_outlined, 'Archive');

  const _SmartTaskPrimary(this.icon, this.label);

  final IconData icon;
  final String label;
}

extension on TaskListCard {
  List<Widget> _quickActionButtons() {
    return [
      if (task.status != 'Today' && task.status != 'Done')
        OutlinedButton.icon(
          key: Key('taskMoveToTodayButton-${task.taskId}'),
          onPressed: onMoveToToday,
          icon: const Icon(Icons.today_outlined),
          label: const Text('Move To Today'),
        ),
      if (task.status != 'Planned')
        OutlinedButton.icon(
          key: Key('taskMoveToPlannedButton-${task.taskId}'),
          onPressed: onMoveToPlanned,
          icon: const Icon(Icons.event_note_outlined),
          label: const Text('Move To Planned'),
        ),
      if (task.status != 'Blocked')
        OutlinedButton.icon(
          key: Key('taskBlockButton-${task.taskId}'),
          onPressed: onBlock,
          icon: const Icon(Icons.block_outlined),
          label: const Text('Mark Blocked'),
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
    ];
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
