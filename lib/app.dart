import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/app_database.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/application/settings_controller.dart';
import 'features/voice_assistant/application/voice_startup_gate_controller.dart';
import 'features/voice_assistant/voice_startup_gate_service.dart';
import 'features/voice_assistant/voice_startup_gate_screen.dart';
import 'features/voice_assistant/widgets/voice_conversation_dock.dart';
import 'features/voice_assistant/widgets/voice_handsfree_layer.dart';
import 'features/voice_assistant/widgets/voice_presence_chip.dart';

class NewEarthCommandDashboardApp extends ConsumerWidget {
  const NewEarthCommandDashboardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(databaseReadyProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final settingsSnapshot = ref.watch(settingsSnapshotProvider);

    Widget buildAppRouter() {
      return MaterialApp.router(
        title: 'Gaia',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        routerConfig: appRouter,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              VoiceHandsfreeLayer(
                child: child ?? const SizedBox.shrink(),
              ),
              const Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: IgnorePointer(
                    child: VoicePresenceChip(),
                  ),
                ),
              ),
              const Positioned(
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: VoiceConversationDock(),
                ),
              ),
            ],
          );
        },
      );
    }

    Widget buildGateScreen(VoiceStartupGateResult result) {
      return MaterialApp(
        title: 'Gaia',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: VoiceStartupGateScreen(result: result),
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
      loading: () {
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
            if (!result.isReady) {
              return buildGateScreen(result);
            }
            return buildAppRouter();
          },
        );
      },
      error: (error, stackTrace) {
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
            if (!result.isReady) {
              return buildGateScreen(result);
            }
            return buildAppRouter();
          },
        );
      },
      data: (snapshot) {
        if (!snapshot.settings.voiceAssistantEnabled) {
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
            if (!result.isReady) {
              return buildGateScreen(result);
            }
            return buildAppRouter();
          },
        );
      },
    );
  }
}
