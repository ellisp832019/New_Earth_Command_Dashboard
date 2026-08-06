import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/dock/dock_lane_hints.dart';
import '../../../core/dock/dock_position.dart';
import '../../../core/modules/module_event_bus.dart';
import '../../modules/application/module_hub_controller.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/treasury_controller.dart';
import '../data/treasury_folder_service.dart';
import '../data/treasury_wizard_flow.dart';

const _treasuryDockModuleId = 'treasury_dock';

class TreasuryDockHost extends ConsumerStatefulWidget {
  const TreasuryDockHost({super.key, this.currentPath});

  final String? currentPath;

  @override
  ConsumerState<TreasuryDockHost> createState() => _TreasuryDockHostState();
}

class _TreasuryDockHostState extends ConsumerState<TreasuryDockHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatingBreatheController;

  @override
  void initState() {
    super.initState();
    _floatingBreatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    final layoutState = ref.read(dockLayoutStateProvider);
    final initialPosition =
        layoutState.positionFor(_treasuryDockModuleId) ?? DockPosition.left;
    _syncFloatingAnimationFor(initialPosition);
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

    final layoutState = ref.watch(dockLayoutStateProvider);
    final position =
        layoutState.positionFor(_treasuryDockModuleId) ?? DockPosition.left;
    final floatingAnchor =
        layoutState.floatingAnchorFor(_treasuryDockModuleId) ??
        DockAnchor.bottomLeft;

    final currentPath = widget.currentPath ?? '';
    if (currentPath == RouteNames.treasury ||
        currentPath.startsWith('${RouteNames.treasury}/')) {
      return const SizedBox.shrink();
    }

    final snapshotAsync = ref.watch(treasuryWorkspaceProvider);

    return snapshotAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (snapshot) {
        final accent = snapshot.isReady
            ? AppColours.darkSuccess
            : AppColours.darkAmber;
        final stateCounts = {
          for (final summary in snapshot.stateSummaries)
            summary.kind: summary.count,
        };
        final body = _TreasuryDockBody(
          snapshot: snapshot,
          accent: accent,
          stateCounts: stateCounts,
          position: position,
          floating: position == DockPosition.floating,
          onOpenTreasury: () => context.go(RouteNames.treasury),
          onOpenWeeklyRitual: () => context.push(
            RouteNames.treasuryWizardFor(
              TreasuryWizardFlow.weeklyRitual.routeValue,
            ),
          ),
          onOpenMonthlySummary: () =>
              context.push(RouteNames.treasuryMonthlySummary),
          onOpenSettings: () => context.push(RouteNames.treasurySettings),
          onRefresh: () => ref.invalidate(treasuryWorkspaceProvider),
          onPositionSelected: _savePosition,
          onOpenDecisionReview: () =>
              context.push(RouteNames.treasuryDecisions),
        );

        if (position == DockPosition.floating) {
          return Positioned.fill(
            child: SafeArea(
              child: _FloatingDockFrame(
                anchor: floatingAnchor,
                breathe: _floatingBreatheController,
                accentColor: accent,
                onDraggedOnce: _markFloatingDragged,
                onAnchorChanged: _saveFloatingAnchor,
                child: body,
              ),
            ),
          );
        }

        return switch (position) {
          DockPosition.left => Positioned(
            left: 20,
            bottom: 20,
            child: SafeArea(child: SizedBox(width: 380, child: body)),
          ),
          DockPosition.right => Positioned(
            right: 20,
            bottom: 20,
            child: SafeArea(child: SizedBox(width: 380, child: body)),
          ),
          DockPosition.bottom => Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SafeArea(
              child: Center(child: SizedBox(width: 380, child: body)),
            ),
          ),
          DockPosition.fullscreen => Positioned.fill(
            child: SafeArea(
              child: Padding(padding: const EdgeInsets.all(20), child: body),
            ),
          ),
          DockPosition.floating => const SizedBox.shrink(),
        };
      },
    );
  }

  void _syncFloatingAnimationFor(DockPosition position) {
    if (position == DockPosition.floating) {
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

  Future<void> _savePosition(DockPosition position) async {
    await ref
        .read(dockLayoutStateProvider.notifier)
        .setPosition(_treasuryDockModuleId, position);
    _syncFloatingAnimationFor(position);
    ref
        .read(moduleEventBusProvider)
        .publish(
          ModuleEvent(
            moduleId: _treasuryDockModuleId,
            type: ModuleEventType.dockPositionChanged,
            timestamp: DateTime.now(),
            message: 'Treasury dock position saved locally.',
            details: <String, dynamic>{'position': position.name},
          ),
        );
  }

  Future<void> _saveFloatingAnchor(DockAnchor anchor) async {
    await ref
        .read(dockLayoutStateProvider.notifier)
        .setFloatingAnchor(_treasuryDockModuleId, anchor);
    ref
        .read(moduleEventBusProvider)
        .publish(
          ModuleEvent(
            moduleId: _treasuryDockModuleId,
            type: ModuleEventType.dockPositionChanged,
            timestamp: DateTime.now(),
            message: 'Treasury floating anchor saved locally.',
            details: <String, dynamic>{'anchor': anchor.name},
          ),
        );
  }

  void _markFloatingDragged() {
    final position =
        ref.read(dockLayoutStateProvider).positionFor(_treasuryDockModuleId) ??
        DockPosition.left;
    if (position != DockPosition.floating) {
      return;
    }
    if (!_floatingBreatheController.isAnimating) {
      _floatingBreatheController.repeat(reverse: true);
    }
  }
}

class _TreasuryDockBody extends StatelessWidget {
  const _TreasuryDockBody({
    required this.snapshot,
    required this.accent,
    required this.stateCounts,
    required this.position,
    required this.floating,
    required this.onOpenTreasury,
    required this.onOpenWeeklyRitual,
    required this.onOpenMonthlySummary,
    required this.onOpenSettings,
    required this.onRefresh,
    required this.onPositionSelected,
    required this.onOpenDecisionReview,
  });

  final TreasuryWorkspaceSnapshot snapshot;
  final Color accent;
  final Map<TreasuryStatusKind, int> stateCounts;
  final DockPosition position;
  final bool floating;
  final VoidCallback onOpenTreasury;
  final VoidCallback onOpenWeeklyRitual;
  final VoidCallback onOpenMonthlySummary;
  final VoidCallback onOpenSettings;
  final VoidCallback onRefresh;
  final ValueChanged<DockPosition> onPositionSelected;
  final VoidCallback onOpenDecisionReview;

  @override
  Widget build(BuildContext context) {
    final issueLabel = snapshot.issues.isEmpty
        ? 'No blockers'
        : '${snapshot.issues.length} issue${snapshot.issues.length == 1 ? '' : 's'}';

    return Material(
      color: AppColours.darkSurfaceAlt.withValues(
        alpha: floating ? 0.86 : 0.93,
      ),
      elevation: floating ? 22 : 11,
      shadowColor: Colors.black.withValues(alpha: floating ? 0.38 : 0.3),
      borderRadius: BorderRadius.circular(22),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 340),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColours.darkOutline.withValues(alpha: 0.92),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: accent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Treasury Dock',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AppColours.darkText,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      _StatusPill(
                        label: snapshot.isReady ? 'Ready' : 'Setup needed',
                        accent: accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.guidanceNote,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColours.darkMutedText,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DockStatLine(
                    label: 'Finance root',
                    value: snapshot.financeRootPath ?? 'Not linked yet',
                  ),
                  _DockStatLine(
                    label: 'Receipts to sort',
                    value: '${snapshot.receiptsToSortCount}',
                  ),
                  _DockStatLine(label: 'Health', value: issueLabel),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusPill(
                        label:
                            'Safe ${stateCounts[TreasuryStatusKind.safe] ?? 0}',
                        accent: AppColours.darkSuccess,
                      ),
                      _StatusPill(
                        label:
                            'Watch ${stateCounts[TreasuryStatusKind.watch] ?? 0}',
                        accent: AppColours.darkAmber,
                      ),
                      _StatusPill(
                        label:
                            'Pause ${stateCounts[TreasuryStatusKind.pause] ?? 0}',
                        accent: const Color(0xFFE26B6B),
                      ),
                      _StatusPill(
                        label:
                            'Decision ${stateCounts[TreasuryStatusKind.decision] ?? 0}',
                        accent: AppColours.darkSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: () => context.go(RouteNames.more),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back to More'),
                      ),
                      _DockPositionChipRow(
                        position: position,
                        onPositionSelected: onPositionSelected,
                      ),
                      FilledButton.tonalIcon(
                        onPressed: onOpenTreasury,
                        icon: const Icon(Icons.open_in_new_outlined),
                        label: const Text('Open Treasury'),
                      ),
                      FilledButton.icon(
                        onPressed: onOpenWeeklyRitual,
                        icon: const Icon(Icons.view_agenda_outlined),
                        label: const Text('Weekly ritual'),
                      ),
                      TextButton.icon(
                        onPressed: onRefresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: onOpenMonthlySummary,
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: const Text('Monthly summary'),
                      ),
                      TextButton.icon(
                        onPressed: onOpenDecisionReview,
                        icon: const Icon(Icons.gavel_outlined),
                        label: const Text('Decisions'),
                      ),
                      TextButton.icon(
                        onPressed: onOpenSettings,
                        icon: const Icon(Icons.settings_outlined),
                        label: const Text('Settings'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
const _floatingDockEstimatedHeight = 360.0;

class _FloatingDockFrame extends StatefulWidget {
  const _FloatingDockFrame({
    required this.anchor,
    required this.breathe,
    required this.accentColor,
    required this.onDraggedOnce,
    required this.onAnchorChanged,
    required this.child,
  });

  final DockAnchor anchor;
  final AnimationController breathe;
  final Color accentColor;
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
            return Transform.translate(offset: Offset(0, bob), child: child);
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              DockLaneHintsOverlay(
                intensity: _isDragging ? 0.7 : (_isHovered ? 0.28 : 0.0),
                accentColor: widget.accentColor,
              ),
              AnimatedPositioned(
                duration: _isDragging
                    ? Duration.zero
                    : const Duration(milliseconds: 420),
                curve: _isDragging ? Curves.linear : Curves.easeOutBack,
                left: clampedOffset.dx,
                top: clampedOffset.dy,
                width: frameWidth,
                child: MouseRegion(
                  onEnter: (_) {
                    if (_isHovered) {
                      return;
                    }
                    setState(() => _isHovered = true);
                  },
                  onExit: (_) {
                    if (!_isHovered) {
                      return;
                    }
                    setState(() => _isHovered = false);
                  },
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
    return available
        .clamp(_floatingDockMinWidth, _floatingDockMaxWidth)
        .toDouble();
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
    final currentOffset =
        (_baseOffsetForAnchor(widget.anchor, size, frameWidth, frameHeight) +
                _dragOffset)
            .clampToBounds(size, frameWidth, frameHeight);

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
      _dragOffset =
          snappedOffset -
          _baseOffsetForAnchor(widget.anchor, size, frameWidth, frameHeight);
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
                color: AppColours.darkSecondary.withValues(
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
          child: Padding(padding: const EdgeInsets.all(2), child: child),
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
                  color: AppColours.darkSecondary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Drag',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColours.darkSecondary,
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
  final midY = ((size.height - frameHeight) / 2)
      .clamp(_floatingDockMargin, maxY)
      .toDouble();

  return switch (anchor) {
    DockAnchor.topLeft => const Offset(
      _floatingDockMargin,
      _floatingDockMargin,
    ),
    DockAnchor.topRight => Offset(maxX, _floatingDockMargin),
    DockAnchor.middleLeft => Offset(_floatingDockMargin, midY),
    DockAnchor.middleRight => Offset(maxX, midY),
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
    DockAnchor.middleLeft: _baseOffsetForAnchor(
      DockAnchor.middleLeft,
      size,
      frameWidth,
      frameHeight,
    ),
    DockAnchor.middleRight: _baseOffsetForAnchor(
      DockAnchor.middleRight,
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

  var closest = DockAnchor.bottomLeft;
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
  Offset clampToBounds(Size size, double frameWidth, double frameHeight) {
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
