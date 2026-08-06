import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/core/modules/module_hub_state_repository.dart';
import 'package:new_earth_command_dashboard/core/modules/module_navigation.dart';

void main() {
  test('module hub state repository persists launch targets locally', () async {
    final tempDir = await Directory.systemTemp.createTemp('module_hub_state');
    addTearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    final repository = ModuleHubStateRepository(
      stateFilePath: path.join(tempDir.path, 'module_hub_state.json'),
    );

    expect(repository.loadLaunchTarget('alpha'), ModuleLaunchTarget.package);

    await repository.saveLaunchTarget('alpha', ModuleLaunchTarget.home);

    expect(repository.loadLaunchTarget('alpha'), ModuleLaunchTarget.home);
    expect(
      repository.loadLaunchTargets(),
      containsPair('alpha', ModuleLaunchTarget.home),
    );
  });
}
