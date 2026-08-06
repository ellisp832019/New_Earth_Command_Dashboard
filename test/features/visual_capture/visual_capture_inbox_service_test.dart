import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:new_earth_command_dashboard/features/visual_capture/data/visual_capture_folder_service.dart';

void main() {
  test('visual capture inbox imports a file and appends the index', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'visual_capture_inbox_service_test_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final visualCaptureRoot = Directory(
      p.join(tempRoot.path, '19_VISUAL_RECORDS_AND_CAPTURE'),
    );
    await visualCaptureRoot.create(recursive: true);

    final configDir = Directory(p.join(tempRoot.path, 'config'));
    await configDir.create(recursive: true);
    await File(p.join(configDir.path, 'local_paths.json')).writeAsString(
      jsonEncode({'visual_capture_path': visualCaptureRoot.path}),
    );

    final service = VisualCaptureFolderService(workingDirectory: tempRoot);
    await service.createMissingRequiredStructure();

    final sourceFile = File(p.join(tempRoot.path, 'sample_receipt.jpg'));
    await sourceFile.writeAsBytes(<int>[1, 2, 3, 4]);

    final result = await service.importImageToInbox(
      visualCaptureRootPath: visualCaptureRoot.path,
      sourceFilePath: sourceFile.path,
      captureType: 'receipt',
      project: 'MicroGrow',
      notes: 'Receipt ready for review.',
    );

    expect(await File(result.copiedFilePath).exists(), isTrue);

    final inbox = await service.loadInbox();
    expect(inbox.queuedFileCount, 1);
    expect(inbox.items, hasLength(1));
    expect(inbox.items.single.captureType, 'receipt');
    expect(inbox.items.single.linkedDomain, 'visual_capture');
    expect(inbox.items.single.linkedId, isEmpty);
    expect(inbox.items.single.project, 'MicroGrow');
    expect(inbox.items.single.status, 'inbox');
    expect(
      await File(
        p.join(
          visualCaptureRoot.path,
          '00_VISUAL_DASHBOARD',
          'visual_capture_index.csv',
        ),
      ).readAsString(),
      contains('Receipt ready for review.'),
    );
  });
}
