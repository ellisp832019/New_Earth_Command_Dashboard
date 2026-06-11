import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/repo_intelligence_bridge_controller.dart';
import '../data/repo_intelligence_bridge_models.dart';

class RepoIntelligenceBridgeScreen extends ConsumerWidget {
  const RepoIntelligenceBridgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceAsync = ref.watch(repoIntelligenceBridgeWorkspaceProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to Projects Hub',
          onPressed: () => context.go(RouteNames.projectsIntelligence),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Repo Intelligence Bridge'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () =>
                ref.invalidate(repoIntelligenceBridgeWorkspaceProvider),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Bridge settings',
            onPressed: () => context.push(RouteNames.repoIntelligenceBridgeSettings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: workspaceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _BridgeError(
          error: error,
          onRetry: () => ref.invalidate(repoIntelligenceBridgeWorkspaceProvider),
        ),
        data: (workspace) {
          final bundle = workspace.bundle;
          final projectStatus = bundle.projectStatus;
          final repoHealth = bundle.repoHealth;
          final tasks = bundle.tasks;
          final risks = bundle.risks;
          final decisions = bundle.decisions;
          final timeline = bundle.timeline;
          final nextActions = bundle.nextActions;
          final aiContext = bundle.aiContext;
          final syncManifest = bundle.syncManifest;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _BridgeHeroCard(
                workspace: workspace,
                onOpenSettings: () =>
                    context.push(RouteNames.repoIntelligenceBridgeSettings),
                onOpenExports: () =>
                    ref
                        .read(repoIntelligenceBridgeControllerProvider)
                        .openExportsFolder(workspace.activeProfile),
                onOpenObsidian: () =>
                    ref
                        .read(repoIntelligenceBridgeControllerProvider)
                        .openObsidianVault(workspace.activeProfile),
                onOpenModuleHome: () =>
                    ref.read(repoIntelligenceBridgeControllerProvider).openModuleHome(),
                onOpenProfiles: () => ref
                    .read(repoIntelligenceBridgeControllerProvider)
                    .openProfilesFolder(),
                onOpenSyncLog: () =>
                    ref.read(repoIntelligenceBridgeControllerProvider).openSyncLog(),
                onRunFullSync: () async {
                  await ref
                      .read(repoIntelligenceBridgeControllerProvider)
                      .runFullSync();
                },
              ),
              const SizedBox(height: 16),
              _BridgeSummaryGrid(
                workspace: workspace,
                projectStatus: projectStatus,
                repoHealth: repoHealth,
                syncManifest: syncManifest,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 920;
                  final firstColumn = <Widget>[
                    _BridgeSectionCard(
                      title: 'Project status',
                      icon: Icons.flag_outlined,
                      child: _ProjectStatusContent(
                        projectStatus: projectStatus,
                        activeProfile: workspace.activeProfile,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _BridgeSectionCard(
                      title: 'Next actions',
                      icon: Icons.next_plan_outlined,
                      child: _ActionList(
                        emptyLabel: 'No next actions yet.',
                        items: nextActions
                            .map(
                              (item) => _ActionRow(
                                title: item.title,
                                subtitle: item.priority.isNotEmpty ||
                                        item.status.isNotEmpty
                                    ? '${item.priority.isEmpty ? 'Priority n/a' : item.priority} / ${item.status.isEmpty ? 'Status n/a' : item.status}'
                                    : '',
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _BridgeSectionCard(
                      title: 'Tasks',
                      icon: Icons.task_alt_outlined,
                      child: _ActionList(
                        emptyLabel: 'No task markers were exported yet.',
                        items: tasks
                            .take(10)
                            .map(
                              (item) => _ActionRow(
                                title: item.text,
                                subtitle: item.file.isNotEmpty
                                    ? '${item.file}:${item.line}'
                                    : 'Line ${item.line}',
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _BridgeSectionCard(
                      title: 'Risks',
                      icon: Icons.warning_amber_outlined,
                      child: _ActionList(
                        emptyLabel: 'No risks were exported yet.',
                        items: risks
                            .map(
                              (item) => _ActionRow(
                                title: item.title,
                                subtitle: item.severity.isNotEmpty
                                    ? 'Severity: ${item.severity}'
                                    : '',
                                detail: item.mitigation,
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                  ];

                  final secondColumn = <Widget>[
                    _BridgeSectionCard(
                      title: 'Decisions',
                      icon: Icons.how_to_reg_outlined,
                      child: _ActionList(
                        emptyLabel: 'No decisions were exported yet.',
                        items: decisions
                            .map(
                              (item) => _ActionRow(
                                title: item.decision,
                                subtitle: item.status.isNotEmpty
                                    ? 'Status: ${item.status}'
                                    : '',
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _BridgeSectionCard(
                      title: 'Timeline',
                      icon: Icons.timeline_outlined,
                      child: _ActionList(
                        emptyLabel: 'No timeline milestones were exported yet.',
                        items: timeline
                            .map(
                              (item) => _ActionRow(
                                title: item.stage,
                                subtitle: item.status.isNotEmpty
                                    ? item.status
                                    : 'Status not set',
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _BridgeSectionCard(
                      title: 'Repo health',
                      icon: Icons.health_and_safety_outlined,
                      child: _RepoHealthContent(repoHealth: repoHealth),
                    ),
                    const SizedBox(height: 16),
                    _BridgeSectionCard(
                      title: 'AI context',
                      icon: Icons.smart_toy_outlined,
                      child: _AiContextContent(aiContext: aiContext),
                    ),
                  ];

                  if (!wide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...firstColumn,
                        ...secondColumn,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: firstColumn,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: secondColumn,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              _BridgeSectionCard(
                title: 'Sync log',
                icon: Icons.receipt_long_outlined,
                child: _SyncLogContent(
                  lines: workspace.syncLogLines,
                  lastSyncTime: workspace.lastSyncTime,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class RepoIntelligenceBridgeDashboardCard extends ConsumerWidget {
  const RepoIntelligenceBridgeDashboardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceAsync = ref.watch(repoIntelligenceBridgeWorkspaceProvider);

    return workspaceAsync.when(
      loading: () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: _panelDecoration(context),
        child: Row(
          children: [
            const Icon(
              Icons.account_tree_outlined,
              color: AppColours.darkSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              'Repo Intelligence Bridge is loading quietly.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            ),
          ],
        ),
      ),
      error: (error, stackTrace) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: _panelDecoration(context),
        child: Row(
          children: [
            const Icon(
              Icons.account_tree_outlined,
              color: AppColours.darkAmber,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Repo Intelligence Bridge could not load right now.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
              ),
            ),
          ],
        ),
      ),
      data: (workspace) {
        final projectStatus = workspace.bundle.projectStatus;
        final repoHealth = workspace.bundle.repoHealth;
        final statusAccent = _healthAccent(repoHealth?.health ?? '');
        final statusLabel = repoHealth?.health.isNotEmpty == true
            ? repoHealth!.health
            : 'Unknown';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _panelDecoration(context),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 920;

              final overview = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_tree_outlined,
                        color: AppColours.darkSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Repo Intelligence Bridge',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColours.darkText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _InlineTag(
                        label: statusLabel,
                        accent: statusAccent,
                        foreground: statusAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    projectStatus?.currentFocus.isNotEmpty == true
                        ? projectStatus!.currentFocus
                        : 'Read dashboard exports, review risks, and keep the bridge local-first.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkMutedText,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _BridgeMetricChip(
                        label: 'Profile',
                        value: workspace.activeProfile.projectName,
                        accent: AppColours.darkSecondary,
                      ),
                      _BridgeMetricChip(
                        label: 'Health',
                        value: repoHealth?.score == null
                            ? '...'
                            : '${repoHealth!.score}',
                        accent: _healthAccent(repoHealth?.health ?? ''),
                      ),
                      _BridgeMetricChip(
                        label: 'Tasks',
                        value: '${workspace.bundle.tasks.length}',
                        accent: AppColours.darkSuccess,
                      ),
                      _BridgeMetricChip(
                        label: 'Risks',
                        value: '${workspace.bundle.risks.length}',
                        accent: AppColours.darkAmber,
                      ),
                      _BridgeMetricChip(
                        label: 'Decisions',
                        value: '${workspace.bundle.decisions.length}',
                        accent: AppColours.darkPurple,
                      ),
                      _BridgeMetricChip(
                        label: 'Last sync',
                        value: workspace.lastSyncTime == null
                            ? 'Not synced'
                            : _formatDateTime(workspace.lastSyncTime!),
                        accent: AppColours.darkSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Dashboard export folder: ${workspace.exportsDirectory}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColours.darkMutedText,
                      height: 1.35,
                    ),
                  ),
                ],
              );

              final actions = Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.start,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.push(
                      RouteNames.repoIntelligenceBridgeSettings,
                    ),
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Settings'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => context.push(
                      RouteNames.repoIntelligenceBridge,
                    ),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open bridge'),
                  ),
                  TextButton.icon(
                    onPressed: () => ref
                        .read(repoIntelligenceBridgeControllerProvider)
                        .runFullSync(),
                    icon: const Icon(Icons.sync_outlined),
                    label: const Text('Run sync'),
                  ),
                ],
              );

              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    overview,
                    const SizedBox(height: 16),
                    actions,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: overview),
                  const SizedBox(width: 20),
                  SizedBox(width: 260, child: actions),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _BridgeHeroCard extends StatelessWidget {
  const _BridgeHeroCard({
    required this.workspace,
    required this.onOpenSettings,
    required this.onOpenExports,
    required this.onOpenObsidian,
    required this.onOpenModuleHome,
    required this.onOpenProfiles,
    required this.onOpenSyncLog,
    required this.onRunFullSync,
  });

  final RepoIntelligenceBridgeWorkspace workspace;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenExports;
  final VoidCallback onOpenObsidian;
  final VoidCallback onOpenModuleHome;
  final VoidCallback onOpenProfiles;
  final VoidCallback onOpenSyncLog;
  final VoidCallback onRunFullSync;

  @override
  Widget build(BuildContext context) {
    final projectStatus = workspace.bundle.projectStatus;
    final repoHealth = workspace.bundle.repoHealth;
    final syncLabel = workspace.lastSyncTime == null
        ? 'Not synced yet'
        : _formatDateTime(workspace.lastSyncTime!);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(context, highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 980;

          final overview = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Repo Intelligence Bridge',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColours.darkText,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Read-only dashboard exports, local profiles, and sync logs stay in one calm place.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InlineTag(
                    label: workspace.activeProfile.projectName,
                    accent: AppColours.darkSecondary,
                    foreground: AppColours.darkSecondary,
                  ),
                  _InlineTag(
                    label: projectStatus?.status.isNotEmpty == true
                        ? projectStatus!.status
                        : 'Status pending',
                    accent: AppColours.darkSuccess,
                    foreground: AppColours.darkSuccess,
                  ),
                  _InlineTag(
                    label: repoHealth?.health.isNotEmpty == true
                        ? repoHealth!.health
                        : 'Health unknown',
                    accent: _healthAccent(repoHealth?.health ?? ''),
                    foreground: _healthAccent(repoHealth?.health ?? ''),
                  ),
                  _InlineTag(
                    label: syncLabel,
                    accent: AppColours.darkPurple,
                    foreground: AppColours.darkPurple,
                  ),
                ],
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: wide ? WrapAlignment.end : WrapAlignment.start,
            children: [
              FilledButton.icon(
                onPressed: onRunFullSync,
                icon: const Icon(Icons.sync_outlined),
                label: const Text('Run full sync'),
              ),
              FilledButton.tonalIcon(
                onPressed: onOpenSettings,
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Settings'),
              ),
              TextButton.icon(
                onPressed: onOpenExports,
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Open exports'),
              ),
              TextButton.icon(
                onPressed: onOpenObsidian,
                icon: const Icon(Icons.book_outlined),
                label: const Text('Open Obsidian'),
              ),
              TextButton.icon(
                onPressed: onOpenModuleHome,
                icon: const Icon(Icons.folder_outlined),
                label: const Text('Open module'),
              ),
              TextButton.icon(
                onPressed: onOpenProfiles,
                icon: const Icon(Icons.folder_copy_outlined),
                label: const Text('Profiles'),
              ),
              TextButton.icon(
                onPressed: onOpenSyncLog,
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Sync log'),
              ),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                overview,
                const SizedBox(height: 18),
                actions,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: overview),
              const SizedBox(width: 20),
              SizedBox(width: 360, child: actions),
            ],
          );
        },
      ),
    );
  }
}

class _BridgeSummaryGrid extends StatelessWidget {
  const _BridgeSummaryGrid({
    required this.workspace,
    required this.projectStatus,
    required this.repoHealth,
    required this.syncManifest,
  });

  final RepoIntelligenceBridgeWorkspace workspace;
  final RepoIntelligenceBridgeProjectStatus? projectStatus;
  final RepoIntelligenceBridgeRepoHealth? repoHealth;
  final RepoIntelligenceBridgeSyncManifest? syncManifest;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _BridgeMetricCard(
        title: 'Project',
        value: projectStatus?.project.isNotEmpty == true
            ? projectStatus!.project
            : workspace.activeProfile.projectName,
        subtitle: projectStatus?.phase.isNotEmpty == true
            ? projectStatus!.phase
            : 'Phase pending',
      ),
      _BridgeMetricCard(
        title: 'Health score',
        value: repoHealth == null ? '...' : '${repoHealth!.score}',
        subtitle: repoHealth?.health.isNotEmpty == true
            ? repoHealth!.health
            : 'Health unknown',
      ),
      _BridgeMetricCard(
        title: 'Generated',
        value: projectStatus?.generatedAt.isNotEmpty == true
            ? _formatDateTime(
                DateTime.tryParse(projectStatus!.generatedAt) ?? DateTime.now(),
              )
            : 'Unknown',
        subtitle: 'Project status export',
      ),
      _BridgeMetricCard(
        title: 'Manifest',
        value: () {
          final manifest = syncManifest;
          return manifest == null ? '...' : '${manifest.exports.length}';
        }(),
        subtitle: 'Exported files',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1040
            ? 4
            : constraints.maxWidth >= 700
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: crossAxisCount == 1 ? 3.0 : 2.2,
          ),
          itemBuilder: (context, index) => cards[index],
        );
      },
    );
  }
}

class _BridgeSectionCard extends StatelessWidget {
  const _BridgeSectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColours.darkSecondary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ProjectStatusContent extends StatelessWidget {
  const _ProjectStatusContent({
    required this.projectStatus,
    required this.activeProfile,
  });

  final RepoIntelligenceBridgeProjectStatus? projectStatus;
  final RepoIntelligenceBridgeProfile activeProfile;

  @override
  Widget build(BuildContext context) {
    if (projectStatus == null) {
      return Text(
        'No project status export is available yet for ${activeProfile.projectName}.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColours.darkMutedText,
          height: 1.4,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'Project', value: projectStatus!.project),
        _DetailRow(label: 'Type', value: projectStatus!.type),
        _DetailRow(label: 'Status', value: projectStatus!.status),
        _DetailRow(label: 'Phase', value: projectStatus!.phase),
        _DetailRow(label: 'Focus', value: projectStatus!.currentFocus),
        _DetailRow(label: 'Repo root', value: projectStatus!.repoRoot),
      ],
    );
  }
}

class _RepoHealthContent extends StatelessWidget {
  const _RepoHealthContent({required this.repoHealth});

  final RepoIntelligenceBridgeRepoHealth? repoHealth;

  @override
  Widget build(BuildContext context) {
    if (repoHealth == null) {
      return Text(
        'No repo health export has been generated yet.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColours.darkMutedText,
          height: 1.4,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'Health', value: repoHealth!.health),
        _DetailRow(label: 'Score', value: '${repoHealth!.score}'),
        _DetailRow(
          label: 'Scanned files',
          value: '${repoHealth!.totalScannedFiles}',
        ),
        _DetailRow(label: 'TODO markers', value: '${repoHealth!.todoMarkers}'),
        const SizedBox(height: 8),
        if (repoHealth!.checks.isEmpty)
          Text(
            'No health checks were exported.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final check in repoHealth!.checks.take(8))
                _InlineTag(
                  label: '${check.name}: ${check.status}',
                  accent: AppColours.darkSurfaceRaised,
                  foreground: AppColours.darkText,
                ),
            ],
          ),
      ],
    );
  }
}

class _AiContextContent extends StatelessWidget {
  const _AiContextContent({required this.aiContext});

  final RepoIntelligenceBridgeAiContext? aiContext;

  @override
  Widget build(BuildContext context) {
    if (aiContext == null) {
      return Text(
        'No AI context export has been generated yet.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColours.darkMutedText,
          height: 1.4,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'Project', value: aiContext!.projectName),
        _DetailRow(label: 'Source', value: aiContext!.sourceOfTruth),
        _DetailRow(label: 'Generated', value: aiContext!.generatedAt),
        const SizedBox(height: 8),
        _PermissionBlock(
          title: 'Locked rules',
          values: aiContext!.lockedRules,
        ),
        const SizedBox(height: 10),
        _PermissionBlock(
          title: 'Safe permissions',
          values: aiContext!.safeAiPermissions,
        ),
        const SizedBox(height: 10),
        _PermissionBlock(
          title: 'Blocked permissions',
          values: aiContext!.blockedAiPermissions,
        ),
        const SizedBox(height: 10),
        _PermissionBlock(
          title: 'Human approval',
          values: aiContext!.humanApprovalRequired,
        ),
      ],
    );
  }
}

class _PermissionBlock extends StatelessWidget {
  const _PermissionBlock({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColours.darkSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        if (values.isEmpty)
          Text(
            'None.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in values.take(8))
                _InlineTag(
                  label: value,
                  accent: AppColours.darkSurfaceRaised,
                  foreground: AppColours.darkText,
                ),
            ],
          ),
      ],
    );
  }
}

class _SyncLogContent extends StatelessWidget {
  const _SyncLogContent({
    required this.lines,
    required this.lastSyncTime,
  });

  final List<String> lines;
  final DateTime? lastSyncTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(
          label: 'Last sync',
          value: lastSyncTime == null
              ? 'Not synced yet'
              : _formatDateTime(lastSyncTime!),
        ),
        const SizedBox(height: 10),
        if (lines.isEmpty)
          Text(
            'No sync log entries were found yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final line in lines.reversed.take(10))
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: SelectableText(
                    line,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColours.darkText,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _ActionList extends StatelessWidget {
  const _ActionList({
    required this.items,
    required this.emptyLabel,
  });

  final List<_ActionRow> items;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        emptyLabel,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColours.darkMutedText,
          height: 1.4,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items.take(8)) ...[
          item,
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    this.subtitle = '',
    this.detail = '',
  });

  final String title;
  final String subtitle;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.isEmpty ? 'Untitled' : title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
          ],
          if (detail.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              detail,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BridgeMetricChip extends StatelessWidget {
  const _BridgeMetricChip({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BridgeMetricCard extends StatelessWidget {
  const _BridgeMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? 'Not set' : value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkText,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _BridgeError extends StatelessWidget {
  const _BridgeError({required this.error, required this.onRetry});

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
            const Icon(Icons.account_tree_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              'Repo Intelligence Bridge could not load right now.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
              ),
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

String _formatDateTime(DateTime value) {
  return DateFormat('d MMM yyyy, HH:mm').format(value);
}

Color _healthAccent(String health) {
  switch (health.toLowerCase().trim()) {
    case 'green':
    case 'ready':
    case 'healthy':
      return AppColours.darkSuccess;
    case 'amber':
    case 'warning':
      return AppColours.darkAmber;
    case 'red':
    case 'critical':
      return const Color(0xFFE26B6B);
    default:
      return AppColours.darkSecondary;
  }
}

BoxDecoration _panelDecoration(
  BuildContext context, {
  bool highlighted = false,
}) {
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

class _InlineTag extends StatelessWidget {
  const _InlineTag({
    required this.label,
    required this.accent,
    this.foreground,
  });

  final String label;
  final Color accent;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: foreground ?? accent,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}




