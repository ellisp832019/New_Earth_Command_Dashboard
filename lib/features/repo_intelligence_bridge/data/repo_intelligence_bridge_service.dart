import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'repo_intelligence_bridge_models.dart';

class RepoIntelligenceBridgeService {
  RepoIntelligenceBridgeService({Directory? workingDirectory})
    : _workingDirectory = workingDirectory ?? Directory.current;

  final Directory _workingDirectory;

  Directory moduleRootDirectory() {
    return _findModuleRoot();
  }

  Future<RepoIntelligenceBridgeWorkspace> loadWorkspace() async {
    final profiles = await loadProfiles();
    final state = await loadState();
    final activeProfile = _resolveEffectiveProfile(profiles, state);
    final bundle = await loadExportsForProfile(activeProfile);
    final syncLogLines = await loadSyncLogLines();
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
          : moduleRootDirectory().path,
      obsidianVaultPath: state.obsidianVaultPath.isNotEmpty
          ? state.obsidianVaultPath
          : activeProfile.obsidianVaultPath,
    );
  }

  Future<List<RepoIntelligenceBridgeProfile>> loadProfiles() async {
    final profilesDir = _profilesDirectory();
    if (!await profilesDir.exists()) {
      return const <RepoIntelligenceBridgeProfile>[];
    }

    final entries = await profilesDir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.json'))
        .cast<File>()
        .toList();

    entries.sort((a, b) => path.basename(a.path).compareTo(path.basename(b.path)));

    final profiles = <RepoIntelligenceBridgeProfile>[];
    for (final file in entries) {
      try {
        final content = await file.readAsString();
        final decoded = jsonDecode(content);
        if (decoded is Map<String, dynamic>) {
          profiles.add(
            RepoIntelligenceBridgeProfile.fromJson(
              decoded,
              fileName: path.basename(file.path),
            ),
          );
        }
      } catch (_) {
        continue;
      }
    }
    return profiles;
  }

  Future<RepoIntelligenceBridgeState> loadState() async {
    final file = _stateFile();
    if (!await file.exists()) {
      return _defaultState();
    }

    try {
      final content = await file.readAsString();
      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic>) {
        return _stateFromJson(decoded);
      }
    } catch (_) {
      // Fall through to defaults.
    }

    return _defaultState();
  }

  Future<void> saveState(RepoIntelligenceBridgeState state) async {
    final file = _stateFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(state.toJson()),
      flush: true,
    );
  }

  Future<RepoIntelligenceBridgeExportBundle> loadExportsForProfile(
    RepoIntelligenceBridgeProfile profile,
  ) async {
    final exportDir = Directory(profile.dashboardExportPath);
    final projectStatus = await _readJsonFile(
      path.join(exportDir.path, 'project_status.json'),
      RepoIntelligenceBridgeProjectStatus.fromJson,
    );
    final nextActions = await _readListFile(
      path.join(exportDir.path, 'next_actions.json'),
      'next_actions',
      RepoIntelligenceBridgeNextAction.fromJson,
    );
    final tasks = await _readListFile(
      path.join(exportDir.path, 'tasks.json'),
      'tasks',
      RepoIntelligenceBridgeTask.fromJson,
    );
    final risks = await _readListFile(
      path.join(exportDir.path, 'risks.json'),
      'risks',
      RepoIntelligenceBridgeRisk.fromJson,
    );
    final decisions = await _readListFile(
      path.join(exportDir.path, 'decisions.json'),
      'decisions',
      RepoIntelligenceBridgeDecision.fromJson,
    );
    final timeline = await _readListFile(
      path.join(exportDir.path, 'timeline.json'),
      'timeline',
      RepoIntelligenceBridgeTimelineItem.fromJson,
    );
    final repoHealth = await _readJsonFile(
      path.join(exportDir.path, 'repo_health.json'),
      RepoIntelligenceBridgeRepoHealth.fromJson,
    );
    final aiContext = await _readJsonFile(
      path.join(exportDir.path, 'ai_context.json'),
      RepoIntelligenceBridgeAiContext.fromJson,
    );
    final syncManifest = await _readJsonFile(
      path.join(exportDir.path, 'sync_manifest.json'),
      RepoIntelligenceBridgeSyncManifest.fromJson,
    );

    return RepoIntelligenceBridgeExportBundle(
      projectStatus: projectStatus,
      nextActions: nextActions,
      tasks: tasks,
      risks: risks,
      decisions: decisions,
      timeline: timeline,
      repoHealth: repoHealth,
      aiContext: aiContext,
      syncManifest: syncManifest,
    );
  }

  Future<List<String>> loadSyncLogLines({int limit = 20}) async {
    final file = _syncLogFile();
    if (!await file.exists()) {
      return const <String>[];
    }

    try {
      final lines = await file.readAsLines();
      final nonEmpty = lines
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList(growable: false);
      if (nonEmpty.length <= limit) {
        return nonEmpty;
      }
      return nonEmpty.sublist(nonEmpty.length - limit);
    } catch (_) {
      return const <String>[];
    }
  }

  Future<String> runSync({
    required RepoIntelligenceBridgeProfile profile,
    required String scriptName,
  }) async {
    if (!Platform.isWindows) {
      throw UnsupportedError('Sync scripts are only wired on Windows.');
    }

    final script = File(
      path.join(moduleRootDirectory().path, 'scripts', scriptName),
    );
    if (!await script.exists()) {
      throw FileSystemException('Sync script not found', script.path);
    }

    await Process.run(
      'powershell.exe',
      <String>[
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        script.path,
        '-Profile',
        _profilePath(profile),
      ],
      workingDirectory: moduleRootDirectory().path,
      runInShell: false,
    );
    return script.path;
  }

  Future<void> openPath(String targetPath) async {
    if (targetPath.trim().isEmpty) {
      return;
    }

    if (Platform.isWindows) {
      await Process.start('explorer.exe', <String>[targetPath]);
      return;
    }

    if (Platform.isMacOS) {
      await Process.start('open', <String>[targetPath]);
      return;
    }

    await Process.start('xdg-open', <String>[targetPath]);
  }

  Future<void> openModuleHome() async {
    await openPath(moduleRootDirectory().path);
  }

  Future<void> openProfilesFolder() async {
    await openPath(_profilesDirectory().path);
  }

  Future<void> openExportsFolder(RepoIntelligenceBridgeProfile profile) async {
    await openPath(profile.dashboardExportPath);
  }

  Future<void> openObsidianVault(RepoIntelligenceBridgeProfile profile) async {
    await openPath(profile.obsidianVaultPath);
  }

  Future<void> openSyncLog() async {
    await openPath(_syncLogFile().path);
  }

  Future<void> openStateFile() async {
    await openPath(_stateFile().path);
  }

  Directory _findModuleRoot() {
    var current = _workingDirectory;
    while (true) {
      final candidate = Directory(
        path.join(current.path, 'modules', 'NE_REPO_INTELLIGENCE_BRIDGE'),
      );
      if (candidate.existsSync()) {
        return candidate;
      }

      final parent = current.parent;
      if (parent.path == current.path) {
        break;
      }
      current = parent;
    }

    return Directory(
      path.join(
        _workingDirectory.path,
        'modules',
        'NE_REPO_INTELLIGENCE_BRIDGE',
      ),
    );
  }

  Directory _profilesDirectory() {
    return Directory(path.join(moduleRootDirectory().path, 'profiles'));
  }

  File _stateFile() {
    return File(
      path.join(moduleRootDirectory().path, 'config', 'dashboard_state.json'),
    );
  }

  File _syncLogFile() {
    return File(path.join(moduleRootDirectory().path, 'logs', 'sync.log'));
  }

  String _profilePath(RepoIntelligenceBridgeProfile profile) {
    return path.join(_profilesDirectory().path, profile.fileName);
  }

  RepoIntelligenceBridgeState _defaultState() {
    return RepoIntelligenceBridgeState(
      activeProfileFile: 'new_earth_dashboard.json',
      dashboardExportRoot: '',
      obsidianVaultPath:
          'D:/NEW_EARTH_OMEGA_OS_PACK/09_KNOWLEDGE_VAULT_OBSIDIAN',
      moduleHomePath: moduleRootDirectory().path,
      lastSyncAt: null,
    );
  }

  RepoIntelligenceBridgeState _stateFromJson(Map<String, dynamic> json) {
    final defaults = _defaultState();
    return RepoIntelligenceBridgeState(
      activeProfileFile:
          json['active_profile_file']?.toString().trim().isNotEmpty == true
          ? json['active_profile_file'].toString()
          : defaults.activeProfileFile,
      dashboardExportRoot:
          json['dashboard_export_root']?.toString().trim().isNotEmpty == true
          ? json['dashboard_export_root'].toString()
          : defaults.dashboardExportRoot,
      obsidianVaultPath:
          json['obsidian_vault_path']?.toString().trim().isNotEmpty == true
          ? json['obsidian_vault_path'].toString()
          : defaults.obsidianVaultPath,
      moduleHomePath:
          json['module_home_path']?.toString().trim().isNotEmpty == true
          ? json['module_home_path'].toString()
          : defaults.moduleHomePath,
      lastSyncAt: json['last_sync_at']?.toString().trim().isNotEmpty == true
          ? json['last_sync_at'].toString()
          : null,
    );
  }

  RepoIntelligenceBridgeProfile _resolveEffectiveProfile(
    List<RepoIntelligenceBridgeProfile> profiles,
    RepoIntelligenceBridgeState state,
  ) {
    final resolvedProfile = _resolveActiveProfile(profiles, state);
    return resolvedProfile.copyWith(
      obsidianVaultPath:
          state.obsidianVaultPath.isNotEmpty ? state.obsidianVaultPath : resolvedProfile.obsidianVaultPath,
      dashboardExportPath: state.dashboardExportRoot.isNotEmpty
          ? state.dashboardExportRoot
          : resolvedProfile.dashboardExportPath,
    );
  }

  RepoIntelligenceBridgeProfile _resolveActiveProfile(
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

  Future<T?> _readJsonFile<T>(
    String filePath,
    T Function(Map<String, dynamic>) parser,
  ) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return null;
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        return parser(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<List<T>> _readListFile<T>(
    String filePath,
    String key,
    T Function(Map<String, dynamic>) parser,
  ) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return <T>[];
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        final rawList = decoded[key];
        if (rawList is List) {
          return rawList
              .whereType<Map<String, dynamic>>()
              .map(parser)
              .toList(growable: false);
        }
      }
    } catch (_) {
      return <T>[];
    }
    return <T>[];
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
}
