import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/features/system_backup/data/backup_guardian_service.dart';

void main() {
  test('backup guardian load snapshot reads config and status', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'backup_guardian_green_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final moduleRoot = Directory(path.join(tempRoot.path, 'modules', 'system_backup'));
    final configDir = Directory(path.join(moduleRoot.path, 'config'));
    final runtimeDir = Directory(path.join(moduleRoot.path, 'runtime'));
    final sourceDir = Directory(path.join(tempRoot.path, 'source_drive'));
    final backupDriveDir = Directory(path.join(tempRoot.path, 'backup_drive'));
    final backupTargetDir = Directory(path.join(backupDriveDir.path, 'NEW_EARTH_BACKUP'));
    final reportsDir = Directory(path.join(backupTargetDir.path, 'reports'));
    final manifestsDir = Directory(path.join(backupTargetDir.path, 'manifests'));
    final restoreDir = Directory(path.join(tempRoot.path, 'restore_test'));

    await configDir.create(recursive: true);
    await runtimeDir.create(recursive: true);
    await sourceDir.create(recursive: true);
    await backupDriveDir.create(recursive: true);
    await backupTargetDir.create(recursive: true);
    await reportsDir.create(recursive: true);
    await manifestsDir.create(recursive: true);
    await restoreDir.create(recursive: true);

    final config = <String, Object?>{
      'source_drive': sourceDir.path,
      'backup_target': backupTargetDir.path,
      'mirror_folder': path.join(backupTargetDir.path, 'mirror'),
      'reports_folder': reportsDir.path,
      'manifests_folder': manifestsDir.path,
      'restore_test_folder': restoreDir.path,
      'verify_after_backup': true,
      'create_manifest': true,
      'schedule': <String, Object?>{
        'enabled': true,
        'daily_time': '02:00',
        'weekly_day': 'Sunday',
        'monthly_day': 1,
        'stale_after_days': 10,
      },
      'mode': 'mirror',
      'retention': <String, Object?>{
        'daily_keep': 7,
        'weekly_keep': 4,
        'monthly_keep': 12,
      },
    };
    await File(
      path.join(configDir.path, 'backup_paths.local.json'),
    ).writeAsString(jsonEncode(config));

    final history = <String, Object?>{
      'events': [
        {
          'action': 'Backup Now',
          'mode': 'BackupNow',
          'backup_kind': 'manual',
          'state': 'green',
          'summary': 'Latest backup verified',
          'started_at': '2026-06-07T05:55:00Z',
          'finished_at': '2026-06-07T06:00:00Z',
          'duration_ms': 300000,
          'files_scanned': 12,
          'files_copied': 12,
          'files_skipped': 0,
          'backup_size_bytes': 2048,
          'backup_size_text': '2.0 KB',
          'manifest_path': path.join(
            manifestsDir.path,
            'backup_manifest_20260607_060000.json',
          ),
          'report_path': path.join(
            reportsDir.path,
            'backup_guardian_20260607_060000.log',
          ),
          'restore_point_label': 'Manual backup - 2026-06-07 06:00',
          'restore_point_path': path.join(
            backupTargetDir.path,
            'daily',
            '20260607_060000',
            'restore_point.json',
          ),
        },
      ],
    };
    await File(
      path.join(runtimeDir.path, 'backup_history.json'),
    ).writeAsString(jsonEncode(history));

    final status = <String, Object?>{
      'module': 'system_backup',
      'state': 'green',
      'health_state': 'green',
      'mode': 'VerifyLatest',
      'source_drive': sourceDir.path,
      'backup_target': backupTargetDir.path,
      'summary': 'Latest backup verified',
      'latest_backup_status': 'Latest backup verified',
      'last_backup_at': '2026-06-07T05:00:00Z',
      'last_verification_at': '2026-06-07T06:00:00Z',
      'restore_test_status': 'Not run yet',
      'backup_size_text': 'Not tracked in V1',
      'latest_report_path': path.join(
        reportsDir.path,
        'backup_guardian_20260607_060000.log',
      ),
      'warnings': <String>[],
      'errors': <String>[],
      'updated_at': '2026-06-07T06:00:00Z',
      'log_path': path.join(
        reportsDir.path,
        'backup_guardian_20260607_060000.log',
      ),
    };
    await File(
      path.join(runtimeDir.path, 'latest_status.json'),
    ).writeAsString(jsonEncode(status));
    await File(
      path.join(manifestsDir.path, 'backup_manifest_20260607_060000.json'),
    ).writeAsString(
      jsonEncode(<String, Object?>{
        'target_inventory_hash': 'abc123',
        'target_inventory_hash_algorithm': 'SHA256',
      }),
    );

    final snapshot = await BackupGuardianService(moduleRoot: moduleRoot).loadSnapshot();

    expect(snapshot.config.isLocalConfig, isTrue);
    expect(snapshot.sourceDrive, sourceDir.path);
    expect(snapshot.backupTarget, backupTargetDir.path);
    expect(snapshot.healthState, BackupGuardianHealthState.green);
    expect(snapshot.latestBackupStatus, 'Latest backup verified');
    expect(snapshot.restoreTestStatus, 'Not run yet');
    expect(snapshot.hasHistory, isTrue);
    expect(snapshot.scheduleSummary, contains('Scheduled daily'));
    expect(snapshot.notificationBanner, contains('Scheduled daily'));
    expect(snapshot.latestReportPath, path.join(
      reportsDir.path,
      'backup_guardian_20260607_060000.log',
    ));
    expect(snapshot.latestManifestPath, path.join(
      manifestsDir.path,
      'backup_manifest_20260607_060000.json',
    ));
    expect(snapshot.warnings, isEmpty);
    expect(snapshot.errors, isEmpty);
  });

  test('backup guardian load snapshot raises a freshness warning when the backup is stale', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'backup_guardian_stale_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final moduleRoot = Directory(path.join(tempRoot.path, 'modules', 'system_backup'));
    final configDir = Directory(path.join(moduleRoot.path, 'config'));
    final runtimeDir = Directory(path.join(moduleRoot.path, 'runtime'));
    final sourceDir = Directory(path.join(tempRoot.path, 'source_drive'));
    final backupDriveDir = Directory(path.join(tempRoot.path, 'backup_drive'));
    final backupTargetDir = Directory(path.join(backupDriveDir.path, 'NEW_EARTH_BACKUP'));
    final reportsDir = Directory(path.join(backupTargetDir.path, 'reports'));
    final manifestsDir = Directory(path.join(backupTargetDir.path, 'manifests'));

    await configDir.create(recursive: true);
    await runtimeDir.create(recursive: true);
    await sourceDir.create(recursive: true);
    await backupDriveDir.create(recursive: true);
    await backupTargetDir.create(recursive: true);
    await reportsDir.create(recursive: true);
    await manifestsDir.create(recursive: true);

    final config = <String, Object?>{
      'source_drive': sourceDir.path,
      'backup_target': backupTargetDir.path,
      'mirror_folder': path.join(backupTargetDir.path, 'mirror'),
      'reports_folder': reportsDir.path,
      'manifests_folder': manifestsDir.path,
      'restore_test_folder': path.join(tempRoot.path, 'restore_test'),
      'verify_after_backup': true,
      'create_manifest': true,
      'schedule': <String, Object?>{
        'enabled': true,
        'daily_time': '02:00',
        'weekly_day': 'Sunday',
        'monthly_day': 1,
        'stale_after_days': 2,
      },
      'mode': 'mirror',
      'retention': <String, Object?>{
        'daily_keep': 7,
        'weekly_keep': 4,
        'monthly_keep': 12,
      },
    };
    await File(
      path.join(configDir.path, 'backup_paths.local.json'),
    ).writeAsString(jsonEncode(config));

    final history = <String, Object?>{
      'events': [
        {
          'action': 'Backup Now',
          'mode': 'BackupNow',
          'backup_kind': 'manual',
          'state': 'green',
          'summary': 'Latest backup verified',
          'started_at': '2026-01-01T05:55:00Z',
          'finished_at': '2026-01-01T06:00:00Z',
          'duration_ms': 300000,
          'files_scanned': 12,
          'files_copied': 12,
          'files_skipped': 0,
          'backup_size_bytes': 2048,
          'backup_size_text': '2.0 KB',
          'manifest_path': path.join(
            manifestsDir.path,
            'backup_manifest_20260101_060000.json',
          ),
          'report_path': path.join(
            reportsDir.path,
            'backup_guardian_20260101_060000.log',
          ),
          'restore_point_label': 'Manual backup - 2026-01-01 06:00',
          'restore_point_path': path.join(
            backupTargetDir.path,
            'daily',
            '20260101_060000',
            'restore_point.json',
          ),
        },
      ],
    };
    await File(
      path.join(runtimeDir.path, 'backup_history.json'),
    ).writeAsString(jsonEncode(history));

    final status = <String, Object?>{
      'module': 'system_backup',
      'state': 'green',
      'health_state': 'green',
      'mode': 'BackupNow',
      'source_drive': sourceDir.path,
      'backup_target': backupTargetDir.path,
      'summary': 'Latest backup verified',
      'latest_backup_status': 'Latest backup verified',
      'last_backup_at': '2026-01-01T06:00:00Z',
      'last_verification_at': '2026-01-01T06:00:00Z',
      'restore_test_status': 'Not run yet',
      'backup_size_text': 'Not tracked in V1',
      'latest_report_path': path.join(
        reportsDir.path,
        'backup_guardian_20260101_060000.log',
      ),
      'warnings': <String>[],
      'errors': <String>[],
      'updated_at': '2026-01-01T06:00:00Z',
      'log_path': path.join(
        reportsDir.path,
        'backup_guardian_20260101_060000.log',
      ),
    };
    await File(
      path.join(runtimeDir.path, 'latest_status.json'),
    ).writeAsString(jsonEncode(status));

    final snapshot = await BackupGuardianService(moduleRoot: moduleRoot).loadSnapshot();

    expect(
      snapshot.warnings.any((warning) =>
          warning.startsWith('Backup is ') &&
          warning.contains('freshness window')),
      isTrue,
    );
    expect(
      snapshot.freshnessSummary,
      contains('freshness window'),
    );
    expect(
      snapshot.notificationBanner,
      contains('Freshness check:'),
    );
    expect(snapshot.healthState, BackupGuardianHealthState.amber);
  });

  test('backup guardian load snapshot warns when the latest manifest is missing', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'backup_guardian_manifest_missing_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final moduleRoot = Directory(path.join(tempRoot.path, 'modules', 'system_backup'));
    final configDir = Directory(path.join(moduleRoot.path, 'config'));
    final runtimeDir = Directory(path.join(moduleRoot.path, 'runtime'));
    final sourceDir = Directory(path.join(tempRoot.path, 'source_drive'));
    final backupDriveDir = Directory(path.join(tempRoot.path, 'backup_drive'));
    final backupTargetDir = Directory(path.join(backupDriveDir.path, 'NEW_EARTH_BACKUP'));
    final reportsDir = Directory(path.join(backupTargetDir.path, 'reports'));
    final manifestsDir = Directory(path.join(backupTargetDir.path, 'manifests'));

    await configDir.create(recursive: true);
    await runtimeDir.create(recursive: true);
    await sourceDir.create(recursive: true);
    await backupDriveDir.create(recursive: true);
    await backupTargetDir.create(recursive: true);
    await reportsDir.create(recursive: true);
    await manifestsDir.create(recursive: true);

    final missingManifestPath = path.join(
      manifestsDir.path,
      'backup_manifest_20260609_060000.json',
    );

    final config = <String, Object?>{
      'source_drive': sourceDir.path,
      'backup_target': backupTargetDir.path,
      'mirror_folder': path.join(backupTargetDir.path, 'mirror'),
      'reports_folder': reportsDir.path,
      'manifests_folder': manifestsDir.path,
      'restore_test_folder': path.join(tempRoot.path, 'restore_test'),
      'verify_after_backup': true,
      'create_manifest': true,
      'schedule': <String, Object?>{
        'enabled': true,
        'daily_time': '02:00',
        'weekly_day': 'Sunday',
        'monthly_day': 1,
        'stale_after_days': 2,
      },
      'mode': 'mirror',
      'retention': <String, Object?>{
        'daily_keep': 7,
        'weekly_keep': 4,
        'monthly_keep': 12,
      },
    };
    await File(
      path.join(configDir.path, 'backup_paths.local.json'),
    ).writeAsString(jsonEncode(config));

    final history = <String, Object?>{
      'events': [
        {
          'action': 'Backup Now',
          'mode': 'BackupNow',
          'backup_kind': 'manual',
          'state': 'green',
          'summary': 'Latest backup verified',
          'started_at': '2026-06-09T05:55:00Z',
          'finished_at': '2026-06-09T06:00:00Z',
          'duration_ms': 300000,
          'files_scanned': 12,
          'files_copied': 12,
          'files_skipped': 0,
          'backup_size_bytes': 2048,
          'backup_size_text': '2.0 KB',
          'manifest_path': missingManifestPath,
          'report_path': path.join(
            reportsDir.path,
            'backup_guardian_20260609_060000.log',
          ),
          'restore_point_label': 'Manual backup - 2026-06-09 06:00',
          'restore_point_path': path.join(
            backupTargetDir.path,
            'daily',
            '20260609_060000',
            'restore_point.json',
          ),
        },
      ],
    };
    await File(
      path.join(runtimeDir.path, 'backup_history.json'),
    ).writeAsString(jsonEncode(history));

    final status = <String, Object?>{
      'module': 'system_backup',
      'state': 'green',
      'health_state': 'green',
      'mode': 'BackupNow',
      'source_drive': sourceDir.path,
      'backup_target': backupTargetDir.path,
      'summary': 'Latest backup verified',
      'latest_backup_status': 'Latest backup verified',
      'last_backup_at': '2026-06-09T06:00:00Z',
      'last_verification_at': '2026-06-09T06:00:00Z',
      'restore_test_status': 'Not run yet',
      'backup_size_text': 'Not tracked in V1',
      'manifest_path': missingManifestPath,
      'latest_report_path': path.join(
        reportsDir.path,
        'backup_guardian_20260609_060000.log',
      ),
      'warnings': <String>[],
      'errors': <String>[],
      'updated_at': '2026-06-09T06:00:00Z',
      'log_path': path.join(
        reportsDir.path,
        'backup_guardian_20260609_060000.log',
      ),
    };
    await File(
      path.join(runtimeDir.path, 'latest_status.json'),
    ).writeAsString(jsonEncode(status));

    final snapshot = await BackupGuardianService(moduleRoot: moduleRoot).loadSnapshot();

    expect(snapshot.latestManifestPath, missingManifestPath);
    expect(snapshot.latestManifestExists, isFalse);
    expect(
      snapshot.warnings,
      contains('The latest manifest is recorded but the file is missing. Verify Latest can only trust a readable manifest.'),
    );
    expect(snapshot.healthState, BackupGuardianHealthState.amber);
    expect(snapshot.healthSummary, 'Latest backup needs a readable manifest');
  });

  test('backup guardian verification readout explains manifest differences', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'backup_guardian_verify_mismatch_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final moduleRoot = Directory(path.join(tempRoot.path, 'modules', 'system_backup'));
    final configDir = Directory(path.join(moduleRoot.path, 'config'));
    final runtimeDir = Directory(path.join(moduleRoot.path, 'runtime'));
    final sourceDir = Directory(path.join(tempRoot.path, 'source_drive'));
    final backupDriveDir = Directory(path.join(tempRoot.path, 'backup_drive'));
    final backupTargetDir = Directory(path.join(backupDriveDir.path, 'NEW_EARTH_BACKUP'));
    final mirrorDir = Directory(path.join(backupTargetDir.path, 'mirror'));
    final reportsDir = Directory(path.join(backupTargetDir.path, 'reports'));
    final manifestsDir = Directory(path.join(backupTargetDir.path, 'manifests'));

    await configDir.create(recursive: true);
    await runtimeDir.create(recursive: true);
    await sourceDir.create(recursive: true);
    await backupDriveDir.create(recursive: true);
    await mirrorDir.create(recursive: true);
    await reportsDir.create(recursive: true);
    await manifestsDir.create(recursive: true);

    await File(path.join(mirrorDir.path, 'alpha.txt')).writeAsString('alpha');
    await File(path.join(mirrorDir.path, 'beta.txt')).writeAsString('beta');

    final manifestPath = path.join(
      manifestsDir.path,
      'backup_manifest_20260610_060000.json',
    );
    await File(manifestPath).writeAsString(
      jsonEncode(<String, Object?>{
        'backup_kind': 'manual',
        'target_path': path.join(backupTargetDir.path, 'mirror_expected'),
        'target_drive': backupDriveDir.path,
        'target_inventory_hash_algorithm': 'SHA256',
        'target_inventory_hash': 'expected-hash',
        'target_inventory_file_count': 3,
        'target_size_bytes': 4096,
      }),
    );

    final config = <String, Object?>{
      'source_drive': sourceDir.path,
      'backup_target': backupTargetDir.path,
      'mirror_folder': mirrorDir.path,
      'reports_folder': reportsDir.path,
      'manifests_folder': manifestsDir.path,
      'restore_test_folder': path.join(tempRoot.path, 'restore_test'),
      'verify_after_backup': true,
      'create_manifest': true,
      'schedule': <String, Object?>{
        'enabled': true,
        'daily_time': '02:00',
        'weekly_day': 'Sunday',
        'monthly_day': 1,
        'stale_after_days': 2,
      },
      'mode': 'mirror',
      'retention': <String, Object?>{
        'daily_keep': 7,
        'weekly_keep': 4,
        'monthly_keep': 12,
      },
    };
    await File(
      path.join(configDir.path, 'backup_paths.local.json'),
    ).writeAsString(jsonEncode(config));

    final status = <String, Object?>{
      'module': 'system_backup',
      'state': 'red',
      'health_state': 'red',
      'mode': 'VerifyLatest',
      'source_drive': sourceDir.path,
      'backup_target': backupTargetDir.path,
      'summary': 'Latest backup verification found manifest differences.',
      'latest_backup_status': 'Latest backup verification found manifest differences.',
      'last_backup_at': '2026-06-10T05:00:00Z',
      'last_verification_at': '2026-06-10T06:00:00Z',
      'restore_test_status': 'Not run yet',
      'backup_size_text': '2.0 KB',
      'backup_kind': 'manual',
      'files_scanned': 2,
      'files_copied': 2,
      'files_skipped': 0,
      'backup_size_bytes': 9,
      'manifest_path': manifestPath,
      'latest_report_path': path.join(
        reportsDir.path,
        'backup_guardian_20260610_060000.log',
      ),
      'warnings': <String>[
        'Manifest target path is ${path.join(backupTargetDir.path, 'mirror_expected')}, but the current target is ${mirrorDir.path}.',
      ],
      'errors': <String>[
        'Target inventory fingerprint mismatch. Manifest has expected-hash but the current target has actual-hash.',
        'Target file count mismatch. Manifest expects 3 files but the current target has 2.',
        'Target size mismatch. Manifest expects 4.0 KB but the current target is 2.0 KB.',
      ],
      'updated_at': '2026-06-10T06:00:00Z',
      'log_path': path.join(
        reportsDir.path,
        'backup_guardian_20260610_060000.log',
      ),
    };
    await File(
      path.join(runtimeDir.path, 'latest_status.json'),
    ).writeAsString(jsonEncode(status));

    final snapshot = await BackupGuardianService(moduleRoot: moduleRoot).loadSnapshot();

    expect(snapshot.verificationSummary, 'Latest backup verification found manifest differences.');
    expect(
      snapshot.verificationDetails,
      contains('Manifest: backup_manifest_20260610_060000.json'),
    );
    expect(
      snapshot.verificationDetails,
      contains('Current mirror: 2 files, 9 B.'),
    );
    expect(
      snapshot.verificationDetails.any((line) => line.contains('Fingerprint:')),
      isTrue,
    );
    expect(
      snapshot.verificationDetails.any((line) => line.contains('Target inventory fingerprint mismatch.')),
      isTrue,
    );
    expect(snapshot.healthState, BackupGuardianHealthState.red);
  });

  test('backup guardian load snapshot waits when the backup drive is missing', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'backup_guardian_red_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final moduleRoot = Directory(path.join(tempRoot.path, 'modules', 'system_backup'));
    final configDir = Directory(path.join(moduleRoot.path, 'config'));
    final runtimeDir = Directory(path.join(moduleRoot.path, 'runtime'));
    final sourceDir = Directory(path.join(tempRoot.path, 'source_drive'));
    final backupTargetDir = Directory(path.join(tempRoot.path, 'missing_drive', 'NEW_EARTH_BACKUP'));

    await configDir.create(recursive: true);
    await runtimeDir.create(recursive: true);
    await sourceDir.create(recursive: true);

    final config = <String, Object?>{
      'source_drive': sourceDir.path,
      'backup_target': backupTargetDir.path,
      'mirror_folder': path.join(backupTargetDir.path, 'mirror'),
      'reports_folder': path.join(backupTargetDir.path, 'reports'),
      'manifests_folder': path.join(backupTargetDir.path, 'manifests'),
      'restore_test_folder': path.join(tempRoot.path, 'restore_test'),
      'verify_after_backup': true,
      'create_manifest': true,
      'mode': 'mirror',
    };
    await File(
      path.join(configDir.path, 'backup_paths.local.json'),
    ).writeAsString(jsonEncode(config));

    final snapshot = await BackupGuardianService(moduleRoot: moduleRoot).loadSnapshot();

    expect(snapshot.healthState, BackupGuardianHealthState.amber);
    expect(
      snapshot.warnings,
      contains('Waiting for the external backup drive to appear.'),
    );
    expect(snapshot.warnings, contains('No backup history has been recorded yet.'));
    expect(snapshot.errors, isEmpty);
  });

  test('backup guardian history entries are sorted newest first', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'backup_guardian_history_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final moduleRoot = Directory(path.join(tempRoot.path, 'modules', 'system_backup'));
    final configDir = Directory(path.join(moduleRoot.path, 'config'));
    final runtimeDir = Directory(path.join(moduleRoot.path, 'runtime'));
    final sourceDir = Directory(path.join(tempRoot.path, 'source_drive'));
    final backupDriveDir = Directory(path.join(tempRoot.path, 'backup_drive'));
    final backupTargetDir = Directory(path.join(backupDriveDir.path, 'NEW_EARTH_BACKUP'));
    final reportsDir = Directory(path.join(backupTargetDir.path, 'reports'));
    final manifestsDir = Directory(path.join(backupTargetDir.path, 'manifests'));

    await configDir.create(recursive: true);
    await runtimeDir.create(recursive: true);
    await sourceDir.create(recursive: true);
    await backupDriveDir.create(recursive: true);
    await backupTargetDir.create(recursive: true);
    await reportsDir.create(recursive: true);
    await manifestsDir.create(recursive: true);

    final config = <String, Object?>{
      'source_drive': sourceDir.path,
      'backup_target': backupTargetDir.path,
      'mirror_folder': path.join(backupTargetDir.path, 'mirror'),
      'reports_folder': reportsDir.path,
      'manifests_folder': manifestsDir.path,
      'restore_test_folder': path.join(tempRoot.path, 'restore_test'),
      'verify_after_backup': true,
      'create_manifest': true,
      'schedule': <String, Object?>{
        'enabled': true,
        'daily_time': '02:00',
        'weekly_day': 'Sunday',
        'monthly_day': 1,
        'stale_after_days': 2,
      },
      'mode': 'mirror',
      'retention': <String, Object?>{
        'daily_keep': 7,
        'weekly_keep': 4,
        'monthly_keep': 12,
      },
    };
    await File(
      path.join(configDir.path, 'backup_paths.local.json'),
    ).writeAsString(jsonEncode(config));

    final history = <String, Object?>{
      'events': [
        {
          'action': 'Daily Backup',
          'mode': 'DailyBackup',
          'backup_kind': 'daily',
          'state': 'green',
          'summary': 'Scheduled daily backup completed successfully.',
          'started_at': '2026-06-07T05:55:00Z',
          'finished_at': '2026-06-07T06:00:00Z',
          'duration_ms': 300000,
          'files_scanned': 12,
          'files_copied': 12,
          'files_skipped': 0,
          'backup_size_bytes': 2048,
          'backup_size_text': '2.0 KB',
          'manifest_path': path.join(
            manifestsDir.path,
            'backup_manifest_20260607_060000.json',
          ),
          'report_path': path.join(
            reportsDir.path,
            'backup_guardian_20260607_060000.log',
          ),
          'restore_point_label': 'Daily backup - 2026-06-07 06:00',
          'restore_point_path': path.join(
            backupTargetDir.path,
            'daily',
            '20260607_060000',
            'restore_point.json',
          ),
        },
        {
          'action': 'Backup Now',
          'mode': 'BackupNow',
          'backup_kind': 'manual',
          'state': 'green',
          'summary': 'Latest backup verified',
          'started_at': '2026-06-08T05:55:00Z',
          'finished_at': '2026-06-08T06:00:00Z',
          'duration_ms': 180000,
          'files_scanned': 18,
          'files_copied': 18,
          'files_skipped': 0,
          'backup_size_bytes': 4096,
          'backup_size_text': '4.0 KB',
          'manifest_path': path.join(
            manifestsDir.path,
            'backup_manifest_20260608_060000.json',
          ),
          'report_path': path.join(
            reportsDir.path,
            'backup_guardian_20260608_060000.log',
          ),
          'restore_point_label': 'Manual backup - 2026-06-08 06:00',
          'restore_point_path': path.join(
            backupTargetDir.path,
            'daily',
            '20260608_060000',
            'restore_point.json',
          ),
        },
      ],
    };
    await File(
      path.join(runtimeDir.path, 'backup_history.json'),
    ).writeAsString(jsonEncode(history));

    final status = <String, Object?>{
      'module': 'system_backup',
      'state': 'green',
      'health_state': 'green',
      'mode': 'BackupNow',
      'source_drive': sourceDir.path,
      'backup_target': backupTargetDir.path,
      'summary': 'Latest backup verified',
      'latest_backup_status': 'Latest backup verified',
      'last_backup_at': '2026-06-08T06:00:00Z',
      'last_verification_at': '2026-06-08T06:00:00Z',
      'restore_test_status': 'Not run yet',
      'backup_size_text': 'Not tracked in V1',
      'latest_report_path': path.join(
        reportsDir.path,
        'backup_guardian_20260608_060000.log',
      ),
      'warnings': <String>[],
      'errors': <String>[],
      'updated_at': '2026-06-08T06:00:00Z',
      'log_path': path.join(
        reportsDir.path,
        'backup_guardian_20260608_060000.log',
      ),
    };
    await File(
      path.join(runtimeDir.path, 'latest_status.json'),
    ).writeAsString(jsonEncode(status));

    final snapshot = await BackupGuardianService(moduleRoot: moduleRoot).loadSnapshot();

    expect(snapshot.historyEntries.first.action, 'Backup Now');
    expect(snapshot.historyEntries.first.mode, 'BackupNow');
    expect(snapshot.historyEntries.last.action, 'Daily Backup');
  });
}
