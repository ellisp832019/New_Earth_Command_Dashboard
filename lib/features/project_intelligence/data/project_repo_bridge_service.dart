import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../../../core/database/app_database.dart';
import '../../../features/projects/data/project_repository.dart';
import '../../../features/tasks/data/task_repository.dart';
import 'dashboard_project_adapter.dart';
import 'dashboard_task_adapter.dart';
import 'project_repo_bridge_models.dart';
import 'repo_snapshot_adapter.dart';

class ProjectRepoBridgeService {
  ProjectRepoBridgeService({
    required ProjectRepository projectRepository,
    required TaskRepository taskRepository,
    Directory? workingDirectory,
  }) : _projectRepository = projectRepository,
       _taskRepository = taskRepository,
       _workingDirectory = workingDirectory ?? Directory.current;

  final ProjectRepository _projectRepository;
  final TaskRepository _taskRepository;
  final Directory _workingDirectory;

  final DashboardProjectAdapter _projectAdapter =
      const DashboardProjectAdapter();
  final DashboardTaskAdapter _taskAdapter = const DashboardTaskAdapter();
  final RepoSnapshotAdapter _snapshotAdapter = const RepoSnapshotAdapter();

  Future<ProjectRepoBridgeBundle> refreshBundle() async {
    final mergedAt = DateTime.now().toUtc().toIso8601String();
    final projects = await _projectRepository.getProjects();
    final tasks = await _taskRepository.getActiveTasks();
    final registryEntries = await _loadRepoRegistryEntries();
    final repoMap = await _loadProjectRepoMap();
    final tasksByProjectId = _tasksByProjectId(tasks);
    final snapshotsByRepoId = <String, RepoSnapshot>{};
    final repoPathOverrides = <String, String>{};

    for (final entry in registryEntries) {
      final overridePath = _repoPathOverrideForEntry(entry);
      if (overridePath != null) {
        repoPathOverrides[entry.id] = overridePath;
      }
    }

    for (final entry in registryEntries) {
      final snapshot = await _scanRepoEntry(
        entry.copyWith(repoPath: repoPathOverrides[entry.id]),
      );
      snapshotsByRepoId[entry.id] = snapshot;
      await _writeSnapshot(entry.id, snapshot);
    }

    final unifiedProjects = <UnifiedProjectRecord>[];
    for (final project in projects) {
      final repoEntry = _resolveRepoEntryForProject(
        project: project,
        repoMap: repoMap,
        registryEntries: registryEntries,
      );
      final repoId = repoEntry?.id;
      final repoSnapshot = repoId == null ? null : snapshotsByRepoId[repoId];
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
        _projectAdapter.fromProject(
          project: project,
          dashboardTasks: projectTasks,
          repoSnapshot: repoSnapshot,
          repoId: repoEntry?.id,
          mergedAt: mergedAt,
          nextActions: nextActions,
          codexHandoffReady: codexHandoffReady,
        ),
      );
    }

