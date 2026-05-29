import 'package:flutter/material.dart';

import '../voice_command_model.dart';

class CommandHistoryList extends StatefulWidget {
  const CommandHistoryList({
    super.key,
    required this.commands,
    this.onCommandSelected,
  });

  final List<VoiceCommand> commands;
  final ValueChanged<VoiceCommand>? onCommandSelected;

  @override
  State<CommandHistoryList> createState() => _CommandHistoryListState();
}

class _CommandHistoryListState extends State<CommandHistoryList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<VoiceCommand> get _filteredCommands {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.commands;
    }

    return widget.commands
        .where((command) {
          return command.transcript.toLowerCase().contains(query) ||
              command.type.label.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredCommands = _filteredCommands;
    final hasSearch = _searchController.text.trim().isNotEmpty;

    if (widget.commands.isEmpty) {
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
        Row(
          children: [
            Expanded(
              child: Text(
                'Command History',
                style: theme.textTheme.titleMedium,
              ),
            ),
            Text(
              '${filteredCommands.length}/${widget.commands.length}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('voiceHistorySearchField'),
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Search saved captures',
            hintText: 'Search a phrase or type',
            prefixIcon: const Icon(Icons.search_outlined),
            suffixIcon: hasSearch
                ? IconButton(
                    key: const Key('voiceHistorySearchClearButton'),
                    tooltip: 'Clear search',
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                    icon: const Icon(Icons.clear_rounded),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hasSearch
              ? 'Showing captures that match your search.'
              : 'Tap any saved command to restore it into the editor.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if (filteredCommands.isEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No saved commands match this search yet.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ] else ...[
          ...filteredCommands.asMap().entries.map((entry) {
            final index = entry.key;
            final command = entry.value;

            return Card(
              key: Key('voiceHistoryItem-$index'),
              child: ListTile(
                onTap: widget.onCommandSelected == null
                    ? null
                    : () => widget.onCommandSelected!(command),
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
          }),
        ],
      ],
    );
  }
}
