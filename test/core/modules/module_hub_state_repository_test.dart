import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/core/dock/dock_position.dart';
import 'package:new_earth_command_dashboard/core/modules/module_hub_state_repository.dart';
import 'package:new_earth_command_dashboard/core/modules/module_loader.dart';
import 'package:new_earth_command_dashboard/core/modules/module_status.dart';

void main() {
  test('module hub state repository saves and reloads enabled state', () async {
    final tempRoot = Directory.systemTemp.createTempSync('module-hub-state-');
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final stateFile = path.join(tempRoot.path, 'module_hub_state.json');
    final repository = ModuleHubStateRepository(stateFilePath: stateFile);

    await repository.saveEnabledState('alpha_module', false);

    final contents =
        jsonDecode(File(stateFile).readAsStringSync()) as Map<String, dynamic>;
    expect(contents['enabledById'], isA<Map>());
    expect(contents['updatedAt'], isA<String>());

    final states = repository.loadEnabledStates();
    expect(states['alpha_module'], isFalse);
  });

  test('module hub state repository saves and reloads hub ui state', () async {
    final tempRoot = Directory.systemTemp.createTempSync('module-hub-ui-');
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final stateFile = path.join(tempRoot.path, 'module_hub_state.json');
    final repository = ModuleHubStateRepository(stateFilePath: stateFile);

    await repository.saveHubUiState({
      'searchQuery': 'voice',
      'viewMode': 'list',
      'categoryFilter': 'aiAutomation',
      'statusFilter': 'scaffold',
      'dockableFilter': true,
      'permissionFilter': 'microphone',
      'sortMode': 'status',
    });

    final contents =
        jsonDecode(File(stateFile).readAsStringSync()) as Map<String, dynamic>;
    expect(contents['hubUiState'], isA<Map>());
    expect(contents['updatedAt'], isA<String>());

    final uiState = repository.loadHubUiState();
    expect(uiState['searchQuery'], 'voice');
    expect(uiState['viewMode'], 'list');
    expect(uiState['categoryFilter'], 'aiAutomation');
    expect(uiState['statusFilter'], 'scaffold');
    expect(uiState['dockableFilter'], isTrue);
    expect(uiState['permissionFilter'], 'microphone');
    expect(uiState['sortMode'], 'status');
  });

  test('module hub state repository saves and reloads dock layout state', ()
      async {
    final tempRoot = Directory.systemTemp.createTempSync('module-hub-dock-');
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final stateFile = path.join(tempRoot.path, 'module_hub_state.json');
    final repository = ModuleHubStateRepository(stateFilePath: stateFile);

    await repository.saveDockPosition('alpha_module', DockPosition.left);
    await repository.saveDockPosition('beta_module', DockPosition.bottom);

    final layoutState = repository.loadDockLayoutState();
    expect(layoutState.positionFor('alpha_module'), DockPosition.left);
    expect(layoutState.positionFor('beta_module'), DockPosition.bottom);

    final contents =
        jsonDecode(File(stateFile).readAsStringSync()) as Map<String, dynamic>;
    expect(contents['dockLayoutState'], isA<Map>());
  });

  test('module hub state repository saves and reloads floating dock anchors',
      () async {
    final tempRoot = Directory.systemTemp.createTempSync('module-hub-anchor-');
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final stateFile = path.join(tempRoot.path, 'module_hub_state.json');
    final repository = ModuleHubStateRepository(stateFilePath: stateFile);

    final layoutState = repository
        .loadDockLayoutState()
        .setFloatingAnchor('alpha_module', DockAnchor.topLeft);
    await repository.saveDockLayoutState(layoutState);

    final restored = repository.loadDockLayoutState();
    expect(restored.floatingAnchorFor('alpha_module'), DockAnchor.topLeft);

    final contents =
        jsonDecode(File(stateFile).readAsStringSync()) as Map<String, dynamic>;
    expect(contents['dockLayoutState'], isA<Map>());
    expect(contents['dockLayoutState']['floatingAnchorsByModuleId'], isA<Map>());
  });

  test('module loader reapplies persisted enabled state on load', () async {
    final tempRoot = Directory.systemTemp.createTempSync(
      'module-loader-state-',
    );
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final modulesRoot = Directory(path.join(tempRoot.path, 'modules'))
      ..createSync(recursive: true);
    final alphaDir = Directory(path.join(modulesRoot.path, 'alpha_module'))
      ..createSync(recursive: true);

    File(path.join(alphaDir.path, 'module_manifest.json')).writeAsStringSync(
      jsonEncode({
        'id': 'alpha_module',
        'name': 'Alpha Module',
        'description': 'A loaded module manifest.',
        'category': 'Project Management',
        'version': '1.0.0',
        'status': 'enabled',
        'dockable': true,
        'defaultDockPosition': 'left',
        'permissions': ['file_read'],
        'omegaOsPath': 'OMEGA_OS/MODULES/ALPHA_MODULE',
      }),
    );

    final stateFile = path.join(modulesRoot.path, 'module_hub_state.json');
    final repository = ModuleHubStateRepository(stateFilePath: stateFile);
    await repository.saveEnabledState('alpha_module', false);

    final registry = ModuleLoader(
      modulesRootPath: modulesRoot.path,
    ).load(stateRepository: repository);

    final alpha = registry.byId('alpha_module');
    expect(alpha?.enabled, isFalse);
    expect(registry.byId('module_hub')?.enabled, isTrue);
    expect(registry.byId('alpha_module')?.status, ModuleStatus.enabled);
  });

  test('module loader reapplies persisted dock positions on load', () async {
    final tempRoot = Directory.systemTemp.createTempSync(
      'module-loader-dock-',
    );
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final modulesRoot = Directory(path.join(tempRoot.path, 'modules'))
      ..createSync(recursive: true);
    final alphaDir = Directory(path.join(modulesRoot.path, 'alpha_module'))
      ..createSync(recursive: true);

    File(path.join(alphaDir.path, 'module_manifest.json')).writeAsStringSync(
      jsonEncode({
        'id': 'alpha_module',
        'name': 'Alpha Module',
        'description': 'A loaded module manifest.',
        'category': 'Project Management',
        'version': '1.0.0',
        'status': 'enabled',
        'dockable': true,
        'defaultDockPosition': 'left',
        'permissions': ['file_read'],
        'omegaOsPath': 'OMEGA_OS/MODULES/ALPHA_MODULE',
      }),
    );

    final stateFile = path.join(modulesRoot.path, 'module_hub_state.json');
    final repository = ModuleHubStateRepository(stateFilePath: stateFile);
    await repository.saveDockPosition('alpha_module', DockPosition.bottom);

    final registry = ModuleLoader(
      modulesRootPath: modulesRoot.path,
    ).load(stateRepository: repository);

    final alpha = registry.byId('alpha_module');
    expect(alpha?.defaultDockPosition, DockPosition.bottom);
  });
}
