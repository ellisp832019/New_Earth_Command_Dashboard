import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/utils/folder_bootstrap_result.dart';
import 'package:new_earth_command_dashboard/features/dashboard/presentation/dashboard_screen.dart';
import 'package:new_earth_command_dashboard/features/meeting_system/application/meeting_system_controller.dart';
import 'package:new_earth_command_dashboard/features/meeting_system/data/meeting_folder_service.dart';
import 'package:new_earth_command_dashboard/features/meeting_system/presentation/meeting_settings_screen.dart';

void main() {
  testWidgets('meeting settings keeps search and filters calm', (tester) async {
    final service = _FakeMeetingFolderService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          meetingFolderServiceProvider.overrideWithValue(service),
          meetingWorkspaceProvider.overrideWith(
            (ref) async => _FakeMeetingFolderService._workspace,
          ),
          meetingOmegaHubProvider.overrideWith(
            (ref) async => _FakeMeetingFolderService._hub,
          ),
          meetingMasterIndexProvider.overrideWith(
            (ref) async => _FakeMeetingFolderService._masterIndex,
          ),
          meetingStatusSummaryProvider.overrideWith(
            (ref) async => _FakeMeetingFolderService._summary,
          ),
          meetingListRowsProvider.overrideWith(
            (ref) async => [
              _FakeMeetingFolderService._searchRow,
              _FakeMeetingFolderService._secondRow,
            ],
          ),
          meetingLatestMeetingProvider.overrideWith(
            (ref) async => _FakeMeetingFolderService._meeting,
          ),
        ],
        child: const MaterialApp(home: MeetingSettingsScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.scrollUntilVisible(
      find.text('Search meetings'),
      400.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('Search meetings'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'alpha');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('1 matching meeting'), findsOneWidget);
    expect(find.textContaining('Search: alpha'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);
  });

  testWidgets('meeting dashboard shows a latest bundle review card', (
    tester,
  ) async {
    final service = _FakeMeetingFolderService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          meetingFolderServiceProvider.overrideWithValue(service),
          meetingDashboardSnapshotProvider.overrideWith(
            (ref) async => _FakeMeetingFolderService._dashboard,
          ),
          meetingLatestMeetingProvider.overrideWith(
            (ref) async => _FakeMeetingFolderService._meeting,
          ),
          meetingStatusSummaryProvider.overrideWith(
            (ref) async => _FakeMeetingFolderService._summary,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 1200,
                  child: MeetingSystemDashboardCard(),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Latest bundle review'), findsWidgets);
    expect(find.text('Export latest bundle'), findsWidgets);
    expect(find.text('Open bundle folder'), findsWidgets);
    expect(find.text('Open summary'), findsWidgets);
    expect(find.text('Open manifest'), findsWidgets);
    expect(find.text('Latest meeting review'), findsOneWidget);
  });
}

class _FakeMeetingFolderService extends MeetingFolderService {
  _FakeMeetingFolderService() : super(workingDirectory: Directory.current);

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

  static final MeetingRecord _earlierMeeting = MeetingRecord(
    id: 'meeting-000',
    date: '2026-06-06',
    time: '15:00',
    timezoneLabel: 'BST',
    timezoneOffsetMinutes: 60,
    durationMinutes: 45,
    project: 'Assets',
    title: 'Alpha bundle meeting',
    personOrGroup: 'Hayley',
    meetingType: 'Meeting',
    status: 'planned',
    folderPath: 'D:/meetings/meeting-000',
    agendaPath: 'D:/meetings/meeting-000/agenda.md',
    notesPath: 'D:/meetings/meeting-000/notes.md',
    actionsPath: 'D:/meetings/meeting-000/actions.md',
    decisionsPath: 'D:/meetings/meeting-000/decisions.md',
    followUpPath: 'D:/meetings/meeting-000/follow-up.md',
    createdAt: '2026-06-06T15:00:00',
    updatedAt: '2026-06-06T15:30:00',
    tags: const ['alpha'],
    purpose: 'Search fixture.',
  );

  static final MeetingWorkspaceSnapshot _workspace = MeetingWorkspaceSnapshot(
    configPath: 'config/local_paths.json',
    omegaRootPath: 'D:/NEW_EARTH_OMEGA_OS_PACK',
    meetingsRootPath:
        'D:/NEW_EARTH_OMEGA_OS_PACK/21_PROJECTS_AND_PROGRAMMES/MEETINGS',
    isReady: true,
    issues: const <String>[],
    requiredFolders: const <String>[],
    missingFolders: const <String>[],
    missingFiles: const <String>[],
    meetingCount: 2,
    actionCount: 4,
    decisionCount: 2,
    followUpCount: 1,
    guidanceNote: 'Connected.',
  );

  static final MeetingOmegaHubSnapshot _hub = MeetingOmegaHubSnapshot(
    omegaRootPath: 'D:/NEW_EARTH_OMEGA_OS_PACK',
    projectsRootPath: 'D:/NEW_EARTH_OMEGA_OS_PACK/21_PROJECTS_AND_PROGRAMMES',
    coreFolders: const [
      MeetingOmegaHubFolder(
        label: 'Meetings',
        path: 'D:/NEW_EARTH_OMEGA_OS_PACK/21_PROJECTS_AND_PROGRAMMES/MEETINGS',
        description: 'Primary meeting archive.',
      ),
    ],
    projectAreas: const [
      MeetingOmegaHubFolder(
        label: 'Dashboard',
        path: 'D:/Dev/Projects/New Earth - Command Dashboard',
        description: 'Dashboard project folder.',
      ),
    ],
    issues: const <String>[],
  );

  static final MeetingMasterIndexSnapshot
  _masterIndex = MeetingMasterIndexSnapshot(
    indexPath:
        'D:/NEW_EARTH_OMEGA_OS_PACK/21_PROJECTS_AND_PROGRAMMES/MEETINGS/meeting_index.csv',
    masterLogPath:
        'D:/NEW_EARTH_OMEGA_OS_PACK/21_PROJECTS_AND_PROGRAMMES/MEETINGS/meeting_index.json',
    meetingCount: 2,
    preview: 'alpha meeting preview',
    exists: true,
  );

  static final MeetingStatusSummarySnapshot _summary =
      MeetingStatusSummarySnapshot(
        totalCount: 2,
        plannedCount: 1,
        openCount: 1,
        waitingCount: 0,
        completeCount: 0,
        archivedCount: 0,
      );

  static final MeetingDashboardSnapshot _dashboard = MeetingDashboardSnapshot(
    workspace: _workspace,
    generatedAt: DateTime.parse('2026-06-07T09:30:00Z'),
    recentMeetings: [_meeting, _earlierMeeting],
    upcomingMeetings: [_meeting],
    notifications: const <MeetingNotificationRecord>[],
    openActions: const <MeetingActionRecord>[],
    recentDecisions: const <MeetingDecisionRecord>[],
    waitingFollowUps: const <MeetingFollowUpRecord>[],
    meetingsThisWeekCount: 2,
    openActionsCount: 4,
    waitingFollowUpsCount: 1,
    decisionsThisMonthCount: 2,
  );

  static final MeetingListRow _searchRow = MeetingListRow(
    meeting: _meeting,
    actionCount: 3,
    decisionCount: 1,
    followUp: null,
  );

  static final MeetingListRow _secondRow = MeetingListRow(
    meeting: _earlierMeeting,
    actionCount: 1,
    decisionCount: 1,
    followUp: null,
  );

  static final MeetingBundleReviewSnapshot _bundleReview =
      MeetingBundleReviewSnapshot(
        bundlePath: 'D:/meetings/meeting-001/bundles/meeting-001_bundle',
        summaryPath:
            'D:/meetings/meeting-001/bundles/meeting-001_bundle/summary.md',
        manifestPath:
            'D:/meetings/meeting-001/bundles/meeting-001_bundle/manifest.json',
        fileCount: 4,
        exists: true,
      );

  @override
  Future<MeetingWorkspaceSnapshot> loadWorkspace() async => _workspace;

  @override
  Future<MeetingOmegaHubSnapshot> loadOmegaHub() async => _hub;

  @override
  Future<MeetingMasterIndexSnapshot> loadMasterIndexPreview() async =>
      _masterIndex;

  @override
  Future<List<MeetingListRow>> listMeetingRows() async => [
    _searchRow,
    _secondRow,
  ];

  @override
  Future<MeetingDashboardSnapshot> loadDashboardSnapshot() async => _dashboard;

  @override
  Future<MeetingStatusSummarySnapshot> loadStatusSummary() async => _summary;

  @override
  Future<MeetingRecord?> getLatestMeeting() async => _meeting;

  @override
  Future<MeetingBundleReviewSnapshot?> loadLatestBundleReview(
    String meetingId,
  ) async {
    if (meetingId == _meeting.id) {
      return _bundleReview;
    }

    return null;
  }

  @override
  Future<MeetingBundleResult> exportMeetingBundle(String meetingId) async {
    return const MeetingBundleResult(
      bundlePath: 'D:/meetings/meeting-001/bundles/meeting-001_bundle',
      summaryPath:
          'D:/meetings/meeting-001/bundles/meeting-001_bundle/summary.md',
      filePaths: <String>[
        'D:/meetings/meeting-001/bundles/meeting-001_bundle/summary.md',
      ],
    );
  }

  @override
  Future<void> openFolder(String folderPath) async {}

  @override
  Future<void> openFile(String filePath) async {}

  @override
  Future<FolderBootstrapCreationResult> createMissingRequiredStructure() async {
    return const FolderBootstrapCreationResult(
      createdFolders: <String>[],
      createdFiles: <String>[],
    );
  }
}
