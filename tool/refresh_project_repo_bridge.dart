// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:new_earth_command_dashboard/features/project_intelligence/data/project_repo_bridge_models.dart';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

Future<void> main(List<String> args) async {
  final options = _CliOptions.parse(args);
  final dbFile = _resolveDatabaseFile(options.databasePath);
  if (dbFile == null) {
    stderr.writeln(
      'Could not find the Dashboard database. Pass --db <path> to the local '
      'new_earth_command_dashboard.db file.',
    );
    exitCode = 2;
    return;
  }

  final workspaceRoot = options.workspaceRoot ?? Directory.current;
  final database = sqlite3.open(dbFile.path);

  try {
    final registryEntries = await _loadRepoRegistryEntries(workspaceRoot);
    final repoMap = await _loadProjectRepoMap(workspaceRoot);
    final projects = _readProjects(database);
    final tasks = _readTasks(database);
    final tasksByProjectId = _tasksByProjectId(tasks);
    final repoPathOverrides = <String, String>{};
    final snapshotsByRepoId = <String, RepoSnapshot>{};

    for (final entry in registryEntries) {
      final overridePath = _repoPathOverrideForEntry(
        entry,
        workspaceRoot: workspaceRoot,
      );
      if (overridePath != null) {
        repoPathOverrides[entry.id] = overridePath;
      }
    }

    for (final entry in registryEntries) {
      final snapshot = await _scanRepoEntry(
        entry.copyWith(repoPath: repoPathOverrides[entry.id]),
      );
      snapshotsByRepoId[entry.id] = snapshot;
      await _writeSnapshot(workspaceRoot, entry.id, snapshot);
    }

    final mergedAt = DateTime.now().toUtc().toIso8601String();
    final unifiedProjects = <UnifiedProjectRecord>[];

    for (final project in projects) {
      final repoEntry = _resolveRepoEntryForProject(
        project: project,
        repoMap: repoMap,
        registryEntries: registryEntries,
      );
      final repoSnapshot = repoEntry == null
          ? null
          : snapshotsByRepoId[repoEntry.id];
      final projectTasks =
          tasksByProjectId[project.projectId] ?? const <UnifiedTaskRecord>[];
      final nextActions = _deriveNextActions(
        project: project,
        tasks: projectTasks,
        repoSnapshot: repoSnapshot,
      );
      final codexHandoffReady = _isCodexHandoffReady(
        repoSnapshot,
        projectTasks,
      );

      unifiedProjects.add(
        UnifiedProjectRecord(
          projectId: project.projectId,
          name: project.name,
          dashboardStatus: project.status,
          dashboardDescription:
              project.shortDescription?.trim().isNotEmpty == true
              ? project.shortDescription
              : project.longDescription,
          dashboardTasks: projectTasks,
          repoLinked: repoSnapshot?.exists == true,
          repoId: repoEntry?.id,
          repoPath: repoSnapshot?.repoPath,
          omegaPath: repoSnapshot?.omegaPath,
          currentPhase:
              repoSnapshot?.currentPhase ??
              project.currentMilestone ??
              project.nextAction,
          latestRepoStatus: repoSnapshot,
          nextActions: nextActions,
          codexHandoffReady: codexHandoffReady,
          lastMergedAt: mergedAt,
        ),
      );
    }

    final bundle = ProjectRepoBridgeBundle(
      mergedAt: mergedAt,
      projects: unifiedProjects,
      outputPath: _unifiedProjectsFile(workspaceRoot).path,
    );
    await _writeUnifiedProjects(workspaceRoot, bundle);

    stdout.writeln('Wrote: ${bundle.outputPath}');
    stdout.writeln('Merged at: ${bundle.mergedAt}');
    stdout.writeln('Projects: ${bundle.projects.length}');
  } finally {
    database.close();
  }
}

