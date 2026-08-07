import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/app_database.dart';
import 'core/routing/app_router.dart';
import 'core/routing/security_route_policy.dart';
import 'core/routing/route_names.dart';
import 'core/theme/app_theme.dart';
import 'features/security/application/security_session_controller.dart';
import 'features/settings/application/settings_controller.dart';
import 'features/meeting_system/presentation/meeting_notification_bridge.dart';
import 'features/knowledge_library/presentation/knowledge_library_dock_host.dart';
import 'features/treasury/presentation/treasury_dock_host.dart';
import 'features/system_backup/presentation/backup_guardian_dock_host.dart';
import 'features/security/presentation/security_session_activity_tracker.dart';
import 'features/voice_intelligence/presentation/voice_startup_status_chip.dart';
import 'features/voice_assistant/widgets/voice_conversation_dock.dart';
import 'features/voice_assistant/widgets/voice_handsfree_layer.dart';
import 'features/voice_assistant/widgets/voice_presence_chip.dart';
import 'core/windowing/desktop_presence_controller.dart';

class OpenCommandPaletteIntent extends Intent {
  const OpenCommandPaletteIntent();
}

class CloseCommandPaletteIntent extends Intent {
  const CloseCommandPaletteIntent();
}

class SleepToTrayIntent extends Intent {
  const SleepToTrayIntent();
}

class WakeDashboardIntent extends Intent {
  const WakeDashboardIntent();
}

class LockNowIntent extends Intent {
  const LockNowIntent();
}

class NewEarthCommandDashboardApp extends ConsumerWidget {
  const NewEarthCommandDashboardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(databaseReadyProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final settingsSnapshot = ref.watch(settingsSnapshotProvider);
    final securitySession = ref.watch(securitySessionProvider);
    final appSettings = settingsSnapshot.maybeWhen(
      data: (snapshot) => snapshot.settings,
      orElse: () => null,
    );

    ref.listen<SecuritySessionState>(securitySessionProvider, (previous, next) {
      final wasUnlocked = previous?.isUnlocked ?? false;
      if (wasUnlocked && !next.isUnlocked) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final currentUri = appRouter.routeInformationProvider.value.uri;
          if (currentUri.path != RouteNames.securityLock) {
            appRouter.go(SecurityRoutePolicy.securityLockFrom(currentUri));
          }
        });
      }
    });

    return MeetingNotificationBridge(
      child: MaterialApp.router(
        title: 'Gaia',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        routerConfig: appRouter,
        builder: (context, child) {
          final routedChild = Shortcuts(
            shortcuts: const {
              SingleActivator(LogicalKeyboardKey.keyK, control: true):
                  OpenCommandPaletteIntent(),
              SingleActivator(
                LogicalKeyboardKey.keyS,
                control: true,
                shift: true,
              ): SleepToTrayIntent(),
              SingleActivator(
                LogicalKeyboardKey.keyW,
                control: true,
                alt: true,
              ): WakeDashboardIntent(),
              SingleActivator(
                LogicalKeyboardKey.keyL,
                control: true,
                shift: true,
              ): LockNowIntent(),
              SingleActivator(LogicalKeyboardKey.escape):
                  CloseCommandPaletteIntent(),
            },
            child: Actions(
              actions: {
                OpenCommandPaletteIntent:
                    CallbackAction<OpenCommandPaletteIntent>(
                      onInvoke: (intent) {
                        appRouter.go(RouteNames.commandPalette);
                        return null;
                      },
                    ),
                CloseCommandPaletteIntent:
                    CallbackAction<CloseCommandPaletteIntent>(
                      onInvoke: (intent) {
                        if (appRouter.canPop()) {
                          appRouter.pop();
                        }
                        return null;
                      },
                    ),
                SleepToTrayIntent: CallbackAction<SleepToTrayIntent>(
                  onInvoke: (intent) {
                    unawaited(DesktopPresenceController.instance.sleep());
                    return null;
                  },
                ),
                WakeDashboardIntent: CallbackAction<WakeDashboardIntent>(
                  onInvoke: (intent) {
                    unawaited(
                      DesktopPresenceController.instance.openDashboard(),
                    );
                    return null;
                  },
                ),
                LockNowIntent: CallbackAction<LockNowIntent>(
                  onInvoke: (intent) {
                    ref.read(securitySessionProvider.notifier).lockNow();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final currentUri =
                          appRouter.routeInformationProvider.value.uri;
                      if (currentUri.path != RouteNames.securityLock) {
                        appRouter.go(
                          SecurityRoutePolicy.securityLockFrom(currentUri),
                        );
                      }
                    });
                    return null;
                  },
                ),
              },
              child: child ?? const SizedBox.shrink(),
            ),
          );

          return Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              SecuritySessionActivityTracker(
                child: VoiceHandsfreeLayer(child: routedChild),
              ),
              ValueListenableBuilder<RouteInformation>(
                valueListenable: appRouter.routeInformationProvider,
                builder: (context, routeInfo, _) {
                  final showDockOverlays =
                      appSettings?.showDockOverlays ?? false;
                  final showBackupGuardianDock =
                      appSettings?.showBackupGuardianDock ?? false;
                  final showTreasuryDock =
                      appSettings?.showTreasuryDock ?? false;
                  final showKnowledgeLibraryDock =
                      appSettings?.showKnowledgeLibraryDock ?? false;

                  return Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: [
                      if (showDockOverlays && showBackupGuardianDock)
                        BackupGuardianDockHost(currentPath: routeInfo.uri.path),
                      if (showDockOverlays && showTreasuryDock)
                        TreasuryDockHost(currentPath: routeInfo.uri.path),
                      if (showDockOverlays && showKnowledgeLibraryDock)
                        KnowledgeLibraryDockHost(
                          currentPath: routeInfo.uri.path,
                        ),
                    ],
                  );
                },
              ),
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: _TopRightStatusCluster(
                    session: securitySession,
                    showVoicePresence:
                        (appSettings?.showDockOverlays ?? false) &&
                        (appSettings?.showVoicePresenceChip ?? false),
                  ),
                ),
              ),
              Positioned(
                top: 126,
                right: 16,
                child: SafeArea(child: VoiceStartupStatusChip(compact: true)),
              ),
              if ((appSettings?.showDockOverlays ?? false) &&
                  (appSettings?.showVoiceConversationDock ?? false) &&
                  (appSettings?.voiceAssistantEnabled ?? false))
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: SafeArea(child: VoiceConversationDock()),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SecuritySessionPill extends StatefulWidget {
  const _SecuritySessionPill({required this.session});

  final SecuritySessionState session;

  @override
  State<_SecuritySessionPill> createState() => _SecuritySessionPillState();
}

