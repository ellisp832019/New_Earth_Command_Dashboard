import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:new_earth_command_dashboard/features/visual_capture/data/visual_capture_folder_service.dart';

void main() {
  test(
    'visual capture folder service bootstraps starter folders and indexes',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'visual_capture_folder_service_test_',
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

      final before = await service.loadWorkspace();
      expect(before.isReady, isFalse);
      expect(before.missingFolders, contains('00_VISUAL_DASHBOARD'));
      expect(
        before.missingFiles,
        contains('00_VISUAL_DASHBOARD/visual_capture_index.csv'),
      );

      final result = await service.createMissingRequiredStructure();
      expect(
        result.createdFolders,
        containsAll(VisualCaptureFolderService.requiredFolders),
      );
      expect(
        result.createdFiles,
        contains('00_VISUAL_DASHBOARD/visual_capture_index.csv'),
      );

      final after = await service.loadWorkspace();
      expect(after.isReady, isTrue);
      expect(after.missingFolders, isEmpty);
      expect(after.missingFiles, isEmpty);

      final visualCaptureIndex = await File(
        p.join(
          visualCaptureRoot.path,
          '00_VISUAL_DASHBOARD',
          'visual_capture_index.csv',
        ),
      ).readAsString();
      expect(visualCaptureIndex, contains('capture_id'));
    },
  );
}