List<_DashboardProjectRow> _readProjects(Database database) {
  final rows = database.select('''
    SELECT
      project_id,
      name,
      short_description,
      long_description,
      status,
      current_milestone,
      next_action
    FROM projects
    WHERE is_archived = 0
    ORDER BY name COLLATE NOCASE ASC
  ''');

  return rows
      .map(
        (row) => _DashboardProjectRow(
          projectId: _text(row, 'project_id'),
          name: _text(row, 'name'),
          shortDescription: _nullableText(row, 'short_description'),
          longDescription: _nullableText(row, 'long_description'),
          status: _text(row, 'status', fallback: 'Idea'),
          currentMilestone: _nullableText(row, 'current_milestone'),
          nextAction: _nullableText(row, 'next_action'),
        ),
      )
      .toList(growable: false);
}

List<_DashboardTaskRow> _readTasks(Database database) {
  final rows = database.select('''
    SELECT task_id, project_id, title, status, priority
    FROM tasks
    WHERE is_archived = 0
    ORDER BY created_at DESC
  ''');

  return rows
      .map(
        (row) => _DashboardTaskRow(
          taskId: _text(row, 'task_id'),
          projectId: _nullableText(row, 'project_id'),
          title: _text(row, 'title'),
          status: _text(row, 'status', fallback: 'Inbox'),
          priority: _text(row, 'priority', fallback: 'Medium'),
        ),
      )
      .toList(growable: false);
}

Map<String, List<UnifiedTaskRecord>> _tasksByProjectId(
  List<_DashboardTaskRow> tasks,
) {
  final grouped = <String, List<UnifiedTaskRecord>>{};
  for (final task in tasks) {
    final projectId = task.projectId;
    if (projectId == null || projectId.trim().isEmpty) {
      continue;
    }
    grouped
        .putIfAbsent(projectId, () => <UnifiedTaskRecord>[])
        .add(
          UnifiedTaskRecord(
            id: task.taskId,
            title: task.title,
            status: task.status,
            projectId: task.projectId,
            priority: task.priority,
          ),
        );
  }
  return grouped;
}

List<String> _deriveNextActions({
  required _DashboardProjectRow project,
  required List<UnifiedTaskRecord> tasks,
  required RepoSnapshot? repoSnapshot,
}) {
  final actions = <String>[];
  final nextAction = project.nextAction?.trim();
  if (nextAction != null && nextAction.isNotEmpty) {
    actions.add(nextAction);
  }

  final activeTasks = tasks.where((task) {
    final status = task.status.toLowerCase().trim();
    return status != 'done' && status != 'parked' && status != 'blocked';
  });

  for (final task in activeTasks.take(3)) {
    actions.add(task.title);
  }

  if (repoSnapshot == null || !repoSnapshot.exists) {
    actions.add('Link the repo or confirm the path in repo_registry.json.');
  } else {
    if (repoSnapshot.docsFound.isEmpty) {
      actions.add('Add project docs to the repo.');
    }
    if (repoSnapshot.todoCount > 0) {
      actions.add('Review TODO/FIXME markers in the repo.');
    }
    if (repoSnapshot.dirtyFiles.isNotEmpty) {
      actions.add('Review uncommitted repo changes.');
    }
  }

  return actions.toSet().toList(growable: false);
}

bool _isCodexHandoffReady(
  RepoSnapshot? repoSnapshot,
  List<UnifiedTaskRecord> tasks,
) {
  if (repoSnapshot == null || !repoSnapshot.exists || !repoSnapshot.isGitRepo) {
    return false;
  }

  final hasActiveTasks = tasks.any((task) {
    final status = task.status.toLowerCase().trim();
    return status != 'done' && status != 'parked';
  });

  return repoSnapshot.dirtyFiles.isEmpty &&
      repoSnapshot.docsFound.isNotEmpty &&
      hasActiveTasks;
}

String _text(dynamic row, String column, {String fallback = ''}) {
  final value = row[column];
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    return fallback;
  }
  return text;
}

