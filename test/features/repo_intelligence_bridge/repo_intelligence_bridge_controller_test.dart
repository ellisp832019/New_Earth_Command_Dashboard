import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/repo_intelligence_bridge/application/repo_intelligence_bridge_controller.dart';
import 'package:new_earth_command_dashboard/features/repo_intelligence_bridge/application/repo_intelligence_bridge_provider.dart';
import 'package:new_earth_command_dashboard/features/repo_intelligence_bridge/data/repo_intelligence_bridge_models.dart';
import 'package:new_earth_command_dashboard/features/repo_intelligence_bridge/data/repo_intelligence_bridge_service.dart';

void main() {
  test('controller operates through the provider abstraction', () async {
    final provider = FakeRepoIntelligenceBridgeProvider();
    final container = ProviderContainer(
      overrides: [repoIntelligenceBridgeProvider.overrideWithValue(provider)],
    );
    addTearDown(container.dispose);

    final firstWorkspace = await container.read(
      repoIntelligenceBridgeWorkspaceProvider.future,
    );
    expect(firstWorkspace.activeProfile.fileName, 'alpha.json');
    expect(provider.loadWorkspaceCount, 1);

    await container
        .read(repoIntelligenceBridgeControllerProvider)
        .setActiveProfile('beta.json');
    expect(provider.savedStates, hasLength(1));
    expect(provider.savedStates.last.activeProfileFile, 'beta.json');
    expect(provider.savedStates.last.dashboardExportRoot, '/exports/alpha');
    expect(provider.savedStates.last.obsidianVaultPath, '/vault/alpha');
    expect(provider.savedStates.last.moduleHomePath, '/module/home');

    final refreshedWorkspace = await container.read(
      repoIntelligenceBridgeWorkspaceProvider.future,
    );
    expect(provider.loadWorkspaceCount, 3);
    expect(refreshedWorkspace.state.activeProfileFile, 'beta.json');

    final syncLines = <String>[];
    final syncResult = await container
        .read(repoIntelligenceBridgeControllerProvider)
        .runFullSync(onOutputLine: syncLines.add);
    expect(syncResult.scriptName, 'sync_all.ps1');
    expect(syncResult.profilePath, '/profiles/alpha.json');
    expect(syncLines, contains('sync:sync_all.ps1'));
    expect(provider.runSyncCalls, hasLength(1));
    expect(provider.runSyncCalls.single.scriptName, 'sync_all.ps1');

    final profile = refreshedWorkspace.activeProfile;
    await container
        .read(repoIntelligenceBridgeControllerProvider)
        .openModuleHome();
    await container
        .read(repoIntelligenceBridgeControllerProvider)
        .openProfilesFolder();
    await container
        .read(repoIntelligenceBridgeControllerProvider)
        .openExportsFolder(profile);
    await container
        .read(repoIntelligenceBridgeControllerProvider)
        .openObsidianVault(profile);
    await container
        .read(repoIntelligenceBridgeControllerProvider)
        .openSyncLog();
    await container
        .read(repoIntelligenceBridgeControllerProvider)
        .openStateFile();

    expect(
      provider.openCalls,
      containsAll(<String>[
        'module_home',
        'profiles_folder',
        'exports:/exports/alpha',
        'obsidian:/vault/alpha',
        'sync_log',
        'state_file',
      ]),
    );
  });

  test('legacy provider delegates to the concrete service', () async {
    final service = TrackingRepoIntelligenceBridgeService();
    final provider = LegacyRepoIntelligenceBridgeProvider(service);

    final workspace = await provider.loadWorkspace();
    expect(workspace.activeProfile.fileName, 'tracked.json');
    expect(service.loadWorkspaceCount, 1);

    final result = await provider.runSync(
      profile: workspace.activeProfile,
      scriptName: 'sync_all.ps1',
      onOutputLine: (line) => service.syncLines.add(line),
    );
    expect(result.scriptName, 'sync_all.ps1');
    expect(service.runSyncCalls, 1);
    expect(service.syncLines, contains('sync:sync_all.ps1'));

    await provider.saveState(
      const RepoIntelligenceBridgeState(
        activeProfileFile: 'tracked.json',
        dashboardExportRoot: '/exports/tracked',
        obsidianVaultPath: '/vault/tracked',
        moduleHomePath: '/module/home/tracked',
        lastSyncAt: '2026-08-18T12:00:00Z',
      ),
    );
    expect(service.savedStates, hasLength(1));
    expect(service.savedStates.single.activeProfileFile, 'tracked.json');

    await provider.openModuleHome();
    await provider.openProfilesFolder();
    await provider.openExportsFolder(workspace.activeProfile);
    await provider.openObsidianVault(workspace.activeProfile);
    await provider.openSyncLog();
    await provider.openStateFile();
    expect(service.openCalls, hasLength(6));
  });
}

