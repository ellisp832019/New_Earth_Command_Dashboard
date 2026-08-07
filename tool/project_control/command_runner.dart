import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

Future<int> runProjectControl(
  List<String> args, {
  Directory? workingDirectory,
}) async {
  final cwd = workingDirectory ?? Directory.current;
  final repoRoot = findRepositoryRoot(cwd);
  if (args.isEmpty ||
      args.first == 'help' ||
      args.first == '--help' ||
      args.first == '-h') {
    printUsage();
    return 0;
  }

  if (repoRoot == null) {
    stderr.writeln('Could not locate the repository root from ${cwd.path}.');
    printUsage();
    return 3;
  }

  final command = args.first;
  final commandArgs = args.skip(1).toList(growable: false);

  switch (command) {
    case 'doctor':
      return await _doctor(repoRoot);
    case 'scan':
      return await _scan(repoRoot);
    case 'validate':
      return await _validate(repoRoot);
    case 'report':
      return await _report(
        repoRoot,
        verbose: commandArgs.contains('--verbose'),
      );
    case 'diff':
      return await _diff(repoRoot);
    case 'release-readiness':
      return await _releaseReadiness(repoRoot);
    default:
      stderr.writeln('Unknown command: $command');
      printUsage();
      return 2;
  }
}

Directory? findRepositoryRoot(Directory start) {
  var current = start;
  while (true) {
    final pubspec = File(p.join(current.path, 'pubspec.yaml'));
    final controlDir = Directory(p.join(current.path, 'project_control'));
    if (pubspec.existsSync() && controlDir.existsSync()) {
      return current;
    }
    final parent = current.parent;
    if (parent.path == current.path) {
      return null;
    }
    current = parent;
  }
}

void printUsage() {
  stdout.writeln('Usage: dart run tool/project_control.dart <command>');
  stdout.writeln('');
  stdout.writeln('Commands:');
  stdout.writeln('  doctor');
  stdout.writeln('  scan');
  stdout.writeln('  validate');
  stdout.writeln('  report');
  stdout.writeln('  diff');
  stdout.writeln('  release-readiness');
  stdout.writeln('  help');
}

Future<int> _doctor(Directory repoRoot) async {
  final issues = <String>[];
  final warnings = <String>[];

  if (!await _commandAvailable('git')) {
    issues.add('git is not available on PATH.');
  }
  if (!await _commandAvailable('flutter')) {
    issues.add('flutter is not available on PATH.');
  }
  if (!await _commandAvailable('dart')) {
    issues.add('dart is not available on PATH.');
  }

  final canonicalFiles = <String>[
    'project_control/status_definitions.yaml',
    'project_control/platform_manifest.yaml',
    'project_control/module_registry.yaml',
    'project_control/dependency_map.yaml',
    'project_control/risk_register.yaml',
    'project_control/verification_registry.yaml',
    'project_control/release_registry.yaml',
    'project_control/architecture_boundaries.yaml',
  ];
  for (final relativePath in canonicalFiles) {
    if (!File(p.join(repoRoot.path, relativePath)).existsSync()) {
      issues.add('Missing canonical file: $relativePath');
    }
  }

  final docsDirs = <String>['docs/project_control', 'docs/developer_guide'];
  for (final relativePath in docsDirs) {
    if (!Directory(p.join(repoRoot.path, relativePath)).existsSync()) {
      warnings.add('Missing documentation directory: $relativePath');
    }
  }

  final validation = _validateCanonicalFiles(repoRoot);
  issues.addAll(validation.errors);
  warnings.addAll(validation.warnings);

  final branch = await _git(repoRoot, ['branch', '--show-current']);
  final commit = await _git(repoRoot, ['rev-parse', 'HEAD']);
  final status = await _git(repoRoot, ['status', '--short']);
  final remote = await _git(repoRoot, ['remote', '-v']);

  stdout.writeln('Repository root: ${repoRoot.path}');
  stdout.writeln('Branch: ${branch.trim()}');
  stdout.writeln('Commit: ${commit.trim()}');
  stdout.writeln('Working tree: ${status.trim().isEmpty ? 'clean' : 'dirty'}');
  stdout.writeln('Remote configuration:');
  stdout.writeln(remote.trim().isEmpty ? '  (none)' : remote.trim());

  for (final warning in warnings) {
    stdout.writeln('Warning: $warning');
  }
  for (final issue in issues) {
    stderr.writeln('Error: $issue');
  }

  return issues.isEmpty ? 0 : 1;
}