String? _nullableText(dynamic row, String column) {
  final value = row[column];
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  return text;
}

Future<List<_RepoRegistryEntry>> _loadRepoRegistryEntries(
  Directory workspaceRoot,
) async {
  final actual = File(
    path.join(
      workspaceRoot.path,
      'modules/project_repo_bridge/config/repo_registry.json',
    ),
  );
  final example = File(
    path.join(
      workspaceRoot.path,
      'modules/project_repo_bridge/config/repo_registry.example.json',
    ),
  );
  final content = await _readFirstExistingFile([actual, example]);
  if (content == null) {
    return const <_RepoRegistryEntry>[];
  }

  final jsonMap = jsonDecode(content) as Map<String, dynamic>;
  final repos = jsonMap['repos'] as List<dynamic>? ?? const [];
  return repos
      .whereType<Map<String, dynamic>>()
      .map(_RepoRegistryEntry.fromJson)
      .toList(growable: false);
}

Future<Map<String, String>> _loadProjectRepoMap(Directory workspaceRoot) async {
  final actual = File(
    path.join(
      workspaceRoot.path,
      'modules/project_repo_bridge/config/project_repo_map.json',
    ),
  );
  final example = File(
    path.join(
      workspaceRoot.path,
      'modules/project_repo_bridge/config/project_repo_map.example.json',
    ),
  );
  final content = await _readFirstExistingFile([actual, example]);
  if (content == null) {
    return const <String, String>{};
  }

  final jsonMap = jsonDecode(content) as Map<String, dynamic>;
  final mappings = jsonMap['mappings'] as List<dynamic>? ?? const [];
  final result = <String, String>{};
  for (final entry in mappings.whereType<Map<String, dynamic>>()) {
    final dashboardProjectId = entry['dashboard_project_id']?.toString() ?? '';
    final repoId = entry['repo_id']?.toString() ?? '';
    if (dashboardProjectId.isNotEmpty && repoId.isNotEmpty) {
      result[dashboardProjectId] = repoId;
    }
  }
  return result;
}

Future<String?> _readFirstExistingFile(List<File> files) async {
  for (final file in files) {
    if (await file.exists()) {
      return file.readAsString();
    }
  }
  return null;
}

_RepoRegistryEntry? _resolveRepoEntryForProject({
  required _DashboardProjectRow project,
  required Map<String, String> repoMap,
  required List<_RepoRegistryEntry> registryEntries,
}) {
  final mappedRepoId = repoMap[project.projectId];
  if (mappedRepoId != null && mappedRepoId.trim().isNotEmpty) {
    final mapped =
        _findRepoEntryById(mappedRepoId.trim(), registryEntries) ??
        _findRepoEntryByDashboardProjectId(
          mappedRepoId.trim(),
          registryEntries,
        ) ??
        _findRepoEntryByKey(mappedRepoId.trim(), registryEntries);
    if (mapped != null) {
      return mapped;
    }
  }

  final directMatch =
      _findRepoEntryByDashboardProjectId(project.projectId, registryEntries) ??
      _findRepoEntryByKey(project.projectId, registryEntries);
  if (directMatch != null) {
    return directMatch;
  }

  return _findFuzzyRepoEntry(
    lookupKeys: _projectLookupKeys(project),
    registryEntries: registryEntries,
  );
}

_RepoRegistryEntry? _findRepoEntryById(
  String repoId,
  List<_RepoRegistryEntry> registryEntries,
) {
  final normalized = _normalizeKey(repoId);
  for (final entry in registryEntries) {
    if (_normalizeKey(entry.id) == normalized) {
      return entry;
    }
  }
  return null;
}

_RepoRegistryEntry? _findRepoEntryByDashboardProjectId(
  String dashboardProjectId,
  List<_RepoRegistryEntry> registryEntries,
) {
  final normalized = _normalizeKey(dashboardProjectId);
  for (final entry in registryEntries) {
    if (_normalizeKey(entry.dashboardProjectId) == normalized) {
      return entry;
    }
  }
  return null;
}