class FakeRepoIntelligenceBridgeProvider
    extends RepoIntelligenceBridgeProvider {
  FakeRepoIntelligenceBridgeProvider()
    : _workspace = _buildWorkspace(
        state: const RepoIntelligenceBridgeState(
          activeProfileFile: 'alpha.json',
          dashboardExportRoot: '/exports/alpha',
          obsidianVaultPath: '/vault/alpha',
          moduleHomePath: '/module/home',
          lastSyncAt: '2026-08-18T08:00:00Z',
        ),
      );

  RepoIntelligenceBridgeWorkspace _workspace;
  int loadWorkspaceCount = 0;
  final List<RepoIntelligenceBridgeState> savedStates =
      <RepoIntelligenceBridgeState>[];
  final List<RunSyncCallRecord> runSyncCalls = <RunSyncCallRecord>[];
  final List<String> openCalls = <String>[];

  @override
  Future<RepoIntelligenceBridgeWorkspace> loadWorkspace() async {
    loadWorkspaceCount++;
    return _workspace;
  }

  @override
  Future<void> saveState(RepoIntelligenceBridgeState state) async {
    savedStates.add(state);
    _workspace = _buildWorkspace(state: state);
  }

  @override
  Future<RepoIntelligenceBridgeSyncResult> runSync({
    required RepoIntelligenceBridgeProfile profile,
    required String scriptName,
    void Function(String line)? onOutputLine,
  }) async {
    runSyncCalls.add(
      RunSyncCallRecord(profile: profile, scriptName: scriptName),
    );
    onOutputLine?.call('sync:$scriptName');
    return RepoIntelligenceBridgeSyncResult(
      scriptName: scriptName,
      scriptPath: '/scripts/$scriptName',
      profilePath: '/profiles/${profile.fileName}',
      startedAt: DateTime.utc(2026, 8, 18, 8, 0, 0),
      finishedAt: DateTime.utc(2026, 8, 18, 8, 0, 2),
      exitCode: 0,
      stdoutLines: <String>['sync:$scriptName'],
      stderrLines: const <String>[],
      logPath: '/logs/sync.log',
    );
  }

  @override
  Future<void> openModuleHome() async {
    openCalls.add('module_home');
  }

  @override
  Future<void> openProfilesFolder() async {
    openCalls.add('profiles_folder');
  }

  @override
  Future<void> openExportsFolder(RepoIntelligenceBridgeProfile profile) async {
    openCalls.add('exports:${profile.dashboardExportPath}');
  }

  @override
  Future<void> openObsidianVault(RepoIntelligenceBridgeProfile profile) async {
    openCalls.add('obsidian:${profile.obsidianVaultPath}');
  }

  @override
  Future<void> openSyncLog() async {
    openCalls.add('sync_log');
  }

  @override
  Future<void> openStateFile() async {
    openCalls.add('state_file');
  }
}

