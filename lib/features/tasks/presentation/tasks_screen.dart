import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../../planner/application/planner_controller.dart';
import '../../projects/application/projects_controller.dart';
import '../application/tasks_controller.dart';
import 'widgets/task_list_card.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  static const statusFilterOptions = [
    'All',
    'Inbox',
    'Today',
    'Planned',
    'In Progress',
    'Blocked',
    'Done',
    'Parked',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tasks = ref.watch(tasksProvider);
    final projects = ref.watch(projectsProvider);
    final todayPlan = ref.watch(todayPlanProvider);
    final statusFilter = ref.watch(selectedTaskStatusFilterProvider);
    final projectFilter = ref.watch(selectedTaskProjectFilterProvider);
    final searchQuery = ref.watch(taskSearchQueryProvider);

    return WorkspaceShell(
      title: 'Tasks',
      subtitle: 'Current Tasks',
      onBack: () => context.go(RouteNames.dashboard),
      trailingActions: [
        FilledButton.icon(
          key: const Key('addTaskButton'),
          onPressed: () => context.push(RouteNames.newTask),
          icon: const Icon(Icons.add_task_outlined),
          label: const Text('Add Task'),
        ),
        FilledButton.tonalIcon(
          onPressed: () => context.push(RouteNames.planner),
          icon: const Icon(Icons.event_note_outlined),
          label: const Text('Open Planner'),
        ),
      ],
      child: tasks.when(
        data: (taskItems) => projects.when(
          data: (projectItems) => todayPlan.when(
            data: (plan) => _TaskListView(
              tasks: taskItems,
              projects: projectItems,
              todayPlan: plan,
              statusFilter: statusFilter,
              projectFilter: projectFilter,
              searchQuery: searchQuery,
              topTaskIds: [
                plan.topTask1Id,
                plan.topTask2Id,
                plan.topTask3Id,
              ].whereType<String>().toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Tasks could not be loaded. Try again in a moment.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Tasks could not be loaded. Try again in a moment.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Tasks could not be loaded. Try again in a moment.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskListView extends ConsumerWidget {
  const _TaskListView({
    required this.tasks,
    required this.projects,
    required this.todayPlan,
    required this.statusFilter,
    required this.projectFilter,
    required this.searchQuery,
    required this.topTaskIds,
  });

  final List<Task> tasks;
  final List<Project> projects;
  final DailyPlan todayPlan;
  final String statusFilter;
  final String? projectFilter;
  final String searchQuery;
  final List<String> topTaskIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final normalizedQuery = searchQuery.trim().toLowerCase();
    final projectNames = {
      for (final project in projects) project.projectId: project.name,
    };
    final filteredTasks = tasks.where((task) {
      final matchesStatus =
          statusFilter == 'All' || task.status == statusFilter;
      final matchesProject =
          projectFilter == null || task.projectId == projectFilter;
      final matchesSearch =
          normalizedQuery.isEmpty ||
          task.title.toLowerCase().contains(normalizedQuery) ||
          (task.notes?.toLowerCase().contains(normalizedQuery) ?? false);
      return matchesStatus && matchesProject && matchesSearch;
    }).toList();
    final topThreeCount = topTaskIds.length;
    final parkedCount = tasks.where((task) => task.status == 'Parked').length;
    final blockedCount = tasks.where((task) => task.status == 'Blocked').length;
    final todayCount = tasks.where((task) => task.status == 'Today').length;
    final carryForwardNotes = todayPlan.carryForwardNotes?.trim() ?? '';
    final showCarryForwardBanner =
        parkedCount > 0 || carryForwardNotes.isNotEmpty;
    final carryForwardBanner = showCarryForwardBanner
        ? _CarryForwardBanner(
            parkedCount: parkedCount,
            carryForwardNotes: carryForwardNotes,
            onReviewParked: () => _showParkedWork(ref),
            onOpenPlanner: () => context.push('${RouteNames.planner}?section=carryForward'),
          )
        : null;

    final headerPanel = Container(
      padding: const EdgeInsets.all(22),
      decoration: _tasksPagePanelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compactHeader = constraints.maxWidth < 700;

              final titleBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tasks',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: AppColours.darkText,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current Tasks',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColours.darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${filteredTasks.length} tasks are visible in the current task view.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColours.darkMutedText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${topTaskIds.length} of 3 priority tasks selected for today.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColours.darkMutedText,
                    ),
                  ),
                ],
              );

              if (compactHeader) {
                return titleBlock;
              }

              return titleBlock;
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TaskSummaryChip(
                label: 'Visible',
                value: '${filteredTasks.length}',
              ),
              _TaskSummaryChip(label: 'Top 3', value: '$topThreeCount / 3'),
              _TaskSummaryChip(label: 'Today', value: '$todayCount'),
              _TaskSummaryChip(label: 'Parked', value: '$parkedCount'),
              _TaskSummaryChip(label: 'Blocked', value: '$blockedCount'),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('taskSearchField'),
            controller: TextEditingController(text: searchQuery)
              ..selection = TextSelection.collapsed(offset: searchQuery.length),
            decoration: InputDecoration(
              labelText: 'Search Tasks',
              hintText: 'Search title or notes',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isEmpty
                  ? null
                  : IconButton(
                      key: const Key('clearTaskSearchButton'),
                      onPressed: () {
                        ref.read(taskSearchQueryProvider.notifier).clear();
                      },
                      icon: const Icon(Icons.close),
                      tooltip: 'Clear Search',
                    ),
            ),
            onChanged: (value) {
              ref.read(taskSearchQueryProvider.notifier).setQuery(value);
            },
          ),
          const SizedBox(height: 14),
          Text(
            'Status',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColours.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TasksScreen.statusFilterOptions.map((option) {
              return ChoiceChip(
                key: Key('taskStatusFilter-$option'),
                label: Text(option),
                selected: statusFilter == option,
                onSelected: (_) {
                  ref
                      .read(selectedTaskStatusFilterProvider.notifier)
                      .setFilter(option);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            key: const Key('taskProjectFilterField'),
            initialValue: projectFilter,
            decoration: const InputDecoration(labelText: 'Project Filter'),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All Projects'),
              ),
              ...projects.map(
                (project) => DropdownMenuItem<String?>(
                  value: project.projectId,
                  child: Text(project.name),
                ),
              ),
            ],
            onChanged: (value) {
              ref
                  .read(selectedTaskProjectFilterProvider.notifier)
                  .setFilter(value);
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (parkedCount > 0)
                FilledButton.tonalIcon(
                  onPressed: () => _showParkedWork(ref),
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Review Parked'),
                ),
            ],
          ),
        ],
      ),
    );

    if (tasks.isEmpty) {
      return ListView(
        key: const Key('tasksScrollView'),
        padding: const EdgeInsets.all(20),
        children: [
          headerPanel,
          if (carryForwardBanner != null) ...[
            const SizedBox(height: 12),
            carryForwardBanner,
          ],
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No tasks yet. Add your first task when you\'re ready.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    if (filteredTasks.isEmpty) {
      return ListView(
        key: const Key('tasksScrollView'),
        padding: const EdgeInsets.all(20),
        children: [
          headerPanel,
          if (carryForwardBanner != null) ...[
            const SizedBox(height: 12),
            carryForwardBanner,
          ],
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                normalizedQuery.isEmpty
                    ? 'No tasks match the current filters yet. Try a different status or project view.'
                    : 'No tasks match the current search and filters yet. Try a different word or clear the search.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      key: const Key('tasksScrollView'),
      padding: const EdgeInsets.all(20),
      itemCount: filteredTasks.length + 1 + (carryForwardBanner == null ? 0 : 1),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return headerPanel;
        }

        if (carryForwardBanner != null && index == 1) {
          return carryForwardBanner;
        }

        final taskIndex = index - 1 - (carryForwardBanner == null ? 0 : 1);
        final task = filteredTasks[taskIndex];
        final taskWithTopThreeState = task.copyWith(
          isTopThree: topTaskIds.contains(task.taskId),
        );
        return TaskListCard(
          task: taskWithTopThreeState,
          projectName: task.projectId == null
              ? null
              : projectNames[task.projectId],
          onTap: () => context.push(RouteNames.editTask(task.taskId)),
          onOpenProject: task.projectId == null
              ? null
              : () => context.push(RouteNames.projectDetail(task.projectId!)),
          onMoveToInbox: () =>
              ref.read(tasksControllerProvider).moveTaskToInbox(task.taskId),
          onMoveToPlanned: () =>
              ref.read(tasksControllerProvider).moveTaskToPlanned(task.taskId),
          onMoveToToday: () =>
              ref.read(tasksControllerProvider).moveTaskToToday(task.taskId),
          onMarkDone: () =>
              ref.read(tasksControllerProvider).markTaskDone(task.taskId),
          onBlock: () =>
              ref.read(tasksControllerProvider).markTaskBlocked(task.taskId),
          onPark: () => ref.read(tasksControllerProvider).parkTask(task.taskId),
          onArchive: () => _confirmArchiveTask(context, ref, task),
          onTopThreeToggle: () async {
            try {
              await ref
                  .read(tasksControllerProvider)
                  .toggleTopThreeTask(task.taskId);
            } on StateError catch (error) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(error.message)));
            }
          },
        );
      },
    );
  }

  void _showParkedWork(WidgetRef ref) {
    ref.read(selectedTaskStatusFilterProvider.notifier).setFilter('Parked');
    ref.read(selectedTaskProjectFilterProvider.notifier).setFilter(null);
    ref.read(taskSearchQueryProvider.notifier).clear();
  }

  Future<void> _confirmArchiveTask(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    final shouldArchive = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Archive Task'),
        content: const Text('Archive this task? You can restore it later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (shouldArchive != true || !context.mounted) {
      return;
    }

    await ref.read(tasksControllerProvider).archiveTask(task.taskId);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${task.title} archived.')));
  }
}