    final outputPath = await _writeUnifiedProjects(mergedAt, unifiedProjects);
    return ProjectRepoBridgeBundle(
      mergedAt: mergedAt,
      projects: unifiedProjects,
      outputPath: outputPath,
    );
  }

  Future<ProjectRepoBridgeBundle?> loadLatestBundle() async {
    final outputFile = _unifiedProjectsFile();
    if (!await outputFile.exists()) {
      return null;
    }

    final content = await outputFile.readAsString();
    final jsonMap = jsonDecode(content) as Map<String, dynamic>;
    final mergedAt = jsonMap['merged_at']?.toString() ?? '';
    final projects = (jsonMap['projects'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((project) => _projectFromJson(project, mergedAt))
        .toList(growable: false);
    return ProjectRepoBridgeBundle(
      mergedAt: mergedAt,
      projects: projects,
      outputPath: outputFile.path,
    );
  }

  Future<void> openFile(String filePath) async {
    if (filePath.isEmpty) {
      return;
    }

    if (Platform.isWindows) {
      await Process.start('explorer.exe', <String>[filePath]);
      return;
    }

    if (Platform.isMacOS) {
      await Process.start('open', <String>[filePath]);
      return;
    }

    await Process.start('xdg-open', <String>[filePath]);
  }

  Future<void> openFolder(String folderPath) async {
    await openFile(folderPath);
  }

  Directory moduleRootDirectory() {
    final root = _findModuleRoot();
    return root;
  }

  Directory _findModuleRoot() {
    var current = _workingDirectory;
    while (true) {
      final candidate = Directory(
        path.join(current.path, 'modules', 'project_repo_bridge'),
      );
      if (candidate.existsSync()) {
        return candidate;
      }

      final parent = current.parent;
      if (parent.path == current.path) {
        break;
      }
      current = parent;
    }

    return Directory(
      path.join(_workingDirectory.path, 'modules', 'project_repo_bridge'),
    );
  }

  File _unifiedProjectsFile() {
    final moduleRoot = moduleRootDirectory();
    return File(
      path.join(moduleRoot.path, 'data', 'unified', 'unified_projects.json'),
    );
  }

  Future<String> _writeUnifiedProjects(
    String mergedAt,
    List<UnifiedProjectRecord> projects,
  ) async {
    final outputFile = _unifiedProjectsFile();
    await outputFile.parent.create(recursive: true);
    final bundle = ProjectRepoBridgeBundle(
      mergedAt: mergedAt,
      projects: projects,
      outputPath: outputFile.path,
    );
    await outputFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(bundle.toJson()),
      flush: true,
    );
    return outputFile.path;
  }

  Future<void> _writeSnapshot(String repoId, RepoSnapshot snapshot) async {
    final moduleRoot = moduleRootDirectory();
    final snapshotFile = File(
      path.join(moduleRoot.path, 'data', 'repo_snapshots', '$repoId.json'),
    );
    await snapshotFile.parent.create(recursive: true);
    await snapshotFile.writeAsString(
      const JsonEncoder.withIndent(
        '  ',
      ).convert(_snapshotAdapter.toJson(snapshot)),
      flush: true,
    );
  }

  Future<List<_RepoRegistryEntry>> _loadRepoRegistryEntries() async {
    final moduleRoot = moduleRootDirectory();
    final actual = File(
      path.join(moduleRoot.path, 'config', 'repo_registry.json'),
    );
    final example = File(
      path.join(moduleRoot.path, 'config', 'repo_registry.example.json'),
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

  Future<Map<String, String>> _loadProjectRepoMap() async {
    final moduleRoot = moduleRootDirectory();
    final actual = File(
      path.join(moduleRoot.path, 'config', 'project_repo_map.json'),
    );
    final example = File(
      path.join(moduleRoot.path, 'config', 'project_repo_map.example.json'),
    );
    final content = await _readFirstExistingFile([actual, example]);
    if (content == null) {
      return const <String, String>{};
    }

    final jsonMap = jsonDecode(content) as Map<String, dynamic>;
    final mappings = jsonMap['mappings'] as List<dynamic>? ?? const [];
    final result = <String, String>{};
    for (final entry in mappings.whereType<Map<String, dynamic>>()) {
      final dashboardProjectId =
          entry['dashboard_project_id']?.toString() ?? '';
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

  Map<String, List<UnifiedTaskRecord>> _tasksByProjectId(List<Task> tasks) {
    final grouped = <String, List<UnifiedTaskRecord>>{};
    for (final task in tasks) {
      final projectId = task.projectId;
      if (projectId == null || projectId.trim().isEmpty) {
        continue;
      }

      grouped
          .putIfAbsent(projectId, () => <UnifiedTaskRecord>[])
          .add(_taskAdapter.fromTask(task));
    }

    return grouped;
  }

  _RepoRegistryEntry? _resolveRepoEntryForProject({
    required Project project,
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
        _findRepoEntryByDashboardProjectId(
          project.projectId,
          registryEntries,
        ) ??
        _findRepoEntryByKey(project.projectId, registryEntries);
    if (directMatch != null) {
      return directMatch;
    }

    final normalizedProjectKeys = _projectLookupKeys(project);
    final fuzzyMatch = _findFuzzyRepoEntry(
      lookupKeys: normalizedProjectKeys,
      registryEntries: registryEntries,
    );
    if (fuzzyMatch != null) {
      return fuzzyMatch;
    }

    return null;
  }

  _RepoRegistryEntry? _findRepoEntryById(
    String repoId,
    List<_RepoRegistryEntry> registryEntries,
  ) {
    for (final entry in registryEntries) {
      if (_normalizeKey(entry.id) == _normalizeKey(repoId)) {
        return entry;
      }
    }
    return null;
  }

  _RepoRegistryEntry? _findRepoEntryByDashboardProjectId(
    String dashboardProjectId,
    List<_RepoRegistryEntry> registryEntries,
  ) {
    for (final entry in registryEntries) {
      if (_normalizeKey(entry.dashboardProjectId) ==
          _normalizeKey(dashboardProjectId)) {
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
      final entryKeys = <String>[
        entry.id,
        entry.dashboardProjectId ?? '',
        entry.name,
      ].map(_normalizeKey).where((value) => value.isNotEmpty).toList();
      if (entryKeys.contains(normalizedLookupKey)) {
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
      final entryKeys = <String>[
        entry.id,
        entry.dashboardProjectId ?? '',
        entry.name,
      ];

      final score = _highestSimilarity(lookupKeys, entryKeys);
      if (score > bestScore) {
        bestScore = score;
        bestMatch = entry;
      }
    }

    if (bestScore >= 0.62) {
      return bestMatch;
    }
    return null;
  }

  List<String> _projectLookupKeys(Project project) {
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

  String? _repoPathOverrideForEntry(_RepoRegistryEntry entry) {
    if (entry.id != 'new_earth_dashboard') {
      return null;
    }

    final localDashboardRoot = _findCurrentDashboardRepoRoot();
    if (localDashboardRoot == null) {
      return null;
    }

    final registryPath = entry.repoPath.trim();
    if (registryPath.isNotEmpty && Directory(registryPath).existsSync()) {
      return null;
    }

    return localDashboardRoot.path;
  }

  Directory? _findCurrentDashboardRepoRoot() {
    var current = _workingDirectory;
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

  List<String> _deriveNextActions({
    required Project project,
    required List<UnifiedTaskRecord> tasks,
    required RepoSnapshot? repoSnapshot,
  }) {
    final actions = <String>[];
    final nextAction = project.nextAction?.trim();
    if (nextAction != null && nextAction.isNotEmpty) {
      actions.add(nextAction);
    }

    final activeTasks = tasks
        .where((task) {
          final status = task.status.toLowerCase().trim();
          return status != 'done' && status != 'parked' && status != 'blocked';
        })
        .toList(growable: false);

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
    if (repoSnapshot == null ||
        !repoSnapshot.exists ||
        !repoSnapshot.isGitRepo) {
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

  Future<RepoSnapshot> _scanRepoEntry(_RepoRegistryEntry entry) async {
    final repoPath = entry.repoPath;
    final repoDirectory = Directory(repoPath);
    final exists = await repoDirectory.exists();
    final scannedAt = DateTime.now().toUtc().toIso8601String();
    final scanWarnings = <String>[];

    if (!exists) {
      return RepoSnapshot(
        id: entry.id,
        name: entry.name,
        repoPath: repoPath,
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
        scannedAt: scannedAt,
      );
    }

    final gitStatus = await _runGit(repoPath, <String>['status', '--short']);
    final gitBranch = await _runGit(repoPath, <String>[
      'branch',
      '--show-current',
    ]);
    final gitLatestCommit = await _runGit(repoPath, <String>[
      'log',
      '-1',
      '--pretty=format:%H|%cI|%s',
    ]);
    final gitRecentCommits = await _runGit(repoPath, <String>[
      'log',
      '-5',
      '--pretty=format:%h %s',
    ]);
    final gitTags = await _runGit(repoPath, <String>[
      'tag',
      '--points-at',
      'HEAD',
    ]);
    final isGitRepo =
        (await _runGit(repoPath, <String>[
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
      repoPath: repoPath,
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
      scannedAt: scannedAt,
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

UnifiedProjectRecord _projectFromJson(
  Map<String, dynamic> json,
  String mergedAt,
) {
  final tasks = (json['dashboardTasks'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(
        (task) => UnifiedTaskRecord(
          id: task['id']?.toString() ?? '',
          title: task['title']?.toString() ?? '',
          status: task['status']?.toString() ?? '',
          projectId: task['projectId']?.toString(),
          priority: task['priority']?.toString(),
        ),
      )
      .toList(growable: false);

  final latestRepoStatusJson = json['latestRepoStatus'];
  final latestRepoStatus = latestRepoStatusJson is Map<String, dynamic>
      ? RepoSnapshot.fromJson(latestRepoStatusJson)
      : null;

  return UnifiedProjectRecord(
    projectId: json['projectId']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    dashboardStatus: json['dashboardStatus']?.toString() ?? '',
    dashboardDescription: json['dashboardDescription']?.toString(),
    dashboardTasks: tasks,
    repoLinked: boolValue(json['repoLinked']),
    repoId: json['repoId']?.toString(),
    repoPath: json['repoPath']?.toString(),
    omegaPath: json['omegaPath']?.toString(),
    currentPhase: json['currentPhase']?.toString(),
    latestRepoStatus: latestRepoStatus,
    nextActions: stringListValue(json['nextActions']),
    codexHandoffReady: boolValue(json['codexHandoffReady']),
    lastMergedAt: json['lastMergedAt']?.toString().trim().isNotEmpty == true
        ? json['lastMergedAt'].toString()
        : mergedAt,
  );
}
