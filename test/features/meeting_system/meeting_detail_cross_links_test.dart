import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/meeting_system/application/meeting_system_controller.dart';
import 'package:new_earth_command_dashboard/features/meeting_system/data/meeting_folder_service.dart';
import 'package:new_earth_command_dashboard/features/meeting_system/presentation/meeting_detail_screen.dart';
import 'package:new_earth_command_dashboard/features/projects/application/projects_controller.dart';

void main() {
  testWidgets('meeting detail links a project into tasks and projects', (
    tester,
  ) async {
    final service = _FakeMeetingFolderService();
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          meetingFolderServiceProvider.overrideWithValue(service),
          meetingDetailProvider.overrideWith(
            (ref, meetingId) async => _FakeMeetingFolderService._detail,
          ),
          projectsProvider.overrideWith(
            (ref) async => [_FakeMeetingFolderService._project],
          ),
        ],
        child: const MaterialApp(
          home: MeetingDetailScreen(
            meetingId: 'meeting-001',
            initialTabIndex: 6,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Matched project: Dashboard'), findsWidgets);
    expect(find.text('Open project'), findsWidgets);
    expect(find.text('Create task'), findsWidgets);
    expect(find.text('Open Tasks'), findsWidgets);
  });
}

class _FakeMeetingFolderService extends MeetingFolderService {
  _FakeMeetingFolderService() : super(workingDirectory: Directory.current);

  static final Project _project = Project(
    projectId: 'dashboard',
    name: 'Dashboard',
    status: 'active',
    priority: 'high',
    progressPercentage: 45,
    createdAt: DateTime.parse('2026-06-07T09:00:00Z'),
    updatedAt: DateTime.parse('2026-06-07T09:30:00Z'),
    isArchived: false,
  );

  static final MeetingRecord _meeting = MeetingRecord(
    id: 'meeting-001',
    date: '2026-06-07',
    time: '09:00',
    timezoneLabel: 'BST',
    timezoneOffsetMinutes: 60,
    durationMinutes: 60,
    project: 'Dashboard',
    title: 'Latest meeting review',
    personOrGroup: 'Ellis',
    meetingType: 'Meeting',
    status: 'open',
    folderPath: 'D:/meetings/meeting-001',
    agendaPath: 'D:/meetings/meeting-001/agenda.md',
    notesPath: 'D:/meetings/meeting-001/notes.md',
    actionsPath: 'D:/meetings/meeting-001/actions.md',
    decisionsPath: 'D:/meetings/meeting-001/decisions.md',
    followUpPath: 'D:/meetings/meeting-001/follow-up.md',
    createdAt: '2026-06-07T09:00:00',
    updatedAt: '2026-06-07T09:30:00',
    tags: const ['weekly', 'review'],
    purpose: 'Review bundle flow.',
  );

  static final MeetingDetailSnapshot _detail = MeetingDetailSnapshot(
    meeting: _meeting,
    agendaMarkdown: '',
    notesMarkdown: '',
    actions: const <MeetingActionRecord>[],
    decisions: const <MeetingDecisionRecord>[],
    followUp: null,
    attachmentsFolderPath: 'D:/meetings/meeting-001/attachments',
    transcriptsFolderPath: 'D:/meetings/meeting-001/transcripts',
    exportsFolderPath: 'D:/meetings/meeting-001/exports',
    summaryPath: 'D:/meetings/meeting-001/summary.md',
  );

  @override
  Future<MeetingDetailSnapshot> readMeeting(String meetingId) async => _detail;

  @override
  Future<void> openFolder(String folderPath) async {}

  @override
  Future<void> openFile(String filePath) async {}
}
