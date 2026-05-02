import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
import '../application/projects_controller.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projectDetail = ref.watch(projectDetailProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Detail'),
        actions: [
          IconButton(
            key: const Key('addProjectTaskButton'),
            onPressed: () =>
                context.push(RouteNames.newTaskForProject(projectId)),
            icon: const Icon(Icons.add_task_outlined),
            tooltip: 'Add Task',
          ),
          IconButton(
            key: const Key('editProjectButton'),
            onPressed: () => context.push(RouteNames.editProject(projectId)),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Project',
          ),
        ],
      ),
      body: projectDetail.when(
        data: (detail) {
          final project = detail.project;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _ProjectSectionCard(
                title: project.name,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (project.shortDescription?.isNotEmpty == true)
                      Text(
                        project.shortDescription!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ProjectInfoChip(label: 'Status: ${project.status}'),
                        _ProjectInfoChip(
                          label: 'Priority: ${project.priority}',
                        ),
                        _ProjectInfoChip(
                          label: 'Progress: ${project.progressPercentage}%',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _ProjectSectionCard(
                title: 'Vision / Purpose',
                body: project.vision ?? 'No project vision has been added yet.',
              ),
              const SizedBox(height: 12),
              _ProjectSectionCard(
                title: 'Current Milestone',
                body:
                    project.currentMilestone ??
                    'No current milestone has been set yet.',
              ),
              const SizedBox(height: 12),
              _ProjectSectionCard(
                title: 'Next Action',
                body:
                    project.nextAction ??
                    'No next action has been recorded yet.',
              ),
              const SizedBox(height: 12),
              _ProjectSectionCard(
                title: 'Active Tasks',
                child: _TaskListSection(
                  tasks: detail.activeTasks,
                  emptyText: 'No active tasks are linked to this project yet.',
                ),
              ),
              const SizedBox(height: 12),
              _ProjectSectionCard(
                title: 'Blocked Tasks',
                child: _TaskListSection(
                  tasks: detail.blockedTasks,
                  emptyText:
                      'No blocked tasks are linked to this project right now.',
                ),
              ),
              const SizedBox(height: 12),
              _ProjectSectionCard(
                title: 'Linked Notes and Build Trail',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Journal Entries: ${detail.journalEntryCount}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Learning Items: ${detail.learningItemCount}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Content Ideas: ${detail.contentItemCount}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _ProjectSectionCard(
                title: 'Notes',
                body: project.notes ?? 'No project notes have been added yet.',
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Project detail could not be loaded. Please try again.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectSectionCard extends StatelessWidget {
  const _ProjectSectionCard({required this.title, this.body, this.child});

  final String title;
  final String? body;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            if (child != null)
              child!
            else
              Text(body ?? '', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ProjectInfoChip extends StatelessWidget {
  const _ProjectInfoChip({required this.label});

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

class _TaskListSection extends StatelessWidget {
  const _TaskListSection({required this.tasks, required this.emptyText});

  final List<Task> tasks;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (tasks.isEmpty) {
      return Text(emptyText, style: theme.textTheme.bodyMedium);
    }

    return Column(
      children: tasks.map((task) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.checklist_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Status: ${task.status}   Priority: ${task.priority}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
