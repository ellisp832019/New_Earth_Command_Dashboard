import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:new_earth_command_dashboard/features/meeting_system/data/meeting_folder_service.dart';

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
