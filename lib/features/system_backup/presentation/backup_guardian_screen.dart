import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/backup_guardian_controller.dart';
import '../data/backup_guardian_service.dart';

class BackupGuardianScreen extends ConsumerStatefulWidget {
  const BackupGuardianScreen({super.key});

  @override
  ConsumerState<BackupGuardianScreen> createState() =>
      _BackupGuardianScreenState();
}

class _BackupGuardianScreenState extends ConsumerState<BackupGuardianScreen> {
  bool _isBusy = false;
  String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    final snapshotAsync = ref.watch(backupGuardianSnapshotProvider);

    return snapshotAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => _ErrorState(
        message: 'Backup Guardian could not load right now.',
        onBack: () => context.go(RouteNames.systems),
        onRetry: () => ref.invalidate(backupGuardianSnapshotProvider),
      ),
      data: (snapshot) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeroCard(
                          snapshot: snapshot,
                          statusMessage: _statusMessage,
                          onBackToSystems: () => context.go(RouteNames.systems),
                          onBackToMore: () => context.go(RouteNames.more),
                        ),
                        const SizedBox(height: 20),
                        _ActionCard(
                          isBusy: _isBusy,
                          snapshot: snapshot,
                          onDryRun: () =>
                              _runAction(BackupGuardianAction.dryRun, snapshot),
                          onBackupNow: () =>
                              _runAction(BackupGuardianAction.backupNow, snapshot),
                          onVerifyLatest: () =>
                              _runAction(
                                BackupGuardianAction.verifyLatest,
                                snapshot,
                              ),
                          onRestoreDryRun: () =>
                              _runAction(
                                BackupGuardianAction.restoreDryRun,
                                snapshot,
                              ),
                          onQuickIncremental: () => _runAction(
                            BackupGuardianAction.quickIncremental,
                            snapshot,
                          ),
                          onOpenBackupFolder: () => _openBackupFolder(snapshot),
                          onViewLatestReport: () =>
                              _viewLatestReport(snapshot),
                          onRefreshStatus: _refreshStatus,
                        ),
                        const SizedBox(height: 20),
                        _AutomationCard(
                          snapshot: snapshot,
                          isBusy: _isBusy,
                          onDailyBackup: () => _runAction(
                            BackupGuardianAction.dailyBackup,
                            snapshot,
                          ),
                          onWeeklySnapshot: () => _runAction(
                            BackupGuardianAction.weeklySnapshot,
                            snapshot,
                          ),
                          onMonthlyArchive: () => _runAction(
                            BackupGuardianAction.monthlyArchive,
                            snapshot,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _StatusGrid(snapshot: snapshot),
                        const SizedBox(height: 20),
                        _HistoryCard(snapshot: snapshot),
                        const SizedBox(height: 20),
                        _WarningsCard(snapshot: snapshot),
                        const SizedBox(height: 20),
                        _ActivityCard(snapshot: snapshot),
                        const SizedBox(height: 20),
                        const _RoadmapCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _runAction(
    BackupGuardianAction action,
    BackupGuardianSnapshot snapshot,
  ) async {
    if (_isBusy) {
      return;
    }

    setState(() {
      _isBusy = true;
      _statusMessage = _launchMessage(action, snapshot);
    });

    try {
      await ref.read(backupGuardianServiceProvider).runAction(action);
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = _afterLaunchMessage(action, snapshot);
      });
      _scheduleStatusRefresh();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = 'Could not launch the action.';
      });
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _openBackupFolder(BackupGuardianSnapshot snapshot) async {
    await ref.read(backupGuardianServiceProvider).openBackupFolder(snapshot);
  }

  Future<void> _viewLatestReport(BackupGuardianSnapshot snapshot) async {
    await ref.read(backupGuardianServiceProvider).viewLatestReport(snapshot);
  }

  void _refreshStatus() {
    ref.invalidate(backupGuardianSnapshotProvider);
    if (!mounted) {
      return;
    }
    setState(() {
      _statusMessage = 'Refreshing backup status...';
    });
  }

