import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../tool/project_control/command_runner.dart';

void main() {
  group('project control CLI', () {
    test('validate passes for a minimal canonical repository', () async {
      final repo = await _createRepository();
      addTearDown(() => repo.delete(recursive: true));

      final exitCode = await runProjectControl([
        'validate',
      ], workingDirectory: repo);

      expect(exitCode, 0);
    });

    test('validate fails for invalid maturity', () async {
      final repo = await _createRepository(
        module1: _baseModule(maturity: 'wizard'),
      );
      addTearDown(() => repo.delete(recursive: true));

      final exitCode = await runProjectControl([
        'validate',
      ], workingDirectory: repo);

      expect(exitCode, 1);
    });

    test('validate fails for duplicate module ids', () async {
      final duplicate = _baseModule(id: 'alpha');
      final repo = await _createRepository(modules: [duplicate, duplicate]);
      addTearDown(() => repo.delete(recursive: true));

      final exitCode = await runProjectControl([
        'validate',
      ], workingDirectory: repo);

      expect(exitCode, 1);
    });

    test('validate fails for missing source path', () async {
      final repo = await _createRepository(module1: _baseModule());
      addTearDown(() => repo.delete(recursive: true));

      await File(
        p.join(repo.path, 'lib', 'features', 'alpha', 'alpha.dart'),
      ).delete();

      final exitCode = await runProjectControl([
        'validate',
      ], workingDirectory: repo);

      expect(exitCode, 1);
    });

    test('validate fails for unknown dependency', () async {
      final repo = await _createRepository(
        module1: _baseModule(dependencies: const ['ghost_module']),
      );
      addTearDown(() => repo.delete(recursive: true));

      final exitCode = await runProjectControl([
        'validate',
      ], workingDirectory: repo);

      expect(exitCode, 1);
    });

    test(
      'validate fails for stable module without passing verification',
      () async {
        final repo = await _createRepository(
          module1: _baseModule(
            maturity: 'stable',
            verificationStatus: 'partial',
          ),
        );
        addTearDown(() => repo.delete(recursive: true));

        final exitCode = await runProjectControl([
          'validate',
        ], workingDirectory: repo);

        expect(exitCode, 1);
      },
    );

    test('validate fails for persisted module without backup policy', () async {
      final repo = await _createRepository(
        module1: _baseModule(backupPolicy: ''),
      );
      addTearDown(() => repo.delete(recursive: true));

      final exitCode = await runProjectControl([
        'validate',
      ], workingDirectory: repo);

      expect(exitCode, 1);
    });

    test('validate fails for missing security classification', () async {
      final repo = await _createRepository(
        module1: _baseModule(securityLevel: ''),
      );
      addTearDown(() => repo.delete(recursive: true));

      final exitCode = await runProjectControl([
        'validate',
      ], workingDirectory: repo);

      expect(exitCode, 1);
    });

    test('validate fails for invalid risk severity', () async {
      final repo = await _createRepository(risks: [_baseRisk(severity: 'P9')]);
      addTearDown(() => repo.delete(recursive: true));

      final exitCode = await runProjectControl([
        'validate',
      ], workingDirectory: repo);

      expect(exitCode, 1);
    });

    test('scan writes generated state files on the first run', () async {
      final repo = await _createRepository();
      addTearDown(() => repo.delete(recursive: true));

      final exitCode = await runProjectControl([
        'scan',
      ], workingDirectory: repo);

      expect(exitCode, 0);
      expect(
        File(
          p.join(
            repo.path,
            'project_control',
            'generated',
            'current_state.json',
          ),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(
            repo.path,
            'project_control',
            'generated',
            'previous_scan.json',
          ),
        ).existsSync(),
        isFalse,
      );
    });

    test('scan records dirty working tree state', () async {
      final repo = await _createRepository(initialiseGit: true);
      addTearDown(() => repo.delete(recursive: true));

      await File(
        p.join(repo.path, 'dirty.txt'),
      ).writeAsString('dirty', flush: true);

      final exitCode = await runProjectControl([
        'scan',
      ], workingDirectory: repo);

      expect(exitCode, 0);
      final currentState = _readJson(
        File(
          p.join(
            repo.path,
            'project_control',
            'generated',
            'current_state.json',
          ),
        ),
      );
      expect(currentState['working_tree_state'], 'dirty');
    });

    test('diff detection records the previous scan', () async {
      final repo = await _createRepository(
        modules: <Map<String, dynamic>>[_baseModule()],
      );
      addTearDown(() => repo.delete(recursive: true));

      expect(await runProjectControl(['scan'], workingDirectory: repo), 0);

      final updated = <Map<String, dynamic>>[
        _baseModule(),
        _baseModule(
          id: 'beta',
          name: 'Beta',
          sourcePath: 'lib/features/beta/beta.dart',
          docPath: 'docs/beta.md',
          testPath: 'test/features/beta_test.dart',
        ),
      ];
      await _writeCanonicalRepository(
        repo,
        modules: updated,
        risks: <Map<String, dynamic>>[_baseRisk()],
      );

      expect(await runProjectControl(['scan'], workingDirectory: repo), 0);
      expect(await runProjectControl(['diff'], workingDirectory: repo), 0);

      final previousState = _readJson(
        File(
          p.join(
            repo.path,
            'project_control',
            'generated',
            'previous_scan.json',
          ),
        ),
      );
      final currentState = _readJson(
        File(
          p.join(
            repo.path,
            'project_control',
            'generated',
            'current_state.json',
          ),
        ),
      );

      expect(_asList(previousState['module_ids']), contains('alpha'));
      expect(
        _asList(currentState['module_ids']),
        containsAll(['alpha', 'beta']),
      );
    });

    test('release readiness is blocked by an open P0 risk', () async {
      final repo = await _createRepository(
        risks: [_baseRisk(severity: 'P0', status: 'open')],
      );
      addTearDown(() => repo.delete(recursive: true));

      final exitCode = await runProjectControl([
        'release-readiness',
      ], workingDirectory: repo);

      expect(exitCode, 1);
      final readiness = _readJson(
        File(
          p.join(
            repo.path,
            'project_control',
            'generated',
            'release_readiness.json',
          ),
        ),
      );
      expect(readiness['result'], 'blocked');
    });

    test(
      'release readiness is not ready when an open P1 risk remains',
      () async {
        final repo = await _createRepository(
          risks: [_baseRisk(severity: 'P1', status: 'open')],
        );
        addTearDown(() => repo.delete(recursive: true));

        final exitCode = await runProjectControl([
          'release-readiness',
        ], workingDirectory: repo);

        expect(exitCode, 1);
        final readiness = _readJson(
          File(
            p.join(
              repo.path,
              'project_control',
              'generated',
              'release_readiness.json',
            ),
          ),
        );
        expect(readiness['result'], 'not_ready');
      },
    );

    test('release readiness can be ready with conditions', () async {
      final repo = await _createRepository(
        risks: [_baseRisk(severity: 'P1', status: 'accepted')],
      );
      addTearDown(() => repo.delete(recursive: true));

      final exitCode = await runProjectControl([
        'release-readiness',
      ], workingDirectory: repo);

      expect(exitCode, 1);
      final readiness = _readJson(
        File(
          p.join(
            repo.path,
            'project_control',
            'generated',
            'release_readiness.json',
          ),
        ),
      );
      expect(readiness['result'], 'ready_with_conditions');
    });

    test('findRepositoryRoot returns null outside a repository', () {
      final temp = Directory.systemTemp.createTempSync(
        'project_control_outside_',
      );
      addTearDown(() => temp.delete(recursive: true));

      expect(findRepositoryRoot(temp), isNull);
    });

    test('running from a nested directory finds the repository root', () async {
      final repo = await _createRepository();
      addTearDown(() => repo.delete(recursive: true));
      final nested = Directory(p.join(repo.path, 'a', 'b', 'c'));
      await nested.create(recursive: true);

      final exitCode = await runProjectControl([
        'validate',
      ], workingDirectory: nested);

      expect(exitCode, 0);
    });

    test('stableMap sorts keys deterministically', () {
      final mapped = stableMap({'b': 2, 'a': 1, 'c': 3});
      expect(mapped.keys.toList(), ['a', 'b', 'c']);
    });
  });
}