class TrackingRepoIntelligenceBridgeService
    extends RepoIntelligenceBridgeService {
  TrackingRepoIntelligenceBridgeService()
    : super(workingDirectory: Directory.systemTemp);

  int loadWorkspaceCount = 0;
  int runSyncCalls = 0;
  final List<RepoIntelligenceBridgeState> savedStates =
      <RepoIntelligenceBridgeState>[];
  final List<String> syncLines = <String>[];
  final List<String> openCalls = <String>[];

  @override
  Future<RepoIntelligenceBridgeWorkspace> loadWorkspace() async {
    loadWorkspaceCount++;
    final profile = RepoIntelligenceBridgeProfile(
      fileName: 'tracked.json',
      projectName: 'Tracked Project',
      projectType: 'repo',
      repoRoot: '/repo/root',
      sourceOfTruth: '/source/of/truth',
      obsidianVaultPath: '/vault/tracked',
      obsidianProjectFolder: '/vault/tracked/project',
      dashboardExportPath: '/exports/tracked',
      ignore: const <String>[],
      lockedRules: const <String>[],
      safeAiPermissions: const <String>[],
      blockedAiPermissions: const <String>[],
    );
    final state = const RepoIntelligenceBridgeState(
      activeProfileFile: 'tracked.json',
      dashboardExportRoot: '/exports/tracked',
      obsidianVaultPath: '/vault/tracked',
      moduleHomePath: '/module/home/tracked',
      lastSyncAt: '2026-08-18T08:00:00Z',
    );
    return RepoIntelligenceBridgeWorkspace(
      profiles: <RepoIntelligenceBridgeProfile>[profile],
      state: state,
      activeProfile: profile,
      bundle: const RepoIntelligenceBridgeExportBundle(
        projectStatus: null,
        nextActions: <RepoIntelligenceBridgeNextAction>[],
        tasks: <RepoIntelligenceBridgeTask>[],
        risks: <RepoIntelligenceBridgeRisk>[],
        decisions: <RepoIntelligenceBridgeDecision>[],
        timeline: <RepoIntelligenceBridgeTimelineItem>[],
        repoHealth: null,
        aiContext: null,
        syncManifest: null,
      ),
      syncLogLines: const <String>[],
      lastSyncTime: DateTime.parse('2026-08-18T08:00:00Z'),
      exportsDirectory: '/exports/tracked',
      moduleHomePath: '/module/home/tracked',
      obsidianVaultPath: '/vault/tracked',
    );
  }

  @override
  Future<void> saveState(RepoIntelligenceBridgeState state) async {
    savedStates.add(state);
  }

  @override
  Future<RepoIntelligenceBridgeSyncResult> runSync({
    required RepoIntelligenceBridgeProfile profile,
    required String scriptName,
    void Function(String line)? onOutputLine,
  }) async {
    runSyncCalls++;
    onOutputLine?.call('sync:$scriptName');
    return RepoIntelligenceBridgeSyncResult(
      scriptName: scriptName,
      scriptPath: '/scripts/$scriptName',
      profilePath: '/profiles/${profile.fileName}',
      startedAt: DateTime.utc(2026, 8, 18, 8, 0, 0),
      finishedAt: DateTime.utc(2026, 8, 18, 8, 0, 3),
      exitCode: 0,
      stdoutLines: <String>['sync:$scriptName'],
      stderrLines: const <String>[],
      logPath: '/logs/sync.log',
    );
  }

  @override
  Future<void> openModuleHome() async {
    openCalls.add('module_home');
  }

  @override
  Future<void> openProfilesFolder() async {
    openCalls.add('profiles_folder');
  }

  @override
  Future<void> openExportsFolder(RepoIntelligenceBridgeProfile profile) async {
    openCalls.add('exports:${profile.dashboardExportPath}');
  }

  @override
  Future<void> openObsidianVault(RepoIntelligenceBridgeProfile profile) async {
    openCalls.add('obsidian:${profile.obsidianVaultPath}');
  }

  @override
  Future<void> openSyncLog() async {
    openCalls.add('sync_log');
  }

  @override
  Future<void> openStateFile() async {
    openCalls.add('state_file');
  }
}

class RunSyncCallRecord {
  const RunSyncCallRecord({required this.profile, required this.scriptName});

  final RepoIntelligenceBridgeProfile profile;
  final String scriptName;
}

RepoIntelligenceBridgeWorkspace _buildWorkspace({
  required RepoIntelligenceBridgeState state,
}) {
  final profile = RepoIntelligenceBridgeProfile(
    fileName: 'alpha.json',
    projectName: 'Alpha Project',
    projectType: 'repo',
    repoRoot: '/repo/root',
    sourceOfTruth: '/source/of/truth',
    obsidianVaultPath: '/vault/alpha',
    obsidianProjectFolder: '/vault/alpha/project',
    dashboardExportPath: '/exports/alpha',
    ignore: const <String>[],
    lockedRules: const <String>[],
    safeAiPermissions: const <String>[],
    blockedAiPermissions: const <String>[],
  );

  return RepoIntelligenceBridgeWorkspace(
    profiles: <RepoIntelligenceBridgeProfile>[profile],
    state: state,
    activeProfile: profile,
    bundle: const RepoIntelligenceBridgeExportBundle(
      projectStatus: null,
      nextActions: <RepoIntelligenceBridgeNextAction>[],
      tasks: <RepoIntelligenceBridgeTask>[],
      risks: <RepoIntelligenceBridgeRisk>[],
      decisions: <RepoIntelligenceBridgeDecision>[],
      timeline: <RepoIntelligenceBridgeTimelineItem>[],
      repoHealth: null,
      aiContext: null,
      syncManifest: null,
    ),
    syncLogLines: const <String>[],
    lastSyncTime: DateTime.parse('2026-08-18T08:00:00Z'),
    exportsDirectory: state.dashboardExportRoot.isNotEmpty
        ? state.dashboardExportRoot
        : '/exports/alpha',
    moduleHomePath: state.moduleHomePath,
    obsidianVaultPath: state.obsidianVaultPath,
  );
}
