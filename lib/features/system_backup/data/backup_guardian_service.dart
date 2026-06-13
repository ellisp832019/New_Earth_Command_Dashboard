import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

enum BackupGuardianAction {
  dryRun,
  backupNow,
  verifyLatest,
  restoreDryRun,
  quickIncremental,
  dailyBackup,
  weeklySnapshot,
  monthlyArchive,
}

enum BackupGuardianHealthState { green, amber, red, grey }

class BackupGuardianConfig {
  const BackupGuardianConfig({
    required this.sourceDrive,
    required this.backupTarget,
    required this.mirrorFolder,
    required this.reportsFolder,
    required this.manifestsFolder,
    required this.restoreTestFolder,
    required this.verifyAfterBackup,
    required this.createManifest,
    required this.scheduleEnabled,
    required this.dailyBackupTime,
    required this.weeklySnapshotDay,
    required this.monthlyArchiveDay,
    required this.staleAfterDays,
    required this.quickKeep,
    required this.dailyKeep,
    required this.weeklyKeep,
    required this.monthlyKeep,
    required this.mode,
    required this.configPath,
    required this.isLocalConfig,
  });

  final String sourceDrive;
  final String backupTarget;
  final String mirrorFolder;
  final String reportsFolder;
  final String manifestsFolder;
  final String restoreTestFolder;
  final bool verifyAfterBackup;
  final bool createManifest;
  final bool scheduleEnabled;
  final String dailyBackupTime;
  final String weeklySnapshotDay;
  final int monthlyArchiveDay;
  final int staleAfterDays;
  final int quickKeep;
  final int dailyKeep;
  final int weeklyKeep;
  final int monthlyKeep;
  final String mode;
  final String configPath;
  final bool isLocalConfig;

  factory BackupGuardianConfig.fromJson({
    required Map<String, dynamic> json,
    required String configPath,
    required bool isLocalConfig,
  }) {
    String readString(String key, String fallback) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      return fallback;
    }

    bool readBool(String key, bool fallback) {
      final value = json[key];
      if (value is bool) {
        return value;
      }
      return fallback;
    }

    int readInt(String key, int fallback) {
      final value = json[key];
      if (value is int) {
        return value;
      }
      if (value is String) {
        return int.tryParse(value.trim()) ?? fallback;
      }
      return fallback;
    }

    Map<String, dynamic> readMap(String key) {
      final value = json[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
      return <String, dynamic>{};
    }

    final schedule = readMap('schedule');
    final retention = readMap('retention');

    return BackupGuardianConfig(
      sourceDrive: readString('source_drive', 'D:/'),
      backupTarget: readString('backup_target', 'E:/NEW_EARTH_BACKUP'),
      mirrorFolder: readString(
        'mirror_folder',
        'E:/NEW_EARTH_BACKUP/mirror',
      ),
      reportsFolder: readString(
        'reports_folder',
        'E:/NEW_EARTH_BACKUP/reports',
      ),
      manifestsFolder: readString(
        'manifests_folder',
        'E:/NEW_EARTH_BACKUP/manifests',
      ),
      restoreTestFolder: readString(
        'restore_test_folder',
        'D:/_RESTORE_TEST_AREA',
      ),
      verifyAfterBackup: readBool('verify_after_backup', true),
      createManifest: readBool('create_manifest', true),
      scheduleEnabled: (schedule['enabled'] is bool
              ? schedule['enabled'] as bool
              : readBool('schedule_enabled', false)),
      dailyBackupTime: schedule['daily_time'] is String &&
              (schedule['daily_time'] as String).trim().isNotEmpty
          ? (schedule['daily_time'] as String).trim()
          : readString('daily_backup_time', '02:00'),
      weeklySnapshotDay: schedule['weekly_day'] is String &&
              (schedule['weekly_day'] as String).trim().isNotEmpty
          ? (schedule['weekly_day'] as String).trim()
          : readString('weekly_snapshot_day', 'Sunday'),
      monthlyArchiveDay: schedule['monthly_day'] is int
          ? schedule['monthly_day'] as int
          : readInt('monthly_archive_day', 1),
      staleAfterDays: schedule['stale_after_days'] is int
          ? schedule['stale_after_days'] as int
          : readInt('stale_after_days', 2),
      quickKeep: retention['quick_keep'] is int
          ? retention['quick_keep'] as int
          : readInt('quick_keep', 7),
      dailyKeep: retention['daily_keep'] is int
          ? retention['daily_keep'] as int
          : readInt('daily_keep', 7),
      weeklyKeep: retention['weekly_keep'] is int
          ? retention['weekly_keep'] as int
          : readInt('weekly_keep', 4),
      monthlyKeep: retention['monthly_keep'] is int
          ? retention['monthly_keep'] as int
          : readInt('monthly_keep', 12),
      mode: readString('mode', 'mirror'),
      configPath: configPath,
      isLocalConfig: isLocalConfig,
    );
  }
}

