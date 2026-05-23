import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/application/settings_controller.dart';
import 'application/voice_startup_gate_controller.dart';
import 'voice_startup_gate_service.dart';

class VoiceStartupGateScreen extends ConsumerWidget {
  const VoiceStartupGateScreen({super.key, required this.result});

  final VoiceStartupGateResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gaia is waiting for your headset',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.message,
                    style: theme.textTheme.bodyLarge,
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
                    'Gaia will continue only after it sees a connected headset or headset microphone.',
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
        ),
      ),
    );
  }
}
