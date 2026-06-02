import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/projects_controller.dart';
import '../data/project_repository.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projectDetail = ref.watch(projectDetailProvider(projectId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Project Detail')),
      body: projectDetail.when(
        data: (detail) {
          final project = detail.project;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: _projectPanelDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compactHeader = constraints.maxWidth < 760;

                        final titleSection = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Project',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColours.darkSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              project.name,
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: AppColours.darkText,
                                fontSize: 30,
                              ),
                            ),
                            if (project.shortDescription?.isNotEmpty ==
                                true) ...[
                              const SizedBox(height: 10),
                              Text(
                                project.shortDescription!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColours.darkMutedText,
                                ),
                              ),
                            ],
                          ],
                        );

                        final actions = ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: compactHeader ? double.infinity : 330,
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.start,
                            children: [
                              OutlinedButton.icon(
                                key: const Key('archiveProjectButton'),
                                onPressed: () =>
                                    _confirmArchive(context, ref, project),
                                icon: const Icon(Icons.archive_outlined),
                                label: const Text('Archive'),
                              ),
                              TextButton.icon(
                                key: const Key('openProjectTasksButton'),
                                onPressed: () => context.push(RouteNames.tasks),
                                icon: const Icon(Icons.task_outlined),
                                label: const Text('Open Tasks'),
                              ),
                              TextButton.icon(
                                key: const Key('openProjectPlannerButton'),
                                onPressed: () =>
                                    context.push(RouteNames.planner),
                                icon: const Icon(Icons.calendar_month_outlined),
                                label: const Text('Open Planner'),
                              ),
                              FilledButton.icon(
                                key: const Key('addProjectTaskButton'),
                                onPressed: () => context.push(
                                  RouteNames.newTaskForProject(projectId),
                                ),
                                icon: const Icon(Icons.add_task_outlined),
                                label: const Text('Add Task'),
                              ),
                              OutlinedButton.icon(
                                key: const Key('addProjectJournalButton'),
                                onPressed: () => context.push(
                                  RouteNames.newJournalForProject(projectId),
                                ),
                                icon: const Icon(Icons.menu_book_outlined),
                                label: const Text('Add Journal'),
                              ),
                              OutlinedButton.icon(
                                key: const Key('addProjectLearningButton'),
                                onPressed: () => context.push(
                                  RouteNames.newLearningForProject(projectId),
                                ),
                                icon: const Icon(Icons.school_outlined),
                                label: const Text('Add Learning'),
                              ),
                              OutlinedButton.icon(
                                key: const Key('addProjectContentButton'),
                                onPressed: () => context.push(
                                  RouteNames.newContentForProject(projectId),
                                ),
                                icon: const Icon(Icons.article_outlined),
                                label: const Text('Add Content'),
                              ),
                              OutlinedButton.icon(
                                key: const Key('addProjectBusinessButton'),
                                onPressed: () => context.push(
                                  RouteNames.newBusinessForProject(projectId),
                                ),
                                icon: const Icon(Icons.work_outline),
                                label: const Text('Add Business'),
                              ),
                              OutlinedButton.icon(
                                key: const Key('editProjectButton'),
                                onPressed: () => context.push(
                                  RouteNames.editProject(projectId),
                                ),
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Edit'),
                              ),
                            ],
                          ),
                        );

                        if (compactHeader) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              titleSection,
                              const SizedBox(height: 16),
                              actions,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: titleSection),
                            const SizedBox(width: 16),
                            actions,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 14),
                    Text(
                      'Linked modules',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColours.darkSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ProjectInfoChip(
                          label: 'Journal Entries: ${detail.journalEntryCount}',
                        ),
                        _ProjectInfoChip(
                          label: 'Learning Items: ${detail.learningItemCount}',
                        ),
                        _ProjectInfoChip(
                          label: 'Content Ideas: ${detail.contentItemCount}',
                        ),
                        _ProjectInfoChip(
                          label:
                              'Business Opportunities: ${detail.businessOpportunityCount}',
                        ),
                      ],
                    ),
                    if (project.nextAction?.isNotEmpty == true) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Next action',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColours.darkSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.nextAction!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColours.darkMutedText,
                        ),
                      ),
                    ],
                    if (project.currentMilestone?.isNotEmpty == true) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Current milestone',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColours.darkSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.currentMilestone!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColours.darkMutedText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _ProjectSectionCard(
                title: 'Project home base',
                body:
                    'This page keeps the project, its notes, and its linked work in one calm place.',
              ),
              const SizedBox(height: 12),
              _ProjectSectionCard(
                title: 'Vision / Purpose',
                body:
                    project.vision ?? 'Project vision has not been added yet.',
              ),
              const SizedBox(height: 12),
              _ProjectSectionCard(
                title: 'Current Milestone',
                body:
                    project.currentMilestone ??
                    'Current milestone has not been set yet.',
              ),
              const SizedBox(height: 12),
              _ProjectSectionCard(
                title: 'Next Action',
                body:
                    project.nextAction ??
                    'Next action has not been recorded yet.',
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
                title: 'Recent Journal Entries',
                child: _LinkedJournalSection(
                  entries: detail.recentJournalEntries,
                ),
              ),
              const SizedBox(height: 12),
              _ProjectSectionCard(
                title: 'Recent Learning Items',
                child: _LinkedLearningSection(
                  items: detail.recentLearningItems,
                ),
              ),
              const SizedBox(height: 12),
              _ProjectSectionCard(
                title: 'Recent Content Ideas',
                child: _LinkedContentSection(items: detail.recentContentItems),
              ),
              const SizedBox(height: 12),
              _ProjectSectionCard(
                title: 'Recent Business Opportunities',
                child: _LinkedBusinessSection(
                  items: detail.recentBusinessOpportunities,
                ),
              ),
              const SizedBox(height: 12),
              _ProjectSectionCard(
                title: 'Notes',
                body: project.notes ?? 'Project notes have not been added yet.',
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Project detail could not be loaded. Try again in a moment.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmArchive(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    final shouldArchive = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Archive Project'),
          content: const Text('Archive this item? You can restore it later.'),
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
        );
      },
    );

    if (shouldArchive != true) {
      return;
    }

    await ref
        .read(projectActionsControllerProvider)
        .archiveProject(project.projectId);

    if (!context.mounted) {
      return;
    }

    context.go(RouteNames.projects);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${project.name} archived.')));
  }
}

