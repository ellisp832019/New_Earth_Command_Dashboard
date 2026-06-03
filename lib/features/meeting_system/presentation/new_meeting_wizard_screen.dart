import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/meeting_system_controller.dart';
import '../data/meeting_folder_service.dart';
import 'meeting_system_widgets.dart';

class NewMeetingWizardScreen extends ConsumerStatefulWidget {
  const NewMeetingWizardScreen({super.key});

  @override
  ConsumerState<NewMeetingWizardScreen> createState() =>
      _NewMeetingWizardScreenState();
}

class _NewMeetingWizardScreenState
    extends ConsumerState<NewMeetingWizardScreen> {
  final TextEditingController _dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _personController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _datePreviewController = TextEditingController();
  String _meetingType = 'Meeting';
  bool _isSaving = false;

  static const _meetingTypes = <String>[
    'Meeting',
    'Google Meet',
    'Phone call',
    'In person',
    'Site visit',
    'Workshop',
    'Review',
  ];

  @override
  void initState() {
    super.initState();
    _datePreviewController.text = _buildPreviewFolderName();
    _dateController.addListener(_syncPreview);
    _projectController.addListener(_syncPreview);
    _personController.addListener(_syncPreview);
  }

  @override
  void dispose() {
    _dateController.removeListener(_syncPreview);
    _projectController.removeListener(_syncPreview);
    _personController.removeListener(_syncPreview);
    _dateController.dispose();
    _projectController.dispose();
    _titleController.dispose();
    _personController.dispose();
    _purposeController.dispose();
    _tagsController.dispose();
    _datePreviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('New Meeting Wizard'),
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: meetingPanelDecoration(highlighted: true),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MeetingSectionHeader(
                    title: 'Create the meeting folder first',
                    subtitle:
                        'The wizard creates the Omega OS meeting folder, starter markdown files, and the meeting index entry.',
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 960;
                      final fields = [
                        TextFormField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            labelText: 'Date (yyyy-MM-dd)',
                            prefixIcon: Icon(Icons.date_range_outlined),
                          ),
                        ),
                        TextFormField(
                          controller: _projectController,
                          decoration: const InputDecoration(
                            labelText: 'Project',
                            prefixIcon: Icon(Icons.folder_outlined),
                          ),
                        ),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Meeting title',
                            prefixIcon: Icon(Icons.title_outlined),
                          ),
                        ),
                        TextFormField(
                          controller: _personController,
                          decoration: const InputDecoration(
                            labelText: 'Person / Group',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          initialValue: _meetingType,
                          decoration: const InputDecoration(
                            labelText: 'Meeting type',
                          ),
                          items: _meetingTypes
                              .map(
                                (type) => DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            setState(() {
                              _meetingType = value ?? 'Meeting';
                            });
                          },
                        ),
                        TextFormField(
                          controller: _tagsController,
                          decoration: const InputDecoration(
                            labelText: 'Tags (comma separated)',
                            prefixIcon: Icon(Icons.sell_outlined),
                          ),
                        ),
                        TextFormField(
                          controller: _purposeController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Purpose',
                            alignLabelWithHint: true,
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(bottom: 64),
                              child: Icon(Icons.edit_note_outlined),
                            ),
                          ),
                        ),
                      ];

                      if (wide) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: fields[0]),
                                const SizedBox(width: 12),
                                Expanded(child: fields[1]),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: fields[2]),
                                const SizedBox(width: 12),
                                Expanded(child: fields[3]),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: fields[4]),
                                const SizedBox(width: 12),
                                Expanded(child: fields[5]),
                              ],
                            ),
                            const SizedBox(height: 12),
                            fields[6],
                          ],
                        );
                      }

                      return Column(
                        children: [
                          ...fields.map(
                            (field) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: field,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
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
                          'Folder preview',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AppColours.darkSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _datePreviewController.text,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColours.darkText),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: _isSaving ? null : _createMeeting,
                        icon: _isSaving
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: const Text('Create meeting'),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push(RouteNames.meetingAll),
                        icon: const Icon(Icons.table_chart_outlined),
                        label: const Text('All Meetings'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncPreview() {
    _datePreviewController.text = _buildPreviewFolderName();
    setState(() {});
  }

  String _buildPreviewFolderName() {
    final date = _dateController.text.trim();
    final project = _projectController.text.trim().replaceAll(
      RegExp(r'\s+'),
      '_',
    );
    final person = _personController.text.trim().replaceAll(
      RegExp(r'\s+'),
      '_',
    );
    if (date.isEmpty || project.isEmpty || person.isEmpty) {
      return 'YYYY-MM-DD_Project_PersonOrTopic';
    }
    return '${date}_${project.isEmpty ? 'Project' : project}_${person.isEmpty ? 'Person' : person}';
  }

  Future<void> _createMeeting() async {
    final date = _dateController.text.trim();
    final project = _projectController.text.trim();
    final title = _titleController.text.trim();
    final person = _personController.text.trim();
    final purpose = _purposeController.text.trim();
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList(growable: false);

    if (date.isEmpty ||
        project.isEmpty ||
        title.isEmpty ||
        person.isEmpty ||
        purpose.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill the date, project, title, person, and purpose.',
          ),
        ),
      );
      return;
    }

    if (DateTime.tryParse(date) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please use a valid yyyy-MM-dd date.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await ref
          .read(meetingFolderServiceProvider)
          .createMeeting(
            MeetingCreateRequest(
              date: date,
              project: project,
              title: title,
              personOrGroup: person,
              meetingType: _meetingType,
              purpose: purpose,
              tags: tags,
            ),
          );
      ref.invalidate(meetingDashboardSnapshotProvider);
      ref.invalidate(meetingWorkspaceProvider);
      ref.invalidate(meetingListRowsProvider);
      if (!mounted) {
        return;
      }
      context.go(RouteNames.meetingDetail(result.meetingId));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create meeting: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
