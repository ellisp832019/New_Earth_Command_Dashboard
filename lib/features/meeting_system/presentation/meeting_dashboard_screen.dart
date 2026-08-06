import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
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
  bool _importingRecording = false;
  String _importingRecordingStatus = '';
  double _importingRecordingProgress = 0.0;
  bool _importingRecordingIndeterminate = false;
  bool _importCancelRequested = false;
  int _whisperDotCount = 0;
  Timer? _whisperDotTimer;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(meetingDashboardSnapshotProvider);
    final statusSummarySnapshot = ref.watch(meetingStatusSummaryProvider);

    return WorkspaceShell(
      title: 'Meeting Dashboard',
      subtitle: 'Local meeting workspace',
      onBack: () {
        if (context.canPop()) {
          context.pop();
        }
      },
      child: snapshot.when(
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
                              MeetingStatChip(
                                label: 'Notifications',
                                value: '${data.notifications.length}',
                                accentColor: AppColours.darkSecondary,
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
                            onPressed: _importingRecording
                                ? null
                                : _importLatestRecording,
                            icon: _importingRecording
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.video_file_outlined),
                            label: Text(
                              _importingRecording
                                  ? 'Importing...'
                                  : 'Import recording',
                            ),
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
                            onPressed:
                                data.recentMeetings.isEmpty ||
                                    _exportingLatestBundle
                                ? null
                                : () => _exportLatestBundle(
                                    data.recentMeetings.first,
                                  ),
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

                      final importStatus = _importingRecording
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinearProgressIndicator(
                                    value: _importingRecordingIndeterminate
                                        ? null
                                        : _importingRecordingProgress.clamp(
                                            0.0,
                                            1.0,
                                          ),
                                    minHeight: 6,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _importStatusLabel(),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColours.darkMutedText,
                                        ),
                                  ),
                                  if (_importingRecordingIndeterminate) ...[
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _ImportStatusChip(
                                          label: 'Whisper running locally',
                                          accentColor: AppColours.darkPrimary,
                                        ),
                                        _ImportStatusChip(
                                          label: 'This can take a few minutes',
                                          accentColor: AppColours.darkMutedText,
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed:
                                          _importingRecording &&
                                              !_importCancelRequested
                                          ? _cancelImport
                                          : null,
                                      icon: const Icon(Icons.close),
                                      label: Text(
                                        _importCancelRequested
                                            ? 'Cancelling...'
                                            : 'Cancel import',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink();

                      if (!wide) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            headline,
                            const SizedBox(height: 20),
                            actions,
                            importStatus,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: headline),
                          const SizedBox(width: 20),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [actions, importStatus],
                            ),
                          ),
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
                _NextMeetingAtAGlanceCard(
                  meeting: data.upcomingMeetings.isEmpty
                      ? null
                      : data.upcomingMeetings.first,
                ),
                const SizedBox(height: 16),
                if (data.notifications.isEmpty)
                  const MeetingEmptyPanel(
                    title: 'No meeting notifications',
                    message:
                        'Scheduled meetings, reminders, and timing alerts will show up here.',
                    icon: Icons.notifications_none_outlined,
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: meetingPanelDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MeetingSectionHeader(
                          title: 'Notifications',
                          subtitle:
                              'A local reminder feed for upcoming meetings and schedule issues.',
                          trailing: TextButton(
                            onPressed: () =>
                                context.push(RouteNames.meetingAll),
                            child: const Text('View all'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...data.notifications.map(
                          (notification) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _MeetingNotificationCard(
                              notification: notification,
                              onOpen: () => context.push(
                                RouteNames.meetingDetail(
                                  notification.meetingId,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                _WeekCalendarSection(meetings: data.upcomingMeetings),
                const SizedBox(height: 16),
                if (data.upcomingMeetings.isEmpty)
                  const MeetingEmptyPanel(
                    title: 'No scheduled meetings yet',
                    message:
                        'Add a time in the wizard and this section will act like a simple calendar block to help prevent double booking.',
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
                          title: 'Schedule',
                          subtitle:
                              'Upcoming meeting blocks in time order so you can spot clashes quickly.',
                          trailing: TextButton(
                            onPressed: () =>
                                context.push(RouteNames.meetingAll),
                            child: const Text('View all'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...data.upcomingMeetings.map(
                          (meeting) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ScheduleMeetingTile(
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
        SnackBar(
          content: Text('Latest bundle exported to ${result.bundlePath}'),
        ),
      );
      await ref
          .read(meetingFolderServiceProvider)
          .openFolder(result.bundlePath);
    } finally {
      if (mounted) {
        setState(() {
          _exportingLatestBundle = false;
        });
      }
    }
  }

  Future<void> _importLatestRecording() async {
    if (_importingRecording) {
      return;
    }

    final folderPath = await FilePicker.getDirectoryPath(
      dialogTitle: 'Select the recording folder',
    );
    if (folderPath == null || folderPath.trim().isEmpty) {
      return;
    }

    setState(() {
      _importingRecording = true;
      _importingRecordingStatus = 'Scanning recording folder...';
      _importingRecordingProgress = 0.08;
      _importingRecordingIndeterminate = false;
      _importCancelRequested = false;
      _whisperDotCount = 0;
    });

    try {
      final result = await ref
          .read(meetingFolderServiceProvider)
          .importLatestRecordingFromFolder(
            folderPath,
            onStatus: (status) {
              if (!mounted) {
                return;
              }
              setState(() {
                _importingRecordingStatus = status;
                _importingRecordingProgress = _progressForImportStatus(status);
                _importingRecordingIndeterminate =
                    status == 'Transcribing recording with Whisper...';
              });
              if (_importingRecordingIndeterminate) {
                _startWhisperAnimation();
              } else {
                _stopWhisperAnimation();
              }
            },
            isCancelled: () => _importCancelRequested,
          );

      ref.invalidate(meetingDashboardSnapshotProvider);
      ref.invalidate(meetingWorkspaceProvider);
      ref.invalidate(meetingListRowsProvider);
      ref.invalidate(meetingMeetingsProvider);
      ref.invalidate(meetingLatestMeetingProvider);
      ref.invalidate(meetingStatusSummaryProvider);
      ref.invalidate(meetingDetailProvider(result.meeting.id));
      ref.invalidate(meetingAttachmentsProvider(result.meeting.id));

      if (!mounted) {
        return;
      }

      if (_importCancelRequested) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording import cancelled.')),
        );
        return;
      }

      final fileName = p.basename(result.recordingSourcePath);
      final distanceLabel = result.minutesFromScheduledWindow == 0
          ? 'It matched the scheduled window.'
          : 'It matched within ${result.minutesFromScheduledWindow} min of the scheduled window.';
      final confidenceLabel =
          'Match confidence: ${result.matchConfidenceLabel}.';
      final harvestParts = <String>[
        if (result.harvestedActionCount > 0)
          '${result.harvestedActionCount} action${result.harvestedActionCount == 1 ? '' : 's'}',
        if (result.harvestedDecisionCount > 0)
          '${result.harvestedDecisionCount} decision${result.harvestedDecisionCount == 1 ? '' : 's'}',
        if (result.harvestedFollowUpCount > 0)
          '${result.harvestedFollowUpCount} follow-up${result.harvestedFollowUpCount == 1 ? '' : 's'}',
      ];
      final harvestLabel = harvestParts.isEmpty
          ? 'No follow-up items were auto-harvested.'
          : 'Auto-harvested ${harvestParts.join(', ')}.';
      context.push(
        Uri(
          path: RouteNames.meetingDetail(result.meeting.id),
          queryParameters: const {'tab': 'transcripts'},
        ).toString(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported $fileName into "${result.meeting.title}" and opened the transcript preview. $distanceLabel $confidenceLabel $harvestLabel',
          ),
        ),
      );
    } catch (error) {
      if (_importCancelRequested) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recording import cancelled.')),
          );
        }
        return;
      }
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      _stopWhisperAnimation();
      if (mounted) {
        setState(() {
          _importingRecording = false;
          _importingRecordingStatus = '';
          _importCancelRequested = false;
          _importingRecordingIndeterminate = false;
        });
      }
    }
  }

  void _cancelImport() {
    if (!_importingRecording) {
      return;
    }

    setState(() {
      _importCancelRequested = true;
      _importingRecordingStatus = 'Cancelling import...';
      _importingRecordingIndeterminate = false;
    });
    ref.read(meetingFolderServiceProvider).cancelActiveRecordingImport();
    _stopWhisperAnimation();
  }

  void _startWhisperAnimation() {
    if (_whisperDotTimer != null) {
      return;
    }

    _whisperDotTimer = Timer.periodic(const Duration(milliseconds: 450), (_) {
      if (!mounted || !_importingRecordingIndeterminate) {
        _stopWhisperAnimation();
        return;
      }
      setState(() {
        _whisperDotCount = (_whisperDotCount + 1) % 4;
      });
    });
  }

  void _stopWhisperAnimation() {
    _whisperDotTimer?.cancel();
    _whisperDotTimer = null;
    if (!mounted) {
      return;
    }
    if (_whisperDotCount != 0) {
      setState(() {
        _whisperDotCount = 0;
      });
    }
  }

  String _importStatusLabel() {
    if (_importingRecordingIndeterminate) {
      final dots = '.' * ((_whisperDotCount % 3) + 1);
      return 'Transcribing with Whisper$dots';
    }

    if (_importingRecordingStatus.isEmpty) {
      return 'Importing recording...';
    }

    return _importingRecordingStatus;
  }

  double _progressForImportStatus(String status) {
    switch (status) {
      case 'Scanning recording folder...':
        return 0.08;
      case 'Matching recording to the closest meeting...':
        return 0.28;
      case 'Reading meeting schedule...':
        return 0.45;
      case 'Transcribing recording with Whisper...':
        return 0.72;
      case 'Saving transcript into the meeting folder...':
        return 0.92;
      default:
        return _importingRecordingProgress;
    }
  }

  @override
  void dispose() {
    _whisperDotTimer?.cancel();
    super.dispose();
  }
}

class _ImportStatusChip extends StatelessWidget {
  const _ImportStatusChip({required this.label, required this.accentColor});

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: accentColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
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

class _NextMeetingAtAGlanceCard extends StatelessWidget {
  const _NextMeetingAtAGlanceCard({required this.meeting});

  final MeetingRecord? meeting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: meetingPanelDecoration(highlighted: true),
      child: meeting == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MeetingSectionHeader(
                  title: 'My time at a glance',
                  subtitle:
                      'Set a meeting time to see the local conversion here instantly.',
                ),
                const SizedBox(height: 12),
                Text(
                  'No scheduled meetings are ready for local conversion yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
                  ),
                ),
              ],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final selectedMeeting = meeting;
                if (selectedMeeting == null) {
                  return const SizedBox.shrink();
                }
                final wide = constraints.maxWidth >= 820;
                final startUtc = selectedMeeting.scheduledStartUtc;
                final localStart = startUtc?.toLocal();
                final myTimeLabel = localStart == null
                    ? 'TBD'
                    : DateFormat('HH:mm').format(localStart);
                final myDateLabel = localStart == null
                    ? 'No local conversion available'
                    : DateFormat('EEE, d MMM y').format(localStart);
                final attendeeTimeLabel = selectedMeeting.time.isEmpty
                    ? 'TBD'
                    : selectedMeeting.time;

                final content = <Widget>[
                  Expanded(
                    child: _TimeAtAglanceCard(
                      label: 'My time',
                      time: myTimeLabel,
                      detail: myDateLabel,
                      accent: AppColours.darkPrimary,
                    ),
                  ),
                  const SizedBox(width: 12, height: 12),
                  Expanded(
                    child: _TimeAtAglanceCard(
                      label: 'Attendee time',
                      time: attendeeTimeLabel,
                      detail: selectedMeeting.timezoneDisplayLabel,
                      accent: AppColours.darkSecondary,
                    ),
                  ),
                ];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MeetingSectionHeader(
                      title: 'My time at a glance',
                      subtitle:
                          'The next scheduled meeting is converted into your local time first, so you can spot it instantly.',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      selectedMeeting.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${selectedMeeting.project} • ${selectedMeeting.personOrGroup}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: content,
                      )
                    else
                      Column(
                        children: [
                          _TimeAtAglanceCard(
                            label: 'My time',
                            time: myTimeLabel,
                            detail: myDateLabel,
                            accent: AppColours.darkPrimary,
                          ),
                          const SizedBox(height: 12),
                          _TimeAtAglanceCard(
                            label: 'Attendee time',
                            time: attendeeTimeLabel,
                            detail: selectedMeeting.timezoneDisplayLabel,
                            accent: AppColours.darkSecondary,
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          label: Text(
                            'Duration ${selectedMeeting.durationMinutes} min',
                          ),
                        ),
                        Chip(label: Text(selectedMeeting.status)),
                        Chip(label: Text(selectedMeeting.date)),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _TimeAtAglanceCard extends StatelessWidget {
  const _TimeAtAglanceCard({
    required this.label,
    required this.time,
    required this.detail,
    required this.accent,
  });

  final String label;
  final String time;
  final String detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: theme.textTheme.displaySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeetingNotificationCard extends StatelessWidget {
  const _MeetingNotificationCard({
    required this.notification,
    required this.onOpen,
  });

  final MeetingNotificationRecord notification;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = switch (notification.severity) {
      'high' => AppColours.darkAmber,
      'warning' => AppColours.darkAmber,
      _ => AppColours.darkSecondary,
    };
    final icon = switch (notification.severity) {
      'high' => Icons.notifications_active_outlined,
      'warning' => Icons.warning_amber_outlined,
      _ => Icons.notifications_outlined,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.26)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text(notification.meetingDate)),
                    Chip(label: Text('My ${notification.myTimeLabel}')),
                    Chip(label: Text(notification.meetingTime)),
                    Chip(label: Text(notification.timezoneLabel)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          TextButton(onPressed: onOpen, child: Text(notification.actionLabel)),
        ],
      ),
    );
  }
}

class _WeekCalendarSection extends StatelessWidget {
  const _WeekCalendarSection({required this.meetings});

  final List<MeetingRecord> meetings;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final days = List<DateTime>.generate(
      7,
      (index) => startOfToday.add(Duration(days: index)),
    );
    final meetingsByDate = <String, List<MeetingRecord>>{};
    for (final meeting in meetings) {
      meetingsByDate
          .putIfAbsent(meeting.date, () => <MeetingRecord>[])
          .add(meeting);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: meetingPanelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MeetingSectionHeader(
            title: 'Week calendar',
            subtitle:
                'A simple seven-day planning strip for spotting meetings and gaps at a glance.',
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 980;
              final cards = days
                  .map(
                    (day) => _WeekDayCard(
                      day: day,
                      meetings:
                          meetingsByDate[_dateKey(day)] ??
                          const <MeetingRecord>[],
                    ),
                  )
                  .toList(growable: false);

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(child: cards[i]),
                    ],
                  ],
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      SizedBox(width: 220, child: cards[i]),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WeekDayCard extends StatelessWidget {
  const _WeekDayCard({required this.day, required this.meetings});

  final DateTime day;
  final List<MeetingRecord> meetings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = _isSameDay(day, DateTime.now());
    final header = DateFormat('EEE').format(day);
    final dateLabel = DateFormat('d MMM').format(day);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isToday
            ? AppColours.darkPrimary.withValues(alpha: 0.10)
            : AppColours.darkSurfaceRaised.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isToday
              ? AppColours.darkPrimary.withValues(alpha: 0.32)
              : AppColours.darkOutline.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                header,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                dateLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            meetings.isEmpty
                ? 'No meetings'
                : '${meetings.length} meeting${meetings.length == 1 ? '' : 's'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 10),
          if (meetings.isEmpty)
            Text(
              'Open space for focus.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
              ),
            )
          else
            ...meetings.take(3).map((meeting) {
              final startUtc = meeting.scheduledStartUtc;
              final myTimeLabel = startUtc == null
                  ? 'TBD'
                  : DateFormat('HH:mm').format(startUtc.toLocal());

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColours.darkSurface.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColours.darkOutline.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        myTimeLabel,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColours.darkPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meeting.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColours.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          if (meetings.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '+ ${meetings.length - 3} more',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScheduleMeetingTile extends StatelessWidget {
  const _ScheduleMeetingTile({
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
    final startUtc = meeting.scheduledStartUtc;
    final localStart = startUtc?.toLocal();
    final myTimeLabel = localStart == null
        ? 'TBD'
        : DateFormat('HH:mm').format(localStart);
    final myDateLabel = localStart == null
        ? 'No local conversion available'
        : DateFormat('EEE, d MMM y').format(localStart);
    final attendeeTimeLabel = meeting.time.isEmpty ? 'TBD' : meeting.time;
    final durationLabel = '${meeting.durationMinutes} min';

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
          Container(
            width: 132,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColours.darkPrimary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColours.darkPrimary.withValues(alpha: 0.24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My time',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  myTimeLabel,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColours.darkPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  myDateLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
                const SizedBox(height: 10),
                Divider(color: AppColours.darkOutline.withValues(alpha: 0.6)),
                const SizedBox(height: 8),
                Text(
                  'Attendee time',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  attendeeTimeLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meeting.timezoneDisplayLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
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
                  '${meeting.project}  •  ${meeting.personOrGroup}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('My $myTimeLabel')),
                    Chip(label: Text('Attendee $attendeeTimeLabel')),
                    Chip(label: Text(durationLabel)),
                    Chip(label: Text(meeting.status)),
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
                  '${meeting.project}  •  ${meeting.personOrGroup}  •  $formattedDate${meeting.time.isEmpty ? '' : '  •  ${meeting.time}'}',
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

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
