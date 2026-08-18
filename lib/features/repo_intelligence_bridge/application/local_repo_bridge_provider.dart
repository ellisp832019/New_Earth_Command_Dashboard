import '../data/repo_intelligence_bridge_models.dart';
import '../data/repo_intelligence_bridge_service.dart';

abstract class LocalRepoBridgeProvider {
  const LocalRepoBridgeProvider();

  Future<RepoIntelligenceBridgeExportBundle> loadExportsForProfile(
    RepoIntelligenceBridgeProfile profile,
  );
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
}
