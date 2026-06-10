import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

class RepoResearchEngineRunResult {
  const RepoResearchEngineRunResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.outputDirectory,
    required this.command,
  });

  final int exitCode;
  final String stdout;
  final String stderr;
  final String outputDirectory;
  final List<String> command;

  bool get succeeded => exitCode == 0;
}

class RepoResearchCloneResult {
  const RepoResearchCloneResult({
    required this.exitCode,
    required this.source,
    required this.workspaceRoot,
    required this.repositoryRoot,
    required this.sourceRoot,
    required this.provider,
    required this.ownerPath,
    required this.repoName,
    required this.branch,
    required this.commit,
    required this.manifestPath,
    required this.workspaceManifestPath,
    required this.command,
    required this.stdout,
    required this.stderr,
  });

  final int exitCode;
  final String source;
  final String workspaceRoot;
  final String repositoryRoot;
  final String sourceRoot;
  final String provider;
  final String ownerPath;
  final String repoName;
  final String branch;
  final String commit;
  final String manifestPath;
  final String workspaceManifestPath;
  final List<String> command;
  final String stdout;
  final String stderr;

  bool get succeeded => exitCode == 0;
}

class RepoResearchCloneHistoryRecord {
  const RepoResearchCloneHistoryRecord({
    required this.timestamp,
    required this.source,
    required this.workspaceRoot,
    required this.repositoryRoot,
    required this.sourceRoot,
    required this.provider,
    required this.ownerPath,
    required this.repoName,
    required this.branch,
    required this.commit,
  });

  factory RepoResearchCloneHistoryRecord.fromJson(Map<String, dynamic> json) {
    return RepoResearchCloneHistoryRecord(
      timestamp: json['timestamp']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      workspaceRoot: json['workspace_root']?.toString() ?? '',
      repositoryRoot: json['repository_root']?.toString() ?? '',
      sourceRoot: json['source_root']?.toString() ?? '',
      provider: json['provider']?.toString() ?? 'local',
      ownerPath: json['owner_path']?.toString() ?? '',
      repoName: json['repo_name']?.toString() ?? '',
      branch: json['branch']?.toString() ?? '',
      commit: json['commit']?.toString() ?? '',
    );
  }

  final String timestamp;
  final String source;
  final String workspaceRoot;
  final String repositoryRoot;
  final String sourceRoot;
  final String provider;
  final String ownerPath;
  final String repoName;
  final String branch;
  final String commit;

  DateTime? get parsedTimestamp => DateTime.tryParse(timestamp);

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'source': source,
      'workspace_root': workspaceRoot,
      'repository_root': repositoryRoot,
      'source_root': sourceRoot,
      'provider': provider,
      'owner_path': ownerPath,
      'repo_name': repoName,
      'branch': branch,
      'commit': commit,
    };
  }

  String get displayTitle {
    final ownerSegment = ownerPath.isEmpty ? '' : '$ownerPath/';
    return '$provider/$ownerSegment$repoName';
  }

  String get shortCommit {
    if (commit.isEmpty) {
      return 'latest';
    }
    return commit.length > 8 ? commit.substring(0, 8) : commit;
  }
}

class RepoResearchRunRecord {
  const RepoResearchRunRecord({
    required this.timestamp,
    required this.repoPath,
    required this.profile,
    required this.outputDirectory,
    required this.exitCode,
    required this.command,
    required this.graphExport,
    required this.compareWith,
    required this.baselineInventory,
    required this.compareProfile,
    required this.reportFiles,
  });

