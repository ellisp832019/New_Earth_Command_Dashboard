import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/meeting_system_controller.dart';
import '../data/meeting_folder_service.dart';
import 'meeting_system_widgets.dart';

class MeetingDecisionsScreen extends ConsumerStatefulWidget {
  const MeetingDecisionsScreen({super.key});

  @override
  ConsumerState<MeetingDecisionsScreen> createState() =>
      _MeetingDecisionsScreenState();
}

class _MeetingDecisionsScreenState
    extends ConsumerState<MeetingDecisionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All';

  static const _statusOptions = <String>[
    'All',
    'proposed',
    'agreed',
    'locked',
    'revisit_later',
    'replaced',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(meetingDecisionsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Decision Tracker'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(meetingDecisionsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _MeetingTrackerError(
          title: 'Decision Tracker',
          error: error,
          onRetry: () => ref.invalidate(meetingDecisionsProvider),
        ),
        data: (decisions) {
          final filtered = decisions
              .where(_matchesFilter)
              .toList(growable: false);

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: meetingPanelDecoration(highlighted: true),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MeetingSectionHeader(
                        title: 'All meeting decisions',
                        subtitle:
                            'Track decisions across meetings and projects without losing the rationale.',
                        trailing: Text(
                          '${filtered.length} decision${filtered.length == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColours.darkSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 920;
                          final filterRow = [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  labelText: 'Search',
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 190,
                              child: DropdownButtonFormField<String>(
                                initialValue: _statusFilter,
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                ),
                                items: _statusOptions
                                    .map(
                                      (status) => DropdownMenuItem<String>(
                                        value: status,
                                        child: Text(status),
                                      ),
                                    )
                                    .toList(growable: false),
                                onChanged: (value) {
                                  setState(() {
                                    _statusFilter = value ?? 'All';
                                  });
                                },
                              ),
                            ),
                          ];

                          return wide
                              ? Row(
                                  children: [
                                    filterRow[0],
                                    const SizedBox(width: 12),
                                    filterRow[1],
                                  ],
                                )
                              : Column(
                                  children: [
                                    filterRow[0],
                                    const SizedBox(height: 12),
                                    filterRow[1],
                                  ],
                                );
                        },
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: () =>
                                context.push(RouteNames.meetingDashboard),
                            icon: const Icon(Icons.dashboard_outlined),
                            label: const Text('Dashboard'),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                context.push(RouteNames.meetingAll),
                            icon: const Icon(Icons.table_chart_outlined),
                            label: const Text('All Meetings'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  const MeetingEmptyPanel(
                    title: 'No decisions match the current filters',
                    message:
                        'Add the first decision from a meeting detail page and it will show here.',
                    icon: Icons.gavel_outlined,
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: meetingPanelDecoration(),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 980;
                        if (wide) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStatePropertyAll(
                                AppColours.darkSurfaceRaised.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                              columns: const [
                                DataColumn(label: Text('Decision')),
                                DataColumn(label: Text('Meeting')),
                                DataColumn(label: Text('Project')),
                                DataColumn(label: Text('Reason')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Open')),
                              ],
                              rows: filtered
                                  .map(_buildDataRow)
                                  .toList(growable: false),
                            ),
                          );
                        }

                        return Column(
                          children: filtered
                              .map(
                                (decision) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _TrackerCard(
                                    title: decision.decision,
                                    subtitle:
                                        '${decision.meetingTitle}  •  ${decision.project}',
                                    badges: [decision.status, decision.reason],
                                    onOpen: () => context.push(
                                      RouteNames.meetingDetail(
                                        decision.meetingId,
                                      ),
                                    ),
                                    onOpenFolder: () =>
                                        _openMeetingFolder(decision.meetingId),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _matchesFilter(MeetingDecisionRecord decision) {
    final search = _searchController.text.trim().toLowerCase();
    final status = _statusFilter.trim().toLowerCase();
    final haystack =
        '${decision.decision} ${decision.meetingTitle} ${decision.project} ${decision.reason}'
            .toLowerCase();

    if (search.isNotEmpty && !haystack.contains(search)) {
      return false;
    }
    if (status != 'all' && decision.status.toLowerCase() != status) {
      return false;
    }
    return true;
  }

  DataRow _buildDataRow(MeetingDecisionRecord decision) {
    return DataRow(
      cells: [
        DataCell(Text(decision.decision)),
        DataCell(Text(decision.meetingTitle)),
        DataCell(Text(decision.project)),
        DataCell(Text(decision.reason)),
        DataCell(Text(decision.status)),
        DataCell(
          IconButton(
            tooltip: 'Open meeting',
            onPressed: () =>
                context.push(RouteNames.meetingDetail(decision.meetingId)),
            icon: const Icon(Icons.open_in_new_outlined),
          ),
        ),
      ],
    );
  }

  Future<void> _openMeetingFolder(String meetingId) async {
    final detail = await ref
        .read(meetingFolderServiceProvider)
        .readMeeting(meetingId);
    await ref
        .read(meetingFolderServiceProvider)
        .openFolder(detail.meeting.folderPath);
  }
}

class _TrackerCard extends StatelessWidget {
  const _TrackerCard({
    required this.title,
    required this.subtitle,
    required this.badges,
    required this.onOpen,
    required this.onOpenFolder,
  });

  final String title;
  final String subtitle;
  final List<String> badges;
  final VoidCallback onOpen;
  final VoidCallback onOpenFolder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: badges.map((badge) => Chip(label: Text(badge))).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new_outlined),
                label: const Text('Open'),
              ),
              const SizedBox(width: 10),
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

class _MeetingTrackerError extends StatelessWidget {
  const _MeetingTrackerError({
    required this.title,
    required this.error,
    required this.onRetry,
  });

  final String title;
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
            const Icon(Icons.report_problem_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              '$title could not load right now.',
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
