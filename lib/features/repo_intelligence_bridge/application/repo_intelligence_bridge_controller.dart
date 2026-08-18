import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repo_intelligence_bridge_provider.dart';
import '../data/repo_intelligence_bridge_models.dart';
import '../data/repo_intelligence_bridge_service.dart';

final repoIntelligenceBridgeServiceProvider =
    Provider<RepoIntelligenceBridgeService>((ref) {
      return RepoIntelligenceBridgeService();
    });

final repoIntelligenceBridgeWorkspaceProvider =
    FutureProvider<RepoIntelligenceBridgeWorkspace>((ref) async {
      return ref.watch(repoIntelligenceBridgeProvider).loadWorkspace();
    });

final repoIntelligenceBridgeProvider = Provider<RepoIntelligenceBridgeProvider>(
  (ref) {
    return LegacyRepoIntelligenceBridgeProvider(
      ref.watch(repoIntelligenceBridgeServiceProvider),
    );
  },
);

final repoIntelligenceBridgeControllerProvider =
    Provider<RepoIntelligenceBridgeController>((ref) {
      return RepoIntelligenceBridgeController(ref);
    });

class RepoIntelligenceBridgeController {
  RepoIntelligenceBridgeController(this._ref);

  final Ref _ref;

  RepoIntelligenceBridgeProvider get _provider =>
      _ref.read(repoIntelligenceBridgeProvider);

  Future<void> setActiveProfile(String fileName) async {
    final workspace = await _provider.loadWorkspace();
    await _provider.saveState(
      RepoIntelligenceBridgeState(
        activeProfileFile: fileName,
        dashboardExportRoot: workspace.state.dashboardExportRoot,
        obsidianVaultPath: workspace.state.obsidianVaultPath,
        moduleHomePath: workspace.state.moduleHomePath,
        lastSyncAt: workspace.state.lastSyncAt,
      ),
    );
    _ref.invalidate(repoIntelligenceBridgeWorkspaceProvider);
  }

  Future<void> updateState({required RepoIntelligenceBridgeState state}) async {
    await _provider.saveState(state);
    _ref.invalidate(repoIntelligenceBridgeWorkspaceProvider);
  }

  Future<RepoIntelligenceBridgeSyncResult> runValidateConfig({
    void Function(String line)? onOutputLine,
  }) async {
    final workspace = await _provider.loadWorkspace();
    final result = await _provider.runSync(
      profile: workspace.activeProfile,
      scriptName: 'validate_config.ps1',
      onOutputLine: onOutputLine,
    );
    _ref.invalidate(repoIntelligenceBridgeWorkspaceProvider);
    return result;
  }

  Future<RepoIntelligenceBridgeSyncResult> runObsidianSync({
    void Function(String line)? onOutputLine,
  }) async {
    final workspace = await _provider.loadWorkspace();
    final result = await _provider.runSync(
      profile: workspace.activeProfile,
      scriptName: 'sync_to_obsidian.ps1',
      onOutputLine: onOutputLine,
    );
    _ref.invalidate(repoIntelligenceBridgeWorkspaceProvider);
    return result;
  }

  Future<RepoIntelligenceBridgeSyncResult> runDashboardSync({
    void Function(String line)? onOutputLine,
  }) async {
    final workspace = await _provider.loadWorkspace();
    final result = await _provider.runSync(
      profile: workspace.activeProfile,
      scriptName: 'sync_to_dashboard.ps1',
      onOutputLine: onOutputLine,
    );
    _ref.invalidate(repoIntelligenceBridgeWorkspaceProvider);
    return result;
  }

  Future<RepoIntelligenceBridgeSyncResult> runFullSync({
    void Function(String line)? onOutputLine,
  }) async {
    final workspace = await _provider.loadWorkspace();
    final result = await _provider.runSync(
      profile: workspace.activeProfile,
      scriptName: 'sync_all.ps1',
      onOutputLine: onOutputLine,
    );
    _ref.invalidate(repoIntelligenceBridgeWorkspaceProvider);
    return result;
  }

  Future<void> openModuleHome() => _provider.openModuleHome();

  Future<void> openProfilesFolder() => _provider.openProfilesFolder();

  Future<void> openExportsFolder(RepoIntelligenceBridgeProfile profile) =>
      _provider.openExportsFolder(profile);

  Future<void> openObsidianVault(RepoIntelligenceBridgeProfile profile) =>
      _provider.openObsidianVault(profile);

  Future<void> openSyncLog() => _provider.openSyncLog();

  Future<void> openStateFile() => _provider.openStateFile();
}
