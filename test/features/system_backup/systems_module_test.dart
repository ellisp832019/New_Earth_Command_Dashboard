import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/more/presentation/more_screen.dart';
import 'package:new_earth_command_dashboard/features/system_backup/application/backup_guardian_controller.dart';
import 'package:new_earth_command_dashboard/features/system_backup/data/backup_guardian_service.dart';
import 'package:new_earth_command_dashboard/features/system_backup/presentation/backup_guardian_screen.dart';
import 'package:new_earth_command_dashboard/features/systems/presentation/systems_screen.dart';

void main() {
  testWidgets('more screen surfaces systems as a module', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MoreScreen()),
    );

    await tester.pumpAndSettle();

    expect(find.text('Systems'), findsOneWidget);
    expect(find.text('Protect the full D: drive, review backup status, and keep recovery tools calm.'), findsOneWidget);
  });

  testWidgets('systems screen surfaces backup guardian', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SystemsScreen()),
    );

    await tester.pumpAndSettle();

    expect(find.text('Backup Guardian'), findsOneWidget);
    expect(find.text('Manual V1'), findsOneWidget);
    expect(find.text('Restore dry run'), findsOneWidget);
  });

  testWidgets('backup guardian screen shows status and roadmap', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          backupGuardianSnapshotProvider.overrideWith(
            (ref) async => const BackupGuardianSnapshot(
              config: BackupGuardianConfig(
                sourceDrive: 'D:/',
                backupTarget: 'E:/NEW_EARTH_BACKUP',
                mirrorFolder: 'E:/NEW_EARTH_BACKUP/mirror',
                reportsFolder: 'E:/NEW_EARTH_BACKUP/reports',
                manifestsFolder: 'E:/NEW_EARTH_BACKUP/manifests',
                restoreTestFolder: 'D:/_RESTORE_TEST_AREA',
                verifyAfterBackup: true,
                createManifest: true,
                mode: 'mirror',
                configPath: 'modules/system_backup/config/backup_paths.local.json',
                isLocalConfig: true,
              ),
              statusFilePath: 'modules/system_backup/runtime/latest_status.json',
              statusFileExists: true,
              sourceExists: true,
              backupDriveExists: true,
              healthState: BackupGuardianHealthState.green,
              latestBackupStatus: 'Latest backup verified',
              latestReportPath: 'E:/NEW_EARTH_BACKUP/reports/latest.log',
              restoreTestStatus: 'Not run yet',
              backupSizeText: 'Not tracked in V1',
              lastBackupAt: null,
              lastVerificationAt: null,
              statusUpdatedAt: null,
              warnings: <String>['Robocopy exit code: 1'],
              errors: <String>[],
              healthSummary: 'Latest backup verified',
            ),
          ),
        ],
        child: const MaterialApp(home: BackupGuardianScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Backup Guardian'), findsOneWidget);
    expect(find.text('Dry Run'), findsOneWidget);
    expect(find.text('Backup Now'), findsOneWidget);
    expect(find.text('Verify Latest'), findsOneWidget);
    expect(find.text('Restore Dry Run'), findsOneWidget);
    expect(find.text('Roadmap / Future work'), findsOneWidget);
    expect(find.text('V2 planned'), findsOneWidget);
    expect(find.text('V3 planned'), findsOneWidget);
  });
}

