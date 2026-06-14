import 'dart:async';
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
const _floatingHintDismissedKey = 'backupGuardianFloatingHintDismissed';

class BackupGuardianDockHost extends ConsumerStatefulWidget {
  const BackupGuardianDockHost({super.key, this.currentPath});

  final String? currentPath;

  @override
  ConsumerState<BackupGuardianDockHost> createState() =>
      _BackupGuardianDockHostState();
}

class _BackupGuardianDockHostState
    extends ConsumerState<BackupGuardianDockHost>
    with SingleTickerProviderStateMixin {
  bool _isBusy = false;
  bool _showFloatingHint = true;
  bool _hasDraggedFloating = false;
  late DockPosition _position;
  late DockAnchor _floatingAnchor;
  late final AnimationController _floatingBreatheController;

  @override
  void initState() {
    super.initState();
    final layoutState = ref.read(moduleHubStateRepositoryProvider).loadDockLayoutState();
    _position =
        layoutState.positionFor(_backupGuardianDockModuleId) ??
        DockPosition.right;
    _floatingAnchor =
        layoutState.floatingAnchorFor(_backupGuardianDockModuleId) ??
        DockAnchor.bottomRight;
    final hintDismissed = ref
        .read(moduleHubStateRepositoryProvider)
        .loadHubUiFlag(_floatingHintDismissedKey);
    _showFloatingHint = !hintDismissed;
    _hasDraggedFloating = hintDismissed;
    _floatingBreatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _syncFloatingAnimation();
  }

  @override
  void dispose() {
    _floatingBreatheController.dispose();
    super.dispose();
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
          floating: _position == DockPosition.floating,
          showFloatingHint: _showFloatingHint,
          onOpenFullView: () => context.go(RouteNames.backupGuardian),
          onVerifyNow: () => _runVerifyNow(snapshot),
          onRefresh: () => ref.invalidate(backupGuardianSnapshotProvider),
          onPositionSelected: _savePosition,
        );

        if (_position == DockPosition.floating) {
          return Positioned.fill(
            child: SafeArea(
              child: _FloatingDockFrame(
                anchor: _floatingAnchor,
                breathe: _floatingBreatheController,
                onDraggedOnce: _markFloatingDragged,
                onAnchorChanged: _saveFloatingAnchor,
                child: dockBody,
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

  void _syncFloatingAnimation() {
    if (_position == DockPosition.floating) {
      if (!_floatingBreatheController.isAnimating) {
        _floatingBreatheController.repeat(reverse: true);
      }
      return;
    }

    if (_floatingBreatheController.isAnimating) {
      _floatingBreatheController.stop();
    }
    _floatingBreatheController.value = 0;
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
    _syncFloatingAnimation();

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

  Future<void> _saveFloatingAnchor(DockAnchor anchor) async {
    if (_floatingAnchor == anchor) {
      return;
    }

    setState(() {
      _floatingAnchor = anchor;
    });

    final repository = ref.read(moduleHubStateRepositoryProvider);
    final current = repository.loadDockLayoutState();
    await repository.saveDockLayoutState(
      current.setFloatingAnchor(_backupGuardianDockModuleId, anchor),
    );
    ref
        .read(moduleEventBusProvider)
        .publish(
          ModuleEvent(
            moduleId: _backupGuardianDockModuleId,
            type: ModuleEventType.dockPositionChanged,
            timestamp: DateTime.now(),
            message: 'Backup Guardian floating anchor saved locally.',
            details: <String, dynamic>{'anchor': anchor.name},
          ),
        );
  }

  void _markFloatingDragged() {
    if (_hasDraggedFloating) {
      return;
    }

    setState(() {
      _hasDraggedFloating = true;
      _showFloatingHint = false;
    });

    unawaited(
      ref
          .read(moduleHubStateRepositoryProvider)
          .saveHubUiFlag(_floatingHintDismissedKey, true),
    );
  }
}

class _DockBody extends StatelessWidget {
  const _DockBody({
    required this.snapshot,
    required this.healthAccent,
    required this.position,
    required this.isBusy,
    required this.floating,
    required this.showFloatingHint,
    required this.onOpenFullView,
    required this.onVerifyNow,
    required this.onRefresh,
    required this.onPositionSelected,
  });

  final BackupGuardianSnapshot snapshot;
  final Color healthAccent;
  final DockPosition position;
  final bool isBusy;
  final bool floating;
  final bool showFloatingHint;
  final VoidCallback onOpenFullView;
  final VoidCallback onVerifyNow;
  final VoidCallback onRefresh;
  final ValueChanged<DockPosition> onPositionSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColours.darkSurfaceAlt.withValues(
        alpha: floating ? 0.84 : 0.92,
      ),
      elevation: floating ? 20 : 10,
      shadowColor: Colors.black.withValues(alpha: floating ? 0.38 : 0.3),
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
                    if (floating) ...[
                      const SizedBox(width: 8),
                      AnimatedOpacity(
                        opacity: showFloatingHint ? 1 : 0.18,
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOut,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColours.darkPrimary.withValues(
                              alpha: 0.14,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColours.darkPrimary.withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ),
                          child: Text(
                            'Drag to a corner',
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColours.darkText,
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                        ),
                      ),
                    ],
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

const _floatingDockMargin = 20.0;
const _floatingDockMinWidth = 320.0;
const _floatingDockMaxWidth = 400.0;
const _floatingDockEstimatedHeight = 372.0;

class _FloatingDockFrame extends StatefulWidget {
  const _FloatingDockFrame({
    required this.anchor,
    required this.breathe,
    required this.onDraggedOnce,
    required this.onAnchorChanged,
    required this.child,
  });

  final DockAnchor anchor;
  final AnimationController breathe;
  final VoidCallback onDraggedOnce;
  final Future<void> Function(DockAnchor anchor) onAnchorChanged;
  final Widget child;

  @override
  State<_FloatingDockFrame> createState() => _FloatingDockFrameState();
}

class _FloatingDockFrameState extends State<_FloatingDockFrame> {
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  bool _isHovered = false;

  @override
  void didUpdateWidget(covariant _FloatingDockFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.anchor != widget.anchor && !_isDragging) {
      _dragOffset = Offset.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final frameWidth = _resolveFloatingWidth(size.width);
        final frameHeight = _floatingDockEstimatedHeight.clamp(
          _floatingDockMinWidth,
          size.height - (_floatingDockMargin * 2),
        );
        final baseOffset = _baseOffsetForAnchor(
          widget.anchor,
          size,
          frameWidth,
          frameHeight.toDouble(),
        );
        final clampedOffset = (baseOffset + _dragOffset).clampToBounds(
          size,
          frameWidth,
          frameHeight.toDouble(),
        );

        return AnimatedBuilder(
          animation: widget.breathe,
          builder: (context, child) {
            final bob = _isDragging
                ? 0.0
                : (Curves.easeInOut.transform(widget.breathe.value) - 0.5) * 8;
            return Transform.translate(
              offset: Offset(0, bob),
              child: child,
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              MouseRegion(
                onEnter: (_) {
                  if (_isHovered) {
                    return;
                  }
                  setState(() {
                    _isHovered = true;
                  });
                },
                onExit: (_) {
                  if (!_isHovered) {
                    return;
                  }
                  setState(() {
                    _isHovered = false;
                  });
                },
                child: AnimatedPositioned(
                  duration: _isDragging
                      ? Duration.zero
                      : const Duration(milliseconds: 420),
                  curve: _isDragging ? Curves.linear : Curves.easeOutBack,
                  left: clampedOffset.dx,
                  top: clampedOffset.dy,
                  width: frameWidth,
                  child: AnimatedScale(
                    scale: _isDragging ? 1.03 : 1.0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _FloatingDragHandle(
                          onPanStart: _handlePanStart,
                          onPanUpdate: _handlePanUpdate,
                          onPanEnd: (_) => _handlePanEnd(
                            size: size,
                            frameWidth: frameWidth,
                            frameHeight: frameHeight.toDouble(),
                          ),
                        ),
                        _FloatingFrameShell(
                          isHovered: _isHovered,
                          isDragging: _isDragging,
                          child: widget.child,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _resolveFloatingWidth(double maxWidth) {
    final available = maxWidth - (_floatingDockMargin * 2);
    if (available < _floatingDockMinWidth) {
      return _floatingDockMinWidth;
    }
    return available.clamp(_floatingDockMinWidth, _floatingDockMaxWidth).toDouble();
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _isHovered = true;
    });
    if (widget.breathe.isAnimating) {
      widget.breathe.stop();
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta * 0.9;
    });
  }

  Future<void> _handlePanEnd({
    required Size size,
    required double frameWidth,
    required double frameHeight,
  }) async {
    final currentOffset = (_baseOffsetForAnchor(
          widget.anchor,
          size,
          frameWidth,
          frameHeight,
        ) +
        _dragOffset).clampToBounds(size, frameWidth, frameHeight);

    final snappedAnchor = _nearestAnchorFor(
      currentOffset: currentOffset,
      size: size,
      frameWidth: frameWidth,
      frameHeight: frameHeight,
    );

    final snappedOffset = _baseOffsetForAnchor(
      snappedAnchor,
      size,
      frameWidth,
      frameHeight,
    );

    setState(() {
      _dragOffset = snappedOffset - _baseOffsetForAnchor(
        widget.anchor,
        size,
        frameWidth,
        frameHeight,
      );
      _isDragging = false;
    });

    if (!widget.breathe.isAnimating) {
      widget.breathe.repeat(reverse: true);
    }

    widget.onDraggedOnce();
    unawaited(widget.onAnchorChanged(snappedAnchor));
  }
}

class _FloatingFrameShell extends StatelessWidget {
  const _FloatingFrameShell({
    required this.child,
    required this.isHovered,
    required this.isDragging,
  });

  final Widget child;
  final bool isHovered;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColours.darkSurfaceAlt.withValues(alpha: 0.92),
                AppColours.darkSurfaceAlt.withValues(alpha: 0.76),
              ],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColours.darkOutline.withValues(alpha: 0.72),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColours.darkPrimary.withValues(
                  alpha: isHovered || isDragging ? 0.16 : 0.06,
                ),
                blurRadius: isHovered || isDragging ? 64 : 34,
                offset: const Offset(0, 0),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDragging ? 0.42 : 0.34),
                blurRadius: isDragging ? 54 : 42,
                offset: Offset(0, isDragging ? 26 : 18),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _FloatingDragHandle extends StatelessWidget {
  const _FloatingDragHandle({
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 58,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColours.darkPrimary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Drag',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColours.darkPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

Offset _baseOffsetForAnchor(
  DockAnchor anchor,
  Size size,
  double frameWidth,
  double frameHeight,
) {
  final maxX = (size.width - frameWidth - _floatingDockMargin)
      .clamp(_floatingDockMargin, double.infinity)
      .toDouble();
  final maxY = (size.height - frameHeight - _floatingDockMargin)
      .clamp(_floatingDockMargin, double.infinity)
      .toDouble();

  return switch (anchor) {
    DockAnchor.topLeft => const Offset(_floatingDockMargin, _floatingDockMargin),
    DockAnchor.topRight => Offset(maxX, _floatingDockMargin),
    DockAnchor.bottomLeft => Offset(_floatingDockMargin, maxY),
    DockAnchor.bottomRight => Offset(maxX, maxY),
  };
}

DockAnchor _nearestAnchorFor({
  required Offset currentOffset,
  required Size size,
  required double frameWidth,
  required double frameHeight,
}) {
  final candidates = <DockAnchor, Offset>{
    DockAnchor.topLeft: _baseOffsetForAnchor(
      DockAnchor.topLeft,
      size,
      frameWidth,
      frameHeight,
    ),
    DockAnchor.topRight: _baseOffsetForAnchor(
      DockAnchor.topRight,
      size,
      frameWidth,
      frameHeight,
    ),
    DockAnchor.bottomLeft: _baseOffsetForAnchor(
      DockAnchor.bottomLeft,
      size,
      frameWidth,
      frameHeight,
    ),
    DockAnchor.bottomRight: _baseOffsetForAnchor(
      DockAnchor.bottomRight,
      size,
      frameWidth,
      frameHeight,
    ),
  };

  var closest = DockAnchor.bottomRight;
  var closestDistance = double.infinity;
  for (final entry in candidates.entries) {
    final dx = currentOffset.dx - entry.value.dx;
    final dy = currentOffset.dy - entry.value.dy;
    final distance = dx * dx + dy * dy;
    if (distance < closestDistance) {
      closestDistance = distance;
      closest = entry.key;
    }
  }
  return closest;
}

extension on Offset {
  Offset clampToBounds(
    Size size,
    double frameWidth,
    double frameHeight,
  ) {
    final minX = _floatingDockMargin;
    final minY = _floatingDockMargin;
    final maxX = (size.width - frameWidth - _floatingDockMargin)
        .clamp(minX, double.infinity)
        .toDouble();
    final maxY = (size.height - frameHeight - _floatingDockMargin)
        .clamp(minY, double.infinity)
        .toDouble();

    return Offset(
      dx.clamp(minX, maxX).toDouble(),
      dy.clamp(minY, maxY).toDouble(),
    );
  }
}
