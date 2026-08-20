import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/features/repo_research_engine/application/repo_research_engine_controller.dart';
import 'package:new_earth_command_dashboard/features/repo_research_engine/data/repo_research_engine_service.dart';

class FakeRepoResearchEngineProvider implements RepoResearchEngineProvider {
  FakeRepoResearchEngineProvider(this.root);

  final Directory root;
  final List<String> calls = <String>[];

  @override
  Directory moduleRootDirectory() {
    calls.add('moduleRootDirectory');
    return root;
  }

  @override
  Future<RepoResearchCloneResult> cloneRepository({
    required String source,
    required String workspaceRoot,
    String? branch,
  }) async {
    calls.add('cloneRepository');
    return RepoResearchCloneResult(
      exitCode: 0,
      source: source,
      workspaceRoot: workspaceRoot,
      repositoryRoot: path.join(workspaceRoot, 'repo'),
      sourceRoot: path.join(workspaceRoot, 'repo', 'source'),
      provider: 'local',
      ownerPath: 'owner',
      repoName: 'repo',
      branch: branch ?? 'main',
      commit: 'abc123',
      manifestPath: path.join(workspaceRoot, 'repo', 'clone_manifest.json'),
      workspaceManifestPath: path.join(
        workspaceRoot,
        'repo',
        'workspace_manifest.json',
      ),
      command: const ['python', 'clone_repo.py'],
      stdout: '',
      stderr: '',
    );
  }

  @override
  Future<void> appendCloneHistory(RepoResearchCloneHistoryRecord record) async {
    calls.add('appendCloneHistory:${record.repoName}');
  }

  @override
  Future<void> appendRecentRun(RepoResearchRunRecord record) async {
    calls.add('appendRecentRun:${record.profile}');
  }

  @override
  Future<List<RepoResearchChangeHistoryRecord>> loadChangeHistory({
    int limit = 8,
  }) async {
    calls.add('loadChangeHistory:$limit');
    return const <RepoResearchChangeHistoryRecord>[];
  }

  @override
  Future<List<RepoResearchCloneHistoryRecord>> loadCloneHistory({
    int limit = 10,
  }) async {
    calls.add('loadCloneHistory:$limit');
    return const <RepoResearchCloneHistoryRecord>[];
  }

  @override
  Future<List<RepoResearchExportRecord>> loadExportHistory({
    int limit = 8,
  }) async {
    calls.add('loadExportHistory:$limit');
    return const <RepoResearchExportRecord>[];
  }

  @override
  Future<List<RepoResearchRunRecord>> loadRecentRuns({int limit = 8}) async {
    calls.add('loadRecentRuns:$limit');
    return const <RepoResearchRunRecord>[];
  }

  @override
  Future<List<String>> listOutputFiles(String outputDirectory) async {
    calls.add('listOutputFiles:$outputDirectory');
    return const <String>['report.md'];
  }

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
  }) async {
    calls.add('runResearch:$profile');
    return RepoResearchEngineRunResult(
      exitCode: 0,
      stdout: 'ok',
      stderr: '',
      outputDirectory: outDirectory,
      command: const ['python', 'run_research.py'],
    );
  }

  @override
  Future<String> readFile(String filePath) async {
    calls.add('readFile:$filePath');
    return 'preview';
  }

  @override
  Future<void> openFolder(String folderPath) async {
    calls.add('openFolder:$folderPath');
  }

  @override
  Future<void> openPath(String targetPath) async {
    calls.add('openPath:$targetPath');
  }
}

class FakeRepoResearchEngineService extends RepoResearchEngineService {
  FakeRepoResearchEngineService({required this.root, super.workingDirectory});

  final Directory root;
  final List<String> calls = <String>[];