Future<int> _scan(Directory repoRoot) async {
  final scan = _buildScan(repoRoot);
  final generatedDir = Directory(
    p.join(repoRoot.path, 'project_control', 'generated'),
  );
  await generatedDir.create(recursive: true);

  final currentPath = p.join(generatedDir.path, 'current_state.json');
  final currentFile = File(currentPath);
  if (currentFile.existsSync()) {
    final currentContent = await currentFile.readAsString();
    final existing = _asMap(jsonDecode(currentContent));
    if (!existing.containsKey('note')) {
      final previousFile = File(
        p.join(generatedDir.path, 'previous_scan.json'),
      );
      await previousFile.writeAsString(currentContent, flush: true);
    }
  }

  await _writeJson(File(currentPath), scan);
  await _writeJson(
    File(p.join(generatedDir.path, 'module_matrix.json')),
    _moduleMatrix(scan),
  );
  await _writeJson(
    File(p.join(generatedDir.path, 'repository_health.json')),
    _repositoryHealth(scan),
  );

  await File(
    p.join(generatedDir.path, 'current_state.md'),
  ).writeAsString(_currentStateMarkdown(scan), flush: true);
  await File(
    p.join(generatedDir.path, 'module_matrix.md'),
  ).writeAsString(_moduleMatrixMarkdown(scan), flush: true);
  await File(
    p.join(generatedDir.path, 'repository_health.md'),
  ).writeAsString(_repositoryHealthMarkdown(scan), flush: true);

  stdout.writeln('Scan ID: ${scan['scan_id']}');
  stdout.writeln('Modules: ${scan['module_count']}');
  stdout.writeln('Risks: ${scan['risk_totals']['total']}');
  return 0;
}

Future<int> _validate(Directory repoRoot) async {
  final validation = _validateCanonicalFiles(repoRoot);
  for (final warning in validation.warnings) {
    stdout.writeln('Warning: $warning');
  }
  for (final error in validation.errors) {
    stderr.writeln('Error: $error');
  }
  return validation.errors.isEmpty ? 0 : 1;
}

Future<int> _report(Directory repoRoot, {required bool verbose}) async {
  final scan = _buildScan(repoRoot);
  final readiness = _evaluateReadinessFromData(
    _loadListFile(repoRoot, 'project_control/module_registry.yaml'),
    _loadListFile(repoRoot, 'project_control/risk_register.yaml'),
  );
  await _writeJson(
    File(
      p.join(
        repoRoot.path,
        'project_control',
        'generated',
        'release_readiness.json',
      ),
    ),
    readiness,
  );
  await File(
    p.join(
      repoRoot.path,
      'project_control',
      'generated',
      'release_readiness.md',
    ),
  ).writeAsString(_releaseReadinessMarkdown(readiness), flush: true);

  stdout.writeln('Platform: ${scan['platform_name']}');
  stdout.writeln('Version: ${scan['application_version']}');
  stdout.writeln('Maturity: ${scan['platform_maturity']}');
  stdout.writeln('Commit: ${scan['commit']}');
  stdout.writeln('Modules: ${scan['module_count']}');
  stdout.writeln('Release readiness: ${readiness['result']}');

  if (verbose) {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(scan));
  }
  return 0;
}

