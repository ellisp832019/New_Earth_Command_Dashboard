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
    await tester.pumpWidget(const MaterialApp(home: MoreScreen()));

    await tester.pumpAndSettle();

    expect(find.text('Systems'), findsOneWidget);
    expect(
      find.text(
        'Protect the full D: drive, review backup status, and keep recovery tools calm.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('systems screen surfaces backup guardian', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: const MaterialApp(home: SystemsScreen())),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Backup Guardian'), findsOneWidget);
    expect(find.text('Manual V1'), findsOneWidget);
    expect(find.text('Restore dry run'), findsOneWidget);
  });

  testWidgets('backup guardian screen shows status and roadmap', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          backupGuardianSnapshotProvider.overrideWith(
            (ref) async => BackupGuardianSnapshot(
              config: BackupGuardianConfig(
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
                staleAfterDays: 7,
                quickKeep: 7,
                dailyKeep: 7,
                weeklyKeep: 4,
                monthlyKeep: 12,
                mode: 'mirror',
                configPath:
                    'modules/system_backup/config/backup_paths.local.json',
                isLocalConfig: true,
              ),
              statusFilePath:
                  'modules/system_backup/runtime/latest_status.json',
              statusFileExists: true,
              sourceExists: true,
              backupDriveExists: true,
              mirrorFolderExists: false,
              healthState: BackupGuardianHealthState.green,
              latestBackupStatus: 'Latest backup verified',
              latestReportPath: 'E:/NEW_EARTH_BACKUP/reports/latest.log',
              latestManifestPath:
                  'E:/NEW_EARTH_BACKUP/manifests/backup_manifest_20260607_060000.json',
              restoreTestStatus: 'Not run yet',
              backupSizeText: 'Not tracked in V1',
              historyFilePath:
                  'modules/system_backup/runtime/backup_history.json',
              historyEntries: <BackupGuardianHistoryEntry>[
                BackupGuardianHistoryEntry(
                  action: 'Backup Now',
                  mode: 'BackupNow',
                  state: 'green',
                  summary: 'Latest backup verified',
                  startedAt: DateTime.parse('2026-06-07T05:55:00Z'),
                  finishedAt: DateTime.parse('2026-06-07T06:00:00Z'),
                  durationMs: 300000,
                  filesScanned: 12,
                  filesCopied: 12,
                  filesSkipped: 0,
                  backupSizeText: '2.0 KB',
                  manifestPath:
                      'E:/NEW_EARTH_BACKUP/manifests/backup_manifest_20260607_060000.json',
                  reportPath: 'E:/NEW_EARTH_BACKUP/reports/latest.log',
                  restorePointLabel: 'Manual backup - 2026-06-07 06:00',
                ),
              ],
              restorePoints: <BackupGuardianHistoryEntry>[
                BackupGuardianHistoryEntry(
                  action: 'Backup Now',
                  mode: 'BackupNow',
                  state: 'green',
                  summary: 'Latest backup verified',
                  startedAt: DateTime.parse('2026-06-07T05:55:00Z'),
                  finishedAt: DateTime.parse('2026-06-07T06:00:00Z'),
                  durationMs: 300000,
                  filesScanned: 12,
                  filesCopied: 12,
                  filesSkipped: 0,
                  backupSizeText: '2.0 KB',
                  manifestPath:
                      'E:/NEW_EARTH_BACKUP/manifests/backup_manifest_20260607_060000.json',
                  reportPath: 'E:/NEW_EARTH_BACKUP/reports/latest.log',
                  restorePointLabel: 'Manual backup - 2026-06-07 06:00',
                ),
              ],
              scheduleSummary:
                  'Scheduled daily at 02:00, weekly on Sunday, monthly on day 1.',
              retentionSummary:
                  'Quick keep 7, daily keep 7, weekly keep 4, monthly keep 12.',
              freshnessSummary: 'Backup ran today.',
              notificationBanner:
                  'Scheduled daily at 02:00, weekly on Sunday, monthly on day 1.',
              nextSuggestedRun: null,
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
    expect(find.text('Verify Latest'), findsOneWidget);
    expect(find.text('Restore Dry Run'), findsOneWidget);
    expect(find.text('Quick Incremental'), findsOneWidget);
    expect(find.text('Open Backup Root'), findsOneWidget);
    expect(find.text('BackupNow'), findsWidgets);
    expect(find.text('1 event'), findsOneWidget);
    expect(find.text('1 restore point'), findsOneWidget);
    expect(
      find.text('Latest restore point: Manual backup - 2026-06-07 06:00'),
      findsOneWidget,
    );
    expect(find.textContaining('Showing all runs.'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Backups'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Verification'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Restore points'), findsOneWidget);
    expect(find.text('Pick a restore point'), findsOneWidget);
    expect(find.text('Backup growth'), findsOneWidget);
    expect(find.text('Recent reports'), findsOneWidget);
    expect(find.text('Quick 7'), findsOneWidget);
    expect(find.text('Daily 7'), findsOneWidget);
    expect(find.text('Weekly 4'), findsOneWidget);
    expect(find.text('Monthly 12'), findsOneWidget);
    expect(find.text('Roadmap / Future work'), findsOneWidget);
    expect(find.text('V2 planned'), findsOneWidget);
    expect(find.text('V3 planned'), findsOneWidget);
    expect(find.text('Latest manifest path'), findsOneWidget);
    expect(
      find.text(
        'Mirror folder is not ready yet, so I am opening the backup root instead.',
      ),
      findsOneWidget,
    );
  });
}
