import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../../system_backup/application/backup_guardian_controller.dart';
import '../../system_backup/data/backup_guardian_service.dart';

class SystemsScreen extends ConsumerWidget {
  const SystemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final snapshotAsync = ref.watch(backupGuardianSnapshotProvider);

    return WorkspaceShell(
      title: 'Systems',
      subtitle: 'Local protection and recovery workspace',
      onBack: () => context.go(RouteNames.more),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: _systemsPanelDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Systems',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: AppColours.darkText,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Local protection and recovery tools live here.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColours.darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Backup Guardian starts the first V1 slice: safe manual backups, status, reports, and restore drills.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColours.darkMutedText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'After launch, you can close the dashboard while the backup script continues running.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColours.darkSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InlineTag(
                        label: 'Safe to close',
                        accent: AppColours.darkSecondary,
                        icon: Icons.lock_open_outlined,
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go(RouteNames.more),
                        icon: const Icon(Icons.grid_view_outlined),
                        label: const Text('Back to More'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            snapshotAsync.when(
              loading: () => _BackupGuardianCard(
                title: 'Backup Guardian',
                subtitle:
                    'Back up the full D: drive to E: / NEW_EARTH_BACKUP, view status, open the backup folder, and keep restore work dry-run only in V1.',
                statusLabel: 'Loading backup state',
                statusAccent: AppColours.darkSecondary,
                statusBanner: 'Checking E: / NEW_EARTH_BACKUP...',
                stripAnimate: true,
                tags: const [
                  'Manual V1',
                  'Local-first',
                  'Reports',
                  'Restore dry run',
                ],
                highlightedTagLabel: null,
                highlightedTagAccent: AppColours.darkPurple,
                highlightedTagIcon: null,
                footerText: 'Last verified pending',
                footerAccent: AppColours.darkPurple,
                onTap: () => context.push(RouteNames.backupGuardian),
              ),
              error: (error, stackTrace) => _BackupGuardianCard(
                title: 'Backup Guardian',
                subtitle:
                    'Back up the full D: drive to E: / NEW_EARTH_BACKUP, view status, open the backup folder, and keep restore work dry-run only in V1.',
                statusLabel: 'State unavailable',
                statusAccent: AppColours.darkAmber,
                statusBanner: 'Could not load live backup state',
                stripAnimate: true,
                tags: const [
                  'Manual V1',
                  'Local-first',
                  'Reports',
                  'Restore dry run',
                ],
                highlightedTagLabel: null,
                highlightedTagAccent: AppColours.darkPurple,
                highlightedTagIcon: null,
                footerText: 'Last verified pending',
                footerAccent: AppColours.darkPurple,
                onTap: () => context.push(RouteNames.backupGuardian),
              ),
              data: (snapshot) {
                final driveReady = snapshot.backupDriveExists;
                final statusAccent = driveReady
                    ? AppColours.darkSuccess
                    : AppColours.darkAmber;
                final schedulerAccent = _schedulerAccent(snapshot);
                return _BackupGuardianCard(
                  title: 'Backup Guardian',
                  subtitle:
                      'Back up the full D: drive to E: / NEW_EARTH_BACKUP, view status, open the backup folder, and keep restore work dry-run only in V1.',
                  statusLabel: driveReady ? 'Drive ready' : 'Waiting for drive',
                  statusAccent: statusAccent,
                  statusBanner: driveReady
                      ? 'E: / NEW_EARTH_BACKUP is visible and ready.'
                      : 'Waiting for E: / NEW_EARTH_BACKUP to connect.',
                  stripAnimate: !driveReady,
                  tags: [
                    driveReady ? 'Ready' : 'Waiting',
                    'Manual V1',
                    'Local-first',
                    'Reports',
                    'Restore dry run',
                    'Safe to close',
                  ],
                  highlightedTagLabel: _schedulerLabel(snapshot),
                  highlightedTagAccent: schedulerAccent,
                  highlightedTagIcon: _schedulerIcon(snapshot.schedulerHealthState),
                  footerText: _schedulerFooterText(snapshot),
                  footerAccent: schedulerAccent,
                  onTap: () => context.push(RouteNames.backupGuardian),
                );
              },
            ),
            const SizedBox(height: 14),
            Text(
              'Planned systems',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColours.darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                final cards = const [
                  _PlannedSystemCard(
                    icon: Icons.monitor_heart_outlined,
                    title: 'Drive Health',
                    description:
                        'Check source drive space, backup drive presence, and simple recovery signals.',
                    tags: ['Planned', 'Health checks'],
                  ),
                  _PlannedSystemCard(
                    icon: Icons.restore_outlined,
                    title: 'Restore Lab',
                    description:
                        'Stage safe restore drills and review restore notes without touching live files.',
                    tags: ['Planned', 'Dry run only'],
                  ),
                  _PlannedSystemCard(
                    icon: Icons.devices_outlined,
                    title: 'Device Health',
                    description:
                        'Watch connected devices, printer readiness, and other local hardware signals.',
                    tags: ['Planned', 'Hardware'],
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
                    Expanded(child: cards[1]),
                    const SizedBox(width: 12),
                    Expanded(child: cards.last),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupGuardianCard extends StatelessWidget {
  const _BackupGuardianCard({
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusAccent,
    required this.statusBanner,
    required this.stripAnimate,
    required this.tags,
    required this.highlightedTagLabel,
    required this.highlightedTagAccent,
    required this.highlightedTagIcon,
    required this.footerText,
    required this.footerAccent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusAccent;
  final String statusBanner;
  final bool stripAnimate;
  final List<String> tags;
  final String? highlightedTagLabel;
  final Color highlightedTagAccent;
  final IconData? highlightedTagIcon;
  final String footerText;
  final Color footerAccent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: _systemsPanelDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusPulseStrip(color: statusAccent, animate: stripAnimate),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: statusAccent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: statusAccent.withValues(alpha: 0.35),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.backup_outlined, color: statusAccent),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColours.darkText,
                          ),
                        ),
                      ),
                      _InlineTag(label: statusLabel, accent: statusAccent),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: statusAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: statusAccent.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Text(
                      statusBanner,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkMutedText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Safe to close once the action is launched.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColours.darkSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (highlightedTagLabel != null)
                        _InlineTag(
                          label: highlightedTagLabel!,
                          accent: highlightedTagAccent,
                          icon: highlightedTagIcon,
                        ),
                      for (final tag in tags) _InlineTag(label: tag),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _InlineTag(
                    label: footerText,
                    accent: footerAccent,
                    icon: Icons.schedule_send_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColours.darkMutedText),
          ],
        ),
      ),
    );
  }
}

class _PlannedSystemCard extends StatelessWidget {
  const _PlannedSystemCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.tags,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColours.darkSurfaceRaised.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColours.darkAmber),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkMutedText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final tag in tags) _InlineTag(label: tag)],
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColours.darkSurface.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.85)),
    );
  }
}