Future<int> _diff(Directory repoRoot) async {
  final generatedDir = Directory(
    p.join(repoRoot.path, 'project_control', 'generated'),
  );
  final currentFile = File(p.join(generatedDir.path, 'current_state.json'));
  final previousFile = File(p.join(generatedDir.path, 'previous_scan.json'));
  if (!currentFile.existsSync()) {
    stderr.writeln('No current scan exists. Run scan first.');
    return 1;
  }
  if (!previousFile.existsSync()) {
    stdout.writeln(
      'No previous scan exists. The current scan establishes the baseline.',
    );
    return 0;
  }

  final current = _asMap(jsonDecode(await currentFile.readAsString()));
  final previous = _asMap(jsonDecode(await previousFile.readAsString()));
  if (previous.containsKey('note')) {
    stdout.writeln(
      'No previous scan exists. The current scan establishes the baseline.',
    );
    return 0;
  }
  final added = _listDifference(
    _asList(current['module_ids']),
    _asList(previous['module_ids']),
  );
  final removed = _listDifference(
    _asList(previous['module_ids']),
    _asList(current['module_ids']),
  );

  stdout.writeln('Added modules: ${added.isEmpty ? 'none' : added.join(', ')}');
  stdout.writeln(
    'Removed modules: ${removed.isEmpty ? 'none' : removed.join(', ')}',
  );
  return 0;
}

Future<int> _releaseReadiness(Directory repoRoot) async {
  final readiness = _evaluateReadinessFromData(
    _loadListFile(repoRoot, 'project_control/module_registry.yaml'),
    _loadListFile(repoRoot, 'project_control/risk_register.yaml'),
  );
  final generatedDir = Directory(
    p.join(repoRoot.path, 'project_control', 'generated'),
  );
  await generatedDir.create(recursive: true);
  await _writeJson(
    File(p.join(generatedDir.path, 'release_readiness.json')),
    readiness,
  );
  await File(
    p.join(generatedDir.path, 'release_readiness.md'),
  ).writeAsString(_releaseReadinessMarkdown(readiness), flush: true);
  stdout.writeln('Release readiness: ${readiness['result']}');
  for (final reason in _asList(readiness['reasons'])) {
    stdout.writeln('- $reason');
  }
  return readiness['result'] == 'ready' ? 0 : 1;
}

Map<String, dynamic> _buildScan(Directory repoRoot) {
  final manifest = _loadObjectFile(
    repoRoot,
    'project_control/platform_manifest.yaml',
  );
  final modules = _loadListFile(
    repoRoot,
    'project_control/module_registry.yaml',
  );
  final risks = _loadListFile(repoRoot, 'project_control/risk_register.yaml');
  final verifications = _loadListFile(
    repoRoot,
    'project_control/verification_registry.yaml',
  );
  final releaseRegistry = _loadListFile(
    repoRoot,
    'project_control/release_registry.yaml',
  );
  final statusDefinitions = _loadObjectFile(
    repoRoot,
    'project_control/status_definitions.yaml',
  );

  final moduleIds = modules
      .map((module) => _stringValue(module, 'id'))
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  final moduleMaturityCounts = _countBy(modules, 'maturity');
  final verificationCounts = _countBy(modules, 'verification_status');
  final documentationCounts = _countBy(modules, 'documentation_status');
  final verificationRegistryCounts = _countBy(verifications, 'result');
  final riskTotals = <String, dynamic>{
    'total': risks.length,
    'by_severity': _countBy(risks, 'severity'),
    'by_status': _countBy(risks, 'status'),
  };

  final branch = _gitSync(repoRoot, ['branch', '--show-current']);
  final commit = _gitSync(repoRoot, ['rev-parse', 'HEAD']);
  final status = _gitSync(repoRoot, ['status', '--short']);
  final dirty = status.trim().isNotEmpty;

  return stableMap(<String, dynamic>{
    'scan_id': 'scan-${DateTime.now().toUtc().toIso8601String()}',
    'scan_timestamp': DateTime.now().toUtc().toIso8601String(),
    'branch': branch.trim(),
    'commit': commit.trim(),
    'working_tree_state': dirty ? 'dirty' : 'clean',
    'platform_name': _stringValue(manifest, 'platform_name'),
    'application_version': _stringValue(manifest, 'application_version'),
    'platform_maturity': _stringValue(manifest, 'platform_maturity'),
    'module_count': modules.length,
    'module_ids': moduleIds,
    'module_maturity_counts': moduleMaturityCounts,
    'verification_counts': verificationCounts,
    'documentation_counts': documentationCounts,
    'verification_registry_counts': verificationRegistryCounts,
    'risk_totals': riskTotals,
    'routes_found': modules
        .map((module) => _stringValue(module, 'route'))
        .where((route) => route.isNotEmpty)
        .toList(growable: false),
    'feature_directories_found': _featureDirectories(repoRoot),
    'test_files_found': _findFiles(repoRoot, ['test'], '.dart'),
    'documentation_files_found': _findFiles(repoRoot, [
      'docs',
      'project_control',
    ], '.md'),
    'missing_declared_paths': _missingDeclaredPaths(repoRoot, modules),
    'version_contradictions': _versionContradictions(manifest),
    'ci_status': _ciStatus(repoRoot),
    'database_schema_version': _databaseSchemaVersion(repoRoot),
    'repository_health_warnings': _repositoryHealthWarnings(
      repoRoot,
      modules,
      risks,
    ),
    'recommended_next_actions': _recommendedNextActions(
      repoRoot,
      modules,
      risks,
      readinessHint: _evaluateReadinessFromData(modules, risks),
    ),
    'release_registry_status': releaseRegistry.isEmpty ? 'empty' : 'seeded',
    'status_definition_version': _stringValue(
      statusDefinitions,
      'schema_version',
    ),
  });
}

