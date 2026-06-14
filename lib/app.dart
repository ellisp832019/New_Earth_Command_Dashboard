import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/app_database.dart';
import 'core/routing/app_router.dart';
import 'core/routing/route_names.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/application/settings_controller.dart';
import 'features/meeting_system/presentation/meeting_notification_bridge.dart';
import 'features/voice_assistant/application/voice_startup_gate_controller.dart';
import 'features/voice_assistant/voice_startup_gate_service.dart';
import 'features/voice_assistant/voice_startup_gate_screen.dart';
import 'features/system_backup/presentation/backup_guardian_dock_host.dart';
import 'features/voice_assistant/widgets/voice_conversation_dock.dart';
import 'features/voice_assistant/widgets/voice_handsfree_layer.dart';
import 'features/voice_assistant/widgets/voice_presence_chip.dart';

class OpenCommandPaletteIntent extends Intent {
  const OpenCommandPaletteIntent();
}

class CloseCommandPaletteIntent extends Intent {
  const CloseCommandPaletteIntent();
}

class NewEarthCommandDashboardApp extends ConsumerWidget {
  const NewEarthCommandDashboardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(databaseReadyProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final settingsSnapshot = ref.watch(settingsSnapshotProvider);
    final startupComplete = ref.watch(voiceStartupGateBypassProvider);

    Widget buildAppRouter() {
      return _VoiceStartupLandingHandler(
        child: MeetingNotificationBridge(
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
                  },
                  child: child ?? const SizedBox.shrink(),
                ),
              );

              return Stack(
                fit: StackFit.expand,
                children: [
                  VoiceHandsfreeLayer(child: routedChild),
                  const BackupGuardianDockHost(),
                  const Positioned(
                    top: 16,
                    right: 16,
                    child: SafeArea(
                      child: IgnorePointer(child: VoicePresenceChip()),
                    ),
                  ),
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: SafeArea(child: VoiceConversationDock()),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }

    Widget buildGateScreen(VoiceStartupGateResult result) {
      return MeetingNotificationBridge(
        child: MaterialApp(
          title: 'Gaia',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          home: VoiceStartupGateScreen(result: result),
        ),
      );
    }

    Widget buildDefaultGate() {
      return buildGateScreen(
        const VoiceStartupGateResult(
          isReady: false,
          message: 'Checking for a connected headset...',
          devices: <VoiceInputDevice>[],
        ),
      );
    }

    return settingsSnapshot.when(
      data: (snapshot) {
        if (startupComplete) {
          return buildAppRouter();
        }

        final startupGate = ref.watch(voiceStartupGateProvider);
        return startupGate.when(
          loading: buildDefaultGate,
          error: (error, stackTrace) => buildGateScreen(
            const VoiceStartupGateResult(
              isReady: false,
              message:
                  'Gaia could not check the headset connection right now. Retry once the device is connected.',
              devices: <VoiceInputDevice>[],
            ),
          ),
          data: (VoiceStartupGateResult result) {
            return buildGateScreen(result);
          },
        );
      },
      loading: () {
        if (startupComplete) {
          return buildAppRouter();
        }

        final startupGate = ref.watch(voiceStartupGateProvider);
        return startupGate.when(
          loading: buildDefaultGate,
          error: (error, stackTrace) => buildGateScreen(
            const VoiceStartupGateResult(
              isReady: false,
              message:
                  'Gaia could not check the headset connection right now. Retry once the device is connected.',
              devices: <VoiceInputDevice>[],
            ),
          ),
          data: (VoiceStartupGateResult result) {
            return buildGateScreen(result);
          },
        );
      },
      error: (error, stackTrace) {
        if (startupComplete) {
          return buildAppRouter();
        }

        final startupGate = ref.watch(voiceStartupGateProvider);
        return startupGate.when(
          loading: buildDefaultGate,
          error: (error, stackTrace) => buildGateScreen(
            const VoiceStartupGateResult(
              isReady: false,
              message:
                  'Gaia could not check the headset connection right now. Retry once the device is connected.',
              devices: <VoiceInputDevice>[],
            ),
          ),
          data: (VoiceStartupGateResult result) {
            return buildGateScreen(result);
          },
        );
      },
    );
  }
}

class _VoiceStartupLandingHandler extends ConsumerStatefulWidget {
  const _VoiceStartupLandingHandler({required this.child});

  final Widget child;

  @override
  ConsumerState<_VoiceStartupLandingHandler> createState() =>
      _VoiceStartupLandingHandlerState();
}

class _VoiceStartupLandingHandlerState
    extends ConsumerState<_VoiceStartupLandingHandler> {
  bool _navigationQueued = false;

  @override
  void initState() {
    super.initState();
    _applyInitialLanding();
  }

  @override
  void didUpdateWidget(covariant _VoiceStartupLandingHandler oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applyInitialLanding();
  }

  void _applyInitialLanding() {
    final landingRoute = ref.read(voiceStartupGateLandingProvider);
    if (landingRoute == null || _navigationQueued) {
      return;
    }

    _navigationQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      appRouter.go(landingRoute);
      if (voiceStartupGateLandingRoute.value == landingRoute) {
        voiceStartupGateLandingRoute.value = null;
      }
      ref.read(voiceStartupGateLandingProvider.notifier).clear();
      _navigationQueued = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
