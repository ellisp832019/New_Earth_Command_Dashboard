import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../planner/application/planner_controller.dart';
import '../../projects/application/projects_controller.dart';
import '../application/tasks_controller.dart';
import 'widgets/task_list_card.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tasks = ref.watch(tasksProvider);
    final projects = ref.watch(projectsProvider);
    final todayPlan = ref.watch(todayPlanProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: tasks.when(
        data: (taskItems) => projects.when(
          data: (projectItems) => todayPlan.when(
            data: (plan) => _TaskListView(
              tasks: taskItems,
              projects: projectItems,
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
    required this.topTaskIds,
  });

  final List<Task> tasks;
  final List<Project> projects;
  final List<String> topTaskIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projectNames = {
      for (final project in projects) project.projectId: project.name,
    };

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
      itemCount: tasks.length + 1,
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
                    '${tasks.length} tasks are available in the local dashboard.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${topTaskIds.length} of 3 priority tasks selected for today.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }

        final task = tasks[index - 1];
        final taskWithTopThreeState = task.copyWith(
          isTopThree: topTaskIds.contains(task.taskId),
        );
        return TaskListCard(
          task: taskWithTopThreeState,
          projectName: task.projectId == null
              ? null
              : projectNames[task.projectId],
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