Map<String, dynamic> _moduleMatrix(Map<String, dynamic> scan) {
  return stableMap(<String, dynamic>{
    'scan_id': scan['scan_id'],
    'module_ids': scan['module_ids'],
    'maturity_counts': scan['module_maturity_counts'],
    'verification_counts': scan['verification_counts'],
    'documentation_counts': scan['documentation_counts'],
  });
}

Map<String, dynamic> _repositoryHealth(Map<String, dynamic> scan) {
  return stableMap(<String, dynamic>{
    'scan_id': scan['scan_id'],
    'branch': scan['branch'],
    'commit': scan['commit'],
    'working_tree_state': scan['working_tree_state'],
    'risk_totals': scan['risk_totals'],
    'warnings': scan['repository_health_warnings'],
  });
}

String _currentStateMarkdown(Map<String, dynamic> scan) {
  return [
    '# Current State',
    '',
    '- Scan ID: ${scan['scan_id']}',
    '- Branch: ${scan['branch']}',
    '- Commit: ${scan['commit']}',
    '- Working tree: ${scan['working_tree_state']}',
    '- Modules: ${scan['module_count']}',
    '- Risks: ${scan['risk_totals']['total']}',
  ].join('\n');
}

String _moduleMatrixMarkdown(Map<String, dynamic> scan) {
  return [
    '# Module Matrix',
    '',
    '- Module count: ${scan['module_count']}',
    '- Maturity counts: ${jsonEncode(scan['module_maturity_counts'])}',
    '- Verification counts: ${jsonEncode(scan['verification_counts'])}',
    '- Documentation counts: ${jsonEncode(scan['documentation_counts'])}',
  ].join('\n');
}

String _repositoryHealthMarkdown(Map<String, dynamic> scan) {
  return [
    '# Repository Health',
    '',
    '- Working tree: ${scan['working_tree_state']}',
    '- CI status: ${scan['ci_status']}',
    '- Missing paths: ${(_asList(scan['missing_declared_paths'])).length}',
    '- Warnings: ${(_asList(scan['repository_health_warnings'])).length}',
  ].join('\n');
}

String _releaseReadinessMarkdown(Map<String, dynamic> readiness) {
  final reasons = _asList(readiness['reasons']);
  return [
    '# Release Readiness',
    '',
    '- Result: ${readiness['result']}',
    '- Reasons:',
    ...reasons.map((reason) => '  - $reason'),
  ].join('\n');
}