class _LinkedJournalSection extends StatelessWidget {
  const _LinkedJournalSection({required this.entries});

  final List<ProjectLinkedJournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (entries.isEmpty) {
      return Text(
        'No journal entries are linked to this project yet.',
        style: theme.textTheme.bodyMedium,
      );
    }

    return Column(
      children: entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            key: Key('projectJournalEntry-${entry.journalEntryId}'),
            onTap: () =>
                context.push(RouteNames.editJournal(entry.journalEntryId)),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.menu_book_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.title, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 2),
                        Text(
                          _entryMeta(entry),
                          style: theme.textTheme.bodySmall,
                        ),
                        if (entry.preview?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            entry.preview!,
                            style: theme.textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _entryMeta(ProjectLinkedJournalEntry entry) {
    final dateLabel =
        '${entry.date.day.toString().padLeft(2, '0')}/${entry.date.month.toString().padLeft(2, '0')}/${entry.date.year}';
    if (entry.category?.isNotEmpty == true) {
      return '$dateLabel   ${entry.category}';
    }

    return dateLabel;
  }
}

class _LinkedLearningSection extends StatelessWidget {
  const _LinkedLearningSection({required this.items});

  final List<ProjectLinkedLearningItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Text(
        'No learning items are linked to this project yet.',
        style: theme.textTheme.bodyMedium,
      );
    }

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            key: Key('projectLearningItem-${item.learningItemId}'),
            onTap: () =>
                context.push(RouteNames.editLearning(item.learningItemId)),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.school_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.topic, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 2),
                        Text(
                          'Status: ${item.status}',
                          style: theme.textTheme.bodySmall,
                        ),
                        if (item.nextStep?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.nextStep!,
                            style: theme.textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LinkedContentSection extends StatelessWidget {
  const _LinkedContentSection({required this.items});

  final List<ProjectLinkedContentItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Text(
        'No content ideas are linked to this project yet.',
        style: theme.textTheme.bodyMedium,
      );
    }

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            key: Key('projectContentItem-${item.contentItemId}'),
            onTap: () =>
                context.push(RouteNames.editContent(item.contentItemId)),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.article_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (item.platform?.isNotEmpty == true)
                              item.platform,
                            'Status: ${item.status}',
                          ].join('   '),
                          style: theme.textTheme.bodySmall,
                        ),
                        if (item.preview?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.preview!,
                            style: theme.textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LinkedBusinessSection extends StatelessWidget {
  const _LinkedBusinessSection({required this.items});

  final List<ProjectLinkedBusinessOpportunity> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Text(
        'No business opportunities are linked to this project yet.',
        style: theme.textTheme.bodyMedium,
      );
    }

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            key: Key('projectBusinessItem-${item.businessOpportunityId}'),
            onTap: () => context.push(
              RouteNames.editBusiness(item.businessOpportunityId),
            ),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.work_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (item.type?.isNotEmpty == true) item.type,
                            'Status: ${item.status}',
                          ].join('   '),
                          style: theme.textTheme.bodySmall,
                        ),
                        if (item.nextAction?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.nextAction!,
                            style: theme.textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
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
      color: AppColours.darkSurface.withValues(alpha: 0.94),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColours.darkText,
              ),
            ),
            const SizedBox(height: 10),
            if (child != null)
              child!
            else
              Text(
                body ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
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

class _TaskListSection extends StatelessWidget {
  const _TaskListSection({required this.tasks, required this.emptyText});

  final List<Task> tasks;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (tasks.isEmpty) {
      return Text(
        emptyText,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColours.darkMutedText,
        ),
      );
    }

    return Column(
      children: tasks.map((task) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.checklist_outlined,
                size: 18,
                color: AppColours.darkSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Status: ${task.status}   Priority: ${task.priority}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
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

BoxDecoration _projectPanelDecoration() {
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