class BackupGuardianSnapshot {
  const BackupGuardianSnapshot({
    required this.config,
    required this.statusFilePath,
    required this.statusFileExists,
    required this.sourceExists,
    required this.backupDriveExists,
    required this.mirrorFolderExists,
    required this.healthState,
    required this.latestBackupStatus,
    required this.latestReportPath,
    required this.latestManifestPath,
    required this.latestManifestExists,
    required this.verificationSummary,
    required this.verificationDetails,
    required this.restoreTestStatus,
    required this.backupSizeText,
    required this.historyFilePath,
    required this.historyEntries,
    required this.restorePoints,
    required this.scheduleSummary,
    required this.retentionSummary,
    required this.freshnessSummary,
    required this.notificationBanner,
    required this.nextSuggestedRun,
    required this.lastBackupAt,
    required this.lastVerificationAt,
    required this.statusUpdatedAt,
    required this.warnings,
    required this.errors,
    required this.healthSummary,
  });

  final BackupGuardianConfig config;
  final String statusFilePath;
  final bool statusFileExists;
  final bool sourceExists;
  final bool backupDriveExists;
  final bool mirrorFolderExists;
  final BackupGuardianHealthState healthState;
  final String latestBackupStatus;
  final String latestReportPath;
  final String latestManifestPath;
  final bool latestManifestExists;
  final String verificationSummary;
  final List<String> verificationDetails;
  final String restoreTestStatus;
  final String backupSizeText;
  final String historyFilePath;
  final List<BackupGuardianHistoryEntry> historyEntries;
  final List<BackupGuardianHistoryEntry> restorePoints;
  final String scheduleSummary;
  final String retentionSummary;
  final String freshnessSummary;
  final String notificationBanner;
  final DateTime? nextSuggestedRun;
  final DateTime? lastBackupAt;
  final DateTime? lastVerificationAt;
  final DateTime? statusUpdatedAt;
  final List<String> warnings;
  final List<String> errors;
  final String healthSummary;

  String get sourceDrive => config.sourceDrive;
  String get backupTarget => config.backupTarget;
  bool get isHealthy => healthState == BackupGuardianHealthState.green;
  bool get hasHistory => historyEntries.isNotEmpty;
}

class BackupGuardianService {
  BackupGuardianService({Directory? moduleRoot})
    : _moduleRoot = moduleRoot ??
          Directory(path.join(Directory.current.path, 'modules', 'system_backup'));

  final Directory _moduleRoot;

  File get _localConfigFile =>
      File(path.join(_moduleRoot.path, 'config', 'backup_paths.local.json'));

  File get _exampleConfigFile => File(
    path.join(_moduleRoot.path, 'config', 'backup_paths.local.json.example'),
  );

  File get _statusFile =>
      File(path.join(_moduleRoot.path, 'runtime', 'latest_status.json'));

  File get _historyFile =>
      File(path.join(_moduleRoot.path, 'runtime', 'backup_history.json'));

