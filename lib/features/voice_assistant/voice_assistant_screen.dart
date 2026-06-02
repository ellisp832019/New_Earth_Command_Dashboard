import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/database/app_database.dart';
import 'application/voice_conversation_dock_controller.dart';
import 'application/voice_ai_assist_controller.dart';
import 'application/voice_session_controller.dart';
import 'ai/voice_ai_assist_service.dart';
import 'voice_command_action_service.dart';
import 'desktop_speech_bridge_service.dart';
import 'voice_command_model.dart';
import 'voice_command_service.dart';
import 'voice_speech_service.dart';
import 'windows_voice_typing_service.dart';
import '../settings/application/settings_controller.dart';
import '../../widgets/calm_guidance_card.dart';
import 'widgets/command_history_list.dart';
import 'widgets/command_type_selector.dart';
import 'widgets/voice_presence_chip.dart';
import 'widgets/transcript_preview_card.dart';
import 'widgets/voice_conversation_thread_card.dart';

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

const _projectStatusOptions = [
  'Idea',
  'Active',
  'Paused',
  'Blocked',
  'Completed',
  'Archived',
];

const _projectPriorityOptions = ['High', 'Medium', 'Low', 'Someday'];

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

enum _VoiceInteractionMode { quick, wizard }

class _VoiceWizardTurn {
  const _VoiceWizardTurn({
    required this.step,
    required this.prompt,
    required this.answer,
    required this.fragment,
  });

  final VoiceWizardStep step;
  final String prompt;
  final String answer;
  final String fragment;
}

class VoiceAssistantScreen extends ConsumerStatefulWidget {
  const VoiceAssistantScreen({
    super.key,
    this.initialTranscript,
    this.initialType,
    this.wakeTriggered = false,
    this.handsfreeTriggered = false,
  });

  final String? initialTranscript;
  final String? initialType;
  final bool wakeTriggered;
  final bool handsfreeTriggered;

