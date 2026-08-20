import 'dart:io';

import 'package:path/path.dart' as path;

import '../data/repo_research_engine_service.dart'
    show
        RepoResearchChangeHistoryRecord,
        RepoResearchCloneHistoryRecord,
        RepoResearchCloneResult,
        RepoResearchEngineRunResult,
        RepoResearchExportRecord,
        RepoResearchRunRecord,
        RepoResearchEngineService;

export '../data/repo_research_engine_service.dart'
    show
        RepoResearchChangeHistoryRecord,
        RepoResearchCloneHistoryRecord,
        RepoResearchCloneResult,
        RepoResearchEngineRunResult,
        RepoResearchExportRecord,
        RepoResearchRunRecord;

abstract class RepoResearchEngineProvider {
  Directory moduleRootDirectory();

  Future<RepoResearchEngineRunResult> runResearch({
    required String repoPath,
    required String profile,
    required String outDirectory,
    String? omegaRoot,
    String? compareWith,
    String? baselineInventory,
    String? compareProfile,
    bool graphExport = false,
  });

  Future<RepoResearchCloneResult> cloneRepository({
    required String source,
    required String workspaceRoot,
    String? branch,
  });

  Future<List<RepoResearchRunRecord>> loadRecentRuns({int limit = 8});

  Future<List<RepoResearchExportRecord>> loadExportHistory({int limit = 8});

  Future<List<RepoResearchChangeHistoryRecord>> loadChangeHistory({
    int limit = 8,
  });

  Future<List<RepoResearchCloneHistoryRecord>> loadCloneHistory({
    int limit = 10,
  });

  Future<void> appendRecentRun(RepoResearchRunRecord record);

  Future<void> appendCloneHistory(RepoResearchCloneHistoryRecord record);

  Future<List<String>> listOutputFiles(String outputDirectory);

  Future<String> readFile(String filePath);

  Future<void> openFolder(String folderPath);

  Future<void> openPath(String targetPath);
}

class LocalRepoResearchEngineProvider implements RepoResearchEngineProvider {
  LocalRepoResearchEngineProvider({
    RepoResearchEngineService? service,
    Directory? workingDirectory,
  }) : _service =
           service ??
           RepoResearchEngineService(workingDirectory: workingDirectory);

  final RepoResearchEngineService _service;

  @override
  Directory moduleRootDirectory() => _service.moduleRootDirectory();

  @override
  Future<RepoResearchEngineRunResult> runResearch({
    required String repoPath,
    required String profile,
    required String outDirectory,
    String? omegaRoot,
    String? compareWith,
    String? baselineInventory,
    String? compareProfile,
    bool graphExport = false,
  }) {
    return _service.runResearch(
      repoPath: repoPath,
      profile: profile,
      outDirectory: outDirectory,
      omegaRoot: omegaRoot,
      compareWith: compareWith,
      baselineInventory: baselineInventory,
      compareProfile: compareProfile,
      graphExport: graphExport,
    );
  }

  @override
  Future<RepoResearchCloneResult> cloneRepository({
    required String source,
    required String workspaceRoot,
    String? branch,
  }) {
    return _service.cloneRepository(
      source: source,
      workspaceRoot: workspaceRoot,
      branch: branch,
    );
  }

  @override
  Future<List<RepoResearchRunRecord>> loadRecentRuns({int limit = 8}) {
    return _service.loadRecentRuns(limit: limit);
  }

  @override
  Future<List<RepoResearchExportRecord>> loadExportHistory({int limit = 8}) {
    return _service.loadExportHistory(limit: limit);
  }

  @override
  Future<List<RepoResearchChangeHistoryRecord>> loadChangeHistory({
    int limit = 8,
  }) {
    return _service.loadChangeHistory(limit: limit);
  }

  @override
  Future<List<RepoResearchCloneHistoryRecord>> loadCloneHistory({
    int limit = 10,
  }) {
    return _service.loadCloneHistory(limit: limit);
  }

  @override
  Future<void> appendRecentRun(RepoResearchRunRecord record) {
    return _service.appendRecentRun(record);
  }

  @override
  Future<void> appendCloneHistory(RepoResearchCloneHistoryRecord record) {
    return _service.appendCloneHistory(record);
  }