  Future<BackupGuardianSnapshot> loadSnapshot() async {
    final config = await _loadConfig();
    final status = await _loadStatus();
    final history = await _loadHistory();
    final sourceExists = Directory(config.sourceDrive).existsSync();
    final mirrorFolderExists = Directory(config.mirrorFolder).existsSync();
    final backupDriveRoot = path.dirname(
      config.backupTarget.replaceAll('\\', '/').trimRight(),
    );
    final backupDriveExists = Directory(backupDriveRoot).existsSync();
    final latestBackupHistory = _latestHistoryEntry(
      history.entries,
      const [
        'BackupNow',
        'QuickIncremental',
        'DailyBackup',
        'WeeklySnapshot',
        'MonthlyArchive',
      ],
    );
    final latestVerificationHistory = _latestHistoryEntry(
      history.entries,
      const ['VerifyLatest'],
    );
    final statusManifestPath = status.manifestPath.trim();
    final historyManifestPath = latestBackupHistory?.manifestPath.trim() ?? '';
    final latestManifestPath = _latestManifestPath(
      status: status,
      latestBackupHistory: latestBackupHistory,
    );
    final latestManifestExists = latestManifestPath.isNotEmpty &&
        File(latestManifestPath).existsSync();
    final mirrorStats = await _loadFolderStats(config.mirrorFolder);
    final manifest = await _loadManifest(latestManifestPath);
    final verificationReadout = _buildVerificationReadout(
      status: status,
      manifest: manifest,
      mirrorStats: mirrorStats,
      latestVerificationHistory: latestVerificationHistory,
      latestManifestPath: latestManifestPath,
      latestManifestExists: latestManifestExists,
      backupDriveRoot: backupDriveRoot,
      config: config,
    );

    final warnings = <String>[
      ...status.warnings,
      if (!config.isLocalConfig)
        'Using the module example config until backup_paths.local.json is created locally.',
      if (!status.exists)
        'No status file found yet. Run Dry Run or Backup Now to create one.',
      if (sourceExists && !backupDriveExists)
        'Waiting for the external backup drive to appear.',
      if (history.entries.isEmpty)
        'No backup history has been recorded yet.',
      if (statusManifestPath.isNotEmpty &&
          historyManifestPath.isNotEmpty &&
          statusManifestPath != historyManifestPath)
        'The status file and history record point to different manifests. The latest backup record is being used for review.',
      if (latestManifestPath.isNotEmpty && !latestManifestExists)
        'The latest manifest is recorded but the file is missing. Verify Latest can only trust a readable manifest.',
      if (latestManifestPath.isEmpty &&
          (status.exists || latestBackupHistory != null) &&
          config.verifyAfterBackup)
        'The latest backup does not have a recorded manifest yet. Verify Latest will fall back to target checks until one appears.',
    ];

    final errors = <String>[
      ...status.errors,
      if (!sourceExists) 'Source drive not found: ${config.sourceDrive}',
    ];

    final lastBackupAt = status.lastBackupAt ??
        latestBackupHistory?.finishedAt ??
        (status.mode == 'BackupNow' || status.mode == 'QuickIncremental'
            ? status.updatedAt
            : null);
    final lastVerificationAt = status.lastVerificationAt ??
        latestVerificationHistory?.finishedAt ??
        (status.mode == 'VerifyLatest' ? status.updatedAt : null);
    final backupAge = _backupAgeInDays(lastBackupAt);
    if (backupAge != null && backupAge >= config.staleAfterDays) {
      final overdueDays = backupAge - config.staleAfterDays;
      warnings.add(
        overdueDays > 0
            ? 'Backup is $backupAge day${backupAge == 1 ? '' : 's'} old, which is $overdueDays day${overdueDays == 1 ? '' : 's'} past the ${config.staleAfterDays}-day freshness window.'
            : 'Backup is $backupAge day${backupAge == 1 ? '' : 's'} old and at the freshness window.',
      );
    }
    if (lastBackupAt != null &&
        lastVerificationAt != null &&
        lastBackupAt.isAfter(lastVerificationAt)) {
      warnings.add(
        'Latest backup has not been verified yet. Run Verify Latest when ready.',
      );
    }
    final healthState = _deriveHealthState(
      status: status,
      sourceExists: sourceExists,
      backupDriveExists: backupDriveExists,
      lastBackupAt: lastBackupAt,
      lastVerificationAt: lastVerificationAt,
      latestManifestExists: latestManifestExists,
      manifestRequired: config.verifyAfterBackup,
      staleAfterDays: config.staleAfterDays,
    );

    final healthSummary = switch (healthState) {
      BackupGuardianHealthState.green => 'Latest backup verified',
      BackupGuardianHealthState.amber when latestManifestPath.isNotEmpty &&
          !latestManifestExists =>
        'Latest backup needs a readable manifest',
      BackupGuardianHealthState.amber when latestManifestPath.isEmpty &&
          (status.exists || latestBackupHistory != null) =>
        'Latest backup is waiting for manifest-backed verification',
      BackupGuardianHealthState.amber => sourceExists && !backupDriveExists
          ? 'Backup drive not connected'
          : backupAge != null && backupAge >= config.staleAfterDays
              ? 'Backup is past the freshness threshold'
              : 'Backup exists but still needs a quick review',
      BackupGuardianHealthState.red => !backupDriveExists
          ? 'Backup drive not connected'
          : 'Backup mirror missing or backup failed',
      BackupGuardianHealthState.grey => 'No backup run yet',
    };

    final freshnessSummary = lastBackupAt == null
        ? 'No backup age recorded yet.'
        : backupAge == null
            ? 'Backup age is being tracked.'
            : backupAge <= 0
                ? 'Backup ran today.'
                : backupAge < config.staleAfterDays
                    ? 'Backup is $backupAge day${backupAge == 1 ? '' : 's'} old and still inside the freshness window.'
                    : 'Backup is $backupAge day${backupAge == 1 ? '' : 's'} old and past the ${config.staleAfterDays}-day freshness window.';

    final scheduleSummary = config.scheduleEnabled
        ? 'Scheduled daily at ${config.dailyBackupTime}, weekly on ${config.weeklySnapshotDay}, monthly on day ${config.monthlyArchiveDay}.'
        : 'Manual backups only for now.';

    final retentionSummary =
        'Retention keeps quick ${config.quickKeep}, daily ${config.dailyKeep}, weekly ${config.weeklyKeep}, and monthly ${config.monthlyKeep} backup sets.';

    final notificationBanner = history.entries.isEmpty
        ? 'No backup history yet. Run a backup to start the timeline.'
        : backupAge != null && backupAge >= config.staleAfterDays
            ? 'Freshness check: backup is $backupAge day${backupAge == 1 ? '' : 's'} old. A new backup would keep it within the ${config.staleAfterDays}-day window.'
            : !backupDriveExists
                ? 'Backup drive not connected. Plug in the external drive when you’re ready.'
                : scheduleSummary;

    final nextSuggestedRun = _calculateNextSuggestedRun(
      config: config,
      lastBackupAt: lastBackupAt,
    );

    return BackupGuardianSnapshot(
      config: config,
      statusFilePath: _statusFile.path,
      statusFileExists: status.exists,
      sourceExists: sourceExists,
      backupDriveExists: backupDriveExists,
      mirrorFolderExists: mirrorFolderExists,
      healthState: healthState,
      latestBackupStatus: status.summary.isNotEmpty
          ? status.summary
          : 'No backup status has been recorded yet.',
      latestReportPath: status.latestReportPath.isNotEmpty
          ? status.latestReportPath
          : _fallbackReportPath(config),
      latestManifestPath: latestManifestPath,
      latestManifestExists: latestManifestExists,
      verificationSummary: verificationReadout.summary,
      verificationDetails: verificationReadout.details,
      restoreTestStatus: status.restoreTestStatus.isNotEmpty
          ? status.restoreTestStatus
          : 'Not run yet',
      backupSizeText: status.backupSizeText.isNotEmpty
          ? status.backupSizeText
          : 'Not tracked in V1',
      historyFilePath: _historyFile.path,
      historyEntries: history.entries,
      restorePoints: history.entries
          .where((entry) => entry.isRestorePoint)
          .toList(growable: false),
      scheduleSummary: scheduleSummary,
      retentionSummary: retentionSummary,
      freshnessSummary: freshnessSummary,
      notificationBanner: notificationBanner,
      nextSuggestedRun: nextSuggestedRun,
      lastBackupAt: lastBackupAt,
      lastVerificationAt: lastVerificationAt,
      statusUpdatedAt: status.updatedAt,
      warnings: warnings,
      errors: errors,
      healthSummary: healthSummary,
    );
  }