Map<String, dynamic> _evaluateReadinessFromData(
  List<dynamic> modules,
  List<dynamic> risks,
) {
  final reasons = <String>[];
  final openP0 = risks
      .where(
        (risk) =>
            _stringValue(risk, 'severity') == 'P0' &&
            _stringValue(risk, 'status') == 'open',
      )
      .toList();
  if (openP0.isNotEmpty) {
    reasons.add('An open P0 risk exists.');
  }

  final failedVerifications = modules
      .where(
        (module) => _stringValue(module, 'verification_status') == 'failed',
      )
      .toList();
  if (failedVerifications.isNotEmpty) {
    reasons.add('At least one module has failed verification.');
  }

  final missingDocs = modules.where((module) {
    final maturity = _stringValue(module, 'maturity');
    final docs = _asList(module['documentation_paths']);
    return _isFunctionalOrHigher(maturity) && docs.isEmpty;
  }).toList();
  if (missingDocs.isNotEmpty) {
    reasons.add(
      'Some functional-or-higher modules are missing documentation paths.',
    );
  }

  final openP1 = risks
      .where(
        (risk) =>
            _stringValue(risk, 'severity') == 'P1' &&
            _stringValue(risk, 'status') == 'open',
      )
      .toList();
  final result = openP0.isNotEmpty
      ? 'blocked'
      : (failedVerifications.isNotEmpty ||
                missingDocs.isNotEmpty ||
                openP1.isNotEmpty
            ? 'not_ready'
            : 'ready_with_conditions');
  if (openP1.isNotEmpty) {
    reasons.add('One or more open P1 risks remain.');
  }
  if (reasons.isEmpty) {
    reasons.add('All required gates are satisfied.');
  }
  return stableMap(<String, dynamic>{'result': result, 'reasons': reasons});
}

bool _isFunctionalOrHigher(String maturity) {
  const ordered = [
    'functional',
    'alpha',
    'beta',
    'release_candidate',
    'stable',
  ];
  return ordered.contains(maturity);
}

