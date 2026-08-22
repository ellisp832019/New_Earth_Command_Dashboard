import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

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

class RepoResearchChangeHistoryRecord {
  const RepoResearchChangeHistoryRecord({
    required this.timestamp,
    required this.currentRepo,
    required this.baselineInventoryPath,
    required this.baselineRepo,
    required this.summary,
    required this.fileChanges,
    required this.newRiskPaths,
    required this.resolvedRiskPaths,
  });

  factory RepoResearchChangeHistoryRecord.fromJson(Map<String, dynamic> json) {
    return RepoResearchChangeHistoryRecord(
      timestamp: json['timestamp']?.toString() ?? '',
      currentRepo: json['current_repo']?.toString() ?? '',
      baselineInventoryPath: json['baseline_inventory_path']?.toString() ?? '',
      baselineRepo: json['baseline_repo']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      fileChanges: _stringListMap(json['file_changes']),
      newRiskPaths: _stringList(json['new_risk_paths']),
      resolvedRiskPaths: _stringList(json['resolved_risk_paths']),
    );
  }

  final String timestamp;
  final String currentRepo;
  final String baselineInventoryPath;
  final String baselineRepo;
  final String summary;
  final Map<String, List<String>> fileChanges;
  final List<String> newRiskPaths;
  final List<String> resolvedRiskPaths;

  DateTime? get parsedTimestamp => DateTime.tryParse(timestamp);

  String get fileChangeSummary {
    final added = fileChanges['added']?.length ?? 0;
    final removed = fileChanges['removed']?.length ?? 0;
    final modified = fileChanges['modified']?.length ?? 0;
    return '$added added, $removed removed, $modified modified';
  }

  String get shortBaselinePath {
    if (baselineInventoryPath.isEmpty) {
      return 'No baseline path recorded';
    }
    return path.basename(baselineInventoryPath);
  }
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

enum RepoResearchProcessFailureKind { launchFailure, timedOut }

enum RepoResearchCloneFailureKind {
  validationFailure,
  launchFailure,
  gitFailure,
  timedOut,
  cancelled,
  cleanupFailure,
  protocolError,
  watchdogFailure,
}

class RepoResearchCloneCancellation {
  final Completer<void> _requested = Completer<void>();

  bool get isRequested => _requested.isCompleted;

  Future<void> get whenRequested => _requested.future;

  void request() {
    if (!_requested.isCompleted) {
      _requested.complete();
    }
  }
}

class RepoResearchCloneException implements Exception {
  const RepoResearchCloneException({
    required this.kind,
    required this.message,
    required this.operationId,
    required this.command,
    this.stdout = '',
    this.stderr = '',
    this.primaryCause,
  });

  final RepoResearchCloneFailureKind kind;
  final String message;
  final String operationId;
  final List<String> command;
  final String stdout;
  final String stderr;
  final String? primaryCause;

  @override
  String toString() {
    return 'RepoResearchCloneException(kind: $kind, message: $message)';
  }
}

class RepoResearchProcessException implements Exception {
  const RepoResearchProcessException({
    required this.kind,
    required this.message,
    required this.command,
    this.stdout = '',
    this.stderr = '',
    this.details = '',
  });

  final RepoResearchProcessFailureKind kind;
  final String message;
  final List<String> command;
  final String stdout;
  final String stderr;
  final String details;

  @override
  String toString() {
    return 'RepoResearchProcessException(kind: $kind, message: $message)';
  }
}

class RepoResearchEngineService {
  static const Duration defaultResearchTimeout = Duration(minutes: 10);
  static const Duration defaultCloneWatchdogTimeout = Duration(minutes: 13);

