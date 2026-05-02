import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'voice_command_action_service.dart';
import 'voice_command_model.dart';
import 'voice_command_service.dart';
import 'widgets/command_history_list.dart';
import 'widgets/command_type_selector.dart';
import 'widgets/transcript_preview_card.dart';

class VoiceAssistantScreen extends ConsumerStatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  ConsumerState<VoiceAssistantScreen> createState() =>
      _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen> {
  final VoiceCommandService _service = VoiceCommandService();
  final TextEditingController _transcriptController = TextEditingController();

  VoiceCommandType _selectedType = VoiceCommandType.task;
  String? _selectedProjectId;
  List<VoiceCommand> _history = [];
  String? _lastCodexPrompt;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _history = _service.getHistory();
  }

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _saveSelectedCommand() async {
    final transcript = _transcriptController.text.trim();

    if (transcript.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add a transcript first.')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref
          .read(voiceCommandActionServiceProvider)
          .saveCommand(
            transcript: transcript,
            type: _selectedType,
            projectId: _selectedProjectId,
          );
      _service.addCommand(transcript: transcript, type: _selectedType);

      setState(() {
        _history = _service.getHistory();
        _lastCodexPrompt = null;
        _transcriptController.clear();
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saved as ${_selectedType.label} in the local dashboard data.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showCodexPrompt() {
    final transcript = _transcriptController.text.trim();

    if (transcript.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add a transcript first.')));
      return;
    }

    final prompt = _service.createCodexPrompt(transcript);
    _service.addCommand(
      transcript: transcript,
      type: VoiceCommandType.codexPrompt,
    );

    setState(() {
      _lastCodexPrompt = prompt;
      _history = _service.getHistory();
    });

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Codex-safe prompt'),
          content: SingleChildScrollView(child: SelectableText(prompt)),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: prompt));
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Prompt copied for review before using Codex.',
                    ),
                  ),
                );
              },
              child: const Text('Copy Prompt'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _mockRecordCommand() {
    setState(() {
      _transcriptController.text =
          'Capture a task to review the voice bridge scaffold and prepare the next safe dashboard step.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectOptions = ref.watch(voiceAssistantProjectOptionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Voice Assistant')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Speak, review, and turn your words into dashboard actions.',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This first safe version stays local, uses mock input, and lets you decide what to do before anything is saved or sent on.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.mic_none_rounded,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _mockRecordCommand,
                    icon: const Icon(Icons.graphic_eq),
                    label: const Text('Use Mock Transcript'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Live microphone access is intentionally not connected in v0.1.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          TranscriptPreviewCard(
            controller: _transcriptController,
            helperText:
                'Review the words first, then choose whether this belongs as a task, journal entry, idea, or Codex prompt.',
          ),
          const SizedBox(height: 16),
          Text('Command Type', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          CommandTypeSelector(
            selectedType: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value;
              });
            },
          ),
          const SizedBox(height: 24),
          Text('Related Project', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          projectOptions.when(
            data: (options) {
              return DropdownButtonFormField<String?>(
                initialValue: _selectedProjectId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Optional project link',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No project selected'),
                  ),
                  ...options.map(
                    (project) => DropdownMenuItem<String?>(
                      value: project.id,
                      child: Text(project.name),
                    ),
                  ),
                ],
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _selectedProjectId = value;
                        });
                      },
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) {
              return Text(
                'Projects could not be loaded right now.',
                style: theme.textTheme.bodySmall,
              );
            },
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: !_isSaving && _selectedType == VoiceCommandType.task
                    ? _saveSelectedCommand
                    : null,
                child: const Text('Save as Task'),
              ),
              FilledButton.tonal(
                onPressed:
                    !_isSaving && _selectedType == VoiceCommandType.journalEntry
                    ? _saveSelectedCommand
                    : null,
                child: const Text('Save as Journal Entry'),
              ),
              FilledButton.tonal(
                onPressed: _isSaving ? null : _showCodexPrompt,
                child: const Text('Send to Codex'),
              ),
              FilledButton.tonal(
                onPressed: !_isSaving && _selectedType == VoiceCommandType.idea
                    ? _saveSelectedCommand
                    : null,
                child: const Text('Save as Idea'),
              ),
            ],
          ),
          if (_lastCodexPrompt != null) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Codex Prompt',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(_lastCodexPrompt!),
                    if (_selectedProjectId != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Project context selected for review: $_selectedProjectId',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          CommandHistoryList(commands: _history),
        ],
      ),
    );
  }
}
