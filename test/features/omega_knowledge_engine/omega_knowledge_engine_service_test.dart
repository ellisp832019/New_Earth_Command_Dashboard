import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/features/omega_knowledge_engine/data/omega_knowledge_engine_service.dart';

void main() {
  test('omega knowledge engine falls back to safe defaults when config is missing', () async {
    final tempRoot = Directory.systemTemp.createTempSync('omega-knowledge-engine-defaults-');
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final service = OmegaKnowledgeEngineService(moduleRootPath: tempRoot.path);
    final settings = await service.loadSettings();

    expect(settings.safetyMode, 'scan_report_only');
    expect(settings.repoProfiles, hasLength(5));
    expect(settings.repoProfiles.first.name, 'Dashboard repo');
    expect(service.buildScanCommand(), contains('omega_scan.py'));
    expect(service.buildScanCommand(), contains('engine_config.yaml'));
  });

  test('omega knowledge engine snapshot reads local sample outputs', () async {
    final tempRoot = Directory.systemTemp.createTempSync('omega-knowledge-engine-snapshot-');
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final outputDir = Directory(path.join(tempRoot.path, 'output'));
    final exportDir = Directory(path.join(outputDir.path, 'obsidian_export'));
    await exportDir.create(recursive: true);

    await File(path.join(outputDir.path, 'repository_index.md')).writeAsString(
      '# Repository Index\n\n- dashboard\n',
    );
    await File(path.join(outputDir.path, 'repository_index.json')).writeAsString(
      '{"generated_at":"2026-06-24","repository_count":2,"files_scanned":11}',
    );
    await File(path.join(outputDir.path, 'code_learning_notes.md')).writeAsString(
      '# Learning Notes\n',
    );
    await File(path.join(outputDir.path, 'comment_suggestions.md')).writeAsString(
      '# Comments\n',
    );
    await File(path.join(outputDir.path, 'architecture_map.md')).writeAsString(
      '# Architecture\n',
    );
    await File(path.join(outputDir.path, 'project_memory.md')).writeAsString(
      '# Memory\n',
    );
    await File(path.join(exportDir.path, 'alpha.md')).writeAsString('alpha');

    final service = OmegaKnowledgeEngineService(moduleRootPath: tempRoot.path);
    final snapshot = await service.loadSnapshot();

    expect(snapshot.generatedAt, '2026-06-24');
    expect(snapshot.repositoryCount, 2);
    expect(snapshot.filesScanned, 11);
    expect(snapshot.repositoryIndexText, contains('Repository Index'));
    expect(snapshot.learningNotesText, contains('Learning Notes'));
    expect(snapshot.commentSuggestionsText, contains('Comments'));
    expect(snapshot.architectureMapText, contains('Architecture'));
    expect(snapshot.projectMemoryText, contains('Memory'));
    expect(snapshot.obsidianExportFiles, contains('alpha.md'));
  });

  test('omega knowledge engine saves and reloads local settings', () async {
    final tempRoot = Directory.systemTemp.createTempSync('omega-knowledge-engine-settings-');
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final service = OmegaKnowledgeEngineService(moduleRootPath: tempRoot.path);
    final settings = OmegaKnowledgeEngineSettings.defaults(moduleRootPath: tempRoot.path).copyWith(
      repoRootPath: tempRoot.path,
      outputDir: path.join(tempRoot.path, 'output'),
      obsidianExportDir: path.join(tempRoot.path, 'output', 'obsidian_export'),
      repoProfiles: const [
        OmegaKnowledgeEngineRepoProfile(
          key: 'custom_repo',
          name: 'Custom repo',
          pathWindows: r'D:\Dev\Projects\Custom Repo',
          type: 'flutter_app',
        ),
      ],
    );

    await service.saveSettings(settings);
    final reloaded = await service.loadSettings();

    expect(reloaded.repoRootPath, tempRoot.path);
    expect(reloaded.outputDir, path.join(tempRoot.path, 'output'));
    expect(reloaded.obsidianExportDir, path.join(tempRoot.path, 'output', 'obsidian_export'));
    expect(reloaded.repoProfiles, hasLength(1));
    expect(reloaded.repoProfiles.single.name, 'Custom repo');
  });

  test('omega knowledge engine runScan fails safely when scanner script is missing', () async {
    final tempRoot = Directory.systemTemp.createTempSync('omega-knowledge-engine-missing-script-');
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final service = OmegaKnowledgeEngineService(moduleRootPath: tempRoot.path);
    final result = await service.runScan();

    expect(result.succeeded, isFalse);
    expect(result.exitCode, isNot(0));
    expect(result.stderr, contains('Scanner script not found'));
  });

  test('omega knowledge engine snapshot stays readable when outputs are missing', () async {
    final tempRoot = Directory.systemTemp.createTempSync('omega-knowledge-engine-empty-');
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final service = OmegaKnowledgeEngineService(moduleRootPath: tempRoot.path);
    final snapshot = await service.loadSnapshot();

    expect(snapshot.generatedAt, 'Not run yet');
    expect(snapshot.repositoryIndexText, contains('Sample output missing'));
    expect(snapshot.learningNotesText, contains('Sample output missing'));
    expect(snapshot.commentSuggestionsText, contains('Sample output missing'));
    expect(snapshot.architectureMapText, contains('Sample output missing'));
    expect(snapshot.projectMemoryText, contains('Sample output missing'));
    expect(snapshot.obsidianExportFiles, isEmpty);
  });
}
