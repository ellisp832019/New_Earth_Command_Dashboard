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
  final TextEditingController _timeController = TextEditingController(
    text: _initialTimeText(),
  );
  final TextEditingController _durationController = TextEditingController(
    text: '60',
  );
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _personController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _datePreviewController = TextEditingController();
  String _timezoneOptionId = 'local';
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
    _timeController.addListener(_syncPreview);
    _durationController.addListener(_syncPreview);
    _projectController.addListener(_syncPreview);
    _personController.addListener(_syncPreview);
  }

  @override
  void dispose() {
    _dateController.removeListener(_syncPreview);
    _timeController.removeListener(_syncPreview);
    _durationController.removeListener(_syncPreview);
    _projectController.removeListener(_syncPreview);
    _personController.removeListener(_syncPreview);
    _dateController.dispose();
    _timeController.dispose();
    _durationController.dispose();
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
    final meetingsSnapshot = ref.watch(meetingMeetingsProvider);

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
                          controller: _timeController,
                          readOnly: true,
                          onTap: () => _pickTime(context),
                          decoration: InputDecoration(
                            labelText: 'Time (24h)',
                            prefixIcon: const Icon(Icons.schedule_outlined),
                            suffixIcon: IconButton(
                              tooltip: 'Pick time',
                              onPressed: () => _pickTime(context),
                              icon: const Icon(Icons.access_time_outlined),
                            ),
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          initialValue: _timezoneOptionId,
                          decoration: const InputDecoration(
                            labelText: 'Meeting timezone',
                            prefixIcon: Icon(Icons.public_outlined),
                          ),
                          items: _timezoneOptions
                              .map(
                                (option) => DropdownMenuItem<String>(
                                  value: option.id,
                                  child: Text(option.label),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            setState(() {
                              _timezoneOptionId = value ?? 'local';
                              _syncPreview();
                            });
                          },
                        ),
                        TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Duration (minutes)',
                            prefixIcon: Icon(Icons.timelapse_outlined),
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
                            Row(
                              children: [
                                Expanded(child: fields[6]),
                                const SizedBox(width: 12),
                                Expanded(child: fields[7]),
                              ],
                            ),
                            const SizedBox(height: 12),
                            fields[8],
                            const SizedBox(height: 12),
                            fields[9],
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
                  meetingsSnapshot.when(
                    loading: () => const SizedBox.shrink(),
                    error: (error, stackTrace) => _SchedulePreviewPanel(
                      data: null,
                      loadingError: error.toString(),
                    ),
                    data: (meetings) => _SchedulePreviewPanel(
                      data: _buildSchedulePreviewData(meetings),
                    ),
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
    final time = _timeController.text.trim().replaceAll(':', '');
    final project = _projectController.text.trim().replaceAll(
      RegExp(r'\s+'),
      '_',
    );
    final person = _personController.text.trim().replaceAll(
      RegExp(r'\s+'),
      '_',
    );
    final timezone = _selectedTimezonePreviewLabel().replaceAll(
      RegExp(r'[^A-Za-z0-9]+'),
      '_',
    );
    if (date.isEmpty || project.isEmpty || person.isEmpty) {
      return 'YYYY-MM-DD_Project_PersonOrTopic';
    }
    if (time.isEmpty) {
      return '${date}_${project.isEmpty ? 'Project' : project}_${person.isEmpty ? 'Person' : person}';
    }
    return '${date}_${project.isEmpty ? 'Project' : project}_${person.isEmpty ? 'Person' : person}_${time}_$timezone';
  }

  Future<void> _createMeeting() async {
    final date = _dateController.text.trim();
    final time = _timeController.text.trim();
    final durationText = _durationController.text.trim();
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

    if (_parseClock(time) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please use a valid HH:mm time.')),
      );
      return;
    }

    final durationMinutes = int.tryParse(durationText);
    if (durationMinutes == null || durationMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a meeting duration of at least 1 minute.'),
        ),
      );
      return;
    }

    final selectedDate = DateTime.parse(date);
    final timezoneOffsetMinutes = _selectedTimezoneOffsetMinutes(selectedDate);

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await ref
          .read(meetingFolderServiceProvider)
          .createMeeting(
            MeetingCreateRequest(
              date: date,
              time: time,
              timezoneLabel: _selectedTimezonePreviewLabel(),
              timezoneOffsetMinutes: timezoneOffsetMinutes,
              durationMinutes: durationMinutes,
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

  Future<void> _pickTime(BuildContext context) async {
    final initialTime = _parseClock(_timeController.text) ??
        TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked == null) {
      return;
    }

    _timeController.text = DateFormat('HH:mm').format(
      DateTime(1970, 1, 1, picked.hour, picked.minute),
    );
    _syncPreview();
  }

  String _selectedTimezonePreviewLabel() {
    final option = _timezoneOptions.firstWhere(
      (item) => item.id == _timezoneOptionId,
      orElse: () => _timezoneOptions.first,
    );
    return option.label;
  }

  int _selectedTimezoneOffsetMinutes(DateTime selectedDate) {
    final option = _timezoneOptions.firstWhere(
      (item) => item.id == _timezoneOptionId,
      orElse: () => _timezoneOptions.first,
    );
    if (option.offsetMinutes != null) {
      return option.offsetMinutes!;
    }
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      12,
    ).timeZoneOffset.inMinutes;
  }

  _MeetingSchedulePreviewData? _buildSchedulePreviewData(
    List<MeetingRecord> meetings,
  ) {
    final date = DateTime.tryParse(_dateController.text.trim());
    final time = _parseClock(_timeController.text.trim());
    final durationMinutes = int.tryParse(_durationController.text.trim()) ?? 60;
    if (date == null || time == null || durationMinutes <= 0) {
      return null;
    }

    final timezoneOffsetMinutes = _selectedTimezoneOffsetMinutes(date);
    final scheduleUtc = DateTime.utc(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).subtract(Duration(minutes: timezoneOffsetMinutes));
    final localDateTime = scheduleUtc.toLocal();
    final localOffsetMinutes = DateTime(
      date.year,
      date.month,
      date.day,
      12,
    ).timeZoneOffset.inMinutes;
    final differenceMinutes = timezoneOffsetMinutes - localOffsetMinutes;
    final meetingZoneLabel = _selectedTimezonePreviewLabel();
    final localZoneLabel =
        'Local (${formatUtcOffsetLabel(localOffsetMinutes)})';
    final endLocal = localDateTime.add(Duration(minutes: durationMinutes));

    _MeetingRecordConflict? conflict;
    final scheduledEndUtc = scheduleUtc.add(Duration(minutes: durationMinutes));
    for (final meeting in meetings) {
      final existingStart = meeting.scheduledStartUtc;
      final existingEnd = meeting.scheduledEndUtc;
      if (existingStart == null || existingEnd == null) {
        continue;
      }
      if (scheduleUtc.isBefore(existingEnd) &&
          existingStart.isBefore(scheduledEndUtc)) {
        conflict = _MeetingRecordConflict(
          title: meeting.title,
          scheduleLabel: meeting.scheduleDisplayLabel,
        );
        break;
      }
    }

      return _MeetingSchedulePreviewData(
      meetingZoneLabel: meetingZoneLabel,
      localZoneLabel: localZoneLabel,
      meetingDateLabel: DateFormat('EEE, d MMM y').format(date),
      meetingTimeLabel: DateFormat('HH:mm').format(
        DateTime(1970, 1, 1, time.hour, time.minute),
      ),
      localTimeLabel: DateFormat('EEE, d MMM y, HH:mm').format(localDateTime),
      localEndLabel: DateFormat('HH:mm').format(endLocal),
      differenceLabel: _formatDifferenceLabel(differenceMinutes),
      conflict: conflict,
      durationMinutes: durationMinutes,
    );
  }

  String _formatDifferenceLabel(int minutes) {
    if (minutes == 0) {
      return 'No time difference from your local zone';
    }
    final amount = _formatOffsetMinutes(minutes.abs());
    if (minutes > 0) {
      return 'Meeting timezone is $amount ahead of your local zone';
    }
    return 'Meeting timezone is $amount behind your local zone';
  }

  String _formatOffsetMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (remainder == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainder.toString().padLeft(2, '0')}m';
  }
}

