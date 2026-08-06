import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:new_earth_command_dashboard/core/services/omega_os_folder_health_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/treasury/data/treasury_folder_service.dart';
import 'package:new_earth_command_dashboard/features/visual_capture/data/visual_capture_folder_service.dart';

void main() {
  test(
    'omega os folder health manager recognises active and reserved systems',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'omega_os_folder_health_service_test_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final omegaRoot = Directory(
        p.join(tempRoot.path, 'NEW_EARTH_OMEGA_OS_PACK'),
      );
      final financeRoot = Directory(
        p.join(omegaRoot.path, '17_FINANCE_AND_TREASURY'),
      );
      final assetsRoot = Directory(
        p.join(omegaRoot.path, '18_ASSETS_EQUIPMENT_AND_PARTS'),
      );
      final visualRoot = Directory(
        p.join(omegaRoot.path, '19_VISUAL_RECORDS_AND_CAPTURE'),
      );

      await financeRoot.create(recursive: true);
      await assetsRoot.create(recursive: true);
      await visualRoot.create(recursive: true);

      await _createStructure(
        root: assetsRoot,
        folders: AssetFolderService.requiredFolders,
        files: AssetFolderService.requiredFiles,
      );
      await _createFoldersOnly(
        root: visualRoot,
        folders: VisualCaptureFolderService.requiredFolders,
      );
      await _createFilesExcept(
        root: visualRoot,
        files: VisualCaptureFolderService.requiredFiles,
        excludedFile: '00_VISUAL_DASHBOARD/visual_capture_index.csv',
      );

      await File(
        p.join(financeRoot.path, TreasuryFolderService.requiredFiles.first),
      ).parent.create(recursive: true);

      await File(
        p.join(financeRoot.path, TreasuryFolderService.requiredFiles.first),
      ).writeAsString('placeholder');

      final configDir = Directory(p.join(tempRoot.path, 'config'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'local_paths.json')).writeAsString(
        jsonEncode({
          'omega_os_root': omegaRoot.path,
          'finance_treasury_path': financeRoot.path,
          'assets_equipment_path': assetsRoot.path,
          'visual_capture_path': visualRoot.path,
        }),
      );

      final service = OmegaOsFolderHealthService(workingDirectory: tempRoot);

      final before = await service.loadSnapshot();
      final treasury = _recordByFolderName(
        before.activeSystems,
        '17_FINANCE_AND_TREASURY',
      );
      final assets = _recordByFolderName(
        before.activeSystems,
        '18_ASSETS_EQUIPMENT_AND_PARTS',
      );
      final visualCapture = _recordByFolderName(
        before.activeSystems,
        '19_VISUAL_RECORDS_AND_CAPTURE',
      );

      expect(treasury.state, OmegaOsFolderHealthState.missingFolder);
      expect(assets.state, OmegaOsFolderHealthState.healthy);
      expect(visualCapture.state, OmegaOsFolderHealthState.missingTemplates);
      expect(before.healthyCount, 1);
      expect(before.missingTemplatesCount, 1);
      expect(before.missingFolderCount, 1);
      expect(before.reservedCount, 4);
      expect(
        before.reservedSystems.map((record) => record.state),
        everyElement(OmegaOsFolderHealthState.reserved),
      );
      expect(
        before.reservedSystems
            .map((record) => record.folderName)
            .toList(growable: false),
        containsAll(<String>[
          '20_CONTACTS_AND_RELATIONSHIPS',
          '21_PROJECTS_AND_PROGRAMMES',
          '22_KNOWLEDGE_AND_LEARNING',
          '23_AI_AND_AUTOMATION',
        ]),
      );

      final repair = await service.repairActiveSystems();
      expect(repair.repairedSystems, contains('Treasury'));
      expect(repair.repairedSystems, contains('Visual Capture'));
      expect(repair.repairedSystems, isNot(contains('Assets')));
      expect(repair.createdFolders, isNotEmpty);
      expect(
        repair.createdFiles,
        contains('00_VISUAL_DASHBOARD/visual_capture_index.csv'),
      );

      final after = await service.loadSnapshot();
      expect(after.healthyCount, 3);
      expect(after.missingTemplatesCount, 0);
      expect(after.missingFolderCount, 0);
    },
  );

  test(
    'omega os folder health manager reports missing config paths clearly',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'omega_os_folder_health_config_test_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final omegaRoot = Directory(
        p.join(tempRoot.path, 'NEW_EARTH_OMEGA_OS_PACK'),
      );
      await omegaRoot.create(recursive: true);

      final configDir = Directory(p.join(tempRoot.path, 'config'));
      await configDir.create(recursive: true);
      await File(
        p.join(configDir.path, 'local_paths.json'),
      ).writeAsString(jsonEncode({'omega_os_root': omegaRoot.path}));

      final service = OmegaOsFolderHealthService(workingDirectory: tempRoot);
      final snapshot = await service.loadSnapshot();

      expect(
        snapshot.issues,
        contains(
          'finance_treasury_path is missing from config/local_paths.json.',
        ),
      );
      expect(
        snapshot.issues,
        contains(
          'assets_equipment_path is missing from config/local_paths.json.',
        ),
      );
      expect(
        snapshot.issues,
        contains(
          'visual_capture_path is missing from config/local_paths.json.',
        ),
      );
      expect(snapshot.activeSystems.length, 3);
      expect(snapshot.reservedCount, 4);
    },
  );
}

Future<void> _createStructure({
  required Directory root,
  required List<String> folders,
  required List<String> files,
}) async {
  await _createFoldersOnly(root: root, folders: folders);
  for (final relativeFile in files) {
    final file = File(p.join(root.path, relativeFile));
    await file.parent.create(recursive: true);
    await file.writeAsString('placeholder');
  }
}

Future<void> _createFoldersOnly({
  required Directory root,
  required List<String> folders,
}) async {
  for (final relativeFolder in folders) {
    await Directory(p.join(root.path, relativeFolder)).create(recursive: true);
  }
}

Future<void> _createFilesExcept({
  required Directory root,
  required List<String> files,
  required String excludedFile,
}) async {
  for (final relativeFile in files) {
    if (relativeFile == excludedFile) {
      continue;
    }

    final file = File(p.join(root.path, relativeFile));
    await file.parent.create(recursive: true);
    await file.writeAsString('placeholder');
  }
}

OmegaOsFolderHealthRecord _recordByFolderName(
  List<OmegaOsFolderHealthRecord> records,
  String folderName,
) {
  return records.firstWhere((record) => record.folderName == folderName);
}
