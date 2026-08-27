import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/gaia/application/gaia_employee_providers.dart';
import 'package:new_earth_command_dashboard/features/more/presentation/more_screen.dart';
import 'package:new_earth_command_dashboard/features/system_backup/application/backup_guardian_controller.dart';
import 'package:new_earth_command_dashboard/features/system_backup/data/backup_guardian_service.dart';
import 'package:new_earth_command_dashboard/features/system_backup/presentation/backup_guardian_screen.dart';
import 'package:new_earth_command_dashboard/features/systems/presentation/systems_screen.dart';

void main() {
  testWidgets('more screen surfaces systems as a module', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gaiaEmployeeFeatureEnabledProvider.overrideWithValue(false),
        ],
        child: const MaterialApp(home: MoreScreen()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Systems'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.text('Systems'), findsAtLeastNWidgets(1));
    expect(
      find.text('Review protected recovery state and local system safeguards.'),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('systems screen surfaces backup guardian', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: const MaterialApp(home: SystemsScreen())),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Backup Guardian'), findsAtLeastNWidgets(1));
    expect(find.text('Manual V1'), findsAtLeastNWidgets(1));
    expect(find.text('Restore dry run'), findsAtLeastNWidgets(1));
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
              latestManifestExists: true,
              verificationSummary:
                  'Latest backup matches the manifest fingerprint.',
              verificationDetails: <String>[
                'Manifest: backup_manifest_20260607_060000.json',
                'Current mirror: 12 files, 2.0 KB.',
                'Fingerprint: recorded in the manifest.',
              ],
              restoreTestStatus: 'Not run yet',
              backupSizeText: 'Not tracked in V1',
              historyFilePath:
                  'modules/system_backup/runtime/backup_history.json',
              historyEntries: <BackupGuardianHistoryEntry>[
                BackupGuardianHistoryEntry(
                  action: 'Verify Latest',
                  mode: 'VerifyLatest',
                  backupKind: 'manual',
                  state: 'green',
                  summary: 'Latest backup verified',
                  startedAt: DateTime.parse('2026-06-08T05:55:00Z'),
                  finishedAt: DateTime.parse('2026-06-08T06:00:00Z'),
                  durationMs: 60000,
                  filesScanned: 12,
                  filesCopied: 12,
                  filesSkipped: 0,
                  backupSizeText: '9.0 KB',
                  manifestPath:
                      'E:/NEW_EARTH_BACKUP/manifests/backup_manifest_20260608_060000.json',
                  reportPath: '',
                  restorePointLabel: '',
                ),
                BackupGuardianHistoryEntry(
                  action: 'Backup Now',
                  mode: 'BackupNow',
                  backupKind: 'manual',
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
                BackupGuardianHistoryEntry(
                  action: 'Daily Backup',
                  mode: 'DailyBackup',
                  backupKind: 'daily',
                  state: 'green',
                  summary: 'Scheduled daily backup completed successfully.',
                  startedAt: DateTime.parse('2026-06-06T05:55:00Z'),
                  finishedAt: DateTime.parse('2026-06-06T06:00:00Z'),
                  durationMs: 240000,
                  filesScanned: 10,
                  filesCopied: 10,
                  filesSkipped: 0,
                  backupSizeText: '1.5 KB',
                  manifestPath:
                      'E:/NEW_EARTH_BACKUP/manifests/backup_manifest_20260606_060000.json',
                  reportPath: 'E:/NEW_EARTH_BACKUP/reports/older.log',
                  restorePointLabel: 'Daily backup - 2026-06-06 06:00',
                ),
              ],
              restorePoints: <BackupGuardianHistoryEntry>[
                BackupGuardianHistoryEntry(
                  action: 'Backup Now',
                  mode: 'BackupNow',
                  backupKind: 'manual',
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
                BackupGuardianHistoryEntry(
                  action: 'Daily Backup',
                  mode: 'DailyBackup',
                  backupKind: 'daily',
                  state: 'green',
                  summary: 'Scheduled daily backup completed successfully.',
                  startedAt: DateTime.parse('2026-06-06T05:55:00Z'),
                  finishedAt: DateTime.parse('2026-06-06T06:00:00Z'),
                  durationMs: 240000,
                  filesScanned: 10,
                  filesCopied: 10,
                  filesSkipped: 0,
                  backupSizeText: '1.5 KB',
                  manifestPath:
                      'E:/NEW_EARTH_BACKUP/manifests/backup_manifest_20260606_060000.json',
                  reportPath: 'E:/NEW_EARTH_BACKUP/reports/older.log',
                  restorePointLabel: 'Daily backup - 2026-06-06 06:00',
                ),
              ],
              scheduleSummary:
                  'Scheduled daily at 02:00, weekly on Sunday, monthly on day 1.',
              schedulerHealthState: BackupGuardianHealthState.green,
              schedulerSummary:
                  'Scheduler verified. Daily, weekly, and monthly tasks are present and enabled.',
              schedulerDetails: <String>[
                'Daily backup task: Ready',
                'Weekly snapshot task: Ready',
                'Monthly archive task: Ready',
              ],
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
              verificationMismatchAreas: <String>[],
              healthSummary: 'Latest backup verified',
            ),
          ),
        ],
        child: const MaterialApp(home: BackupGuardianScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Backup Guardian'), findsAtLeastNWidgets(1));
    expect(find.text('Dry Run'), findsAtLeastNWidgets(1));
    expect(find.text('Verify Latest'), findsWidgets);
    expect(find.text('Restore Dry Run'), findsAtLeastNWidgets(1));
    expect(find.text('Quick Incremental'), findsAtLeastNWidgets(1));
    expect(find.text('Run state summary'), findsAtLeastNWidgets(1));
    expect(
      find.textContaining('State: Latest backup verified'),
      findsAtLeastNWidgets(1),
    );
    expect(find.textContaining('Health: Green'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Restore points: 2'), findsAtLeastNWidgets(1));
    expect(
      find.textContaining('Latest report: latest.log'),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('Open Backup Root'), findsAtLeastNWidgets(1));
    expect(
      find.text(
        'Click opens the backup root at E:/NEW_EARTH_BACKUP because the mirror folder is not ready yet.',
      ),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('Open Latest Report'), findsAtLeastNWidgets(1));
    expect(find.text('Latest report: latest.log'), findsAtLeastNWidgets(2));
    expect(find.text('BackupNow'), findsWidgets);
    expect(find.text('3 events'), findsAtLeastNWidgets(1));
    expect(find.text('2 restore points'), findsAtLeastNWidgets(1));
    expect(
      find.text('Latest restore point: Manual backup - 2026-06-07 06:00'),
      findsAtLeastNWidgets(1),
    );
    expect(find.textContaining('Showing all runs.'), findsAtLeastNWidgets(1));
    expect(
      find.text(
        'Use filters to focus on backups, verification, restore points, or health states.',
      ),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.widgetWithText(FilterChip, 'Backups (2)'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.widgetWithText(FilterChip, 'Verification (1)'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.widgetWithText(FilterChip, 'Restore points (3)'),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('Pick a restore point'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Action: Backup Now'), findsWidgets);
    expect(find.textContaining('Kind: manual'), findsWidgets);
    expect(find.textContaining('Report: latest.log'), findsWidgets);
    expect(find.text('Backup growth'), findsAtLeastNWidgets(1));
    expect(
      find.textContaining('Latest backup size: 2.0 KB'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.textContaining('Previous backup size: 1.5 KB'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.textContaining(
        'Backup size grew by 512 B compared with the previous run.',
      ),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('Latest report'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Report: older.log'), findsWidgets);
    expect(find.text('Recent reports'), findsAtLeastNWidgets(1));
    expect(find.text('Quick 7'), findsAtLeastNWidgets(1));
    expect(find.text('Daily 7'), findsAtLeastNWidgets(1));
    expect(find.text('Weekly 4'), findsAtLeastNWidgets(1));
    expect(find.text('Monthly 12'), findsAtLeastNWidgets(1));
    expect(
      find.text(
        'Quick keeps the newest snapshots, daily keeps routine runs, weekly keeps recovery points, and monthly keeps long-term archives.',
      ),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('Roadmap / Future work'), findsAtLeastNWidgets(1));
    expect(find.text('V2 roadmap'), findsAtLeastNWidgets(1));
    expect(find.text('V3 roadmap'), findsAtLeastNWidgets(1));
    expect(find.text('Current run state'), findsAtLeastNWidgets(1));
    expect(find.text('Latest manifest path'), findsAtLeastNWidgets(1));
    expect(find.text('Verification details'), findsAtLeastNWidgets(1));
    expect(
      find.text('Latest backup matches the manifest fingerprint.'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.textContaining(
        'Scheduled daily at 02:00, weekly on Sunday, monthly on day 1.',
      ),
      findsWidgets,
    );
    expect(
      find.text(
        'Restore preview stays read-only and writes only to the test area.',
      ),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.text(
        'Mirror folder is not ready yet, so the backup root will open instead.',
      ),
      findsAtLeastNWidgets(1),
    );
  });
}
