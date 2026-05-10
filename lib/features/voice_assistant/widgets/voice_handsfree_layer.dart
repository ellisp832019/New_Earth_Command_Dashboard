import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/routing/route_names.dart';
import '../application/voice_conversation_dock_controller.dart';
import '../application/voice_presence_controller.dart';
import '../../settings/application/settings_controller.dart';
import '../desktop_speech_bridge_service.dart';
import '../voice_command_model.dart';
import '../voice_speech_service.dart';
import '../voice_command_service.dart';
import '../windows_voice_typing_service.dart';

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

  Timer? _debounceTimer;
  bool _isStarted = false;
  String _lastDispatchedTranscript = '';
  bool _wakeOnlyRouteConsumed = false;
  bool _startupGreetingQueued = false;
  bool _startupGreetingCompleted = false;

  @override
  void initState() {
    super.initState();
    _captureController.addListener(_handleCaptureChanged);
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

  Future<void> _armHandsfreeListener() async {
    await Future<void>.delayed(
      WindowsVoiceTypingService.isSupported
          ? const Duration(milliseconds: 1200)
          : const Duration(milliseconds: 350),
    );
    if (!mounted) {
      return;
    }

    await _startHandsfreeListener();
  }

  Future<void> _startHandsfreeListener() async {
    if (!mounted || _isStarted) {
      return;
    }

    _isStarted = true;
    _setVoicePresence(
      label: 'Gaia listening',
      detail: 'Arming voice input',
      isActive: true,
      opacity: 0.72,
    );

    if (WindowsVoiceTypingService.isSupported) {
      _captureFocusNode.requestFocus();
      final capture = await _desktopSpeechBridgeService.captureOnce();
      if (!mounted) {
        return;
      }

      if (capture != null && capture.transcript.trim().isNotEmpty) {
        _setVoicePresence(
          label: 'Gaia captured',
          detail: 'Reviewing transcript',
          isActive: true,
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
        _setVoicePresence(
          label: 'Gaia idle',
          detail: 'Mic not available',
          isActive: false,
          opacity: 0.28,
        );
        _scheduleRearm();
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
      _setVoicePresence(
        label: 'Gaia idle',
        detail: 'Mic not available',
        isActive: false,
        opacity: 0.28,
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
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      WindowsVoiceTypingService.isSupported
          ? const Duration(seconds: 3)
          : const Duration(seconds: 2),
      () {
        if (!mounted) {
          return;
        }

        _isStarted = false;
        _setVoicePresence(
          label: 'Gaia listening',
          detail: 'Arming voice input',
          isActive: true,
          opacity: 0.72,
        );
        unawaited(_startHandsfreeListener());
      },
    );
  }

  Future<void> _runStartupGreetingAndArm() async {
    if (_startupGreetingCompleted || !mounted) {
      return;
    }

    _startupGreetingCompleted = true;

    final settingsSnapshot = ref
        .read(settingsSnapshotProvider)
        .maybeWhen(data: (snapshot) => snapshot, orElse: () => null);

    if (settingsSnapshot?.settings.voiceRepliesEnabled ?? false) {
      try {
        _setVoicePresence(
          label: 'Gaia greeting',
          detail: 'Getting ready to listen',
          isActive: true,
          opacity: 0.64,
        );
        await ref
            .read(voiceAssistantSpeechServiceProvider)
            .speak(
              'Gaia is here and ready.',
              enabled: true,
              rate: settingsSnapshot!.settings.preferredTtsVoiceRate,
              pitch: settingsSnapshot.settings.preferredTtsVoicePitch,
            );
      } catch (_) {
        // Best-effort greeting only.
      }
    }

    if (!mounted) {
      return;
    }

    unawaited(_armHandsfreeListener());
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
    final previousConversationContext =
        ref.read(voiceConversationDockProvider).conversationContext;
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
      _setVoicePresence(
        label: 'Gaia wake',
        detail: 'Opening Voice Assistant',
        isActive: true,
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
    _setVoicePresence(
      label: 'Gaia captured',
      detail: 'Conversation dock visible',
      isActive: true,
      opacity: 0.82,
    );
    final route = Uri(
      path: RouteNames.voiceAssistant,
      queryParameters: {'transcript': transcriptToOpen},
    ).toString();
    context.go(route);

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
      _setVoicePresence(
        label: 'Gaia captured',
        detail: 'Reviewing transcript',
        isActive: true,
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

  void _setVoicePresence({
    required String label,
    required String detail,
    required bool isActive,
    required double opacity,
  }) {
    ref
        .read(voicePresenceProvider.notifier)
        .setPresence(
          VoicePresenceState(
            label: label,
            detail: detail,
            isActive: isActive,
            opacity: opacity,
          ),
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
      final voices = await ref.read(voiceAssistantVoicesProvider.future);
      final selectedVoice = resolveConfiguredVoiceOption(
        voices: voices,
        preferredName: settingsSnapshot.settings.preferredTtsVoiceName,
        preferredLocale: settingsSnapshot.settings.preferredTtsVoiceLocale,
        preferredGender: settingsSnapshot.settings.preferredTtsVoiceGender,
        preferredIdentifier:
            settingsSnapshot.settings.preferredTtsVoiceIdentifier,
      );
      await ref.read(voiceAssistantSpeechServiceProvider).stop();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      await ref
          .read(voiceAssistantSpeechServiceProvider)
          .speak(
            '${response.summary} ${response.nextStep}',
            enabled: true,
            rate: settingsSnapshot.settings.preferredTtsVoiceRate,
            pitch: settingsSnapshot.settings.preferredTtsVoicePitch,
            voice: selectedVoice,
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

    if (settingsSnapshot != null &&
        !_startupGreetingQueued &&
        !_startupGreetingCompleted) {
      _startupGreetingQueued = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        unawaited(_runStartupGreetingAndArm());
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
                  autofocus: true,
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