_ValidationResult _validateCanonicalFiles(Directory repoRoot) {
  final errors = <String>[];
  final warnings = <String>[];
  final statusDefinitions = _loadObjectFile(
    repoRoot,
    'project_control/status_definitions.yaml',
  );
  final modules = _loadListFile(
    repoRoot,
    'project_control/module_registry.yaml',
  );
  final risks = _loadListFile(repoRoot, 'project_control/risk_register.yaml');
  final verifications = _loadListFile(
    repoRoot,
    'project_control/verification_registry.yaml',
  );
  final releaseRegistry = _loadListFile(
    repoRoot,
    'project_control/release_registry.yaml',
  );

  if (_stringValue(statusDefinitions, 'schema_version') != '1') {
    errors.add(
      'project_control/status_definitions.yaml has an invalid schema_version.',
    );
  }

  final allowedMaturities = {
    'planned',
    'scaffold',
    'prototype',
    'functional',
    'alpha',
    'beta',
    'release_candidate',
    'stable',
    'parked',
    'deprecated',
  };
  final allowedVerification = {
    'not_checked',
    'failed',
    'partial',
    'passed',
    'passed_with_warnings',
    'stale',
  };
  final allowedDocumentation = {
    'missing',
    'partial',
    'current',
    'stale',
    'conflicting',
  };
  final allowedRiskSeverity = {'P0', 'P1', 'P2', 'P3'};
  final allowedReleaseStatus = {
    'blocked',
    'not_ready',
    'ready_with_conditions',
    'ready',
    'unverified_historical',
  };

  final moduleIds = <String>{};
  for (final module in modules) {
    final id = _stringValue(module, 'id');
    final maturity = _stringValue(module, 'maturity');
    final verificationStatus = _stringValue(module, 'verification_status');
    final documentationStatus = _stringValue(module, 'documentation_status');
    final sourcePaths = _asList(module['source_paths']);
    final documentationPaths = _asList(module['documentation_paths']);
    final testPaths = _asList(module['test_paths']);

    if (id.isEmpty) {
      errors.add('Module record missing id.');
      continue;
    }
    if (!moduleIds.add(id)) {
      errors.add('Duplicate module id: $id');
    }
    if (!allowedMaturities.contains(maturity)) {
      errors.add('Module $id uses invalid maturity $maturity.');
    }
    if (!allowedVerification.contains(verificationStatus)) {
      errors.add(
        'Module $id uses invalid verification status $verificationStatus.',
      );
    }
    if (!allowedDocumentation.contains(documentationStatus)) {
      errors.add(
        'Module $id uses invalid documentation status $documentationStatus.',
      );
    }
    if (_stringValue(module, 'backup_policy').trim().isEmpty) {
      errors.add('Module $id is missing a backup policy.');
    }
    if (_stringValue(module, 'security_level').trim().isEmpty) {
      errors.add('Module $id is missing a security level.');
    }
    if (sourcePaths.isEmpty) {
      errors.add('Module $id is missing source paths.');
    }
    if (_isFunctionalOrHigher(maturity) && documentationPaths.isEmpty) {
      errors.add(
        'Module $id is functional-or-higher but has no documentation paths.',
      );
    }
    if (maturity == 'stable' &&
        verificationStatus != 'passed' &&
        verificationStatus != 'passed_with_warnings') {
      errors.add('Stable module $id must have passing verification.');
    }
    for (final dep in _asList(
      module['dependencies'],
    ).map((value) => value.toString())) {
      if (dep.isEmpty) {
        continue;
      }
      if (!moduleIds.contains(dep) && !_isKnownExternalDependency(dep)) {
        // Defer until all ids are known; this check is repeated after the loop.
        continue;
      }
    }
    if (_isFunctionalOrHigher(maturity) && testPaths.isEmpty) {
      warnings.add('Module $id has no test paths declared.');
    }
  }

  for (final module in modules) {
    final id = _stringValue(module, 'id');
    for (final dep in _asList(
      module['dependencies'],
    ).map((value) => value.toString())) {
      if (dep.isEmpty) {
        continue;
      }
      if (!moduleIds.contains(dep) && !_isKnownExternalDependency(dep)) {
        errors.add(
          'Module $id depends on unknown module or external boundary: $dep',
        );
      }
    }
    for (final sourcePath in _asList(
      module['source_paths'],
    ).map((value) => value.toString())) {
      if (!_pathExists(repoRoot, sourcePath)) {
        errors.add('Module $id references missing source path: $sourcePath');
      }
    }
    for (final docPath in _asList(
      module['documentation_paths'],
    ).map((value) => value.toString())) {
      if (!_pathExists(repoRoot, docPath)) {
        errors.add(
          'Module $id references missing documentation path: $docPath',
        );
      }
    }
    for (final testPath in _asList(
      module['test_paths'],
    ).map((value) => value.toString())) {
      if (!_pathExists(repoRoot, testPath)) {
        errors.add('Module $id references missing test path: $testPath');
      }
    }
  }

  for (final risk in risks) {
    final severity = _stringValue(risk, 'severity');
    if (!allowedRiskSeverity.contains(severity)) {
      errors.add(
        'Risk ${_stringValue(risk, 'risk_id')} has invalid severity $severity.',
      );
    }
  }

  if (releaseRegistry.any(
    (record) => !allowedReleaseStatus.contains(_stringValue(record, 'status')),
  )) {
    errors.add('Release registry contains an unknown release status.');
  }

  for (final verification in verifications) {
    final result = _stringValue(verification, 'result');
    if (result.isEmpty) {
      errors.add(
        'Verification record ${_stringValue(verification, 'verification_id')} is missing a result.',
      );
    }
  }

  final manifest = _loadObjectFile(
    repoRoot,
    'project_control/platform_manifest.yaml',
  );
  if (_stringValue(manifest, 'current_branch').isEmpty ||
      _stringValue(manifest, 'current_commit').isEmpty) {
    errors.add(
      'Platform manifest is missing current branch or current commit.',
    );
  }

  final scanGeneratedFiles = [
    'project_control/generated/current_state.json',
    'project_control/generated/current_state.md',
    'project_control/generated/module_matrix.json',
    'project_control/generated/module_matrix.md',
    'project_control/generated/release_readiness.json',
    'project_control/generated/release_readiness.md',
    'project_control/generated/repository_health.json',
    'project_control/generated/repository_health.md',
    'project_control/generated/previous_scan.json',
  ];
  for (final relative in scanGeneratedFiles) {
    if (!File(p.join(repoRoot.path, relative)).existsSync()) {
      warnings.add('Missing generated file: $relative');
    }
  }

  return _ValidationResult(errors: errors, warnings: warnings);
}

