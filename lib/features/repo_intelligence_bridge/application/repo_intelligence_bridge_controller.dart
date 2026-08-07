import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repo_intelligence_bridge_models.dart';
import '../data/repo_intelligence_bridge_service.dart';

final repoIntelligenceBridgeServiceProvider =
    Provider<RepoIntelligenceBridgeService>((ref) {
      return RepoIntelligenceBridgeService();
    });

final repoIntelligenceBridgeWorkspaceProvider =
    FutureProvider<RepoIntelligenceBridgeWorkspace>((ref) async {
      return ref.watch(repoIntelligenceBridgeServiceProvider).loadWorkspace();
    });

final repoIntelligenceBridgeControllerProvider =
    Provider<RepoIntelligenceBridgeController>((ref) {
      return RepoIntelligenceBridgeController(ref);
    });

class RepoIntelligenceBridgeController {
  RepoIntelligenceBridgeController(this._ref);

  final Ref _ref;

  RepoIntelligenceBridgeService get _service =>
      _ref.read(repoIntelligenceBridgeServiceProvider);

  Future<void> setActiveProfile(String fileName) async {
    final workspace = await _service.loadWorkspace();
    await _service.saveState(
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
    await _service.saveState(state);
    _ref.invalidate(repoIntelligenceBridgeWorkspaceProvider);
  }

  Future<RepoIntelligenceBridgeSyncResult> runValidateConfig({
    void Function(String line)? onOutputLine,
  }) async {
    final workspace = await _service.loadWorkspace();
    final result = await _service.runSync(
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
    final workspace = await _service.loadWorkspace();
    final result = await _service.runSync(
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
    final workspace = await _service.loadWorkspace();
    final result = await _service.runSync(
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
    final workspace = await _service.loadWorkspace();
    final result = await _service.runSync(
      profile: workspace.activeProfile,
      scriptName: 'sync_all.ps1',
      onOutputLine: onOutputLine,
    );
    _ref.invalidate(repoIntelligenceBridgeWorkspaceProvider);
    return result;
  }

  Future<void> openModuleHome() => _service.openModuleHome();

  Future<void> openProfilesFolder() => _service.openProfilesFolder();

  Future<void> openExportsFolder(RepoIntelligenceBridgeProfile profile) =>
      _service.openExportsFolder(profile);

  Future<void> openObsidianVault(RepoIntelligenceBridgeProfile profile) =>
      _service.openObsidianVault(profile);

  Future<void> openSyncLog() => _service.openSyncLog();

  Future<void> openStateFile() => _service.openStateFile();
}