class _MeetingTimezoneOption {
  const _MeetingTimezoneOption({
    required this.id,
    required this.label,
    required this.offsetMinutes,
  });

  final String id;
  final String label;
  final int? offsetMinutes;
}

class _MeetingSchedulePreviewData {
  const _MeetingSchedulePreviewData({
    required this.meetingZoneLabel,
    required this.localZoneLabel,
    required this.meetingDateLabel,
    required this.meetingTimeLabel,
    required this.localTimeLabel,
    required this.localEndLabel,
    required this.differenceLabel,
    required this.conflict,
    required this.durationMinutes,
  });

  final String meetingZoneLabel;
  final String localZoneLabel;
  final String meetingDateLabel;
  final String meetingTimeLabel;
  final String localTimeLabel;
  final String localEndLabel;
  final String differenceLabel;
  final _MeetingRecordConflict? conflict;
  final int durationMinutes;
}

class _MeetingRecordConflict {
  const _MeetingRecordConflict({
    required this.title,
    required this.scheduleLabel,
  });

  final String title;
  final String scheduleLabel;
}

class _SchedulePreviewPanel extends StatelessWidget {
  const _SchedulePreviewPanel({
    required this.data,
    this.loadingError,
  });

  final _MeetingSchedulePreviewData? data;
  final String? loadingError;