class _SecuritySessionPillState extends State<_SecuritySessionPill> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant _SecuritySessionPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.isUnlocked != widget.session.isUnlocked ||
        oldWidget.session.expiresAt != widget.session.expiresAt ||
        oldWidget.session.lastActivityAt != widget.session.lastActivityAt) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return '0s';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }

    if (minutes > 0) {
      return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
    }

    return '${seconds}s';
  }

  void _openSecurityLock() {
    final currentUri = appRouter.routeInformationProvider.value.uri;
    appRouter.go(SecurityRoutePolicy.securityLockFrom(currentUri));
  }

  void _openAccessMatrix() {
    if (!widget.session.isUnlocked || widget.session.isExpired) {
      _openSecurityLock();
      return;
    }

    appRouter.go(RouteNames.usersDevicesAccessMatrix);
  }

  Color _accentColor(SecuritySessionState session) {
    if (!session.isUnlocked || session.isExpired) {
      return const Color(0xFF6B7780);
    }

    final remaining = session.remaining;
    if (remaining == null) {
      return const Color(0xFF7ACB9A);
    }

    if (remaining <= const Duration(seconds: 30)) {
      return const Color(0xFFFF6B5E);
    }

    if (remaining <= const Duration(minutes: 2)) {
      return const Color(0xFFFFC857);
    }

    return const Color(0xFF7ACB9A);
  }

  String _activeUserLabel(SecuritySessionState session) {
    final label = session.activeUserLabel;
    if (label == null || label.isEmpty) {
      return 'No active user';
    }

    return label;
  }

  String? _activeDeviceLabel(SecuritySessionState session) {
    final label = session.activeDeviceLabel;
    if (label == null || label.isEmpty) {
      return null;
    }

    return label;
  }

  String _presenceLabel(SecuritySessionState session) {
    final label = session.activeUserLabel;
    if (label == null || label.isEmpty) {
      return 'Offline';
    }

    return session.activeUserOnline ? 'Online' : 'Offline';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = widget.session;
    final isUnlocked = session.isUnlocked && !session.isExpired;
    final connectedAt = session.lastActivityAt;
    final durationSinceConnect = connectedAt == null
        ? null
        : DateTime.now().difference(connectedAt);
    final remaining = session.remaining;
    final accentColor = _accentColor(session);
    final activeUserLabel = _activeUserLabel(session);
    final activeDeviceLabel = _activeDeviceLabel(session);
    final presenceLabel = _presenceLabel(session);
    final remainingFraction =
        session.timeout.inMilliseconds <= 0 || remaining == null
        ? 0.0
        : remaining.inMilliseconds / session.timeout.inMilliseconds;
    final clampedFraction = remainingFraction.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 260;
        final contentSpacing = isCompact ? 6.0 : 8.0;
        final labelSpacing = isCompact ? 6.0 : 8.0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _openSecurityLock,
            child: Ink(
              decoration: BoxDecoration(
                color: const Color(0xFF0B1418).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: accentColor.withValues(alpha: 0.55)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 10 : 12,
                  vertical: isCompact ? 8 : 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isUnlocked ? Icons.lock_open : Icons.lock,
                          size: isCompact ? 13 : 15,
                          color: accentColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Security session',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  Chip(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    label: Text(
                                      isUnlocked ? 'Active' : 'Locked',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    labelPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    side: BorderSide(
                                      color: accentColor.withValues(
                                        alpha: 0.45,
                                      ),
                                    ),
                                    backgroundColor: accentColor.withValues(
                                      alpha: 0.12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activeUserLabel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFFE4E8EA),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                presenceLabel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: session.activeUserOnline
                                      ? const Color(0xFFBFE9CF)
                                      : const Color(0xFFFFC857),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: contentSpacing),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: isCompact ? 5 : 6,
                        value: isUnlocked ? clampedFraction : 0,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      ),
                    ),
                    SizedBox(height: labelSpacing),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        if (activeDeviceLabel != null)
                          _SessionLabel(label: activeDeviceLabel),
                        _SessionLabel(
                          label: durationSinceConnect == null
                              ? 'Live -'
                              : 'Live ${_formatDuration(durationSinceConnect)}',
                        ),
                        _SessionLabel(
                          label: 'Timeout ${_formatDuration(session.timeout)}',
                        ),
                        _SessionLabel(
                          label: remaining == null
                              ? 'Expires: -'
                              : 'Expires in ${_formatDuration(remaining)}',
                          accent: accentColor,
                        ),
                      ],
                    ),
                    SizedBox(height: labelSpacing),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniSessionAction(
                          label: 'Open lock',
                          icon: Icons.lock_outline,
                          onPressed: _openSecurityLock,
                        ),
                        _MiniSessionAction(
                          label: isUnlocked ? 'Open matrix' : 'Matrix locked',
                          icon: Icons.grid_view_outlined,
                          onPressed: isUnlocked ? _openAccessMatrix : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopRightStatusCluster extends StatefulWidget {
  const _TopRightStatusCluster({
    required this.session,
    required this.showVoicePresence,
  });

  final SecuritySessionState session;
  final bool showVoicePresence;

  @override
  State<_TopRightStatusCluster> createState() => _TopRightStatusClusterState();
}

class _TopRightStatusClusterState extends State<_TopRightStatusCluster> {
  bool _expanded = false;

  void _setExpanded(bool value) {
    if (_expanded == value) {
      return;
    }

    setState(() {
      _expanded = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = math.min<double>(240, MediaQuery.sizeOf(context).width - 32);

    return MouseRegion(
      onEnter: (_) => _setExpanded(true),
      onExit: (_) => _setExpanded(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _setExpanded(!_expanded),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.topRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: _expanded
                ? _ExpandedTopRightStatus(
                    session: widget.session,
                    showVoicePresence: widget.showVoicePresence,
                  )
                : _CollapsedTopRightStatus(session: widget.session),
          ),
        ),
      ),
    );
  }
}

class _CollapsedTopRightStatus extends StatelessWidget {
  const _CollapsedTopRightStatus({required this.session});

  final SecuritySessionState session;

  @override
  Widget build(BuildContext context) {
    final isUnlocked = session.isUnlocked && !session.isExpired;
    final accent = isUnlocked
        ? const Color(0xFF7ACB9A)
        : const Color(0xFF6B7780);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1418).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isUnlocked ? Icons.lock_open : Icons.lock,
              size: 14,
              color: accent,
            ),
            const SizedBox(width: 8),
            Text(
              isUnlocked ? 'Session active' : 'Session locked',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 10),
            _MiniStatusDot(color: accent),
          ],
        ),
      ),
    );
  }
}

class _ExpandedTopRightStatus extends StatelessWidget {
  const _ExpandedTopRightStatus({
    required this.session,
    required this.showVoicePresence,
  });

  final SecuritySessionState session;
  final bool showVoicePresence;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showVoicePresence) ...[
            const IgnorePointer(child: VoicePresenceChip(compact: true)),
            const SizedBox(height: 8),
          ],
          _SecuritySessionPill(session: session),
        ],
      ),
    );
  }
}

class _MiniStatusDot extends StatelessWidget {
  const _MiniStatusDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 0),
          ),
        ],
      ),
    );
  }
}

class _SessionLabel extends StatelessWidget {
  const _SessionLabel({required this.label, this.accent});

  final String label;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final baseColor = accent ?? const Color(0xFFE4E8EA);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: baseColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: baseColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MiniSessionAction extends StatelessWidget {
  const _MiniSessionAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFE6F0E8),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      icon: Icon(icon, size: 14),
      label: Text(label),
    );
  }
}