_RepoRegistryEntry? _findRepoEntryByKey(
  String lookupKey,
  List<_RepoRegistryEntry> registryEntries,
) {
  final normalizedLookupKey = _normalizeKey(lookupKey);
  for (final entry in registryEntries) {
    final keys = <String>[
      entry.id,
      entry.dashboardProjectId ?? '',
      entry.name,
    ].map(_normalizeKey).where((value) => value.isNotEmpty).toList();
    if (keys.contains(normalizedLookupKey)) {
      return entry;
    }
  }
  return null;
}

_RepoRegistryEntry? _findFuzzyRepoEntry({
  required List<String> lookupKeys,
  required List<_RepoRegistryEntry> registryEntries,
}) {
  _RepoRegistryEntry? bestMatch;
  var bestScore = 0.0;
  for (final entry in registryEntries) {
    final score = _highestSimilarity(lookupKeys, <String>[
      entry.id,
      entry.dashboardProjectId ?? '',
      entry.name,
    ]);
    if (score > bestScore) {
      bestScore = score;
      bestMatch = entry;
    }
  }

  return bestScore >= 0.62 ? bestMatch : null;
}

List<String> _projectLookupKeys(_DashboardProjectRow project) {
  return <String>[
        project.projectId,
        project.name,
        project.shortDescription ?? '',
        project.currentMilestone ?? '',
        project.nextAction ?? '',
      ]
      .map(_normalizeKey)
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
}

double _highestSimilarity(List<String> leftKeys, List<String> rightKeys) {
  var highest = 0.0;
  for (final left in leftKeys) {
    for (final right in rightKeys) {
      final score = _similarityScore(left, right);
      if (score > highest) {
        highest = score;
      }
    }
  }
  return highest;
}

double _similarityScore(String left, String right) {
  if (left.isEmpty || right.isEmpty) {
    return 0.0;
  }
  if (left == right) {
    return 1.0;
  }
  if (left.contains(right) || right.contains(left)) {
    final shorterLength = left.length < right.length
        ? left.length
        : right.length;
    final longerLength = left.length > right.length
        ? left.length
        : right.length;
    return shorterLength / longerLength;
  }

  final leftTokens = _tokenize(left);
  final rightTokens = _tokenize(right);
  if (leftTokens.isEmpty || rightTokens.isEmpty) {
    return 0.0;
  }

  final intersection = leftTokens.intersection(rightTokens).length;
  final union = leftTokens.union(rightTokens).length;
  if (union == 0) {
    return 0.0;
  }

  return intersection / union;
}

Set<String> _tokenize(String text) {
  return text
      .split(RegExp(r'[^a-z0-9]+'))
      .where((token) => token.isNotEmpty)
      .map(_normalizeKey)
      .where((token) => token.isNotEmpty)
      .toSet();
}

