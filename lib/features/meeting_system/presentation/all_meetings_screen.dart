import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/meeting_system_controller.dart';
import '../data/meeting_folder_service.dart';
import 'meeting_system_widgets.dart';

class AllMeetingsScreen extends ConsumerStatefulWidget {
  const AllMeetingsScreen({super.key});

  @override
  ConsumerState<AllMeetingsScreen> createState() => _AllMeetingsScreenState();
}

class _AllMeetingsScreenState extends ConsumerState<AllMeetingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _personController = TextEditingController();
  String _statusFilter = 'All';

  static const _statusOptions = <String>[
    'All',
    'planned',
    'open',
    'waiting',
    'complete',
    'archived',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _projectController.dispose();
    _personController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(meetingListRowsProvider);

    return WorkspaceShell(
      title: 'All Meetings',
      subtitle: 'Meeting index workspace',
      onBack: () {
        if (context.canPop()) {
          context.pop();
        }
      },
      trailingActions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => ref.invalidate(meetingListRowsProvider),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _MeetingIndexError(
          error: error,
          onRetry: () => ref.invalidate(meetingListRowsProvider),
        ),
        data: (rows) {
          final filtered = rows.where(_matchesFilter).toList(growable: false)
            ..sort(_compareRowsByScheduleDesc);

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
                        title: 'Meeting index',
                        subtitle:
                            'Search by project, person, title, status, or folder path.',
                        trailing: Text(
                          '${filtered.length} meeting${filtered.length == 1 ? '' : 's'}',
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
                          final wide = constraints.maxWidth >= 1000;
                          final filters = [
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
                            Expanded(
                              child: TextField(
                                controller: _projectController,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  labelText: 'Project',
                                  prefixIcon: Icon(Icons.folder_outlined),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _personController,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  labelText: 'Person / Group',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                              ),
                            ),
                            DropdownButtonFormField<String>(
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
                          ];

                          return wide
                              ? Row(
                                  children: [
                                    filters[0],
                                    const SizedBox(width: 12),
                                    filters[1],
                                    const SizedBox(width: 12),
                                    filters[2],
                                    const SizedBox(width: 12),
                                    SizedBox(width: 180, child: filters[3]),
                                  ],
                                )
                              : Column(
                                  children: [
                                    filters[0],
                                    const SizedBox(height: 12),
                                    filters[1],
                                    const SizedBox(height: 12),
                                    filters[2],
                                    const SizedBox(height: 12),
                                    filters[3],
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
                                context.push(RouteNames.meetingNew),
                            icon: const Icon(Icons.add),
                            label: const Text('New Meeting'),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                context.push(RouteNames.meetingDashboard),
                            icon: const Icon(Icons.dashboard_outlined),
                            label: const Text('Dashboard'),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _projectController.clear();
                                _personController.clear();
                                _statusFilter = 'All';
                              });
                            },
                            icon: const Icon(Icons.clear_outlined),
                            label: const Text('Clear filters'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  const MeetingEmptyPanel(
                    title: 'No meetings match the current filters',
                    message:
                        'Try widening the search or create the first meeting from the wizard.',
                    icon: Icons.event_busy_outlined,
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
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Time')),
                                DataColumn(label: Text('Project')),
                                DataColumn(label: Text('Title')),
                                DataColumn(label: Text('Person')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Actions')),
                                DataColumn(label: Text('Follow-up')),
                                DataColumn(label: Text('Open Folder')),
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
                                (row) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _MeetingListCard(
                                    row: row,
                                    onOpen: () => context.push(
                                      RouteNames.meetingDetail(row.meeting.id),
                                    ),
                                    onOpenFolder: () => ref
                                        .read(meetingFolderServiceProvider)
                                        .openFolder(row.meeting.folderPath),
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

  int _compareRowsByScheduleDesc(MeetingListRow a, MeetingListRow b) {
    final aStart = a.meeting.scheduledStartUtc;
    final bStart = b.meeting.scheduledStartUtc;
    if (aStart != null && bStart != null) {
      return bStart.compareTo(aStart);
    }
    if (aStart != null) {
      return -1;
    }
    if (bStart != null) {
      return 1;
    }
    return b.meeting.date.compareTo(a.meeting.date);
  }

  bool _matchesFilter(MeetingListRow row) {
    final search = _searchController.text.trim().toLowerCase();
    final project = _projectController.text.trim().toLowerCase();
    final person = _personController.text.trim().toLowerCase();
    final status = _statusFilter.trim().toLowerCase();
    final meeting = row.meeting;

    final haystack =
        '${meeting.title} ${meeting.project} ${meeting.personOrGroup} ${meeting.status} ${meeting.folderPath} ${meeting.date} ${meeting.time} ${meeting.timezoneDisplayLabel}'
            .toLowerCase();

    if (search.isNotEmpty && !haystack.contains(search)) {
      return false;
    }
    if (project.isNotEmpty &&
        !meeting.project.toLowerCase().contains(project)) {
      return false;
    }
    if (person.isNotEmpty &&
        !meeting.personOrGroup.toLowerCase().contains(person)) {
      return false;
    }
    if (status != 'all' && meeting.status.toLowerCase() != status) {
      return false;
    }
    return true;
  }

  DataRow _buildDataRow(MeetingListRow row) {
    final date = DateTime.tryParse(row.meeting.date);
    final formattedDate = date == null
        ? row.meeting.date
        : DateFormat('d MMM y').format(date);
    final timeText = row.meeting.time.isEmpty ? 'TBD' : row.meeting.time;

    return DataRow(
      cells: [
        DataCell(Text(formattedDate)),
        DataCell(Text(timeText)),
        DataCell(Text(row.meeting.project)),
        DataCell(
          SizedBox(
            width: 260,
            child: Text(
              row.meeting.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text(row.meeting.personOrGroup)),
        DataCell(Text(row.meeting.status)),
        DataCell(Text('${row.actionCount}')),
        DataCell(Text(row.followUpLabel)),
        DataCell(
          IconButton(
            tooltip: 'Open folder',
            onPressed: () => ref
                .read(meetingFolderServiceProvider)
                .openFolder(row.meeting.folderPath),
            icon: const Icon(Icons.folder_open_outlined),
          ),
        ),
      ],
      onSelectChanged: (_) =>
          context.push(RouteNames.meetingDetail(row.meeting.id)),
    );
  }
}

class _MeetingIndexError extends StatelessWidget {
  const _MeetingIndexError({required this.error, required this.onRetry});

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
            const Icon(Icons.table_chart_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              'Meeting index could not load right now.',
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

class _MeetingListCard extends StatelessWidget {
  const _MeetingListCard({
    required this.row,
    required this.onOpen,
    required this.onOpenFolder,
  });

  final MeetingListRow row;
  final VoidCallback onOpen;
  final VoidCallback onOpenFolder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateTime.tryParse(row.meeting.date);
    final formattedDate = date == null
        ? row.meeting.date
        : DateFormat('d MMM y').format(date);
    final timeText = row.meeting.time.isEmpty ? 'TBD' : row.meeting.time;

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
            row.meeting.title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${row.meeting.project}  •  ${row.meeting.personOrGroup}  •  $formattedDate  •  $timeText',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(row.meeting.status)),
              Chip(label: Text('${row.actionCount} actions')),
              Chip(label: Text('Follow-up ${row.followUpLabel}')),
            ],
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