  Future<void> runAction(BackupGuardianAction action) async {
    final script = switch (action) {
      BackupGuardianAction.dryRun => 'scripts/windows/dry_run.bat',
      BackupGuardianAction.backupNow => 'scripts/windows/backup_now.bat',
      BackupGuardianAction.verifyLatest => 'scripts/windows/verify_latest.bat',
      BackupGuardianAction.restoreDryRun =>
        'scripts/windows/restore_dry_run.bat',
      BackupGuardianAction.quickIncremental =>
        'scripts/windows/quick_incremental.bat',
      BackupGuardianAction.dailyBackup =>
        'scripts/windows/daily_backup.bat',
      BackupGuardianAction.weeklySnapshot =>
        'scripts/windows/weekly_snapshot.bat',
      BackupGuardianAction.monthlyArchive =>
        'scripts/windows/monthly_archive.bat',
    };

    final scriptPath = path.join(_moduleRoot.path, script);
    if (!File(scriptPath).existsSync()) {
      throw FileSystemException('Backup script not found', scriptPath);
    }

    if (Platform.isWindows) {
      await Process.start(
        'cmd.exe',
        ['/c', 'start', '', scriptPath],
        workingDirectory: _moduleRoot.path,
        runInShell: true,
      );
      return;
    }

    await Process.start(
      'sh',
      [scriptPath],
      workingDirectory: _moduleRoot.path,
      runInShell: true,
    );
  }

  Future<void> openBackupFolder(BackupGuardianSnapshot snapshot) async {
    final mirrorFolder = snapshot.config.mirrorFolder.trim();
    if (mirrorFolder.isNotEmpty && Directory(mirrorFolder).existsSync()) {
      await _openPath(mirrorFolder);
      return;
    }

    await _openPath(snapshot.backupTarget);
  }

  Future<void> viewLatestReport(BackupGuardianSnapshot snapshot) async {
    final reportPath = snapshot.latestReportPath.trim();
    if (reportPath.isNotEmpty && File(reportPath).existsSync()) {
      await _openFile(reportPath);
      return;
    }

    await _openPath(snapshot.config.reportsFolder);
  }