  void _scheduleStatusRefresh() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) {
        return;
      }
      ref.invalidate(backupGuardianSnapshotProvider);
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) {
        return;
      }
      ref.invalidate(backupGuardianSnapshotProvider);
    });
  }

  String _launchMessage(
    BackupGuardianAction action,
    BackupGuardianSnapshot snapshot,
  ) {
    return switch (action) {
      BackupGuardianAction.dryRun =>
        'Dry Run launching. It will compare D: with ${snapshot.backupTarget} without copying files.',
      BackupGuardianAction.backupNow =>
        'Backup Now launching for ${snapshot.backupTarget}.',
      BackupGuardianAction.verifyLatest =>
        'Verify Latest launching. Current saved result: ${snapshot.latestBackupStatus}.',
      BackupGuardianAction.restoreDryRun =>
        'Restore Dry Run launching into ${snapshot.config.restoreTestFolder}.',
      BackupGuardianAction.quickIncremental =>
        'Quick Incremental launching. It will copy only new and changed files into the mirror target.',
      BackupGuardianAction.dailyBackup =>
        'Daily Backup launching for the scheduled V2 run.',
      BackupGuardianAction.weeklySnapshot =>
        'Weekly Snapshot launching for a dated restore point.',
      BackupGuardianAction.monthlyArchive =>
        'Monthly Archive launching for the longer-term restore set.',
    };
  }

  String _afterLaunchMessage(
    BackupGuardianAction action,
    BackupGuardianSnapshot snapshot,
  ) {
    return switch (action) {
      BackupGuardianAction.dryRun =>
        'Dry Run started. The current saved status is ${snapshot.latestBackupStatus}. The page will refresh shortly.',
      BackupGuardianAction.backupNow =>
        'Backup Now started. Current target: ${snapshot.backupTarget}. The page will refresh shortly.',
      BackupGuardianAction.verifyLatest =>
        'Verify Latest started. Saved status: ${snapshot.latestBackupStatus}. Last verification: ${_formatDate(snapshot.lastVerificationAt)}. The page will refresh shortly.',
      BackupGuardianAction.restoreDryRun =>
        'Restore Dry Run started. Test folder: ${snapshot.config.restoreTestFolder}. The page will refresh shortly.',
      BackupGuardianAction.quickIncremental =>
        'Quick Incremental started. Only new and changed files should copy. The page will refresh shortly.',
      BackupGuardianAction.dailyBackup =>
        'Daily Backup started. The timeline will refresh shortly.',
      BackupGuardianAction.weeklySnapshot =>
        'Weekly Snapshot started. The timeline will refresh shortly.',
      BackupGuardianAction.monthlyArchive =>
        'Monthly Archive started. The timeline will refresh shortly.',
    };
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.snapshot,
    required this.onBackToSystems,
    required this.onBackToMore,
    required this.statusMessage,
  });

  final BackupGuardianSnapshot snapshot;
  final VoidCallback onBackToSystems;
  final VoidCallback onBackToMore;
  final String? statusMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(context, highlighted: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Backup Guardian',
            style: theme.textTheme.displaySmall?.copyWith(
              color: AppColours.darkText,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'More / Systems / Backup Guardian',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Local-first backup for D: to E: / NEW_EARTH_BACKUP.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            snapshot.notificationBanner,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You can close the dashboard after launching an action. The backup script keeps running on its own.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              height: 1.35,
            ),
          ),
          if (statusMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              statusMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColours.darkSecondary,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              FilledButton.tonalIcon(
                onPressed: onBackToSystems,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Systems'),
              ),
              OutlinedButton.icon(
                onPressed: onBackToMore,
                icon: const Icon(Icons.apps_outlined),
                label: const Text('Back to More'),
              ),
              _Badge(
                label: snapshot.config.isLocalConfig
                    ? 'Local config'
                    : 'Example config',
                accent: snapshot.config.isLocalConfig
                    ? AppColours.darkSuccess
                    : AppColours.darkAmber,
              ),
              _Badge(
                label: _healthLabel(snapshot.healthState),
                accent: _healthAccent(snapshot.healthState),
              ),
              _Badge(
                label: snapshot.sourceDrive,
                accent: AppColours.darkSecondary,
              ),
              _Badge(
                label: snapshot.backupDriveExists
                    ? snapshot.backupTarget
                    : 'Waiting for E: / NEW_EARTH_BACKUP',
                accent: snapshot.backupDriveExists
                    ? AppColours.darkPurple
                    : AppColours.darkAmber,
              ),
              _Badge(
                label: 'Safe to close',
                accent: AppColours.darkSecondary,
                icon: Icons.lock_open_outlined,
              ),
              _Badge(
                label: 'Scheduled V2',
                accent: AppColours.darkSuccess,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.isBusy,
    required this.snapshot,
    required this.onDryRun,
    required this.onBackupNow,
    required this.onVerifyLatest,
    required this.onRestoreDryRun,
    required this.onQuickIncremental,
    required this.onOpenBackupFolder,
    required this.onViewLatestReport,
    required this.onRefreshStatus,
  });

  final bool isBusy;
  final BackupGuardianSnapshot snapshot;
  final VoidCallback onDryRun;
  final VoidCallback onBackupNow;
  final VoidCallback onVerifyLatest;
  final VoidCallback onRestoreDryRun;
  final VoidCallback onQuickIncremental;
  final VoidCallback onOpenBackupFolder;
  final VoidCallback onViewLatestReport;
  final VoidCallback onRefreshStatus;

  @override
  Widget build(BuildContext context) {
    final hasVerification = snapshot.lastVerificationAt != null;
    final verificationIsFresh = hasVerification &&
        DateTime.now().difference(snapshot.lastVerificationAt!.toLocal()) <=
            const Duration(days: 7);
    final verifyAccent = verificationIsFresh
        ? AppColours.darkSuccess
        : AppColours.darkAmber;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Actions', icon: Icons.play_arrow_outlined),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: isBusy ? null : onDryRun,
                icon: const Icon(Icons.science_outlined),
                label: const Text('Dry Run'),
              ),
              FilledButton.icon(
                onPressed: isBusy ? null : onBackupNow,
                icon: const Icon(Icons.backup_outlined),
                label: const Text('Backup Now'),
              ),
              verificationIsFresh
                  ? FilledButton.icon(
                      onPressed: isBusy ? null : onVerifyLatest,
                      style: FilledButton.styleFrom(
                        backgroundColor: verifyAccent,
                        foregroundColor: AppColours.darkBackground,
                      ),
                      icon: const Icon(Icons.verified_outlined),
                      label: const Text('Verify Latest'),
                    )
                  : OutlinedButton.icon(
                      onPressed: isBusy ? null : onVerifyLatest,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: verifyAccent,
                        side: BorderSide(
                          color: verifyAccent.withValues(alpha: 0.55),
                        ),
                      ),
                      icon: const Icon(Icons.verified_outlined),
                      label: const Text('Verify Latest'),
                    ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  !hasVerification
                      ? 'Last verified: never'
                      : 'Last verified: ${_formatDate(snapshot.lastVerificationAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: verifyAccent,
                      ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: isBusy ? null : onRestoreDryRun,
                icon: const Icon(Icons.restore_outlined),
                label: const Text('Restore Dry Run'),
              ),
              FilledButton.tonalIcon(
                onPressed: isBusy ? null : onQuickIncremental,
                icon: const Icon(Icons.bolt_outlined),
                label: const Text('Quick Incremental'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenBackupFolder,
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Open Backup Folder'),
              ),
              OutlinedButton.icon(
                onPressed: onViewLatestReport,
                icon: const Icon(Icons.article_outlined),
                label: const Text('View Latest Report'),
              ),
              OutlinedButton.icon(
                onPressed: onRefreshStatus,
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Refresh Status'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AutomationCard extends StatelessWidget {
  const _AutomationCard({
    required this.snapshot,
    required this.isBusy,
    required this.onDailyBackup,
    required this.onWeeklySnapshot,
    required this.onMonthlyArchive,
  });

  final BackupGuardianSnapshot snapshot;
  final bool isBusy;
  final VoidCallback onDailyBackup;
  final VoidCallback onWeeklySnapshot;
  final VoidCallback onMonthlyArchive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Schedule and retention',
            icon: Icons.schedule_outlined,
          ),
          const SizedBox(height: 10),
          Text(
            snapshot.scheduleSummary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            snapshot.retentionSummary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkSecondary,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            snapshot.freshnessSummary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkText,
                  height: 1.35,
                ),
          ),
          if (snapshot.nextSuggestedRun != null) ...[
            const SizedBox(height: 6),
            Text(
              'Next suggested run: ${_formatDate(snapshot.nextSuggestedRun)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
                  ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: isBusy ? null : onDailyBackup,
                icon: const Icon(Icons.today_outlined),
                label: const Text('Daily Backup'),
              ),
              OutlinedButton.icon(
                onPressed: isBusy ? null : onWeeklySnapshot,
                icon: const Icon(Icons.view_week_outlined),
                label: const Text('Weekly Snapshot'),
              ),
              OutlinedButton.icon(
                onPressed: isBusy ? null : onMonthlyArchive,
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text('Monthly Archive'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.snapshot});

  final BackupGuardianSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Timeline and restore points',
            icon: Icons.timeline_outlined,
          ),
          const SizedBox(height: 10),
          Text(
            snapshot.hasHistory
                ? 'Recent events from ${p.basename(snapshot.historyFilePath)}'
                : 'No backup history has been recorded yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 880;
              final timeline = _EventList(
                title: 'Recent backup events',
                emptyText: 'No events yet.',
                entries: snapshot.historyEntries.take(5).toList(growable: false),
              );
              final restorePoints = _EventList(
                title: 'Restore points',
                emptyText: 'No restore points yet.',
                entries: snapshot.restorePoints.take(5).toList(growable: false),
                showRestorePointLabel: true,
              );

              if (!wide) {
                return Column(
                  children: [
                    timeline,
                    const SizedBox(height: 12),
                    restorePoints,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: timeline),
                  const SizedBox(width: 12),
                  Expanded(child: restorePoints),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({
    required this.title,
    required this.emptyText,
    required this.entries,
    this.showRestorePointLabel = false,
  });

  final String title;
  final String emptyText;
  final List<BackupGuardianHistoryEntry> entries;
  final bool showRestorePointLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            Text(
              emptyText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
            )
          else
            Column(
              children: [
                for (final entry in entries) ...[
                  _HistoryEntryTile(
                    entry: entry,
                    showRestorePointLabel: showRestorePointLabel,
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _HistoryEntryTile extends StatelessWidget {
  const _HistoryEntryTile({
    required this.entry,
    required this.showRestorePointLabel,
  });

  final BackupGuardianHistoryEntry entry;
  final bool showRestorePointLabel;

  @override
  Widget build(BuildContext context) {
    final accent = switch (entry.state.toLowerCase()) {
      'green' => AppColours.darkSuccess,
      'amber' => AppColours.darkAmber,
      'red' => AppColours.darkSecondary,
      _ => AppColours.darkPurple,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.action.isNotEmpty ? entry.action : entry.mode,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              _Badge(
                label: entry.state.toUpperCase(),
                accent: accent,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            entry.summary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(
                label: _formatDate(entry.finishedAt ?? entry.startedAt),
                accent: AppColours.darkSecondary,
              ),
              if (entry.duration != null)
                _Badge(
                  label: _formatDuration(entry.duration!),
                  accent: AppColours.darkSuccess,
                ),
              if (entry.filesCopied != null)
                _Badge(
                  label: '${entry.filesCopied} files',
                  accent: AppColours.darkPurple,
                ),
              if (showRestorePointLabel && entry.restorePointLabel.isNotEmpty)
                _Badge(
                  label: entry.restorePointLabel,
                  accent: AppColours.darkSuccess,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusGrid extends StatelessWidget {
  const _StatusGrid({required this.snapshot});

  final BackupGuardianSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatusTile(
        label: 'Source drive',
        value: snapshot.sourceDrive,
        detail: snapshot.sourceExists ? 'Visible on this machine' : 'Missing',
        accent: snapshot.sourceExists ? AppColours.darkSuccess : AppColours.darkAmber,
      ),
      _StatusTile(
        label: 'Backup target',
        value: snapshot.backupTarget,
        detail: snapshot.backupDriveExists
            ? 'External drive visible'
            : 'Waiting for E: / NEW_EARTH_BACKUP',
        accent: snapshot.backupDriveExists ? AppColours.darkSuccess : AppColours.darkAmber,
      ),
      _StatusTile(
        label: 'Latest backup status',
        value: snapshot.latestBackupStatus,
        detail: snapshot.statusFileExists ? 'From latest_status.json' : 'No status file yet',
        accent: AppColours.darkSecondary,
      ),
      _StatusTile(
        label: 'Last backup time',
        value: _formatDate(snapshot.lastBackupAt),
        detail: snapshot.lastBackupAt == null ? 'Not recorded yet' : 'From latest status',
        accent: AppColours.darkSecondary,
      ),
      _StatusTile(
        label: 'Last verification time',
        value: _formatDate(snapshot.lastVerificationAt),
        detail: snapshot.lastVerificationAt == null ? 'Not recorded yet' : 'From latest status',
        accent: AppColours.darkSecondary,
      ),
      _StatusTile(
        label: 'Health state',
        value: _healthLabel(snapshot.healthState).toUpperCase(),
        detail: snapshot.healthSummary,
        accent: _healthAccent(snapshot.healthState),
      ),
      _StatusTile(
        label: 'Backup size',
        value: snapshot.backupSizeText,
        detail: 'Tracked in the report layer later',
        accent: AppColours.darkPurple,
      ),
      _StatusTile(
        label: 'Restore test status',
        value: snapshot.restoreTestStatus,
        detail: 'Restore remains dry-run only in V1',
        accent: AppColours.darkPurple,
      ),
      _StatusTile(
        label: 'Latest report path',
        value: p.basename(snapshot.latestReportPath),
        detail: snapshot.latestReportPath,
        accent: AppColours.darkSecondary,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 3
            : constraints.maxWidth >= 760
            ? 2
            : 1;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final card in cards)
              SizedBox(
                width: _cardWidth(constraints.maxWidth, columns),
                child: card,
              ),
          ],
        );
      },
    );
  }

  double _cardWidth(double maxWidth, int columns) {
    if (columns == 1) {
      return maxWidth;
    }
    return (maxWidth - (14 * (columns - 1))) / columns;
  }
}

class _WarningsCard extends StatelessWidget {
  const _WarningsCard({required this.snapshot});

  final BackupGuardianSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Warnings and errors', icon: Icons.warning_amber_outlined),
          const SizedBox(height: 12),
          if (snapshot.warnings.isEmpty && snapshot.errors.isEmpty)
            Text(
              'No warnings yet. The backup module is quiet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.4,
                  ),
            )
          else ...[
            if (snapshot.warnings.isNotEmpty) ...[
              Text(
                snapshot.backupDriveExists ? 'Warnings' : 'Waiting',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColours.darkText,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in snapshot.warnings)
                    _Badge(label: item, accent: AppColours.darkAmber),
                ],
              ),
            ],
            if (snapshot.errors.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Errors',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColours.darkText,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in snapshot.errors)
                    _Badge(label: item, accent: AppColours.darkSecondary),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.snapshot});

  final BackupGuardianSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Activity', icon: Icons.timeline_outlined),
          const SizedBox(height: 12),
          Text(
            'Latest status file',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            p.basename(snapshot.statusFilePath),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Last status update',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatDate(snapshot.statusUpdatedAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
          ),
        ],
      ),
    );
  }
}