  @override
  Future<List<String>> listOutputFiles(String outputDirectory) {
    return _service.listOutputFiles(outputDirectory);
  }

  @override
  Future<String> readFile(String filePath) {
    return _service.readFile(filePath);
  }

  @override
  Future<void> openFolder(String folderPath) {
    return _service.openFolder(folderPath);
  }

  @override
  Future<void> openPath(String targetPath) {
    return _service.openPath(targetPath);
  }
}

class RepoResearchEngineRuntime {
  RepoResearchEngineRuntime._(this.provider, this.controller);

  factory RepoResearchEngineRuntime.local({
    RepoResearchEngineProvider? provider,
    Directory? workingDirectory,
  }) {
    final resolvedProvider =
        provider ??
        LocalRepoResearchEngineProvider(workingDirectory: workingDirectory);
    return RepoResearchEngineRuntime._(
      resolvedProvider,
      RepoResearchEngineController(provider: resolvedProvider),
    );
  }

  final RepoResearchEngineProvider provider;
  final RepoResearchEngineController controller;
}

class RepoResearchEngineController {
  RepoResearchEngineController({RepoResearchEngineProvider? provider})
    : _provider = provider ?? LocalRepoResearchEngineProvider();

  final RepoResearchEngineProvider _provider;

  Directory moduleRootDirectory() => _provider.moduleRootDirectory();

  String get defaultOutputDirectory =>
      path.join(moduleRootDirectory().path, 'reports');

  String get defaultProfilesDirectory =>
      path.join(moduleRootDirectory().path, 'profiles');

  String get defaultWorkspaceRoot =>
      path.join(moduleRootDirectory().path, 'workspaces', 'imports');

  String get defaultProfilePath =>
      path.join(defaultProfilesDirectory, 'generic.profile.json');

  String get templateSetsPath =>
      path.join(moduleRootDirectory().path, 'config', 'template_sets.json');

  String get exportHistoryMarkdownPath =>
      path.join(moduleRootDirectory().path, 'reports', 'export_history.md');

  Future<RepoResearchEngineRunResult> runResearch({
    required String repoPath,
    required String profile,
    required String outDirectory,
    String? omegaRoot,
    String? compareWith,
    String? baselineInventory,
    String? compareProfile,
    bool graphExport = false,
  }) {
    return _provider.runResearch(
      repoPath: repoPath,
      profile: profile,
      outDirectory: outDirectory,
      omegaRoot: omegaRoot,
      compareWith: compareWith,
      baselineInventory: baselineInventory,
      compareProfile: compareProfile,
      graphExport: graphExport,
    );
  }

  Future<RepoResearchCloneResult> cloneRepository({
    required String source,
    required String workspaceRoot,
    String? branch,
  }) {
    return _provider.cloneRepository(
      source: source,
      workspaceRoot: workspaceRoot,
      branch: branch,
    );
  }

  Future<List<RepoResearchRunRecord>> loadRecentRuns({int limit = 8}) {
    return _provider.loadRecentRuns(limit: limit);
  }

  Future<List<RepoResearchExportRecord>> loadExportHistory({int limit = 8}) {
    return _provider.loadExportHistory(limit: limit);
  }

  Future<List<RepoResearchChangeHistoryRecord>> loadChangeHistory({
    int limit = 8,
  }) {
    return _provider.loadChangeHistory(limit: limit);
  }

  Future<List<RepoResearchCloneHistoryRecord>> loadCloneHistory({
    int limit = 10,
  }) {
    return _provider.loadCloneHistory(limit: limit);
  }

  Future<void> appendRecentRun(RepoResearchRunRecord record) {
    return _provider.appendRecentRun(record);
  }

  Future<void> appendCloneHistory(RepoResearchCloneHistoryRecord record) {
    return _provider.appendCloneHistory(record);
  }

  Future<List<String>> listOutputFiles(String outputDirectory) {
    return _provider.listOutputFiles(outputDirectory);
  }

  Future<String> readFile(String filePath) {
    return _provider.readFile(filePath);
  }

  Future<void> openFolder(String folderPath) {
    return _provider.openFolder(folderPath);
  }

  Future<void> openPath(String targetPath) {
    return _provider.openPath(targetPath);
  }
}
