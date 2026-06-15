import 'dart:io';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'gaia_bridge.dart';
import 'application/voice_conversation_dock_controller.dart';
import 'application/voice_assistant_turn_coordinator.dart';
import 'application/voice_ai_assist_controller.dart';
import 'application/voice_session_controller.dart';
import 'ai/voice_ai_assist_service.dart';
import 'voice_command_action_service.dart';
import 'desktop_speech_bridge_service.dart';
import 'voice_command_model.dart';
import 'voice_command_service.dart';
import 'voice_speech_service.dart';
import 'voice_speech_diagnostics_service.dart';
import 'windows_voice_typing_service.dart';
import '../voice_intelligence/application/voice_module_providers.dart';
import '../voice_intelligence/application/voice_thread_controller.dart';
import '../../core/routing/route_names.dart';
import '../settings/application/settings_controller.dart';
import '../../widgets/calm_guidance_card.dart';
import 'widgets/command_history_list.dart';
import 'widgets/command_type_selector.dart';
import 'widgets/transcript_preview_card.dart';
import 'widgets/voice_briefing_review_surface.dart';
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
    this.startInWizardMode = false,
    this.wakeTriggered = false,
    this.handsfreeTriggered = false,
  });

  final String? initialTranscript;
  final String? initialType;
  final bool startInWizardMode;
  final bool wakeTriggered;
  final bool handsfreeTriggered;

  @override
  ConsumerState<VoiceAssistantScreen> createState() =>
      _VoiceAssistantScreenState();
}

class _VoiceGuidePdfScreen extends StatelessWidget {
  const _VoiceGuidePdfScreen({required this.pdfPath});