bool _pathExists(Directory repoRoot, String relativePath) {
  return File(p.join(repoRoot.path, relativePath)).existsSync() ||
      Directory(p.join(repoRoot.path, relativePath)).existsSync();
}

bool _isKnownExternalDependency(String name) {
  const known = {
    'git',
    'flutter',
    'dart',
    'speech_to_text',
    'window_manager',
    'tray_manager',
    'path_provider',
    'sqlite',
    'local_database',
    'routing',
    'filesystem',
    'pin entry hardware or keyboard',
    'microphone',
    'audio input',
    'screen capture',
    'desktop windowing',
    'voice hardware',
    'git remote access',
    'repository intelligence bridge',
  };
  return known.contains(name);
}

Map<String, dynamic> stableMap(Map<String, dynamic> input) {
  final keys = input.keys.toList()..sort();
  final result = <String, dynamic>{};
  for (final key in keys) {
    result[key] = _stableValue(input[key]);
  }
  return result;
}

dynamic _stableValue(dynamic value) {
  if (value is Map<String, dynamic>) {
    return stableMap(value);
  }
  if (value is List) {
    return value.map(_stableValue).toList(growable: false);
  }
  return value;
}

Map<String, dynamic> _loadObjectFile(Directory repoRoot, String relativePath) {
  final file = File(p.join(repoRoot.path, relativePath));
  final content = file.readAsStringSync();
  return _asMap(jsonDecode(content));
}

List<dynamic> _loadListFile(Directory repoRoot, String relativePath) {
  final file = File(p.join(repoRoot.path, relativePath));
  final content = file.readAsStringSync();
  return _asList(jsonDecode(content));
}

Future<void> _writeJson(File file, Map<String, dynamic> data) async {
  await file.parent.create(recursive: true);
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(stableMap(data)),
    flush: true,
  );
}

