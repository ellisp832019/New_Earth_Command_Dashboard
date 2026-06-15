import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'desktop_speech_bridge_service.dart';
import '../settings/application/settings_controller.dart';
import 'application/voice_startup_gate_controller.dart';
import 'voice_startup_gate_service.dart';
import 'voice_speech_diagnostics_service.dart';

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
  bool _voiceDiagnosticsShown = false;

  @override
  void initState() {
    super.initState();
    _scheduleRefresh();
    _maybeShowVoiceDiagnostics();
  }

  @override
  void didUpdateWidget(covariant VoiceStartupGateScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleRefresh();
    _maybeShowVoiceDiagnostics();
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

  void _maybeShowVoiceDiagnostics() {
    if (widget.result.isReady || _voiceDiagnosticsShown) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.result.isReady || _voiceDiagnosticsShown) {
        return;
      }

      _voiceDiagnosticsShown = true;
      unawaited(_showVoiceDiagnostics());
    });
  }

  Future<void> _showVoiceDiagnostics() async {
    final diagnostics = await VoiceSpeechDiagnosticsService().run();
    if (!mounted) {
      return;
    }

    final bridge = diagnostics.bridgeDiagnostics;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Voice diagnostics'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(diagnostics.headsetStatus),
                const SizedBox(height: 12),
                Text(diagnostics.bridgeStatus),
                if (bridge != null) ...[
                  const SizedBox(height: 12),
                  Text('Python: ${bridge.pythonVersion}'),
                  Text('Bridge model: ${bridge.bridgeModel}'),
                  if (bridge.defaultInputDevice != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Default input: ${bridge.defaultInputDevice!['name']}',
                    ),
                  ],
                ],
                const SizedBox(height: 12),
                Text(diagnostics.recommendation),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _headlineForResult(VoiceStartupGateResult result) {
    return switch (result.resolvedState) {
      VoiceStartupGateState.ready => 'Headset detected',
      VoiceStartupGateState.noDevices => 'No microphone or headset found',
      VoiceStartupGateState.microphoneOnly =>
        'Microphone found, but not a headset-like device',
      VoiceStartupGateState.checkFailed => 'Could not check audio devices',
      VoiceStartupGateState.bypassed => 'Voice gate bypassed',
    };
  }

  String _explanationForResult(VoiceStartupGateResult result) {
    return switch (result.resolvedState) {
      VoiceStartupGateState.ready =>
        'The assistant can start hands-free voice with the headset you connected.',
      VoiceStartupGateState.noDevices =>
        'No audio input is showing up yet. Connect a Bluetooth headset or headset microphone, then try again.',
      VoiceStartupGateState.microphoneOnly =>
        'Windows can see a microphone, but not one that looks like a headset. If this is your headset mic, choose Have Voice.',
      VoiceStartupGateState.checkFailed =>
        'The assistant could not verify the audio devices from Windows right now. Open diagnostics to check the offline bridge and default input path.',
      VoiceStartupGateState.bypassed =>
        'The startup gate is bypassed on this platform, so the assistant will continue without blocking.',
    };
  }

  String _nextStepForResult(VoiceStartupGateResult result) {
    return switch (result.resolvedState) {
      VoiceStartupGateState.ready => 'You can continue into the assistant now.',
      VoiceStartupGateState.noDevices =>
        'If a headset is already connected, unplug and reconnect it, then retry.',
      VoiceStartupGateState.microphoneOnly =>
        'Choose Have Voice if this microphone is actually the one on your headset.',
      VoiceStartupGateState.checkFailed =>
        'Run diagnostics to see whether the bridge can still reach the input device.',
      VoiceStartupGateState.bypassed =>
        'You can continue to the dashboard without waiting for the gate.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = widget.result;

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
                      _headlineForResult(result),
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(result.message, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Text(
                      'The assistant keeps checking while this screen is open, so you can connect the headset and continue without restarting.',
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
                              'What the assistant sees',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _explanationForResult(result),
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _nextStepForResult(result),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
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
                    if (result.devices.isNotEmpty) ...[
                      Text(
                        'Detected audio inputs',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...result.devices.map(
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
                                .read(settingsControllerProvider)
                                .setVoicePreferences(
                                  voiceAssistantEnabled: true,
                                );
                            ref
                                .read(voiceStartupGateLandingProvider.notifier)
                                .requestVoiceAssistant();
                          },
                          icon: const Icon(Icons.headset_mic_outlined),
                          label: const Text('Have Voice'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            ref
                                .read(settingsControllerProvider)
                                .setVoicePreferences(
                                  voiceAssistantEnabled: false,
                                );
                            ref
                                .read(voiceStartupGateLandingProvider.notifier)
                                .requestDashboard();
                          },
                          icon: const Icon(Icons.volume_off_outlined),
                          label: const Text('No Voice'),
                        ),
                        TextButton.icon(
                          onPressed: _showVoiceDiagnostics,
                          icon: const Icon(Icons.health_and_safety_outlined),
                          label: const Text('Run diagnostics'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'The assistant keeps rechecking while this screen is open, and you can still use diagnostics or bypass if your headset mic is the correct input.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If your headset shows up as a plain microphone, you can still open the assistant and use it as the input device.',
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
