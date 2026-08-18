import '../data/repo_intelligence_bridge_models.dart';
import '../data/repo_intelligence_bridge_service.dart';

abstract class LocalRepoBridgeProvider {
  const LocalRepoBridgeProvider();

  Future<RepoIntelligenceBridgeExportBundle> loadExportsForProfile(
    RepoIntelligenceBridgeProfile profile,
  );

  Future<List<RepoIntelligenceBridgeProfile>> loadProfiles();

  Future<RepoIntelligenceBridgeState> loadState();

  Future<void> saveState(RepoIntelligenceBridgeState state);

  Future<List<String>> loadSyncLogLines({int limit = 20});
}

class LegacyLocalRepoBridgeProvider extends LocalRepoBridgeProvider {
  const LegacyLocalRepoBridgeProvider(this._service);

  final RepoIntelligenceBridgeService _service;

  @override
  Future<RepoIntelligenceBridgeExportBundle> loadExportsForProfile(
    RepoIntelligenceBridgeProfile profile,
  ) {
    return _service.loadExportsForProfile(profile);
  }

  @override
  Future<List<RepoIntelligenceBridgeProfile>> loadProfiles() {
    return _service.loadProfiles();
  }

  @override
  Future<RepoIntelligenceBridgeState> loadState() {
    return _service.loadState();
  }

  @override
  Future<void> saveState(RepoIntelligenceBridgeState state) {
    return _service.saveState(state);
  }

  @override
  Future<List<String>> loadSyncLogLines({int limit = 20}) {
    return _service.loadSyncLogLines(limit: limit);
  }
}
