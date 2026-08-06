import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/meeting_system_controller.dart';
import '../data/meeting_folder_service.dart';
import 'meeting_system_widgets.dart';

class MeetingFollowUpsScreen extends ConsumerStatefulWidget {
  const MeetingFollowUpsScreen({super.key});

  @override
  ConsumerState<MeetingFollowUpsScreen> createState() =>
      _MeetingFollowUpsScreenState();
}

class _MeetingFollowUpsScreenState
    extends ConsumerState<MeetingFollowUpsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _stateFilter = 'All';

  static const _stateOptions = <String>[
    'All',
    'Open',
    'Sent',
    'Closed',
    'Pending',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(meetingFollowUpsProvider);

    return WorkspaceShell(
      title: 'Follow-up Tracker',
      subtitle: 'Meeting follow-up workspace',
      onBack: () {
        if (context.canPop()) {
          context.pop();
        }
      },
      trailingActions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => ref.invalidate(meetingFollowUpsProvider),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _MeetingTrackerError(
          title: 'Follow-up Tracker',
          error: error,
          onRetry: () => ref.invalidate(meetingFollowUpsProvider),
        ),
        data: (followUps) {
          final filtered = followUps
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
                        title: 'All meeting follow-ups',
                        subtitle:
                            'Keep replies, next steps, and pending messages visible.',
                        trailing: Text(
                          '${filtered.length} follow-up${filtered.length == 1 ? '' : 's'}',
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
                                initialValue: _stateFilter,
                                decoration: const InputDecoration(
                                  labelText: 'State',
                                ),
                                items: _stateOptions
                                    .map(
                                      (status) => DropdownMenuItem<String>(
                                        value: status,
                                        child: Text(status),
                                      ),
                                    )
                                    .toList(growable: false),
                                onChanged: (value) {
                                  setState(() {
                                    _stateFilter = value ?? 'All';
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
                    title: 'No follow-ups match the current filters',
                    message:
                        'Add a follow-up from a meeting detail page and it will show here.',
                    icon: Icons.reply_outlined,
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
                                DataColumn(label: Text('Person')),
                                DataColumn(label: Text('Meeting')),
                                DataColumn(label: Text('Project')),
                                DataColumn(label: Text('Message needed')),
                                DataColumn(label: Text('Sent')),
                                DataColumn(label: Text('Response')),
                                DataColumn(label: Text('Next step')),
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
                                (followUp) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _TrackerCard(
                                    title: followUp.person,
                                    subtitle:
                                        '${followUp.meetingTitle}  •  ${followUp.project}',
                                    badges: [
                                      followUp.messageNeeded
                                          ? 'Message needed'
                                          : 'No message needed',
                                      followUp.sent ? 'Sent' : 'Not sent',
                                      followUp.responseReceived
                                          ? 'Response received'
                                          : 'Waiting reply',
                                    ],
                                    onOpen: () => context.push(
                                      RouteNames.meetingDetail(
                                        followUp.meetingId,
                                      ),
                                    ),
                                    onOpenFolder: () =>
                                        _openMeetingFolder(followUp.meetingId),
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

  bool _matchesFilter(MeetingFollowUpRecord followUp) {
    final search = _searchController.text.trim().toLowerCase();
    final state = _stateFilter.trim().toLowerCase();
    final statusLabel = _stateLabel(followUp).toLowerCase();
    final haystack =
        '${followUp.person} ${followUp.meetingTitle} ${followUp.project} ${followUp.nextStep} ${followUp.notes}'
            .toLowerCase();

    if (search.isNotEmpty && !haystack.contains(search)) {
      return false;
    }
    if (state != 'all' && statusLabel != state) {
      return false;
    }
    return true;
  }

  String _stateLabel(MeetingFollowUpRecord followUp) {
    if (followUp.sent && followUp.responseReceived) {
      return 'Closed';
    }
    if (followUp.sent) {
      return 'Sent';
    }
    if (followUp.messageNeeded) {
      return 'Open';
    }
    return 'Pending';
  }

  DataRow _buildDataRow(MeetingFollowUpRecord followUp) {
    return DataRow(
      cells: [
        DataCell(Text(followUp.person)),
        DataCell(Text(followUp.meetingTitle)),
        DataCell(Text(followUp.project)),
        DataCell(Text(followUp.messageNeeded ? 'Yes' : 'No')),
        DataCell(Text(followUp.sent ? 'Yes' : 'No')),
        DataCell(Text(followUp.responseReceived ? 'Yes' : 'No')),
        DataCell(Text(followUp.nextStep)),
        DataCell(
          IconButton(
            tooltip: 'Open meeting',
            onPressed: () =>
                context.push(RouteNames.meetingDetail(followUp.meetingId)),
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