Future<Directory> _createRepository({
  Map<String, dynamic>? module1,
  Map<String, dynamic>? module2,
  List<Map<String, dynamic>>? modules,
  List<Map<String, dynamic>>? risks,
  bool initialiseGit = false,
}) async {
  final repo = await Directory.systemTemp.createTemp('project_control_repo_');
  await _writeFile(
    p.join(repo.path, 'pubspec.yaml'),
    'name: project_control_repo\nversion: 1.0.0\n',
  );
  await Directory(p.join(repo.path, 'project_control')).create(recursive: true);
  await Directory(
    p.join(repo.path, 'project_control', 'generated'),
  ).create(recursive: true);
  await Directory(p.join(repo.path, 'docs')).create(recursive: true);
  await Directory(
    p.join(repo.path, 'docs', 'project_control'),
  ).create(recursive: true);
  await Directory(
    p.join(repo.path, 'docs', 'developer_guide'),
  ).create(recursive: true);

  final resolvedModules =
      modules ??
      <Map<String, dynamic>>[
        module1 ?? _baseModule(),
        module2 ?? _baseModule(id: 'beta', name: 'Beta'),
      ];
  await _writeCanonicalRepository(
    repo,
    modules: resolvedModules,
    risks: risks ?? <Map<String, dynamic>>[_baseRisk()],
  );

  for (final module in resolvedModules) {
    for (final relative in [
      ..._asList(module['source_paths']).cast<String>(),
      ..._asList(module['documentation_paths']).cast<String>(),
      ..._asList(module['test_paths']).cast<String>(),
    ]) {
      await _writeFile(p.join(repo.path, relative), '// fixture\n');
    }
  }

  if (initialiseGit) {
    await Process.run('git', ['init'], workingDirectory: repo.path);
  }

  return repo;
}

