import 'package:flutter/material.dart';

class AssistantDockPlaceholder extends StatelessWidget {
  const AssistantDockPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('AI Assistant Dock', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            const Text('Status: Offline'),
            const Text('Model: Not connected'),
            const Text('STT: Not connected'),
            const Text('TTS: Not connected'),
            const Text('Permissions: Locked'),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton(onPressed: () {}, child: const Text('Start placeholder')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () {}, child: const Text('Settings')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