String _normalizeKey(String? value) {
  return (value ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
}

String? _repoPathOverrideForEntry(
  _RepoRegistryEntry entry, {
  required Directory workspaceRoot,
}) {
  if (entry.id != 'new_earth_dashboard') {
    return null;
  }

  final registryPath = entry.repoPath.trim();
  if (registryPath.isNotEmpty && Directory(registryPath).existsSync()) {
    return null;
  }

  final localDashboardRoot = _findCurrentDashboardRepoRoot(workspaceRoot);
  return localDashboardRoot?.path;
}

Directory? _findCurrentDashboardRepoRoot(Directory workspaceRoot) {
  var current = workspaceRoot;
  while (true) {
    if (File(path.join(current.path, 'pubspec.yaml')).existsSync()) {
      return current;
    }

    final parent = current.parent;
    if (parent.path == current.path) {
      break;
    }
    current = parent;
  }

  return null;
}

Future<RepoSnapshot> _scanRepoEntry(
  _RepoRegistryEntry entry, {
  DateTime Function()? now,
}) async {
  final timestamp = (now ?? DateTime.now).call().toUtc().toIso8601String();
  final repoDirectory = Directory(entry.repoPath);
  final exists = repoDirectory.existsSync();
  final scanWarnings = <String>[];

  if (!exists) {
    return RepoSnapshot(
      id: entry.id,
      name: entry.name,
      repoPath: entry.repoPath,
      dashboardProjectId: entry.dashboardProjectId,
      omegaPath: entry.omegaPath,
      status: entry.status,
      type: entry.type,
      currentPhase: entry.currentPhase,
      exists: false,
      isGitRepo: false,
      tags: const <String>[],
      dirtyFiles: const <String>[],
      recentCommits: const <String>[],
      docsFound: const <String>[],
      todoMarkers: const <RepoTodoMarker>[],
      scanWarnings: <String>['Repository path not found.'],
      scannedAt: timestamp,
    );
  }

  final gitStatus = await _runGit(entry.repoPath, <String>[
    'status',
    '--short',
  ]);
  final gitBranch = await _runGit(entry.repoPath, <String>[
    'branch',
    '--show-current',
  ]);
  final gitLatestCommit = await _runGit(entry.repoPath, <String>[
    'log',
    '-1',
    '--pretty=format:%H|%cI|%s',
  ]);
  final gitRecentCommits = await _runGit(entry.repoPath, <String>[
    'log',
    '-5',
    '--pretty=format:%h %s',
  ]);
  final gitTags = await _runGit(entry.repoPath, <String>[
    'tag',
    '--points-at',
    'HEAD',
  ]);
  final isGitRepo =
      (await _runGit(entry.repoPath, <String>[
        'rev-parse',
        '--is-inside-work-tree',
      ])).trim().toLowerCase() ==
      'true';

  final dirtyFiles = _extractDirtyFiles(gitStatus);
  final recentCommits = _splitLines(gitRecentCommits);
  final tags = _splitLines(gitTags);
  final latestCommitParts = _splitCommitLine(gitLatestCommit);
  final docsFound = await _discoverDocs(repoDirectory);
  final todoMarkers = await _discoverTodoMarkers(repoDirectory);

  if (gitStatus.trim().isEmpty && !isGitRepo) {
    scanWarnings.add(
      'The repository does not appear to be a Git working tree.',
    );
  }

  return RepoSnapshot(
    id: entry.id,
    name: entry.name,
    repoPath: entry.repoPath,
    dashboardProjectId: entry.dashboardProjectId,
    omegaPath: entry.omegaPath,
    status: entry.status,
    type: entry.type,
    currentPhase: entry.currentPhase,
    exists: true,
    isGitRepo: isGitRepo,
    branch: gitBranch.trim().isEmpty ? null : gitBranch.trim(),
    latestCommit: latestCommitParts.$1,
    latestCommitDate: latestCommitParts.$2,
    tags: tags,
    dirtyFiles: dirtyFiles,
    recentCommits: recentCommits,
    docsFound: docsFound,
    todoMarkers: todoMarkers,
    scanWarnings: scanWarnings,
    scannedAt: timestamp,
  );
}

Future<String> _runGit(String repoPath, List<String> args) async {
  try {
    final result = await Process.run('git', <String>[
      '-C',
      repoPath,
      ...args,
    ], runInShell: true);
    if (result.exitCode != 0) {
      return '';
    }
    return (result.stdout ?? '').toString().trim();
  } catch (_) {
    return '';
  }
}

List<String> _extractDirtyFiles(String gitStatus) {
  if (gitStatus.trim().isEmpty) {
    return const <String>[];
  }

  final files = <String>[];
  for (final line in _splitLines(gitStatus)) {
    if (line.length < 3) {
      continue;
    }
    final fileName = line.substring(3).trim();
    if (fileName.isNotEmpty) {
      files.add(fileName);
    }
  }
  return files;
}

List<String> _splitLines(String text) {
  return text
      .split(RegExp(r'[\r\n]+'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);
}

(String?, String?) _splitCommitLine(String gitLatestCommit) {
  if (gitLatestCommit.trim().isEmpty) {
    return (null, null);
  }

  final parts = gitLatestCommit.split('|');
  if (parts.length < 3) {
    return (gitLatestCommit.trim(), null);
  }

  return (parts[0].trim(), parts[1].trim());
}

Future<List<String>> _discoverDocs(Directory repoDirectory) async {
  final docs = <String>[];
  await for (final entity in repoDirectory.list(
    recursive: true,
    followLinks: false,
  )) {
    if (entity is! File) {
      continue;
    }
    final relative = path.relative(entity.path, from: repoDirectory.path);
    if (_shouldIgnorePath(relative)) {
      continue;
    }
    final lower = relative.toLowerCase();
    final fileName = path.basename(lower);
    if (fileName.startsWith('readme') ||
        lower.contains(
          '${Platform.pathSeparator}docs${Platform.pathSeparator}',
        ) ||
        lower.endsWith('.md') ||
        lower.endsWith('.markdown')) {
      docs.add(relative);
    }
    if (docs.length >= 50) {
      break;
    }
  }
  return docs.toSet().toList(growable: false);
}

Future<List<RepoTodoMarker>> _discoverTodoMarkers(
  Directory repoDirectory,
) async {
  final markers = <RepoTodoMarker>[];
  const textExtensions = {
    '.dart',
    '.md',
    '.markdown',
    '.ts',
    '.tsx',
    '.js',
    '.json',
    '.yaml',
    '.yml',
    '.py',
    '.sh',
    '.ps1',
    '.txt',
    '.html',
    '.css',
    '.scss',
    '.xml',
  };
  final todoPattern = RegExp(r'\b(TODO|FIXME)\b', caseSensitive: false);

  await for (final entity in repoDirectory.list(
    recursive: true,
    followLinks: false,
  )) {
    if (entity is! File) {
      continue;
    }

    final relative = path.relative(entity.path, from: repoDirectory.path);
    if (_shouldIgnorePath(relative)) {
      continue;
    }
    final extension = path.extension(relative).toLowerCase();
    if (!textExtensions.contains(extension)) {
      continue;
    }

    try {
      final lines = await entity.readAsLines();
      for (var index = 0; index < lines.length; index++) {
        final line = lines[index];
        if (!todoPattern.hasMatch(line)) {
          continue;
        }

        markers.add(
          RepoTodoMarker(file: relative, line: index + 1, text: line.trim()),
        );

        if (markers.length >= 100) {
          return markers;
        }
      }
    } catch (_) {
      continue;
    }
  }

  return markers;
}

bool _shouldIgnorePath(String relativePath) {
  final normalized = relativePath.replaceAll('\\', '/').toLowerCase();
  const ignoredSegments = [
    '/.git/',
    '/.dart_tool/',
    '/build/',
    '/dist/',
    '/node_modules/',
    '/.idea/',
    '/.vscode/',
    '/coverage/',
    '/.venv/',
    '/venv/',
    '/__pycache__/',
    '/.next/',
    '/.turbo/',
  ];

  return ignoredSegments.any((segment) => normalized.contains(segment));
}

Future<void> _writeSnapshot(
  Directory workspaceRoot,
  String repoId,
  RepoSnapshot snapshot,
) async {
  final snapshotFile = File(
    path.join(
      workspaceRoot.path,
      'modules/project_repo_bridge/data/repo_snapshots/$repoId.json',
    ),
  );
  await snapshotFile.parent.create(recursive: true);
  await snapshotFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(snapshot.toJson()),
    flush: true,
  );
}

Future<void> _writeUnifiedProjects(
  Directory workspaceRoot,
  ProjectRepoBridgeBundle bundle,
) async {
  final outputFile = _unifiedProjectsFile(workspaceRoot);
  await outputFile.parent.create(recursive: true);
  await outputFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(bundle.toJson()),
    flush: true,
  );
}

