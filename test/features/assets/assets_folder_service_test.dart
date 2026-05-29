import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';

void main() {
  test('asset folder service bootstraps the journal folder and file', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'asset-folder-service-',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final assetsRoot = Directory(
      '${tempRoot.path}/18_ASSETS_EQUIPMENT_AND_PARTS',
    );
    await assetsRoot.create(recursive: true);
    await File(
      '${tempRoot.path}/config/local_paths.json',
    ).create(recursive: true);
    await File(
      '${tempRoot.path}/config/local_paths.json',
    ).writeAsString(jsonEncode({'assets_equipment_path': assetsRoot.path}));

    final service = AssetFolderService(workingDirectory: tempRoot);
    final snapshot = await service.loadWorkspace();
    expect(snapshot.guidanceNote, contains('reserved'));

    final result = await service.createMissingRequiredStructure();

    expect(result.createdFolders, contains('changes'));
    expect(result.createdFiles, contains('changes/asset_change_journal.csv'));
    expect(
      await File(
        '${assetsRoot.path}/changes/asset_change_journal.csv',
      ).exists(),
      isTrue,
    );
  });
}
