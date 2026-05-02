import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            key: const Key('addTaskButton'),
            onPressed: () => context.push(RouteNames.newTask),
            icon: const Icon(Icons.add_task_outlined),
            tooltip: 'Add Task',
          ),
        ],
      ),
      body: tasks.when(
        data: (taskItems) => projects.when(
          data: (projectItems) => todayPlan.when(
            data: (plan) => _TaskListView(
              tasks: taskItems,
              projects: projectItems,
              statusFilter: statusFilter,
              projectFilter: projectFilter,
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
                  'Tasks could not be loaded. Please try again.',
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
                'Tasks could not be loaded. Please try again.',
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
              'Tasks could not be loaded. Please try again.',
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
    required this.statusFilter,
    required this.projectFilter,
    required this.topTaskIds,
  });

  final List<Task> tasks;
  final List<Project> projects;
  final String statusFilter;
  final String? projectFilter;
  final List<String> topTaskIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projectNames = {
      for (final project in projects) project.projectId: project.name,
    };
    final filteredTasks = tasks.where((task) {
      final matchesStatus =
          statusFilter == 'All' || task.status == statusFilter;
      final matchesProject =
          projectFilter == null || task.projectId == projectFilter;
      return matchesStatus && matchesProject;
    }).toList();

    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No tasks yet. Add your first task to start moving New Earth forward.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: (filteredTasks.isEmpty ? 1 : filteredTasks.length) + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Tasks', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    '${filteredTasks.length} tasks are visible in the current task view.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${topTaskIds.length} of 3 priority tasks selected for today.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Text('Status', style: theme.textTheme.titleSmall),
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
                    decoration: const InputDecoration(
                      labelText: 'Project Filter',
                      border: OutlineInputBorder(),
                    ),
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
                ],
              ),
            ),
          );
        }

        if (filteredTasks.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No tasks match the current filters. Try a different status or project view.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }

        final task = filteredTasks[index - 1];
        final taskWithTopThreeState = task.copyWith(
          isTopThree: topTaskIds.contains(task.taskId),
        );
        return TaskListCard(
          task: taskWithTopThreeState,
          projectName: task.projectId == null
              ? null
              : projectNames[task.projectId],
          onTap: () => context.push(RouteNames.editTask(task.taskId)),
          onMoveToToday: () =>
              ref.read(tasksControllerProvider).moveTaskToToday(task.taskId),
          onMarkDone: () =>
              ref.read(tasksControllerProvider).markTaskDone(task.taskId),
          onPark: () => ref.read(tasksControllerProvider).parkTask(task.taskId),
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
}