File _unifiedProjectsFile(Directory workspaceRoot) {
  return File(
    path.join(
      workspaceRoot.path,
      'modules/project_repo_bridge/data/unified/unified_projects.json',
    ),
  );
}

File? _resolveDatabaseFile(String? databasePath) {
  if (databasePath != null && databasePath.trim().isNotEmpty) {
    final file = File(databasePath.trim());
    if (file.existsSync()) {
      return file;
    }
  }

  final userProfile = Platform.environment['USERPROFILE'];
  final candidates = <String>[
    if (userProfile != null && userProfile.isNotEmpty) ...[
      '$userProfile\\OneDrive\\Documents\\new_earth_command_dashboard.db',
      '$userProfile\\Documents\\new_earth_command_dashboard.db',
    ],
  ];

  for (final candidatePath in candidates) {
    final file = File(candidatePath);
    if (file.existsSync()) {
      return file;
    }
  }

  return null;
}

class _CliOptions {
  const _CliOptions({required this.databasePath, required this.workspaceRoot});

  final String? databasePath;
  final Directory? workspaceRoot;

  factory _CliOptions.parse(List<String> args) {
    String? databasePath;
    Directory? workspaceRoot;

    for (var index = 0; index < args.length; index++) {
      final arg = args[index];
      if (arg == '--db' && index + 1 < args.length) {
        databasePath = args[++index];
      } else if (arg == '--workspace-root' && index + 1 < args.length) {
        workspaceRoot = Directory(args[++index]);
      }
    }

    return _CliOptions(
      databasePath: databasePath,
      workspaceRoot: workspaceRoot,
    );
  }
}

