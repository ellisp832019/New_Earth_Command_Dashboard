import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  VoiceCommandType? _selectedType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<VoiceCommand> get _filteredCommands {
    final query = _searchController.text.trim().toLowerCase();
    return widget.commands.where((command) {
      final matchesSearch = query.isEmpty ||
          command.transcript.toLowerCase().contains(query) ||
          command.type.label.toLowerCase().contains(query);
      final matchesType =
          _selectedType == null || command.type == _selectedType;
      return matchesSearch && matchesType;
    }).toList(growable: false);
  }

  Future<void> _copyTranscript(String transcript) async {
    final trimmed = transcript.trim();
    if (trimmed.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: trimmed));
  }

  Widget _buildTypeChip({
    required String label,
    required VoiceCommandType? type,
  }) {
    final selected = _selectedType == type;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _selectedType = selected ? null : type;
        });
      },
    );
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  VoiceCommand? get _latestCommand =>
      widget.commands.isEmpty ? null : widget.commands.first;

  void _reuseLatest() {
    final latest = _latestCommand;
    if (latest == null || widget.onCommandSelected == null) {
      return;
    }

    widget.onCommandSelected!(latest);
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

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        Text(
          'Recent capture history',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Saved captures stay local and can be reopened, copied, or filtered by type.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: Text('${widget.commands.length} saved captures'),
                  ),
                  if (_latestCommand != null)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      label: Text(
                        'Latest ${_latestCommand!.type.label.toLowerCase()} capture',
                      ),
                    ),
                ],
              ),
            ),
            Text('${filteredCommands.length}/${widget.commands.length}'),
          ],
        ),
        const SizedBox(height: 12),
        if (_latestCommand != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Latest capture',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      Chip(
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        label: Text(
                          _formatDateTime(_latestCommand!.createdAt),
                        ),
                      ),
                    ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _latestCommand!.transcript,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                    '${_latestCommand!.type.label} capture ready to reuse.',
                        style: theme.textTheme.bodySmall,
                      ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed:
                            widget.onCommandSelected == null ? null : _reuseLatest,
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: const Text('Reuse latest'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await _copyTranscript(_latestCommand!.transcript);
                          if (!context.mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied latest voice capture.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded),
                        label: const Text('Copy latest'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
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
              : 'Tap any saved command to restore it into the editor. Use the chips to narrow the list by type.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTypeChip(label: 'All', type: null),
            ...VoiceCommandType.values.map(
              (type) => _buildTypeChip(label: type.label, type: type),
            ),
          ],
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
                  '${command.type.label} • ${_formatDateTime(command.createdAt)}',
                ),
                trailing: Wrap(
                  spacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Copy transcript',
                      onPressed: () async {
                        await _copyTranscript(command.transcript);
                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied voice transcript.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded),
                    ),
                    Icon(
                      Icons.restore_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}