class _RoadmapCard extends StatelessWidget {
  const _RoadmapCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Roadmap / Future work',
            icon: Icons.route_outlined,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final cards = const [
                _RoadmapTile(
                  title: 'V2',
                  subtitle: 'Scheduled backups, history, retention, checksum verification',
                ),
                _RoadmapTile(
                  title: 'V3',
                  subtitle:
                      'Disaster recovery, multi-drive support, restore wizard, drive health',
                ),
              ];

              if (!wide) {
                return Column(
                  children: [
                    for (final card in cards) ...[
                      card,
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: cards.first),
                  const SizedBox(width: 12),
                  Expanded(child: cards.last),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RoadmapTile extends StatelessWidget {
  const _RoadmapTile({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Badge(label: '$title planned', accent: AppColours.darkAmber),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.label,
    required this.value,
    required this.detail,
    required this.accent,
  });

  final String label;
  final String value;
  final String detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.accent,
    this.icon,
  });

  final String label;
  final Color accent;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: accent),
            const SizedBox(width: 5),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColours.darkSurfaceRaised.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColours.darkSecondary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onBack,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: onBack,
                    child: const Text('Back'),
                  ),
                  FilledButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) {
    return 'Not recorded';
  }
  return DateFormat('d MMM yyyy, HH:mm').format(value.toLocal());
}