  Future<void> openReportPath(String reportPath) async {
    final normalized = reportPath.trim();
    if (normalized.isEmpty) {
      return;
    }

    if (File(normalized).existsSync()) {
      await _openFile(normalized);
      return;
    }

    await _openPath(path.dirname(normalized));
  }

  Future<BackupGuardianConfig> _loadConfig() async {
    final localExists = _localConfigFile.existsSync();
    final configFile = localExists ? _localConfigFile : _exampleConfigFile;
    final jsonMap = await _readJsonMap(configFile);
    if (jsonMap == null) {
      return BackupGuardianConfig.fromJson(
        json: const <String, dynamic>{},
        configPath: configFile.path,
        isLocalConfig: localExists,
      );
    }

    return BackupGuardianConfig.fromJson(
      json: jsonMap,
      configPath: configFile.path,
      isLocalConfig: localExists,
    );
  }

  Future<_ParsedStatus> _loadStatus() async {
    if (!_statusFile.existsSync()) {
      return const _ParsedStatus();
    }

    final jsonMap = await _readJsonMap(_statusFile);
    if (jsonMap == null) {
      return const _ParsedStatus(exists: true);
    }

    return _ParsedStatus.fromJson(jsonMap);
  }

  Future<Map<String, dynamic>?> _readJsonMap(File file) async {
    if (!file.existsSync()) {
      return null;
    }
    try {
      final contents = await file.readAsString();
      final decoded = jsonDecode(contents);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  BackupGuardianHealthState _deriveHealthState({
    required _ParsedStatus status,
    required bool sourceExists,
    required bool backupDriveExists,
    required DateTime? lastBackupAt,
    required DateTime? lastVerificationAt,
    required bool latestManifestExists,
    required bool manifestRequired,
    required int staleAfterDays,
  }) {
    if (!sourceExists) {
      return BackupGuardianHealthState.red;
    }

    if (status.errors.isNotEmpty) {
      return BackupGuardianHealthState.red;
    }

    final state = status.state.toLowerCase();
    if (state == 'red') {
      return BackupGuardianHealthState.red;
    }

    if (status.exists && lastBackupAt != null) {
      if (lastVerificationAt == null || lastBackupAt.isAfter(lastVerificationAt)) {
        return BackupGuardianHealthState.amber;
      }
    }

    if (manifestRequired && lastBackupAt != null && !latestManifestExists) {
      return BackupGuardianHealthState.amber;
    }

    final backupAge = _backupAgeInDays(lastBackupAt);
    if (backupAge != null && backupAge >= staleAfterDays) {
      return BackupGuardianHealthState.amber;
    }

    if (!backupDriveExists) {
      return BackupGuardianHealthState.amber;
    }

    if (state == 'green') {
      return BackupGuardianHealthState.green;
    }

    if (state == 'amber') {
      return BackupGuardianHealthState.amber;
    }

    return BackupGuardianHealthState.grey;
  }

  String _fallbackReportPath(BackupGuardianConfig config) {
    return path.join(config.reportsFolder, 'latest_backup_guardian_report.log');
  }

  Future<_ParsedHistory> _loadHistory() async {
    if (!_historyFile.existsSync()) {
      return const _ParsedHistory();
    }

    final jsonMap = await _readJsonMap(_historyFile);
    if (jsonMap == null) {
      return const _ParsedHistory(exists: true);
    }

    return _ParsedHistory.fromJson(jsonMap);
  }

  Future<_ParsedManifest> _loadManifest(String manifestPath) async {
    final normalized = manifestPath.trim();
    if (normalized.isEmpty || !File(normalized).existsSync()) {
      return const _ParsedManifest();
    }

    final jsonMap = await _readJsonMap(File(normalized));
    if (jsonMap == null) {
      return const _ParsedManifest(exists: true);
    }

    return _ParsedManifest.fromJson(jsonMap);
  }

  Future<_FolderStats> _loadFolderStats(String folderPath) async {
    final normalized = folderPath.trim();
    if (normalized.isEmpty) {
      return const _FolderStats();
    }

    final directory = Directory(normalized);
    if (!directory.existsSync()) {
      return const _FolderStats();
    }

    var fileCount = 0;
    var sizeBytes = 0;
    try {
      for (final entity in directory.listSync(recursive: true, followLinks: false)) {
        if (entity is File) {
          fileCount += 1;
          sizeBytes += entity.lengthSync();
        }
      }
    } catch (_) {
      return const _FolderStats();
    }

    return _FolderStats(
      fileCount: fileCount,
      sizeBytes: sizeBytes,
    );
  }

  BackupGuardianHistoryEntry? _latestHistoryEntry(
    List<BackupGuardianHistoryEntry> entries,
    List<String> modes,
  ) {
    for (final entry in entries) {
      if (modes.contains(entry.mode)) {
        return entry;
      }
    }
    return null;
  }

  String _latestManifestPath({
    required _ParsedStatus status,
    required BackupGuardianHistoryEntry? latestBackupHistory,
  }) {
    if (status.manifestPath.isNotEmpty) {
      return status.manifestPath;
    }

    if (latestBackupHistory != null && latestBackupHistory.manifestPath.isNotEmpty) {
      return latestBackupHistory.manifestPath;
    }

    return '';
  }

  _VerificationReadout _buildVerificationReadout({
    required _ParsedStatus status,
    required _ParsedManifest manifest,
    required _FolderStats mirrorStats,
    required BackupGuardianHistoryEntry? latestVerificationHistory,
    required String latestManifestPath,
    required bool latestManifestExists,
    required String backupDriveRoot,
    required BackupGuardianConfig config,
  }) {
    if (latestVerificationHistory == null && status.mode != 'VerifyLatest') {
      return const _VerificationReadout(
        summary: 'No verification run yet.',
        details: <String>[
          'Run Verify Latest to compare the current mirror with the latest manifest.',
        ],
      );
    }

    if (!latestManifestExists || latestManifestPath.isEmpty) {
      return const _VerificationReadout(
        summary: 'Manifest verification is not available yet.',
        details: <String>[
          'The latest backup does not have a readable manifest yet.',
          'Verify Latest can only fall back to target checks until one appears.',
        ],
      );
    }

    if (!manifest.exists) {
      return const _VerificationReadout(
        summary: 'Manifest verification is not available yet.',
        details: <String>[
          'The manifest path exists, but the file could not be read.',
          'Verify Latest needs a readable manifest before it can compare fingerprints.',
        ],
      );
    }

    final details = <String>[
      'Manifest: ${path.basename(latestManifestPath)}',
      'Current mirror: ${mirrorStats.fileCount} files, ${mirrorStats.sizeText}.',
      if (status.summary.isNotEmpty) 'Status: ${status.summary}',
    ];

    if (status.filesScanned != null || status.backupSizeText.isNotEmpty) {
      details.add(
        'Verification output: ${status.filesScanned ?? mirrorStats.fileCount} files scanned, ${status.backupSizeText.isNotEmpty ? status.backupSizeText : mirrorStats.sizeText}.',
      );
    }

    if (manifest.targetInventoryHash.isNotEmpty) {
      details.add(
        'Fingerprint: ${status.errors.any((item) => item.toLowerCase().contains('fingerprint')) ? 'mismatch reported by Verify Latest' : 'recorded in the manifest'}.',
      );
    } else {
      details.add('Fingerprint: not recorded in the manifest yet.');
    }

    if (manifest.targetInventoryFileCount != null) {
      details.add(
        'File count: manifest expects ${manifest.targetInventoryFileCount}, current mirror has ${mirrorStats.fileCount}.',
      );
    }
    if (manifest.targetSizeBytes != null) {
      details.add(
        'Size: manifest expects ${_formatBytes(manifest.targetSizeBytes!)}, current mirror is ${mirrorStats.sizeText}.',
      );
    }
    if (manifest.targetPath.isNotEmpty) {
      details.add(
        'Path: manifest expects ${manifest.targetPath}, current mirror is ${config.mirrorFolder}.',
      );
    }
    if (manifest.targetDrive.isNotEmpty) {
      details.add(
        'Drive: manifest expects ${manifest.targetDrive}, current backup root is $backupDriveRoot.',
      );
    }

    for (final warning in status.warnings) {
      details.add('Warning: $warning');
    }
    for (final error in status.errors) {
      details.add('Error: $error');
    }

    final summary = status.summary.isNotEmpty
        ? status.summary
        : status.errors.isNotEmpty
            ? 'Latest backup verification found manifest differences.'
            : 'Latest backup verification passed.';

    return _VerificationReadout(
      summary: summary,
      details: List<String>.unmodifiable(details),
    );
  }

  int? _backupAgeInDays(DateTime? lastBackupAt) {
    if (lastBackupAt == null) {
      return null;
    }
    return DateTime.now().difference(lastBackupAt).inDays;
  }

  DateTime? _calculateNextSuggestedRun({
    required BackupGuardianConfig config,
    required DateTime? lastBackupAt,
  }) {
    if (!config.scheduleEnabled) {
      return null;
    }

    final timeParts = config.dailyBackupTime.split(':');
    final hour = timeParts.isNotEmpty ? int.tryParse(timeParts.first) ?? 2 : 2;
    final minute = timeParts.length > 1
        ? int.tryParse(timeParts.last) ?? 0
        : 0;

    final base = lastBackupAt?.toLocal() ?? DateTime.now().toLocal();
    var candidate = DateTime(
      base.year,
      base.month,
      base.day,
      hour,
      minute,
    );
    if (!candidate.isAfter(base)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  Future<void> _openPath(String value) async {
    if (value.trim().isEmpty) {
      return;
    }
    final normalized = value.trim();

    if (Platform.isWindows) {
      await Process.start('explorer.exe', [normalized], runInShell: true);
      return;
    }

    if (Platform.isMacOS) {
      await Process.start('open', [normalized], runInShell: true);
      return;
    }

    await Process.start('xdg-open', [normalized], runInShell: true);
  }

  Future<void> _openFile(String filePath) async {
    if (Platform.isWindows) {
      await Process.start('explorer.exe', ['/select,$filePath'], runInShell: true);
      return;
    }

    await _openPath(filePath);
  }
}

class _ParsedStatus {
  const _ParsedStatus({
    this.exists = false,
    this.state = 'grey',
    this.mode = '',
    this.source = '',
    this.target = '',
    this.summary = '',
    this.latestReportPath = '',
    this.manifestPath = '',
    this.restoreTestStatus = '',
    this.backupSizeText = '',
    this.backupKind = '',
    this.filesScanned,
    this.filesCopied,
    this.filesSkipped,
    this.backupSizeBytes,
    this.warnings = const <String>[],
    this.errors = const <String>[],
    this.lastBackupAt,
    this.lastVerificationAt,
    this.updatedAt,
  });

  final bool exists;
  final String state;
  final String mode;
  final String source;
  final String target;
  final String summary;
  final String latestReportPath;
  final String manifestPath;
  final String restoreTestStatus;
  final String backupSizeText;
  final String backupKind;
  final int? filesScanned;
  final int? filesCopied;
  final int? filesSkipped;
  final int? backupSizeBytes;
  final List<String> warnings;
  final List<String> errors;
  final DateTime? lastBackupAt;
  final DateTime? lastVerificationAt;
  final DateTime? updatedAt;

  factory _ParsedStatus.fromJson(Map<String, dynamic> json) {
    String readString(String key) {
      final value = json[key];
      if (value is String) {
        return value.trim();
      }
      return '';
    }

    return _ParsedStatus(
      exists: true,
      state: readString('health_state').isNotEmpty
          ? readString('health_state')
          : readString('state'),
      mode: readString('mode'),
      source: readString('source_drive').isNotEmpty
          ? readString('source_drive')
          : readString('source'),
      target: readString('backup_target').isNotEmpty
          ? readString('backup_target')
          : readString('target'),
      summary: readString('latest_backup_status').isNotEmpty
          ? readString('latest_backup_status')
          : readString('summary'),
      latestReportPath: readString('latest_report_path').isNotEmpty
          ? readString('latest_report_path')
          : readString('log_path'),
      manifestPath: readString('manifest_path'),
      restoreTestStatus: readString('restore_test_status'),
      backupSizeText: readString('backup_size_text'),
      backupKind: readString('backup_kind'),
      filesScanned: _readInt(json, 'files_scanned'),
      filesCopied: _readInt(json, 'files_copied'),
      filesSkipped: _readInt(json, 'files_skipped'),
      backupSizeBytes: _readInt(json, 'backup_size_bytes'),
      warnings: _stringList(json['warnings']),
      errors: _stringList(json['errors']),
      lastBackupAt: _parseDate(
        readString('last_backup_at').isNotEmpty
            ? readString('last_backup_at')
            : readString('last_backup_time'),
      ),
      lastVerificationAt: _parseDate(
        readString('last_verification_at').isNotEmpty
            ? readString('last_verification_at')
            : readString('last_verify_at'),
      ),
      updatedAt: _parseDate(readString('updated_at')),
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Object?>()
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }

  static DateTime? _parseDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return DateTime.tryParse(trimmed);
  }

  static int? _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }
}

class _ParsedManifest {
  const _ParsedManifest({
    this.exists = false,
    this.backupKind = '',
    this.targetPath = '',
    this.targetDrive = '',
    this.targetInventoryHashAlgorithm = '',
    this.targetInventoryHash = '',
    this.targetInventoryFileCount,
    this.targetSizeBytes,
  });

  final bool exists;
  final String backupKind;
  final String targetPath;
  final String targetDrive;
  final String targetInventoryHashAlgorithm;
  final String targetInventoryHash;
  final int? targetInventoryFileCount;
  final int? targetSizeBytes;

  factory _ParsedManifest.fromJson(Map<String, dynamic> json) {
    return _ParsedManifest(
      exists: true,
      backupKind: _stringValue(json, 'backup_kind'),
      targetPath: _stringValue(json, 'target_path'),
      targetDrive: _stringValue(json, 'target_drive'),
      targetInventoryHashAlgorithm: _stringValue(
        json,
        'target_inventory_hash_algorithm',
      ),
      targetInventoryHash: _stringValue(json, 'target_inventory_hash'),
      targetInventoryFileCount: _intValue(json, 'target_inventory_file_count'),
      targetSizeBytes: _intValue(json, 'target_size_bytes'),
    );
  }
}

class _FolderStats {
  const _FolderStats({
    this.fileCount = 0,
    this.sizeBytes = 0,
  });

  final int fileCount;
  final int sizeBytes;

  String get sizeText => _formatBytes(sizeBytes);
}

class _VerificationReadout {
  const _VerificationReadout({
    required this.summary,
    required this.details,
  });

  final String summary;
  final List<String> details;
}

String _stringValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String) {
    return value.trim();
  }
  return '';
}

int? _intValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value.trim());
  }
  return null;
}

