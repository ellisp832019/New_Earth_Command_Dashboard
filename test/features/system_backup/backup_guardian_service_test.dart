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
      'mode': 'mirror',
    };
    await File(
      path.join(configDir.path, 'backup_paths.local.json'),
    ).writeAsString(jsonEncode(config));

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

    final snapshot = await BackupGuardianService(moduleRoot: moduleRoot).loadSnapshot();

    expect(snapshot.config.isLocalConfig, isTrue);
    expect(snapshot.sourceDrive, sourceDir.path);
    expect(snapshot.backupTarget, backupTargetDir.path);
    expect(snapshot.healthState, BackupGuardianHealthState.green);
    expect(snapshot.latestBackupStatus, 'Latest backup verified');
    expect(snapshot.restoreTestStatus, 'Not run yet');
    expect(snapshot.latestReportPath, path.join(
      reportsDir.path,
      'backup_guardian_20260607_060000.log',
    ));
    expect(snapshot.warnings, isEmpty);
    expect(snapshot.errors, isEmpty);
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
    expect(snapshot.errors, isEmpty);
  });
}