String _formatDuration(Duration value) {
  if (value.inSeconds < 60) {
    return '${value.inSeconds}s';
  }
  if (value.inMinutes < 60) {
    return '${value.inMinutes}m ${value.inSeconds.remainder(60)}s';
  }
  return '${value.inHours}h ${value.inMinutes.remainder(60)}m';
}

String _healthLabel(BackupGuardianHealthState state) {
  return switch (state) {
    BackupGuardianHealthState.green => 'Green',
    BackupGuardianHealthState.amber => 'Amber',
    BackupGuardianHealthState.red => 'Red',
    BackupGuardianHealthState.grey => 'Grey',
  };
}

Color _healthAccent(BackupGuardianHealthState state) {
  return switch (state) {
    BackupGuardianHealthState.green => AppColours.darkSuccess,
    BackupGuardianHealthState.amber => AppColours.darkAmber,
    BackupGuardianHealthState.red => AppColours.darkSecondary,
    BackupGuardianHealthState.grey => AppColours.darkPurple,
  };
}

BoxDecoration _panelDecoration(BuildContext context, {bool highlighted = false}) {
  return BoxDecoration(
    color: highlighted
        ? AppColours.darkSurfaceRaised.withValues(alpha: 0.96)
        : AppColours.darkSurface.withValues(alpha: 0.9),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.85)),
  );
}