String _formatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}

class BackupGuardianHistoryEntry {
  const BackupGuardianHistoryEntry({
    required this.action,
    required this.mode,
    required this.backupKind,
    required this.state,
    required this.summary,
    required this.startedAt,
    required this.finishedAt,
    required this.durationMs,
    required this.filesScanned,
    required this.filesCopied,
    required this.filesSkipped,
    required this.backupSizeText,
    required this.manifestPath,
    required this.reportPath,
    required this.restorePointLabel,
  });

  final String action;
  final String mode;
  final String backupKind;
  final String state;
  final String summary;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int? durationMs;
  final int? filesScanned;
  final int? filesCopied;
  final int? filesSkipped;
  final String backupSizeText;
  final String manifestPath;
  final String reportPath;
  final String restorePointLabel;

  bool get isRestorePoint {
    final lowerState = state.toLowerCase();
    return lowerState == 'green' ||
        mode == 'BackupNow' ||
        mode == 'QuickIncremental' ||
        mode == 'DailyBackup' ||
        mode == 'WeeklySnapshot' ||
        mode == 'MonthlyArchive';
  }

  Duration? get duration =>
      durationMs == null ? null : Duration(milliseconds: durationMs!);

  DateTime get sortKey => finishedAt ?? startedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  factory BackupGuardianHistoryEntry.fromJson(Map<String, dynamic> json) {
    String readString(String key) {
      final value = json[key];
      if (value is String) {
        return value.trim();
      }
      return '';
    }

    int? readInt(String key) {
      final value = json[key];
      if (value is int) {
        return value;
      }
      if (value is String) {
        return int.tryParse(value.trim());
      }
      return null;
    }

    DateTime? readDate(String key) {
      final value = readString(key);
      if (value.isEmpty) {
        return null;
      }
      return DateTime.tryParse(value);
    }

    return BackupGuardianHistoryEntry(
      action: readString('action'),
      mode: readString('mode'),
      backupKind: readString('backup_kind'),
      state: readString('state').isNotEmpty ? readString('state') : readString('result'),
      summary: readString('summary'),
      startedAt: readDate('started_at'),
      finishedAt: readDate('finished_at'),
      durationMs: readInt('duration_ms'),
      filesScanned: readInt('files_scanned'),
      filesCopied: readInt('files_copied'),
      filesSkipped: readInt('files_skipped'),
      backupSizeText: readString('backup_size_text'),
      manifestPath: readString('manifest_path'),
      reportPath: readString('report_path'),
      restorePointLabel: readString('restore_point_label'),
    );
  }
}

class _ParsedHistory {
  const _ParsedHistory({
    this.exists = false,
    this.entries = const <BackupGuardianHistoryEntry>[],
  });

  final bool exists;
  final List<BackupGuardianHistoryEntry> entries;

  factory _ParsedHistory.fromJson(Map<String, dynamic> json) {
    final rawEvents = json['events'];
    final entries = <BackupGuardianHistoryEntry>[];
    if (rawEvents is List) {
      for (final item in rawEvents) {
        if (item is Map<String, dynamic>) {
          entries.add(BackupGuardianHistoryEntry.fromJson(item));
        }
      }
    }

    entries.sort((a, b) => b.sortKey.compareTo(a.sortKey));
    return _ParsedHistory(
      exists: true,
      entries: List<BackupGuardianHistoryEntry>.unmodifiable(entries),
    );
  }
}
