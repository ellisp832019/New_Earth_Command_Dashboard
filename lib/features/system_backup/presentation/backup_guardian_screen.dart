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
                          onDryRun: () =>
                              _runAction(BackupGuardianAction.dryRun),
                          onBackupNow: () =>
                              _runAction(BackupGuardianAction.backupNow),
                          onVerifyLatest: () =>
                              _runAction(BackupGuardianAction.verifyLatest),
                          onRestoreDryRun: () =>
                              _runAction(BackupGuardianAction.restoreDryRun),
                          onOpenBackupFolder: () => _openBackupFolder(snapshot),
                          onViewLatestReport: () =>
                              _viewLatestReport(snapshot),
                        ),
                        const SizedBox(height: 20),
                        _StatusGrid(snapshot: snapshot),
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

  Future<void> _runAction(BackupGuardianAction action) async {
    if (_isBusy) {
      return;
    }

    setState(() {
      _isBusy = true;
      _statusMessage = switch (action) {
        BackupGuardianAction.dryRun => 'Launching Dry Run...',
        BackupGuardianAction.backupNow => 'Launching Backup Now...',
        BackupGuardianAction.verifyLatest => 'Launching Verify Latest...',
        BackupGuardianAction.restoreDryRun => 'Launching Restore Dry Run...',
      };
    });

    try {
      await ref.read(backupGuardianServiceProvider).runAction(action);
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage =
            'Action launched. Refresh the page after the script finishes.';
      });
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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
                  'Local-first backup for D: to the external drive.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.4,
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
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FilledButton.tonalIcon(
                onPressed: onBackToSystems,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Systems'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onBackToMore,
                icon: const Icon(Icons.apps_outlined),
                label: const Text('Back to More'),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                children: [
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
                        : 'Waiting for external drive',
                    accent: snapshot.backupDriveExists
                        ? AppColours.darkPurple
                        : AppColours.darkAmber,
                  ),
                ],
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
    required this.onDryRun,
    required this.onBackupNow,
    required this.onVerifyLatest,
    required this.onRestoreDryRun,
    required this.onOpenBackupFolder,
    required this.onViewLatestReport,
  });

  final bool isBusy;
  final VoidCallback onDryRun;
  final VoidCallback onBackupNow;
  final VoidCallback onVerifyLatest;
  final VoidCallback onRestoreDryRun;
  final VoidCallback onOpenBackupFolder;
  final VoidCallback onViewLatestReport;

  @override
  Widget build(BuildContext context) {
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
              OutlinedButton.icon(
                onPressed: isBusy ? null : onVerifyLatest,
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Verify Latest'),
              ),
              OutlinedButton.icon(
                onPressed: isBusy ? null : onRestoreDryRun,
                icon: const Icon(Icons.restore_outlined),
                label: const Text('Restore Dry Run'),
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
            : 'Waiting for external drive',
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
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
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
