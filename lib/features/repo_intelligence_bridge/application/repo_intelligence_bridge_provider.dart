import '../data/repo_intelligence_bridge_models.dart';
import '../data/repo_intelligence_bridge_service.dart';

abstract class RepoIntelligenceBridgeProvider {
  const RepoIntelligenceBridgeProvider();

  Future<RepoIntelligenceBridgeWorkspace> loadWorkspace();

  Future<void> saveState(RepoIntelligenceBridgeState state);

  Future<RepoIntelligenceBridgeSyncResult> runSync({
    required RepoIntelligenceBridgeProfile profile,
    required String scriptName,
    void Function(String line)? onOutputLine,
  });

  Future<void> openModuleHome();

  Future<void> openProfilesFolder();

  Future<void> openExportsFolder(RepoIntelligenceBridgeProfile profile);

  Future<void> openObsidianVault(RepoIntelligenceBridgeProfile profile);

  Future<void> openSyncLog();

  Future<void> openStateFile();
}

class LegacyRepoIntelligenceBridgeProvider
    extends RepoIntelligenceBridgeProvider {
  const LegacyRepoIntelligenceBridgeProvider(this._service);

  final RepoIntelligenceBridgeService _service;

  @override
  Future<RepoIntelligenceBridgeWorkspace> loadWorkspace() {
    return _service.loadWorkspace();
  }

  @override
  Future<void> saveState(RepoIntelligenceBridgeState state) {
    return _service.saveState(state);
  }

  @override
  Future<RepoIntelligenceBridgeSyncResult> runSync({
    required RepoIntelligenceBridgeProfile profile,
    required String scriptName,
    void Function(String line)? onOutputLine,
  }) {
    return _service.runSync(
      profile: profile,
      scriptName: scriptName,
      onOutputLine: onOutputLine,
    );
  }

  @override
  Future<void> openModuleHome() {
    return _service.openModuleHome();
  }

  @override
  Future<void> openProfilesFolder() {
    return _service.openProfilesFolder();
  }

  @override
  Future<void> openExportsFolder(RepoIntelligenceBridgeProfile profile) {
    return _service.openExportsFolder(profile);
  }

  @override
  Future<void> openObsidianVault(RepoIntelligenceBridgeProfile profile) {
    return _service.openObsidianVault(profile);
  }

  @override
  Future<void> openSyncLog() {
    return _service.openSyncLog();
  }

  @override
  Future<void> openStateFile() {
    return _service.openStateFile();
  }
}