  RepoResearchEngineService({
    Directory? workingDirectory,
    Duration researchTimeout = defaultResearchTimeout,
    Duration cloneWatchdogTimeout = defaultCloneWatchdogTimeout,
    Future<Process> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
      bool runInShell,
    })?
    processStarter,
  }) : _workingDirectory = workingDirectory ?? Directory.current,
       _researchTimeout = researchTimeout,
       _cloneWatchdogTimeout = cloneWatchdogTimeout,
       _processStarter = processStarter ?? _defaultProcessStarter;

  final Directory _workingDirectory;
  final Duration _researchTimeout;
  final Duration _cloneWatchdogTimeout;
  final Future<Process> Function(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    bool runInShell,
  })
  _processStarter;

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
    final commandLine = <String>[command, ...args];
    final process = await _startResearchProcess(
      command,
      args,
      workingDirectory: moduleRoot.path,
    );
    final stdoutBuffer = StringBuffer();
    final stderrBuffer = StringBuffer();

    final stdoutDone = process.stdout
        .transform(utf8.decoder)
        .listen(stdoutBuffer.write)
        .asFuture<void>();
    final stderrDone = process.stderr
        .transform(utf8.decoder)
        .listen(stderrBuffer.write)
        .asFuture<void>();
    int exitCode;
    try {
      exitCode = await process.exitCode.timeout(_researchTimeout);
    } on TimeoutException {
      process.kill(ProcessSignal.sigkill);
      await process.exitCode;
      await Future.wait<void>(<Future<void>>[stdoutDone, stderrDone]);
      throw RepoResearchProcessException(
        kind: RepoResearchProcessFailureKind.timedOut,
        message: 'Timed out while running local research.',
        command: commandLine,
        stdout: stdoutBuffer.toString(),
        stderr: stderrBuffer.toString(),
      );
    }
    await Future.wait<void>(<Future<void>>[stdoutDone, stderrDone]);

    return RepoResearchEngineRunResult(
      exitCode: exitCode,
      stdout: stdoutBuffer.toString(),
      stderr: stderrBuffer.toString(),
      outputDirectory: outDirectory,
      command: commandLine,
    );
  }

  Future<RepoResearchCloneResult> cloneRepository({
    required String source,
    required String workspaceRoot,
    String? branch,
  }) {
    return _cloneRepository(
      source: source,
      workspaceRoot: workspaceRoot,
      branch: branch,
    );
  }

  Future<RepoResearchCloneResult> cloneRepositoryWithCancellation({
    required String source,
    required String workspaceRoot,
    String? branch,
    required RepoResearchCloneCancellation cancellation,
  }) {
    return _cloneRepository(
      source: source,
      workspaceRoot: workspaceRoot,
      branch: branch,
      cancellation: cancellation,
    );
  }

  Future<RepoResearchCloneResult> _cloneRepository({
    required String source,
    required String workspaceRoot,
    String? branch,
    RepoResearchCloneCancellation? cancellation,
  }) async {
    final moduleRoot = moduleRootDirectory();
    final script = path.join(moduleRoot.path, 'scripts', 'clone_repo.py');
    final operationId = _cloneOperationId();
    final args = <String>[
      script,
      '--protocol-version',
      'ds05-c4b1-clone-protocol-v1',
      '--operation-id',
      operationId,
      '--source',
      source,
      '--workspace-root',
      workspaceRoot,
    ];
    if (branch != null && branch.trim().isNotEmpty) {
      args.addAll(['--branch', branch.trim()]);
    }
    if (cancellation != null) {
      args.add('--control-stdin');
    }

    final command = _pythonCommand();
    final commandLine = <String>[command, ...args];
    late final Process process;
    try {
      process = await _processStarter(
        command,
        args,
        workingDirectory: moduleRoot.path,
        runInShell: true,
      );
    } on ProcessException catch (error) {
      throw RepoResearchCloneException(
        kind: RepoResearchCloneFailureKind.launchFailure,
        message: 'Unable to start repository clone.',
        operationId: operationId,
        command: commandLine,
        primaryCause: _sanitizeCloneText(error.message),
      );
    }

    final stdoutBuffer = StringBuffer();
    final stderrBuffer = StringBuffer();
    final stdoutDone = process.stdout
        .transform(utf8.decoder)
        .listen(stdoutBuffer.write)
        .asFuture<void>();
    final stderrDone = process.stderr
        .transform(utf8.decoder)
        .listen(stderrBuffer.write)
        .asFuture<void>();
    var terminal = false;
    var cancellationSent = false;
    var stdinClosed = false;

    Future<void> closeStdin() async {
      if (stdinClosed) {
        return;
      }
      stdinClosed = true;
      try {
        await process.stdin.close();
      } catch (_) {
        // The child may already have closed its control channel.
      }
    }

    Future<void> sendCancellation() async {
      if (terminal || cancellationSent) {
        return;
      }
      cancellationSent = true;
      final frame = jsonEncode({
        'protocol_version': 'ds05-c4b1-clone-protocol-v1',
        'kind': 'cancel',
        'operation_id': operationId,
        'reason': 'user_cancelled',
      });
      try {
        process.stdin.writeln(frame);
        await process.stdin.flush();
      } finally {
        await closeStdin();
      }
    }

    final exitFuture = process.exitCode;
    final cancellationFuture = cancellation?.whenRequested.then((_) async {
      await sendCancellation();
      return true;
    });
    final watchdogCompleter = Completer<void>();
    final watchdogTimer = Timer(_cloneWatchdogTimeout, () {
      if (!watchdogCompleter.isCompleted) {
        watchdogCompleter.complete();
      }
    });
    final race = <Future<Object>>[
      exitFuture.then<Object>((code) => code),
      watchdogCompleter.future.then<Object>(
        (_) => const _CloneWatchdogExpired(),
      ),
      if (cancellationFuture != null)
        cancellationFuture.then<Object>((_) => const _CloneCancelled()),
    ];

    Object outcome;
    try {
      outcome = await Future.any<Object>(race);
      if (outcome is _CloneWatchdogExpired) {
        process.kill(ProcessSignal.sigterm);
        await exitFuture;
        await Future.wait<void>(<Future<void>>[stdoutDone, stderrDone]);
        terminal = true;
        await closeStdin();
        throw RepoResearchCloneException(
          kind: RepoResearchCloneFailureKind.watchdogFailure,
          message: 'Repository clone watchdog expired.',
          operationId: operationId,
          command: commandLine,
          stdout: _sanitizeCloneText(stdoutBuffer.toString()),
          stderr: _sanitizeCloneText(stderrBuffer.toString()),
        );
      }
      if (outcome is _CloneCancelled) {
        final exitCode = await exitFuture;
        await Future.wait<void>(<Future<void>>[stdoutDone, stderrDone]);
        terminal = true;
        await closeStdin();
        if (exitCode != 0) {
          throw _cloneFailureFromProcess(
            exitCode: exitCode,
            operationId: operationId,
            command: commandLine,
            stdout: stdoutBuffer.toString(),
            stderr: stderrBuffer.toString(),
          );
        }
        outcome = exitCode;
      }

      final exitCode = outcome as int;
      await Future.wait<void>(<Future<void>>[stdoutDone, stderrDone]);
      terminal = true;
      await closeStdin();
      final stdout = stdoutBuffer.toString();
      final stderr = stderrBuffer.toString();

      if (exitCode != 0) {
        throw _cloneFailureFromProcess(
          exitCode: exitCode,
          operationId: operationId,
          command: commandLine,
          stdout: stdout,
          stderr: stderr,
        );
      }

      final decoded = _decodeCloneSuccess(
        stdout,
        operationId: operationId,
        command: commandLine,
      );
      final result = RepoResearchCloneResult(
        exitCode: exitCode,
        source: _stringValue(decoded, 'source') ?? source,
        workspaceRoot:
            _stringValue(decoded, 'workspaceRoot', 'workspace_root') ??
            workspaceRoot,
        repositoryRoot:
            _stringValue(decoded, 'repositoryRoot', 'repository_root') ?? '',
        sourceRoot: _stringValue(decoded, 'sourceRoot', 'source_root') ?? '',
        provider: _stringValue(decoded, 'provider') ?? 'local',
        ownerPath: _stringValue(decoded, 'ownerPath', 'owner_path') ?? '',
        repoName: _stringValue(decoded, 'repoName', 'repo_name') ?? '',
        branch: _stringValue(decoded, 'branch') ?? '',
        commit: _stringValue(decoded, 'commit') ?? '',
        manifestPath:
            _stringValue(decoded, 'manifestPath', 'manifest_path') ?? '',
        workspaceManifestPath:
            _stringValue(
              decoded,
              'workspaceManifestPath',
              'workspace_manifest_path',
            ) ??
            '',
        command: commandLine,
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
    } finally {
      terminal = true;
      watchdogTimer.cancel();
      await closeStdin();
    }
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

  Future<List<RepoResearchChangeHistoryRecord>> loadChangeHistory({
    int limit = 8,
  }) async {
    final historyFile = _changeHistoryFile();
    if (!await historyFile.exists()) {
      return const <RepoResearchChangeHistoryRecord>[];
    }

    try {
      final decoded = jsonDecode(await historyFile.readAsString());
      if (decoded is! List) {
        return const <RepoResearchChangeHistoryRecord>[];
      }

      final records = decoded
          .whereType<Map<String, dynamic>>()
          .map(RepoResearchChangeHistoryRecord.fromJson)
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
      return const <RepoResearchChangeHistoryRecord>[];
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

  Future<Process> _startResearchProcess(
    String command,
    List<String> args, {
    required String workingDirectory,
  }) async {
    try {
      return await _processStarter(
        command,
        args,
        workingDirectory: workingDirectory,
        runInShell: true,
      );
    } on ProcessException catch (error) {
      throw RepoResearchProcessException(
        kind: RepoResearchProcessFailureKind.launchFailure,
        message: 'Unable to start local research.',
        command: <String>[command, ...args],
        details: error.message,
      );
    }
  }

  static Future<Process> _defaultProcessStarter(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    bool runInShell = false,
  }) {
    return Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      runInShell: runInShell,
    );
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

  File _changeHistoryFile() {
    final moduleRoot = moduleRootDirectory();
    return File(path.join(moduleRoot.path, 'reports', 'change_history.json'));
  }
}

class _CloneWatchdogExpired {
  const _CloneWatchdogExpired();
}

class _CloneCancelled {
  const _CloneCancelled();
}

const _cloneProtocolVersion = 'ds05-c4b1-clone-protocol-v1';
const _cloneFailureKinds = <String>{
  'validation_failed',
  'launch_failed',
  'git_failed',
  'timed_out',
  'cancelled',
  'cleanup_failed',
  'protocol_error',
};

String _cloneOperationId() {
  final now = DateTime.now().toUtc();
  final timestamp =
      '${now.year.toString().padLeft(4, '0')}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}'
      'T${now.hour.toString().padLeft(2, '0')}'
      '${now.minute.toString().padLeft(2, '0')}'
      '${now.second.toString().padLeft(2, '0')}Z';
  final random = Random.secure();
  final hex = StringBuffer();
  for (var index = 0; index < 32; index++) {
    hex.write(random.nextInt(16).toRadixString(16));
  }
  return 'clone_v1_${timestamp}_${hex.toString()}';
}

Map<String, dynamic> _decodeCloneSuccess(
  String stdout, {
  required String operationId,
  required List<String> command,
}) {
  try {
    final decoded = jsonDecode(stdout);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } catch (_) {
    // Convert malformed success output to the same deterministic protocol error.
  }
  throw RepoResearchCloneException(
    kind: RepoResearchCloneFailureKind.protocolError,
    message: 'Repository clone returned an invalid success response.',
    operationId: operationId,
    command: command,
  );
}

String? _stringValue(
  Map<String, dynamic> values,
  String primary, [
  String? legacy,
]) {
  final value = values[primary] ?? (legacy == null ? null : values[legacy]);
  return value?.toString();
}

RepoResearchCloneException _cloneFailureFromProcess({
  required int exitCode,
  required String operationId,
  required List<String> command,
  required String stdout,
  required String stderr,
}) {
  final trimmed = stderr.trim();
  if (trimmed.isEmpty) {
    return RepoResearchCloneException(
      kind: RepoResearchCloneFailureKind.protocolError,
      message: 'Repository clone returned an empty failure response.',
      operationId: operationId,
      command: command,
      stdout: stdout,
      stderr: stderr,
    );
  }

  dynamic decoded;
  try {
    decoded = jsonDecode(trimmed);
  } catch (_) {
    return RepoResearchCloneException(
      kind: RepoResearchCloneFailureKind.protocolError,
      message: 'Repository clone returned a malformed failure response.',
      operationId: operationId,
      command: command,
      stdout: stdout,
      stderr: _sanitizeCloneText(stderr),
    );
  }
  if (decoded is! Map<String, dynamic> ||
      decoded['protocol_version'] != _cloneProtocolVersion ||
      decoded['kind'] != 'clone_failure' ||
      decoded['operation_id'] != operationId ||
      decoded['failure_kind'] is! String ||
      !_cloneFailureKinds.contains(decoded['failure_kind']) ||
      decoded['message'] is! String ||
      decoded['exit_code'] is! int ||
      decoded['exit_code'] != exitCode ||
      decoded['stdout'] is! String ||
      decoded['stderr'] is! String ||
      decoded['cleanup_state'] is! String ||
      (decoded['primary_cause'] != null &&
          decoded['primary_cause'] is! String)) {
    return RepoResearchCloneException(
      kind: RepoResearchCloneFailureKind.protocolError,
      message: 'Repository clone returned an invalid failure response.',
      operationId: operationId,
      command: command,
      stdout: stdout,
      stderr: _sanitizeCloneText(stderr),
    );
  }

  return RepoResearchCloneException(
    kind: _mapCloneFailureKind(decoded['failure_kind'] as String),
    message: _sanitizeCloneText(decoded['message'] as String),
    operationId: operationId,
    command: command,
    stdout: _sanitizeCloneText(decoded['stdout']?.toString() ?? stdout),
    stderr: _sanitizeCloneText(decoded['stderr']?.toString() ?? stderr),
    primaryCause: decoded['primary_cause'] == null
        ? null
        : _sanitizeCloneText(decoded['primary_cause'] as String),
  );
}

RepoResearchCloneFailureKind _mapCloneFailureKind(String kind) {
  switch (kind) {
    case 'validation_failed':
      return RepoResearchCloneFailureKind.validationFailure;
    case 'launch_failed':
      return RepoResearchCloneFailureKind.launchFailure;
    case 'git_failed':
      return RepoResearchCloneFailureKind.gitFailure;
    case 'timed_out':
      return RepoResearchCloneFailureKind.timedOut;
    case 'cancelled':
      return RepoResearchCloneFailureKind.cancelled;
    case 'cleanup_failed':
      return RepoResearchCloneFailureKind.cleanupFailure;
    case 'protocol_error':
      return RepoResearchCloneFailureKind.protocolError;
  }
  return RepoResearchCloneFailureKind.protocolError;
}

String _sanitizeCloneText(String value) {
  final urlCredentials = RegExp(r'([A-Za-z][A-Za-z0-9+.-]*://)[^/@\s]+@');
  final token = RegExp(
    r'\b(access[_-]?token|token|password|passwd|secret|authorization)\b\s*[:=]\s*([^\s,;]+)',
    caseSensitive: false,
  );
  return value
      .replaceAllMapped(urlCredentials, (match) => '${match[1]}***@')
      .replaceAllMapped(token, (match) => '${match[1]}=***');
}

Map<String, List<String>> _stringListMap(dynamic value) {
  if (value is! Map) {
    return const <String, List<String>>{};
  }
  final result = <String, List<String>>{};
  for (final entry in value.entries) {
    if (entry.value is List) {
      result[entry.key.toString()] = (entry.value as List)
          .map((item) => item.toString())
          .toList(growable: false);
    }
  }
  return result;
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList(growable: false);
  }
  return const <String>[];
}
