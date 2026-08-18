import 'package:path/path.dart' as path;

import '../data/repo_intelligence_bridge_models.dart';
import '../data/repo_intelligence_bridge_service.dart';
import 'local_repo_bridge_provider.dart';

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
  const LegacyRepoIntelligenceBridgeProvider({
    required RepoIntelligenceBridgeService service,
    required LocalRepoBridgeProvider localProvider,
  }) : _service = service,
       _localProvider = localProvider;

  final RepoIntelligenceBridgeService _service;
  final LocalRepoBridgeProvider _localProvider;

  @override
  Future<RepoIntelligenceBridgeWorkspace> loadWorkspace() async {
    final profiles = await _localProvider.loadProfiles();
    final state = await _localProvider.loadState();
    final activeProfile = _resolveEffectiveProfile(profiles, state);
    final bundle = await _localProvider.loadExportsForProfile(activeProfile);
    final syncLogLines = await _localProvider.loadSyncLogLines();
    final lastSyncTime = _resolveLastSyncTime(
      state: state,
      bundle: bundle,
      syncLogLines: syncLogLines,
    );

    return RepoIntelligenceBridgeWorkspace(
      profiles: profiles,
      state: state,
      activeProfile: activeProfile,
      bundle: bundle,
      syncLogLines: syncLogLines,
      lastSyncTime: lastSyncTime,
      exportsDirectory: state.dashboardExportRoot.isNotEmpty
          ? state.dashboardExportRoot
          : activeProfile.dashboardExportPath,
      moduleHomePath: state.moduleHomePath.isNotEmpty
          ? state.moduleHomePath
          : _localProvider.moduleRootDirectory().path,
      obsidianVaultPath: state.obsidianVaultPath.isNotEmpty
          ? state.obsidianVaultPath
          : activeProfile.obsidianVaultPath,
    );
  }

  @override
  Future<void> saveState(RepoIntelligenceBridgeState state) {
    return _localProvider.saveState(state);
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
    return _localProvider.openModuleHome();
  }

  @override
  Future<void> openProfilesFolder() {
    return _localProvider.openProfilesFolder();
  }

  @override
  Future<void> openExportsFolder(RepoIntelligenceBridgeProfile profile) {
    return _localProvider.openExportsFolder(profile);
  }

  @override
  Future<void> openObsidianVault(RepoIntelligenceBridgeProfile profile) {
    return _localProvider.openObsidianVault(profile);
  }

  @override
  Future<void> openSyncLog() {
    return _localProvider.openSyncLog();
  }

  @override
  Future<void> openStateFile() {
    return _localProvider.openStateFile();
  }
}

RepoIntelligenceBridgeProfile _resolveEffectiveProfile(
  List<RepoIntelligenceBridgeProfile> profiles,
  RepoIntelligenceBridgeState state,
) {
  if (profiles.isNotEmpty) {
    for (final profile in profiles) {
      if (profile.fileName == state.activeProfileFile) {
        return profile;
      }
    }

    final preferred = profiles.where(
      (profile) => profile.fileName == 'new_earth_dashboard.json',
    );
    if (preferred.isNotEmpty) {
      return preferred.first;
    }

    return profiles.first;
  }

  return RepoIntelligenceBridgeProfile(
    fileName: state.activeProfileFile,
    projectName: path.basenameWithoutExtension(state.activeProfileFile),
    projectType: '',
    repoRoot: '.',
    sourceOfTruth: '',
    obsidianVaultPath: state.obsidianVaultPath,
    obsidianProjectFolder: '',
    dashboardExportPath: path.join(
      state.dashboardExportRoot,
      path.basenameWithoutExtension(state.activeProfileFile),
    ),
    ignore: const <String>[],
    lockedRules: const <String>[],
    safeAiPermissions: const <String>[],
    blockedAiPermissions: const <String>[],
  );
}

DateTime? _resolveLastSyncTime({
  required RepoIntelligenceBridgeState state,
  required RepoIntelligenceBridgeExportBundle bundle,
  required List<String> syncLogLines,
}) {
  DateTime? parsed(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value.trim());
  }

  final stateSync = parsed(state.lastSyncAt);
  if (stateSync != null) {
    return stateSync;
  }

  final manifestSync = parsed(bundle.syncManifest?.generatedAt);
  if (manifestSync != null) {
    return manifestSync;
  }

  for (final line in syncLogLines.reversed) {
    final spaceIndex = line.indexOf(' ');
    if (spaceIndex <= 0) {
      continue;
    }
    final candidate = DateTime.tryParse(line.substring(0, spaceIndex));
    if (candidate != null) {
      return candidate;
    }
  }

  return null;
}