Map<String, int> _countBy(List<dynamic> records, String key) {
  final counts = <String, int>{};
  for (final record in records) {
    final value = _stringValue(record, key);
    counts[value] = (counts[value] ?? 0) + 1;
  }
  return Map<String, int>.fromEntries(
    counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

String _stringValue(dynamic record, String key) {
  if (record is Map) {
    final value = record[key];
    return value == null ? '' : value.toString();
  }
  return '';
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, dynamic value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}

List<String> _listDifference(List<dynamic> left, List<dynamic> right) {
  final rightValues = right.map((value) => value.toString()).toSet();
  return left
      .map((value) => value.toString())
      .where((value) => !rightValues.contains(value))
      .toList(growable: false)
    ..sort();
}

List<dynamic> _asList(dynamic value) {
  if (value is List<dynamic>) {
    return value;
  }
  if (value is List) {
    return value.toList(growable: false);
  }
  return const [];
}

Future<bool> _commandAvailable(String command) async {
  try {
    final result = Platform.isWindows
        ? await Process.run('cmd', ['/c', 'where', command])
        : await Process.run('which', [command]);
    return result.exitCode == 0;
  } catch (_) {
    return false;
  }
}

Future<String> _git(Directory repoRoot, List<String> args) async {
  try {
    final result = await Process.run('git', ['-C', repoRoot.path, ...args]);
    if (result.exitCode == 0) {
      return (result.stdout ?? '').toString().trim();
    }
  } catch (_) {
    // Ignore and return empty output.
  }
  return '';
}

String _gitSync(Directory repoRoot, List<String> args) {
  try {
    final result = Process.runSync('git', ['-C', repoRoot.path, ...args]);
    if (result.exitCode == 0) {
      return (result.stdout ?? '').toString().trim();
    }
  } catch (_) {
    // Ignore and return empty output.
  }
  return '';
}

List<String> _featureDirectories(Directory repoRoot) {
  final dir = Directory(p.join(repoRoot.path, 'lib', 'features'));
  if (!dir.existsSync()) {
    return const [];
  }
  final entries =
      dir
          .listSync()
          .whereType<Directory>()
          .map((entity) => p.relative(entity.path, from: repoRoot.path))
          .toList(growable: false)
        ..sort();
  return entries;
}

List<String> _findFiles(
  Directory repoRoot,
  List<String> roots,
  String extension,
) {
  final results = <String>[];
  for (final root in roots) {
    final dir = Directory(p.join(repoRoot.path, root));
    if (!dir.existsSync()) {
      continue;
    }
    for (final entity in dir.listSync(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.toLowerCase().endsWith(extension)) {
        results.add(p.relative(entity.path, from: repoRoot.path));
      }
    }
  }
  results.sort();
  return results;
}

List<String> _missingDeclaredPaths(Directory repoRoot, List<dynamic> modules) {
  final missing = <String>[];
  for (final module in modules) {
    final id = _stringValue(module, 'id');
    for (final relative in [
      ..._asList(module['source_paths']).map((value) => value.toString()),
      ..._asList(
        module['documentation_paths'],
      ).map((value) => value.toString()),
      ..._asList(module['test_paths']).map((value) => value.toString()),
    ]) {
      if (relative.isEmpty) {
        continue;
      }
      if (!_pathExists(repoRoot, relative)) {
        missing.add('$id:$relative');
      }
    }
  }
  missing.sort();
  return missing;
}

List<String> _versionContradictions(Map<String, dynamic> manifest) {
  final version = _stringValue(manifest, 'application_version');
  final contradictions = <String>[];
  if (version.isEmpty) {
    contradictions.add('Application version missing.');
  }
  return contradictions;
}

String _ciStatus(Directory repoRoot) {
  final workflows = Directory(p.join(repoRoot.path, '.github', 'workflows'));
  return workflows.existsSync() ? 'present' : 'missing';
}

dynamic _databaseSchemaVersion(Directory repoRoot) {
  final database = File(
    p.join(repoRoot.path, 'lib', 'core', 'database', 'app_database.dart'),
  );
  if (!database.existsSync()) {
    return null;
  }
  final content = database.readAsStringSync();
  final match = RegExp(r'schemaVersion\s*=>\s*(\d+)').firstMatch(content);
  return match?.group(1);
}

List<String> _repositoryHealthWarnings(
  Directory repoRoot,
  List<dynamic> modules,
  List<dynamic> risks,
) {
  final warnings = <String>[];
  if (_gitSync(repoRoot, ['status', '--short']).trim().isNotEmpty) {
    warnings.add('Working tree is dirty.');
  }
  if (_ciStatus(repoRoot) == 'missing') {
    warnings.add('No GitHub workflows were detected.');
  }
  if (risks.any(
    (risk) =>
        _stringValue(risk, 'severity') == 'P0' &&
        _stringValue(risk, 'status') == 'open',
  )) {
    warnings.add('Open P0 risk remains.');
  }
  if (modules.any(
    (module) => _stringValue(module, 'documentation_status') == 'missing',
  )) {
    warnings.add('Some modules lack documentation.');
  }
  return warnings;
}

List<String> _recommendedNextActions(
  Directory repoRoot,
  List<dynamic> modules,
  List<dynamic> risks, {
  required Map<String, dynamic> readinessHint,
}) {
  final actions = <String>[];
  if (readinessHint['result'] != 'ready') {
    actions.add('Resolve readiness blockers before a release attempt.');
  }
  if (modules.any(
    (module) => _stringValue(module, 'documentation_status') == 'partial',
  )) {
    actions.add('Fill in the highest-value missing module documentation.');
  }
  if (risks.any((risk) => _stringValue(risk, 'status') == 'open')) {
    actions.add('Track open risks in the canonical risk register.');
  }
  if (_ciStatus(repoRoot) == 'missing') {
    actions.add('Add or verify CI workflows.');
  }
  return actions;
}

class _ValidationResult {
  const _ValidationResult({required this.errors, required this.warnings});
  final List<String> errors;
  final List<String> warnings;
}
