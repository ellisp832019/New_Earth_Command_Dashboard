import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/dock/dock_position.dart';
import '../../../core/modules/module_event_bus.dart';
import '../../modules/application/module_hub_controller.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../data/knowledge_library_repository.dart';

const _knowledgeLibraryDockModuleId = 'knowledge_library_dock';

class KnowledgeLibraryDockHost extends ConsumerStatefulWidget {
  const KnowledgeLibraryDockHost({super.key, this.currentPath});

  final String? currentPath;

  @override
  ConsumerState<KnowledgeLibraryDockHost> createState() =>
      _KnowledgeLibraryDockHostState();
}

class _KnowledgeLibraryDockHostState
    extends ConsumerState<KnowledgeLibraryDockHost>
    with SingleTickerProviderStateMixin {
  late final KnowledgeLibraryRepository _repository;
  late DockPosition _position;
  late DockAnchor _floatingAnchor;
  late final AnimationController _floatingBreatheController;
  late Future<_KnowledgeLibraryDockSnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _repository = KnowledgeLibraryRepository();
    final layoutState = ref.read(moduleHubStateRepositoryProvider).loadDockLayoutState();
    _position =
        layoutState.positionFor(_knowledgeLibraryDockModuleId) ?? DockPosition.right;
    _floatingAnchor =
        layoutState.floatingAnchorFor(_knowledgeLibraryDockModuleId) ??
        DockAnchor.bottomRight;
    _floatingBreatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _snapshotFuture = _loadSnapshot();
    _syncFloatingAnimation();
  }

  @override
  void dispose() {
    _repository.dispose();
    _floatingBreatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 1280) {
      return const SizedBox.shrink();
    }

    final currentPath = widget.currentPath ?? '';
    if (currentPath == RouteNames.dashboard ||
        currentPath == RouteNames.knowledgeLibrary) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<_KnowledgeLibraryDockSnapshot>(
      future: _snapshotFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final accent = data.health.isHealthy
            ? AppColours.darkSuccess
            : AppColours.darkAmber;
        final body = _KnowledgeLibraryDockBody(
          snapshot: data,
          accent: accent,
          position: _position,
          floating: _position == DockPosition.floating,
          onOpenLibrary: () => context.go(RouteNames.knowledgeLibrary),
          onOpenRepoResearch: () => context.push(RouteNames.repoResearchEngine),
          onRefresh: _refresh,
          onPositionSelected: _savePosition,
          onOpenFailureReport: data.extractionStatus.reportPath.isEmpty
              ? null
              : () async {
                  await _repository.openFailureReport(
                    data.extractionStatus.reportPath,
                  );
                },
        );

        if (_position == DockPosition.floating) {
          return Positioned.fill(
            child: SafeArea(
              child: _FloatingDockFrame(
                anchor: _floatingAnchor,
                breathe: _floatingBreatheController,
                onDraggedOnce: _markFloatingDragged,
                onAnchorChanged: _saveFloatingAnchor,
                child: body,
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
                constraints: const BoxConstraints(maxWidth: 380),
                child: body,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<_KnowledgeLibraryDockSnapshot> _loadSnapshot() async {
    final results = await Future.wait([
      _repository.loadHealth(),
      _repository.loadStats(),
      _repository.loadExtractionStatus(),
    ]);

    return _KnowledgeLibraryDockSnapshot(
      health: results[0] as KnowledgeLibraryHealth,
      stats: results[1] as KnowledgeLibraryStats,
      extractionStatus: results[2] as KnowledgeLibraryExtractionStatus,
    );
  }

  void _refresh() {
    setState(() {
      _snapshotFuture = _loadSnapshot();
    });
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
        .saveDockPosition(_knowledgeLibraryDockModuleId, position);
    ref.read(moduleEventBusProvider).publish(
          ModuleEvent(
            moduleId: _knowledgeLibraryDockModuleId,
            type: ModuleEventType.dockPositionChanged,
            timestamp: DateTime.now(),
            message: 'Knowledge Library dock position saved locally.',
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
      current.setFloatingAnchor(_knowledgeLibraryDockModuleId, anchor),
    );
    ref.read(moduleEventBusProvider).publish(
          ModuleEvent(
            moduleId: _knowledgeLibraryDockModuleId,
            type: ModuleEventType.dockPositionChanged,
            timestamp: DateTime.now(),
            message: 'Knowledge Library floating anchor saved locally.',
            details: <String, dynamic>{'anchor': anchor.name},
          ),
        );
  }

  void _markFloatingDragged() {
    if (_position != DockPosition.floating) {
      return;
    }
    if (!_floatingBreatheController.isAnimating) {
      _floatingBreatheController.repeat(reverse: true);
    }
  }
}

class _KnowledgeLibraryDockSnapshot {
  const _KnowledgeLibraryDockSnapshot({
    required this.health,
    required this.stats,
    required this.extractionStatus,
  });

  final KnowledgeLibraryHealth health;
  final KnowledgeLibraryStats stats;
  final KnowledgeLibraryExtractionStatus extractionStatus;
}

class _KnowledgeLibraryDockBody extends StatelessWidget {
  const _KnowledgeLibraryDockBody({
    required this.snapshot,
    required this.accent,
    required this.position,
    required this.floating,
    required this.onOpenLibrary,
    required this.onOpenRepoResearch,
    required this.onRefresh,
    required this.onPositionSelected,
    required this.onOpenFailureReport,
  });

  final _KnowledgeLibraryDockSnapshot snapshot;
  final Color accent;
  final DockPosition position;
  final bool floating;
  final VoidCallback onOpenLibrary;
  final VoidCallback onOpenRepoResearch;
  final VoidCallback onRefresh;
  final ValueChanged<DockPosition> onPositionSelected;
  final VoidCallback? onOpenFailureReport;

  @override
  Widget build(BuildContext context) {
    final stats = snapshot.stats;
    final extraction = snapshot.extractionStatus;
    final statusLabel = snapshot.health.isHealthy ? 'Ready' : 'Needs attention';
    final statusDetail = snapshot.health.message.isEmpty
        ? 'Live knowledge catalogue snapshot'
        : snapshot.health.message;

    return Material(
      color: AppColours.darkSurfaceAlt.withValues(alpha: floating ? 0.86 : 0.93),
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
                      Icon(Icons.library_books_outlined, color: accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Knowledge Library Dock',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColours.darkText,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      _StatusPill(label: statusLabel, accent: accent),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    statusDetail,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColours.darkMutedText,
                          height: 1.35,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _DockStatLine(label: 'PDFs', value: '${stats.totalPdfs}'),
                  _DockStatLine(label: 'Text extractable', value: '${stats.textExtractable}'),
                  _DockStatLine(label: 'OCR needed', value: '${stats.ocrRequired}'),
                  _DockStatLine(label: 'Audio generated', value: '${stats.audioGenerated}'),
                  _DockStatLine(
                    label: 'Extraction',
                    value:
                        '${extraction.extracted} extracted, ${extraction.failed} failed, ${extraction.pending} pending',
                  ),
                  if (extraction.lastRunAt != null)
                    _DockStatLine(
                      label: 'Last run',
                      value: extraction.lastRunAt!.toLocal().toString(),
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
                        onPressed: onOpenLibrary,
                        icon: const Icon(Icons.menu_book_outlined),
                        label: const Text('Open Library'),
                      ),
                      FilledButton.icon(
                        onPressed: onOpenRepoResearch,
                        icon: const Icon(Icons.travel_explore_outlined),
                        label: const Text('Repo Research'),
                      ),
                      TextButton.icon(
                        onPressed: onRefresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                  if (onOpenFailureReport != null) ...[
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: onOpenFailureReport,
                      icon: const Icon(Icons.description_outlined),
                      label: const Text('Open failure report'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
    DockPosition.left => const EdgeInsets.fromLTRB(20, 20, 180, 20),
    DockPosition.right => const EdgeInsets.fromLTRB(180, 20, 20, 20),
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
const _floatingDockEstimatedHeight = 360.0;

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
              AnimatedPositioned(
                duration:
                    _isDragging ? Duration.zero : const Duration(milliseconds: 420),
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
