import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: tasks.when(
        data: (taskItems) => projects.when(
          data: (projectItems) =>
              _TaskListView(tasks: taskItems, projects: projectItems),
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

class _TaskListView extends StatelessWidget {
  const _TaskListView({required this.tasks, required this.projects});

  final List<Task> tasks;
  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
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
                ],
              ),
            ),
          );
        }

        final task = tasks[index - 1];
        return TaskListCard(
          task: task,
          projectName: task.projectId == null
              ? null
              : projectNames[task.projectId],
        );
      },
    );
  }
}