  @override
  Directory moduleRootDirectory() {
    calls.add('moduleRootDirectory');
    return root;
  }

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
  }) async {
    calls.add('runResearch:$profile');
    return RepoResearchEngineRunResult(
      exitCode: 0,
      stdout: 'service',
      stderr: '',
      outputDirectory: outDirectory,
      command: const ['python', 'run_research.py'],
    );
  }

  @override
  Future<RepoResearchCloneResult> cloneRepository({
    required String source,
    required String workspaceRoot,
    String? branch,
  }) async {
    calls.add('cloneRepository');
    return RepoResearchCloneResult(
      exitCode: 0,
      source: source,
      workspaceRoot: workspaceRoot,
      repositoryRoot: path.join(workspaceRoot, 'repo'),
      sourceRoot: path.join(workspaceRoot, 'repo', 'source'),
      provider: 'local',
      ownerPath: 'owner',
      repoName: 'repo',
      branch: branch ?? 'main',
      commit: 'abc123',
      manifestPath: path.join(workspaceRoot, 'repo', 'clone_manifest.json'),
      workspaceManifestPath: path.join(
        workspaceRoot,
        'repo',
        'workspace_manifest.json',
      ),
      command: const ['python', 'clone_repo.py'],
      stdout: '',
      stderr: '',
    );
  }

  @override
  Future<List<RepoResearchRunRecord>> loadRecentRuns({int limit = 8}) async {
    calls.add('loadRecentRuns:$limit');
    return const <RepoResearchRunRecord>[];
  }

  @override
  Future<List<RepoResearchExportRecord>> loadExportHistory({
    int limit = 8,
  }) async {
    calls.add('loadExportHistory:$limit');
    return const <RepoResearchExportRecord>[];
  }

  @override
  Future<List<RepoResearchChangeHistoryRecord>> loadChangeHistory({
    int limit = 8,
  }) async {
    calls.add('loadChangeHistory:$limit');
    return const <RepoResearchChangeHistoryRecord>[];
  }

  @override
  Future<List<RepoResearchCloneHistoryRecord>> loadCloneHistory({
    int limit = 10,
  }) async {
    calls.add('loadCloneHistory:$limit');
    return const <RepoResearchCloneHistoryRecord>[];
  }

  @override
  Future<void> appendRecentRun(RepoResearchRunRecord record) async {
    calls.add('appendRecentRun:${record.profile}');
  }

  @override
  Future<void> appendCloneHistory(RepoResearchCloneHistoryRecord record) async {
    calls.add('appendCloneHistory:${record.repoName}');
  }

  @override
  Future<List<String>> listOutputFiles(String outputDirectory) async {
    calls.add('listOutputFiles:$outputDirectory');
    return const <String>['report.md'];
  }

  @override
  Future<String> readFile(String filePath) async {
    calls.add('readFile:$filePath');
    return 'service-preview';
  }

  @override
  Future<void> openFolder(String folderPath) async {
    calls.add('openFolder:$folderPath');
  }

  @override
  Future<void> openPath(String targetPath) async {
    calls.add('openPath:$targetPath');
  }
}

