import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:new_earth_command_dashboard/features/treasury/data/treasury_folder_service.dart';

void main() {
  test(
    'loadWorkspace reports missing files until templates are created',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'treasury_folder_service_test_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final repoRoot = Directory(p.join(tempRoot.path, 'dashboard_repo'));
      await repoRoot.create(recursive: true);

      final financeRoot = Directory(
        p.join(tempRoot.path, '17_FINANCE_AND_TREASURY'),
      );
      await financeRoot.create(recursive: true);
      for (final relativeFolder in TreasuryFolderService.requiredFolders) {
        await Directory(
          p.join(financeRoot.path, relativeFolder),
        ).create(recursive: true);
      }

      final configDir = Directory(p.join(repoRoot.path, 'config'));
      await configDir.create(recursive: true);
      await File(
        p.join(configDir.path, 'local_paths.json'),
      ).writeAsString(jsonEncode({'finance_treasury_path': financeRoot.path}));

      final service = TreasuryFolderService(workingDirectory: repoRoot);

      final before = await service.loadWorkspace();
      expect(before.isReady, isFalse);
      expect(
        before.missingFiles,
        containsAll(TreasuryFolderService.requiredFiles),
      );

      final createdFiles = await service.createMissingRequiredFiles();
      expect(createdFiles, containsAll(TreasuryFolderService.requiredFiles));

      final after = await service.loadWorkspace();
      expect(after.isReady, isTrue);
      expect(after.missingFiles, isEmpty);

      final dashboardState = await File(
        p.join(
          financeRoot.path,
          '00_FINANCE_DASHBOARD',
          'dashboard_state.json',
        ),
      ).readAsString();
      expect(dashboardState, contains('"safe"'));
    },
  );

  test(
    'writeTextFileWithBackup preserves a .bak copy before overwrite',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'treasury_file_backup_test_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final service = TreasuryFolderService(workingDirectory: tempRoot);
      final targetFile = File(p.join(tempRoot.path, 'notes', 'file.txt'));
      await targetFile.parent.create(recursive: true);
      await targetFile.writeAsString('old content');

      await service.writeTextFileWithBackup(targetFile, 'new content');

      expect(await targetFile.readAsString(), 'new content');
      expect(
        await File('${targetFile.path}.bak').readAsString(),
        'old content',
      );
    },
  );
}