Future<void> _writeCanonicalRepository(
  Directory repo, {
  required List<Map<String, dynamic>> modules,
  required List<Map<String, dynamic>> risks,
}) async {
  await _writeFile(
    p.join(repo.path, 'project_control', 'status_definitions.yaml'),
    jsonEncode({
      'schema_version': 1,
      'module_maturity_values': [],
      'verification_states': [],
      'documentation_states': [],
      'release_readiness_states': [],
      'risk_severities': [],
      'risk_status_values': [],
    }),
  );
  await _writeFile(
    p.join(repo.path, 'project_control', 'platform_manifest.yaml'),
    jsonEncode({
      'schema_version': 1,
      'platform_id': 'temp',
      'platform_name': 'Temp',
      'description': 'Temp',
      'repository_url': '.',
      'repository_root_hint': '.',
      'current_branch': 'main',
      'current_commit': 'abc',
      'application_version': '1.0.0+1',
      'platform_maturity': 'beta',
      'supported_platforms': ['windows'],
      'primary_platform': 'windows',
      'local_first': true,
      'data_ownership': 'local',
      'telemetry_policy': 'none',
      'cloud_dependency': 'none',
      'release_policy': 'internal',
      'default_branch_policy': 'main',
      'canonical_documentation': ['docs/project_control/START_HERE.md'],
      'last_verified_commit': 'abc',
      'last_verified_date': '2026-08-06',
      'last_verified_build': {},
      'last_scan': {},
      'release_readiness': 'not_ready',
      'known_limitations': [],
    }),
  );
  await _writeFile(
    p.join(repo.path, 'project_control', 'module_registry.yaml'),
    jsonEncode(modules),
  );
  await _writeFile(
    p.join(repo.path, 'project_control', 'dependency_map.yaml'),
    jsonEncode({'schema_version': 1}),
  );
  await _writeFile(
    p.join(repo.path, 'project_control', 'risk_register.yaml'),
    jsonEncode(risks),
  );
  await _writeFile(
    p.join(repo.path, 'project_control', 'verification_registry.yaml'),
    jsonEncode([
      {
        'verification_id': 'V-1',
        'scope': 'baseline',
        'commit': 'abc',
        'branch': 'main',
        'environment': 'test',
        'commands': ['validate'],
        'result': 'passed',
        'warnings': [],
        'evidence_paths': [],
        'build_artifacts': [],
        'build_hashes': [],
        'date': '2026-08-06',
        'limitations': [],
      },
    ]),
  );
  await _writeFile(
    p.join(repo.path, 'project_control', 'release_registry.yaml'),
    jsonEncode(<Map<String, dynamic>>[]),
  );
  await _writeFile(
    p.join(repo.path, 'project_control', 'architecture_boundaries.yaml'),
    jsonEncode({'schema_version': 1, 'layers': []}),
  );
}

Map<String, dynamic> _baseModule({
  String id = 'alpha',
  String name = 'Alpha',
  String maturity = 'beta',
  String verificationStatus = 'passed',
  String documentationStatus = 'current',
  List<String> dependencies = const [],
  String backupPolicy = 'repository backups',
  String securityLevel = 'internal',
  String sourcePath = 'lib/features/alpha/alpha.dart',
  String docPath = 'docs/alpha.md',
  String testPath = 'test/features/alpha_test.dart',
}) {
  return <String, dynamic>{
    'id': id,
    'name': name,
    'description': '$name module',
    'version': '1.0.0',
    'maturity': maturity,
    'enabled': true,
    'route': '/$id',
    'source_paths': [sourcePath],
    'documentation_paths': [docPath],
    'test_paths': [testPath],
    'data_storage': 'sqlite',
    'data_owner': '$id-team',
    'backup_policy': backupPolicy,
    'export_policy': 'markdown',
    'security_level': securityLevel,
    'permissions': ['read', 'write'],
    'dependencies': dependencies,
    'known_risks': <String>[],
    'last_verified_commit': 'abc',
    'last_verified_date': '2026-08-06',
    'verification_status': verificationStatus,
    'documentation_status': documentationStatus,
    'recommended_next_action': 'none',
    'owner': '$id-team',
    'notes': '',
  };
}

Map<String, dynamic> _baseRisk({
  String severity = 'P2',
  String status = 'open',
}) {
  return <String, dynamic>{
    'risk_id': 'R-1',
    'title': 'Risk',
    'severity': severity,
    'likelihood': 'medium',
    'affected_modules': ['alpha'],
    'description': 'Risk',
    'evidence': ['test'],
    'mitigation': 'mitigate',
    'owner': 'owner',
    'status': status,
    'target_release': 'test',
    'created_date': '2026-08-06',
    'last_reviewed_date': '2026-08-06',
  };
}

List<dynamic> _asList(dynamic value) {
  if (value is List<dynamic>) {
    return value;
  }
  return const [];
}

Map<String, dynamic> _readJson(File file) =>
    jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

Future<void> _writeFile(String path, String content) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString(content, flush: true);
}
