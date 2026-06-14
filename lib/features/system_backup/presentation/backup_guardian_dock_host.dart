import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../modules/application/module_hub_controller.dart';
import '../../../core/dock/dock_position.dart';
import '../../../core/modules/module_event_bus.dart';
import '../application/backup_guardian_controller.dart';
import '../data/backup_guardian_service.dart';

const _backupGuardianDockModuleId = 'backup_guardian_dock';

class BackupGuardianDockHost extends ConsumerStatefulWidget {
  const BackupGuardianDockHost({super.key, this.currentPath});

  final String? currentPath;

  @override
  ConsumerState<BackupGuardianDockHost> createState() =>
      _BackupGuardianDockHostState();
}

class _BackupGuardianDockHostState
    extends ConsumerState<BackupGuardianDockHost> {
  bool _isBusy = false;
  late DockPosition _position;

  @override
  void initState() {
    super.initState();
    _position =
        ref
            .read(moduleHubStateRepositoryProvider)
            .loadDockLayoutState()
            .positionFor(_backupGuardianDockModuleId) ??
        DockPosition.right;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 1280) {
      return const SizedBox.shrink();
    }

    final currentPath =
        widget.currentPath ??
        GoRouter.of(context).routeInformationProvider.value.uri.path;
    if (currentPath == RouteNames.backupGuardian) {
      return const SizedBox.shrink();
    }

    final snapshotAsync = ref.watch(backupGuardianSnapshotProvider);

    return snapshotAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (snapshot) {
        final healthAccent = _healthAccent(snapshot.healthState);
        final dockBody = _DockBody(
          snapshot: snapshot,
          healthAccent: healthAccent,
          position: _position,
          isBusy: _isBusy,
          onOpenFullView: () => context.go(RouteNames.backupGuardian),
          onVerifyNow: () => _runVerifyNow(snapshot),
          onRefresh: () => ref.invalidate(backupGuardianSnapshotProvider),
          onPositionSelected: _savePosition,
        );

        if (_position == DockPosition.floating) {
          return Positioned(
            left: 24,
            right: 24,
            bottom: 128,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Transform.translate(
                  offset: const Offset(0, -12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColours.darkSurfaceAlt.withValues(
                              alpha: 0.76,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColours.darkOutline.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: dockBody,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: _dockInsetsForPosition(_position),
            child: Align(
              alignment: _dockAlignmentForPosition(_position),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: dockBody,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _runVerifyNow(BackupGuardianSnapshot snapshot) async {
    if (_isBusy) {
      return;
    }

    setState(() => _isBusy = true);
    try {
      await ref
          .read(backupGuardianServiceProvider)
          .runAction(BackupGuardianAction.verifyLatest);
      ref.invalidate(backupGuardianSnapshotProvider);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _savePosition(DockPosition position) async {
    if (_position == position) {
      return;
    }

    setState(() {
      _position = position;
    });

    await ref
        .read(moduleHubStateRepositoryProvider)
        .saveDockPosition(_backupGuardianDockModuleId, position);
    ref
        .read(moduleEventBusProvider)
        .publish(
          ModuleEvent(
            moduleId: _backupGuardianDockModuleId,
            type: ModuleEventType.dockPositionChanged,
            timestamp: DateTime.now(),
            message: 'Backup Guardian dock position saved locally.',
            details: <String, dynamic>{'position': position.name},
          ),
        );
  }
}

class _DockBody extends StatelessWidget {
  const _DockBody({
    required this.snapshot,
    required this.healthAccent,
    required this.position,
    required this.isBusy,
    required this.onOpenFullView,
    required this.onVerifyNow,
    required this.onRefresh,
    required this.onPositionSelected,
  });

  final BackupGuardianSnapshot snapshot;
  final Color healthAccent;
  final DockPosition position;
  final bool isBusy;
  final VoidCallback onOpenFullView;
  final VoidCallback onVerifyNow;
  final VoidCallback onRefresh;
  final ValueChanged<DockPosition> onPositionSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColours.darkSurfaceAlt.withValues(alpha: 0.92),
      elevation: position == DockPosition.floating ? 28 : 10,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(22),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 320),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColours.darkOutline.withValues(alpha: 0.92),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.backup_outlined,
                      color: AppColours.darkPrimary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Backup Guardian Dock',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColours.darkText,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    _StatusPill(
                      label: snapshot.healthSummary,
                      accent: healthAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  snapshot.notificationBanner,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 10),
                _DockStatLine(
                  label: 'Latest status',
                  value: snapshot.latestBackupStatus,
                ),
                _DockStatLine(
                  label: 'Freshness',
                  value: snapshot.freshnessSummary,
                ),
                _DockStatLine(
                  label: 'Next run',
                  value: snapshot.nextSuggestedRun == null
                      ? 'Not scheduled yet'
                      : snapshot.nextSuggestedRun!.toLocal().toString(),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _DockPositionChipRow(
                      position: position,
                      onPositionSelected: onPositionSelected,
                    ),
                    FilledButton.tonalIcon(
                      onPressed: onOpenFullView,
                      icon: const Icon(Icons.open_in_full_rounded),
                      label: const Text('Open full view'),
                    ),
                    FilledButton.icon(
                      onPressed: isBusy ? null : onVerifyNow,
                      icon: isBusy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.verified_outlined),
                      label: const Text('Verify now'),
                    ),
                    TextButton.icon(
                      onPressed: onRefresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color _healthAccent(BackupGuardianHealthState state) {
  return switch (state) {
    BackupGuardianHealthState.green => AppColours.darkSuccess,
    BackupGuardianHealthState.amber => AppColours.darkAmber,
    BackupGuardianHealthState.red => AppColours.darkSecondary,
    BackupGuardianHealthState.grey => AppColours.darkPurple,
  };
}

Alignment _dockAlignmentForPosition(DockPosition position) {
  return switch (position) {
    DockPosition.left => Alignment.bottomLeft,
    DockPosition.right => Alignment.bottomRight,
    DockPosition.bottom => Alignment.bottomCenter,
    DockPosition.floating => Alignment.bottomCenter,
    DockPosition.fullscreen => Alignment.center,
  };
}

EdgeInsets _dockInsetsForPosition(DockPosition position) {
  return switch (position) {
    DockPosition.left => const EdgeInsets.fromLTRB(172, 20, 20, 20),
    DockPosition.right => const EdgeInsets.fromLTRB(20, 20, 172, 20),
    DockPosition.bottom => const EdgeInsets.fromLTRB(20, 20, 20, 20),
    DockPosition.floating => const EdgeInsets.fromLTRB(20, 20, 20, 20),
    DockPosition.fullscreen => const EdgeInsets.all(20),
  };
}

class _DockPositionChipRow extends StatelessWidget {
  const _DockPositionChipRow({
    required this.position,
    required this.onPositionSelected,
  });

  final DockPosition position;
  final ValueChanged<DockPosition> onPositionSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final candidate in DockPosition.values)
          ChoiceChip(
            label: Text(candidate.label),
            selected: position == candidate,
            onSelected: (_) => onPositionSelected(candidate),
          ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColours.darkText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DockStatLine extends StatelessWidget {
  const _DockStatLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkText,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