class _DashboardProjectRow {
  const _DashboardProjectRow({
    required this.projectId,
    required this.name,
    required this.shortDescription,
    required this.longDescription,
    required this.status,
    required this.currentMilestone,
    required this.nextAction,
  });

  final String projectId;
  final String name;
  final String? shortDescription;
  final String? longDescription;
  final String status;
  final String? currentMilestone;
  final String? nextAction;
}

class _DashboardTaskRow {
  const _DashboardTaskRow({
    required this.taskId,
    required this.projectId,
    required this.title,
    required this.status,
    required this.priority,
  });

  final String taskId;
  final String? projectId;
  final String title;
  final String status;
  final String priority;
}

class _RepoRegistryEntry {
  const _RepoRegistryEntry({
    required this.id,
    required this.name,
    required this.repoPath,
    this.dashboardProjectId,
    this.omegaPath,
    this.status,
    this.type,
    this.currentPhase,
  });

  final String id;
  final String name;
  final String repoPath;
  final String? dashboardProjectId;
  final String? omegaPath;
  final String? status;
  final String? type;
  final String? currentPhase;

  _RepoRegistryEntry copyWith({String? repoPath}) {
    return _RepoRegistryEntry(
      id: id,
      name: name,
      repoPath: repoPath ?? this.repoPath,
      dashboardProjectId: dashboardProjectId,
      omegaPath: omegaPath,
      status: status,
      type: type,
      currentPhase: currentPhase,
    );
  }

  factory _RepoRegistryEntry.fromJson(Map<String, dynamic> json) {
    return _RepoRegistryEntry(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      repoPath: json['repo_path']?.toString() ?? '',
      dashboardProjectId: json['dashboard_project_id']?.toString(),
      omegaPath: json['omega_path']?.toString(),
      status: json['status']?.toString(),
      type: json['type']?.toString(),
      currentPhase: json['current_phase']?.toString(),
    );
  }
}
