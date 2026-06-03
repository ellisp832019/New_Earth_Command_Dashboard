import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/meeting_system_controller.dart';
import '../data/meeting_folder_service.dart';
import 'meeting_system_widgets.dart';

class MeetingDashboardScreen extends ConsumerStatefulWidget {
  const MeetingDashboardScreen({super.key});

  @override
  ConsumerState<MeetingDashboardScreen> createState() =>
      _MeetingDashboardScreenState();
}

class _MeetingDashboardScreenState
    extends ConsumerState<MeetingDashboardScreen> {
  bool _bootstrapping = false;
  bool _exportingLatestBundle = false;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(meetingDashboardSnapshotProvider);
    final statusSummarySnapshot = ref.watch(meetingStatusSummaryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Meeting Dashboard'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _MeetingDashboardError(
          error: error,
          onRetry: () => ref.invalidate(meetingDashboardSnapshotProvider),
        ),
        data: (data) {
          final workspace = data.workspace;
          final isReady = workspace.isReady;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: meetingPanelDecoration(highlighted: true),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 980;

                      final headline = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meeting System',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppColours.darkText,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Keep every meeting, action, decision, and follow-up in Omega OS without scattering the source of truth.',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColours.darkMutedText,
                                  height: 1.35,
                                ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              MeetingStatChip(
                                label: 'Meetings',
                                value: '${workspace.meetingCount}',
                                accentColor: AppColours.darkPrimary,
                              ),
                              MeetingStatChip(
                                label: 'Actions',
                                value: '${workspace.actionCount}',
                                accentColor: AppColours.darkSuccess,
                              ),
                              MeetingStatChip(
                                label: 'Decisions',
                                value: '${workspace.decisionCount}',
                                accentColor: AppColours.darkAmber,
                              ),
                              MeetingStatChip(
                                label: 'Follow-ups',
                                value: '${workspace.followUpCount}',
                                accentColor: AppColours.darkPurple,
                              ),
                            ],
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
                          FilledButton.tonalIcon(
                            onPressed: () =>
                                context.push(RouteNames.meetingAll),
                            icon: const Icon(Icons.table_chart_outlined),
                            label: const Text('All Meetings'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () =>
                                context.push(RouteNames.meetingNew),
                            icon: const Icon(Icons.add),
                            label: const Text('New Meeting'),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                context.push(RouteNames.meetingActions),
                            icon: const Icon(Icons.checklist_outlined),
                            label: const Text('Actions'),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                context.push(RouteNames.meetingTemplates),
                            icon: const Icon(Icons.description_outlined),
                            label: const Text('Templates'),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                context.push(RouteNames.meetingSettings),
                            icon: const Icon(Icons.settings_outlined),
                            label: const Text('Settings'),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                context.push(RouteNames.meetingDecisions),
                            icon: const Icon(Icons.gavel_outlined),
                            label: const Text('Decisions'),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                context.push(RouteNames.meetingFollowUps),
                            icon: const Icon(Icons.reply_outlined),
                            label: const Text('Follow-ups'),
                          ),
                          TextButton.icon(
                            onPressed: data.recentMeetings.isEmpty ||
                                    _exportingLatestBundle
                                ? null
                                : () => _exportLatestBundle(data.recentMeetings.first),
                            icon: _exportingLatestBundle
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.inventory_2_outlined),
                            label: const Text('Export latest'),
                          ),
                          TextButton.icon(
                            onPressed: _bootstrapping ? null : _createStructure,
                            icon: _bootstrapping
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.create_new_folder_outlined),
                            label: Text(
                              isReady
                                  ? 'Refresh structure'
                                  : 'Create starter files',
                            ),
                          ),
                        ],
                      );

                      if (!wide) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            headline,
                            const SizedBox(height: 20),
                            actions,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: headline),
                          const SizedBox(width: 20),
                          Flexible(child: actions),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                statusSummarySnapshot.when(
                  loading: () => const SizedBox.shrink(),
                  error: (error, stackTrace) => const SizedBox.shrink(),
                  data: (statusSummary) => Container(
                    padding: const EdgeInsets.all(18),
                    decoration: meetingPanelDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MeetingSectionHeader(
                          title: 'Status summary',
                          subtitle:
                              'A quick glance at the current meeting state mix.',
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            MeetingStatChip(
                              label: 'Total',
                              value: '${statusSummary.totalCount}',
                              accentColor: AppColours.darkSecondary,
                            ),
                            MeetingStatChip(
                              label: 'Planned',
                              value: '${statusSummary.plannedCount}',
                              accentColor: AppColours.darkAmber,
                            ),
                            MeetingStatChip(
                              label: 'Open',
                              value: '${statusSummary.openCount}',
                              accentColor: AppColours.darkPrimary,
                            ),
                            MeetingStatChip(
                              label: 'Waiting',
                              value: '${statusSummary.waitingCount}',
                              accentColor: AppColours.darkPurple,
                            ),
                            MeetingStatChip(
                              label: 'Complete',
                              value: '${statusSummary.completeCount}',
                              accentColor: AppColours.darkSuccess,
                            ),
                            MeetingStatChip(
                              label: 'Archived',
                              value: '${statusSummary.archivedCount}',
                              accentColor: AppColours.darkMutedText,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (workspace.issues.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: meetingPanelDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MeetingSectionHeader(
                          title: 'Workspace notes',
                          subtitle:
                              'What the Meeting System needs to calm down.',
                        ),
                        const SizedBox(height: 10),
                        ...workspace.issues.map(
                          (issue) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '• $issue',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColours.darkMutedText),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (workspace.issues.isNotEmpty) const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: meetingPanelDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MeetingSectionHeader(
                        title: 'Live status',
                        subtitle:
                            'Meetings this week ${data.meetingsThisWeekCount}  •  Open actions ${data.openActionsCount}  •  Waiting follow-ups ${data.waitingFollowUpsCount}  •  Decisions this month ${data.decisionsThisMonthCount}',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        workspace.guidanceNote,
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
                          _QuickActionPill(
                            label: 'Open meetings folder',
                            icon: Icons.folder_open_outlined,
                            onTap: workspace.meetingsRootPath == null
                                ? null
                                : () => ref
                                      .read(meetingFolderServiceProvider)
                                      .openFolder(workspace.meetingsRootPath!),
                          ),
                          _QuickActionPill(
                            label: 'Open master index',
                            icon: Icons.description_outlined,
                            onTap: workspace.omegaRootPath == null
                                ? null
                                : () => ref
                                      .read(meetingFolderServiceProvider)
                                      .openFile(
                                        '${workspace.omegaRootPath!}/21_PROJECTS_AND_PROGRAMMES/01_MASTER_INDEXES/meeting_index.json',
                                      ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (data.recentMeetings.isEmpty)
                  const MeetingEmptyPanel(
                    title: 'No meetings yet',
                    message:
                        'Create the first meeting to seed the Omega OS meeting folders and templates.',
                    icon: Icons.event_available_outlined,
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: meetingPanelDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MeetingSectionHeader(
                          title: 'Recent meetings',
                          subtitle: 'Latest Omega OS entries first.',
                          trailing: TextButton(
                            onPressed: () =>
                                context.push(RouteNames.meetingAll),
                            child: const Text('View all'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...data.recentMeetings.map(
                          (meeting) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _RecentMeetingTile(
                              meeting: meeting,
                              onOpen: () => context.push(
                                RouteNames.meetingDetail(meeting.id),
                              ),
                              onOpenFolder: () => ref
                                  .read(meetingFolderServiceProvider)
                                  .openFolder(meeting.folderPath),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _createStructure() async {
    setState(() {
      _bootstrapping = true;
    });

    try {
      await ref
          .read(meetingFolderServiceProvider)
          .createMissingRequiredStructure();
      ref.invalidate(meetingDashboardSnapshotProvider);
      ref.invalidate(meetingWorkspaceProvider);
    } finally {
      if (mounted) {
        setState(() {
          _bootstrapping = false;
        });
      }
    }
  }

  Future<void> _exportLatestBundle(MeetingRecord meeting) async {
    setState(() {
      _exportingLatestBundle = true;
    });

    try {
      final result = await ref
          .read(meetingFolderServiceProvider)
          .exportMeetingBundle(meeting.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Latest bundle exported to ${result.bundlePath}')),
      );
      await ref.read(meetingFolderServiceProvider).openFolder(result.bundlePath);
    } finally {
      if (mounted) {
        setState(() {
          _exportingLatestBundle = false;
        });
      }
    }
  }
}

class _MeetingDashboardError extends StatelessWidget {
  const _MeetingDashboardError({required this.error, required this.onRetry});

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
            const Icon(Icons.event_note_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              'Meeting Dashboard could not load right now.',
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
            FilledButton.tonalIcon(
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

class _QuickActionPill extends StatelessWidget {
  const _QuickActionPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 18, color: AppColours.darkSecondary),
      label: Text(label),
    );
  }
}

class _RecentMeetingTile extends StatelessWidget {
  const _RecentMeetingTile({
    required this.meeting,
    required this.onOpen,
    required this.onOpenFolder,
  });

  final MeetingRecord meeting;
  final VoidCallback onOpen;
  final VoidCallback onOpenFolder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateTime.tryParse(meeting.date);
    final formattedDate = date == null
        ? meeting.date
        : DateFormat('d MMM y').format(date);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${meeting.project}  •  ${meeting.personOrGroup}  •  $formattedDate',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(meeting.status),
                      labelStyle: theme.textTheme.labelSmall?.copyWith(
                        color: AppColours.darkSecondary,
                      ),
                      backgroundColor: AppColours.darkSecondary.withValues(
                        alpha: 0.12,
                      ),
                      side: BorderSide(
                        color: AppColours.darkSecondary.withValues(alpha: 0.25),
                      ),
                    ),
                    if (meeting.tags.isNotEmpty)
                      Chip(
                        label: Text(meeting.tags.first),
                        labelStyle: theme.textTheme.labelSmall?.copyWith(
                          color: AppColours.darkSuccess,
                        ),
                        backgroundColor: AppColours.darkSuccess.withValues(
                          alpha: 0.12,
                        ),
                        side: BorderSide(
                          color: AppColours.darkSuccess.withValues(alpha: 0.25),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new_outlined),
                label: const Text('Open'),
              ),
              TextButton.icon(
                onPressed: onOpenFolder,
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Folder'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