class _TaskSummaryChip extends StatelessWidget {
  const _TaskSummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CarryForwardBanner extends StatelessWidget {
  const _CarryForwardBanner({
    required this.parkedCount,
    required this.carryForwardNotes,
    required this.onReviewParked,
    required this.onOpenPlanner,
  });

  final int parkedCount;
  final String carryForwardNotes;
  final VoidCallback onReviewParked;
  final VoidCallback onOpenPlanner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasNotes = carryForwardNotes.isNotEmpty;

    return Container(
      key: const Key('tasksCarryForwardBanner'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: AppColours.darkAmber),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Carry-forward',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (parkedCount > 0)
                _TaskSummaryChip(label: 'Parked', value: '$parkedCount'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasNotes
                ? 'A parked task or note is waiting to be reopened.'
                : 'Parked tasks are waiting to be reopened.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          if (hasNotes) ...[
            const SizedBox(height: 10),
            Text(
              carryForwardNotes,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColours.darkText,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onReviewParked,
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Review Parked'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenPlanner,
                icon: const Icon(Icons.event_note_outlined),
                label: const Text('Open Planner'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

BoxDecoration _tasksPagePanelDecoration() {
  return BoxDecoration(
    color: AppColours.darkSurface.withValues(alpha: 0.94),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.9)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