  factory RepoResearchRunRecord.fromJson(Map<String, dynamic> json) {
    return RepoResearchRunRecord(
      timestamp: json['timestamp']?.toString() ?? '',
      repoPath: json['repo_path']?.toString() ?? '',
      profile: json['profile']?.toString() ?? 'Generic',
      outputDirectory: json['output_directory']?.toString() ?? '',
      exitCode: int.tryParse(json['exit_code']?.toString() ?? '') ?? 0,
      command: (json['command'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      graphExport: json['graph_export'] == true,
      compareWith: json['compare_with']?.toString(),
      baselineInventory: json['baseline_inventory']?.toString(),
      compareProfile: json['compare_profile']?.toString(),
      reportFiles: (json['report_files'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }

  final String timestamp;
  final String repoPath;
  final String profile;
  final String outputDirectory;
  final int exitCode;
  final List<String> command;
  final bool graphExport;
  final String? compareWith;
  final String? baselineInventory;
  final String? compareProfile;
  final List<String> reportFiles;

  bool get succeeded => exitCode == 0;

  DateTime? get parsedTimestamp => DateTime.tryParse(timestamp);

  String get shortStatus => succeeded ? 'Success' : 'Needs review';
}

class RepoResearchExportRecord {
  const RepoResearchExportRecord({
    required this.timestamp,
    required this.exportedAt,
    required this.profileName,
    required this.profileFolder,
    required this.repoName,
    required this.repoPath,
    required this.exportedTo,
    required this.sourceReportDir,
    required this.exportedFiles,
    required this.promptFiles,
  });

  factory RepoResearchExportRecord.fromJson(Map<String, dynamic> json) {
    return RepoResearchExportRecord(
      timestamp: json['timestamp']?.toString() ?? '',
      exportedAt: json['exported_at']?.toString() ?? '',
      profileName: json['profile_name']?.toString() ?? 'Generic',
      profileFolder: json['profile_folder']?.toString() ?? 'GENERAL',
      repoName: json['repo_name']?.toString() ?? '',
      repoPath: json['repo_path']?.toString() ?? '',
      exportedTo: json['exported_to']?.toString() ?? '',
      sourceReportDir: json['source_report_dir']?.toString() ?? '',
      exportedFiles: (json['exported_files'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      promptFiles: (json['prompt_files'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }

  final String timestamp;
  final String exportedAt;
  final String profileName;
  final String profileFolder;
  final String repoName;
  final String repoPath;
  final String exportedTo;
  final String sourceReportDir;
  final List<String> exportedFiles;
  final List<String> promptFiles;
}

class RepoResearchEngineService {
  RepoResearchEngineService({Directory? workingDirectory})
    : _workingDirectory = workingDirectory ?? Directory.current;

  final Directory _workingDirectory;

  Directory moduleRootDirectory() {
    var current = _workingDirectory;
    while (true) {
      final candidate = Directory(
        path.join(current.path, 'modules', 'repo_research_engine'),
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
      path.join(_workingDirectory.path, 'modules', 'repo_research_engine'),
    );
  }

  Future<RepoResearchEngineRunResult> runResearch({
    required String repoPath,
    required String profile,
    required String outDirectory,
    String? omegaRoot,
    String? compareWith,
    String? baselineInventory,
    String? compareProfile,
    bool graphExport = false,
  }) async {
    final moduleRoot = moduleRootDirectory();
    final script = path.join(moduleRoot.path, 'scripts', 'run_research.py');
    final args = <String>[
      script,
      '--repo',
      repoPath,
      '--profile',
      profile,
      '--out',
      outDirectory,
    ];

    if (omegaRoot != null && omegaRoot.trim().isNotEmpty) {
      args.addAll(['--omega-root', omegaRoot.trim()]);
    }
    if (compareWith != null && compareWith.trim().isNotEmpty) {
      args.addAll(['--compare-with', compareWith.trim()]);
    }
    if (baselineInventory != null && baselineInventory.trim().isNotEmpty) {
      args.addAll(['--baseline-inventory', baselineInventory.trim()]);
    }
    if (compareProfile != null && compareProfile.trim().isNotEmpty) {
      args.addAll(['--compare-profile', compareProfile.trim()]);
    }
    if (graphExport) {
      args.add('--graph-export');
    }

    final command = _pythonCommand();
    final process = await Process.start(
      command,
      args,
      workingDirectory: moduleRoot.path,
      runInShell: true,
    );
    final stdoutBuffer = StringBuffer();
    final stderrBuffer = StringBuffer();

    process.stdout.transform(utf8.decoder).listen(stdoutBuffer.write);
    process.stderr.transform(utf8.decoder).listen(stderrBuffer.write);
    final exitCode = await process.exitCode;

    return RepoResearchEngineRunResult(
      exitCode: exitCode,
      stdout: stdoutBuffer.toString(),
      stderr: stderrBuffer.toString(),
      outputDirectory: outDirectory,
      command: <String>[command, ...args],
    );
  }

  Future<RepoResearchCloneResult> cloneRepository({
    required String source,
    required String workspaceRoot,
    String? branch,
  }) async {
    final moduleRoot = moduleRootDirectory();
    final script = path.join(moduleRoot.path, 'scripts', 'clone_repo.py');
    final args = <String>[
      script,
      '--source',
      source,
      '--workspace-root',
      workspaceRoot,
    ];
    if (branch != null && branch.trim().isNotEmpty) {
      args.addAll(['--branch', branch.trim()]);
    }

    final command = _pythonCommand();
    final process = await Process.start(
      command,
      args,
      workingDirectory: moduleRoot.path,
      runInShell: true,
    );
    final stdoutBuffer = StringBuffer();
    final stderrBuffer = StringBuffer();

    process.stdout.transform(utf8.decoder).listen(stdoutBuffer.write);
    process.stderr.transform(utf8.decoder).listen(stderrBuffer.write);
    final exitCode = await process.exitCode;
    final stdout = stdoutBuffer.toString();
    final stderr = stderrBuffer.toString();

    if (exitCode != 0) {
      throw StateError(
        stderr.trim().isNotEmpty ? stderr.trim() : 'Repository clone failed.',
      );
    }

    final decoded = jsonDecode(stdout);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Repository clone returned an invalid response.');
    }

    final result = RepoResearchCloneResult(
      exitCode: exitCode,
      source: decoded['source']?.toString() ?? source,
      workspaceRoot: decoded['workspace_root']?.toString() ?? workspaceRoot,
      repositoryRoot: decoded['repository_root']?.toString() ?? '',
      sourceRoot: decoded['source_root']?.toString() ?? '',
      provider: decoded['provider']?.toString() ?? 'local',
      ownerPath: decoded['owner_path']?.toString() ?? '',
      repoName: decoded['repo_name']?.toString() ?? '',
      branch: decoded['branch']?.toString() ?? '',
      commit: decoded['commit']?.toString() ?? '',
      manifestPath: decoded['manifest_path']?.toString() ?? '',
      workspaceManifestPath:
          decoded['workspace_manifest_path']?.toString() ?? '',
      command: <String>[command, ...args],
      stdout: stdout,
      stderr: stderr,
    );

    await appendCloneHistory(
      RepoResearchCloneHistoryRecord(
        timestamp: DateTime.now().toIso8601String(),
        source: result.source,
        workspaceRoot: result.workspaceRoot,
        repositoryRoot: result.repositoryRoot,
        sourceRoot: result.sourceRoot,
        provider: result.provider,
        ownerPath: result.ownerPath,
        repoName: result.repoName,
        branch: result.branch,
        commit: result.commit,
      ),
    );

    return result;
  }

  Future<List<RepoResearchRunRecord>> loadRecentRuns({int limit = 8}) async {
    final historyFile = _historyFile();
    if (!await historyFile.exists()) {
      return const <RepoResearchRunRecord>[];
    }

    try {
      final decoded = jsonDecode(await historyFile.readAsString());
      if (decoded is! List) {
        return const <RepoResearchRunRecord>[];
      }

      final records = decoded
          .whereType<Map<String, dynamic>>()
          .map(RepoResearchRunRecord.fromJson)
          .toList();
      records.sort(
        (left, right) =>
            (right.parsedTimestamp ?? DateTime.fromMillisecondsSinceEpoch(0))
                .compareTo(
                  left.parsedTimestamp ??
                      DateTime.fromMillisecondsSinceEpoch(0),
                ),
      );
      return records.take(limit).toList(growable: false);
    } catch (_) {
      return const <RepoResearchRunRecord>[];
    }
  }

  Future<List<RepoResearchExportRecord>> loadExportHistory({
    int limit = 8,
  }) async {
    final historyFile = _exportHistoryFile();
    if (!await historyFile.exists()) {
      return const <RepoResearchExportRecord>[];
    }

    try {
      final decoded = jsonDecode(await historyFile.readAsString());
      if (decoded is! List) {
        return const <RepoResearchExportRecord>[];
      }

      final records = decoded
          .whereType<Map<String, dynamic>>()
          .map(RepoResearchExportRecord.fromJson)
          .toList();
      records.sort(
        (left, right) =>
            (right.timestamp.isEmpty ? right.exportedAt : right.timestamp)
                .compareTo(
                  left.timestamp.isEmpty ? left.exportedAt : left.timestamp,
                ),
      );
      return records.take(limit).toList(growable: false);
    } catch (_) {
      return const <RepoResearchExportRecord>[];
    }
  }

  Future<List<RepoResearchCloneHistoryRecord>> loadCloneHistory({
    int limit = 10,
  }) async {
    final historyFile = _cloneHistoryFile();
    if (!await historyFile.exists()) {
      return const <RepoResearchCloneHistoryRecord>[];
    }

    try {
      final decoded = jsonDecode(await historyFile.readAsString());
      if (decoded is! List) {
        return const <RepoResearchCloneHistoryRecord>[];
      }

      final records = decoded
          .whereType<Map<String, dynamic>>()
          .map(RepoResearchCloneHistoryRecord.fromJson)
          .toList();
      records.sort(
        (left, right) =>
            (right.parsedTimestamp ?? DateTime.fromMillisecondsSinceEpoch(0))
                .compareTo(
                  left.parsedTimestamp ??
                      DateTime.fromMillisecondsSinceEpoch(0),
                ),
      );
      return records.take(limit).toList(growable: false);
    } catch (_) {
      return const <RepoResearchCloneHistoryRecord>[];
    }
  }

  Future<void> appendRecentRun(RepoResearchRunRecord record) async {
    final historyFile = _historyFile();
    await historyFile.parent.create(recursive: true);

    final existing = await loadRecentRuns(limit: 50);
    final updated = <RepoResearchRunRecord>[
      record,
      ...existing,
    ].take(20).toList(growable: false);

    final encoded = jsonEncode(
      updated
          .map(
            (entry) => {
              'timestamp': entry.timestamp,
              'repo_path': entry.repoPath,
              'profile': entry.profile,
              'output_directory': entry.outputDirectory,
              'exit_code': entry.exitCode,
              'command': entry.command,
              'graph_export': entry.graphExport,
              'compare_with': entry.compareWith,
              'baseline_inventory': entry.baselineInventory,
              'compare_profile': entry.compareProfile,
              'report_files': entry.reportFiles,
            },
          )
          .toList(growable: false),
    );
    await historyFile.writeAsString(encoded, flush: true);
  }

  Future<void> appendCloneHistory(RepoResearchCloneHistoryRecord record) async {
    final historyFile = _cloneHistoryFile();
    await historyFile.parent.create(recursive: true);

    final existing = await loadCloneHistory(limit: 50);
    final updated = <RepoResearchCloneHistoryRecord>[
      record,
      ...existing,
    ].take(20).toList(growable: false);

    final encoded = jsonEncode(
      updated.map((entry) => entry.toJson()).toList(growable: false),
    );
    await historyFile.writeAsString(encoded, flush: true);
  }

  Future<List<String>> listOutputFiles(String outputDirectory) async {
    final directory = Directory(outputDirectory);
    if (!await directory.exists()) {
      return const <String>[];
    }

    final files = <String>[];
    await for (final entity in directory.list(
      recursive: false,
      followLinks: false,
    )) {
      if (entity is! File) {
        continue;
      }
      files.add(path.basename(entity.path));
    }
    files.sort();
    return files;
  }

  Future<String> readFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return '';
    }
    return file.readAsString();
  }

  Future<void> openFolder(String folderPath) async {
    final normalized = path.normalize(folderPath);
    if (Platform.isWindows) {
      await Process.start('explorer.exe', <String>[normalized]);
      return;
    }
    if (Platform.isMacOS) {
      await Process.start('open', <String>[normalized]);
      return;
    }
    await Process.start('xdg-open', <String>[normalized]);
  }

  Future<void> openPath(String targetPath) async {
    final normalized = path.normalize(targetPath);
    if (Platform.isWindows) {
      await Process.start('explorer.exe', <String>['/select,', normalized]);
      return;
    }
    if (Platform.isMacOS) {
      await Process.start('open', <String>[normalized]);
      return;
    }
    await Process.start('xdg-open', <String>[normalized]);
  }

  String _pythonCommand() {
    if (Platform.isWindows) {
      return 'python';
    }
    return 'python3';
  }

  File _historyFile() {
    final moduleRoot = moduleRootDirectory();
    return File(path.join(moduleRoot.path, 'reports', 'run_history.json'));
  }

  File _exportHistoryFile() {
    final moduleRoot = moduleRootDirectory();
    return File(path.join(moduleRoot.path, 'reports', 'export_history.json'));
  }

  File _cloneHistoryFile() {
    final moduleRoot = moduleRootDirectory();
    return File(path.join(moduleRoot.path, 'reports', 'clone_history.json'));
  }
}
