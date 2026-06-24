import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/core/modules/module_category.dart';
import 'package:new_earth_command_dashboard/core/modules/module_loader.dart';
import 'package:new_earth_command_dashboard/core/modules/module_manifest.dart';
import 'package:new_earth_command_dashboard/core/modules/module_manifest_parser.dart';
import 'package:new_earth_command_dashboard/core/modules/module_status.dart';

void main() {
  test(
    'module manifest parser maps schema fields into the dashboard model',
    () {
      const parser = ModuleManifestParser();

      final manifest = parser.parse(
        <String, dynamic>{
          'module_id': 'gaia_voice_assistant',
          'module_name': 'GAIA Voice Assistant',
          'version': '0.1.0',
          'category': 'AI & Automation',
          'description': 'Local voice bridge.',
          'status': 'bridge_ready',
          'dockable': true,
          'defaultDockPosition': 'right',
          'iconKey': 'science_outlined',
          'routes': ['/experiments'],
          'storagePath': 'modules/gaia_voice_assistant/storage',
          'permissions': ['microphone', 'speaker', 'local_network'],
          'omegaOsPath': 'OMEGA_OS/MODULES/GAIA_VOICE_ASSISTANT',
          'backend': {
            'implemented': false,
            'type': 'placeholder',
            'notes': 'UI shell only.',
          },
          'tags': ['voice', 'assistant'],
        },
        installPath: 'modules/gaia_voice_assistant',
        folderName: 'gaia_voice_assistant',
      );

      expect(manifest.id, 'gaia_voice_assistant');
      expect(manifest.name, 'GAIA Voice Assistant');
      expect(manifest.category, ModuleCategory.aiAutomation);
      expect(manifest.status, ModuleStatus.scaffold);
      expect(manifest.status.label, 'Scaffold');
      expect(manifest.source.label, 'Manifest');
      expect(manifest.enabled, isFalse);
      expect(manifest.iconKey, 'science_outlined');
      expect(manifest.routes, contains('/experiments'));
      expect(manifest.storagePath, 'modules/gaia_voice_assistant/storage');
      expect(manifest.permissions, hasLength(3));
      expect(manifest.health.warnings, isNotEmpty);
    },
  );

  test(
    'module loader reads manifests and infers missing ones from folders',
    () {
      final tempRoot = Directory.systemTemp.createTempSync('module-loader-');
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      final alphaDir = Directory(path.join(tempRoot.path, 'alpha_module'))
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
          'iconKey': 'folder_outlined',
          'routes': ['/alpha'],
          'storagePath': 'modules/alpha_module/storage',
          'permissions': ['file_read'],
          'omegaOsPath': 'OMEGA_OS/MODULES/ALPHA_MODULE',
        }),
      );

      Directory(
        path.join(tempRoot.path, 'beta_module'),
      ).createSync(recursive: true);
      Directory(
        path.join(tempRoot.path, '00_NEW_EARTH_OMEGA_MODULE_HUB_UI'),
      ).createSync(recursive: true);

      final registry = ModuleLoader(modulesRootPath: tempRoot.path).load();
      final ids = registry.all.map((module) => module.id).toList();

      expect(ids.first, 'module_hub');
      expect(ids, contains('alpha_module'));
      expect(ids, contains('beta_module'));
      expect(ids, isNot(contains('00_NEW_EARTH_OMEGA_MODULE_HUB_UI')));

      final alpha = registry.byId('alpha_module');
      final beta = registry.byId('beta_module');

      expect(alpha?.status, ModuleStatus.enabled);
      expect(beta?.status, ModuleStatus.scaffold);
      expect(beta?.status.label, 'Scaffold');
      expect(alpha?.source.label, 'Manifest');
      expect(beta?.source.label, 'Inferred scaffold');
      expect(alpha?.iconKey, 'folder_outlined');
      expect(alpha?.routes, contains('/alpha'));
      expect(alpha?.storagePath, 'modules/alpha_module/storage');
      expect(beta?.description, contains('inferred'));
    },
  );

  test('module loader keeps manifest-backed modules out of scaffold state', () {
    final registry = ModuleLoader().load();

    expect(
      registry.byId('meeting_system')?.status,
      isNot(ModuleStatus.scaffold),
    );
    expect(
      registry.byId('voice_intelligence_module')?.status,
      isNot(ModuleStatus.scaffold),
    );
    expect(
      registry.byId('new_earth_command_deck')?.status,
      isNot(ModuleStatus.scaffold),
    );
    expect(
      registry.byId('repo_research_engine')?.status,
      isNot(ModuleStatus.scaffold),
    );
    expect(
      registry.byId('knowledge_engine')?.status,
      isNot(ModuleStatus.scaffold),
    );
  });

  test('omega experiment engine manifest is discoverable from the module tree', () {
    final registry = ModuleLoader().load();
    final manifest = registry.byId('00_OMEGA_EXPERIMENT_VALIDATION_ENGINE');

    expect(manifest, isNotNull);
    expect(manifest?.name, contains('Omega Experiment'));
    expect(manifest?.routes, contains('/experiments'));
    expect(manifest?.iconKey, isNotEmpty);
  });

  test('omega knowledge engine manifest is discoverable from the module tree', () {
    final registry = ModuleLoader().load();
    final manifest = registry.byId('26_OMEGA_KNOWLEDGE_ENGINE');

    expect(manifest, isNotNull);
    expect(manifest?.name, contains('Omega Knowledge Engine'));
    expect(manifest?.routes, contains('/modules/omega-knowledge-engine'));
    expect(manifest?.iconKey, isNotEmpty);
    expect(manifest?.notes, contains('Scan/report only'));
  });
}