  final String pdfPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Voice Guide PDF')),
      body: PdfViewer.file(pdfPath, params: const PdfViewerParams()),
    );
  }
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen> {
  static const _voiceGuidePdfPath = 'docs/user_guide/voice_assistant_guide.pdf';

  final VoiceCommandService _service = VoiceCommandService();
  final DesktopSpeechBridgeService _desktopSpeechBridgeService =
      DesktopSpeechBridgeService();
  final GaiaBridge _gaiaBridge = GaiaBridge();
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
  final TextEditingController _assistantConversationController =
      TextEditingController();
  final FocusNode _transcriptFocusNode = FocusNode();
  final FocusNode _assistantConversationFocusNode = FocusNode();
  final FocusNode _wizardAnswerFocusNode = FocusNode();
  late final VoiceSessionNotifier _voiceSessionNotifier;
  late final VoiceAssistantTurnCoordinator _turnCoordinator;

  late _VoiceInteractionMode _mode;
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
  VoiceAiAssistResponse? _acceptedAiBriefing;
  String? _acceptedAiTranscriptSummary;
  String? _acceptedAiWizardAnswer;
  String? _manualWizardAnswerBeforeAi;
  String _speechStatus = 'Ready when you are.';
  String? _speechError;
  bool _showAdvancedAssistantDetails = false;
  bool _isSaving = false;
  bool _speechAvailable = false;
  bool _isInitializingSpeech = false;
  bool _isListening = false;
  bool _usingWindowsVoiceTyping = false;
  bool _wakeAcknowledgeQueued = false;
  bool _wakeAcknowledgePending = false;
  bool _wakeAcknowledgeSpoken = false;
  bool _wakeAutoListenQueued = false;
  bool _handsfreeSessionActive = false;
  bool _voiceDiagnosticsShown = false;
  String? _lastAutoNavigatedSpeechTranscript;

  String get _speechStateLabel {
    if (_isInitializingSpeech) {
      return 'Preparing mic';
    }
    if (_isListening) {
      return 'Listening';
    }
    if (_speechError != null) {
      return 'Needs attention';
    }
    if (_speechStatus.toLowerCase().contains('review')) {
      return 'Review';
    }
    if (_speechStatus.toLowerCase().contains('handsfree')) {
      return 'Handsfree';
    }
    return 'Ready';
  }

  Color _speechStateColor(ThemeData theme) {
    if (_isInitializingSpeech) {
      return theme.colorScheme.tertiary;
    }
    if (_isListening) {
      return theme.colorScheme.error;
    }
    if (_speechError != null) {
      return theme.colorScheme.errorContainer;
    }
    if (_speechStatus.toLowerCase().contains('review')) {
      return theme.colorScheme.secondary;
    }
    return theme.colorScheme.primary;
  }

  Future<void> _openVoiceGuidePdf() async {
    final file = File(_voiceGuidePdfPath);
    if (!await file.exists()) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Voice guide PDF not found at ${file.path}')),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _VoiceGuidePdfScreen(pdfPath: file.path),
      ),
    );
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
                Text(
                  diagnostics.headsetStatus,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  diagnostics.bridgeStatus,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (bridge != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Python: ${bridge.pythonVersion}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Bridge model: ${bridge.bridgeModel}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (bridge.defaultInputDevice != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Default input: ${bridge.defaultInputDevice!['name']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (bridge.inputDevices.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Available inputs:',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    ...bridge.inputDevices.map(
                      (device) => Text(
                        '• ${device['name']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 12),
                Text(
                  diagnostics.recommendation,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
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

  Future<void> _showVoiceDiagnosticsOnce() async {
    if (_voiceDiagnosticsShown || !mounted) {
      return;
    }

    _voiceDiagnosticsShown = true;
    await _showVoiceDiagnostics();
  }

  @override
  void initState() {
    super.initState();
    _mode = widget.startInWizardMode
        ? _VoiceInteractionMode.wizard
        : _VoiceInteractionMode.quick;
    _voiceSessionNotifier = ref.read(voiceSessionProvider.notifier);
    _turnCoordinator = ref.read(voiceAssistantTurnCoordinatorProvider);
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
        label: 'Assistant ready',
        detail: 'Review before saving',
        opacity: 0.64,
      );
      ref.read(voiceConversationDockProvider.notifier).hide();
    });
    if (!(widget.wakeTriggered || widget.handsfreeTriggered)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        _assistantConversationFocusNode.requestFocus();
      });
    }
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
          label: 'Assistant ready',
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
            label: 'Assistant ready',
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
    _gaiaBridge.dispose();
    _transcriptController.removeListener(_handleTranscriptChanged);
    _transcriptController.dispose();
    _assistantConversationController.dispose();
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
    _assistantConversationFocusNode.dispose();
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
    final settingsSnapshot = ref
        .read(settingsSnapshotProvider)
        .maybeWhen(data: (snapshot) => snapshot, orElse: () => null);
    if (settingsSnapshot == null) {
      return;
    }

    await _turnCoordinator.speak(
      VoiceAssistantTurnPlan(
        kind: VoiceAssistantTurnKind.wake,
        owner: VoiceSessionOwner.assistant,
        speakingLabel: 'Assistant speaking',
        speakingDetail: 'Answering the wake phrase',
        followUpLabel: 'Assistant ready',
        followUpDetail: 'Waiting for your next command',
        text: "I'm here. Say task, project, summary, or continue thread.",
        settings: settingsSnapshot.settings,
        tone: VoiceSpeechTone.wake,
      ),
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
      _lastAutoNavigatedSpeechTranscript = null;
      if (!mounted) {
        return;
      }

      setState(() {
        _presetType = null;
        _suggestion = null;
        _acceptedAiBriefing = null;
        _acceptedAiTranscriptSummary = null;
        _acceptedAiWizardAnswer = null;
        _manualWizardAnswerBeforeAi = null;
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

    final isVoiceCaptureActive =
        _isListening || _isInitializingSpeech || _usingWindowsVoiceTyping;
    final isNavigationRequest = _service.isDashboardNavigationRequest(
      transcript,
    );
    if (isVoiceCaptureActive && isNavigationRequest) {
      if (_lastAutoNavigatedSpeechTranscript == transcript) {
        return;
      }

      _lastAutoNavigatedSpeechTranscript = transcript;
      unawaited(
        _handleCapturedSpeechTranscript(
          transcript,
          source: 'transcript listener',
        ),
      );
      return;
    }

    _lastAutoNavigatedSpeechTranscript = null;

    if (!mounted) {
      return;
    }

    setState(() {
      _suggestion = suggestion;
      _acceptedAiBriefing = null;
      _acceptedAiTranscriptSummary = null;
      _acceptedAiWizardAnswer = null;
      _manualWizardAnswerBeforeAi = null;
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
          ? 'I am here and ready.'
          : 'I heard you and I am here.',
      nextStep:
          'Say the next command and I will shape it into the right local action.',
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

  void _applyAiBriefingDraft(VoiceAiAssistResponse aiAssist) {
    setState(() {
      _acceptedAiBriefing = aiAssist;
      _speechStatus = 'AI briefing wording applied. Review it before saving.';
    });
  }

  void _clearAiBriefingDraft() {
    if (_acceptedAiBriefing == null) {
      return;
    }

    setState(() {
      _acceptedAiBriefing = null;
      _speechStatus = 'Using the manual briefing wording again.';
    });
  }

  void _applyAiTranscriptSummary(String summary) {
    setState(() {
      _acceptedAiTranscriptSummary = summary;
      _speechStatus = 'AI transcript summary applied. Review before saving.';
    });
  }

  void _clearAiTranscriptSummary() {
    if (_acceptedAiTranscriptSummary == null) {
      return;
    }

    setState(() {
      _acceptedAiTranscriptSummary = null;
      _speechStatus = 'Using the manual transcript wording again.';
    });
  }

  void _applyAiWizardAnswer(String answer) {
    setState(() {
      _manualWizardAnswerBeforeAi ??= _wizardAnswerController.text.trim();
      _acceptedAiWizardAnswer = answer;
      _wizardAnswerController.text = answer;
      _wizardAnswerController.selection = TextSelection.collapsed(
        offset: _wizardAnswerController.text.length,
      );
      _speechStatus = 'AI wizard answer applied. Review it before continuing.';
    });
  }

  void _clearAiWizardAnswer() {
    if (_acceptedAiWizardAnswer == null) {
      return;
    }

    setState(() {
      _acceptedAiWizardAnswer = null;
      _wizardAnswerController.text = _manualWizardAnswerBeforeAi ?? '';
      _wizardAnswerController.selection = TextSelection.collapsed(
        offset: _wizardAnswerController.text.length,
      );
      _manualWizardAnswerBeforeAi = null;
      _speechStatus = 'Using the manual wizard answer again.';
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
    _acceptedAiWizardAnswer = null;
    _manualWizardAnswerBeforeAi = null;
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
          : 'Wizard answer locked in. Keep going with the next question.';
    });

    if (_wizardStep == VoiceWizardStep.review) {
      unawaited(
        _speakWithCurrentVoice(
          'Draft complete. Ready for review.',
          tone: VoiceSpeechTone.wizard,
        ),
      );
    } else {
      unawaited(
        _speakWithCurrentVoice(
          'Good. Next: ${_wizardPrompt()}',
          tone: VoiceSpeechTone.wizard,
        ),
      );
    }

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
      label: 'Assistant listening',
      detail: 'Preparing microphone',
      opacity: 0.72,
    )) {
      if (!mounted) {
        return;
      }

      setState(() {
        _speechStatus = 'Voice is already active somewhere else.';
      });
      return;
    }

    _setVoicePresence(
      label: 'Assistant listening',
      detail: 'I\'m listening',
      isActive: true,
      opacity: 0.72,
    );

    setState(() {
      _speechStatus = "Listening. Okay, Peter. What's next?";
    });
    await _speakListeningGreeting();

    if (WindowsVoiceTypingService.isSupported && preferDesktopBridge) {
      await _startWindowsDesktopCapture(
        preferDesktopBridge: preferDesktopBridge,
      );
      return;
    }

    setState(() {
      _speechError = null;
      _isInitializingSpeech = true;
      _speechStatus = 'Preparing microphone for capture...';
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
        _speechStatus = 'Windows speech could not start. Open diagnostics.';
        _speechError =
            'Windows did not start speech capture. Run Voice diagnostics to check the offline bridge and default input device.';
      });
      session.release(
        owner: VoiceSessionOwner.assistant,
        label: 'Assistant idle',
        detail: 'Microphone unavailable',
      );
      unawaited(_showVoiceDiagnosticsOnce());
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
      _speechStatus = 'Listening for your voice...';
    });
    _setVoicePresence(
      label: 'Assistant listening',
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
          ? 'Listening with the assistant. Speak your next command...'
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
        _usingWindowsVoiceTyping = available;
        _speechStatus = available
            ? 'Microphone ready. Speak your next command.'
            : 'Windows voice typing could not start. The assistant will use the offline bridge or diagnostics.';
        _speechError = available
            ? null
            : 'Windows speech is not ready yet. Run Voice diagnostics to check the headset, bridge, and default input device.';
      });
      if (available) {
        session.beginListening(
          owner: VoiceSessionOwner.assistant,
          label: 'Assistant listening',
          detail: 'Speak your next command',
          opacity: 0.82,
        );
      } else {
        return await _startWindowsSpeechToTextCapture(
          preparingStatus:
              'Windows voice typing could not start. The assistant will use diagnostics and the offline bridge.',
          unavailableStatus:
              'Windows speech could not start. Open diagnostics.',
          unavailableError:
              'Run Voice diagnostics to check the headset, offline bridge, and default input device.',
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
      await _handleCapturedSpeechTranscript(
        capture.transcript.trim(),
        source: 'desktop bridge',
      );
      return;
    }

    final available = await startWindowsTyping();
    if (!available) {
      session.release(
        owner: VoiceSessionOwner.assistant,
        label: 'Assistant idle',
        detail: 'Mic not available',
      );
      unawaited(_showVoiceDiagnosticsOnce());
    }
  }

  Future<bool> _startWindowsSpeechToTextCapture({
    required String preparingStatus,
    required String unavailableStatus,
    required String unavailableError,
  }) async {
    final session = ref.read(voiceSessionProvider.notifier);

    setState(() {
      _speechError = null;
      _isInitializingSpeech = true;
      _speechStatus = preparingStatus;
    });

    final available = await _speech.initialize(
      onError: _onSpeechError,
      onStatus: _onSpeechStatus,
    );

    if (!mounted) {
      return false;
    }

    setState(() {
      _speechAvailable = available;
      _isInitializingSpeech = false;
      _usingWindowsVoiceTyping = false;
    });

    if (!available) {
      setState(() {
        _speechStatus = unavailableStatus;
        _speechError = unavailableError;
      });
      session.release(
        owner: VoiceSessionOwner.assistant,
        label: 'Assistant idle',
        detail: 'Microphone unavailable',
      );
      unawaited(_showVoiceDiagnosticsOnce());
      return false;
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
      return false;
    }

    setState(() {
      _isListening = true;
      _speechStatus = 'Listening for your voice...';
    });
    _setVoicePresence(
      label: 'Assistant listening',
      detail: 'Speak your next command',
      isActive: true,
      opacity: 0.84,
    );
    return true;
  }

  Future<void> _startHandsfreeConversationSession() async {
    if (_handsfreeSessionActive || !mounted) {
      return;
    }

    final session = ref.read(voiceSessionProvider.notifier);
    if (!session.beginListening(
      owner: VoiceSessionOwner.assistant,
      label: 'Assistant listening',
      detail: 'Handsfree conversation',
      opacity: 0.84,
    )) {
      _handsfreeSessionActive = false;
      if (mounted) {
        setState(() {
          _speechStatus = 'Voice is already active somewhere else.';
        });
      }
      return;
    }

    _handsfreeSessionActive = true;
    _wakeAutoListenQueued = true;
    await _turnCoordinator.stop();
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

      var transcript = capture?.transcript.trim() ?? '';
      if (transcript.isEmpty) {
        transcript =
            (await _captureHandsfreeTranscriptWithSpeechToText())?.trim() ?? '';
      }
      if (transcript.isEmpty) {
        session.beginListening(
          owner: VoiceSessionOwner.assistant,
          label: 'Assistant listening',
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
        label: 'Assistant captured',
        detail: 'Sending to Assistant',
        opacity: 0.84,
      );

      await _handleHandsfreeConversationTurn(transcript);
      if (!mounted || !_handsfreeSessionActive) {
        break;
      }

      await Future<void>.delayed(const Duration(milliseconds: 600));
    }

    if (!mounted) {
      return;
    }

    _handsfreeSessionActive = false;
    session.release(
      owner: VoiceSessionOwner.assistant,
      label: 'Assistant idle',
      detail: 'Ready when you are',
    );
  }

  VoiceCommandAssistantResponse _buildConversationAssistantResponse({
    required VoiceAiAssistResponse aiResponse,
    required VoiceConversationContext? conversationContext,
    required VoiceCommandSuggestion suggestion,
  }) {
    return VoiceCommandAssistantResponse(
      summary: aiResponse.summary,
      nextStep: aiResponse.nextStep,
      projectContext:
          aiResponse.projectContext ??
          conversationContext?.projectName ??
          suggestion.suggestedProjectName,
      threadContext:
          aiResponse.threadContext ??
          conversationContext?.threadScopeLabel ??
          suggestion.suggestedTitle,
      suggestedTitle: aiResponse.suggestedTitle ?? suggestion.suggestedTitle,
      suggestedSummary:
          aiResponse.suggestedSummary ?? suggestion.suggestedTitle,
      suggestedWizardAnswer: aiResponse.suggestedWizardAnswer,
      suggestedType: aiResponse.suggestedType ?? suggestion.suggestedType,
      hints: aiResponse.hints,
    );
  }

  Future<VoiceCommandAssistantResponse?> _sendAssistantConversationTurn(
    String transcript, {
    bool speakReply = true,
    String source = 'typed',
  }) async {
    final cleanedTranscript = transcript.trim();
    if (cleanedTranscript.isEmpty) {
      return null;
    }

    final suggestion = _service.suggestCommand(transcript: cleanedTranscript);
    final conversationContext = _service.buildConversationContext(
      transcript: suggestion.transcript,
      type: suggestion.suggestedType,
      title: suggestion.suggestedTitle,
      projectId: suggestion.suggestedProjectId,
      projectName: suggestion.suggestedProjectName,
      previous: _conversationContext,
      navigation: _service.isDashboardNavigationRequest(cleanedTranscript),
    );

    _conversationContext = conversationContext;
    _syncSharedConversationThread();

    VoiceCommandAssistantResponse assistantResponse;
    try {
      final aiResponse = await ref.read(
        voiceAiConversationAssistProvider(
          VoiceAiAssistRequest(
            transcript: cleanedTranscript,
            conversationContext: conversationContext,
            selectedType: suggestion.suggestedType,
          ),
        ).future,
      );
      assistantResponse = _buildConversationAssistantResponse(
        aiResponse: aiResponse,
        conversationContext: conversationContext,
        suggestion: suggestion,
      );
    } catch (_) {
      assistantResponse = _service.buildAssistantResponse(
        transcript: cleanedTranscript,
        suggestion: suggestion,
        conversationContext: conversationContext,
      );
    }

    if (!mounted) {
      return assistantResponse;
    }

    if (_service.isDashboardNavigationRequest(cleanedTranscript)) {
      setState(() {
        _speechStatus =
            'Opening the dashboard now. You are back on the main dashboard.';
      });
      context.go(RouteNames.dashboard);
      unawaited(
        _speakWithCurrentVoice(
          assistantResponse.summary,
          tone: VoiceSpeechTone.briefing,
        ),
      );
      return assistantResponse;
    }

    _showConversationDock(
      transcript: cleanedTranscript,
      response: assistantResponse,
      isWake: suggestion.usedWakePhrase || suggestion.isWakeOnly,
      conversationContext: conversationContext,
    );

    setState(() {
      _speechStatus = source == 'handsfree'
          ? 'The assistant replied. Keep talking or say stop.'
          : 'The assistant replied. You can keep typing or speak the next turn.';
    });

    if (speakReply) {
      await _speakWithCurrentVoice(
        assistantResponse.summary,
        tone: VoiceSpeechTone.briefing,
      );
    }

    if (!mounted) {
      return assistantResponse;
    }

    ref
        .read(voiceSessionProvider.notifier)
        .beginAwaitingFollowUp(
          owner: VoiceSessionOwner.assistant,
          label: 'Assistant ready',
          detail: source == 'handsfree'
              ? 'Handsfree conversation active'
              : 'Ready for your next turn',
          opacity: 0.84,
        );

    return assistantResponse;
  }

  void _showConversationDock({
    required String transcript,
    required VoiceAssistantResponse response,
    required bool isWake,
    required VoiceConversationContext conversationContext,
  }) {
    ref
        .read(voiceConversationDockProvider.notifier)
        .show(
          title: 'Assistant',
          summary: response.summary,
          nextStep: response.nextStep,
          transcript: transcript,
          isWake: isWake,
          projectContext: response.projectContext,
          threadContext: response.threadContext,
          conversationContext: conversationContext,
        );
  }

  Future<void> _handleHandsfreeConversationTurn(String transcript) async {
    await _sendAssistantConversationTurn(
      transcript,
      speakReply: true,
      source: 'handsfree',
    );
  }

  Future<void> _submitTypedAssistantConversation() async {
    final transcript = _assistantConversationController.text.trim();
    if (transcript.isEmpty) {
      return;
    }

    _assistantConversationController.clear();
    await _sendAssistantConversationTurn(
      transcript,
      speakReply: true,
      source: 'typed',
    );
  }

  Future<String?> _captureHandsfreeTranscriptWithSpeechToText() async {
    String latestTranscript = '';
    final completer = Completer<String?>();

    setState(() {
      _speechStatus =
          'Handsfree mode is using the local microphone recognizer.';
      _speechError = null;
    });

    final available = await _speech.initialize(
      onError: (SpeechRecognitionError error) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      },
      onStatus: (String status) {
        if (status == 'done' && !completer.isCompleted) {
          completer.complete(
            latestTranscript.trim().isEmpty ? null : latestTranscript.trim(),
          );
        }
      },
    );

    if (!available) {
      return null;
    }

    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          latestTranscript = result.recognizedWords;
          if (result.finalResult && !completer.isCompleted) {
            completer.complete(
              latestTranscript.trim().isEmpty ? null : latestTranscript.trim(),
            );
          }
        },
        listenFor: const Duration(seconds: 8),
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.confirmation,
          partialResults: true,
          cancelOnError: true,
          autoPunctuation: true,
        ),
      );

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () =>
            latestTranscript.trim().isEmpty ? null : latestTranscript.trim(),
      );
    } finally {
      await _speech.stop();
    }
  }

  Future<void> _stopListening() async {
    _handsfreeSessionActive = false;
    if (WindowsVoiceTypingService.isSupported && _usingWindowsVoiceTyping) {
      _activeSpeechFocusNode.requestFocus();
      if (!mounted) {
        return;
      }

      setState(() {
        _isListening = false;
        _speechStatus =
            'Dictation captured. Review it now. If Windows voice typing is still open, press Win + H to close it.';
      });
      ref
          .read(voiceSessionProvider.notifier)
          .release(
            owner: VoiceSessionOwner.assistant,
            label: 'Assistant idle',
            detail: 'Reviewing dictation',
          );
      _usingWindowsVoiceTyping = false;
      return;
    }

    await _speech.stop();
    if (!mounted) {
      return;
    }

    setState(() {
      _isListening = false;
      _speechStatus = 'Capture stopped. Review the transcript before saving.';
    });
    ref
        .read(voiceSessionProvider.notifier)
        .release(
          owner: VoiceSessionOwner.assistant,
          label: 'Assistant idle',
          detail: 'Stopped listening',
        );
    _usingWindowsVoiceTyping = false;
  }

  Future<void> _cancelListening() async {
    _handsfreeSessionActive = false;
    if (WindowsVoiceTypingService.isSupported && _usingWindowsVoiceTyping) {
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
        label: 'Assistant idle',
        detail: 'Listening cancelled',
        isActive: false,
        opacity: 0.28,
      );
      _usingWindowsVoiceTyping = false;
      return;
    }

    await _speech.cancel();
    if (!mounted) {
      return;
    }

    setState(() {
      _isListening = false;
      _speechStatus = 'Capture cancelled. You can start again anytime.';
    });
    ref
        .read(voiceSessionProvider.notifier)
        .release(
          owner: VoiceSessionOwner.assistant,
          label: 'Assistant idle',
          detail: 'Capture cancelled',
        );
    _usingWindowsVoiceTyping = false;
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) {
      return;
    }

    if (result.finalResult) {
      unawaited(
        _handleCapturedSpeechTranscript(
          result.recognizedWords,
          source: 'speech',
        ),
      );
      return;
    }

    setState(() {
      _activeSpeechController.text = result.recognizedWords;
      _activeSpeechController.selection = TextSelection.collapsed(
        offset: _activeSpeechController.text.length,
      );
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
          ? 'Speech capture needs attention. Open diagnostics.'
          : 'Speech capture paused. Try again or open diagnostics.';
    });
    _setVoicePresence(
      label: 'Assistant idle',
      detail: 'Speech paused',
      isActive: false,
      opacity: 0.28,
    );
    if (error.permanent) {
      unawaited(_showVoiceDiagnosticsOnce());
    }
  }

  void _onSpeechStatus(String status) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isListening = _speech.isListening;
      if (!_isListening && status == 'done') {
        if (_service.isDashboardNavigationRequest(
          _activeSpeechController.text,
        )) {
          return;
        }
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
      await _speakWithCurrentVoice(
        'Saving locally now.',
        tone: VoiceSpeechTone.calmConfirmation,
      );
      final editableSuggestion = _buildEditableSuggestion();
      final normalizedTranscript = editableSuggestion?.transcript ?? transcript;
      final assistantDecision = await _gaiaBridge.sendCommand(
        GaiaCommand(
          intent: _currentType.name,
          module: 'voice_assistant',
          action: 'save_command',
          payload: {
            'transcript': normalizedTranscript,
            'type': _currentType.name,
            'project_id': _selectedProjectId,
            'title_override': _titleController.text.trim(),
          },
          requiresConfirmation: false,
          sensitivity: 'medium',
        ),
      );

      if (assistantDecision.isBlocked) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Assistant blocked this command: ${assistantDecision.reason}',
            ),
          ),
        );
        return;
      }

      if (assistantDecision.isConfirm) {
        if (!mounted) {
          return;
        }
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirm command'),
              content: Text(
                'Assistant wants confirmation before saving this command. ${assistantDecision.reason}',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );

        if (confirmed != true) {
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Save canceled by assistant confirmation.'),
            ),
          );
          return;
        }
      }

      await ref
          .read(voiceCommandActionsControllerProvider)
          .saveCommand(
            transcript: normalizedTranscript,
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
        _speechStatus = 'Saved locally. Ready for the next move.';
      });
      _setVoicePresence(
        label: 'Assistant ready',
        detail: 'Saved and ready',
        isActive: false,
        opacity: 0.32,
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
      label: 'Assistant ready',
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
      label: 'Assistant ready',
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
      label: 'Assistant ready',
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
      label: 'Assistant ready',
      detail: 'History item loaded',
      isActive: false,
      opacity: 0.32,
    );
    _transcriptFocusNode.requestFocus();
  }

  void _restoreLatestCommandFromHistory() {
    if (_history.isEmpty) {
      return;
    }

    _restoreCommandFromHistory(_history.first);
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
    _syncSharedConversationThread();
  }

  void _syncSharedConversationThread() {
    final conversationContext = _conversationContext;
    if (conversationContext == null) {
      return;
    }

    ref
        .read(voiceConversationThreadProvider.notifier)
        .rememberThread(
          threadTitle: 'Voice Assistant',
          summary: conversationContext.summary,
          nextStep:
              'Continue the shared thread in the calm voice conversation route.',
          resumeRoute: RouteNames.voiceConversation,
          latestCaptureLabel: conversationContext.latestEntryLabel,
          latestCapturePreview: conversationContext.latestEntryPreview,
          lastThingYouSaid:
              conversationContext.transcript ?? conversationContext.summary,
          reviewPrompt:
              'Review the legacy assistant thread before saving or branching it.',
          prompts: const [
            VoiceConversationPrompt(
              label: 'Open shared conversation',
              description: 'Switch into the calm shared voice thread.',
              route: RouteNames.voiceConversation,
            ),
            VoiceConversationPrompt(
              label: 'Return home',
              description: 'Go back to the voice hub.',
              route: RouteNames.voice,
            ),
            VoiceConversationPrompt(
              label: 'Open legacy assistant',
              description: 'Stay in the legacy assistant flow.',
              route: RouteNames.voiceAssistant,
            ),
          ],
          isFresh: false,
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
      label: 'Assistant thread',
      detail: 'Continuing voice conversation',
      isActive: true,
      opacity: 0.74,
    );
    _wizardAnswerFocusNode.requestFocus();
    unawaited(
      _speakWithCurrentVoice(
        'Continuing this thread. ${conversationContext.summary}',
        tone: VoiceSpeechTone.briefing,
      ),
    );
  }

  void _startNewThread() {
    setState(() {
      _conversationContext = null;
      _resetWizardDraft(keepMode: true, preserveThread: false);
      _speechStatus = 'Started a fresh voice thread.';
    });
    ref.read(voiceConversationThreadProvider.notifier).startFresh();
    _setVoicePresence(
      label: 'Assistant ready',
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
      'Thread: ${conversationContext.threadScopeLabel}',
      'Summary: ${conversationContext.summary}',
      if (conversationContext.projectName != null &&
          conversationContext.projectName!.isNotEmpty)
        'Project: ${conversationContext.projectName}',
      'Latest: ${conversationContext.latestEntryLabel}',
    ];

    await Clipboard.setData(ClipboardData(text: parts.join('\n')));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied remembered thread summary.')),
    );
  }

  Future<void> _speakWithCurrentVoice(
    String text, {
    VoiceSpeechTone tone = VoiceSpeechTone.neutral,
  }) async {
    final settingsSnapshot = ref
        .read(settingsSnapshotProvider)
        .maybeWhen(data: (snapshot) => snapshot, orElse: () => null);
    if (settingsSnapshot == null) {
      return;
    }

    try {
      await _turnCoordinator.speak(
        VoiceAssistantTurnPlan(
          kind: VoiceAssistantTurnKind.briefing,
          owner: VoiceSessionOwner.assistant,
          speakingLabel: 'Assistant speaking',
          speakingDetail: 'Reading back the current response',
          followUpLabel: 'Assistant ready',
          followUpDetail: 'Waiting for your next command',
          text: text,
          settings: settingsSnapshot.settings,
          tone: tone,
        ),
      );
    } catch (_) {
      // Voice output is best-effort. The transcript flow still works if TTS fails.
    }
  }

  Future<void> _speakListeningGreeting() async {
    final settingsSnapshot = ref
        .read(settingsSnapshotProvider)
        .maybeWhen(data: (snapshot) => snapshot, orElse: () => null);
    if (settingsSnapshot == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Listening. Okay, Peter. What's next?")),
    );

    try {
      final service = ref.read(voiceAssistantSpeechServiceProvider);
      final voices = await ref.read(voiceAssistantVoicesProvider.future);
      final selectedVoice = resolveConfiguredVoiceOption(
        voices: voices,
        preferredName: settingsSnapshot.settings.preferredTtsVoiceName,
        preferredLocale: settingsSnapshot.settings.preferredTtsVoiceLocale,
        preferredGender: settingsSnapshot.settings.preferredTtsVoiceGender,
        preferredIdentifier:
            settingsSnapshot.settings.preferredTtsVoiceIdentifier,
      );
      await service.primeSpeechOutput(enabled: true);
      await Future<void>.delayed(const Duration(milliseconds: 250));
      await service.speakWithPowerShellFallback(
        "Okay, Peter. What's next?",
        enabled: true,
        rate: settingsSnapshot.settings.preferredTtsVoiceRate,
        pitch: settingsSnapshot.settings.preferredTtsVoicePitch,
        voice: selectedVoice,
      );
    } catch (_) {
      // Best effort only. The visible status still confirms listening.
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
    await _turnCoordinator.stop();
    ref
        .read(voiceSessionProvider.notifier)
        .updatePresence(
          label: 'Assistant ready',
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
    final rawTranscript = _transcriptController.text.trim();
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
    final VoiceAiAssistResponse? aiAssistDraft = aiAssistAsync.maybeWhen(
      data: (aiAssist) => aiAssist,
      orElse: () => null,
    );
    final VoiceAiAssistResponse? appliedAiBriefing =
        _acceptedAiBriefing ?? aiAssistDraft;
    final String? transcriptCleanupSummary =
        _acceptedAiTranscriptSummary ?? aiAssistDraft?.suggestedSummary;
    final String? wizardAiAnswer =
        _acceptedAiWizardAnswer ?? aiAssistDraft?.suggestedWizardAnswer;
    final briefingSummary =
        appliedAiBriefing?.summary ?? briefing?.summary ?? '';
    final briefingNextStep =
        appliedAiBriefing?.nextStep ?? briefing?.nextStep ?? '';
    final briefingReason = appliedAiBriefing != null
        ? 'AI wording is ready to review. Keep it only if it makes the next move clearer.'
        : briefing?.projectContext ??
              briefing?.threadContext ??
              'It keeps the thread moving without adding noise.';

    return Scaffold(
      appBar: AppBar(title: const Text('Voice Assistant')),
      body: KeyedSubtree(
        key: const Key('voiceAssistantPageBody'),
        child: ListView(
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
                  : 'Capture first, then review the transcript, then speak or save when it feels right.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            Card(
              key: const Key('voiceFlowGuideCard'),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Start here', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      'The simplest path is Capture, Review, then Speak or Save. Whisper is tried first on Windows, then the local recognizer, and the extra tools stay lower on the page.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        Chip(label: Text('Capture')),
                        Chip(label: Text('Review')),
                        Chip(label: Text('Save')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                key: const Key('voiceGuidePdfButton'),
                onPressed: _openVoiceGuidePdf,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Voice Guide PDF'),
              ),
            ),
            const SizedBox(height: 24),
            if (conversationContext != null) ...[
              VoiceConversationThreadCard(
                conversationContext: conversationContext,
                onResumeThread: _continueCurrentThread,
                onReuseLatestCapture: _restoreLatestCommandFromHistory,
                onStartFresh: _startNewThread,
                onCopySummary: _copyConversationSummary,
                onOpenSharedConversation: () =>
                    context.go(RouteNames.voiceConversation),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              key: const Key('voiceAssistantChatCard'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ask the assistant',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Type a question here and the assistant will answer from the same local conversation runtime used by voice.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('voiceAssistantChatField'),
                      controller: _assistantConversationController,
                      focusNode: _assistantConversationFocusNode,
                      minLines: 2,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        labelText: 'Message Assistant',
                        hintText:
                            'Ask for a summary, next step, or thread follow-up...',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          key: const Key('voiceAssistantChatSendIconButton'),
                          onPressed: _submitTypedAssistantConversation,
                          icon: const Icon(Icons.send_outlined),
                        ),
                      ),
                      onSubmitted: (_) => _submitTypedAssistantConversation(),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          key: const Key('voiceAssistantChatSendButton'),
                          onPressed: _submitTypedAssistantConversation,
                          icon: const Icon(Icons.send_outlined),
                          label: const Text('Send to Assistant'),
                        ),
                      ],
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
                    Row(
                      children: [
                        Icon(
                          _isListening
                              ? Icons.mic_rounded
                              : Icons.mic_none_rounded,
                          size: 20,
                          color: _isListening
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _speechStatus,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
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
                          _isInitializingSpeech ? 'Preparing' : 'Start speech',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _showVoiceDiagnostics,
                      icon: const Icon(Icons.health_and_safety_outlined),
                      label: const Text('Run voice diagnostics'),
                    ),
                    if (_speechError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _speechError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showAdvancedAssistantDetails =
                        !_showAdvancedAssistantDetails;
                  });
                },
                icon: Icon(
                  _showAdvancedAssistantDetails
                      ? Icons.expand_less
                      : Icons.expand_more,
                ),
                label: Text(
                  _showAdvancedAssistantDetails
                      ? 'Hide advanced voice tools'
                      : 'Show advanced voice tools',
                ),
              ),
            ),
            if (_showAdvancedAssistantDetails) ...[
              const SizedBox(height: 8),
              Card(
                key: const Key('voiceAssistantAdvancedCard'),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Advanced voice tools',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use these when you want capture paths, wizard mode, and local command tools.',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Text('Capture', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                _isListening
                                    ? Icons.mic_rounded
                                    : Icons.mic_none_rounded,
                                size: 32,
                                color: _isListening
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  FilledButton.tonalIcon(
                                    key: const Key('voiceStopListeningButton'),
                                    onPressed: _isListening
                                        ? _stopListening
                                        : null,
                                    icon: const Icon(
                                      Icons.stop_circle_outlined,
                                    ),
                                    label: const Text('Stop'),
                                  ),
                                  TextButton.icon(
                                    key: const Key(
                                      'voiceCancelListeningButton',
                                    ),
                                    onPressed: _isListening
                                        ? _cancelListening
                                        : null,
                                    icon: const Icon(Icons.close),
                                    label: const Text('Cancel'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: theme
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _speechStateColor(
                                      theme,
                                    ).withValues(alpha: 0.28),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        Chip(
                                          label: Text(_speechStateLabel),
                                          side: BorderSide.none,
                                          backgroundColor: _speechStateColor(
                                            theme,
                                          ).withValues(alpha: 0.16),
                                        ),
                                        if (_usingWindowsVoiceTyping)
                                          Chip(
                                            label: const Text(
                                              'Windows dictation',
                                            ),
                                            side: BorderSide.none,
                                            backgroundColor: theme
                                                .colorScheme
                                                .secondaryContainer
                                                .withValues(alpha: 0.72),
                                          ),
                                        if (!_usingWindowsVoiceTyping &&
                                            !_isInitializingSpeech &&
                                            !_isListening)
                                          Chip(
                                            label: const Text('Review mode'),
                                            side: BorderSide.none,
                                            backgroundColor: theme
                                                .colorScheme
                                                .primaryContainer
                                                .withValues(alpha: 0.72),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _speechStatus,
                                      style: theme.textTheme.bodySmall,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
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
                              if (!_speechAvailable &&
                                  _speechError != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Paste Transcript and mock capture still work without microphone access.',
                                  style: theme.textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              const SizedBox(height: 12),
                              ExpansionTile(
                                key: const Key('voiceMoreCaptureToolsTile'),
                                tilePadding: EdgeInsets.zero,
                                childrenPadding: EdgeInsets.zero,
                                title: Text(
                                  'More capture tools',
                                  style: theme.textTheme.titleSmall,
                                ),
                                subtitle: Text(
                                  'Use these if you want a different capture path.',
                                  style: theme.textTheme.bodySmall,
                                ),
                                children: [
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      FilledButton.icon(
                                        key: const Key(
                                          'voiceMockTranscriptButton',
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: theme
                                              .colorScheme
                                              .secondaryContainer,
                                          foregroundColor: theme
                                              .colorScheme
                                              .onSecondaryContainer,
                                        ),
                                        onPressed: _mockRecordCommand,
                                        icon: const Icon(Icons.graphic_eq),
                                        label: const Text(
                                          'Use Mock Transcript',
                                        ),
                                      ),
                                      FilledButton.tonalIcon(
                                        key: const Key(
                                          'voicePasteTranscriptButton',
                                        ),
                                        onPressed: _pasteFromClipboard,
                                        icon: const Icon(Icons.content_paste),
                                        label: const Text('Paste Transcript'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ExpansionTile(
                key: const Key('voiceAssistantDebugTile'),
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: Text(
                  'Debug, history, and wizard',
                  style: theme.textTheme.titleSmall,
                ),
                subtitle: Text(
                  'Everything else lives here: thread context, guide cards, wizard mode, and save/history tools.',
                  style: theme.textTheme.bodySmall,
                ),
                children: [
                  const SizedBox(height: 12),
                  Text('Review + history', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Keep the transcript, review cards, save flow, and command history together here.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  if (conversationContext != null) ...[
                    VoiceConversationThreadCard(
                      conversationContext: conversationContext,
                      onResumeThread: _continueCurrentThread,
                      onReuseLatestCapture: _restoreLatestCommandFromHistory,
                      onStartFresh: _startNewThread,
                      onCopySummary: _copyConversationSummary,
                      onOpenSharedConversation: () =>
                          context.go(RouteNames.voiceConversation),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Card(
                    key: const Key('voiceFlowGuideCard'),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Start here', style: theme.textTheme.titleSmall),
                          const SizedBox(height: 4),
                          Text(
                            'The simplest path is Capture, Review, then Speak or Save. Whisper is tried first on Windows, then the local recognizer, and the extra tools stay lower on the page.',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: const [
                              Chip(label: Text('Capture')),
                              Chip(label: Text('Review')),
                              Chip(label: Text('Save')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.tonalIcon(
                      key: const Key('voiceGuidePdfButton'),
                      onPressed: _openVoiceGuidePdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Voice Guide PDF'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Wizard', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Wizard mode stays here so quick capture stays the default path.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  ExpansionTile(
                    key: const Key('voiceAdvancedModesTile'),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    title: Text(
                      'Advanced voice modes',
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      'Wizard mode stays here so quick capture stays the default path.',
                      style: theme.textTheme.bodySmall,
                    ),
                    children: [
                      const SizedBox(height: 12),
                      SegmentedButton<_VoiceInteractionMode>(
                        key: const Key('voiceInteractionModeSegmentedButton'),
                        segments: const [
                          ButtonSegment(
                            value: _VoiceInteractionMode.quick,
                            label: Text('Quick'),
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
                    ],
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
                            Text(
                              'Voice Wizard',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_wizardStep.progressLabel} · ${_wizardStep.label}',
                              style: theme.textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                minHeight: 8,
                                value:
                                    (_wizardStep.index + 1) /
                                    VoiceWizardStep.values.length,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'One answer at a time. The assistant will move to the next step after each submission.',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              wizardPrompt ??
                                  'Let us build this one answer at a time.',
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
                                  onPressed: _wizardTurns.isEmpty
                                      ? null
                                      : _wizardBack,
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('Back'),
                                ),
                                TextButton.icon(
                                  key: const Key('voiceWizardResetButton'),
                                  onPressed: () =>
                                      _resetWizardDraft(keepMode: true),
                                  icon: const Icon(Icons.restart_alt),
                                  label: const Text('Reset'),
                                ),
                              ],
                            ),
                            if (wizardSummary != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Conversation',
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                wizardSummary,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                            if (wizardAiAnswer != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                'AI wizard assist',
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Use the suggestion or keep your own answer. The raw prompt stays review-first.',
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                wizardAiAnswer,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  FilledButton.tonalIcon(
                                    key: const Key(
                                      'voiceApplyAiWizardAnswerButton',
                                    ),
                                    onPressed: () =>
                                        _applyAiWizardAnswer(wizardAiAnswer),
                                    icon: const Icon(
                                      Icons.auto_fix_high_outlined,
                                    ),
                                    label: const Text('Use AI answer'),
                                  ),
                                  TextButton.icon(
                                    key: const Key(
                                      'voiceKeepManualWizardAnswerButton',
                                    ),
                                    onPressed: _acceptedAiWizardAnswer == null
                                        ? null
                                        : _clearAiWizardAnswer,
                                    icon: const Icon(Icons.edit_outlined),
                                    label: const Text('Keep manual answer'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (transcriptCleanupSummary != null) ...[
                    Card(
                      key: const Key('voiceTranscriptCleanupCard'),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transcript cleanup',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'The raw transcript stays untouched. This is only a shorter review note to make the capture easier to scan.',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              transcriptCleanupSummary,
                              style: theme.textTheme.bodyMedium,
                            ),
                            if (_acceptedAiTranscriptSummary != null) ...[
                              const SizedBox(height: 10),
                              TextButton.icon(
                                key: const Key(
                                  'voiceKeepManualSummaryButtonInline',
                                ),
                                onPressed: _clearAiTranscriptSummary,
                                icon: const Icon(Icons.undo_outlined),
                                label: const Text('Keep manual summary'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TranscriptPreviewCard(
                    controller: _transcriptController,
                    focusNode: _transcriptFocusNode,
                    onChanged: (_) => _handleTranscriptChanged(),
                    helperText: _mode == _VoiceInteractionMode.wizard
                        ? 'The wizard assembles the draft here from each answered step. Review the full command before saving.'
                        : 'Live microphone capture fills this field. Edit the words first, then save to the right local module.',
                  ),
                  const SizedBox(height: 16),
                  if (_mode != _VoiceInteractionMode.wizard &&
                      assistantResponse != null) ...[
                    Card(
                      key: const Key('voiceAssistantReplyCard'),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assistant Reply',
                              style: theme.textTheme.titleSmall,
                            ),
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
                                    _service.buildSpokenReplyFromParts(
                                      summary: assistantResponse.summary,
                                      nextStep: assistantResponse.nextStep,
                                    ),
                                    tone: VoiceSpeechTone.briefing,
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
                      title: briefingSummary,
                      summary: briefingNextStep,
                      reason: briefingReason,
                      details: [
                        if (conversationContext != null)
                          'Thread: ${conversationContext.threadScopeLabel}',
                        if (conversationContext != null)
                          conversationContext.entryCountLabel,
                        if (briefing.projectContext != null)
                          briefing.projectContext!,
                        if (briefing.threadContext != null)
                          briefing.threadContext!,
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      key: const Key('voiceBriefingCard'),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            VoiceBriefingReviewSurface(
                              isAiDraft: appliedAiBriefing != null,
                              summary: briefingSummary,
                              nextStep: briefingNextStep,
                              rawTranscript: rawTranscript,
                              projectContext: briefing.projectContext,
                              threadContext: briefing.threadContext,
                            ),
                            if (briefing.memorySummary != null ||
                                briefing.memoryHighlights.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                'Thread memory',
                                style: theme.textTheme.labelSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                briefing.memorySummary ??
                                    'The assistant is building memory from the current thread.',
                                style: theme.textTheme.bodySmall,
                              ),
                              if (briefing.memoryHighlights.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: briefing.memoryHighlights
                                      .map(
                                        (highlight) =>
                                            Chip(label: Text(highlight)),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                            if (briefing.plannerSummary != null ||
                                briefing.plannerSteps.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                'Suggested path',
                                style: theme.textTheme.labelSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                briefing.plannerSummary ??
                                    'The assistant is ready to suggest the next useful move.',
                                style: theme.textTheme.bodySmall,
                              ),
                              if (briefing.plannerSteps.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: briefing.plannerSteps
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                        final index = entry.key;
                                        final step = entry.value;
                                        return Chip(
                                          label: Text('${index + 1}. $step'),
                                        );
                                      })
                                      .toList(),
                                ),
                              ],
                            ],
                            const SizedBox(height: 10),
                            Text(
                              'AI Assist preview',
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
                                              visualDensity:
                                                  VisualDensity.compact,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              label: Text(
                                                'AI type: ${aiAssist.suggestedType!.label}',
                                              ),
                                            ),
                                          if (aiAssist.suggestedTitle != null)
                                            Chip(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              label: Text(
                                                'AI title: ${aiAssist.suggestedTitle}',
                                              ),
                                            ),
                                          if (aiAssist.suggestedSummary != null)
                                            Chip(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              label: Text(
                                                'AI summary: ${aiAssist.suggestedSummary}',
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
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                label: Text(hint),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        FilledButton.tonalIcon(
                                          key: const Key(
                                            'voiceApplyAiBriefingButton',
                                          ),
                                          onPressed: () =>
                                              _applyAiBriefingDraft(aiAssist),
                                          icon: const Icon(
                                            Icons.auto_fix_high_outlined,
                                          ),
                                          label: const Text('Use AI wording'),
                                        ),
                                        TextButton.icon(
                                          key: const Key(
                                            'voiceKeepManualBriefingButton',
                                          ),
                                          onPressed: _acceptedAiBriefing == null
                                              ? null
                                              : _clearAiBriefingDraft,
                                          icon: const Icon(Icons.edit_outlined),
                                          label: const Text(
                                            'Keep manual wording',
                                          ),
                                        ),
                                        if (aiAssist.suggestedTitle != null)
                                          OutlinedButton.icon(
                                            key: const Key(
                                              'voiceApplyAiTitleButton',
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _titleController.text =
                                                    aiAssist.suggestedTitle!;
                                                _titleController.selection =
                                                    TextSelection.collapsed(
                                                      offset: _titleController
                                                          .text
                                                          .length,
                                                    );
                                                _speechStatus =
                                                    'AI title applied. Review it before saving.';
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.title_outlined,
                                            ),
                                            label: const Text('Use AI title'),
                                          ),
                                        if (aiAssist.suggestedSummary != null)
                                          OutlinedButton.icon(
                                            key: const Key(
                                              'voiceApplyAiSummaryButton',
                                            ),
                                            onPressed: () =>
                                                _applyAiTranscriptSummary(
                                                  aiAssist.suggestedSummary!,
                                                ),
                                            icon: const Icon(
                                              Icons.short_text_outlined,
                                            ),
                                            label: const Text('Use AI summary'),
                                          ),
                                        if (_acceptedAiTranscriptSummary !=
                                            null)
                                          TextButton.icon(
                                            key: const Key(
                                              'voiceKeepManualSummaryButton',
                                            ),
                                            onPressed:
                                                _clearAiTranscriptSummary,
                                            icon: const Icon(
                                              Icons.undo_outlined,
                                            ),
                                            label: const Text(
                                              'Keep manual summary',
                                            ),
                                          ),
                                      ],
                                    ),
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
                                children: briefing.actions.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  final action = entry.value;
                                  return Tooltip(
                                    message: action.description,
                                    child: OutlinedButton.icon(
                                      key: Key(
                                        'voiceBriefingActionButton-${action.id}',
                                      ),
                                      onPressed: () =>
                                          _handleQuickAction(action),
                                      icon: Icon(_quickActionIcon(action.id)),
                                      label: Text(
                                        '${index + 1}. ${action.label}',
                                      ),
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
                                    _service.buildSpokenReplyFromParts(
                                      summary: briefingSummary,
                                      nextStep: briefing.nextStep,
                                    ),
                                    tone: VoiceSpeechTone.briefing,
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
                          Text(
                            'Action Macros',
                            style: theme.textTheme.titleMedium,
                          ),
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
                                      onPressed: () =>
                                          _handleQuickAction(action),
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
                              'daily-reset',
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
                              'project-update',
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
                            groupKey: const Key(
                              'voiceStarterDeckShortcutGroup',
                            ),
                            title: 'Shortcuts',
                            templateIds: const [
                              'project-checkpoint',
                              'carry-forward',
                              'meeting-notes',
                              'meeting-summary',
                              'quick-review',
                              'business-follow-up',
                              'voice-review',
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
                          Text(
                            'Command Router',
                            style: theme.textTheme.titleMedium,
                          ),
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
                                      key: Key(
                                        'voiceQuickActionButton-${action.id}',
                                      ),
                                      onPressed: () =>
                                          _handleQuickAction(action),
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
                            if (activeSuggestion.suggestedProjectName !=
                                null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Project: ${activeSuggestion.suggestedProjectName}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                            ..._buildStructuredSuggestionLines(
                              theme,
                              activeSuggestion,
                            ),
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
                                'Wake phrase detected: ${activeSuggestion.wakePhrase ?? 'Assistant'}',
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
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleCapturedSpeechTranscript(
    String transcript, {
    required String source,
  }) async {
    final cleanedTranscript = transcript.trim();
    if (cleanedTranscript.isEmpty || !mounted) {
      return;
    }

    final suggestion = _service.suggestCommand(transcript: cleanedTranscript);
    final followUpAction = _service.resolveFollowUpAction(
      transcript: cleanedTranscript,
      conversationContext: _conversationContext,
    );
    final route = followUpAction?.route;
    final navigationRequest =
        route != null ||
        _service.isDashboardNavigationRequest(cleanedTranscript);
    _lastAutoNavigatedSpeechTranscript = navigationRequest
        ? cleanedTranscript
        : null;

    setState(() {
      _speechAvailable = true;
      _isInitializingSpeech = false;
      _isListening = false;
      _activeSpeechController.text = cleanedTranscript;
      _activeSpeechController.selection = TextSelection.collapsed(
        offset: _activeSpeechController.text.length,
      );
      _speechError = null;
      _speechStatus = navigationRequest
          ? _navigationStatusForAction(followUpAction)
          : _mode == _VoiceInteractionMode.wizard
          ? 'Wizard answer captured. Review before continuing.'
          : 'Transcript captured. Review before saving.';
    });

    if (navigationRequest) {
      final destinationLabel = _navigationDestinationLabel(followUpAction);
      ref
          .read(voiceSessionProvider.notifier)
          .release(
            owner: VoiceSessionOwner.assistant,
            label: 'Assistant ready',
            detail: route != null
                ? 'Opening $destinationLabel'
                : 'Opening dashboard',
          );
      _setVoicePresence(
        label: 'Assistant ready',
        detail: route != null
            ? 'Opening $destinationLabel'
            : 'Opening dashboard',
        isActive: true,
        opacity: 0.82,
      );
      final assistantResponse = route != null
          ? VoiceCommandAssistantResponse(
              summary: _navigationStatusForAction(followUpAction),
              nextStep: 'You can continue from there.',
            )
          : _service.buildAssistantResponse(
              transcript: cleanedTranscript,
              suggestion: suggestion,
              conversationContext: _conversationContext,
            );
      unawaited(
        _speakWithCurrentVoice(
          assistantResponse.summary,
          tone: VoiceSpeechTone.briefing,
        ),
      );
      if (route != null) {
        context.go(route);
      } else {
        context.go(RouteNames.dashboard);
      }
      return;
    }

    ref
        .read(voiceSessionProvider.notifier)
        .beginProcessing(
          owner: VoiceSessionOwner.assistant,
          label: 'Assistant captured',
          detail: source == 'speech'
              ? 'Review transcript'
              : 'Review transcript',
          opacity: 0.82,
        );
    _setVoicePresence(
      label: 'Assistant captured',
      detail: 'Review transcript',
      isActive: true,
      opacity: 0.82,
    );
  }

  String _navigationStatusForAction(VoiceCommandQuickAction? action) {
    if (action == null) {
      return 'Opening the dashboard now. You are back on the main dashboard.';
    }

    final target = _navigationDestinationLabel(action);
    return 'Opening $target now.';
  }

  String _navigationDestinationLabel(VoiceCommandQuickAction? action) {
    if (action == null) {
      return 'the dashboard';
    }

    return action.label.replaceFirst(
      RegExp(
        r'^(Open|Show|Go to|Take me to|Navigate to|Bring up)\s+',
        caseSensitive: false,
      ),
      '',
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
      case 'daily-reset':
        return Icons.restart_alt_outlined;
      case 'project':
        return Icons.folder_open_outlined;
      case 'project-update':
        return Icons.update_outlined;
      case 'carry-forward':
        return Icons.forward_outlined;
      case 'meeting-notes':
        return Icons.meeting_room_outlined;
      case 'meeting-summary':
        return Icons.summarize_outlined;
      case 'project-checkpoint':
        return Icons.flag_outlined;
      case 'business-follow-up':
        return Icons.phone_forwarded_outlined;
      case 'quick-review':
        return Icons.rate_review_outlined;
      case 'voice-review':
        return Icons.fact_check_outlined;
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
