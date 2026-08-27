import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../../projects/application/projects_controller.dart';
import '../application/project_intelligence_controller.dart';
import '../data/project_repo_bridge_models.dart';
import '../../settings/application/settings_controller.dart';

class ProjectsIntelligenceScreen extends ConsumerStatefulWidget {
  const ProjectsIntelligenceScreen({super.key});

  @override
  ConsumerState<ProjectsIntelligenceScreen> createState() =>
      _ProjectsIntelligenceScreenState();
}

class _ProjectsIntelligenceScreenState
    extends ConsumerState<ProjectsIntelligenceScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final bundleSnapshot = ref.watch(projectIntelligenceBundleProvider);
    final workspaceSnapshot = ref.watch(projectsProvider);
    final settingsSnapshot = ref.watch(settingsSnapshotProvider);
    final service = ref.read(projectRepoBridgeServiceProvider);
    final showWorkspaceSnapshot = settingsSnapshot.maybeWhen(
      data: (snapshot) => snapshot.settings.showProjectsWorkspaceSnapshot,
      orElse: () => true,
    );

    return WorkspaceShell(
      title: 'Projects Hub',
      subtitle: 'Observed technical insight from connected repositories; not project authority.',
      onBack: () => context.go(RouteNames.dashboard),
      trailingActions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => ref.invalidate(projectIntelligenceBundleProvider),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: bundleSnapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ProjectsIntelligenceError(
          error: error,
          onRetry: () => ref.invalidate(projectIntelligenceBundleProvider),
        ),
        data: (bundle) {
          final projects = bundle.projects
              .where((project) {
                if (_searchQuery.trim().isEmpty) {
                  return true;
                }

                final search = _searchQuery.trim().toLowerCase();
                final latest = project.latestRepoStatus;
                return <String>[
                  project.name,
                  project.projectId,
                  project.dashboardStatus,
                  project.repoId ?? '',
                  project.repoPath ?? '',
                  project.currentPhase ?? '',
                  latest?.branch ?? '',
                  latest?.latestCommit ?? '',
                  latest?.dirtyFiles.length.toString() ?? '0',
                  latest?.docsFound.length.toString() ?? '0',
                  latest?.todoCount.toString() ?? '0',
                  project.nextActions.join(' '),
                ].any((value) => value.toLowerCase().contains(search));
              })
              .toList(growable: false);

          final summary = _ProjectsIntelligenceSummary.fromBundle(bundle);

          return ListView(
            key: const Key('projectsHubScrollView'),
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: _panelDecoration(highlighted: true),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 900;
                        final titleBlock = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Projects Hub',
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    color: AppColours.darkText,
                                    fontSize: 28,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Read-only project intelligence, with the live workspace tucked quietly underneath.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColours.darkMutedText,
                                    height: 1.35,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: const [
                                _HubCrumb(label: 'Dashboard'),
                                _HubCrumb(label: 'Projects Hub'),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Hub first. Workspace inside.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColours.darkMutedText,
                                    letterSpacing: 0.15,
                                  ),
                            ),
                          ],
                        );

                        final actions = Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: wide
                              ? WrapAlignment.end
                              : WrapAlignment.start,
                          children: [
                            TextButton.icon(
                              onPressed: () =>
                                  service.openFile(bundle.outputPath),
                              icon: const Icon(Icons.description_outlined),
                              label: const Text('Open unified JSON'),
                            ),
                            TextButton.icon(
                              onPressed: () => context.push(
                                RouteNames.repoIntelligenceBridge,
                              ),
                              icon: const Icon(Icons.account_tree_outlined),
                              label: const Text('Open bridge'),
                            ),
                            TextButton.icon(
                              onPressed: () => service.openFolder(
                                service.moduleRootDirectory().path,
                              ),
                              icon: const Icon(Icons.folder_open_outlined),
                              label: const Text('Open bridge folder'),
                            ),
                            TextButton.icon(
                              key: const Key('projectsHubOpenWorkspaceButton'),
                              onPressed: () =>
                                  context.go(RouteNames.projectsWorkspace),
                              icon: const Icon(Icons.work_outline),
                              label: const Text('Open workspace'),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                ref.invalidate(
                                  projectIntelligenceBundleProvider,
                                );
                                ref.invalidate(projectsProvider);
                              },
                              icon: const Icon(Icons.sync_outlined),
                              label: const Text('Refresh hub'),
                            ),
                          ],
                        );

                        if (!wide) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              titleBlock,
                              const SizedBox(height: 16),
                              actions,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: titleBlock),
                            const SizedBox(width: 20),
                            Flexible(child: actions),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _IntelligenceChip(
                          label: 'Projects',
                          value: '${summary.projectCount}',
                        ),
                        _IntelligenceChip(
                          label: 'Linked repos',
                          value: '${summary.linkedRepoCount}',
                          accentColor: AppColours.darkSuccess,
                        ),
                        _IntelligenceChip(
                          label: 'Dirty repos',
                          value: '${summary.dirtyRepoCount}',
                          accentColor: AppColours.darkAmber,
                        ),
                        _IntelligenceChip(
                          label: 'Docs found',
                          value: '${summary.docsFoundCount}',
                          accentColor: AppColours.darkSecondary,
                        ),
                        _IntelligenceChip(
                          label: 'TODO/FIXME',
                          value: '${summary.todoCount}',
                          accentColor: AppColours.darkPurple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search intelligence',
                        prefixIcon: Icon(Icons.search),
                        hintText:
                            'Search name, repo, branch, status, docs, TODOs, or next action',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${projects.length} project${projects.length == 1 ? '' : 's'} visible from ${bundle.projects.length} tracked.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (projects.isNotEmpty) ...[
                _ProjectWorkflowSpotlightCard(
                  project: _spotlightProject(projects),
                ),
                const SizedBox(height: 16),
              ],
              _WorkspaceSnapshotSection(
                workspaceSnapshot: workspaceSnapshot,
                isExpanded: showWorkspaceSnapshot,
                onToggle: () {
                  ref
                      .read(settingsControllerProvider)
                      .setShowProjectsWorkspaceSnapshot(!showWorkspaceSnapshot);
                },
              ),
              const SizedBox(height: 16),
              if (projects.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: _panelDecoration(),
                  child: const Text('No projects match the current search.'),
                )
              else
                ...projects.map(
                  (project) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ProjectIntelligenceCard(project: project),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _WorkspaceSnapshotSection extends StatelessWidget {
  const _WorkspaceSnapshotSection({
    required this.workspaceSnapshot,
    required this.isExpanded,
    required this.onToggle,
  });

  final AsyncValue<List<Project>> workspaceSnapshot;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.work_outline, color: AppColours.darkSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Workspace snapshot',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onToggle,
                icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                label: Text(isExpanded ? 'Collapse' : 'Expand'),
              ),
              TextButton(
                key: const Key('projectsWorkspaceOpenWorkspaceButton'),
                onPressed: () => context.go(RouteNames.projectsWorkspace),
                child: const Text('Open workspace'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'The workspace preview is saved locally and can stay collapsed for a quieter view.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          if (isExpanded)
            workspaceSnapshot.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => Text(
                'Workspace snapshot could not load: $error',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
              data: (projects) {
                if (projects.isEmpty) {
                  return Text(
                    'No active projects are available in the workspace yet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkMutedText,
                    ),
                  );
                }

                final visibleProjects = projects
                    .take(4)
                    .toList(growable: false);
                return Column(
                  children: [
                    for (
                      var index = 0;
                      index < visibleProjects.length;
                      index++
                    ) ...[
                      _WorkspaceProjectCard(project: visibleProjects[index]),
                      if (index != visibleProjects.length - 1)
                        const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            )
          else
            Text(
              'Workspace snapshot is collapsed. Expand it for the live project table preview.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            ),
        ],
      ),
    );
  }
}

class _WorkspaceProjectCard extends StatelessWidget {
  const _WorkspaceProjectCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final priorityColor = switch (project.priority) {
      'High' => AppColours.darkAmber,
      'Low' => AppColours.darkMutedText,
      _ => AppColours.darkSecondary,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColours.darkSuccess.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColours.darkSuccess.withValues(alpha: 0.24),
                  ),
                ),
                child: Text(
                  project.status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkSuccess,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _IntelligenceChip(
                label: 'Priority',
                value: project.priority,
                accentColor: priorityColor,
              ),
              _IntelligenceChip(
                label: 'Progress',
                value: '${project.progressPercentage}%',
              ),
              _IntelligenceChip(label: 'Project ID', value: project.projectId),
            ],
          ),
          if ((project.currentMilestone ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Current milestone',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColours.darkSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              project.currentMilestone!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkText),
            ),
          ],
          if ((project.nextAction ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Next action',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColours.darkSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              project.nextAction!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () =>
                  context.push(RouteNames.projectDetail(project.projectId)),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open detail'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectIntelligenceCard extends StatelessWidget {
  const _ProjectIntelligenceCard({required this.project});

  final UnifiedProjectRecord project;

  @override
  Widget build(BuildContext context) {
    final latest = project.latestRepoStatus;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      project.dashboardDescription?.isNotEmpty == true
                          ? project.dashboardDescription!
                          : 'No project description is set yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkMutedText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColours.darkPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColours.darkPrimary.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  project.dashboardStatus,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _IntelligenceChip(
                label: 'Tasks',
                value: '${project.dashboardTasks.length}',
              ),
              _IntelligenceChip(
                label: 'Repo',
                value: project.repoLinked
                    ? (project.repoId ?? 'Linked')
                    : 'Not linked',
                accentColor: project.repoLinked
                    ? AppColours.darkSuccess
                    : AppColours.darkAmber,
              ),
              _IntelligenceChip(
                label: 'Branch',
                value: latest?.branch ?? 'No branch',
                accentColor: AppColours.darkSecondary,
              ),
              _IntelligenceChip(
                label: 'Commit',
                value: latest?.latestCommit == null
                    ? 'No commit'
                    : _shortCommitSummary(latest!.latestCommit!),
                accentColor: AppColours.darkPurple,
              ),
              _IntelligenceChip(
                label: 'Dirty files',
                value: '${latest?.dirtyFiles.length ?? 0}',
                accentColor: AppColours.darkAmber,
              ),
              _IntelligenceChip(
                label: 'Docs found',
                value: '${latest?.docsFound.length ?? 0}',
                accentColor: AppColours.darkSecondary,
              ),
              _IntelligenceChip(
                label: 'TODO/FIXME',
                value: '${latest?.todoCount ?? 0}',
                accentColor: AppColours.darkPurple,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (latest?.latestCommit != null || latest?.latestCommitDate != null)
            Text(
              latest?.latestCommit ?? 'No commit summary available.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkText,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (latest?.latestCommitDate?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              'Latest commit date: ${latest!.latestCommitDate!}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            ),
          ],
          if (project.currentPhase?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              'Current phase: ${project.currentPhase}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkSecondary),
            ),
          ],
          if (project.nextActions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Next suggested action',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColours.darkSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            ...project.nextActions
                .take(3)
                .map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '- $action',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _ProjectWorkflowSpotlightCard extends StatelessWidget {
  const _ProjectWorkflowSpotlightCard({required this.project});

  final UnifiedProjectRecord project;

  @override
  Widget build(BuildContext context) {
    final latest = project.latestRepoStatus;
    final theme = Theme.of(context);
    final nextActions = project.nextActions.take(3).toList(growable: false);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timeline_outlined,
                    color: AppColours.darkSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Project workflow spotlight',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColours.darkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Use the strongest current project to move from overview into the next useful action without losing the calm hub view.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                project.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                project.dashboardDescription?.isNotEmpty == true
                    ? project.dashboardDescription!
                    : 'No project description is set yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _IntelligenceChip(
                    label: 'Status',
                    value: project.dashboardStatus,
                    accentColor: AppColours.darkSuccess,
                  ),
                  _IntelligenceChip(
                    label: 'Tasks',
                    value: '${project.dashboardTasks.length}',
                  ),
                  _IntelligenceChip(
                    label: 'Phase',
                    value: project.currentPhase ?? 'No phase',
                    accentColor: AppColours.darkSecondary,
                  ),
                  _IntelligenceChip(
                    label: 'Codex',
                    value: project.codexHandoffReady ? 'Ready' : 'Parked',
                    accentColor: project.codexHandoffReady
                        ? AppColours.darkSuccess
                        : AppColours.darkAmber,
                  ),
                  if (latest != null) ...[
                    _IntelligenceChip(
                      label: 'Branch',
                      value: latest.branch ?? 'No branch',
                      accentColor: AppColours.darkSecondary,
                    ),
                    _IntelligenceChip(
                      label: 'Dirty',
                      value: '${latest.dirtyFiles.length}',
                      accentColor: AppColours.darkAmber,
                    ),
                  ],
                ],
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () =>
                    context.push(RouteNames.projectDetail(project.projectId)),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open detail'),
              ),
              FilledButton.tonalIcon(
                onPressed: () =>
                    context.push(RouteNames.repoIntelligenceBridge),
                icon: const Icon(Icons.account_tree_outlined),
                label: const Text('Open bridge'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push(
                  RouteNames.newTaskForProject(project.projectId),
                ),
                icon: const Icon(Icons.add_task_outlined),
                label: const Text('Add task'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push(
                  RouteNames.newJournalForProject(project.projectId),
                ),
                icon: const Icon(Icons.menu_book_outlined),
                label: const Text('Add journal'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push(
                  RouteNames.newLearningForProject(project.projectId),
                ),
                icon: const Icon(Icons.school_outlined),
                label: const Text('Add learning'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push(
                  RouteNames.newContentForProject(project.projectId),
                ),
                icon: const Icon(Icons.article_outlined),
                label: const Text('Add content'),
              ),
            ],
          );

          final nextActionsBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Next actions',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (nextActions.isEmpty)
                Text(
                  'No next actions are set yet. The project detail page can help shape the next move.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final action in nextActions) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $action',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColours.darkMutedText,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _IntelligenceChip(
                    label: 'Repo',
                    value: project.repoLinked ? 'linked' : 'not linked',
                    accentColor: project.repoLinked
                        ? AppColours.darkSuccess
                        : AppColours.darkAmber,
                  ),
                  _IntelligenceChip(
                    label: 'Tasks',
                    value: '${project.dashboardTasks.length}',
                  ),
                  _IntelligenceChip(
                    label: 'Handoff',
                    value: project.codexHandoffReady ? 'ready' : 'parked',
                    accentColor: project.codexHandoffReady
                        ? AppColours.darkSuccess
                        : AppColours.darkAmber,
                  ),
                ],
              ),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 16),
                actions,
                const SizedBox(height: 16),
                nextActionsBlock,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: copy),
              const SizedBox(width: 18),
              SizedBox(
                width: 440,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    actions,
                    const SizedBox(height: 16),
                    nextActionsBlock,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

UnifiedProjectRecord _spotlightProject(List<UnifiedProjectRecord> projects) {
  final handoffReady = projects
      .where((project) => project.codexHandoffReady)
      .toList(growable: false);
  if (handoffReady.isNotEmpty) {
    return handoffReady.first;
  }

  final withActions = projects
      .where((project) => project.nextActions.isNotEmpty)
      .toList(growable: false);
  if (withActions.isNotEmpty) {
    return withActions.first;
  }

  return projects.first;
}

class _ProjectsIntelligenceSummary {
  const _ProjectsIntelligenceSummary({
    required this.projectCount,
    required this.linkedRepoCount,
    required this.dirtyRepoCount,
    required this.docsFoundCount,
    required this.todoCount,
  });

  factory _ProjectsIntelligenceSummary.fromBundle(
    ProjectRepoBridgeBundle bundle,
  ) {
    var linkedRepoCount = 0;
    var dirtyRepoCount = 0;
    var docsFoundCount = 0;
    var todoCount = 0;
    for (final project in bundle.projects) {
      final latest = project.latestRepoStatus;
      if (project.repoLinked) {
        linkedRepoCount++;
      }
      if ((latest?.dirtyFiles.isNotEmpty ?? false)) {
        dirtyRepoCount++;
      }
      docsFoundCount += latest?.docsFound.length ?? 0;
      todoCount += latest?.todoCount ?? 0;
    }
    return _ProjectsIntelligenceSummary(
      projectCount: bundle.projects.length,
      linkedRepoCount: linkedRepoCount,
      dirtyRepoCount: dirtyRepoCount,
      docsFoundCount: docsFoundCount,
      todoCount: todoCount,
    );
  }

  final int projectCount;
  final int linkedRepoCount;
  final int dirtyRepoCount;
  final int docsFoundCount;
  final int todoCount;
}

class _HubCrumb extends StatelessWidget {
  const _HubCrumb({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColours.darkMutedText,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _IntelligenceChip extends StatelessWidget {
  const _IntelligenceChip({
    required this.label,
    required this.value,
    this.accentColor = AppColours.darkSecondary,
  });

  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectsIntelligenceError extends StatelessWidget {
  const _ProjectsIntelligenceError({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.analytics_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              'Projects Intelligence could not load right now.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _panelDecoration({bool highlighted = false}) {
  return BoxDecoration(
    color: highlighted
        ? AppColours.darkSurface.withValues(alpha: 0.96)
        : AppColours.darkSurface.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: highlighted
          ? AppColours.darkSecondary.withValues(alpha: 0.22)
          : AppColours.darkOutline.withValues(alpha: 0.9),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 26,
        offset: const Offset(0, 10),
      ),
    ],
  );
}

String _shortCommitSummary(String summary) {
  final trimmed = summary.trim();
  if (trimmed.length <= 72) {
    return trimmed;
  }
  return '${trimmed.substring(0, 69)}...';
}
