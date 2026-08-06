import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../../projects/application/projects_controller.dart';
import '../application/meeting_system_controller.dart';
import '../data/meeting_folder_service.dart';
import 'meeting_system_widgets.dart';

class MeetingDetailScreen extends ConsumerStatefulWidget {
  const MeetingDetailScreen({
    super.key,
    required this.meetingId,
    this.initialTabIndex = 0,
  });

  final String meetingId;
  final int initialTabIndex;

  @override
  ConsumerState<MeetingDetailScreen> createState() =>
      _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends ConsumerState<MeetingDetailScreen> {
  bool _isExporting = false;
  bool _isExportingBundle = false;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(meetingDetailProvider(widget.meetingId));

    return WorkspaceShell(
      title: 'Meeting Detail',
      subtitle: 'Meeting record workspace',
      onBack: () {
        if (context.canPop()) {
          context.pop();
        }
      },
      trailingActions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () =>
              ref.invalidate(meetingDetailProvider(widget.meetingId)),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _MeetingDetailError(
          error: error,
          onRetry: () =>
              ref.invalidate(meetingDetailProvider(widget.meetingId)),
        ),
        data: (detail) {
          final meeting = detail.meeting;
          final date = DateTime.tryParse(meeting.date);
          final formattedDate = date == null
              ? meeting.date
              : DateFormat('d MMM y').format(date);
          final scheduleText = meeting.time.isEmpty
              ? formattedDate
              : '$formattedDate  •  ${meeting.time}  •  ${meeting.timezoneDisplayLabel}';
          final localStart = meeting.scheduledStartUtc?.toLocal();
          final localEnd = localStart?.add(
            Duration(
              minutes: meeting.durationMinutes <= 0
                  ? 60
                  : meeting.durationMinutes,
            ),
          );
          final attendeeTimeLabel = meeting.time.isEmpty
              ? 'Not set'
              : '${meeting.time} ${meeting.timezoneDisplayLabel}';
          final localTimeLabel = localStart == null
              ? 'Not set'
              : '${DateFormat('EEE, d MMM y, HH:mm').format(localStart)}${localEnd == null ? '' : ' - ${DateFormat('HH:mm').format(localEnd)}'}';

          final initialTabIndex = widget.initialTabIndex.clamp(0, 6);

          return DefaultTabController(
            length: 7,
            initialIndex: initialTabIndex,
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: meetingPanelDecoration(highlighted: true),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meeting.title,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppColours.darkText,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${meeting.project}  -  ${meeting.personOrGroup}  -  $scheduleText  -  ${meeting.status}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColours.darkMutedText),
                          ),
                          const SizedBox(height: 14),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final wide = constraints.maxWidth >= 720;
                              final cards = [
                                _TimeComparisonCard(
                                  label: 'My time',
                                  value: localTimeLabel,
                                  sublabel: 'Converted to your device timezone',
                                  accentColor: AppColours.darkPrimary,
                                ),
                                _TimeComparisonCard(
                                  label: 'Attendee time',
                                  value: attendeeTimeLabel,
                                  sublabel: 'The meeting timezone you selected',
                                  accentColor: AppColours.darkSecondary,
                                ),
                              ];

                              if (wide) {
                                return Row(
                                  children: [
                                    Expanded(child: cards[0]),
                                    const SizedBox(width: 12),
                                    Expanded(child: cards[1]),
                                  ],
                                );
                              }

                              return Column(
                                children: [
                                  cards[0],
                                  const SizedBox(height: 12),
                                  cards[1],
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              MeetingStatChip(
                                label: 'Actions',
                                value: '${detail.actions.length}',
                                accentColor: AppColours.darkSuccess,
                              ),
                              MeetingStatChip(
                                label: 'Decisions',
                                value: '${detail.decisions.length}',
                                accentColor: AppColours.darkAmber,
                              ),
                              MeetingStatChip(
                                label: 'Follow-up',
                                value: detail.followUp == null
                                    ? 'None'
                                    : detail.followUp!.sent
                                    ? (detail.followUp!.responseReceived
                                          ? 'Closed'
                                          : 'Sent')
                                    : 'Open',
                                accentColor: AppColours.darkPurple,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () => ref
                                    .read(meetingFolderServiceProvider)
                                    .openFolder(meeting.folderPath),
                                icon: const Icon(Icons.folder_open_outlined),
                                label: const Text('Open folder'),
                              ),
                              TextButton.icon(
                                onPressed: _isExporting
                                    ? null
                                    : () => _exportSummary(detail),
                                icon: _isExporting
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.download_outlined),
                                label: const Text('Export summary'),
                              ),
                              TextButton.icon(
                                onPressed: _isExportingBundle
                                    ? null
                                    : () => _exportBundle(detail),
                                icon: _isExportingBundle
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.inventory_2_outlined),
                                label: const Text('Export bundle'),
                              ),
                              TextButton.icon(
                                onPressed: () => _editSchedule(detail),
                                icon: const Icon(Icons.event_repeat_outlined),
                                label: const Text('Edit schedule'),
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
                  ),
                  const TabBar(
                    tabs: [
                      Tab(text: 'Overview'),
                      Tab(text: 'Notes'),
                      Tab(text: 'Actions'),
                      Tab(text: 'Decisions'),
                      Tab(text: 'Follow-up'),
                      Tab(text: 'Attachments'),
                      Tab(text: 'Links'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _MeetingOverviewTab(detail: detail),
                        _MeetingNotesTab(
                          meetingId: widget.meetingId,
                          initialMarkdown: detail.notesMarkdown,
                        ),
                        _MeetingActionsTab(
                          meetingId: widget.meetingId,
                          detail: detail,
                        ),
                        _MeetingDecisionsTab(
                          meetingId: widget.meetingId,
                          detail: detail,
                        ),
                        _MeetingFollowUpTab(
                          meetingId: widget.meetingId,
                          detail: detail,
                        ),
                        _MeetingAttachmentsTab(detail: detail),
                        _MeetingLinksTab(detail: detail),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _exportSummary(MeetingDetailSnapshot detail) async {
    setState(() {
      _isExporting = true;
    });

    try {
      final summaryPath = await ref
          .read(meetingFolderServiceProvider)
          .exportMeetingSummary(detail.meeting.id);
      ref.invalidate(meetingDetailProvider(widget.meetingId));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Summary exported to $summaryPath')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _exportBundle(MeetingDetailSnapshot detail) async {
    setState(() {
      _isExportingBundle = true;
    });

    try {
      final result = await ref
          .read(meetingFolderServiceProvider)
          .exportMeetingBundle(detail.meeting.id);
      ref.invalidate(meetingDetailProvider(widget.meetingId));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bundle exported to ${result.bundlePath}')),
      );
      await ref
          .read(meetingFolderServiceProvider)
          .openFolder(result.bundlePath);
    } finally {
      if (mounted) {
        setState(() {
          _isExportingBundle = false;
        });
      }
    }
  }

  Future<void> _editSchedule(MeetingDetailSnapshot detail) async {
    final meeting = detail.meeting;
    final initialDate = DateTime.tryParse(meeting.date) ?? DateTime.now();
    final dateController = TextEditingController(text: meeting.date);
    final timeController = TextEditingController(
      text: meeting.time.isEmpty ? '09:00' : meeting.time,
    );
    final durationController = TextEditingController(
      text: meeting.durationMinutes <= 0 ? '60' : '${meeting.durationMinutes}',
    );
    var timezoneId = _detailTimezoneOptions
        .firstWhere(
          (item) => item.offsetMinutes == meeting.timezoneOffsetMinutes,
          orElse: () => _detailTimezoneOptions.first,
        )
        .id;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final preview = _buildSchedulePreview(
              dateText: dateController.text,
              timeText: timeController.text,
              durationText: durationController.text,
              timezoneId: timezoneId,
              currentMeeting: meeting,
            );

            return AlertDialog(
              title: const Text('Edit schedule'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: dateController,
                        decoration: const InputDecoration(
                          labelText: 'Date (yyyy-MM-dd)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: timeController,
                        decoration: InputDecoration(
                          labelText: 'Time (HH:mm)',
                          suffixIcon: IconButton(
                            tooltip: 'Pick time',
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime:
                                    _parseClock(timeController.text) ??
                                    TimeOfDay.fromDateTime(initialDate),
                              );
                              if (picked == null) {
                                return;
                              }
                              setState(() {
                                timeController.text = DateFormat('HH:mm')
                                    .format(
                                      DateTime(
                                        1970,
                                        1,
                                        1,
                                        picked.hour,
                                        picked.minute,
                                      ),
                                    );
                              });
                            },
                            icon: const Icon(Icons.access_time_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: timezoneId,
                        decoration: const InputDecoration(
                          labelText: 'Meeting timezone',
                        ),
                        items: _detailTimezoneOptions
                            .map(
                              (option) => DropdownMenuItem<String>(
                                value: option.id,
                                child: Text(option.label),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          setState(() {
                            timezoneId = value ?? timezoneId;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Duration (minutes)',
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (preview != null)
                        _ScheduleSummaryCard(preview: preview),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true) {
      dateController.dispose();
      timeController.dispose();
      durationController.dispose();
      return;
    }

    final date = dateController.text.trim();
    final time = timeController.text.trim();
    final duration = int.tryParse(durationController.text.trim());
    final timezone = _detailTimezoneOptions.firstWhere(
      (item) => item.id == timezoneId,
      orElse: () => _detailTimezoneOptions.first,
    );
    if (DateTime.tryParse(date) == null ||
        _parseClock(time) == null ||
        duration == null ||
        duration <= 0) {
      dateController.dispose();
      timeController.dispose();
      durationController.dispose();
      _showScheduleMessage('Please enter a valid schedule.');
      return;
    }

    try {
      await ref
          .read(meetingFolderServiceProvider)
          .updateMeetingSchedule(
            meeting.id,
            MeetingScheduleInput(
              date: date,
              time: time,
              timezoneLabel: timezone.label,
              timezoneOffsetMinutes:
                  timezone.offsetMinutes ??
                  DateTime.now().timeZoneOffset.inMinutes,
              durationMinutes: duration,
            ),
          );
      ref.invalidate(meetingDetailProvider(widget.meetingId));
      ref.invalidate(meetingDashboardSnapshotProvider);
      ref.invalidate(meetingListRowsProvider);
      if (!mounted) {
        return;
      }
      _showScheduleMessage('Meeting schedule updated.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showScheduleMessage('Could not update schedule: $error');
    } finally {
      dateController.dispose();
      timeController.dispose();
      durationController.dispose();
    }
  }

  void _showScheduleMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TimeComparisonCard extends StatelessWidget {
  const _TimeComparisonCard({
    required this.label,
    required this.value,
    required this.sublabel,
    required this.accentColor,
  });

  final String label;
  final String value;
  final String sublabel;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sublabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeetingOverviewTab extends ConsumerWidget {
  const _MeetingOverviewTab({required this.detail});

  final MeetingDetailSnapshot detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundleReviewAsync = ref.watch(
      meetingLatestBundleReviewProvider(detail.meeting.id),
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: meetingPanelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MeetingSectionHeader(
                title: 'Metadata',
                subtitle: 'Everything the meeting record knows right now.',
              ),
              const SizedBox(height: 12),
              _MetadataGrid(detail: detail),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: meetingPanelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MeetingSectionHeader(
                title: 'Files',
                subtitle: 'Direct links to the Omega OS meeting files.',
              ),
              const SizedBox(height: 12),
              _FileLinkRow(
                label: 'Agenda',
                path: detail.meeting.agendaPath,
                onOpen: () => ref
                    .read(meetingFolderServiceProvider)
                    .openFile(detail.meeting.agendaPath),
              ),
              _FileLinkRow(
                label: 'Notes',
                path: detail.meeting.notesPath,
                onOpen: () => ref
                    .read(meetingFolderServiceProvider)
                    .openFile(detail.meeting.notesPath),
              ),
              _FileLinkRow(
                label: 'Actions',
                path: detail.meeting.actionsPath,
                onOpen: () => ref
                    .read(meetingFolderServiceProvider)
                    .openFile(detail.meeting.actionsPath),
              ),
              _FileLinkRow(
                label: 'Decisions',
                path: detail.meeting.decisionsPath,
                onOpen: () => ref
                    .read(meetingFolderServiceProvider)
                    .openFile(detail.meeting.decisionsPath),
              ),
              _FileLinkRow(
                label: 'Follow-up',
                path: detail.meeting.followUpPath,
                onOpen: () => ref
                    .read(meetingFolderServiceProvider)
                    .openFile(detail.meeting.followUpPath),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        bundleReviewAsync.when(
          loading: () => Container(
            padding: const EdgeInsets.all(18),
            decoration: meetingPanelDecoration(),
            child: const Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Loading bundle review...'),
              ],
            ),
          ),
          error: (error, stackTrace) => Container(
            padding: const EdgeInsets.all(18),
            decoration: meetingPanelDecoration(),
            child: Text(
              'Bundle review could not load right now.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            ),
          ),
          data: (bundleReview) {
            if (bundleReview == null) {
              return MeetingEmptyPanel(
                title: 'No bundle exported yet',
                message:
                    'Export a bundle from this meeting when you want a compact review pack with the summary, notes, actions, decisions, and follow-up together.',
                icon: Icons.inventory_2_outlined,
                action: FilledButton.tonalIcon(
                  onPressed: () => ref
                      .read(meetingFolderServiceProvider)
                      .openFolder(detail.meeting.folderPath),
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Open meeting folder'),
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(18),
              decoration: meetingPanelDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MeetingSectionHeader(
                    title: 'Bundle review',
                    subtitle:
                        'The latest export bundle for this meeting stays openable from here.',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      MeetingStatChip(
                        label: 'Files',
                        value: '${bundleReview.fileCount}',
                        accentColor: AppColours.darkPrimary,
                      ),
                      MeetingStatChip(
                        label: 'Ready',
                        value: bundleReview.exists ? 'Yes' : 'Partial',
                        accentColor: bundleReview.exists
                            ? AppColours.darkSuccess
                            : AppColours.darkAmber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FileLinkRow(
                    label: 'Bundle folder',
                    path: bundleReview.bundlePath,
                    onOpen: () => ref
                        .read(meetingFolderServiceProvider)
                        .openFolder(bundleReview.bundlePath),
                  ),
                  _FileLinkRow(
                    label: 'Summary',
                    path: bundleReview.summaryPath,
                    onOpen: () => ref
                        .read(meetingFolderServiceProvider)
                        .openFile(bundleReview.summaryPath),
                  ),
                  _FileLinkRow(
                    label: 'Manifest',
                    path: bundleReview.manifestPath,
                    onOpen: () => ref
                        .read(meetingFolderServiceProvider)
                        .openFile(bundleReview.manifestPath),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MeetingNotesTab extends ConsumerStatefulWidget {
  const _MeetingNotesTab({
    required this.meetingId,
    required this.initialMarkdown,
  });

  final String meetingId;
  final String initialMarkdown;

  @override
  ConsumerState<_MeetingNotesTab> createState() => _MeetingNotesTabState();
}

class _MeetingNotesTabState extends ConsumerState<_MeetingNotesTab> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialMarkdown);
    _controller.addListener(_onMarkdownChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onMarkdownChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onMarkdownChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionsPreview = _sectionPreview(
      _controller.text,
      'Questions for attendee',
    );
    final summaryPreview = _sectionPreview(_controller.text, 'Summary');
    final mainPointsPreview = _sectionPreview(_controller.text, 'Main points');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: meetingPanelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MeetingSectionHeader(
                title: 'Meeting notes',
                subtitle:
                    'Edit the markdown that lives in 01_MEETING_NOTES.md, or work section by section below.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _NotesSectionCard(
                    title: 'Questions for attendee',
                    preview: questionsPreview,
                    onEdit: _saving
                        ? null
                        : () => _editSection('Questions for attendee'),
                    onDelete: _saving
                        ? null
                        : () => _deleteSection('Questions for attendee'),
                  ),
                  _NotesSectionCard(
                    title: 'Summary',
                    preview: summaryPreview,
                    onEdit: _saving ? null : () => _editSection('Summary'),
                    onDelete: _saving ? null : () => _deleteSection('Summary'),
                  ),
                  _NotesSectionCard(
                    title: 'Main points',
                    preview: mainPointsPreview,
                    onEdit: _saving ? null : () => _editSection('Main points'),
                    onDelete: _saving
                        ? null
                        : () => _deleteSection('Main points'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                minLines: 16,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Notes markdown',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Save notes'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
    });

    try {
      await ref
          .read(meetingFolderServiceProvider)
          .updateMeetingNotes(widget.meetingId, _controller.text);
      if (!mounted) {
        return;
      }
      ref.invalidate(meetingDetailProvider(widget.meetingId));
      ref.invalidate(meetingDashboardSnapshotProvider);
      ref.invalidate(meetingWorkspaceProvider);
      ref.invalidate(meetingListRowsProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Meeting notes saved.')));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _editSection(String heading) async {
    final controller = TextEditingController(
      text: _sectionBody(_controller.text, heading),
    );

    try {
      final updated = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text('Edit $heading'),
            content: SizedBox(
              width: 560,
              child: TextField(
                controller: controller,
                minLines: 8,
                maxLines: 12,
                decoration: const InputDecoration(
                  labelText: 'Section content',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton.tonalIcon(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(controller.text),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save changes'),
              ),
            ],
          );
        },
      );

      if (updated == null) {
        return;
      }

      setState(() {
        _controller.text = _replaceSection(_controller.text, heading, updated);
      });
      await _save();
    } finally {
      controller.dispose();
    }
  }

  Future<void> _deleteSection(String heading) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Delete $heading'),
          content: Text(
            'Remove the $heading section from the meeting notes? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _controller.text = _removeSection(_controller.text, heading);
    });
    await _save();
  }

  String _sectionBody(String markdown, String heading) {
    final normalized = markdown.replaceAll('\r\n', '\n');
    final lines = normalized.split('\n');
    final headingIndex = lines.indexWhere(
      (line) => line.trim() == '## $heading',
    );
    if (headingIndex == -1) {
      return '';
    }

    var endIndex = lines.length;
    for (var index = headingIndex + 1; index < lines.length; index++) {
      if (lines[index].startsWith('## ')) {
        endIndex = index;
        break;
      }
    }

    return lines.sublist(headingIndex + 1, endIndex).join('\n').trim();
  }

  String _sectionPreview(String markdown, String heading) {
    final body = _sectionBody(markdown, heading);
    if (body.isEmpty) {
      return 'Not set yet.';
    }
    final compact = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= 72) {
      return compact;
    }
    return '${compact.substring(0, 69)}...';
  }

  String _replaceSection(String markdown, String heading, String content) {
    final normalized = markdown.replaceAll('\r\n', '\n');
    final lines = normalized.split('\n');
    final headingIndex = lines.indexWhere(
      (line) => line.trim() == '## $heading',
    );
    final sectionLines = <String>['## $heading', '', content.trim(), ''];

    if (headingIndex == -1) {
      if (normalized.trim().isEmpty) {
        return sectionLines.join('\n').trimRight();
      }
      return '${normalized.trimRight()}\n\n${sectionLines.join('\n').trimRight()}';
    }

    var endIndex = lines.length;
    for (var index = headingIndex + 1; index < lines.length; index++) {
      if (lines[index].startsWith('## ')) {
        endIndex = index;
        break;
      }
    }

    final before = lines.take(headingIndex).toList(growable: false);
    final after = lines.skip(endIndex).toList(growable: false);
    return [
      ...before,
      ...sectionLines,
      ...after,
    ].join('\n').replaceFirst(RegExp(r'\n+$'), '\n');
  }

  String _removeSection(String markdown, String heading) {
    final normalized = markdown.replaceAll('\r\n', '\n');
    final lines = normalized.split('\n');
    final headingIndex = lines.indexWhere(
      (line) => line.trim() == '## $heading',
    );
    if (headingIndex == -1) {
      return markdown;
    }

    var startIndex = headingIndex;
    while (startIndex > 0 && lines[startIndex - 1].trim().isEmpty) {
      startIndex--;
    }

    var endIndex = lines.length;
    for (var index = headingIndex + 1; index < lines.length; index++) {
      if (lines[index].startsWith('## ')) {
        endIndex = index;
        break;
      }
    }
    while (endIndex < lines.length && lines[endIndex].trim().isEmpty) {
      endIndex++;
    }

    final updated = <String>[
      ...lines.take(startIndex),
      ...lines.skip(endIndex),
    ];
    final result = updated.join('\n').replaceFirst(RegExp(r'\n+$'), '\n');
    return result.trim().isEmpty ? '' : result;
  }
}

class _NotesSectionCard extends StatelessWidget {
  const _NotesSectionCard({
    required this.title,
    required this.preview,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String preview;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 360),
      child: Container(
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
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColours.darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              preview,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MeetingActionsTab extends ConsumerStatefulWidget {
  const _MeetingActionsTab({required this.meetingId, required this.detail});

  final String meetingId;
  final MeetingDetailSnapshot detail;

  @override
  ConsumerState<_MeetingActionsTab> createState() => _MeetingActionsTabState();
}

class _MeetingActionsTabState extends ConsumerState<_MeetingActionsTab> {
  final TextEditingController _actionController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController(
    text: 'Peter',
  );
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _status = 'open';
  bool _saving = false;

  static const _statusOptions = <String>[
    'open',
    'doing',
    'waiting',
    'done',
    'blocked',
    'archived',
  ];

  @override
  void dispose() {
    _actionController.dispose();
    _ownerController.dispose();
    _dueDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: meetingPanelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MeetingSectionHeader(
                title: 'Add action',
                subtitle:
                    'Add one meeting action and it will also appear in the master action log.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _actionController,
                decoration: const InputDecoration(
                  labelText: 'Action',
                  prefixIcon: Icon(Icons.checklist_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ownerController,
                      decoration: const InputDecoration(
                        labelText: 'Owner',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _dueDateController,
                      decoration: const InputDecoration(
                        labelText: 'Due date',
                        prefixIcon: Icon(Icons.date_range_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
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
                    _status = value ?? 'open';
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: _saving ? null : _saveAction,
                icon: _saving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: const Text('Add action'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _MeetingProjectTaskLinksCard(
          projectsAsync: projectsAsync,
          meeting: widget.detail.meeting,
          title: 'Action links',
          subtitle:
              'Keep the matching project record close and spin up a task when the action is ready to move.',
          matchCopy:
              'Matched project records make this action easier to move into a live task.',
          noMatchCopy:
              'No exact project match yet. Open the Projects Hub to resolve the live project record, then come back to create a task.',
          taskTitlePrefix: 'Action follow-up',
          createTaskDescription: _meetingTaskDescription(widget.detail.meeting),
          createTaskNotes: _meetingTaskNotes(widget.detail.meeting),
          onOpenProjectsHub: () => context.go(RouteNames.projectsIntelligence),
          onOpenTasks: () => context.push(RouteNames.tasks),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: meetingPanelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MeetingSectionHeader(
                title: 'Current actions',
                subtitle:
                    '${widget.detail.actions.length} action${widget.detail.actions.length == 1 ? '' : 's'} recorded here.',
              ),
              const SizedBox(height: 12),
              if (widget.detail.actions.isEmpty)
                const MeetingEmptyPanel(
                  title: 'No actions yet',
                  message: 'Add the first action for this meeting above.',
                  icon: Icons.checklist_outlined,
                )
              else
                ...widget.detail.actions.map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColours.darkSurfaceRaised.withValues(
                          alpha: 0.9,
                        ),
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
                                child: Text(
                                  action.action,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: AppColours.darkText,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: _saving
                                        ? null
                                        : () => _editAction(action),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                    ),
                                    label: const Text('Edit'),
                                  ),
                                  TextButton.icon(
                                    onPressed: _saving
                                        ? null
                                        : () => _deleteAction(action),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                    ),
                                    label: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${action.owner} • Due ${action.dueDate.isEmpty ? 'not set' : action.dueDate} • ${action.status}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColours.darkMutedText),
                          ),
                          if (action.notes.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              action.notes,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColours.darkMutedText),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveAction() async {
    if (_actionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add an action first.')),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await ref
          .read(meetingFolderServiceProvider)
          .addAction(
            widget.meetingId,
            MeetingActionInput(
              action: _actionController.text,
              owner: _ownerController.text,
              dueDate: _dueDateController.text,
              status: _status,
              notes: _notesController.text,
            ),
          );
      if (!mounted) {
        return;
      }
      ref.invalidate(meetingDetailProvider(widget.meetingId));
      ref.invalidate(meetingActionsProvider);
      ref.invalidate(meetingDashboardSnapshotProvider);
      ref.invalidate(meetingWorkspaceProvider);
      ref.invalidate(meetingListRowsProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Action added.')));
      _actionController.clear();
      _ownerController.text = 'Peter';
      _dueDateController.clear();
      _notesController.clear();
      setState(() {
        _status = 'open';
      });
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _editAction(MeetingActionRecord action) async {
    final actionController = TextEditingController(text: action.action);
    final ownerController = TextEditingController(text: action.owner);
    final dueDateController = TextEditingController(text: action.dueDate);
    final notesController = TextEditingController(text: action.notes);
    var status = action.status;

    try {
      final updated = await showDialog<MeetingActionInput>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Edit action'),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: 520,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: actionController,
                          decoration: const InputDecoration(
                            labelText: 'Action',
                            prefixIcon: Icon(Icons.checklist_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: ownerController,
                                decoration: const InputDecoration(
                                  labelText: 'Owner',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: dueDateController,
                                decoration: const InputDecoration(
                                  labelText: 'Due date',
                                  prefixIcon: Icon(Icons.date_range_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                          items: _statusOptions
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            setDialogState(() {
                              status = value ?? 'open';
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      if (actionController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please add an action title.'),
                          ),
                        );
                        return;
                      }
                      Navigator.of(dialogContext).pop(
                        MeetingActionInput(
                          action: actionController.text,
                          owner: ownerController.text,
                          dueDate: dueDateController.text,
                          status: status,
                          notes: notesController.text,
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save changes'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (updated == null) {
        return;
      }

      await ref
          .read(meetingFolderServiceProvider)
          .updateAction(widget.meetingId, action.id, updated);
      if (!mounted) {
        return;
      }
      ref.invalidate(meetingDetailProvider(widget.meetingId));
      ref.invalidate(meetingActionsProvider);
      ref.invalidate(meetingDashboardSnapshotProvider);
      ref.invalidate(meetingWorkspaceProvider);
      ref.invalidate(meetingListRowsProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Action updated.')));
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      actionController.dispose();
      ownerController.dispose();
      dueDateController.dispose();
      notesController.dispose();
    }
  }

  Future<void> _deleteAction(MeetingActionRecord action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete action'),
          content: Text(
            'Remove "${action.action}" from this meeting? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref
          .read(meetingFolderServiceProvider)
          .deleteAction(widget.meetingId, action.id);
      if (!mounted) {
        return;
      }
      ref.invalidate(meetingDetailProvider(widget.meetingId));
      ref.invalidate(meetingActionsProvider);
      ref.invalidate(meetingDashboardSnapshotProvider);
      ref.invalidate(meetingWorkspaceProvider);
      ref.invalidate(meetingListRowsProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Action deleted.')));
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _MeetingDecisionsTab extends ConsumerStatefulWidget {
  const _MeetingDecisionsTab({required this.meetingId, required this.detail});

  final String meetingId;
  final MeetingDetailSnapshot detail;

  @override
  ConsumerState<_MeetingDecisionsTab> createState() =>
      _MeetingDecisionsTabState();
}

class _MeetingDecisionsTabState extends ConsumerState<_MeetingDecisionsTab> {
  final TextEditingController _decisionController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String _status = 'proposed';
  bool _saving = false;

  static const _statusOptions = <String>[
    'proposed',
    'agreed',
    'locked',
    'revisit_later',
    'replaced',
  ];

  @override
  void dispose() {
    _decisionController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: meetingPanelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MeetingSectionHeader(
                title: 'Add decision',
                subtitle:
                    'Add a decision and it will also appear in the master decision log.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _decisionController,
                decoration: const InputDecoration(
                  labelText: 'Decision',
                  prefixIcon: Icon(Icons.gavel_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
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
                    _status = value ?? 'proposed';
                  });
                },
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: _saving ? null : _saveDecision,
                icon: _saving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: const Text('Add decision'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _MeetingProjectTaskLinksCard(
          projectsAsync: projectsAsync,
          meeting: widget.detail.meeting,
          title: 'Decision links',
          subtitle:
              'Keep the matching project close and turn the decision into a tracked task when it needs follow-through.',
          matchCopy:
              'Matched project records make this decision easier to turn into a task.',
          noMatchCopy:
              'No exact project match yet. Open the Projects Hub to resolve the live project record, then come back to create a task.',
          taskTitlePrefix: 'Decision follow-up',
          createTaskDescription: _meetingTaskDescription(widget.detail.meeting),
          createTaskNotes: _meetingTaskNotes(widget.detail.meeting),
          onOpenProjectsHub: () => context.go(RouteNames.projectsIntelligence),
          onOpenTasks: () => context.push(RouteNames.tasks),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: meetingPanelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MeetingSectionHeader(
                title: 'Current decisions',
                subtitle:
                    '${widget.detail.decisions.length} decision${widget.detail.decisions.length == 1 ? '' : 's'} recorded here.',
              ),
              const SizedBox(height: 12),
              if (widget.detail.decisions.isEmpty)
                const MeetingEmptyPanel(
                  title: 'No decisions yet',
                  message: 'Add the first decision for this meeting above.',
                  icon: Icons.gavel_outlined,
                )
              else
                ...widget.detail.decisions.map(
                  (decision) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColours.darkSurfaceRaised.withValues(
                          alpha: 0.9,
                        ),
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
                                child: Text(
                                  decision.decision,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: AppColours.darkText,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: _saving
                                        ? null
                                        : () => _editDecision(decision),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                    ),
                                    label: const Text('Edit'),
                                  ),
                                  TextButton.icon(
                                    onPressed: _saving
                                        ? null
                                        : () => _deleteDecision(decision),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                    ),
                                    label: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${decision.status} • ${decision.reason}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColours.darkMutedText),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveDecision() async {
    if (_decisionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a decision first.')),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await ref
          .read(meetingFolderServiceProvider)
          .addDecision(
            widget.meetingId,
            MeetingDecisionInput(
              decision: _decisionController.text,
              reason: _reasonController.text,
              status: _status,
            ),
          );
      if (!mounted) {
        return;
      }
      ref.invalidate(meetingDetailProvider(widget.meetingId));
      ref.invalidate(meetingDecisionsProvider);
      ref.invalidate(meetingDashboardSnapshotProvider);
      ref.invalidate(meetingWorkspaceProvider);
      ref.invalidate(meetingListRowsProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Decision added.')));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _editDecision(MeetingDecisionRecord decision) async {
    final decisionController = TextEditingController(text: decision.decision);
    final reasonController = TextEditingController(text: decision.reason);
    var status = decision.status;

    try {
      final updated = await showDialog<MeetingDecisionInput>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Edit decision'),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: 520,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: decisionController,
                          decoration: const InputDecoration(
                            labelText: 'Decision',
                            prefixIcon: Icon(Icons.gavel_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: reasonController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Reason',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                          items: _statusOptions
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            setDialogState(() {
                              status = value ?? 'proposed';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      if (decisionController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please add a decision title.'),
                          ),
                        );
                        return;
                      }
                      Navigator.of(dialogContext).pop(
                        MeetingDecisionInput(
                          decision: decisionController.text,
                          reason: reasonController.text,
                          status: status,
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save changes'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (updated == null) {
        return;
      }

      await ref
          .read(meetingFolderServiceProvider)
          .updateDecision(widget.meetingId, decision.id, updated);
      if (!mounted) {
        return;
      }
      ref.invalidate(meetingDetailProvider(widget.meetingId));
      ref.invalidate(meetingDecisionsProvider);
      ref.invalidate(meetingDashboardSnapshotProvider);
      ref.invalidate(meetingWorkspaceProvider);
      ref.invalidate(meetingListRowsProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Decision updated.')));
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      decisionController.dispose();
      reasonController.dispose();
    }
  }

  Future<void> _deleteDecision(MeetingDecisionRecord decision) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete decision'),
          content: Text(
            'Remove "${decision.decision}" from this meeting? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref
          .read(meetingFolderServiceProvider)
          .deleteDecision(widget.meetingId, decision.id);
      if (!mounted) {
        return;
      }
      ref.invalidate(meetingDetailProvider(widget.meetingId));
      ref.invalidate(meetingDecisionsProvider);
      ref.invalidate(meetingDashboardSnapshotProvider);
      ref.invalidate(meetingWorkspaceProvider);
      ref.invalidate(meetingListRowsProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Decision deleted.')));
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _MeetingFollowUpTab extends ConsumerStatefulWidget {
  const _MeetingFollowUpTab({required this.meetingId, required this.detail});

  final String meetingId;
  final MeetingDetailSnapshot detail;

  @override
  ConsumerState<_MeetingFollowUpTab> createState() =>
      _MeetingFollowUpTabState();
}

class _MeetingFollowUpTabState extends ConsumerState<_MeetingFollowUpTab> {
  late final TextEditingController _personController;
  late final TextEditingController _nextStepController;
  late final TextEditingController _notesController;
  late final TextEditingController _messageDraftController;
  final ScrollController _scrollController = ScrollController();
  bool _messageNeeded = true;
  bool _sent = false;
  bool _responseReceived = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final followUp = widget.detail.followUp;
    _personController = TextEditingController(
      text: followUp?.person.isNotEmpty == true
          ? followUp!.person
          : widget.detail.meeting.personOrGroup,
    );
    _nextStepController = TextEditingController(text: followUp?.nextStep ?? '');
    _notesController = TextEditingController(text: followUp?.notes ?? '');
    _messageDraftController = TextEditingController(
      text: followUp?.messageDraft.isNotEmpty == true
          ? followUp!.messageDraft
          : _defaultMessageDraft(widget.detail.meeting.personOrGroup),
    );
    _messageNeeded = followUp?.messageNeeded ?? true;
    _sent = followUp?.sent ?? false;
    _responseReceived = followUp?.responseReceived ?? false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _personController.dispose();
    _nextStepController.dispose();
    _notesController.dispose();
    _messageDraftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final followUp = widget.detail.followUp;
    final projectsAsync = ref.watch(projectsProvider);

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: meetingPanelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MeetingSectionHeader(
                title: 'Follow-up',
                subtitle:
                    'Track the next message, the reply state, and the next step.',
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _messageNeeded,
                onChanged: (value) {
                  setState(() {
                    _messageNeeded = value;
                  });
                },
                title: const Text('Message needed'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _sent,
                onChanged: (value) {
                  setState(() {
                    _sent = value;
                  });
                },
                title: const Text('Sent'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _responseReceived,
                onChanged: (value) {
                  setState(() {
                    _responseReceived = value;
                  });
                },
                title: const Text('Response received'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _personController,
                decoration: const InputDecoration(
                  labelText: 'Person',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nextStepController,
                decoration: const InputDecoration(
                  labelText: 'Next step',
                  prefixIcon: Icon(Icons.timeline_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageDraftController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Message draft',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: _saving ? null : _saveFollowUp,
                icon: _saving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  followUp == null ? 'Save follow-up' : 'Update follow-up',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _MeetingProjectTaskLinksCard(
          projectsAsync: projectsAsync,
          meeting: widget.detail.meeting,
          title: 'Follow-up links',
          subtitle:
              'Keep the meeting follow-up pointed at the matching project and the task list.',
          matchCopy:
              'Matched project records make the follow-up easy to turn into a task.',
          noMatchCopy:
              'No exact project match yet. Open the Projects Hub to resolve the live project record, then come back to create a task.',
          taskTitlePrefix: 'Follow-up work',
          createTaskDescription: _meetingTaskDescription(widget.detail.meeting),
          createTaskNotes: _meetingTaskNotes(widget.detail.meeting),
          onOpenProjectsHub: () => context.go(RouteNames.projectsIntelligence),
          onOpenTasks: () => context.push(RouteNames.tasks),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: meetingPanelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MeetingSectionHeader(
                title: 'Follow-up record',
                subtitle: 'What the tracker will show for this meeting.',
              ),
              const SizedBox(height: 12),
              if (followUp == null)
                const MeetingEmptyPanel(
                  title: 'No follow-up record yet',
                  message:
                      'Save one above and it will appear here and in the tracker.',
                  icon: Icons.reply_outlined,
                )
              else
                _FollowUpSummaryCard(
                  followUp: followUp,
                  onEdit: _scrollToFollowUpForm,
                  onDelete: _deleteFollowUp,
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _defaultMessageDraft(String person) {
    return '''
Hi $person,

Thank you for the meeting today.

The key points I took from it were:

- 

My next steps are:

1. 

Thanks,
Peter
''';
  }

  Future<void> _saveFollowUp() async {
    setState(() {
      _saving = true;
    });

    try {
      await ref
          .read(meetingFolderServiceProvider)
          .updateFollowUp(
            widget.meetingId,
            MeetingFollowUpInput(
              person: _personController.text,
              messageNeeded: _messageNeeded,
              sent: _sent,
              responseReceived: _responseReceived,
              nextStep: _nextStepController.text,
              notes: _notesController.text,
              messageDraft: _messageDraftController.text,
              id: widget.detail.followUp?.id,
              createdAt: widget.detail.followUp?.createdAt,
            ),
          );
      if (!mounted) {
        return;
      }
      ref.invalidate(meetingDetailProvider(widget.meetingId));
      ref.invalidate(meetingFollowUpsProvider);
      ref.invalidate(meetingDashboardSnapshotProvider);
      ref.invalidate(meetingWorkspaceProvider);
      ref.invalidate(meetingListRowsProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Follow-up saved.')));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _scrollToFollowUpForm() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _deleteFollowUp() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete follow-up'),
          content: const Text(
            'Remove this follow-up record from the meeting? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref
          .read(meetingFolderServiceProvider)
          .deleteFollowUp(widget.meetingId);
      if (!mounted) {
        return;
      }
      _personController.text = widget.detail.meeting.personOrGroup;
      _nextStepController.clear();
      _notesController.clear();
      _messageDraftController.text = _defaultMessageDraft(
        widget.detail.meeting.personOrGroup,
      );
      setState(() {
        _messageNeeded = true;
        _sent = false;
        _responseReceived = false;
      });
      ref.invalidate(meetingDetailProvider(widget.meetingId));
      ref.invalidate(meetingFollowUpsProvider);
      ref.invalidate(meetingDashboardSnapshotProvider);
      ref.invalidate(meetingWorkspaceProvider);
      ref.invalidate(meetingListRowsProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Follow-up deleted.')));
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _MeetingAttachmentsTab extends ConsumerStatefulWidget {
  const _MeetingAttachmentsTab({required this.detail});

  final MeetingDetailSnapshot detail;

  @override
  ConsumerState<_MeetingAttachmentsTab> createState() =>
      _MeetingAttachmentsTabState();
}

class _MeetingAttachmentsTabState
    extends ConsumerState<_MeetingAttachmentsTab> {
  bool _isImporting = false;
  String? _selectedAttachmentPath;
  String? _selectedTranscriptPath;
  bool _highlightTranscriptPreview = false;
  Timer? _highlightTranscriptTimer;
  final GlobalKey _transcriptPreviewKey = GlobalKey();

  @override
  void dispose() {
    _highlightTranscriptTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.read(meetingFolderServiceProvider);
    final attachmentsAsync = ref.watch(
      meetingAttachmentsProvider(widget.detail.meeting.id),
    );
    final transcriptsAsync = ref.watch(
      meetingTranscriptFilesProvider(widget.detail.meeting.id),
    );

    return attachmentsAsync.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: meetingPanelDecoration(),
            child: const Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Loading attachments...'),
              ],
            ),
          ),
        ],
      ),
      error: (error, stackTrace) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: meetingPanelDecoration(),
            child: Text(
              'Attachments could not load right now.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            ),
          ),
        ],
      ),
      data: (attachments) {
        return transcriptsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: meetingPanelDecoration(),
                child: Text(
                  'Transcript files could not load right now.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
              ),
            ],
          ),
          data: (transcripts) {
            MeetingAttachmentRecord? selectedTranscript;
            if (_selectedTranscriptPath != null) {
              for (final transcript in transcripts) {
                if (transcript.path == _selectedTranscriptPath) {
                  selectedTranscript = transcript;
                  break;
                }
              }
            }
            selectedTranscript ??=
                transcripts.isEmpty ? null : transcripts.first;

            if (transcripts.isNotEmpty &&
                selectedTranscript != null &&
                selectedTranscript.path != _selectedTranscriptPath) {
              final selectedPath = selectedTranscript.path;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  _selectedTranscriptPath = selectedPath;
                });
                _focusTranscriptPreview();
              });
            }

            MeetingAttachmentRecord? selectedAttachment;
            if (_selectedAttachmentPath != null) {
              for (final attachment in attachments) {
                if (attachment.path == _selectedAttachmentPath) {
                  selectedAttachment = attachment;
                  break;
                }
              }
            }
            selectedAttachment ??=
                attachments.isEmpty ? null : attachments.first;

            if (attachments.isNotEmpty &&
                selectedAttachment != null &&
                selectedAttachment.path != _selectedAttachmentPath) {
              final selectedPath = selectedAttachment.path;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  _selectedAttachmentPath = selectedPath;
                });
              });
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _MeetingFileSectionCard(
                  key: _transcriptPreviewKey,
                  title: 'Transcript preview',
                  subtitle:
                      'The latest transcript from the local recording folder is shown here first.',
                  emptyTitle: 'No transcript yet',
                  emptyMessage:
                      'Import a recording and the transcript will appear here automatically.',
                  primaryActionLabel: 'Open transcript folder',
                  primaryActionIcon: Icons.folder_open_outlined,
                  onPrimaryAction: () =>
                      service.openFolder(widget.detail.transcriptsFolderPath),
                  secondaryActionLabel: 'Open meeting folder',
                  secondaryActionIcon: Icons.folder_open_outlined,
                  onSecondaryAction: () =>
                      service.openFolder(widget.detail.meeting.folderPath),
                  fileListTitle: 'Transcript files',
                  fileListSubtitle:
                      'Choose a transcript file to preview its Markdown here.',
                  files: transcripts,
                  selectedFilePath: selectedTranscript?.path,
                  onSelectFile: (path) {
                    setState(() {
                      _selectedTranscriptPath = path;
                    });
                    _focusTranscriptPreview();
                  },
                  onOpenFile: (path) => service.openFile(path),
                  onOpenFolder: () =>
                      service.openFolder(widget.detail.transcriptsFolderPath),
                  highlighted: _highlightTranscriptPreview,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: meetingPanelDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MeetingSectionHeader(
                        title: 'Attachments',
                        subtitle:
                            'Store PDFs, Word docs, screenshots, and other reference files here.',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: _isImporting
                                ? null
                                : () => _pickAttachmentFiles(),
                            icon: _isImporting
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.upload_file_outlined),
                            label: const Text('Import documents'),
                          ),
                          TextButton.icon(
                            onPressed: () => service.openFolder(
                              widget.detail.attachmentsFolderPath,
                            ),
                            icon: const Icon(Icons.folder_open_outlined),
                            label: const Text('Open attachments folder'),
                          ),
                          TextButton.icon(
                            onPressed: () => service.openFolder(
                              widget.detail.transcriptsFolderPath,
                            ),
                            icon: const Icon(Icons.folder_open_outlined),
                            label: const Text('Open transcript folder'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _FileLinkRow(
                        label: 'Attachments folder',
                        path: widget.detail.attachmentsFolderPath,
                        onOpen: () => service.openFolder(
                          widget.detail.attachmentsFolderPath,
                        ),
                      ),
                      _FileLinkRow(
                        label: 'Audio or transcripts',
                        path: widget.detail.transcriptsFolderPath,
                        onOpen: () => service.openFolder(
                          widget.detail.transcriptsFolderPath,
                        ),
                      ),
                      _FileLinkRow(
                        label: 'Exports folder',
                        path: widget.detail.exportsFolderPath,
                        onOpen: () =>
                            service.openFolder(widget.detail.exportsFolderPath),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (attachments.isEmpty)
                  MeetingEmptyPanel(
                    title: 'No attachments yet',
                    message:
                        'Import PDFs, Word docs, screenshots, or reference files for this meeting. They will stay local in the attachments folder.',
                    icon: Icons.folder_copy_outlined,
                    action: FilledButton.tonalIcon(
                      onPressed: _isImporting ? null : _pickAttachmentFiles,
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text('Import documents'),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 920;
                      final list = _AttachmentListPanel(
                        title: 'Attachment list',
                        subtitle: 'Choose a file to preview it here.',
                        attachments: attachments,
                        selectedPath: selectedAttachment?.path,
                        onSelect: (path) {
                          setState(() {
                            _selectedAttachmentPath = path;
                          });
                        },
                        onOpen: (path) => service.openFile(path),
                      );
                      final preview = _AttachmentPreviewPanel(
                        title: 'Attachment preview',
                        subtitle:
                            'This stays local and only shows the selected file.',
                        attachment: selectedAttachment,
                        onOpenFile: selectedAttachment == null
                            ? null
                            : () =>
                                  service.openFile(selectedAttachment!.path),
                        onOpenFolder: selectedAttachment == null
                            ? null
                            : () => service.openFolder(
                                widget.detail.attachmentsFolderPath,
                              ),
                      );

                      if (!wide) {
                        return Column(
                          children: [list, const SizedBox(height: 16), preview],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: list),
                          const SizedBox(width: 16),
                          Expanded(flex: 7, child: preview),
                        ],
                      );
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickAttachmentFiles() async {
    if (_isImporting) {
      return;
    }

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: <String>[
        'pdf',
        'txt',
        'md',
        'doc',
        'docx',
        'png',
        'jpg',
        'jpeg',
        'webp',
      ],
      withData: false,
    );
    final paths =
        result?.files
            .map((file) => file.path)
            .whereType<String>()
            .where((path) => path.trim().isNotEmpty)
            .toList(growable: false) ??
        <String>[];
    if (paths.isEmpty) {
      return;
    }

    setState(() {
      _isImporting = true;
    });

    try {
      final imported = await ref
          .read(meetingFolderServiceProvider)
          .importAttachmentFiles(widget.detail.meeting.id, paths);
      ref.invalidate(meetingAttachmentsProvider(widget.detail.meeting.id));
      ref.invalidate(meetingDetailProvider(widget.detail.meeting.id));
      ref.invalidate(meetingDashboardSnapshotProvider);
      ref.invalidate(meetingWorkspaceProvider);
      ref.invalidate(meetingListRowsProvider);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            imported.isEmpty
                ? 'No documents were imported.'
                : 'Imported ${imported.length} document${imported.length == 1 ? '' : 's'}.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  void _focusTranscriptPreview() {
    if (!mounted) {
      return;
    }

    _highlightTranscriptTimer?.cancel();
    setState(() {
      _highlightTranscriptPreview = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final context = _transcriptPreviewKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          alignment: 0.08,
        );
      }
    });

    _highlightTranscriptTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _highlightTranscriptPreview = false;
      });
    });
  }
}

class _MeetingFileSectionCard extends StatelessWidget {
  const _MeetingFileSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.primaryActionLabel,
    required this.primaryActionIcon,
    required this.onPrimaryAction,
    required this.secondaryActionLabel,
    required this.secondaryActionIcon,
    required this.onSecondaryAction,
    required this.fileListTitle,
    required this.fileListSubtitle,
    required this.files,
    required this.selectedFilePath,
    required this.onSelectFile,
    required this.onOpenFile,
    required this.onOpenFolder,
    this.highlighted = false,
  });

  final String title;
  final String subtitle;
  final String emptyTitle;
  final String emptyMessage;
  final String primaryActionLabel;
  final IconData primaryActionIcon;
  final VoidCallback onPrimaryAction;
  final String secondaryActionLabel;
  final IconData secondaryActionIcon;
  final VoidCallback onSecondaryAction;
  final String fileListTitle;
  final String fileListSubtitle;
  final List<MeetingAttachmentRecord> files;
  final String? selectedFilePath;
  final ValueChanged<String> onSelectFile;
  final ValueChanged<String> onOpenFile;
  final VoidCallback onOpenFolder;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return MeetingEmptyPanel(
        title: emptyTitle,
        message: emptyMessage,
        icon: Icons.folder_outlined,
        action: FilledButton.tonalIcon(
          onPressed: onPrimaryAction,
          icon: Icon(primaryActionIcon),
          label: Text(primaryActionLabel),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 920;
        final list = _AttachmentListPanel(
          title: fileListTitle,
          subtitle: fileListSubtitle,
          attachments: files,
          selectedPath: selectedFilePath,
          onSelect: onSelectFile,
          onOpen: onOpenFile,
        );
        final preview = _AttachmentPreviewPanel(
          title: title,
          subtitle: subtitle,
          attachment: files.firstWhere(
            (item) => item.path == selectedFilePath,
            orElse: () => files.first,
          ),
          onOpenFile: () => onOpenFile(
            files.firstWhere(
              (item) => item.path == selectedFilePath,
              orElse: () => files.first,
            ).path,
          ),
          onOpenFolder: onOpenFolder,
        );

        if (!wide) {
          return Column(
            children: [list, const SizedBox(height: 16), preview],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: list),
            const SizedBox(width: 16),
            Expanded(flex: 7, child: preview),
          ],
        );
      },
    );
  }
}

class _AttachmentListPanel extends StatelessWidget {
  const _AttachmentListPanel({
    required this.title,
    required this.subtitle,
    required this.attachments,
    required this.selectedPath,
    required this.onSelect,
    required this.onOpen,
  });

  final String title;
  final String subtitle;
  final List<MeetingAttachmentRecord> attachments;
  final String? selectedPath;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: meetingPanelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MeetingSectionHeader(
            title: title,
            subtitle: subtitle,
          ),
          const SizedBox(height: 12),
          ...attachments.map((attachment) {
            final selected = attachment.path == selectedPath;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onSelect(attachment.path),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColours.darkSurfaceRaised.withValues(alpha: 0.95)
                        : AppColours.darkSurface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected
                          ? AppColours.darkPrimary.withValues(alpha: 0.5)
                          : AppColours.darkOutline.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    children: [
                      _AttachmentTypeIcon(extension: attachment.extension),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attachment.fileName,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: AppColours.darkText,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_formatBytes(attachment.sizeBytes)}  •  ${attachment.extension.isEmpty ? 'file' : attachment.extension.substring(1).toUpperCase()}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColours.darkMutedText),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _AttachmentBadge(
                                  label: attachment.canPreviewInline
                                      ? 'Previewable'
                                      : 'Open in app',
                                  accentColor: attachment.canPreviewInline
                                      ? AppColours.darkSuccess
                                      : AppColours.darkMutedText,
                                ),
                                if (_isPdfExtension(attachment.extension))
                                  const _AttachmentBadge(
                                    label: 'PDF',
                                    accentColor: AppColours.darkAmber,
                                  ),
                                if (attachment.extension.toLowerCase() ==
                                    '.docx')
                                  const _AttachmentBadge(
                                    label: 'DOCX',
                                    accentColor: AppColours.darkPrimary,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => onOpen(attachment.path),
                        child: const Text('Open'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AttachmentPreviewPanel extends StatelessWidget {
  const _AttachmentPreviewPanel({
    required this.title,
    required this.subtitle,
    required this.attachment,
    required this.onOpenFile,
    required this.onOpenFolder,
  });

  final String title;
  final String subtitle;
  final MeetingAttachmentRecord? attachment;
  final VoidCallback? onOpenFile;
  final VoidCallback? onOpenFolder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: meetingPanelDecoration(highlighted: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MeetingSectionHeader(
            title: title,
            subtitle: subtitle,
          ),
          const SizedBox(height: 12),
          if (attachment == null)
            const MeetingEmptyPanel(
              title: 'No attachment selected',
              message: 'Select a file from the list to preview it here.',
              icon: Icons.preview_outlined,
            )
          else ...[
            Text(
              attachment!.fileName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColours.darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_formatBytes(attachment!.sizeBytes)}  •  ${attachment!.modifiedAt.toLocal()}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _AttachmentBadge(
                  label: attachment!.canPreviewInline
                      ? 'Previewable'
                      : 'Open in app',
                  accentColor: attachment!.canPreviewInline
                      ? AppColours.darkSuccess
                      : AppColours.darkMutedText,
                ),
                if (_isPdfExtension(attachment!.extension))
                  const _AttachmentBadge(
                    label: 'PDF',
                    accentColor: AppColours.darkAmber,
                  ),
                if (attachment!.extension.toLowerCase() == '.docx')
                  const _AttachmentBadge(
                    label: 'DOCX',
                    accentColor: AppColours.darkPrimary,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 280),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColours.darkSurfaceRaised.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColours.darkOutline.withValues(alpha: 0.8),
                ),
              ),
              child: _buildPreviewBody(context, attachment!),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onOpenFile,
                  icon: const Icon(Icons.open_in_new_outlined),
                  label: const Text('Open file'),
                ),
                TextButton.icon(
                  onPressed: onOpenFolder,
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Open folder'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewBody(
    BuildContext context,
    MeetingAttachmentRecord attachment,
  ) {
    if (_isImageExtension(attachment.extension)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          File(attachment.path),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              _PreviewText(text: 'This image could not be loaded for preview.'),
        ),
      );
    }

    if (_isPdfExtension(attachment.extension)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 520,
          child: PdfViewer.file(
            attachment.path,
            params: const PdfViewerParams(),
          ),
        ),
      );
    }

    final preview = attachment.preview;
    if (preview != null && preview.trim().isNotEmpty) {
      return SingleChildScrollView(
        child: SelectableText(
          preview,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColours.darkText,
            height: 1.4,
          ),
        ),
      );
    }

    return _PreviewText(
      text:
          'No inline preview is available for this file type yet. Use Open file to view it in the default app.',
    );
  }
}

class _AttachmentTypeIcon extends StatelessWidget {
  const _AttachmentTypeIcon({required this.extension});

  final String extension;

  @override
  Widget build(BuildContext context) {
    final color = _isImageExtension(extension)
        ? AppColours.darkSuccess
        : extension == '.pdf'
        ? AppColours.darkAmber
        : AppColours.darkPrimary;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Icon(_attachmentIcon(extension), color: color),
    );
  }
}

class _AttachmentBadge extends StatelessWidget {
  const _AttachmentBadge({required this.label, required this.accentColor});

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

class _PreviewText extends StatelessWidget {
  const _PreviewText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

IconData _attachmentIcon(String extension) {
  switch (extension.toLowerCase()) {
    case '.pdf':
      return Icons.picture_as_pdf_outlined;
    case '.doc':
    case '.docx':
      return Icons.description_outlined;
    case '.png':
    case '.jpg':
    case '.jpeg':
    case '.webp':
      return Icons.image_outlined;
    case '.txt':
    case '.md':
      return Icons.notes_outlined;
    default:
      return Icons.insert_drive_file_outlined;
  }
}

bool _isImageExtension(String extension) {
  switch (extension.toLowerCase()) {
    case '.png':
    case '.jpg':
    case '.jpeg':
    case '.webp':
    case '.gif':
      return true;
    default:
      return false;
  }
}

bool _isPdfExtension(String extension) {
  switch (extension.toLowerCase()) {
    case '.pdf':
      return true;
    default:
      return false;
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

class _MeetingLinksTab extends ConsumerWidget {
  const _MeetingLinksTab({required this.detail});

  final MeetingDetailSnapshot detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projectsAsync = ref.watch(projectsProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: meetingPanelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MeetingSectionHeader(
                title: 'Links',
                subtitle:
                    'Useful places to connect this meeting to other Omega OS records.',
              ),
              const SizedBox(height: 12),
              _MeetingProjectTaskLinksCard(
                projectsAsync: projectsAsync,
                meeting: detail.meeting,
                title: 'Project record',
                subtitle:
                    'Use the live project record or spin up a task from this meeting when it needs follow-through.',
                matchCopy:
                    'Matched project records make it easier to move this meeting into the live project or task list.',
                noMatchCopy:
                    'No exact project match was found. Keep the meeting as archive source-of-truth text, then use the Projects Hub to resolve the live project record if needed.',
                taskTitlePrefix: 'Meeting follow-up',
                createTaskDescription: _meetingTaskDescription(detail.meeting),
                createTaskNotes: _meetingTaskNotes(detail.meeting),
                onOpenProjectsHub: () =>
                    context.go(RouteNames.projectsIntelligence),
                onOpenTasks: () => context.push(RouteNames.tasks),
              ),
              const SizedBox(height: 14),
              Text(
                'Linked visuals',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Store screenshots, diagrams, and supporting captures in 19_VISUAL_RECORDS_AND_CAPTURE, then link them from the meeting folder.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Linked project docs',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Project-specific context should stay in Omega OS under 21_PROJECTS_AND_PROGRAMMES and linked from here rather than duplicated.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MeetingProjectTaskLinksCard extends StatelessWidget {
  const _MeetingProjectTaskLinksCard({
    required this.projectsAsync,
    required this.meeting,
    required this.title,
    required this.subtitle,
    required this.matchCopy,
    required this.noMatchCopy,
    required this.taskTitlePrefix,
    required this.createTaskDescription,
    required this.createTaskNotes,
    required this.onOpenProjectsHub,
    required this.onOpenTasks,
  });

  final AsyncValue<List<Project>> projectsAsync;
  final MeetingRecord meeting;
  final String title;
  final String subtitle;
  final String matchCopy;
  final String noMatchCopy;
  final String taskTitlePrefix;
  final String createTaskDescription;
  final String createTaskNotes;
  final VoidCallback onOpenProjectsHub;
  final VoidCallback onOpenTasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return projectsAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(18),
        decoration: meetingPanelDecoration(),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Checking for a matching project...'),
          ],
        ),
      ),
      error: (error, stackTrace) => Container(
        padding: const EdgeInsets.all(18),
        decoration: meetingPanelDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MeetingSectionHeader(
              title: title,
              subtitle: subtitle,
            ),
            const SizedBox(height: 12),
            Text(
              'Project links are available once the workspace loads.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onOpenProjectsHub,
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Open Projects Hub'),
                ),
                TextButton.icon(
                  onPressed: onOpenTasks,
                  icon: const Icon(Icons.task_outlined),
                  label: const Text('Open Tasks'),
                ),
              ],
            ),
          ],
        ),
      ),
      data: (projects) {
        final linkedProject = _resolveLinkedProject(projects, meeting.project);

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: meetingPanelDecoration(highlighted: linkedProject != null),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MeetingSectionHeader(
                title: title,
                subtitle: subtitle,
              ),
              const SizedBox(height: 12),
              Text(
                meeting.project,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                linkedProject == null ? noMatchCopy : matchCopy,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
              if (linkedProject != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Matched project: ${linkedProject.name} (${linkedProject.projectId})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (linkedProject != null) ...[
                    FilledButton.tonalIcon(
                      onPressed: () => context.push(
                        RouteNames.projectDetail(linkedProject.projectId),
                      ),
                      icon: const Icon(Icons.folder_open_outlined),
                      label: const Text('Open project'),
                    ),
                    FilledButton.icon(
                      onPressed: () => context.push(
                        RouteNames.newTaskWithContext(
                          projectId: linkedProject.projectId,
                          title: '$taskTitlePrefix: ${meeting.title}',
                          description: createTaskDescription,
                          notes: createTaskNotes,
                        ),
                      ),
                      icon: const Icon(Icons.add_task_outlined),
                      label: const Text('Create task'),
                    ),
                  ] else ...[
                    FilledButton.tonalIcon(
                      onPressed: onOpenProjectsHub,
                      icon: const Icon(Icons.folder_open_outlined),
                      label: const Text('Open Projects Hub'),
                    ),
                  ],
                  TextButton.icon(
                    onPressed: onOpenTasks,
                    icon: const Icon(Icons.task_outlined),
                    label: const Text('Open Tasks'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

Project? _resolveLinkedProject(List<Project> projects, String meetingProject) {
  final normalizedMeetingProject = _normalize(meetingProject);
  if (normalizedMeetingProject.isEmpty) {
    return null;
  }

  for (final project in projects) {
    final normalizedProjectName = _normalize(project.name);
    if (normalizedProjectName == normalizedMeetingProject) {
      return project;
    }
  }

  for (final project in projects) {
    final normalizedProjectName = _normalize(project.name);
    if (normalizedProjectName.contains(normalizedMeetingProject) ||
        normalizedMeetingProject.contains(normalizedProjectName)) {
      return project;
    }
  }

  return null;
}

String _normalize(String value) {
  return value.trim().toLowerCase();
}

String _meetingTaskDescription(MeetingRecord meeting) {
  return [
    'Meeting follow-up for ${meeting.title}.',
    'Project: ${meeting.project}',
    'Person / Group: ${meeting.personOrGroup}',
    'Date: ${meeting.date}',
    if (meeting.purpose.isNotEmpty) 'Purpose: ${meeting.purpose}',
  ].join('\n');
}

String _meetingTaskNotes(MeetingRecord meeting) {
  final tags = meeting.tags.isEmpty ? 'None' : meeting.tags.join(', ');
  return [
    'Created from meeting archive.',
    'Meeting ID: ${meeting.id}',
    'Meeting folder: ${meeting.folderPath}',
    'Tags: $tags',
  ].join('\n');
}

class _MetadataGrid extends StatelessWidget {
  const _MetadataGrid({required this.detail});

  final MeetingDetailSnapshot detail;

  @override
  Widget build(BuildContext context) {
    final meeting = detail.meeting;
    final cards = <_MetadataCardData>[
      _MetadataCardData(label: 'Date', value: meeting.date),
      _MetadataCardData(label: 'Project', value: meeting.project),
      _MetadataCardData(label: 'Person / Group', value: meeting.personOrGroup),
      _MetadataCardData(label: 'Type', value: meeting.meetingType),
      _MetadataCardData(label: 'Status', value: meeting.status),
      _MetadataCardData(label: 'Purpose', value: meeting.purpose),
      _MetadataCardData(label: 'Folder', value: meeting.folderPath),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1100
            ? 3
            : constraints.maxWidth >= 760
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: crossAxisCount == 1 ? 2.2 : 1.6,
          ),
          itemBuilder: (context, index) {
            final card = cards[index];
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
                  Text(
                    card.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColours.darkSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      card.value.isEmpty ? '—' : card.value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkText,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MetadataCardData {
  const _MetadataCardData({required this.label, required this.value});

  final String label;
  final String value;
}

class _FileLinkRow extends StatelessWidget {
  const _FileLinkRow({
    required this.label,
    required this.path,
    required this.onOpen,
  });

  final String label;
  final String path;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColours.darkText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    path,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColours.darkMutedText,
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

class _FollowUpSummaryCard extends StatelessWidget {
  const _FollowUpSummaryCard({
    required this.followUp,
    required this.onEdit,
    required this.onDelete,
  });

  final MeetingFollowUpRecord followUp;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  followUp.person,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Message needed: ${followUp.messageNeeded ? 'Yes' : 'No'} • Sent: ${followUp.sent ? 'Yes' : 'No'} • Response: ${followUp.responseReceived ? 'Yes' : 'No'}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
          ),
          if (followUp.nextStep.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              followUp.nextStep,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkText),
            ),
          ],
        ],
      ),
    );
  }
}

class _MeetingDetailError extends StatelessWidget {
  const _MeetingDetailError({required this.error, required this.onRetry});

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
            const Icon(Icons.event_busy_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              'Meeting detail could not load right now.',
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

class _SchedulePreviewData {
  const _SchedulePreviewData({
    required this.localLabel,
    required this.durationLabel,
    required this.meetingLabel,
    required this.differenceLabel,
  });

  final String localLabel;
  final String durationLabel;
  final String meetingLabel;
  final String differenceLabel;
}

class _ScheduleSummaryCard extends StatelessWidget {
  const _ScheduleSummaryCard({required this.preview});

  final _SchedulePreviewData preview;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            preview.meetingLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            preview.localLabel,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
          ),
          const SizedBox(height: 4),
          Text(
            preview.durationLabel,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
          ),
          const SizedBox(height: 4),
          Text(
            preview.differenceLabel,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
          ),
        ],
      ),
    );
  }
}

class _DetailTimezoneOption {
  const _DetailTimezoneOption({
    required this.id,
    required this.label,
    required this.offsetMinutes,
  });

  final String id;
  final String label;
  final int? offsetMinutes;
}

const _detailTimezoneOptions = <_DetailTimezoneOption>[
  _DetailTimezoneOption(
    id: 'local',
    label: 'Local time (device)',
    offsetMinutes: null,
  ),
  _DetailTimezoneOption(id: 'utc', label: 'UTC+00:00', offsetMinutes: 0),
  _DetailTimezoneOption(
    id: 'london',
    label: 'UTC+00:00 London',
    offsetMinutes: 0,
  ),
  _DetailTimezoneOption(
    id: 'eastern',
    label: 'UTC-05:00 Eastern',
    offsetMinutes: -300,
  ),
  _DetailTimezoneOption(
    id: 'central',
    label: 'UTC-06:00 Central',
    offsetMinutes: -360,
  ),
  _DetailTimezoneOption(
    id: 'pacific',
    label: 'UTC-08:00 Pacific',
    offsetMinutes: -480,
  ),
  _DetailTimezoneOption(
    id: 'pakistan',
    label: 'UTC+05:00 Pakistan',
    offsetMinutes: 300,
  ),
  _DetailTimezoneOption(
    id: 'india',
    label: 'UTC+05:30 India',
    offsetMinutes: 330,
  ),
  _DetailTimezoneOption(
    id: 'singapore',
    label: 'UTC+08:00 Singapore',
    offsetMinutes: 480,
  ),
  _DetailTimezoneOption(
    id: 'tokyo',
    label: 'UTC+09:00 Tokyo',
    offsetMinutes: 540,
  ),
];

TimeOfDay? _parseClock(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(trimmed);
  if (match == null) {
    return null;
  }
  final hour = int.tryParse(match.group(1)!);
  final minute = int.tryParse(match.group(2)!);
  if (hour == null || minute == null || hour > 23 || minute > 59) {
    return null;
  }
  return TimeOfDay(hour: hour, minute: minute);
}

_SchedulePreviewData? _buildSchedulePreview({
  required String dateText,
  required String timeText,
  required String durationText,
  required String timezoneId,
  required MeetingRecord currentMeeting,
}) {
  final date = DateTime.tryParse(dateText.trim());
  final time = _parseClock(timeText);
  final duration = int.tryParse(durationText.trim()) ?? 60;
  if (date == null || time == null || duration <= 0) {
    return null;
  }

  final timezone = _detailTimezoneOptions.firstWhere(
    (item) => item.id == timezoneId,
    orElse: () => _detailTimezoneOptions.first,
  );
  final offsetMinutes =
      timezone.offsetMinutes ??
      DateTime(date.year, date.month, date.day, 12).timeZoneOffset.inMinutes;
  final utc = DateTime.utc(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  ).subtract(Duration(minutes: offsetMinutes));
  final local = utc.toLocal();
  final difference =
      offsetMinutes -
      DateTime(date.year, date.month, date.day, 12).timeZoneOffset.inMinutes;
  final endLocal = local.add(Duration(minutes: duration));

  return _SchedulePreviewData(
    localLabel:
        'Local: ${DateFormat('EEE, d MMM y, HH:mm').format(local)} to ${DateFormat('HH:mm').format(endLocal)}',
    durationLabel: 'Duration: $duration min',
    meetingLabel:
        '${DateFormat('EEE, d MMM y').format(date)} • ${DateFormat('HH:mm').format(DateTime(1970, 1, 1, time.hour, time.minute))} ${timezone.label}',
    differenceLabel: difference == 0
        ? 'No difference from local time'
        : 'Difference: ${difference.abs()} minutes ${difference > 0 ? 'ahead' : 'behind'}',
  );
}
