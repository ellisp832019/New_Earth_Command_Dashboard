import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:new_earth_command_dashboard/features/meeting_system/data/meeting_folder_service.dart';

class _FakeMeetingRecordingTranscriber
    implements MeetingRecordingTranscriber {
  _FakeMeetingRecordingTranscriber(this.transcript);

  final String transcript;
  String? lastSourcePath;

  @override
  Future<MeetingRecordingTranscriptionJob?> startTranscribeFile(
    String sourcePath,
  ) async {
    lastSourcePath = sourcePath;
    return MeetingRecordingTranscriptionJob(
      result: Future<String?>.value(transcript),
      cancel: () {},
    );
  }
}

void main() {
  test(
    'createMeeting can deduplicate an existing meeting index entry',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'meeting_folder_service_test_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final repoRoot = Directory(p.join(tempRoot.path, 'dashboard_repo'));
      await repoRoot.create(recursive: true);

      final omegaRoot = Directory(p.join(tempRoot.path, 'omega_os'));
      await omegaRoot.create(recursive: true);

      final configDir = Directory(p.join(repoRoot.path, 'config'));
      await configDir.create(recursive: true);
      await File(
        p.join(configDir.path, 'local_paths.json'),
      ).writeAsString(jsonEncode({'omega_os_root': omegaRoot.path}));

      final service = MeetingFolderService(workingDirectory: repoRoot);

      final result = await service.createMeeting(
        const MeetingCreateRequest(
          date: '2026-06-04',
          time: '09:00',
          timezoneLabel: 'UTC+00:00',
          timezoneOffsetMinutes: 0,
          durationMinutes: 60,
          project: 'MicroGrow',
          title: 'PCB Prototype Strategy Call',
          personOrGroup: 'Anas Ahmed - Hackerspace Karachi',
          meetingType: 'Google Meet',
          purpose: 'Leave the call with a clear next step.',
          tags: ['ESP32', 'prototype'],
        ),
      );

      expect(await File(result.indexPath).exists(), isTrue);

      final meetings = await service.listMeetings();
      expect(meetings, hasLength(1));
      expect(meetings.single.title, 'PCB Prototype Strategy Call');
    },
  );

  test('createMeeting blocks overlapping meeting times', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'meeting_folder_service_overlap_test_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final repoRoot = Directory(p.join(tempRoot.path, 'dashboard_repo'));
    await repoRoot.create(recursive: true);

    final omegaRoot = Directory(p.join(tempRoot.path, 'omega_os_overlap'));
    await omegaRoot.create(recursive: true);

    final configDir = Directory(p.join(repoRoot.path, 'config'));
    await configDir.create(recursive: true);
    await File(
      p.join(configDir.path, 'local_paths.json'),
    ).writeAsString(jsonEncode({'omega_os_root': omegaRoot.path}));

    final service = MeetingFolderService(workingDirectory: repoRoot);
    await service.createMeeting(
      const MeetingCreateRequest(
        date: '2026-06-04',
        time: '09:00',
        timezoneLabel: 'UTC+00:00',
        timezoneOffsetMinutes: 0,
        durationMinutes: 60,
        project: 'MicroGrow',
        title: 'Morning Planning',
        personOrGroup: 'Anas Ahmed - Hackerspace Karachi',
        meetingType: 'Meeting',
        purpose: 'Plan the day.',
        tags: ['calendar'],
      ),
    );

    expect(
      () => service.createMeeting(
        const MeetingCreateRequest(
          date: '2026-06-04',
          time: '09:30',
          timezoneLabel: 'UTC+00:00',
          timezoneOffsetMinutes: 0,
          durationMinutes: 60,
          project: 'MicroGrow',
          title: 'Overlapping Call',
          personOrGroup: 'Anas Ahmed - Hackerspace Karachi',
          meetingType: 'Meeting',
          purpose: 'This should clash.',
          tags: ['calendar'],
        ),
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('overlaps with'),
        ),
      ),
    );
  });

  test(
    'updateMeetingSchedule renames the folder and updates the time',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'meeting_folder_service_update_schedule_test_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final repoRoot = Directory(p.join(tempRoot.path, 'dashboard_repo'));
      await repoRoot.create(recursive: true);

      final omegaRoot = Directory(p.join(tempRoot.path, 'omega_os_update'));
      await omegaRoot.create(recursive: true);

      final configDir = Directory(p.join(repoRoot.path, 'config'));
      await configDir.create(recursive: true);
      await File(
        p.join(configDir.path, 'local_paths.json'),
      ).writeAsString(jsonEncode({'omega_os_root': omegaRoot.path}));

      final service = MeetingFolderService(workingDirectory: repoRoot);
      final created = await service.createMeeting(
        const MeetingCreateRequest(
          date: '2026-06-04',
          time: '09:00',
          timezoneLabel: 'UTC+00:00',
          timezoneOffsetMinutes: 0,
          durationMinutes: 60,
          project: 'MicroGrow',
          title: 'Reschedule Me',
          personOrGroup: 'Anas Ahmed - Hackerspace Karachi',
          meetingType: 'Meeting',
          purpose: 'Reschedule this meeting.',
          tags: ['update'],
        ),
      );

      final updated = await service.updateMeetingSchedule(
        created.meetingId,
        const MeetingScheduleInput(
          date: '2026-06-04',
          time: '10:30',
          timezoneLabel: 'UTC+00:00',
          timezoneOffsetMinutes: 0,
          durationMinutes: 90,
        ),
      );

      expect(updated.time, '10:30');
      expect(updated.durationMinutes, 90);
      expect(updated.folderPath, isNot(equals(created.folderPath)));
      expect(await Directory(created.folderPath).exists(), isFalse);
      expect(await Directory(updated.folderPath).exists(), isTrue);

      final detail = await service.readMeeting(created.meetingId);
      expect(detail.meeting.time, '10:30');
      expect(detail.meeting.durationMinutes, 90);
    },
  );

  test(
    'addAction rejects duplicates, dedupes reads, and updateAction edits the record',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'meeting_folder_service_actions_test_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final repoRoot = Directory(p.join(tempRoot.path, 'dashboard_repo'));
      await repoRoot.create(recursive: true);

      final omegaRoot = Directory(p.join(tempRoot.path, 'omega_os_actions'));
      await omegaRoot.create(recursive: true);

      final configDir = Directory(p.join(repoRoot.path, 'config'));
      await configDir.create(recursive: true);
      await File(
        p.join(configDir.path, 'local_paths.json'),
      ).writeAsString(jsonEncode({'omega_os_root': omegaRoot.path}));

      final service = MeetingFolderService(workingDirectory: repoRoot);
      final created = await service.createMeeting(
        const MeetingCreateRequest(
          date: '2026-06-04',
          time: '09:00',
          timezoneLabel: 'UTC+00:00',
          timezoneOffsetMinutes: 0,
          durationMinutes: 60,
          project: 'MicroGrow',
          title: 'Action Dedup Test',
          personOrGroup: 'Anas Ahmed - Hackerspace Karachi',
          meetingType: 'Meeting',
          purpose: 'Test actions.',
          tags: ['actions'],
        ),
      );

      final original = await service.addAction(
        created.meetingId,
        const MeetingActionInput(
          action: 'Send follow-up summary',
          owner: 'Peter',
          dueDate: '2026-06-05',
          status: 'open',
          notes: 'Send a summary after the call.',
        ),
      );

      expect(
        () => service.addAction(
          created.meetingId,
          const MeetingActionInput(
            action: 'Send follow-up summary',
            owner: 'Peter',
            dueDate: '2026-06-05',
            status: 'open',
            notes: 'Send a summary after the call.',
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('already exists'),
          ),
        ),
      );

      final actionIndexFile = File(
        p.join(
          omegaRoot.path,
          '21_PROJECTS_AND_PROGRAMMES',
          '02_ACTIONS_AND_FOLLOW_UPS',
          'action_index.json',
        ),
      );
      final decoded = jsonDecode(await actionIndexFile.readAsString()) as List;
      final duplicate = Map<String, dynamic>.from(decoded.first as Map);
      duplicate['id'] = 'act_duplicate_copy';
      duplicate['updated_at'] = '2026-06-04T09:15:00';
      decoded.add(duplicate);
      await actionIndexFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(decoded),
      );

      final dedupedActions = await service.listActions();
      expect(dedupedActions, hasLength(1));
      expect(dedupedActions.single.action, 'Send follow-up summary');

      final updated = await service.updateAction(
        created.meetingId,
        original.id,
        const MeetingActionInput(
          action: 'Send follow-up summary',
          owner: 'Peter',
          dueDate: '2026-06-06',
          status: 'doing',
          notes: 'Updated after review.',
        ),
      );

      expect(updated.id, original.id);
      expect(updated.dueDate, '2026-06-06');
      expect(updated.status, 'doing');

      await service.deleteAction(created.meetingId, original.id);

      final refreshed = await service.listActions();
      expect(refreshed, isEmpty);
    },
  );

  test(
    'updateDecision edits the record and deleteFollowUp clears the meeting follow-up',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'meeting_folder_service_decision_followup_test_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final repoRoot = Directory(p.join(tempRoot.path, 'dashboard_repo'));
      await repoRoot.create(recursive: true);

      final omegaRoot = Directory(
        p.join(tempRoot.path, 'omega_os_decision_followup'),
      );
      await omegaRoot.create(recursive: true);

      final configDir = Directory(p.join(repoRoot.path, 'config'));
      await configDir.create(recursive: true);
      await File(
        p.join(configDir.path, 'local_paths.json'),
      ).writeAsString(jsonEncode({'omega_os_root': omegaRoot.path}));

      final service = MeetingFolderService(workingDirectory: repoRoot);
      final created = await service.createMeeting(
        const MeetingCreateRequest(
          date: '2026-06-07',
          time: '13:00',
          timezoneLabel: 'UTC+00:00',
          timezoneOffsetMinutes: 0,
          durationMinutes: 60,
          project: 'MicroGrow',
          title: 'Decision Follow-up Test',
          personOrGroup: 'Anas Ahmed - Hackerspace Karachi',
          meetingType: 'Meeting',
          purpose: 'Exercise decision and follow-up editing.',
          tags: ['decision', 'followup'],
        ),
      );

      final decision = await service.addDecision(
        created.meetingId,
        const MeetingDecisionInput(
          decision: 'Use the revised PCB outline',
          reason: 'Keeps the prototype on scope.',
          status: 'proposed',
        ),
      );

      final updatedDecision = await service.updateDecision(
        created.meetingId,
        decision.id,
        const MeetingDecisionInput(
          decision: 'Use the revised PCB outline',
          reason: 'Keeps the prototype on scope and budget.',
          status: 'agreed',
        ),
      );

      expect(updatedDecision.id, decision.id);
      expect(
        updatedDecision.reason,
        'Keeps the prototype on scope and budget.',
      );
      expect(updatedDecision.status, 'agreed');

      await service.deleteDecision(created.meetingId, decision.id);
      expect(await service.listDecisions(), isEmpty);

      await service.updateFollowUp(
        created.meetingId,
        const MeetingFollowUpInput(
          person: 'Anas Ahmed - Hackerspace Karachi',
          messageNeeded: true,
          sent: false,
          responseReceived: false,
          nextStep: 'Send the revised outline.',
          notes: 'Keep it concise.',
          messageDraft: 'Draft message for follow-up.',
        ),
      );

      expect(await service.listFollowUps(), hasLength(1));

      await service.deleteFollowUp(created.meetingId);
      expect(await service.listFollowUps(), isEmpty);
      final detail = await service.readMeeting(created.meetingId);
      expect(detail.followUp, isNull);
    },
  );

  test('createMeeting normalizes mixed-separator Omega OS paths', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'meeting_folder_service_norm_test_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final repoRoot = Directory(p.join(tempRoot.path, 'dashboard_repo'));
    await repoRoot.create(recursive: true);

    final omegaRoot = Directory(
      p.join(tempRoot.path, 'omega_os_path_with_forward_slashes'),
    );
    await omegaRoot.create(recursive: true);

    final configDir = Directory(p.join(repoRoot.path, 'config'));
    await configDir.create(recursive: true);
    final omegaConfigPath = omegaRoot.path.replaceAll('\\', '/');
    await File(
      p.join(configDir.path, 'local_paths.json'),
    ).writeAsString(jsonEncode({'omega_os_root': omegaConfigPath}));

    final service = MeetingFolderService(workingDirectory: repoRoot);
    final result = await service.createMeeting(
      const MeetingCreateRequest(
        date: '2026-06-05',
        time: '10:00',
        timezoneLabel: 'UTC+00:00',
        timezoneOffsetMinutes: 0,
        durationMinutes: 60,
        project: 'MicroGrow',
        title: 'Path Normalization Check',
        personOrGroup: 'Anas Ahmed - Hackerspace Karachi',
        meetingType: 'Meeting',
        purpose: 'Confirm the saved folder path is normalized.',
        tags: ['test'],
      ),
    );

    expect(result.folderPath, p.normalize(result.folderPath));
    expect(result.folderPath, contains(omegaRoot.path));
  });

  test(
    'createMeeting writes a questions-for-attendee section into meeting notes',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'meeting_folder_service_notes_test_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final repoRoot = Directory(p.join(tempRoot.path, 'dashboard_repo'));
      await repoRoot.create(recursive: true);

      final omegaRoot = Directory(p.join(tempRoot.path, 'omega_os_notes'));
      await omegaRoot.create(recursive: true);

      final configDir = Directory(p.join(repoRoot.path, 'config'));
      await configDir.create(recursive: true);
      await File(
        p.join(configDir.path, 'local_paths.json'),
      ).writeAsString(jsonEncode({'omega_os_root': omegaRoot.path}));

      final service = MeetingFolderService(workingDirectory: repoRoot);
      final result = await service.createMeeting(
        const MeetingCreateRequest(
          date: '2026-06-06',
          time: '11:00',
          timezoneLabel: 'UTC+00:00',
          timezoneOffsetMinutes: 0,
          durationMinutes: 60,
          project: 'MicroGrow',
          title: 'Attendee Questions Review',
          personOrGroup: 'Anas Ahmed - Hackerspace Karachi',
          meetingType: 'Meeting',
          purpose: 'Collect the questions to ask during the call.',
          tags: ['notes'],
        ),
      );

      final notesFile = File(p.join(result.folderPath, '01_MEETING_NOTES.md'));
      final notes = await notesFile.readAsString();
      expect(notes, contains('## Questions for attendee'));
      expect(notes, contains('- '));
    },
  );

  test(
    'readMeeting backfills questions-for-attendee into older notes',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'meeting_folder_service_backfill_test_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final repoRoot = Directory(p.join(tempRoot.path, 'dashboard_repo'));
      await repoRoot.create(recursive: true);

      final omegaRoot = Directory(p.join(tempRoot.path, 'omega_os_backfill'));
      await omegaRoot.create(recursive: true);

      final configDir = Directory(p.join(repoRoot.path, 'config'));
      await configDir.create(recursive: true);
      await File(
        p.join(configDir.path, 'local_paths.json'),
      ).writeAsString(jsonEncode({'omega_os_root': omegaRoot.path}));

      final service = MeetingFolderService(workingDirectory: repoRoot);
      final result = await service.createMeeting(
        const MeetingCreateRequest(
          date: '2026-06-07',
          time: '12:00',
          timezoneLabel: 'UTC+00:00',
          timezoneOffsetMinutes: 0,
          durationMinutes: 60,
          project: 'MicroGrow',
          title: 'Legacy Notes Backfill',
          personOrGroup: 'Anas Ahmed - Hackerspace Karachi',
          meetingType: 'Meeting',
          purpose: 'Test the backfill flow.',
          tags: ['migration'],
        ),
      );

      final notesFile = File(p.join(result.folderPath, '01_MEETING_NOTES.md'));
      await notesFile.writeAsString('''
# Meeting Notes - Legacy

## Attendees

- Anas Ahmed

## Summary

Old notes.
''');

      final detail = await service.readMeeting(result.meetingId);
      final backfilledNotes = await notesFile.readAsString();
      expect(detail.notesMarkdown, contains('## Questions for attendee'));
      expect(backfilledNotes, contains('## Questions for attendee'));
    },
  );

  test(
    'importAttachmentFiles copies docs into the attachments folder',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'meeting_folder_service_attachment_test_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final repoRoot = Directory(p.join(tempRoot.path, 'dashboard_repo'));
      await repoRoot.create(recursive: true);

      final omegaRoot = Directory(p.join(tempRoot.path, 'omega_os_attachment'));
      await omegaRoot.create(recursive: true);

      final configDir = Directory(p.join(repoRoot.path, 'config'));
      await configDir.create(recursive: true);
      await File(
        p.join(configDir.path, 'local_paths.json'),
      ).writeAsString(jsonEncode({'omega_os_root': omegaRoot.path}));

      final service = MeetingFolderService(workingDirectory: repoRoot);
      final result = await service.createMeeting(
        const MeetingCreateRequest(
          date: '2026-06-08',
          time: '13:00',
          timezoneLabel: 'UTC+00:00',
          timezoneOffsetMinutes: 0,
          durationMinutes: 60,
          project: 'MicroGrow',
          title: 'Document Import',
          personOrGroup: 'Anas Ahmed - Hackerspace Karachi',
          meetingType: 'Meeting',
          purpose: 'Test document import.',
          tags: ['docs'],
        ),
      );

      final sourceDoc = File(p.join(tempRoot.path, 'spec.docx'));
      await sourceDoc.writeAsString('word document content');

      final imported = await service.importAttachmentFiles(result.meetingId, [
        sourceDoc.path,
      ]);

      expect(imported, hasLength(1));
      expect(await File(imported.single).exists(), isTrue);
      expect(imported.single, contains('attachments'));
    },
  );

  test(
    'importLatestRecordingFromFolder matches the closest meeting and writes a transcript',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'meeting_folder_service_recording_test_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final repoRoot = Directory(p.join(tempRoot.path, 'dashboard_repo'));
      await repoRoot.create(recursive: true);

      final omegaRoot = Directory(p.join(tempRoot.path, 'omega_os_recording'));
      await omegaRoot.create(recursive: true);

      final configDir = Directory(p.join(repoRoot.path, 'config'));
      await configDir.create(recursive: true);
      await File(
        p.join(configDir.path, 'local_paths.json'),
      ).writeAsString(jsonEncode({'omega_os_root': omegaRoot.path}));

      final transcriber = _FakeMeetingRecordingTranscriber(
        'This is the imported transcript.',
      );
      final service = MeetingFolderService(
        workingDirectory: repoRoot,
        recordingTranscriber: transcriber,
      );

      final now = DateTime.now();
      final offsetMinutes = now.timeZoneOffset.inMinutes;
      final firstMeetingStart = now.subtract(const Duration(minutes: 10));
      final secondMeetingStart = now.add(const Duration(hours: 4));

      final firstMeeting = await service.createMeeting(
        MeetingCreateRequest(
          date: _dateLabel(firstMeetingStart),
          time: _timeLabel(firstMeetingStart),
          timezoneLabel: 'Local',
          timezoneOffsetMinutes: offsetMinutes,
          durationMinutes: 60,
          project: 'MicroGrow',
          title: 'Recording Match Test',
          personOrGroup: 'Anas Ahmed - Hackerspace Karachi',
          meetingType: 'Meeting',
          purpose: 'Match the recording to this meeting.',
          tags: ['recording'],
        ),
      );

      await service.createMeeting(
        MeetingCreateRequest(
          date: _dateLabel(secondMeetingStart),
          time: _timeLabel(secondMeetingStart),
          timezoneLabel: 'Local',
          timezoneOffsetMinutes: offsetMinutes,
          durationMinutes: 60,
          project: 'MicroGrow',
          title: 'Later Meeting',
          personOrGroup: 'Anas Ahmed - Hackerspace Karachi',
          meetingType: 'Meeting',
          purpose: 'This one should not win.',
          tags: ['recording'],
        ),
      );

      final sourceFolder = Directory(p.join(tempRoot.path, 'recordings'));
      await sourceFolder.create(recursive: true);

      final olderFile = File(p.join(sourceFolder.path, 'older.mp4'));
      await olderFile.writeAsString('older recording');
      await olderFile.setLastModified(
        now.subtract(const Duration(minutes: 30)),
      );

      final newerFile = File(p.join(sourceFolder.path, 'latest.mkv'));
      await newerFile.writeAsString('newer recording');
      await newerFile.setLastModified(now);

      final result = await service.importLatestRecordingFromFolder(
        sourceFolder.path,
      );

      expect(transcriber.lastSourcePath, newerFile.path);
      expect(result.meeting.id, firstMeeting.meetingId);
      expect(result.minutesFromScheduledWindow, 0);
      expect(await File(result.recordingStoredPath).exists(), isTrue);
      expect(await File(result.transcriptPath).exists(), isTrue);

      final transcriptMarkdown = await File(result.transcriptPath).readAsString();
      expect(transcriptMarkdown, contains('This is the imported transcript.'));
      expect(transcriptMarkdown, contains('Recording Match Test'));

      final refreshed = await service.readMeeting(firstMeeting.meetingId);
      expect(refreshed.meeting.updatedAt, isNotEmpty);
    },
  );

  test('listAttachmentFiles builds an inline preview for text files', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'meeting_folder_service_preview_test_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final repoRoot = Directory(p.join(tempRoot.path, 'dashboard_repo'));
    await repoRoot.create(recursive: true);

    final omegaRoot = Directory(p.join(tempRoot.path, 'omega_os_preview'));
    await omegaRoot.create(recursive: true);

    final configDir = Directory(p.join(repoRoot.path, 'config'));
    await configDir.create(recursive: true);
    await File(
      p.join(configDir.path, 'local_paths.json'),
    ).writeAsString(jsonEncode({'omega_os_root': omegaRoot.path}));

    final service = MeetingFolderService(workingDirectory: repoRoot);
    final result = await service.createMeeting(
      const MeetingCreateRequest(
        date: '2026-06-09',
        time: '14:00',
        timezoneLabel: 'UTC+00:00',
        timezoneOffsetMinutes: 0,
        durationMinutes: 60,
        project: 'MicroGrow',
        title: 'Preview Text',
        personOrGroup: 'Anas Ahmed - Hackerspace Karachi',
        meetingType: 'Meeting',
        purpose: 'Test preview text.',
        tags: ['preview'],
      ),
    );

    final sourceDoc = File(p.join(tempRoot.path, 'notes.txt'));
    await sourceDoc.writeAsString('first line\nsecond line\nthird line');

    await service.importAttachmentFiles(result.meetingId, [sourceDoc.path]);

    final attachments = await service.listAttachmentFiles(result.meetingId);
    expect(attachments, hasLength(1));
    expect(attachments.single.preview, contains('first line'));
    expect(attachments.single.canPreviewInline, isTrue);
  });

  test('listAttachmentFiles builds an inline preview for docx files', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'meeting_folder_service_docx_preview_test_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final repoRoot = Directory(p.join(tempRoot.path, 'dashboard_repo'));
    await repoRoot.create(recursive: true);

    final omegaRoot = Directory(p.join(tempRoot.path, 'omega_os_docx'));
    await omegaRoot.create(recursive: true);

    final configDir = Directory(p.join(repoRoot.path, 'config'));
    await configDir.create(recursive: true);
    await File(
      p.join(configDir.path, 'local_paths.json'),
    ).writeAsString(jsonEncode({'omega_os_root': omegaRoot.path}));

    final service = MeetingFolderService(workingDirectory: repoRoot);
    final result = await service.createMeeting(
      const MeetingCreateRequest(
        date: '2026-06-10',
        time: '15:00',
        timezoneLabel: 'UTC+00:00',
        timezoneOffsetMinutes: 0,
        durationMinutes: 60,
        project: 'MicroGrow',
        title: 'Preview DOCX',
        personOrGroup: 'Anas Ahmed - Hackerspace Karachi',
        meetingType: 'Meeting',
        purpose: 'Test docx preview.',
        tags: ['preview'],
      ),
    );

    final docxFile = File(p.join(tempRoot.path, 'notes.docx'));
    final docxXml = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    <w:p><w:r><w:t>First paragraph</w:t></w:r></w:p>
    <w:p><w:r><w:t>Second paragraph</w:t></w:r></w:p>
  </w:body>
</w:document>
''';
    final contentTypes = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="xml" ContentType="application/xml"/>
</Types>
''';
    final archive = Archive()
      ..addFile(
        ArchiveFile(
          '[Content_Types].xml',
          utf8.encode(contentTypes).length,
          utf8.encode(contentTypes),
        ),
      )
      ..addFile(
        ArchiveFile(
          'word/document.xml',
          utf8.encode(docxXml).length,
          utf8.encode(docxXml),
        ),
      );
    final encoded = ZipEncoder().encode(archive);
    await docxFile.writeAsBytes(encoded);

    await service.importAttachmentFiles(result.meetingId, [docxFile.path]);

    final attachments = await service.listAttachmentFiles(result.meetingId);
    expect(attachments, hasLength(1));
    expect(attachments.single.preview, contains('First paragraph'));
    expect(attachments.single.preview, contains('Second paragraph'));
  });
}

String _dateLabel(DateTime value) {
  final local = value.toLocal();
  return
      '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

String _timeLabel(DateTime value) {
  final local = value.toLocal();
  return
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}
