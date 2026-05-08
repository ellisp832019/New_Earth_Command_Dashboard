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
                'No voice commands saved yet. Try a mock transcript and choose where it belongs.',
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
        const SizedBox(height: 12),
        ...commands.map(
          (command) => Card(
            child: ListTile(
              onTap: onCommandSelected == null
                  ? null
                  : () => onCommandSelected!(command),
              title: Text(command.transcript),
              subtitle: Text(command.type.label),
              trailing: Text(
                '${command.createdAt.hour.toString().padLeft(2, '0')}:${command.createdAt.minute.toString().padLeft(2, '0')}',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
