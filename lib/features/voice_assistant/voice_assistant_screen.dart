import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'voice_command_action_service.dart';
import 'voice_command_model.dart';
import 'voice_command_service.dart';
import 'windows_voice_typing_service.dart';
import 'widgets/command_history_list.dart';
import 'widgets/command_type_selector.dart';
import 'widgets/transcript_preview_card.dart';

const _taskCategoryOptions = [
  'Build',
  'Design',
  'Research',
  'Test',
  'Docs',
  'Planning',
  'Business',
  'Learning',
  'Content',
  'Admin',
  'Wellbeing',
];

const _priorityOptions = ['High', 'Medium', 'Low', 'Someday'];

const _contentPlatformOptions = [
  'LinkedIn',
  'Website',
  'YouTube',
  'Book',
  'Newsletter',
  'Other',
];

const _contentTypeOptions = [
  'LinkedIn Post',
  'Website Journal',
  'Video Script',
  'Image Prompt',
  'Book Section',
  'Project Update',
  'Founder Journey',
  'Technical Update',
  'Awareness Post',
];

const _businessTypeOptions = [
  'Job',
  'Contract',
  'Grant',
  'Partnership',
  'Client',
  'Funding',
  'Mentor',
  'Investor',
  'Collaboration',
  'Business Idea',
];

const _businessStatusOptions = [
  'Researching',
  'Preparing',
  'Applied',
  'Waiting',
  'Follow-up Needed',
  'Accepted',
  'Rejected',
  'Paused',
  'Archived',
];