void main() {
  test('controller can be replaced by a fake provider', () async {
    final root = Directory.systemTemp.createTempSync(
      'repo_research_controller',
    );
    addTearDown(() {
      if (root.existsSync()) {
        root.deleteSync(recursive: true);
      }
    });

    final provider = FakeRepoResearchEngineProvider(root);
    final controller = RepoResearchEngineController(provider: provider);

    expect(controller.moduleRootDirectory().path, root.path);
    expect(controller.defaultOutputDirectory, path.join(root.path, 'reports'));
    expect(
      controller.defaultProfilesDirectory,
      path.join(root.path, 'profiles'),
    );
    expect(
      controller.defaultWorkspaceRoot,
      path.join(root.path, 'workspaces', 'imports'),
    );
    expect(
      controller.defaultProfilePath,
      path.join(root.path, 'profiles', 'generic.profile.json'),
    );
    expect(
      controller.templateSetsPath,
      path.join(root.path, 'config', 'template_sets.json'),
    );
    expect(
      controller.exportHistoryMarkdownPath,
      path.join(root.path, 'reports', 'export_history.md'),
    );

    await controller.runResearch(
      repoPath: 'D:/repo',
      profile: 'Generic',
      outDirectory: 'D:/out',
    );
    await controller.cloneRepository(
      source: 'D:/repo',
      workspaceRoot: 'D:/workspace',
    );
    await controller.loadRecentRuns();
    await controller.loadExportHistory();
    await controller.loadChangeHistory();
    await controller.loadCloneHistory();
    await controller.appendRecentRun(
      const RepoResearchRunRecord(
        timestamp: '2024-01-01T00:00:00',
        repoPath: 'D:/repo',
        profile: 'Generic',
        outputDirectory: 'D:/out',
        exitCode: 0,
        command: <String>[],
        graphExport: false,
        compareWith: null,
        baselineInventory: null,
        compareProfile: null,
        reportFiles: <String>[],
      ),
    );
    await controller.appendCloneHistory(
      const RepoResearchCloneHistoryRecord(
        timestamp: '2024-01-01T00:00:00',
        source: 'D:/repo',
        workspaceRoot: 'D:/workspace',
        repositoryRoot: 'D:/workspace/repo',
        sourceRoot: 'D:/workspace/repo/source',
        provider: 'local',
        ownerPath: 'owner',
        repoName: 'repo',
        branch: 'main',
        commit: 'abc123',
      ),
    );
    await controller.listOutputFiles('D:/out');
    await controller.readFile('D:/out/report.md');
    await controller.openFolder('D:/out');
    await controller.openPath('D:/out/report.md');

    expect(
      provider.calls,
      containsAllInOrder(<String>[
        'moduleRootDirectory',
        'runResearch:Generic',
        'cloneRepository',
        'loadRecentRuns:8',
        'loadExportHistory:8',
        'loadChangeHistory:8',
        'loadCloneHistory:10',
        'appendRecentRun:Generic',
        'appendCloneHistory:repo',
        'listOutputFiles:D:/out',
        'readFile:D:/out/report.md',
        'openFolder:D:/out',
        'openPath:D:/out/report.md',
      ]),
    );
  });

  test('runtime reuses a single injected provider instance', () {
    final root = Directory.systemTemp.createTempSync('repo_research_runtime');
    addTearDown(() {
      if (root.existsSync()) {
        root.deleteSync(recursive: true);
      }
    });

    final provider = FakeRepoResearchEngineProvider(root);
    final runtime = RepoResearchEngineRuntime.local(provider: provider);

    expect(runtime.provider, same(provider));
    expect(runtime.controller.moduleRootDirectory().path, root.path);
  });

  test(
    'local provider delegates to the legacy service implementation',
    () async {
      final root = Directory.systemTemp.createTempSync('repo_research_service');
      addTearDown(() {
        if (root.existsSync()) {
          root.deleteSync(recursive: true);
        }
      });

      final service = FakeRepoResearchEngineService(root: root);
      final provider = LocalRepoResearchEngineProvider(service: service);

      expect(provider.moduleRootDirectory().path, root.path);

      await provider.runResearch(
        repoPath: 'D:/repo',
        profile: 'Generic',
        outDirectory: 'D:/out',
      );
      await provider.cloneRepository(
        source: 'D:/repo',
        workspaceRoot: 'D:/workspace',
      );
      await provider.loadRecentRuns();
      await provider.loadExportHistory();
      await provider.loadChangeHistory();
      await provider.loadCloneHistory();
      await provider.appendRecentRun(
        const RepoResearchRunRecord(
          timestamp: '2024-01-01T00:00:00',
          repoPath: 'D:/repo',
          profile: 'Generic',
          outputDirectory: 'D:/out',
          exitCode: 0,
          command: <String>[],
          graphExport: false,
          compareWith: null,
          baselineInventory: null,
          compareProfile: null,
          reportFiles: <String>[],
        ),
      );
      await provider.appendCloneHistory(
        const RepoResearchCloneHistoryRecord(
          timestamp: '2024-01-01T00:00:00',
          source: 'D:/repo',
          workspaceRoot: 'D:/workspace',
          repositoryRoot: 'D:/workspace/repo',
          sourceRoot: 'D:/workspace/repo/source',
          provider: 'local',
          ownerPath: 'owner',
          repoName: 'repo',
          branch: 'main',
          commit: 'abc123',
        ),
      );
      await provider.listOutputFiles('D:/out');
      await provider.readFile('D:/out/report.md');
      await provider.openFolder('D:/out');
      await provider.openPath('D:/out/report.md');

      expect(
        service.calls,
        containsAllInOrder(<String>[
          'moduleRootDirectory',
          'runResearch:Generic',
          'cloneRepository',
          'loadRecentRuns:8',
          'loadExportHistory:8',
          'loadChangeHistory:8',
          'loadCloneHistory:10',
          'appendRecentRun:Generic',
          'appendCloneHistory:repo',
          'listOutputFiles:D:/out',
          'readFile:D:/out/report.md',
          'openFolder:D:/out',
          'openPath:D:/out/report.md',
        ]),
      );
    },
  );
}
