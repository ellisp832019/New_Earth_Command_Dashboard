import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'desktop_speech_bridge_service.dart';
import '../settings/application/settings_controller.dart';
import 'application/voice_startup_gate_controller.dart';
import 'voice_startup_gate_service.dart';

class VoiceStartupGateScreen extends ConsumerStatefulWidget {
  const VoiceStartupGateScreen({super.key, required this.result});

  final VoiceStartupGateResult result;

  @override
  ConsumerState<VoiceStartupGateScreen> createState() =>
      _VoiceStartupGateScreenState();
}

class _VoiceStartupGateScreenState
    extends ConsumerState<VoiceStartupGateScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _scheduleRefresh();
  }

  @override
  void didUpdateWidget(covariant VoiceStartupGateScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _scheduleRefresh() {
    _refreshTimer?.cancel();
    if (widget.result.isReady) {
      return;
    }

    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) {
        return;
      }

      ref.invalidate(voiceStartupGateProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gaia is waiting for your headset',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(widget.result.message, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Gaia keeps checking while this screen is open, so you can connect the headset and continue without restarting.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Capture path',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DesktopSpeechBridgeService.isSupported
                                  ? 'Windows voice capture tries the local bridge first, then falls back to the local microphone recognizer.'
                                  : 'This build falls back to the local microphone recognizer when the bridge is not available.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (widget.result.devices.isNotEmpty) ...[
                      Text(
                        'Detected audio inputs',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...widget.result.devices.map(
                        (device) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              device.isHeadsetLike
                                  ? Icons.headphones_outlined
                                  : Icons.mic_outlined,
                            ),
                            title: Text(device.name),
                            subtitle: device.identifier.isEmpty
                                ? null
                                : Text(device.identifier),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: () {
                            ref.invalidate(voiceStartupGateProvider);
                          },
                          icon: const Icon(Icons.refresh_outlined),
                          label: const Text('Retry'),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            ref.invalidate(voiceStartupGateProvider);
                          },
                          icon: const Icon(Icons.headset_outlined),
                          label: const Text('Check again'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            ref
                                .read(voiceStartupGateBypassProvider.notifier)
                                .allowBypass();
                          },
                          icon: const Icon(Icons.headset_mic_outlined),
                          label: const Text('Use headset anyway'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            ref
                                .read(settingsControllerProvider)
                                .setVoicePreferences(
                                  voiceAssistantEnabled: false,
                                );
                          },
                          icon: const Icon(Icons.volume_off_outlined),
                          label: const Text('Continue without Voice'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gaia will continue only after it sees a connected headset or headset microphone, but it keeps rechecking while this screen is open.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If your headset shows up as a plain microphone, you can still open Gaia and use it as the input device.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If you prefer, disable the voice assistant now and re-enable it later in Settings.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
