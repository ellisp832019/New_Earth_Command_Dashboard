import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/routing/route_names.dart';
import '../application/voice_conversation_dock_controller.dart';
import '../application/voice_assistant_turn_coordinator.dart';
import '../application/voice_session_controller.dart';
import '../../settings/application/settings_controller.dart';
import '../desktop_speech_bridge_service.dart';
import '../voice_command_model.dart';
import '../voice_speech_service.dart';
import '../voice_command_service.dart';
import '../windows_voice_typing_service.dart';
import '../voice_test_mode.dart';

class VoiceHandsfreeLayer extends ConsumerStatefulWidget {
  const VoiceHandsfreeLayer({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<VoiceHandsfreeLayer> createState() =>
      _VoiceHandsfreeLayerState();
}

class _VoiceHandsfreeLayerState extends ConsumerState<VoiceHandsfreeLayer> {
  final VoiceCommandService _service = VoiceCommandService();
  final DesktopSpeechBridgeService _desktopSpeechBridgeService =
      DesktopSpeechBridgeService();
  final SpeechToText _speech = SpeechToText();
  final TextEditingController _captureController = TextEditingController();
  final FocusNode _captureFocusNode = FocusNode(debugLabel: 'GaiaHandsfree');
  late final VoiceAssistantTurnCoordinator _turnCoordinator;

  Timer? _debounceTimer;
  bool _isStarted = false;
  bool _hasQueuedInitialArm = false;
  String _lastDispatchedTranscript = '';
  bool _wakeOnlyRouteConsumed = false;

  @override
  void initState() {
    super.initState();
    _turnCoordinator = ref.read(voiceAssistantTurnCoordinatorProvider);
    _captureController.addListener(_handleCaptureChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _queueHandsfreeArm());
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _speech.cancel();
    _captureController.removeListener(_handleCaptureChanged);
    _captureController.dispose();
    _captureFocusNode.dispose();
    super.dispose();
  }

  Future<void> _startHandsfreeListener() async {
    if (!mounted || _isStarted) {
      return;
    }

    final session = ref.read(voiceSessionProvider.notifier);
    if (!session.beginListening(
      owner: VoiceSessionOwner.handsfree,
      label: 'Gaia listening',
      detail: 'Arming voice input',
      opacity: 0.72,
    )) {
      _isStarted = false;
      _scheduleRearm();
      return;
    }

    _isStarted = true;

    if (WindowsVoiceTypingService.isSupported) {
      final capture = await _desktopSpeechBridgeService.captureOnce();
      if (!mounted) {
        return;
      }

      if (capture != null && capture.transcript.trim().isNotEmpty) {
        session.beginProcessing(
          owner: VoiceSessionOwner.handsfree,
          label: 'Gaia captured',
          detail: 'Reviewing transcript',
          opacity: 0.84,
        );
        _captureController.text = capture.transcript.trim();
        _captureController.selection = TextSelection.collapsed(
          offset: _captureController.text.length,
        );
        unawaited(_dispatchWakeTranscript(capture.transcript));
        _scheduleRearm();
        return;
      }

      final available = await WindowsVoiceTypingService.startVoiceTyping();
      if (!mounted) {
        return;
      }

      if (!available) {
        final speechAvailable = await _speech.initialize(
          onError: _onSpeechError,
          onStatus: _onSpeechStatus,
        );

        if (!mounted) {
          return;
        }

        if (!speechAvailable) {
          ref
              .read(voiceSessionProvider.notifier)
              .release(
                owner: VoiceSessionOwner.handsfree,
                label: 'Gaia idle',
                detail: 'Mic not available',
              );
          _scheduleRearm();
          return;
        }

        await _speech.listen(
          onResult: _onSpeechResult,
          listenFor: const Duration(minutes: 30),
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

        _captureFocusNode.requestFocus();
      } else {
        _captureFocusNode.requestFocus();
      }
      return;
    }

    final available = await _speech.initialize(
      onError: _onSpeechError,
      onStatus: _onSpeechStatus,
    );

    if (!mounted) {
      return;
    }

    if (!available) {
      ref
          .read(voiceSessionProvider.notifier)
          .release(
            owner: VoiceSessionOwner.handsfree,
            label: 'Gaia idle',
            detail: 'Mic not available',
          );
      return;
    }

    await _speech.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(minutes: 30),
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
  }

  void _scheduleRearm() {
    final settingsSnapshot = ref
        .read(settingsSnapshotProvider)
        .maybeWhen(data: (snapshot) => snapshot, orElse: () => null);
    if (settingsSnapshot?.settings.voiceAssistantEnabled != true) {
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      WindowsVoiceTypingService.isSupported
          ? const Duration(seconds: 3)
          : const Duration(seconds: 2),
      () {
        if (!mounted) {
          return;
        }

        final session = ref.read(voiceSessionProvider);
        if (!session.canBeClaimed) {
          _isStarted = false;
          _scheduleRearm();
          return;
        }

        _isStarted = false;
        unawaited(_queueHandsfreeArm(force: true));
      },
    );
  }

  Future<void> _queueHandsfreeArm({bool force = false}) async {
    if (!mounted) {
      return;
    }

    final settingsSnapshot = ref
        .read(settingsSnapshotProvider)
        .maybeWhen(data: (snapshot) => snapshot, orElse: () => null);
    if (settingsSnapshot?.settings.voiceAssistantEnabled != true) {
      return;
    }

    if (!force && (_hasQueuedInitialArm || _isStarted)) {
      return;
    }

    _hasQueuedInitialArm = true;
    await Future<void>.delayed(Duration.zero);
    if (!mounted) {
      return;
    }

    if (_isStarted) {
      return;
    }

    await _startHandsfreeListener();
  }

  void _handleCaptureChanged() {
    final transcript = _captureController.text.trim();
    if (transcript.isEmpty) {
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) {
        return;
      }

      unawaited(_dispatchWakeTranscript(transcript));
    });
  }

  Future<void> _dispatchWakeTranscript(String transcript) async {
    final suggestion = _service.suggestCommand(transcript: transcript);
    final cleanedTranscript = suggestion.transcript.trim();
    final transcriptToOpen = cleanedTranscript.isEmpty
        ? transcript.trim()
        : cleanedTranscript;

    if (transcriptToOpen.isEmpty) {
      return;
    }

    if (transcriptToOpen == _lastDispatchedTranscript) {
      return;
    }

    _captureController.clear();

    if (!mounted) {
      return;
    }

    final isWakeOnly = suggestion.usedWakePhrase && cleanedTranscript.isEmpty;
    final response = _service.buildAssistantResponse(
      transcript: transcriptToOpen.isEmpty
          ? (suggestion.wakePhrase ?? transcript.trim())
          : transcriptToOpen,
      suggestion: suggestion,
    );
    final previousConversationContext = ref
        .read(voiceConversationDockProvider)
        .conversationContext;
    final conversationContext = _service.buildConversationContext(
      transcript: transcriptToOpen.isEmpty
          ? (suggestion.wakePhrase ?? transcript.trim())
          : transcriptToOpen,
      type: suggestion.suggestedType,
      title: suggestion.suggestedTitle,
      projectId: suggestion.suggestedProjectId,
      projectName: suggestion.suggestedProjectName,
      previous: previousConversationContext,
    );

    final routeAction = _service.resolveFollowUpAction(
      transcript: transcriptToOpen,
      conversationContext: conversationContext,
    );
    final destinationRoute = routeAction?.route;
    if (destinationRoute != null) {
      _wakeOnlyRouteConsumed = false;
      _lastDispatchedTranscript = transcriptToOpen;
      final target = _navigationDestinationLabel(routeAction);
      final response = VoiceCommandAssistantResponse(
        summary: 'Opening $target now.',
        nextStep: 'You can continue from there.',
      );

      ref.read(voiceSessionProvider.notifier).handoff(
            from: VoiceSessionOwner.handsfree,
            to: VoiceSessionOwner.assistant,
            phase: VoiceSessionPhase.awaitingFollowUp,
            label: 'Gaia ready',
            detail: 'Opening $target',
            opacity: 0.82,
          );
      context.go(destinationRoute);
      _isStarted = false;
      _scheduleRearm();
      unawaited(_speakConversationResponse(response));
      return;
    }

    if (_service.isDashboardNavigationRequest(transcriptToOpen)) {
      _wakeOnlyRouteConsumed = false;
      _lastDispatchedTranscript = transcriptToOpen;
      ref
          .read(voiceSessionProvider.notifier)
          .handoff(
            from: VoiceSessionOwner.handsfree,
            to: VoiceSessionOwner.assistant,
            phase: VoiceSessionPhase.awaitingFollowUp,
            label: 'Gaia ready',
            detail: 'Opening dashboard',
            opacity: 0.82,
          );
      context.go(RouteNames.dashboard);
      _isStarted = false;
      _scheduleRearm();
      unawaited(_speakConversationResponse(response));
      return;
    }

    _showConversationDock(
      transcript: transcriptToOpen.isEmpty
          ? (suggestion.wakePhrase ?? transcript.trim())
          : transcriptToOpen,
      response: response,
      isWake: suggestion.usedWakePhrase || isWakeOnly,
      conversationContext: conversationContext,
    );
    if (isWakeOnly) {
      if (_wakeOnlyRouteConsumed) {
        return;
      }
      _wakeOnlyRouteConsumed = true;
      ref
          .read(voiceSessionProvider.notifier)
          .handoff(
            from: VoiceSessionOwner.handsfree,
            to: VoiceSessionOwner.assistant,
            phase: VoiceSessionPhase.awaitingFollowUp,
            label: 'Gaia wake',
            detail: 'Opening Voice Assistant',
            opacity: 0.82,
          );
      context.go(
        Uri(
          path: RouteNames.voiceAssistant,
          queryParameters: const {'wake': '1'},
        ).toString(),
      );
      _isStarted = false;
      _scheduleRearm();
      return;
    }

    await _speakConversationResponse(response);
    if (!mounted) {
      return;
    }

    _wakeOnlyRouteConsumed = false;
    _lastDispatchedTranscript = transcriptToOpen;
    ref
        .read(voiceSessionProvider.notifier)
        .handoff(
          from: VoiceSessionOwner.handsfree,
          to: VoiceSessionOwner.assistant,
          phase: VoiceSessionPhase.awaitingFollowUp,
          label: 'Gaia captured',
          detail: 'Conversation dock visible',
          opacity: 0.82,
        );
    final voiceAssistantRoute = Uri(
      path: RouteNames.voiceAssistant,
      queryParameters: {'transcript': transcriptToOpen},
    ).toString();
    context.go(voiceAssistantRoute);

    _isStarted = false;
    _scheduleRearm();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) {
      return;
    }

    _captureController.text = result.recognizedWords;
    _captureController.selection = TextSelection.collapsed(
      offset: _captureController.text.length,
    );

    if (result.finalResult) {
      ref
          .read(voiceSessionProvider.notifier)
          .beginProcessing(
            owner: VoiceSessionOwner.handsfree,
            label: 'Gaia captured',
            detail: 'Reviewing transcript',
            opacity: 0.84,
          );
      unawaited(_dispatchWakeTranscript(result.recognizedWords));
      _scheduleRearm();
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    if (!mounted) {
      return;
    }

    ref
        .read(voiceSessionProvider.notifier)
        .beginAwaitingFollowUp(
          owner: VoiceSessionOwner.handsfree,
          label: 'Gaia listening',
          detail: 'Speak your next command',
          opacity: 0.84,
        );
    _scheduleRearm();
  }

  void _onSpeechStatus(String status) {
    if (!mounted) {
      return;
    }

    if (status == 'done') {
      _scheduleRearm();
    }
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

  void _showConversationDock({
    required String transcript,
    required VoiceCommandAssistantResponse response,
    required bool isWake,
    required VoiceConversationContext conversationContext,
  }) {
    ref
        .read(voiceConversationDockProvider.notifier)
        .show(
          title: 'Gaia',
          summary: response.summary,
          nextStep: response.nextStep,
          transcript: transcript,
          isWake: isWake,
          projectContext: response.projectContext,
          threadContext: response.threadContext,
          conversationContext: conversationContext,
        );
  }

  Future<void> _speakConversationResponse(
    VoiceCommandAssistantResponse response,
  ) async {
    final settingsSnapshot = ref
        .read(settingsSnapshotProvider)
        .maybeWhen(data: (snapshot) => snapshot, orElse: () => null);
    if (settingsSnapshot == null ||
        !settingsSnapshot.settings.voiceRepliesEnabled) {
      return;
    }

    try {
      await _turnCoordinator.speak(
        VoiceAssistantTurnPlan(
          kind: VoiceAssistantTurnKind.dockFollowUp,
          owner: VoiceSessionOwner.handsfree,
          speakingLabel: 'Gaia speaking',
          speakingDetail: 'Reading back the response',
          followUpLabel: 'Gaia ready',
          followUpDetail: 'Handsfree listener ready',
          text: VoiceCommandService().buildSpokenReply(response),
          settings: settingsSnapshot.settings,
          tone: VoiceSpeechTone.briefing,
          response: response,
        ),
      );
    } catch (_) {
      // Best-effort only. The dock should still render even if speech fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsSnapshot = ref
        .watch(settingsSnapshotProvider)
        .maybeWhen(data: (snapshot) => snapshot, orElse: () => null);
    final voiceAssistantEnabled =
        settingsSnapshot?.settings.voiceAssistantEnabled ?? true;

    if (isRunningUnderTest()) {
      return widget.child;
    }

    if (!voiceAssistantEnabled) {
      if (_isStarted) {
        _speech.cancel();
        _isStarted = false;
      }
      _hasQueuedInitialArm = false;
      return widget.child;
    }

    if (!_isStarted && !_hasQueuedInitialArm) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_queueHandsfreeArm());
      });
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(
          left: 0,
          top: 0,
          child: Opacity(
            opacity: 0.01,
            child: Material(
              type: MaterialType.transparency,
              child: SizedBox(
                width: 1,
                height: 1,
                child: TextField(
                  controller: _captureController,
                  focusNode: _captureFocusNode,
                  // Only grab focus when we arm capture. Keeping this field
                  // unfocused at startup avoids a permanent keyboard target
                  // on Windows that can interfere with key event bookkeeping.
                  autofocus: false,
                  enableInteractiveSelection: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontSize: 1, height: 1),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
