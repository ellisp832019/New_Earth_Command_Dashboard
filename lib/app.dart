import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/app_database.dart';
import 'core/routing/app_router.dart';
import 'core/routing/route_names.dart';
import 'core/theme/app_theme.dart';
import 'features/security/application/security_session_controller.dart';
import 'features/settings/application/settings_controller.dart';
import 'features/meeting_system/presentation/meeting_notification_bridge.dart';
import 'features/knowledge_library/presentation/knowledge_library_dock_host.dart';
import 'features/treasury/presentation/treasury_dock_host.dart';
import 'features/system_backup/presentation/backup_guardian_dock_host.dart';
import 'features/security/presentation/security_session_activity_tracker.dart';
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
        appRouter.go(RouteNames.securityLock);
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
                    unawaited(
                      DesktopPresenceController.instance.sleep(),
                    );
                    return null;
                  },
                ),
                WakeDashboardIntent:
                    CallbackAction<WakeDashboardIntent>(
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
                    appRouter.go(RouteNames.securityLock);
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
                      appSettings?.showDockOverlays ?? true;
                  final showBackupGuardianDock =
                      appSettings?.showBackupGuardianDock ?? true;
                  final showTreasuryDock =
                      appSettings?.showTreasuryDock ?? true;
                  final showKnowledgeLibraryDock =
                      appSettings?.showKnowledgeLibraryDock ?? true;

                  return Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: [
                      if (showDockOverlays && showBackupGuardianDock)
                        BackupGuardianDockHost(
                          currentPath: routeInfo.uri.path,
                        ),
                      if (showDockOverlays && showTreasuryDock)
                        TreasuryDockHost(
                          currentPath: routeInfo.uri.path,
                        ),
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
                  child: SizedBox(
                    width: math.min(
                      340,
                      MediaQuery.sizeOf(context).width - 32,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if ((appSettings?.showDockOverlays ?? true) &&
                            (appSettings?.showVoicePresenceChip ?? true))
                          const IgnorePointer(child: VoicePresenceChip()),
                        if ((appSettings?.showDockOverlays ?? true) &&
                            (appSettings?.showVoicePresenceChip ?? true))
                          const SizedBox(height: 12),
                        _SecuritySessionPill(session: securitySession),
                      ],
                    ),
                  ),
                ),
              ),
              if ((appSettings?.showDockOverlays ?? true) &&
                  (appSettings?.showVoiceConversationDock ?? true) &&
                  (appSettings?.voiceAssistantEnabled ?? true))
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
    appRouter.go(RouteNames.securityLock);
  }

  void _openAccessMatrix() {
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
      return 'Active user: none';
    }

    return 'Active user: $label';
  }

  String _presenceLabel(SecuritySessionState session) {
    final label = session.activeUserLabel;
    if (label == null || label.isEmpty) {
      return 'Status: offline';
    }

    return session.activeUserOnline ? 'Status: online' : 'Status: offline';
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
    final presenceLabel = _presenceLabel(session);
    final remainingFraction = session.timeout.inMilliseconds <= 0 ||
            remaining == null
        ? 0.0
        : remaining.inMilliseconds / session.timeout.inMilliseconds;
    final clampedFraction = remainingFraction.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 260;
        final contentSpacing = isCompact ? 8.0 : 10.0;
        final labelSpacing = isCompact ? 8.0 : 10.0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _openSecurityLock,
            child: Ink(
              decoration: BoxDecoration(
                color: const Color(0xFF0B1418).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.55),
                ),
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
                  horizontal: isCompact ? 12 : 14,
                  vertical: isCompact ? 10 : 12,
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
                          size: isCompact ? 14 : 16,
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
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
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
                                      color: accentColor.withValues(alpha: 0.45),
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
                        _SessionLabel(
                          label: durationSinceConnect == null
                              ? 'Connected: -'
                              : 'Connected ${_formatDuration(durationSinceConnect)} ago',
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
                          label: 'Open matrix',
                          icon: Icons.grid_view_outlined,
                          onPressed: _openAccessMatrix,
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
  final VoidCallback onPressed;

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
