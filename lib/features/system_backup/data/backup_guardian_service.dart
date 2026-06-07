import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

enum BackupGuardianAction {
  dryRun,
  backupNow,
  verifyLatest,
  restoreDryRun,
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
    required this.healthState,
    required this.latestBackupStatus,
    required this.latestReportPath,
    required this.restoreTestStatus,
    required this.backupSizeText,
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
  final BackupGuardianHealthState healthState;
  final String latestBackupStatus;
  final String latestReportPath;
  final String restoreTestStatus;
  final String backupSizeText;
  final DateTime? lastBackupAt;
  final DateTime? lastVerificationAt;
  final DateTime? statusUpdatedAt;
  final List<String> warnings;
  final List<String> errors;
  final String healthSummary;

  String get sourceDrive => config.sourceDrive;
  String get backupTarget => config.backupTarget;
  bool get isHealthy => healthState == BackupGuardianHealthState.green;
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

  Future<BackupGuardianSnapshot> loadSnapshot() async {
    final config = await _loadConfig();
    final status = await _loadStatus();
    final sourceExists = Directory(config.sourceDrive).existsSync();
    final backupDriveRoot = path.dirname(
      config.backupTarget.replaceAll('\\', '/').trimRight(),
    );
    final backupDriveExists = Directory(backupDriveRoot).existsSync();

    final warnings = <String>[
      ...status.warnings,
      if (!config.isLocalConfig)
        'Using the module example config until backup_paths.local.json is created locally.',
      if (!status.exists)
        'No status file found yet. Run Dry Run or Backup Now to create one.',
      if (sourceExists && !backupDriveExists)
        'Waiting for the external backup drive to appear.',
    ];

    final errors = <String>[
      ...status.errors,
      if (!sourceExists) 'Source drive not found: ${config.sourceDrive}',
    ];

    final lastBackupAt = status.lastBackupAt ??
        (status.mode == 'BackupNow' ? status.updatedAt : null);
    final lastVerificationAt = status.lastVerificationAt ??
        (status.mode == 'VerifyLatest' ? status.updatedAt : null);
    final healthState = _deriveHealthState(
      status: status,
      sourceExists: sourceExists,
      backupDriveExists: backupDriveExists,
      lastBackupAt: lastBackupAt,
      lastVerificationAt: lastVerificationAt,
    );

    final healthSummary = switch (healthState) {
      BackupGuardianHealthState.green => 'Latest backup verified',
      BackupGuardianHealthState.amber => sourceExists && !backupDriveExists
          ? 'Waiting for the external backup drive'
          : 'Backup exists but still needs review',
      BackupGuardianHealthState.red => 'Backup failed or target missing',
      BackupGuardianHealthState.grey => 'No backup run yet',
    };

    return BackupGuardianSnapshot(
      config: config,
      statusFilePath: _statusFile.path,
      statusFileExists: status.exists,
      sourceExists: sourceExists,
      backupDriveExists: backupDriveExists,
      healthState: healthState,
      latestBackupStatus: status.summary.isNotEmpty
          ? status.summary
          : 'No backup status has been recorded yet.',
      latestReportPath: status.latestReportPath.isNotEmpty
          ? status.latestReportPath
          : _fallbackReportPath(config),
      restoreTestStatus: status.restoreTestStatus.isNotEmpty
          ? status.restoreTestStatus
          : 'Not run yet',
      backupSizeText: status.backupSizeText.isNotEmpty
          ? status.backupSizeText
          : 'Not tracked in V1',
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
    this.restoreTestStatus = '',
    this.backupSizeText = '',
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
  final String restoreTestStatus;
  final String backupSizeText;
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
      restoreTestStatus: readString('restore_test_status'),
      backupSizeText: readString('backup_size_text'),
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
}