class VoiceAssistantScreen extends ConsumerStatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  ConsumerState<VoiceAssistantScreen> createState() =>
      _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen> {
  final VoiceCommandService _service = VoiceCommandService();
  final SpeechToText _speech = SpeechToText();
  final TextEditingController _transcriptController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _journalWorkedOnController =
      TextEditingController();
  final TextEditingController _journalLearnedController =
      TextEditingController();
  final TextEditingController _journalNextActionsController =
      TextEditingController();
  final TextEditingController _businessContactController =
      TextEditingController();
  final TextEditingController _businessNextActionController =
      TextEditingController();
  final FocusNode _transcriptFocusNode = FocusNode();

  VoiceCommandType _selectedType = VoiceCommandType.task;
  String? _selectedProjectId;
  List<VoiceCommand> _history = [];
  String? _lastCodexPrompt;
  VoiceCommandSuggestion? _suggestion;
  String? _taskCategoryValue;
  String? _taskPriorityValue;
  String? _contentPlatformValue;
  String? _contentTypeValue;
  String? _businessTypeValue;
  String? _businessStatusValue;
  String _speechStatus = 'Ready when you are.';
  String? _speechError;
  bool _isSaving = false;
  bool _speechAvailable = false;
  bool _isInitializingSpeech = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _history = _service.getHistory();
    _transcriptController.addListener(_handleTranscriptChanged);
  }

  @override
  void dispose() {
    _speech.cancel();
    _transcriptController.removeListener(_handleTranscriptChanged);
    _transcriptController.dispose();
    _titleController.dispose();
    _journalWorkedOnController.dispose();
    _journalLearnedController.dispose();
    _journalNextActionsController.dispose();
    _businessContactController.dispose();
    _businessNextActionController.dispose();
    _transcriptFocusNode.dispose();
    super.dispose();
  }

  void _handleTranscriptChanged() {
    final transcript = _transcriptController.text.trim();

    if (transcript.isEmpty) {
      if (!mounted) {
        return;
      }

      setState(() {
        _suggestion = null;
        _selectedType = VoiceCommandType.task;
        _selectedProjectId = null;
        _taskCategoryValue = null;
        _taskPriorityValue = null;
        _contentPlatformValue = null;
        _contentTypeValue = null;
        _businessTypeValue = null;
        _businessStatusValue = null;
        _titleController.clear();
        _journalWorkedOnController.clear();
        _journalLearnedController.clear();
        _journalNextActionsController.clear();
        _businessContactController.clear();
        _businessNextActionController.clear();
      });
      return;
    }

    final projectOptionsState = ref.read(voiceAssistantProjectOptionsProvider);
    final projectOptions =
        projectOptionsState is AsyncData<List<VoiceAssistantProjectOption>>
        ? projectOptionsState.value
        : const <VoiceAssistantProjectOption>[];
    final suggestion = _service.suggestCommand(
      transcript: transcript,
      projectOptions: projectOptions,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _suggestion = suggestion;
      _selectedType = suggestion.suggestedType;
      _selectedProjectId = suggestion.suggestedProjectId;
      _titleController.text = suggestion.suggestedTitle;
      _taskCategoryValue = suggestion.extractedTaskCategory;
      _taskPriorityValue = suggestion.extractedTaskPriority;
      _journalWorkedOnController.text =
          suggestion.extractedJournalWorkedOn ?? '';
      _journalLearnedController.text = suggestion.extractedJournalLearned ?? '';
      _journalNextActionsController.text =
          suggestion.extractedJournalNextActions ?? '';
      _contentPlatformValue = suggestion.extractedContentPlatform;
      _contentTypeValue = suggestion.extractedContentType;
      _businessTypeValue = suggestion.extractedBusinessType;
      _businessStatusValue = suggestion.extractedBusinessStatus;
      _businessContactController.text =
          suggestion.extractedBusinessContact ?? '';
      _businessNextActionController.text =
          suggestion.extractedBusinessNextAction ?? '';
    });
  }

  Future<void> _startListening() async {
    if (WindowsVoiceTypingService.isSupported) {
      await _startWindowsVoiceTyping();
      return;
    }

    setState(() {
      _speechError = null;
      _isInitializingSpeech = true;
      _speechStatus = 'Preparing microphone...';
    });

    final available = await _speech.initialize(
      onError: _onSpeechError,
      onStatus: _onSpeechStatus,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _speechAvailable = available;
      _isInitializingSpeech = false;
    });

    if (!available) {
      setState(() {
        _speechStatus = 'Microphone speech capture is not available here.';
        _speechError =
            'Check microphone permission, speech services, or use Paste Transcript.';
      });
      return;
    }

    await _speech.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 45),
      pauseFor: const Duration(seconds: 5),
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.confirmation,
        partialResults: true,
        cancelOnError: true,
        autoPunctuation: true,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isListening = true;
      _speechStatus = 'Listening...';
    });
  }

  Future<void> _startWindowsVoiceTyping() async {
    _transcriptFocusNode.requestFocus();

    setState(() {
      _speechError = null;
      _isInitializingSpeech = true;
      _speechStatus = 'Opening Windows voice typing...';
    });

    final available = await WindowsVoiceTypingService.startVoiceTyping();

    if (!mounted) {
      return;
    }

    setState(() {
      _speechAvailable = available;
      _isInitializingSpeech = false;
      _isListening = available;
      _speechStatus = available
          ? 'Windows voice typing is open. Speak now, then review the text here.'
          : 'Windows voice typing could not be opened right now.';
      _speechError = available
          ? null
          : 'Try Win + H, or use Paste Transcript if Windows dictation is unavailable.';
    });
  }

  Future<void> _stopListening() async {
    if (WindowsVoiceTypingService.isSupported) {
      _transcriptFocusNode.requestFocus();
      if (!mounted) {
        return;
      }

      setState(() {
        _isListening = false;
        _speechStatus =
            'Dictation ready to review. If Windows voice typing is still open, press Win + H to close it.';
      });
      return;
    }

    await _speech.stop();
    if (!mounted) {
      return;
    }

    setState(() {
      _isListening = false;
      _speechStatus = 'Stopped. Review the transcript before saving.';
    });
  }

  Future<void> _cancelListening() async {
    if (WindowsVoiceTypingService.isSupported) {
      _transcriptFocusNode.requestFocus();
      if (!mounted) {
        return;
      }

      setState(() {
        _isListening = false;
        _speechStatus =
            'Dictation cancelled in the app. If Windows voice typing is still open, press Win + H to close it.';
      });
      return;
    }

    await _speech.cancel();
    if (!mounted) {
      return;
    }

    setState(() {
      _isListening = false;
      _speechStatus = 'Capture cancelled.';
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) {
      return;
    }

    setState(() {
      _transcriptController.text = result.recognizedWords;
      _transcriptController.selection = TextSelection.collapsed(
        offset: _transcriptController.text.length,
      );
      if (result.finalResult) {
        _isListening = false;
        _speechStatus = 'Transcript captured. Review before saving.';
      }
    });
  }

  void _onSpeechError(SpeechRecognitionError error) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isListening = false;
      _isInitializingSpeech = false;
      _speechError = error.errorMsg;
      _speechStatus = error.permanent
          ? 'Speech capture needs attention before it can run.'
          : 'Speech capture paused. You can try again.';
    });
  }

  void _onSpeechStatus(String status) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isListening = _speech.isListening;
      if (!_isListening && status == 'done') {
        _speechStatus = 'Transcript captured. Review before saving.';
      }
    });
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
      final editableSuggestion = _buildEditableSuggestion();
      await ref
          .read(voiceCommandActionsControllerProvider)
          .saveCommand(
            transcript: editableSuggestion?.transcript ?? transcript,
            type: _selectedType,
            projectId: _selectedProjectId,
            titleOverride: _titleController.text.trim(),
            suggestion: editableSuggestion,
          );
      _service.addCommand(transcript: transcript, type: _selectedType);

      setState(() {
        _history = _service.getHistory();
        _lastCodexPrompt = null;
        _suggestion = null;
        _taskCategoryValue = null;
        _taskPriorityValue = null;
        _contentPlatformValue = null;
        _contentTypeValue = null;
        _businessTypeValue = null;
        _businessStatusValue = null;
        _titleController.clear();
        _journalWorkedOnController.clear();
        _journalLearnedController.clear();
        _journalNextActionsController.clear();
        _businessContactController.clear();
        _businessNextActionController.clear();
        _transcriptController.clear();
        _speechStatus = 'Saved. Ready for another capture.';
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

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();

    if (text == null || text.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clipboard is empty right now.')),
      );
      return;
    }

    setState(() {
      _transcriptController.text = text;
      _transcriptController.selection = TextSelection.collapsed(
        offset: text.length,
      );
      _speechStatus = 'Transcript pasted. Review before saving.';
    });
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
      _speechStatus = 'Codex prompt prepared for review.';
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
      _speechStatus = 'Mock transcript loaded. Review before saving.';
    });
  }

  void _applyTemplate(VoiceCommandTemplate template) {
    setState(() {
      _selectedType = template.type;
      _transcriptController.text = template.transcript;
      _transcriptController.selection = TextSelection.collapsed(
        offset: template.transcript.length,
      );
      _speechStatus = 'Template loaded. Review before saving.';
    });
    _transcriptFocusNode.requestFocus();
  }

  void _restoreCommandFromHistory(VoiceCommand command) {
    setState(() {
      _selectedType = command.type;
      _transcriptController.text = command.transcript;
      _transcriptController.selection = TextSelection.collapsed(
        offset: command.transcript.length,
      );
      _speechStatus = 'History item loaded. Review before saving.';
    });
    _transcriptFocusNode.requestFocus();
  }

  void _handleQuickAction(VoiceCommandQuickAction action) {
    if (action.route != null) {
      context.go(action.route!);
      return;
    }

    if (action.templateId != null) {
      final template = _service.getTemplates().firstWhere(
            (item) => item.id == action.templateId,
          );
      _applyTemplate(template);
    }
  }

  VoiceCommandSuggestion? _buildEditableSuggestion() {
    final suggestion = _suggestion;
    if (suggestion == null) {
      return null;
    }

    final journalWorkedOn = _journalWorkedOnController.text.trim();
    final journalLearned = _journalLearnedController.text.trim();
    final journalNextActions = _journalNextActionsController.text.trim();
    final businessContact = _businessContactController.text.trim();
    final businessNextAction = _businessNextActionController.text.trim();

    return VoiceCommandSuggestion(
      transcript: suggestion.transcript,
      suggestedType: _selectedType,
      suggestedTitle: _titleController.text.trim(),
      extractedTaskCategory: _taskCategoryValue,
      extractedTaskPriority: _taskPriorityValue,
      extractedJournalWorkedOn: journalWorkedOn.isEmpty
          ? null
          : journalWorkedOn,
      extractedJournalLearned: journalLearned.isEmpty ? null : journalLearned,
      extractedJournalNextActions: journalNextActions.isEmpty
          ? null
          : journalNextActions,
      extractedContentPlatform: _contentPlatformValue,
      extractedContentType: _contentTypeValue,
      extractedBusinessType: _businessTypeValue,
      extractedBusinessStatus: _businessStatusValue,
      extractedBusinessContact: businessContact.isEmpty
          ? null
          : businessContact,
      extractedBusinessNextAction: businessNextAction.isEmpty
          ? null
          : businessNextAction,
      suggestedProjectId: _selectedProjectId,
      suggestedProjectName: suggestion.suggestedProjectName,
      usedExplicitType: suggestion.usedExplicitType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectOptions = ref.watch(voiceAssistantProjectOptionsProvider);
    final templates = _service.getTemplates();
    final quickActions = _service.suggestQuickActions(
      transcript: _transcriptController.text,
      suggestion: _suggestion,
    );

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
            'Press Start Listening, review the transcript, then choose where it belongs before anything is saved.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    size: 40,
                    color: _isListening
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        key: const Key('voiceStartListeningButton'),
                        onPressed:
                            _isSaving || _isListening || _isInitializingSpeech
                            ? null
                            : _startListening,
                        icon: _isInitializingSpeech
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.mic_rounded),
                        label: Text(
                          _isInitializingSpeech
                              ? 'Preparing'
                              : 'Start Listening',
                        ),
                      ),
                      FilledButton.tonalIcon(
                        key: const Key('voiceStopListeningButton'),
                        onPressed: _isListening ? _stopListening : null,
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: const Text('Stop'),
                      ),
                      TextButton.icon(
                        key: const Key('voiceCancelListeningButton'),
                        onPressed: _isListening ? _cancelListening : null,
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    key: const Key('voiceMockTranscriptButton'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      foregroundColor: theme.colorScheme.onSecondaryContainer,
                    ),
                    onPressed: _mockRecordCommand,
                    icon: const Icon(Icons.graphic_eq),
                    label: const Text('Use Mock Transcript'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
                    key: const Key('voicePasteTranscriptButton'),
                    onPressed: _pasteFromClipboard,
                    icon: const Icon(Icons.content_paste),
                    label: const Text('Paste Transcript'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _speechStatus,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  if (_speechError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _speechError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (!_speechAvailable && _speechError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Paste Transcript and mock capture still work without microphone access.',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          TranscriptPreviewCard(
            controller: _transcriptController,
            focusNode: _transcriptFocusNode,
            onChanged: (_) => _handleTranscriptChanged(),
            helperText:
                'Live microphone capture fills this field. Edit the words first, then save to the right local module.',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voice Starter Deck',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'One tap loads a ready-made command to edit, speak, or turn into a prompt.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: templates
                        .map(
                          (template) => Tooltip(
                            message: template.description,
                            child: FilledButton.tonalIcon(
                              key: Key('voiceTemplateButton-${template.id}'),
                              onPressed: () => _applyTemplate(template),
                              icon: Icon(_templateIcon(template.id)),
                              label: Text(template.label),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Command Router', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Based on the current command, here are the next likely moves.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: quickActions
                        .map(
                          (action) => Tooltip(
                            message: action.description,
                            child: OutlinedButton.icon(
                              key: Key('voiceQuickActionButton-${action.id}'),
                              onPressed: () => _handleQuickAction(action),
                              icon: Icon(_quickActionIcon(action.id)),
                              label: Text(action.label),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          if (_suggestion != null) ...[
            const SizedBox(height: 16),
            Card(
              key: const Key('voiceSuggestionCard'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggested Action',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Type: ${_suggestion!.suggestedType.label}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      key: const Key('voiceSuggestedTitleField'),
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (_suggestion!.suggestedProjectName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Project: ${_suggestion!.suggestedProjectName}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    ..._buildStructuredSuggestionLines(theme, _suggestion!),
                    if (_suggestion!.usedExplicitType) ...[
                      const SizedBox(height: 6),
                      Text(
                        'An explicit command prefix was detected in the transcript.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildEditableFields(theme),
                  ],
                ),
              ),
            ),
          ],
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
              FilledButton.icon(
                key: const Key('voiceSaveCommandButton'),
                onPressed: _isSaving
                    ? null
                    : _selectedType == VoiceCommandType.codexPrompt
                    ? _showCodexPrompt
                    : _saveSelectedCommand,
                icon: Icon(
                  _selectedType == VoiceCommandType.codexPrompt
                      ? Icons.code_outlined
                      : Icons.save_outlined,
                ),
                label: Text(
                  _selectedType == VoiceCommandType.codexPrompt
                      ? 'Prepare Codex Prompt'
                      : 'Save as ${_selectedType.label}',
                ),
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
          CommandHistoryList(
            commands: _history,
            onCommandSelected: _restoreCommandFromHistory,
          ),
        ],
      ),
    );
  }

  IconData _templateIcon(String id) {
    switch (id) {
      case 'build-day':
        return Icons.calendar_view_day_outlined;
      case 'task':
        return Icons.task_alt_outlined;
      case 'journal':
        return Icons.menu_book_outlined;
      case 'content':
        return Icons.article_outlined;
      case 'business':
        return Icons.work_outline;
      case 'codex':
        return Icons.code_outlined;
      case 'idea':
        return Icons.lightbulb_outline;
      default:
        return Icons.auto_awesome_outlined;
    }
  }

  IconData _quickActionIcon(String id) {
    switch (id) {
      case 'open-dashboard':
        return Icons.dashboard_outlined;
      case 'open-planner':
        return Icons.event_note_outlined;
      case 'open-tasks':
        return Icons.task_alt_outlined;
      case 'open-journal':
        return Icons.menu_book_outlined;
      case 'open-content':
        return Icons.article_outlined;
      case 'open-business':
        return Icons.work_outline;
      case 'open-projects':
        return Icons.folder_open_outlined;
      case 'open-inbox':
        return Icons.inbox_outlined;
      default:
        return Icons.arrow_forward_outlined;
    }
  }

  List<Widget> _buildStructuredSuggestionLines(
    ThemeData theme,
    VoiceCommandSuggestion suggestion,
  ) {
    final lines = <String>[];

    if (suggestion.suggestedType == VoiceCommandType.task) {
      if (suggestion.extractedTaskCategory != null) {
        lines.add('Category: ${suggestion.extractedTaskCategory}');
      }
      if (suggestion.extractedTaskPriority != null) {
        lines.add('Priority: ${suggestion.extractedTaskPriority}');
      }
    } else if (suggestion.suggestedType == VoiceCommandType.journalEntry) {
      if (suggestion.extractedJournalLearned != null) {
        lines.add('Learned: ${suggestion.extractedJournalLearned}');
      }
      if (suggestion.extractedJournalNextActions != null) {
        lines.add('Next: ${suggestion.extractedJournalNextActions}');
      }
    } else if (suggestion.suggestedType == VoiceCommandType.contentIdea) {
      if (suggestion.extractedContentPlatform != null) {
        lines.add('Platform: ${suggestion.extractedContentPlatform}');
      }
      if (suggestion.extractedContentType != null) {
        lines.add('Content Type: ${suggestion.extractedContentType}');
      }
    } else if (suggestion.suggestedType ==
        VoiceCommandType.businessOpportunity) {
      if (suggestion.extractedBusinessType != null) {
        lines.add('Opportunity Type: ${suggestion.extractedBusinessType}');
      }
      if (suggestion.extractedBusinessContact != null) {
        lines.add('Contact: ${suggestion.extractedBusinessContact}');
      }
      if (suggestion.extractedBusinessStatus != null) {
        lines.add('Status: ${suggestion.extractedBusinessStatus}');
      }
    }

    return lines
        .map(
          (line) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(line, style: theme.textTheme.bodySmall),
          ),
        )
        .toList();
  }

  Widget _buildEditableFields(ThemeData theme) {
    if (_selectedType == VoiceCommandType.task) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Task Details', style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          _buildDropdownField(
            fieldName: 'voiceTaskCategoryField',
            resetToken: _suggestion?.transcript ?? 'empty',
            label: 'Category',
            value: _taskCategoryValue,
            options: _taskCategoryOptions,
            onChanged: (value) => setState(() => _taskCategoryValue = value),
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            fieldName: 'voiceTaskPriorityField',
            resetToken: _suggestion?.transcript ?? 'empty',
            label: 'Priority',
            value: _taskPriorityValue,
            options: _priorityOptions,
            onChanged: (value) => setState(() => _taskPriorityValue = value),
          ),
        ],
      );
    } else if (_selectedType == VoiceCommandType.journalEntry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Journal Details', style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          _buildTextField(
            key: const Key('voiceJournalWorkedOnField'),
            label: 'Worked On',
            controller: _journalWorkedOnController,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            key: const Key('voiceJournalLearnedField'),
            label: 'Learned',
            controller: _journalLearnedController,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            key: const Key('voiceJournalNextActionsField'),
            label: 'Next Actions',
            controller: _journalNextActionsController,
          ),
        ],
      );
    } else if (_selectedType == VoiceCommandType.contentIdea) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Content Details', style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          _buildDropdownField(
            fieldName: 'voiceContentPlatformField',
            resetToken: _suggestion?.transcript ?? 'empty',
            label: 'Platform',
            value: _contentPlatformValue,
            options: _contentPlatformOptions,
            onChanged: (value) => setState(() => _contentPlatformValue = value),
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            fieldName: 'voiceContentTypeField',
            resetToken: _suggestion?.transcript ?? 'empty',
            label: 'Content Type',
            value: _contentTypeValue,
            options: _contentTypeOptions,
            onChanged: (value) => setState(() => _contentTypeValue = value),
          ),
        ],
      );
    } else if (_selectedType == VoiceCommandType.businessOpportunity) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Business Details', style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          _buildDropdownField(
            fieldName: 'voiceBusinessTypeField',
            resetToken: _suggestion?.transcript ?? 'empty',
            label: 'Type',
            value: _businessTypeValue,
            options: _businessTypeOptions,
            onChanged: (value) => setState(() => _businessTypeValue = value),
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            fieldName: 'voiceBusinessStatusField',
            resetToken: _suggestion?.transcript ?? 'empty',
            label: 'Status',
            value: _businessStatusValue,
            options: _businessStatusOptions,
            onChanged: (value) => setState(() => _businessStatusValue = value),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            key: const Key('voiceBusinessContactField'),
            label: 'Company or Contact',
            controller: _businessContactController,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            key: const Key('voiceBusinessNextActionField'),
            label: 'Next Action',
            controller: _businessNextActionController,
          ),
        ],
      );
    } else {
      return Text(
        'This capture type is reviewed as text only.',
        style: theme.textTheme.bodySmall,
      );
    }
  }

  Widget _buildTextField({
    required Key key,
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDropdownField({
    required String fieldName,
    required String resetToken,
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String?>(
      key: ValueKey('$fieldName-$resetToken'),
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text('No $label selected'),
        ),
        ...options.map(
          (option) =>
              DropdownMenuItem<String?>(value: option, child: Text(option)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
