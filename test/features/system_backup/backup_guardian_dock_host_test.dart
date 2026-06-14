import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/system_backup/application/backup_guardian_controller.dart';
import 'package:new_earth_command_dashboard/features/system_backup/data/backup_guardian_service.dart';
import 'package:new_earth_command_dashboard/features/system_backup/presentation/backup_guardian_dock_host.dart';

void main() {
  testWidgets('backup guardian dock host surfaces on wide layouts', (
    tester,
  ) async {
    final snapshot = BackupGuardianSnapshot(
      config: const BackupGuardianConfig(
        sourceDrive: 'D:/',
        backupTarget: 'E:/NEW_EARTH_BACKUP',
        mirrorFolder: 'E:/NEW_EARTH_BACKUP/mirror',
        reportsFolder: 'E:/NEW_EARTH_BACKUP/reports',
        manifestsFolder: 'E:/NEW_EARTH_BACKUP/manifests',
        restoreTestFolder: 'D:/_RESTORE_TEST_AREA',
        verifyAfterBackup: true,
        createManifest: true,
        scheduleEnabled: true,
        dailyBackupTime: '02:00',
        weeklySnapshotDay: 'Sunday',
        monthlyArchiveDay: 1,
        staleAfterDays: 2,
        quickKeep: 7,
        dailyKeep: 7,
        weeklyKeep: 4,
        monthlyKeep: 12,
        mode: 'mirror',
        configPath: 'modules/system_backup/config/backup_paths.local.json',
        isLocalConfig: true,
      ),
      statusFilePath: 'modules/system_backup/runtime/latest_status.json',
      statusFileExists: true,
      sourceExists: true,
      backupDriveExists: true,
      mirrorFolderExists: true,
      healthState: BackupGuardianHealthState.green,
      latestBackupStatus: 'Backup verified locally.',
      latestReportPath: 'modules/system_backup/runtime/reports/report.html',
      latestManifestPath: 'modules/system_backup/runtime/manifests/latest.json',
      latestManifestExists: true,
      verificationSummary: 'Verification matched the manifest.',
      verificationDetails: const <String>['Manifest and mirror are aligned.'],
      restoreTestStatus: 'Not run yet',
      backupSizeText: '1.2 TB',
      historyFilePath: 'modules/system_backup/runtime/backup_history.json',
      historyEntries: const <BackupGuardianHistoryEntry>[],
      restorePoints: const <BackupGuardianHistoryEntry>[],
      scheduleSummary: 'Scheduled daily at 02:00.',
      retentionSummary: 'Retention keeps recent restore points.',
      freshnessSummary: 'Backup ran today.',
      notificationBanner: 'Ready for the next verification pass.',
      nextSuggestedRun: DateTime.utc(2026, 6, 15, 2),
      lastBackupAt: DateTime.utc(2026, 6, 14, 8),
      lastVerificationAt: DateTime.utc(2026, 6, 14, 9),
      statusUpdatedAt: DateTime.utc(2026, 6, 14, 9),
      warnings: const <String>[],
      errors: const <String>[],
      healthSummary: 'Latest backup verified',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          backupGuardianSnapshotProvider.overrideWithValue(AsyncData(snapshot)),
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(1440, 900)),
            child: Scaffold(body: BackupGuardianDockHost()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Backup Guardian Dock'), findsOneWidget);
    expect(find.text('Ready for the next verification pass.'), findsOneWidget);
    expect(find.text('Latest backup verified'), findsOneWidget);
    expect(find.text('Open full view'), findsOneWidget);
    expect(find.text('Verify now'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);
  });
}