  @override
  Widget build(BuildContext context) {
    if (loadingError != null) {
      return _SchedulePreviewShell(
        title: 'Schedule preview',
        subtitle: loadingError!,
        icon: Icons.event_available_outlined,
        child: const Text(
          'Unable to read current meetings for overlap checking.',
        ),
      );
    }

    if (data == null) {
      return _SchedulePreviewShell(
        title: 'Schedule preview',
        subtitle: 'Add a time and timezone to see the instant local conversion.',
        icon: Icons.event_available_outlined,
        child: const Text(
          'Pick a date, time, and timezone to see the converted local time.',
        ),
      );
    }

    final preview = data!;
    final conflict = preview.conflict;

    return _SchedulePreviewShell(
      title: 'Schedule preview',
      subtitle:
          'This acts like a simple calendar block and helps prevent double booking.',
      icon: Icons.event_available_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(preview.meetingZoneLabel)),
              Chip(label: Text(preview.localZoneLabel)),
              Chip(label: Text('${preview.durationMinutes} min')),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${preview.meetingDateLabel} at ${preview.meetingTimeLabel}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Local time: ${preview.localTimeLabel} to ${preview.localEndLabel}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkText,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            preview.differenceLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
          ),
          if (conflict != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColours.darkAmber.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColours.darkAmber.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                'Overlap warning: this will clash with "${conflict.title}" (${conflict.scheduleLabel}).',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkAmber,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SchedulePreviewShell extends StatelessWidget {
  const _SchedulePreviewShell({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColours.darkSecondary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColours.darkSecondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

const _timezoneOptions = <_MeetingTimezoneOption>[
  _MeetingTimezoneOption(
    id: 'local',
    label: 'Local time (device)',
    offsetMinutes: null,
  ),
  _MeetingTimezoneOption(
    id: 'utc',
    label: 'UTC+00:00',
    offsetMinutes: 0,
  ),
  _MeetingTimezoneOption(
    id: 'london',
    label: 'UTC+00:00 London',
    offsetMinutes: 0,
  ),
  _MeetingTimezoneOption(
    id: 'cairo',
    label: 'UTC+02:00 Cairo',
    offsetMinutes: 120,
  ),
  _MeetingTimezoneOption(
    id: 'johannesburg',
    label: 'UTC+02:00 Johannesburg',
    offsetMinutes: 120,
  ),
  _MeetingTimezoneOption(
    id: 'berlin',
    label: 'UTC+01:00 Berlin',
    offsetMinutes: 60,
  ),
  _MeetingTimezoneOption(
    id: 'paris',
    label: 'UTC+01:00 Paris',
    offsetMinutes: 60,
  ),
  _MeetingTimezoneOption(
    id: 'eastern',
    label: 'UTC-05:00 Eastern',
    offsetMinutes: -300,
  ),
  _MeetingTimezoneOption(
    id: 'pacific',
    label: 'UTC-08:00 Pacific',
    offsetMinutes: -480,
  ),
  _MeetingTimezoneOption(
    id: 'mountain',
    label: 'UTC-07:00 Mountain',
    offsetMinutes: -420,
  ),
  _MeetingTimezoneOption(
    id: 'central',
    label: 'UTC-06:00 Central',
    offsetMinutes: -360,
  ),
  _MeetingTimezoneOption(
    id: 'pakistan',
    label: 'UTC+05:00 Pakistan',
    offsetMinutes: 300,
  ),
  _MeetingTimezoneOption(
    id: 'india',
    label: 'UTC+05:30 India',
    offsetMinutes: 330,
  ),
  _MeetingTimezoneOption(
    id: 'singapore',
    label: 'UTC+08:00 Singapore',
    offsetMinutes: 480,
  ),
  _MeetingTimezoneOption(
    id: 'hongkong',
    label: 'UTC+08:00 Hong Kong',
    offsetMinutes: 480,
  ),
  _MeetingTimezoneOption(
    id: 'tokyo',
    label: 'UTC+09:00 Tokyo',
    offsetMinutes: 540,
  ),
  _MeetingTimezoneOption(
    id: 'seoul',
    label: 'UTC+09:00 Seoul',
    offsetMinutes: 540,
  ),
  _MeetingTimezoneOption(
    id: 'sydney',
    label: 'UTC+10:00 Sydney',
    offsetMinutes: 600,
  ),
  _MeetingTimezoneOption(
    id: 'auckland',
    label: 'UTC+12:00 Auckland',
    offsetMinutes: 720,
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

String _initialTimeText() {
  final now = DateTime.now().add(const Duration(hours: 1));
  final roundedMinute = now.minute < 30 ? 30 : 0;
  final roundedHour = now.minute < 30 ? now.hour : now.hour + 1;
  final normalized = DateTime(now.year, now.month, now.day, roundedHour, roundedMinute);
  return DateFormat('HH:mm').format(normalized);
}