class _InlineTag extends StatelessWidget {
  const _InlineTag({
    required this.label,
    this.accent = AppColours.darkText,
    this.icon,
  });

  final String label;
  final Color accent;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: accent),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _systemsPanelDecoration() {
  return BoxDecoration(
    color: AppColours.darkSurface.withValues(alpha: 0.9),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.85)),
  );
}

String _schedulerLabel(BackupGuardianSnapshot snapshot) {
  return switch (snapshot.schedulerHealthState) {
    BackupGuardianHealthState.green => 'Scheduler Ready',
    BackupGuardianHealthState.amber => 'Scheduler Check',
    BackupGuardianHealthState.red => 'Scheduler Red',
    BackupGuardianHealthState.grey => 'Scheduler Pending',
  };
}

String _schedulerFooterText(BackupGuardianSnapshot snapshot) {
  final value = snapshot.lastVerificationAt;
  if (value == null) {
    return 'Last verified pending';
  }
  final local = value.toLocal();
  return 'Last verified ${local.day.toString().padLeft(2, '0')} ${_monthAbbreviation(local.month)} ${local.year}, ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

String _monthAbbreviation(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final index = month < 1
      ? 0
      : month > 12
      ? 11
      : month - 1;
  return months[index];
}

Color _schedulerAccent(BackupGuardianSnapshot snapshot) {
  return switch (snapshot.schedulerHealthState) {
    BackupGuardianHealthState.green => AppColours.darkSuccess,
    BackupGuardianHealthState.amber => AppColours.darkAmber,
    BackupGuardianHealthState.red => AppColours.darkSecondary,
    BackupGuardianHealthState.grey => AppColours.darkPurple,
  };
}

IconData _schedulerIcon(BackupGuardianHealthState state) {
  return switch (state) {
    BackupGuardianHealthState.green => Icons.verified_outlined,
    BackupGuardianHealthState.amber => Icons.schedule_outlined,
    BackupGuardianHealthState.red => Icons.error_outline,
    BackupGuardianHealthState.grey => Icons.help_outline,
  };
}

class _StatusPulseStrip extends StatefulWidget {
  const _StatusPulseStrip({required this.color, required this.animate});

  final Color color;
  final bool animate;

  @override
  State<_StatusPulseStrip> createState() => _StatusPulseStripState();
}

class _StatusPulseStripState extends State<_StatusPulseStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _StatusPulseStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = Tween<double>(begin: 0.55, end: 1.0).animate(_controller);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = widget.animate ? animation.value : 1.0;
        return Container(
          height: 6,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: opacity * 0.18),
                blurRadius: widget.animate ? 10 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
      },
    );
  }
}
