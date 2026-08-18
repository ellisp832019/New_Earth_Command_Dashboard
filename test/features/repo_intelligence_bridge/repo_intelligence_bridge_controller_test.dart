import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/repo_intelligence_bridge/application/local_repo_bridge_provider.dart';
import 'package:new_earth_command_dashboard/features/repo_intelligence_bridge/application/repo_intelligence_bridge_controller.dart';
import 'package:new_earth_command_dashboard/features/repo_intelligence_bridge/data/repo_intelligence_bridge_models.dart';
import 'package:new_earth_command_dashboard/features/repo_intelligence_bridge/data/repo_intelligence_bridge_service.dart';

void main() {
  test(
    'loadProfiles, loadState, and loadSyncLogLines can be faked through the local provider seam',
    () async {
      final service = TrackingRepoIntelligenceBridgeService();
      final localProvider = FakeLocalRepoBridgeProvider(
        profiles: <RepoIntelligenceBridgeProfile>[
          _trackedProfile('/exports/tracked', '/vault/tracked'),
        ],
        state: const RepoIntelligenceBridgeState(
          activeProfileFile: 'tracked.json',
          dashboardExportRoot: '/exports/tracked',
          obsidianVaultPath: '/vault/tracked',
          moduleHomePath: '/module/root/tracked',
          lastSyncAt: '2026-08-18T08:00:00Z',
        ),
        bundle: const RepoIntelligenceBridgeExportBundle(
          projectStatus: RepoIntelligenceBridgeProjectStatus(
            project: 'Fake Project',
            type: 'repo',
            status: 'green',
            phase: 'Build',
            health: 'good',
            healthScore: 99,
            currentFocus: 'Fake seam',
            generatedAt: '2026-08-18T10:00:00Z',
            repoRoot: '/repo/root',
          ),
          nextActions: <RepoIntelligenceBridgeNextAction>[
            RepoIntelligenceBridgeNextAction(
              title: 'Fake export seam',
              priority: 'High',
              status: 'Open',
            ),
          ],
          tasks: <RepoIntelligenceBridgeTask>[],
          risks: <RepoIntelligenceBridgeRisk>[],
          decisions: <RepoIntelligenceBridgeDecision>[],
          timeline: <RepoIntelligenceBridgeTimelineItem>[],
          repoHealth: RepoIntelligenceBridgeRepoHealth(
            health: 'good',
            score: 99,
            totalScannedFiles: 1,
            todoMarkers: 0,
            checks: <RepoIntelligenceBridgeRepoHealthCheck>[],
            generatedAt: '2026-08-18T10:00:00Z',
          ),
          aiContext: RepoIntelligenceBridgeAiContext(
            projectName: 'Fake Project',
            sourceOfTruth: '/repo/root',
            generatedAt: '2026-08-18T10:00:00Z',
            lockedRules: <String>[],
            safeAiPermissions: <String>[],
            blockedAiPermissions: <String>[],
            humanApprovalRequired: <String>[],
          ),
          syncManifest: null,
        ),
        syncLogLines: const <String>['2026-08-18T07:45:00Z local sync log'],
      );

      final container = ProviderContainer(
        overrides: [
          repoIntelligenceBridgeServiceProvider.overrideWithValue(service),
          localRepoBridgeProvider.overrideWithValue(localProvider),
        ],
      );
      addTearDown(container.dispose);

      final workspace = await container.read(
        repoIntelligenceBridgeWorkspaceProvider.future,
      );

      expect(workspace.bundle.projectStatus?.project, 'Fake Project');
      expect(workspace.bundle.repoHealth?.score, 99);
      expect(workspace.bundle.nextActions.single.title, 'Fake export seam');
      expect(localProvider.loadProfilesCalls, 1);
      expect(localProvider.loadStateCalls, 1);
      expect(localProvider.loadExportsCalls, 1);
      expect(localProvider.loadSyncLogLinesCalls, 1);
      expect(localProvider.moduleRootDirectoryCalls, 0);
      expect(service.loadProfilesCalls, 0);
      expect(service.loadStateCalls, 0);
      expect(service.loadSyncLogLinesCalls, 0);
      expect(service.moduleRootDirectoryCalls, 0);
    },
  );

  test(
    'moduleRootDirectory can be faked through the local provider seam',
    () async {
      final service = TrackingRepoIntelligenceBridgeService();
      final localProvider = FakeLocalRepoBridgeProvider(
        state: const RepoIntelligenceBridgeState(
          activeProfileFile: 'tracked.json',
          dashboardExportRoot: '/exports/tracked',
          obsidianVaultPath: '/vault/tracked',
          moduleHomePath: '',
          lastSyncAt: '2026-08-18T08:00:00Z',
        ),
        moduleRootDirectoryValue: Directory('/module/root/from-local-seam'),
      );

      final container = ProviderContainer(
        overrides: [
          repoIntelligenceBridgeServiceProvider.overrideWithValue(service),
          localRepoBridgeProvider.overrideWithValue(localProvider),
        ],
      );
      addTearDown(container.dispose);

      final workspace = await container.read(
        repoIntelligenceBridgeWorkspaceProvider.future,
      );

      expect(workspace.moduleHomePath, '/module/root/from-local-seam');
      expect(localProvider.moduleRootDirectoryCalls, 1);
      expect(service.moduleRootDirectoryCalls, 0);
      expect(localProvider.loadProfilesCalls, 1);
      expect(localProvider.loadStateCalls, 1);
      expect(localProvider.loadExportsCalls, 1);
      expect(localProvider.loadSyncLogLinesCalls, 1);
      expect(service.loadProfilesCalls, 0);
      expect(service.loadStateCalls, 0);
      expect(service.loadSyncLogLinesCalls, 0);
      expect(service.moduleRootDirectoryCalls, 0);
    },
  );

  test('workspace export assembly remains semantically identical', () async {
    final service = TrackingRepoIntelligenceBridgeService();
    final localProvider = FakeLocalRepoBridgeProvider();

    final container = ProviderContainer(
      overrides: [
        repoIntelligenceBridgeServiceProvider.overrideWithValue(service),
        localRepoBridgeProvider.overrideWithValue(localProvider),
      ],
    );
    addTearDown(container.dispose);

    final workspace = await container.read(
      repoIntelligenceBridgeWorkspaceProvider.future,
    );

    expect(workspace.state.activeProfileFile, 'tracked.json');
    expect(workspace.activeProfile.fileName, 'tracked.json');
    expect(workspace.exportsDirectory, '/exports/tracked');
    expect(workspace.moduleHomePath, '/module/root/tracked');
    expect(workspace.obsidianVaultPath, '/vault/tracked');
    expect(workspace.lastSyncTime, DateTime.parse('2026-08-18T08:00:00Z'));
    expect(workspace.bundle.projectStatus?.project, 'Tracked Project');
    expect(workspace.bundle.repoHealth?.score, 87);
    expect(localProvider.loadProfilesCalls, 1);
    expect(localProvider.loadStateCalls, 1);
    expect(localProvider.loadExportsCalls, 1);
    expect(localProvider.loadSyncLogLinesCalls, 1);
    expect(localProvider.moduleRootDirectoryCalls, 0);
    expect(service.loadProfilesCalls, 0);
    expect(service.loadStateCalls, 0);
    expect(service.loadSyncLogLinesCalls, 0);
    expect(service.moduleRootDirectoryCalls, 0);
  });

  test('non-export methods continue through the legacy service path', () async {
    final service = TrackingRepoIntelligenceBridgeService();
    final localProvider = FakeLocalRepoBridgeProvider(service: service);

    final container = ProviderContainer(
      overrides: [
        repoIntelligenceBridgeServiceProvider.overrideWithValue(service),
        localRepoBridgeProvider.overrideWithValue(localProvider),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(repoIntelligenceBridgeControllerProvider);
    await controller.setActiveProfile('beta.json');
    await controller.updateState(
      state: const RepoIntelligenceBridgeState(
        activeProfileFile: 'beta.json',
        dashboardExportRoot: '/exports/beta',
        obsidianVaultPath: '/vault/beta',
        moduleHomePath: '/module/root/beta',
        lastSyncAt: '2026-08-18T09:00:00Z',
      ),
    );

    final syncLines = <String>[];
    await controller.runFullSync(onOutputLine: syncLines.add);
    await controller.openModuleHome();
    await controller.openProfilesFolder();
    await controller.openExportsFolder(
      _trackedProfile('/exports/beta', '/vault/beta'),
    );
    await controller.openObsidianVault(
      _trackedProfile('/exports/beta', '/vault/beta'),
    );
    await controller.openSyncLog();
    await controller.openStateFile();

    expect(service.saveStateCalls, 2);
    expect(service.runSyncCalls, 1);
    expect(service.openModuleHomeCalls, 1);
    expect(service.openProfilesFolderCalls, 1);
    expect(service.openExportsFolderCalls, 1);
    expect(service.openObsidianVaultCalls, 1);
    expect(service.openSyncLogCalls, 1);
    expect(service.openStateFileCalls, 1);
    expect(syncLines, contains('sync:sync_all.ps1'));
    expect(localProvider.loadExportsCalls, 2);
    expect(localProvider.loadProfilesCalls, 2);
    expect(localProvider.loadStateCalls, 2);
    expect(localProvider.loadSyncLogLinesCalls, 2);
    expect(localProvider.moduleRootDirectoryCalls, 0);
    expect(service.loadProfilesCalls, 0);
    expect(service.loadStateCalls, 0);
    expect(service.loadSyncLogLinesCalls, 0);
    expect(service.moduleRootDirectoryCalls, 0);
  });

  test(
    'legacy local provider delegates loadExportsForProfile, loadProfiles, and loadState correctly',
    () async {
      final service = TrackingRepoIntelligenceBridgeService();
      final provider = LegacyLocalRepoBridgeProvider(service);

      final profiles = await provider.loadProfiles();
      final state = await provider.loadState();
      final logLines = await provider.loadSyncLogLines();
      final bundle = await provider.loadExportsForProfile(
        _trackedProfile('/exports/tracked', '/vault/tracked'),
      );

      expect(profiles.single.fileName, 'tracked.json');
      expect(state.activeProfileFile, 'tracked.json');
      expect(logLines.single, '2026-08-18T08:00:00Z tracked sync log');
      expect(bundle.projectStatus?.project, 'Tracked Project');
      expect(service.loadProfilesCalls, 1);
      expect(service.loadStateCalls, 1);
      expect(service.loadSyncLogLinesCalls, 1);
      expect(service.loadExportsCalls, 1);
    },
  );

  test(
    'saveState delegates through the local provider seam unchanged',
    () async {
      final service = TrackingRepoIntelligenceBridgeService();
      final localProvider = FakeLocalRepoBridgeProvider(service: service);

      final container = ProviderContainer(
        overrides: [
          repoIntelligenceBridgeServiceProvider.overrideWithValue(service),
          localRepoBridgeProvider.overrideWithValue(localProvider),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        repoIntelligenceBridgeControllerProvider,
      );
      const state = RepoIntelligenceBridgeState(
        activeProfileFile: 'saved.json',
        dashboardExportRoot: '/exports/saved',
        obsidianVaultPath: '/vault/saved',
        moduleHomePath: '/module/root/saved',
        lastSyncAt: '2026-08-18T11:00:00Z',
      );

      await controller.updateState(state: state);

      expect(localProvider.saveStateCalls, 1);
      expect(service.saveStateCalls, 1);
      expect(identical(localProvider.savedStates.single, state), isTrue);
      expect(identical(service.savedStates.single, state), isTrue);
      expect(service.savedStates.single.dashboardExportRoot, '/exports/saved');
      expect(service.savedStates.single.obsidianVaultPath, '/vault/saved');
      expect(service.savedStates.single.moduleHomePath, '/module/root/saved');
      expect(service.savedStates.single.lastSyncAt, '2026-08-18T11:00:00Z');
    },
  );

  test('local provider seam does not import NEOS', () {
    final source = File(
      'lib/features/repo_intelligence_bridge/application/local_repo_bridge_provider.dart',
    ).readAsStringSync();

    expect(source.toLowerCase(), isNot(contains('neos')));
  });
}

class FakeLocalRepoBridgeProvider extends LocalRepoBridgeProvider {
  FakeLocalRepoBridgeProvider({
    this.service,
    List<RepoIntelligenceBridgeProfile>? profiles,
    RepoIntelligenceBridgeState? state,
    RepoIntelligenceBridgeExportBundle? bundle,
    List<String>? syncLogLines,
    Directory? moduleRootDirectoryValue,
  }) : _profiles =
           profiles ??
           <RepoIntelligenceBridgeProfile>[
             _trackedProfile('/exports/tracked', '/vault/tracked'),
           ],
       _state =
           state ??
           const RepoIntelligenceBridgeState(
             activeProfileFile: 'tracked.json',
             dashboardExportRoot: '/exports/tracked',
             obsidianVaultPath: '/vault/tracked',
             moduleHomePath: '/module/root/tracked',
             lastSyncAt: '2026-08-18T08:00:00Z',
           ),
       _bundle =
           bundle ??
           const RepoIntelligenceBridgeExportBundle(
             projectStatus: RepoIntelligenceBridgeProjectStatus(
               project: 'Tracked Project',
               type: 'repo',
               status: 'green',
               phase: 'Build',
               health: 'good',
               healthScore: 87,
               currentFocus: 'Tracked Project',
               generatedAt: '2026-08-18T08:00:00Z',
               repoRoot: '/repo/root',
             ),
             nextActions: <RepoIntelligenceBridgeNextAction>[
               RepoIntelligenceBridgeNextAction(
                 title: 'Track delegation',
                 priority: 'High',
                 status: 'Open',
               ),
             ],
             tasks: <RepoIntelligenceBridgeTask>[],
             risks: <RepoIntelligenceBridgeRisk>[],
             decisions: <RepoIntelligenceBridgeDecision>[],
             timeline: <RepoIntelligenceBridgeTimelineItem>[],
             repoHealth: RepoIntelligenceBridgeRepoHealth(
               health: 'good',
               score: 87,
               totalScannedFiles: 12,
               todoMarkers: 1,
               checks: <RepoIntelligenceBridgeRepoHealthCheck>[],
               generatedAt: '2026-08-18T08:00:00Z',
             ),
             aiContext: RepoIntelligenceBridgeAiContext(
               projectName: 'Tracked Project',
               sourceOfTruth: '/source/of/truth',
               generatedAt: '2026-08-18T08:00:00Z',
               lockedRules: <String>['local-first'],
               safeAiPermissions: <String>['read_only'],
               blockedAiPermissions: <String>['write'],
               humanApprovalRequired: <String>['sync'],
             ),
             syncManifest: null,
           ),
       _syncLogLines =
           syncLogLines ??
           const <String>['2026-08-18T08:00:00Z tracked sync log'],
       _moduleRootDirectory =
           moduleRootDirectoryValue ?? Directory('/module/root/tracked');

  final TrackingRepoIntelligenceBridgeService? service;
  final List<RepoIntelligenceBridgeProfile> _profiles;
  final RepoIntelligenceBridgeState _state;
  final RepoIntelligenceBridgeExportBundle _bundle;
  final List<String> _syncLogLines;
  final Directory _moduleRootDirectory;
  final List<RepoIntelligenceBridgeState> savedStates =
      <RepoIntelligenceBridgeState>[];
  int loadProfilesCalls = 0;
  int loadStateCalls = 0;
  int loadExportsCalls = 0;
  int loadSyncLogLinesCalls = 0;
  int moduleRootDirectoryCalls = 0;
  int saveStateCalls = 0;

  @override
  Future<List<RepoIntelligenceBridgeProfile>> loadProfiles() async {
    loadProfilesCalls++;
    return _profiles;
  }

  @override
  Future<RepoIntelligenceBridgeState> loadState() async {
    loadStateCalls++;
    return _state;
  }

  @override
  Future<RepoIntelligenceBridgeExportBundle> loadExportsForProfile(
    RepoIntelligenceBridgeProfile profile,
  ) async {
    loadExportsCalls++;
    return _bundle;
  }

  @override
  Future<List<String>> loadSyncLogLines({int limit = 20}) async {
    loadSyncLogLinesCalls++;
    if (_syncLogLines.length <= limit) {
      return _syncLogLines;
    }
    return _syncLogLines.sublist(_syncLogLines.length - limit);
  }

  @override
  Directory moduleRootDirectory() {
    moduleRootDirectoryCalls++;
    return _moduleRootDirectory;
  }

  @override
  Future<void> saveState(RepoIntelligenceBridgeState state) async {
    saveStateCalls++;
    savedStates.add(state);
    await service?.saveState(state);
  }
}

class TrackingRepoIntelligenceBridgeService
    extends RepoIntelligenceBridgeService {
  TrackingRepoIntelligenceBridgeService()
    : super(workingDirectory: Directory.systemTemp);

  int loadProfilesCalls = 0;
  int loadStateCalls = 0;
  int loadSyncLogLinesCalls = 0;
  int loadExportsCalls = 0;
  int saveStateCalls = 0;
  int moduleRootDirectoryCalls = 0;
  final List<RepoIntelligenceBridgeState> savedStates =
      <RepoIntelligenceBridgeState>[];
  int runSyncCalls = 0;
  int openModuleHomeCalls = 0;
  int openProfilesFolderCalls = 0;
  int openExportsFolderCalls = 0;
  int openObsidianVaultCalls = 0;
  int openSyncLogCalls = 0;
  int openStateFileCalls = 0;

  @override
  Directory moduleRootDirectory() {
    moduleRootDirectoryCalls++;
    return Directory('/module/root/tracked');
  }

  @override
  Future<List<RepoIntelligenceBridgeProfile>> loadProfiles() async {
    loadProfilesCalls++;
    return <RepoIntelligenceBridgeProfile>[
      _trackedProfile('/exports/tracked', '/vault/tracked'),
    ];
  }

  @override
  Future<RepoIntelligenceBridgeState> loadState() async {
    loadStateCalls++;
    return const RepoIntelligenceBridgeState(
      activeProfileFile: 'tracked.json',
      dashboardExportRoot: '/exports/tracked',
      obsidianVaultPath: '/vault/tracked',
      moduleHomePath: '/module/root/tracked',
      lastSyncAt: '2026-08-18T08:00:00Z',
    );
  }

  @override
  Future<RepoIntelligenceBridgeExportBundle> loadExportsForProfile(
    RepoIntelligenceBridgeProfile profile,
  ) async {
    loadExportsCalls++;
    return RepoIntelligenceBridgeExportBundle(
      projectStatus: RepoIntelligenceBridgeProjectStatus(
        project: 'Tracked Project',
        type: 'repo',
        status: 'green',
        phase: 'Build',
        health: 'good',
        healthScore: 87,
        currentFocus: profile.projectName,
        generatedAt: '2026-08-18T08:00:00Z',
        repoRoot: profile.repoRoot,
      ),
      nextActions: <RepoIntelligenceBridgeNextAction>[
        const RepoIntelligenceBridgeNextAction(
          title: 'Track delegation',
          priority: 'High',
          status: 'Open',
        ),
      ],
      tasks: const <RepoIntelligenceBridgeTask>[],
      risks: const <RepoIntelligenceBridgeRisk>[],
      decisions: const <RepoIntelligenceBridgeDecision>[],
      timeline: const <RepoIntelligenceBridgeTimelineItem>[],
      repoHealth: RepoIntelligenceBridgeRepoHealth(
        health: 'good',
        score: 87,
        totalScannedFiles: 12,
        todoMarkers: 1,
        checks: const <RepoIntelligenceBridgeRepoHealthCheck>[],
        generatedAt: '2026-08-18T08:00:00Z',
      ),
      aiContext: const RepoIntelligenceBridgeAiContext(
        projectName: 'Tracked Project',
        sourceOfTruth: '/source/of/truth',
        generatedAt: '2026-08-18T08:00:00Z',
        lockedRules: <String>['local-first'],
        safeAiPermissions: <String>['read_only'],
        blockedAiPermissions: <String>['write'],
        humanApprovalRequired: <String>['sync'],
      ),
      syncManifest: null,
    );
  }

  @override
  Future<List<String>> loadSyncLogLines({int limit = 20}) async {
    loadSyncLogLinesCalls++;
    return const <String>['2026-08-18T08:00:00Z tracked sync log'];
  }

  @override
  Future<void> saveState(RepoIntelligenceBridgeState state) async {
    saveStateCalls++;
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
    openModuleHomeCalls++;
  }

  @override
  Future<void> openProfilesFolder() async {
    openProfilesFolderCalls++;
  }

  @override
  Future<void> openExportsFolder(RepoIntelligenceBridgeProfile profile) async {
    openExportsFolderCalls++;
  }

  @override
  Future<void> openObsidianVault(RepoIntelligenceBridgeProfile profile) async {
    openObsidianVaultCalls++;
  }

  @override
  Future<void> openSyncLog() async {
    openSyncLogCalls++;
  }

  @override
  Future<void> openStateFile() async {
    openStateFileCalls++;
  }
}

RepoIntelligenceBridgeProfile _trackedProfile(
  String dashboardExportPath,
  String obsidianVaultPath,
) {
  return RepoIntelligenceBridgeProfile(
    fileName: 'tracked.json',
    projectName: 'Tracked Project',
    projectType: 'repo',
    repoRoot: '/repo/root',
    sourceOfTruth: '/source/of/truth',
    obsidianVaultPath: obsidianVaultPath,
    obsidianProjectFolder: '$obsidianVaultPath/project',
    dashboardExportPath: dashboardExportPath,
    ignore: const <String>[],
    lockedRules: const <String>[],
    safeAiPermissions: const <String>[],
    blockedAiPermissions: const <String>[],
  );
}
