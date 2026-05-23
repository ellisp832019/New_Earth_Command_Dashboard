import 'package:flutter/material.dart';

import '../voice_command_model.dart';

class CommandHistoryList extends StatelessWidget {
  const CommandHistoryList({
    super.key,
    required this.commands,
    this.onCommandSelected,
  });

  final List<VoiceCommand> commands;
  final ValueChanged<VoiceCommand>? onCommandSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (commands.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Command History', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'No voice commands saved yet. Save one reviewed capture, then tap it here to reuse it.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Command History', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Tap any saved command to restore it into the editor.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        ...commands.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final command = entry.value;

            return Card(
              key: Key('voiceHistoryItem-$index'),
              child: ListTile(
                onTap: onCommandSelected == null
                    ? null
                    : () => onCommandSelected!(command),
                leading: const Icon(Icons.history_rounded),
                title: Text(command.transcript),
                subtitle: Text(
                  '${command.type.label} • ${command.createdAt.hour.toString().padLeft(2, '0')}:${command.createdAt.minute.toString().padLeft(2, '0')}',
                ),
                trailing: Icon(
                  Icons.restore_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
