import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/meeting_system_controller.dart';
import '../data/meeting_folder_service.dart';
import 'meeting_system_widgets.dart';

class MeetingSettingsScreen extends ConsumerStatefulWidget {
  const MeetingSettingsScreen({super.key});

  @override
  ConsumerState<MeetingSettingsScreen> createState() =>
      _MeetingSettingsScreenState();
}

class _MeetingSettingsScreenState extends ConsumerState<MeetingSettingsScreen> {
  final TextEditingController _masterIndexSearchController =
      TextEditingController();
  bool _refreshing = false;
  String _masterIndexStatusFilter = 'All';

  static const _masterIndexStatusOptions = <String>[
    'All',
    'planned',
    'open',
    'waiting',
    'complete',
    'archived',
  ];

  @override
  void initState() {
    super.initState();
    _masterIndexSearchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _masterIndexSearchController.removeListener(_onSearchChanged);
    _masterIndexSearchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(meetingWorkspaceProvider);
    final hubSnapshot = ref.watch(meetingOmegaHubProvider);
    final masterIndexSnapshot = ref.watch(meetingMasterIndexProvider);
    final latestMeetingSnapshot = ref.watch(meetingLatestMeetingProvider);
    final statusSummarySnapshot = ref.watch(meetingStatusSummaryProvider);
    final rowsSnapshot = ref.watch(meetingListRowsProvider);

    return WorkspaceShell(
      title: 'Meeting Settings',
      subtitle: 'Meeting workspace settings',
      onBack: () {
        if (context.canPop()) {
          context.pop();
        }
      },
      trailingActions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => ref.invalidate(meetingWorkspaceProvider),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _MeetingSettingsError(
          error: error,
          onRetry: () => ref.invalidate(meetingWorkspaceProvider),
        ),
        data: (workspace) {
          return hubSnapshot.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _MeetingSettingsError(
              error: error,
              onRetry: () => ref.invalidate(meetingOmegaHubProvider),
            ),
            data: (hub) {
              final service = ref.read(meetingFolderServiceProvider);
              final omegaRootPath = workspace.omegaRootPath;
              final meetingsRootPath = workspace.meetingsRootPath;
              final templatePath = omegaRootPath == null
                  ? null
                  : '$omegaRootPath/21_PROJECTS_AND_PROGRAMMES/06_TEMPLATES/meeting_folder';

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
                          final chips = Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              MeetingStatChip(
                                label: 'Ready',
                                value: workspace.isReady ? 'Yes' : 'No',
                                accentColor: workspace.isReady
                                    ? AppColours.darkSuccess
                                    : AppColours.darkAmber,
                              ),
                              MeetingStatChip(
                                label: 'Missing folders',
                                value: '${workspace.missingFolders.length}',
                                accentColor: AppColours.darkAmber,
                              ),
                              MeetingStatChip(
                                label: 'Missing files',
                                value: '${workspace.missingFiles.length}',
                                accentColor: AppColours.darkPurple,
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
                                onPressed: _refreshing
                                    ? null
                                    : () => _createStructure(service),
                                icon: _refreshing
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.build_outlined),
                                label: Text(
                                  workspace.isReady
                                      ? 'Refresh structure'
                                      : 'Create starter files',
                                ),
                              ),
                              TextButton.icon(
                                onPressed: omegaRootPath == null
                                    ? null
                                    : () => service.openFolder(omegaRootPath),
                                icon: const Icon(Icons.folder_open_outlined),
                                label: const Text('Open Omega OS'),
                              ),
                              TextButton.icon(
                                onPressed: meetingsRootPath == null
                                    ? null
                                    : () =>
                                          service.openFolder(meetingsRootPath),
                                icon: const Icon(Icons.event_note_outlined),
                                label: const Text('Open meetings folder'),
                              ),
                              TextButton.icon(
                                onPressed: () =>
                                    context.push(RouteNames.meetingDashboard),
                                icon: const Icon(Icons.dashboard_outlined),
                                label: const Text('Back to Dashboard'),
                              ),
                              TextButton.icon(
                                onPressed: workspace.configPath.isEmpty
                                    ? null
                                    : () => service.openFile(
                                        workspace.configPath,
                                      ),
                                icon: const Icon(Icons.settings_outlined),
                                label: const Text('Open local_paths.json'),
                              ),
                            ],
                          );

                          final titleBlock = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Meeting System settings',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: AppColours.darkText,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'These settings keep the meeting module local-first by pointing it at the Omega OS folder and the shared template tree.',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: AppColours.darkMutedText,
                                      height: 1.35,
                                    ),
                              ),
                              const SizedBox(height: 14),
                              chips,
                              const SizedBox(height: 14),
                              if (templatePath != null)
                                SelectableText(
                                  templatePath,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColours.darkSecondary,
                                      ),
                                ),
                            ],
                          );

                          if (!wide) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                titleBlock,
                                const SizedBox(height: 20),
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
                                  'What the Meeting System needs before it is fully ready.',
                            ),
                            const SizedBox(height: 10),
                            ...workspace.issues.map(
                              (issue) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '• $issue',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColours.darkMutedText,
                                      ),
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
                          const MeetingSectionHeader(
                            title: 'Configured paths',
                            subtitle:
                                'The local files that keep the module grounded.',
                          ),
                          const SizedBox(height: 12),
                          _PathRow(
                            label: 'Config file',
                            pathText: workspace.configPath,
                            onOpen: workspace.configPath.isEmpty
                                ? null
                                : () => service.openFile(workspace.configPath),
                          ),
                          _PathRow(
                            label: 'Omega OS root',
                            pathText: omegaRootPath ?? 'Not configured',
                            onOpen: omegaRootPath == null
                                ? null
                                : () => service.openFolder(omegaRootPath),
                          ),
                          _PathRow(
                            label: 'Meetings root',
                            pathText: meetingsRootPath ?? 'Not available yet',
                            onOpen: meetingsRootPath == null
                                ? null
                                : () => service.openFolder(meetingsRootPath),
                          ),
                          _PathRow(
                            label: 'Templates folder',
                            pathText: templatePath ?? 'Not available yet',
                            onOpen: templatePath == null
                                ? null
                                : () => service.openFolder(templatePath),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    statusSummarySnapshot.when(
                      loading: () => Container(
                        padding: const EdgeInsets.all(18),
                        decoration: meetingPanelDecoration(),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stackTrace) => Container(
                        padding: const EdgeInsets.all(18),
                        decoration: meetingPanelDecoration(),
                        child: _MeetingSettingsError(
                          error: error,
                          onRetry: () =>
                              ref.invalidate(meetingStatusSummaryProvider),
                        ),
                      ),
                      data: (summary) => Container(
                        padding: const EdgeInsets.all(18),
                        decoration: meetingPanelDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MeetingSectionHeader(
                              title: 'Meeting status summary',
                              subtitle:
                                  'A calm count of where the meeting work is right now.',
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                MeetingStatChip(
                                  label: 'Total',
                                  value: '${summary.totalCount}',
                                  accentColor: AppColours.darkSecondary,
                                ),
                                MeetingStatChip(
                                  label: 'Planned',
                                  value: '${summary.plannedCount}',
                                  accentColor: AppColours.darkAmber,
                                ),
                                MeetingStatChip(
                                  label: 'Open',
                                  value: '${summary.openCount}',
                                  accentColor: AppColours.darkPrimary,
                                ),
                                MeetingStatChip(
                                  label: 'Waiting',
                                  value: '${summary.waitingCount}',
                                  accentColor: AppColours.darkPurple,
                                ),
                                MeetingStatChip(
                                  label: 'Complete',
                                  value: '${summary.completeCount}',
                                  accentColor: AppColours.darkSuccess,
                                ),
                                MeetingStatChip(
                                  label: 'Archived',
                                  value: '${summary.archivedCount}',
                                  accentColor: AppColours.darkMutedText,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    rowsSnapshot.when(
                      loading: () => Container(
                        padding: const EdgeInsets.all(18),
                        decoration: meetingPanelDecoration(),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stackTrace) => Container(
                        padding: const EdgeInsets.all(18),
                        decoration: meetingPanelDecoration(),
                        child: _MeetingSettingsError(
                          error: error,
                          onRetry: () =>
                              ref.invalidate(meetingListRowsProvider),
                        ),
                      ),
                      data: (rows) {
                        final filteredRows =
                            rows
                                .where(_matchesMasterIndexFilter)
                                .toList(growable: false)
                              ..sort(
                                (a, b) =>
                                    b.meeting.date.compareTo(a.meeting.date),
                              );

                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: meetingPanelDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const MeetingSectionHeader(
                                title: 'Master index search',
                                subtitle:
                                    'Search the live meeting index by project, person, title, status, or folder path. Use the chips to narrow the list and keep the review calm.',
                              ),
                              const SizedBox(height: 12),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final wide = constraints.maxWidth >= 980;
                                  final searchField = TextField(
                                    controller: _masterIndexSearchController,
                                    decoration: InputDecoration(
                                      labelText: 'Search meetings',
                                      prefixIcon: Icon(Icons.search),
                                      suffixIcon:
                                          _masterIndexSearchController
                                              .text
                                              .isEmpty
                                          ? null
                                          : IconButton(
                                              tooltip: 'Clear search',
                                              onPressed: () {
                                                _masterIndexSearchController
                                                    .clear();
                                                setState(() {
                                                  _masterIndexStatusFilter =
                                                      'All';
                                                });
                                              },
                                              icon: const Icon(Icons.clear),
                                            ),
                                    ),
                                  );
                                  final statusField =
                                      DropdownButtonFormField<String>(
                                        initialValue: _masterIndexStatusFilter,
                                        decoration: const InputDecoration(
                                          labelText: 'Status',
                                        ),
                                        items: _masterIndexStatusOptions
                                            .map(
                                              (status) =>
                                                  DropdownMenuItem<String>(
                                                    value: status,
                                                    child: Text(status),
                                                  ),
                                            )
                                            .toList(growable: false),
                                        onChanged: (value) {
                                          setState(() {
                                            _masterIndexStatusFilter =
                                                value ?? 'All';
                                          });
                                        },
                                      );

                                  if (wide) {
                                    return Row(
                                      children: [
                                        Expanded(child: searchField),
                                        const SizedBox(width: 12),
                                        SizedBox(
                                          width: 180,
                                          child: statusField,
                                        ),
                                      ],
                                    );
                                  }

                                  return Column(
                                    children: [
                                      searchField,
                                      const SizedBox(height: 12),
                                      statusField,
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (final status
                                      in _masterIndexStatusOptions)
                                    ChoiceChip(
                                      label: Text(status),
                                      selected:
                                          _masterIndexStatusFilter == status,
                                      onSelected: (_) {
                                        setState(() {
                                          _masterIndexStatusFilter = status;
                                        });
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${filteredRows.length} matching meeting${filteredRows.length == 1 ? '' : 's'}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColours.darkMutedText),
                              ),
                              if (_masterIndexSearchController.text
                                      .trim()
                                      .isNotEmpty ||
                                  _masterIndexStatusFilter != 'All') ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if (_masterIndexSearchController.text
                                        .trim()
                                        .isNotEmpty)
                                      InputChip(
                                        label: Text(
                                          'Search: ${_masterIndexSearchController.text.trim()}',
                                        ),
                                        onDeleted: () {
                                          _masterIndexSearchController.clear();
                                          setState(() {});
                                        },
                                      ),
                                    if (_masterIndexStatusFilter != 'All')
                                      InputChip(
                                        label: Text(
                                          'Status: $_masterIndexStatusFilter',
                                        ),
                                        onDeleted: () {
                                          setState(() {
                                            _masterIndexStatusFilter = 'All';
                                          });
                                        },
                                      ),
                                    TextButton.icon(
                                      onPressed: () {
                                        _masterIndexSearchController.clear();
                                        setState(() {
                                          _masterIndexStatusFilter = 'All';
                                        });
                                      },
                                      icon: const Icon(Icons.clear_all),
                                      label: const Text('Clear filters'),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 12),
                              if (filteredRows.isEmpty)
                                const MeetingEmptyPanel(
                                  title: 'No meetings match the current filter',
                                  message:
                                      'Try a wider search or switch the status chip back to All.',
                                  icon: Icons.search_off_outlined,
                                )
                              else
                                ...filteredRows
                                    .take(5)
                                    .map(
                                      (row) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        child: _MasterIndexResultTile(
                                          row: row,
                                          onOpenMeeting: () => context.push(
                                            RouteNames.meetingDetail(
                                              row.meeting.id,
                                            ),
                                          ),
                                          onOpenFolder: () =>
                                              service.openFolder(
                                                row.meeting.folderPath,
                                              ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: meetingPanelDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MeetingSectionHeader(
                            title: 'Projects & Programmes hub',
                            subtitle:
                                'This mirrors the exact Omega OS tree where the meetings live.',
                          ),
                          const SizedBox(height: 12),
                          _PathRow(
                            label: '21_PROJECTS_AND_PROGRAMMES root',
                            pathText:
                                hub.projectsRootPath ?? 'Not available yet',
                            onOpen: hub.projectsRootPath == null
                                ? null
                                : () =>
                                      service.openFolder(hub.projectsRootPath!),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Core meeting folders',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: AppColours.darkSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 10),
                          ...hub.coreFolders.map(
                            (folder) => _PathRow(
                              label: folder.label,
                              pathText: folder.path,
                              onOpen: () => service.openFolder(folder.path),
                            ),
                          ),
                          const SizedBox(height: 16),
                          latestMeetingSnapshot.when(
                            loading: () => const SizedBox.shrink(),
                            error: (error, stackTrace) =>
                                const SizedBox.shrink(),
                            data: (latestMeeting) {
                              if (latestMeeting == null) {
                                return const SizedBox.shrink();
                              }

                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColours.darkSurfaceRaised
                                      .withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppColours.darkOutline.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Latest meeting folder',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  color:
                                                      AppColours.darkSecondary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            latestMeeting.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppColours.darkText,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${latestMeeting.project}  •  ${latestMeeting.date}  •  ${latestMeeting.personOrGroup}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColours.darkMutedText,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => service.openFolder(
                                            latestMeeting.folderPath,
                                          ),
                                          icon: const Icon(
                                            Icons.folder_open_outlined,
                                          ),
                                          label: const Text('Open folder'),
                                        ),
                                        TextButton.icon(
                                          onPressed: () => context.push(
                                            RouteNames.meetingDetail(
                                              latestMeeting.id,
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.open_in_new_outlined,
                                          ),
                                          label: const Text('Open meeting'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          masterIndexSnapshot.when(
                            loading: () => const SizedBox.shrink(),
                            error: (error, stackTrace) =>
                                const SizedBox.shrink(),
                            data: (masterIndex) {
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColours.darkSurfaceRaised
                                      .withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppColours.darkOutline.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Master index preview',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: AppColours.darkSecondary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${masterIndex.meetingCount} meeting${masterIndex.meetingCount == 1 ? '' : 's'} tracked in the index.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColours.darkMutedText,
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                    SelectableText(
                                      masterIndex.indexPath,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColours.darkSecondary,
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColours.darkSurface
                                            .withValues(alpha: 0.95),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppColours.darkOutline
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                      child: Text(
                                        masterIndex.preview,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColours.darkText,
                                              height: 1.45,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        TextButton.icon(
                                          onPressed:
                                              masterIndex.indexPath.isEmpty
                                              ? null
                                              : () => service.openFile(
                                                  masterIndex.indexPath,
                                                ),
                                          icon: const Icon(
                                            Icons.description_outlined,
                                          ),
                                          label: const Text(
                                            'Open meeting_index',
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed:
                                              masterIndex.masterLogPath.isEmpty
                                              ? null
                                              : () => service.openFile(
                                                  masterIndex.masterLogPath,
                                                ),
                                          icon: const Icon(
                                            Icons.notes_outlined,
                                          ),
                                          label: const Text('Open master log'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Project areas discovered in Omega OS',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: AppColours.darkSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 10),
                          if (hub.projectAreas.isEmpty)
                            Text(
                              'No project areas were found yet under 21_PROJECTS_AND_PROGRAMMES.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColours.darkMutedText),
                            )
                          else
                            ...hub.projectAreas.map(
                              (folder) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ProjectAreaTile(
                                  folder: folder,
                                  onOpen: () => service.openFolder(folder.path),
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
          );
        },
      ),
    );
  }

  Future<void> _createStructure(MeetingFolderService service) async {
    setState(() {
      _refreshing = true;
    });

    try {
      await service.createMissingRequiredStructure();
      ref.invalidate(meetingWorkspaceProvider);
      ref.invalidate(meetingTemplatesProvider);
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
        });
      }
    }
  }

  bool _matchesMasterIndexFilter(MeetingListRow row) {
    final search = _masterIndexSearchController.text.trim().toLowerCase();
    final statusFilter = _masterIndexStatusFilter.toLowerCase();
    final meeting = row.meeting;
    final status = meeting.status.trim().toLowerCase();

    if (statusFilter != 'all' && status != statusFilter) {
      return false;
    }

    if (search.isEmpty) {
      return true;
    }

    final searchableTerms = <String>[
      meeting.id,
      meeting.date,
      meeting.project,
      meeting.title,
      meeting.personOrGroup,
      meeting.meetingType,
      meeting.status,
      meeting.folderPath,
      meeting.agendaPath,
      meeting.notesPath,
      meeting.actionsPath,
      meeting.decisionsPath,
      meeting.followUpPath,
      meeting.purpose,
      meeting.tags.join(' '),
      row.actionCount.toString(),
      row.decisionCount.toString(),
      row.followUpLabel,
    ];

    return searchableTerms.any((value) => value.toLowerCase().contains(search));
  }
}

class _ProjectAreaTile extends StatelessWidget {
  const _ProjectAreaTile({required this.folder, required this.onOpen});

  final MeetingOmegaHubFolder folder;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
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
                  folder.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  folder.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  folder.path,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new_outlined),
            label: const Text('Open'),
          ),
        ],
      ),
    );
  }
}

class _PathRow extends StatelessWidget {
  const _PathRow({
    required this.label,
    required this.pathText,
    required this.onOpen,
  });

  final String label;
  final String pathText;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColours.darkSurfaceRaised.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
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
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColours.darkSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    pathText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.open_in_new_outlined),
              label: const Text('Open'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MasterIndexResultTile extends StatelessWidget {
  const _MasterIndexResultTile({
    required this.row,
    required this.onOpenMeeting,
    required this.onOpenFolder,
  });

  final MeetingListRow row;
  final VoidCallback onOpenMeeting;
  final VoidCallback onOpenFolder;

  @override
  Widget build(BuildContext context) {
    final meeting = row.meeting;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.8),
        ),
      ),
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
                      meeting.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${meeting.date} • ${meeting.project} • ${meeting.personOrGroup}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
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
                  color: AppColours.darkPrimary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColours.darkPrimary.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  meeting.status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkPrimary,
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
              MeetingStatChip(
                label: 'Actions',
                value: '${row.actionCount}',
                accentColor: AppColours.darkSecondary,
              ),
              MeetingStatChip(
                label: 'Decisions',
                value: '${row.decisionCount}',
                accentColor: AppColours.darkPurple,
              ),
              MeetingStatChip(
                label: 'Follow-up',
                value: row.followUpLabel,
                accentColor: AppColours.darkSuccess,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(
            meeting.folderPath,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              TextButton.icon(
                onPressed: onOpenMeeting,
                icon: const Icon(Icons.open_in_new_outlined),
                label: const Text('Open meeting'),
              ),
              TextButton.icon(
                onPressed: onOpenFolder,
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Open folder'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MeetingSettingsError extends StatelessWidget {
  const _MeetingSettingsError({required this.error, required this.onRetry});

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
            const Icon(Icons.settings_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              'Meeting settings could not load right now.',
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
