import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/meeting_system_controller.dart';
import '../data/meeting_folder_service.dart';
import 'meeting_system_widgets.dart';

class MeetingDetailScreen extends ConsumerStatefulWidget {
  const MeetingDetailScreen({super.key, required this.meetingId});

  final String meetingId;

  @override
  ConsumerState<MeetingDetailScreen> createState() =>
      _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends ConsumerState<MeetingDetailScreen> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(meetingDetailProvider(widget.meetingId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Meeting Detail'),
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
            onPressed: () =>
                ref.invalidate(meetingDetailProvider(widget.meetingId)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: snapshot.when(
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

          return DefaultTabController(
            length: 7,
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
                            '${meeting.project}  -  ${meeting.personOrGroup}  -  $formattedDate  -  ${meeting.status}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColours.darkMutedText),
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
}

class _MeetingOverviewTab extends ConsumerWidget {
  const _MeetingOverviewTab({required this.detail});

  final MeetingDetailSnapshot detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    'Edit the markdown that lives in 01_MEETING_NOTES.md.',
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
                          Text(
                            action.action,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColours.darkText,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${action.owner}  •  Due ${action.dueDate.isEmpty ? 'not set' : action.dueDate}  •  ${action.status}',
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
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
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
                          Text(
                            decision.decision,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColours.darkText,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${decision.status}  •  ${decision.reason}',
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
    _personController.dispose();
    _nextStepController.dispose();
    _notesController.dispose();
    _messageDraftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final followUp = widget.detail.followUp;

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
                _FollowUpSummaryCard(followUp: followUp),
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
}

class _MeetingAttachmentsTab extends ConsumerWidget {
  const _MeetingAttachmentsTab({required this.detail});

  final MeetingDetailSnapshot detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(meetingFolderServiceProvider);

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
                title: 'Attachments',
                subtitle:
                    'Drop PDFs, screenshots, audio files, or reference docs here.',
              ),
              const SizedBox(height: 12),
              _FileLinkRow(
                label: 'Attachments folder',
                path: detail.attachmentsFolderPath,
                onOpen: () => service.openFolder(detail.attachmentsFolderPath),
              ),
              _FileLinkRow(
                label: 'Audio or transcripts',
                path: detail.transcriptsFolderPath,
                onOpen: () => service.openFolder(detail.transcriptsFolderPath),
              ),
              _FileLinkRow(
                label: 'Exports folder',
                path: detail.exportsFolderPath,
                onOpen: () => service.openFolder(detail.exportsFolderPath),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MeetingLinksTab extends ConsumerWidget {
  const _MeetingLinksTab({required this.detail});

  final MeetingDetailSnapshot detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

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
              Text(
                'Project record',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                detail.meeting.project,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkText,
                ),
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
  const _FollowUpSummaryCard({required this.followUp});

  final MeetingFollowUpRecord followUp;

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
          Text(
            followUp.person,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Message needed: ${followUp.messageNeeded ? 'Yes' : 'No'}  •  Sent: ${followUp.sent ? 'Yes' : 'No'}  •  Response: ${followUp.responseReceived ? 'Yes' : 'No'}',
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