  @override
  ConsumerState<VoiceAssistantScreen> createState() =>
      _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen> {
  final VoiceCommandService _service = VoiceCommandService();
  final DesktopSpeechBridgeService _desktopSpeechBridgeService =
      DesktopSpeechBridgeService();
  final SpeechToText _speech = SpeechToText();
  final TextEditingController _transcriptController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _projectVisionController =
      TextEditingController();
  final TextEditingController _projectNextActionController =
      TextEditingController();
  final TextEditingController _projectNotesController = TextEditingController();
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
  final TextEditingController _wizardAnswerController = TextEditingController();
  final FocusNode _transcriptFocusNode = FocusNode();
  final FocusNode _wizardAnswerFocusNode = FocusNode();
  late final VoiceSessionNotifier _voiceSessionNotifier;

  _VoiceInteractionMode _mode = _VoiceInteractionMode.quick;
  VoiceWizardStep _wizardStep = VoiceWizardStep.type;
  final List<_VoiceWizardTurn> _wizardTurns = [];
  VoiceConversationContext? _conversationContext;
  VoiceCommandType? _presetType;
  VoiceCommandType _selectedType = VoiceCommandType.task;
  String? _selectedProjectId;
  List<VoiceCommand> _history = [];
  String? _lastCodexPrompt;
  VoiceCommandSuggestion? _suggestion;
  String? _lastTemplateId;
  String? _taskCategoryValue;
  String? _taskPriorityValue;
  String? _projectStatusValue;
  String? _projectPriorityValue;
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
  bool _wakeAcknowledgeQueued = false;
  bool _wakeAcknowledgePending = false;
  bool _wakeAcknowledgeSpoken = false;
  bool _wakeAutoListenQueued = false;
  bool _handsfreeSessionActive = false;

  @override
  void initState() {
    super.initState();
    _voiceSessionNotifier = ref.read(voiceSessionProvider.notifier);
    _history = _service.getHistory();
    _transcriptController.addListener(_handleTranscriptChanged);
    _applyInitialTranscript(widget.initialTranscript);
    final initialType = parseVoiceCommandType(widget.initialType);
    if (initialType != null) {
      _presetType = initialType;
      _selectedType = initialType;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        setState(() {
          _selectedType = initialType;
        });
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _voiceSessionNotifier.beginAwaitingFollowUp(
        owner: VoiceSessionOwner.assistant,
        label: 'Gaia ready',
        detail: 'Review before saving',
        opacity: 0.64,
      );
      ref.read(voiceConversationDockProvider.notifier).hide();
    });
    if (widget.wakeTriggered || widget.handsfreeTriggered) {
      _speechStatus = widget.wakeTriggered
          ? 'Wake phrase heard. Tell me what to create, open, summarize, or continue.'
          : 'Handsfree capture heard. Tell me what to create, open, summarize, or continue.';
      _wakeAcknowledgePending = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        _voiceSessionNotifier.beginAwaitingFollowUp(
          owner: VoiceSessionOwner.assistant,
          label: 'Gaia ready',
          detail: widget.wakeTriggered
              ? 'Wake phrase heard'
              : 'Handsfree capture heard',
          opacity: 0.64,
        );
        _transcriptFocusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant VoiceAssistantScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTranscript != oldWidget.initialTranscript) {
      _applyInitialTranscript(widget.initialTranscript);
    }
    if (widget.initialType != oldWidget.initialType) {
      final initialType = parseVoiceCommandType(widget.initialType);
      if (initialType != null) {
        _presetType = initialType;
        _selectedType = initialType;
      } else {
        _presetType = null;
      }
    }
    if ((widget.wakeTriggered || widget.handsfreeTriggered) &&
        !(oldWidget.wakeTriggered || oldWidget.handsfreeTriggered)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        ref.read(voiceConversationDockProvider.notifier).hide();
      });
      _speechStatus = widget.wakeTriggered
          ? 'Wake phrase heard. Tell me what to create, open, summarize, or continue.'
          : 'Handsfree capture heard. Tell me what to create, open, summarize, or continue.';
      ref
          .read(voiceSessionProvider.notifier)
          .beginAwaitingFollowUp(
            owner: VoiceSessionOwner.assistant,
            label: 'Gaia ready',
            detail: widget.wakeTriggered
                ? 'Wake phrase heard'
                : 'Handsfree capture heard',
            opacity: 0.64,
          );
      _wakeAcknowledgePending = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        _transcriptFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    _transcriptController.removeListener(_handleTranscriptChanged);
    _transcriptController.dispose();
    _titleController.dispose();
    _projectVisionController.dispose();
    _projectNextActionController.dispose();
    _projectNotesController.dispose();
    _journalWorkedOnController.dispose();
    _journalLearnedController.dispose();
    _journalNextActionsController.dispose();
    _businessContactController.dispose();
    _businessNextActionController.dispose();
    _wizardAnswerController.dispose();
    _transcriptFocusNode.dispose();
    _wizardAnswerFocusNode.dispose();
    super.dispose();
  }

  void _applyInitialTranscript(String? transcript) {
    final cleanedTranscript = transcript?.trim() ?? '';
    if (cleanedTranscript.isEmpty) {
      return;
    }

    _transcriptController.text = cleanedTranscript;
    _transcriptController.selection = TextSelection.collapsed(
      offset: _transcriptController.text.length,
    );
    _speechStatus = 'Handsfree capture loaded. Review before saving.';
  }

  void _queueWakeAcknowledge() {
    if (_wakeAcknowledgeQueued || _wakeAcknowledgeSpoken) {
      return;
    }

    _wakeAcknowledgeQueued = true;
    unawaited(() async {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted || (!widget.wakeTriggered && !widget.handsfreeTriggered)) {
        return;
      }

      _wakeAcknowledgeSpoken = true;
      await _speakWakeAcknowledge();
    }());
  }

  Future<void> _speakWakeAcknowledge() async {
    ref
        .read(voiceSessionProvider.notifier)
        .beginSpeaking(
          owner: VoiceSessionOwner.assistant,
          label: 'Gaia speaking',
          detail: 'Answering the wake phrase',
          opacity: 0.72,
        );
    await _speakWithCurrentVoice(
      "I'm here. You can ask me what I can do, or say create a task, create a project, summarize today, or continue the thread.",
    );

    if (!mounted ||
        (!(widget.wakeTriggered || widget.handsfreeTriggered)) ||
        _wakeAutoListenQueued) {
      return;
    }

    _wakeAutoListenQueued = true;
    unawaited(() async {
      await Future<void>.delayed(const Duration(milliseconds: 750));
      if (!mounted || (!widget.wakeTriggered && !widget.handsfreeTriggered)) {
        return;
      }

      await _startHandsfreeConversationSession();
    }());
  }

  void _handleTranscriptChanged() {
    final transcript = _transcriptController.text.trim();

    if (transcript.isEmpty) {
      if (!mounted) {
        return;
      }

      setState(() {
        _presetType = null;
        _suggestion = null;
        _selectedType = VoiceCommandType.task;
        _selectedProjectId = null;
        _taskCategoryValue = null;
        _taskPriorityValue = null;
        _projectStatusValue = null;
        _projectPriorityValue = null;
        _contentPlatformValue = null;
        _contentTypeValue = null;
        _businessTypeValue = null;
        _businessStatusValue = null;
        _titleController.clear();
        _projectVisionController.clear();
        _projectNextActionController.clear();
        _projectNotesController.clear();
        _journalWorkedOnController.clear();
        _journalLearnedController.clear();
        _journalNextActionsController.clear();
        _businessContactController.clear();
        _businessNextActionController.clear();
      });
      if (_mode == _VoiceInteractionMode.wizard) {
        _resetWizardDraft(keepMode: true);
      }
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
      _selectedType = _presetType ?? suggestion.suggestedType;
      _selectedProjectId = suggestion.suggestedProjectId;
      _titleController.text = suggestion.suggestedTitle;
      _taskCategoryValue = suggestion.extractedTaskCategory;
      _taskPriorityValue = suggestion.extractedTaskPriority;
      _projectStatusValue = suggestion.extractedProjectStatus;
      _projectPriorityValue = suggestion.extractedProjectPriority;
      _projectVisionController.text = suggestion.extractedProjectVision ?? '';
      _projectNextActionController.text =
          suggestion.extractedProjectNextAction ?? '';
      _projectNotesController.text = suggestion.extractedProjectNotes ?? '';
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

  VoiceCommandAssistantResponse? _buildWakeAssistantResponse() {
    if (!(widget.wakeTriggered || widget.handsfreeTriggered)) {
      return null;
    }

    return VoiceCommandAssistantResponse(
      summary: widget.wakeTriggered
          ? 'I am here and ready to help. You can ask me what I can do, create a task, create a project, summarize today, or continue the thread.'
          : 'I heard you and I am here to help. You can ask me what I can do, create a task, create a project, summarize today, or continue the thread.',
      nextStep:
          'Speak your next command and I will shape it into the right local action.',
      threadContext: _conversationContext == null
          ? null
          : 'You have a remembered thread ready to continue.',
    );
  }

  VoiceCommandBriefing? _buildWakeBriefing(
    VoiceCommandAssistantResponse? wakeResponse,
  ) {
    if (wakeResponse == null) {
      return null;
    }

    return VoiceCommandBriefing(
      summary: wakeResponse.summary,
      nextStep: wakeResponse.nextStep,
      threadContext: wakeResponse.threadContext,
      projectContext: wakeResponse.projectContext,
      actions: _service
          .suggestQuickActions(
            transcript: 'hey gaia',
            suggestion: VoiceCommandSuggestion(
              transcript: 'hey gaia',
              suggestedType: VoiceCommandType.task,
              suggestedTitle: 'Hey Gaia',
              usedWakePhrase: true,
            ),
            conversationContext: _conversationContext,
          )
          .take(3)
          .toList(),
    );
  }

  TextEditingController get _activeSpeechController {
    return _mode == _VoiceInteractionMode.wizard
        ? _wizardAnswerController
        : _transcriptController;
  }

  VoiceCommandType get _currentType => _presetType ?? _selectedType;

  FocusNode get _activeSpeechFocusNode {
    return _mode == _VoiceInteractionMode.wizard
        ? _wizardAnswerFocusNode
        : _transcriptFocusNode;
  }

  String _wizardPrompt() {
    final projectName = _suggestion?.suggestedProjectName;
    return _service.buildWizardPrompt(
      step: _wizardStep,
      selectedType: _selectedType,
      projectName: projectName,
      conversationContext: _conversationContext,
    );
  }

  void _setVoiceMode(_VoiceInteractionMode mode) {
    if (_mode == mode) {
      return;
    }

    setState(() {
      _mode = mode;
      if (mode == _VoiceInteractionMode.wizard) {
        _resetWizardDraft(keepMode: true);
      }
    });
  }

  void _resetWizardDraft({required bool keepMode, bool preserveThread = true}) {
    _wizardTurns.clear();
    if (!preserveThread) {
      _conversationContext = null;
    }
    final hasThreadMemory =
        preserveThread &&
        _conversationContext != null &&
        _conversationContext!.hasMemory;
    _wizardStep = hasThreadMemory && _conversationContext!.type != null
        ? VoiceWizardStep.title
        : VoiceWizardStep.type;
    _selectedType = hasThreadMemory && _conversationContext!.type != null
        ? _conversationContext!.type!
        : VoiceCommandType.task;
    _selectedProjectId = hasThreadMemory
        ? _conversationContext?.projectId
        : null;
    _suggestion = null;
    _transcriptController.clear();
    _wizardAnswerController.clear();
    _speechStatus = hasThreadMemory
        ? 'Wizard reset. Continuing the current thread.'
        : 'Wizard reset. Ready for a new guided exchange.';
    if (!keepMode) {
      _mode = _VoiceInteractionMode.quick;
    }
  }

  String _buildWizardDraftTranscript() {
    return _wizardTurns.map((turn) => turn.fragment).join(' ');
  }

  VoiceCommandType _inferWizardTypeFromAnswer(String answer) {
    final suggestion = _service.suggestCommand(transcript: answer);
    return suggestion.suggestedType;
  }

  String _wizardConversationSummary() {
    final threadSummary = _conversationContext?.summary;
    final threadSummaryParts = threadSummary == null
        ? null
        : <String>[threadSummary];

    if (_wizardTurns.isEmpty && threadSummary == null) {
      return 'We will build the entry one answer at a time.';
    }

    final parts = <String>[
      ...?threadSummaryParts,
      ..._wizardTurns.map((turn) => '${turn.prompt} ${turn.answer}'),
    ];

    return parts.join(' ');
  }

  Future<void> _submitWizardAnswer() async {
    final answer = _wizardAnswerController.text.trim();
    if (answer.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add an answer first.')));
      return;
    }

    final prompt = _wizardPrompt();
    final resolvedType = _wizardStep == VoiceWizardStep.type
        ? _inferWizardTypeFromAnswer(answer)
        : _selectedType;
    final fragment = _service.buildWizardTranscriptPiece(
      step: _wizardStep,
      answer: answer,
      selectedType: resolvedType,
    );

    setState(() {
      if (_wizardStep == VoiceWizardStep.type) {
        _selectedType = resolvedType;
      }

      _wizardTurns.add(
        _VoiceWizardTurn(
          step: _wizardStep,
          prompt: prompt,
          answer: answer,
          fragment: fragment,
        ),
      );
      _wizardAnswerController.clear();
      _wizardStep = switch (_wizardStep) {
        VoiceWizardStep.type => VoiceWizardStep.title,
        VoiceWizardStep.title => VoiceWizardStep.project,
        VoiceWizardStep.project => VoiceWizardStep.details,
        VoiceWizardStep.details => VoiceWizardStep.review,
        VoiceWizardStep.review => VoiceWizardStep.review,
      };
      _transcriptController.text = _buildWizardDraftTranscript();
      _transcriptController.selection = TextSelection.collapsed(
        offset: _transcriptController.text.length,
      );
      _speechStatus = _wizardStep == VoiceWizardStep.review
          ? 'Wizard draft ready. Review the assembled transcript before saving.'
          : 'Wizard answer saved. Keep going with the next question.';
    });

    if (_wizardStep != VoiceWizardStep.review) {
      _wizardAnswerFocusNode.requestFocus();
    }
  }

  void _wizardBack() {
    if (_wizardTurns.isEmpty) {
      return;
    }

    final removedTurn = _wizardTurns.removeLast();
    setState(() {
      _wizardStep = removedTurn.step;
      _wizardAnswerController.clear();
      _transcriptController.text = _buildWizardDraftTranscript();
      _transcriptController.selection = TextSelection.collapsed(
        offset: _transcriptController.text.length,
      );
      _speechStatus =
          'Wizard stepped back. Answer the previous question again.';
    });

    _wizardAnswerFocusNode.requestFocus();
  }

  Future<void> _startListening({bool preferDesktopBridge = true}) async {
    final session = ref.read(voiceSessionProvider.notifier);
    if (!session.beginListening(
      owner: VoiceSessionOwner.assistant,
      label: 'Gaia listening',
      detail: 'Preparing microphone',
      opacity: 0.72,
    )) {
      if (!mounted) {
        return;
      }

      setState(() {
        _speechStatus = 'Another voice session is already active.';
      });
      return;
    }

    _setVoicePresence(
      label: 'Gaia listening',
      detail: 'Preparing microphone',
      isActive: true,
      opacity: 0.72,
    );

    if (WindowsVoiceTypingService.isSupported) {
      await _startWindowsDesktopCapture(
        preferDesktopBridge: preferDesktopBridge,
      );
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
      session.release(
        owner: VoiceSessionOwner.assistant,
        label: 'Gaia idle',
        detail: 'Microphone unavailable',
      );
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
    _setVoicePresence(
      label: 'Gaia listening',
      detail: 'Speak your next command',
      isActive: true,
      opacity: 0.84,
    );
  }

  Future<void> _startWindowsDesktopCapture({
    required bool preferDesktopBridge,
  }) async {
    final session = ref.read(voiceSessionProvider.notifier);

    setState(() {
      _speechError = null;
      _isInitializingSpeech = true;
      _speechStatus = preferDesktopBridge
          ? 'Listening with Gaia. Speak your next command...'
          : 'Arming microphone for conversation...';
      _speechAvailable = true;
      _isListening = true;
    });

    Future<bool> startWindowsTyping() async {
      _activeSpeechFocusNode.requestFocus();
      final available = await WindowsVoiceTypingService.startVoiceTyping();

      if (!mounted) {
        return false;
      }

      setState(() {
        _speechAvailable = available;
        _isInitializingSpeech = false;
        _isListening = available;
        _speechStatus = available
            ? 'Microphone armed. Speak your next command.'
            : 'Desktop speech bridge could not capture a transcript right now.';
        _speechError = available
            ? null
            : 'Try Win + H, or use Paste Transcript if Windows dictation is unavailable.';
      });
      if (available) {
        session.beginListening(
          owner: VoiceSessionOwner.assistant,
          label: 'Gaia listening',
          detail: 'Speak your next command',
          opacity: 0.82,
        );
      } else {
        session.release(
          owner: VoiceSessionOwner.assistant,
          label: 'Gaia idle',
          detail: 'Mic not available',
        );
      }

      return available;
    }

    if (!preferDesktopBridge) {
      final available = await startWindowsTyping();
      if (available) {
        return;
      }
    }

    final capture = await _desktopSpeechBridgeService.captureOnce();

    if (!mounted) {
      return;
    }

    if (capture != null && capture.transcript.trim().isNotEmpty) {
      setState(() {
        _speechAvailable = true;
        _isInitializingSpeech = false;
        _isListening = false;
        _activeSpeechController.text = capture.transcript.trim();
        _activeSpeechController.selection = TextSelection.collapsed(
          offset: _activeSpeechController.text.length,
        );
        _speechStatus =
            'I heard you. Review the transcript or ask for the next step.';
        _speechError = null;
      });
      session.beginProcessing(
        owner: VoiceSessionOwner.assistant,
        label: 'Gaia captured',
        detail: 'Review transcript',
        opacity: 0.82,
      );
      return;
    }

    final available = await startWindowsTyping();
    if (!available) {
      session.release(
        owner: VoiceSessionOwner.assistant,
        label: 'Gaia idle',
        detail: 'Mic not available',
      );
    }
  }

  Future<void> _startHandsfreeConversationSession() async {
    if (_handsfreeSessionActive || !mounted) {
      return;
    }

    final session = ref.read(voiceSessionProvider.notifier);
    if (!session.beginListening(
      owner: VoiceSessionOwner.assistant,
      label: 'Gaia listening',
      detail: 'Handsfree conversation',
      opacity: 0.84,
    )) {
      _handsfreeSessionActive = false;
      if (mounted) {
        setState(() {
          _speechStatus = 'Another voice session is already active.';
        });
      }
      return;
    }

    _handsfreeSessionActive = true;
    _wakeAutoListenQueued = true;
    await ref.read(voiceAssistantSpeechServiceProvider).stop();
    setState(() {
      _speechStatus = 'Handsfree mode is listening. Speak naturally.';
    });

    while (mounted &&
        _handsfreeSessionActive &&
        (widget.wakeTriggered || widget.handsfreeTriggered)) {
      final capture = await _desktopSpeechBridgeService.captureOnce(
        timeout: const Duration(seconds: 30),
        durationSeconds: 8,
      );

      if (!mounted || !_handsfreeSessionActive) {
        break;
      }

      final transcript = capture?.transcript.trim() ?? '';
      if (transcript.isEmpty) {
        session.beginListening(
          owner: VoiceSessionOwner.assistant,
          label: 'Gaia listening',
          detail: 'Waiting for speech',
          opacity: 0.72,
        );
        continue;
      }

      setState(() {
        _activeSpeechController.text = transcript;
        _activeSpeechController.selection = TextSelection.collapsed(
          offset: _activeSpeechController.text.length,
        );
        _speechAvailable = true;
        _isInitializingSpeech = false;
        _isListening = false;
        _speechStatus =
            'I heard you. Review the transcript or keep the conversation going.';
        _speechError = null;
      });
      session.beginProcessing(
        owner: VoiceSessionOwner.assistant,
        label: 'Gaia captured',
        detail: 'Conversation transcript',
        opacity: 0.84,
      );

      await Future<void>.delayed(const Duration(milliseconds: 600));
    }

    if (!mounted) {
      return;
    }

    _handsfreeSessionActive = false;
    session.release(
      owner: VoiceSessionOwner.assistant,
      label: 'Gaia idle',
      detail: 'Ready when you are',
    );
  }

  Future<void> _stopListening() async {
    _handsfreeSessionActive = false;
    if (WindowsVoiceTypingService.isSupported) {
      _activeSpeechFocusNode.requestFocus();
      if (!mounted) {
        return;
      }

      setState(() {
        _isListening = false;
        _speechStatus =
            'Dictation ready to review. If Windows voice typing is still open, press Win + H to close it.';
      });
      ref
          .read(voiceSessionProvider.notifier)
          .release(
            owner: VoiceSessionOwner.assistant,
            label: 'Gaia idle',
            detail: 'Reviewing dictation',
          );
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
    ref
        .read(voiceSessionProvider.notifier)
        .release(
          owner: VoiceSessionOwner.assistant,
          label: 'Gaia idle',
          detail: 'Stopped listening',
        );
  }

  Future<void> _cancelListening() async {
    _handsfreeSessionActive = false;
    if (WindowsVoiceTypingService.isSupported) {
      _activeSpeechFocusNode.requestFocus();
      if (!mounted) {
        return;
      }

      setState(() {
        _isListening = false;
        _speechStatus =
            'Dictation cancelled in the app. If Windows voice typing is still open, press Win + H to close it.';
      });
      _setVoicePresence(
        label: 'Gaia idle',
        detail: 'Listening cancelled',
        isActive: false,
        opacity: 0.28,
      );
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
    ref
        .read(voiceSessionProvider.notifier)
        .release(
          owner: VoiceSessionOwner.assistant,
          label: 'Gaia idle',
          detail: 'Capture cancelled',
        );
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) {
      return;
    }

    setState(() {
      _activeSpeechController.text = result.recognizedWords;
      _activeSpeechController.selection = TextSelection.collapsed(
        offset: _activeSpeechController.text.length,
      );
      if (result.finalResult) {
        _isListening = false;
        _speechStatus = _mode == _VoiceInteractionMode.wizard
            ? 'Wizard answer captured. Use the answer to continue.'
            : 'Transcript captured. Review before saving.';
      }
    });
    if (result.finalResult) {
      _setVoicePresence(
        label: 'Gaia captured',
        detail: 'Review transcript',
        isActive: true,
        opacity: 0.82,
      );
    }
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
    _setVoicePresence(
      label: 'Gaia idle',
      detail: 'Speech paused',
      isActive: false,
      opacity: 0.28,
    );
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

    if (_mode == _VoiceInteractionMode.wizard &&
        _wizardStep != VoiceWizardStep.review) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finish the wizard before saving.')),
      );
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
            type: _currentType,
            projectId: _selectedProjectId,
            titleOverride: _titleController.text.trim(),
            suggestion: editableSuggestion,
          );
      _service.addCommand(transcript: transcript, type: _currentType);
      _rememberConversationThread(
        transcript: editableSuggestion?.transcript ?? transcript,
        type: _currentType,
        title: _titleController.text.trim().isEmpty
            ? _service.suggestCommand(transcript: transcript).suggestedTitle
            : _titleController.text.trim(),
        projectId: _selectedProjectId,
        projectName: editableSuggestion?.suggestedProjectName,
        continueExistingThread: true,
      );

      setState(() {
        _history = _service.getHistory();
        _lastCodexPrompt = null;
        _suggestion = null;
        _presetType = null;
        _taskCategoryValue = null;
        _taskPriorityValue = null;
        _projectStatusValue = null;
        _projectPriorityValue = null;
        _contentPlatformValue = null;
        _contentTypeValue = null;
        _businessTypeValue = null;
        _businessStatusValue = null;
        _titleController.clear();
        _projectVisionController.clear();
        _projectNextActionController.clear();
        _projectNotesController.clear();
        _journalWorkedOnController.clear();
        _journalLearnedController.clear();
        _journalNextActionsController.clear();
        _businessContactController.clear();
        _businessNextActionController.clear();
        _transcriptController.clear();
        _speechStatus =
            'Saved. Ready for another capture. The current thread is still available.';
      });
      _setVoicePresence(
        label: 'Gaia ready',
        detail: 'Saved and ready',
        isActive: false,
        opacity: 0.32,
      );

      unawaited(
        _speakWithCurrentVoice(
          'Saved as ${_currentType.label}. Ready for another capture.',
        ),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saved as ${_currentType.label} in the local dashboard data.',
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
      _activeSpeechController.text = text;
      _activeSpeechController.selection = TextSelection.collapsed(
        offset: text.length,
      );
      _speechStatus = _mode == _VoiceInteractionMode.wizard
          ? 'Wizard answer pasted. Submit it to continue.'
          : 'Transcript pasted. Review before saving.';
    });
    _setVoicePresence(
      label: 'Gaia ready',
      detail: 'Transcript pasted',
      isActive: false,
      opacity: 0.32,
    );
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
    _setVoicePresence(
      label: 'Gaia ready',
      detail: 'Codex prompt prepared',
      isActive: false,
      opacity: 0.32,
    );

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
      _activeSpeechController.text =
          'Capture a task to review the voice bridge scaffold and prepare the next safe dashboard step.';
      _activeSpeechController.selection = TextSelection.collapsed(
        offset: _activeSpeechController.text.length,
      );
      _speechStatus = _mode == _VoiceInteractionMode.wizard
          ? 'Mock wizard answer loaded. Submit it to continue.'
          : 'Mock transcript loaded. Review before saving.';
    });
  }

  void _applyTemplate(VoiceCommandTemplate template) {
    final suggestion = _service.suggestCommand(transcript: template.transcript);
    setState(() {
      _suggestion = suggestion;
      _selectedType = template.type;
      _lastTemplateId = template.id;
      _transcriptController.text = template.transcript;
      _transcriptController.selection = TextSelection.collapsed(
        offset: template.transcript.length,
      );
      _selectedProjectId = suggestion.suggestedProjectId;
      _rememberConversationThread(
        transcript: template.transcript,
        type: template.type,
        title: suggestion.suggestedTitle,
        projectId: suggestion.suggestedProjectId,
        projectName: suggestion.suggestedProjectName,
      );
      _speechStatus = 'Template loaded. Review before saving.';
    });
    _setVoicePresence(
      label: 'Gaia ready',
      detail: 'Template loaded',
      isActive: false,
      opacity: 0.32,
    );
    _transcriptFocusNode.requestFocus();
  }

  void _restoreCommandFromHistory(VoiceCommand command) {
    final suggestion = _service.suggestCommand(transcript: command.transcript);
    setState(() {
      _selectedType = command.type;
      _lastTemplateId = null;
      _transcriptController.text = command.transcript;
      _transcriptController.selection = TextSelection.collapsed(
        offset: command.transcript.length,
      );
      _selectedProjectId = suggestion.suggestedProjectId;
      _rememberConversationThread(
        transcript: command.transcript,
        type: command.type,
        title: suggestion.suggestedTitle,
        projectId: suggestion.suggestedProjectId,
        projectName: suggestion.suggestedProjectName,
      );
      _speechStatus = 'History item loaded. Review before saving.';
    });
    _setVoicePresence(
      label: 'Gaia ready',
      detail: 'History item loaded',
      isActive: false,
      opacity: 0.32,
    );
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
      return;
    }

    if (action.id == 'continue-thread') {
      _continueCurrentThread();
    }
  }

  void _loadLatestTemplate() {
    final templates = _service.getTemplates();
    if (templates.isEmpty) {
      return;
    }

    _applyTemplate(templates.first);
  }

  void _repeatLastTemplate() {
    final lastTemplateId = _lastTemplateId;
    if (lastTemplateId == null) {
      _loadLatestTemplate();
      return;
    }

    final template = _service.getTemplateById(lastTemplateId);
    if (template == null) {
      _loadLatestTemplate();
      return;
    }

    _applyTemplate(template);
  }

  void _rememberConversationThread({
    required String transcript,
    required VoiceCommandType type,
    String? title,
    String? projectId,
    String? projectName,
    bool continueExistingThread = false,
  }) {
    _conversationContext = _service.buildConversationContext(
      transcript: transcript,
      type: type,
      title: title,
      projectId: projectId,
      projectName: projectName,
      previous: continueExistingThread ? _conversationContext : null,
    );
  }

  void _continueCurrentThread() {
    final conversationContext = _conversationContext;
    if (conversationContext == null) {
      return;
    }

    setState(() {
      _mode = _VoiceInteractionMode.wizard;
      _selectedType = conversationContext.type ?? _selectedType;
      _selectedProjectId = conversationContext.projectId;
      _wizardTurns.clear();
      _wizardAnswerController.clear();
      _wizardStep = conversationContext.type == null
          ? VoiceWizardStep.type
          : VoiceWizardStep.title;
      _speechStatus =
          'Continuing the current voice thread. Start the next step here.';
    });
    _setVoicePresence(
      label: 'Gaia thread',
      detail: 'Continuing voice conversation',
      isActive: true,
      opacity: 0.74,
    );
    _wizardAnswerFocusNode.requestFocus();
    unawaited(
      _speakWithCurrentVoice(
        'Continuing the current thread. ${conversationContext.summary}',
      ),
    );
  }

  void _startNewThread() {
    setState(() {
      _conversationContext = null;
      _resetWizardDraft(keepMode: true, preserveThread: false);
      _speechStatus = 'Started a fresh voice thread.';
    });
    _setVoicePresence(
      label: 'Gaia ready',
      detail: 'Started a fresh thread',
      isActive: false,
      opacity: 0.32,
    );
    _wizardAnswerFocusNode.requestFocus();
  }

  Future<void> _copyConversationSummary() async {
    final conversationContext = _conversationContext;
    if (conversationContext == null) {
      return;
    }

    final parts = <String>[
      'Thread: ${conversationContext.label}',
      'Summary: ${conversationContext.summary}',
      if (conversationContext.projectName != null &&
          conversationContext.projectName!.isNotEmpty)
        'Project: ${conversationContext.projectName}',
      if (conversationContext.title != null &&
          conversationContext.title!.isNotEmpty)
        'Latest: ${conversationContext.title}',
    ];

    await Clipboard.setData(ClipboardData(text: parts.join('\n')));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied remembered thread summary.')),
    );
  }

  VoiceTtsVoiceOption? _resolveSelectedVoice(
    List<VoiceTtsVoiceOption> voices,
    AppSetting settings,
  ) {
    for (final voice in voices) {
      if (voice.name == settings.preferredTtsVoiceName &&
          voice.locale == settings.preferredTtsVoiceLocale &&
          voice.gender == settings.preferredTtsVoiceGender &&
          voice.identifier == settings.preferredTtsVoiceIdentifier) {
        return voice;
      }
    }
    return null;
  }

  Future<void> _speakWithCurrentVoice(String text) async {
    final settingsSnapshot = ref
        .read(settingsSnapshotProvider)
        .maybeWhen(data: (snapshot) => snapshot, orElse: () => null);
    if (settingsSnapshot == null) {
      return;
    }

    try {
      ref
          .read(voiceSessionProvider.notifier)
          .beginSpeaking(
            owner: VoiceSessionOwner.assistant,
            label: 'Gaia speaking',
            detail: 'Reading back the current response',
            opacity: 0.72,
          );
      final voices = await ref.read(voiceAssistantVoicesProvider.future);
      final selectedVoice = _resolveSelectedVoice(
        voices,
        settingsSnapshot.settings,
      );
      await ref
          .read(voiceAssistantSpeechServiceProvider)
          .speak(
            text,
            enabled: settingsSnapshot.settings.voiceRepliesEnabled,
            rate: settingsSnapshot.settings.preferredTtsVoiceRate,
            pitch: settingsSnapshot.settings.preferredTtsVoicePitch,
            voice: selectedVoice,
          );
      ref
          .read(voiceSessionProvider.notifier)
          .beginAwaitingFollowUp(
            owner: VoiceSessionOwner.assistant,
            label: 'Gaia ready',
            detail: 'Waiting for your next command',
            opacity: 0.64,
          );
    } catch (_) {
      // Voice output is best-effort. The transcript flow still works if TTS fails.
    }
  }

  void _setVoicePresence({
    required String label,
    required String detail,
    required bool isActive,
    required double opacity,
  }) {
    ref
        .read(voiceSessionProvider.notifier)
        .updatePresence(
          label: label,
          detail: detail,
          isActive: isActive,
          opacity: opacity,
        );
  }

  Future<void> _stopSpeaking() async {
    await ref.read(voiceAssistantSpeechServiceProvider).stop();
    ref
        .read(voiceSessionProvider.notifier)
        .updatePresence(
          label: 'Gaia ready',
          detail: 'Voice output stopped',
          isActive: true,
          opacity: 0.64,
        );
  }

  VoiceCommandSuggestion? _buildEditableSuggestion() {
    final suggestion = _presetType != null
        ? _buildPresetSuggestion()
        : _suggestion ?? _buildPresetSuggestion();
    if (suggestion == null) {
      return null;
    }

    final journalWorkedOn = _journalWorkedOnController.text.trim();
    final journalLearned = _journalLearnedController.text.trim();
    final journalNextActions = _journalNextActionsController.text.trim();
    final projectVision = _projectVisionController.text.trim();
    final projectNextAction = _projectNextActionController.text.trim();
    final projectNotes = _projectNotesController.text.trim();
    final businessContact = _businessContactController.text.trim();
    final businessNextAction = _businessNextActionController.text.trim();

    return VoiceCommandSuggestion(
      transcript: suggestion.transcript,
      suggestedType: _presetType ?? _selectedType,
      suggestedTitle: _titleController.text.trim(),
      extractedTaskCategory: _taskCategoryValue,
      extractedTaskPriority: _taskPriorityValue,
      extractedProjectStatus: _projectStatusValue,
      extractedProjectPriority: _projectPriorityValue,
      extractedProjectVision: projectVision.isEmpty ? null : projectVision,
      extractedProjectNextAction: projectNextAction.isEmpty
          ? null
          : projectNextAction,
      extractedProjectNotes: projectNotes.isEmpty ? null : projectNotes,
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

  VoiceCommandSuggestion? _buildPresetSuggestion() {
    final initialType = parseVoiceCommandType(widget.initialType);
    if (initialType == null) {
      return null;
    }

    final transcript = _transcriptController.text.trim();
    return VoiceCommandSuggestion(
      transcript: transcript,
      suggestedType: initialType,
      suggestedTitle: transcript.isEmpty
          ? '${initialType.label} capture'
          : transcript,
      usedExplicitType: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectOptions = ref.watch(voiceAssistantProjectOptionsProvider);
    final settingsSnapshotAsync = ref.watch(settingsSnapshotProvider);
    final settingsSnapshot = settingsSnapshotAsync.maybeWhen(
      data: (snapshot) => snapshot,
      orElse: () => null,
    );

    if ((widget.wakeTriggered || widget.handsfreeTriggered) &&
        _wakeAcknowledgePending &&
        settingsSnapshot != null &&
        !_wakeAcknowledgeQueued &&
        !_wakeAcknowledgeSpoken) {
      _wakeAcknowledgePending = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || (!widget.wakeTriggered && !widget.handsfreeTriggered)) {
          return;
        }

        _queueWakeAcknowledge();
      });
    }

    final templates = _service.getTemplates();
    final templateById = {
      for (final template in templates) template.id: template,
    };
    final conversationContext = _conversationContext;
    final presetSuggestion = _buildPresetSuggestion();
    final activeSuggestion = _presetType != null
        ? presetSuggestion
        : _suggestion ?? presetSuggestion;
    final quickActions = _service.suggestQuickActions(
      transcript: _transcriptController.text,
      suggestion: activeSuggestion,
      conversationContext: conversationContext,
    );
    final assistantResponse =
        _transcriptController.text.trim().isEmpty && activeSuggestion == null
        ? _buildWakeAssistantResponse()
        : _service.buildAssistantResponse(
            transcript: _transcriptController.text,
            suggestion: activeSuggestion,
            conversationContext: conversationContext,
          );
    final briefing =
        _transcriptController.text.trim().isEmpty && activeSuggestion == null
        ? _buildWakeBriefing(_buildWakeAssistantResponse())
        : _service.buildBriefing(
            transcript: _transcriptController.text,
            suggestion: activeSuggestion,
            conversationContext: conversationContext,
          );
    final macroActions = _service.buildMacroActions(
      conversationContext: conversationContext,
    );
    final wizardPrompt = _mode == _VoiceInteractionMode.wizard
        ? _wizardPrompt()
        : null;
    final wizardSummary = _mode == _VoiceInteractionMode.wizard
        ? _wizardConversationSummary()
        : null;
    final aiAssistRequest = VoiceAiAssistRequest(
      transcript: _mode == _VoiceInteractionMode.wizard
          ? _wizardAnswerController.text
          : _transcriptController.text,
      prompt: wizardPrompt,
      selectedType: _currentType,
      wizardStep: _mode == _VoiceInteractionMode.wizard ? _wizardStep : null,
      conversationContext: conversationContext,
    );
    final aiAssistAsync = ref.watch(
      voiceAiBriefingAssistProvider(aiAssistRequest),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              child: IgnorePointer(child: VoicePresenceChip(compact: true)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Speak, review, and turn your words into dashboard actions.',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _mode == _VoiceInteractionMode.wizard
                ? 'Answer one question at a time and let the wizard assemble the draft for review.'
                : 'Speak naturally or press Start Listening, review the transcript, then choose where it belongs before anything is saved.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          SegmentedButton<_VoiceInteractionMode>(
            segments: const [
              ButtonSegment(
                value: _VoiceInteractionMode.quick,
                label: Text('Quick Capture'),
                icon: Icon(Icons.flash_on_outlined),
              ),
              ButtonSegment(
                value: _VoiceInteractionMode.wizard,
                label: Text('Wizard'),
                icon: Icon(Icons.auto_fix_high_outlined),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) {
              _setVoiceMode(selection.first);
            },
          ),
          const SizedBox(height: 20),
          if (conversationContext != null) ...[
            VoiceConversationThreadCard(
              conversationContext: conversationContext,
              onResumeThread: _continueCurrentThread,
              onStartFresh: _startNewThread,
              onCopySummary: _copyConversationSummary,
            ),
            const SizedBox(height: 16),
          ],
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
          if (_mode == _VoiceInteractionMode.wizard) ...[
            const SizedBox(height: 16),
            Card(
              key: const Key('voiceWizardCard'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Voice Wizard', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      wizardPrompt ?? 'Let us build this one answer at a time.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('voiceWizardAnswerField'),
                      controller: _wizardAnswerController,
                      focusNode: _wizardAnswerFocusNode,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Wizard answer',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _submitWizardAnswer(),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          key: const Key('voiceWizardNextButton'),
                          onPressed: _submitWizardAnswer,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Use Answer'),
                        ),
                        TextButton.icon(
                          key: const Key('voiceWizardBackButton'),
                          onPressed: _wizardTurns.isEmpty ? null : _wizardBack,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back'),
                        ),
                        TextButton.icon(
                          key: const Key('voiceWizardResetButton'),
                          onPressed: () => _resetWizardDraft(keepMode: true),
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('Reset'),
                        ),
                      ],
                    ),
                    if (wizardSummary != null) ...[
                      const SizedBox(height: 12),
                      Text('Conversation', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Text(wizardSummary, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          TranscriptPreviewCard(
            controller: _transcriptController,
            focusNode: _transcriptFocusNode,
            onChanged: (_) => _handleTranscriptChanged(),
            helperText: _mode == _VoiceInteractionMode.wizard
                ? 'The wizard assembles the draft here from each answered step. Review the full command before saving.'
                : 'Live microphone capture fills this field. Edit the words first, then save to the right local module.',
          ),
          const SizedBox(height: 16),
          if (assistantResponse != null) ...[
            Card(
              key: const Key('voiceAssistantReplyCard'),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Assistant Reply', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text(
                      assistantResponse.summary,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      assistantResponse.nextStep,
                      style: theme.textTheme.bodySmall,
                    ),
                    if (assistantResponse.projectContext != null ||
                        assistantResponse.threadContext != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        [
                          if (assistantResponse.projectContext != null)
                            assistantResponse.projectContext,
                          if (assistantResponse.threadContext != null)
                            assistantResponse.threadContext,
                        ].join(' • '),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          key: const Key('voiceSpeakReplyButton'),
                          onPressed: () => _speakWithCurrentVoice(
                            '${assistantResponse.summary} ${assistantResponse.nextStep}',
                          ),
                          icon: const Icon(Icons.volume_up_outlined),
                          label: const Text('Speak Reply'),
                        ),
                        TextButton.icon(
                          key: const Key('voiceStopSpeakingButton'),
                          onPressed: _stopSpeaking,
                          icon: const Icon(Icons.stop_circle_outlined),
                          label: const Text('Stop Voice'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (briefing != null) ...[
            CalmGuidanceCard(
              sectionLabel: 'Briefing',
              title: briefing.summary,
              summary: briefing.nextStep,
              reason:
                  briefing.projectContext ??
                  briefing.threadContext ??
                  'It keeps the thread moving without adding noise.',
            ),
            const SizedBox(height: 16),
            Card(
              key: const Key('voiceBriefingCard'),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Briefing', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text('What I heard', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Text(briefing.summary, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Text('Next step', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Text(briefing.nextStep, style: theme.textTheme.bodySmall),
                    if (briefing.projectContext != null ||
                        briefing.threadContext != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        [
                          if (briefing.projectContext != null)
                            briefing.projectContext,
                          if (briefing.threadContext != null)
                            briefing.threadContext,
                        ].join(' • '),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    if (briefing.memorySummary != null ||
                        briefing.memoryHighlights.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        briefing.memorySummary ??
                            'Gaia is building memory from the current thread.',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (briefing.memoryHighlights.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: briefing.memoryHighlights
                              .map((highlight) => Chip(label: Text(highlight)))
                              .toList(),
                        ),
                      ],
                    ],
                    if (briefing.plannerSummary != null ||
                        briefing.plannerSteps.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        briefing.plannerSummary ??
                            'Gaia is ready to suggest the next useful move.',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (briefing.plannerSteps.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: briefing.plannerSteps.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final step = entry.value;
                            return Chip(label: Text('${index + 1}. $step'));
                          }).toList(),
                        ),
                      ],
                    ],
                    const SizedBox(height: 10),
                    Text(
                      'AI Assist',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    aiAssistAsync.when(
                      data: (aiAssist) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              aiAssist.summary,
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              aiAssist.nextStep,
                              style: theme.textTheme.bodySmall,
                            ),
                            if (aiAssist.suggestedType != null ||
                                aiAssist.suggestedTitle != null) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  if (aiAssist.suggestedType != null)
                                    Chip(
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      label: Text(
                                        'AI type: ${aiAssist.suggestedType!.label}',
                                      ),
                                    ),
                                  if (aiAssist.suggestedTitle != null)
                                    Chip(
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      label: Text(
                                        'AI title: ${aiAssist.suggestedTitle}',
                                      ),
                                    ),
                                ],
                              ),
                            ],
                            if (aiAssist.hints.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: aiAssist.hints
                                    .map(
                                      (hint) => Chip(
                                        visualDensity: VisualDensity.compact,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        label: Text(hint),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ],
                        );
                      },
                      loading: () => Text(
                        'Preparing AI assist suggestions...',
                        style: theme.textTheme.bodySmall,
                      ),
                      error: (error, stackTrace) => Text(
                        'AI assist could not load right now.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    if (briefing.actions.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: briefing.actions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final action = entry.value;
                          return Tooltip(
                            message: action.description,
                            child: OutlinedButton.icon(
                              key: Key(
                                'voiceBriefingActionButton-${action.id}',
                              ),
                              onPressed: () => _handleQuickAction(action),
                              icon: Icon(_quickActionIcon(action.id)),
                              label: Text('${index + 1}. ${action.label}'),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          key: const Key('voiceSpeakBriefingButton'),
                          onPressed: () => _speakWithCurrentVoice(
                            '${briefing.summary} ${briefing.nextStep}',
                          ),
                          icon: const Icon(Icons.campaign_outlined),
                          label: const Text('Speak Briefing'),
                        ),
                        TextButton.icon(
                          key: const Key('voiceStopBriefingButton'),
                          onPressed: _stopSpeaking,
                          icon: const Icon(Icons.stop_circle_outlined),
                          label: const Text('Stop Voice'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Card(
            key: const Key('voiceMacroCard'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Action Macros', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Tap a macro to run a common assistant move instantly.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: macroActions
                        .map(
                          (action) => Tooltip(
                            message: action.description,
                            child: FilledButton.tonalIcon(
                              key: Key('voiceMacroButton-${action.id}'),
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
                    'Pick a starting point, then edit the details before you save.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  _buildStarterDeckGroup(
                    theme: theme,
                    groupKey: const Key('voiceStarterDeckPlanGroup'),
                    title: 'Plan',
                    templateIds: const [
                      'build-day',
                      'summarize-today',
                      'whats-next',
                      'recall-thread',
                      'plan-day',
                    ],
                    templateById: templateById,
                  ),
                  const SizedBox(height: 12),
                  _buildStarterDeckGroup(
                    theme: theme,
                    groupKey: const Key('voiceStarterDeckCaptureGroup'),
                    title: 'Capture',
                    templateIds: const [
                      'project',
                      'task',
                      'journal',
                      'content',
                      'business',
                      'idea',
                    ],
                    templateById: templateById,
                  ),
                  const SizedBox(height: 12),
                  _buildStarterDeckGroup(
                    theme: theme,
                    groupKey: const Key('voiceStarterDeckShortcutGroup'),
                    title: 'Shortcuts',
                    templateIds: const [
                      'project-checkpoint',
                      'carry-forward',
                      'meeting-notes',
                      'quick-review',
                      'business-follow-up',
                    ],
                    templateById: templateById,
                  ),
                  const SizedBox(height: 12),
                  _buildStarterDeckGroup(
                    theme: theme,
                    groupKey: const Key('voiceStarterDeckCodexGroup'),
                    title: 'Review',
                    templateIds: const ['codex'],
                    templateById: templateById,
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
          if (activeSuggestion != null) ...[
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
                      'Type: ${activeSuggestion.suggestedType.label}',
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
                    if (activeSuggestion.suggestedProjectName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Project: ${activeSuggestion.suggestedProjectName}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    ..._buildStructuredSuggestionLines(theme, activeSuggestion),
                    if (activeSuggestion.usedExplicitType) ...[
                      const SizedBox(height: 6),
                      Text(
                        'An explicit command prefix was detected in the transcript.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    if (activeSuggestion.usedWakePhrase) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Wake phrase detected: ${activeSuggestion.wakePhrase ?? 'Gaia'}',
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
            selectedType: _currentType,
            onChanged: (value) {
              setState(() {
                _presetType = null;
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
                    : _currentType == VoiceCommandType.codexPrompt
                    ? _showCodexPrompt
                    : _saveSelectedCommand,
                icon: Icon(
                  _currentType == VoiceCommandType.codexPrompt
                      ? Icons.code_outlined
                      : Icons.save_outlined,
                ),
                label: Text(
                  _currentType == VoiceCommandType.codexPrompt
                      ? 'Prepare Codex Prompt'
                      : 'Save as ${_currentType.label}',
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
      case 'summarize-today':
        return Icons.summarize_outlined;
      case 'whats-next':
        return Icons.alt_route_outlined;
      case 'recall-thread':
        return Icons.history_rounded;
      case 'plan-day':
        return Icons.calendar_month_outlined;
      case 'project':
        return Icons.folder_open_outlined;
      case 'carry-forward':
        return Icons.forward_outlined;
      case 'meeting-notes':
        return Icons.meeting_room_outlined;
      case 'project-checkpoint':
        return Icons.flag_outlined;
      case 'business-follow-up':
        return Icons.phone_forwarded_outlined;
      case 'quick-review':
        return Icons.rate_review_outlined;
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

  Widget _buildStarterDeckGroup({
    required ThemeData theme,
    required Key groupKey,
    required String title,
    required List<String> templateIds,
    required Map<String, VoiceCommandTemplate> templateById,
  }) {
    final templates = templateIds
        .map((templateId) => templateById[templateId])
        .whereType<VoiceCommandTemplate>()
        .toList();

    if (templates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      key: groupKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(title, style: theme.textTheme.titleSmall),
                ],
              ),
              const SizedBox(height: 10),
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
              if (groupKey == const Key('voiceStarterDeckPlanGroup')) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _loadLatestTemplate,
                      icon: const Icon(Icons.history_toggle_off_outlined),
                      label: const Text('Load latest template'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _repeatLastTemplate,
                      icon: const Icon(Icons.repeat_rounded),
                      label: const Text('Repeat last template'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  IconData _quickActionIcon(String id) {
    switch (id) {
      case 'start-build-day':
        return Icons.calendar_view_day_outlined;
      case 'open-dashboard':
        return Icons.dashboard_outlined;
      case 'open-planner':
        return Icons.event_note_outlined;
      case 'open-planner-summary':
        return Icons.summarize_outlined;
      case 'summarize-today':
        return Icons.summarize_outlined;
      case 'plan-day':
        return Icons.calendar_month_outlined;
      case 'whats-next':
        return Icons.alt_route_outlined;
      case 'open-tasks-next':
        return Icons.task_alt_outlined;
      case 'open-projects-next':
        return Icons.folder_open_outlined;
      case 'open-tasks':
        return Icons.task_alt_outlined;
      case 'recall-memory':
      case 'recall-thread':
        return Icons.history_rounded;
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
    } else if (suggestion.suggestedType == VoiceCommandType.project) {
      if (suggestion.extractedProjectStatus != null) {
        lines.add('Status: ${suggestion.extractedProjectStatus}');
      }
      if (suggestion.extractedProjectPriority != null) {
        lines.add('Priority: ${suggestion.extractedProjectPriority}');
      }
      if (suggestion.extractedProjectVision != null) {
        lines.add('Vision: ${suggestion.extractedProjectVision}');
      }
      if (suggestion.extractedProjectNextAction != null) {
        lines.add('Next: ${suggestion.extractedProjectNextAction}');
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
    if (_currentType == VoiceCommandType.task) {
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
    } else if (_currentType == VoiceCommandType.project) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Project Details', style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          _buildDropdownField(
            fieldName: 'voiceProjectStatusField',
            resetToken: _suggestion?.transcript ?? 'empty',
            label: 'Status',
            value: _projectStatusValue,
            options: _projectStatusOptions,
            onChanged: (value) => setState(() => _projectStatusValue = value),
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            fieldName: 'voiceProjectPriorityField',
            resetToken: _suggestion?.transcript ?? 'empty',
            label: 'Priority',
            value: _projectPriorityValue,
            options: _projectPriorityOptions,
            onChanged: (value) => setState(() => _projectPriorityValue = value),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            key: const Key('voiceProjectVisionField'),
            label: 'Vision',
            controller: _projectVisionController,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            key: const Key('voiceProjectNextActionField'),
            label: 'Next Action',
            controller: _projectNextActionController,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            key: const Key('voiceProjectNotesField'),
            label: 'Notes',
            controller: _projectNotesController,
          ),
        ],
      );
    } else if (_currentType == VoiceCommandType.journalEntry) {
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
    } else if (_currentType == VoiceCommandType.contentIdea) {
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
    } else if (_currentType == VoiceCommandType.businessOpportunity) {
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
