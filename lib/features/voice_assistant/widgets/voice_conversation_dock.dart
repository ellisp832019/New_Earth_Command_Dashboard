import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../settings/application/settings_controller.dart';
import '../application/voice_conversation_dock_controller.dart';
import '../application/voice_session_controller.dart';
import '../desktop_speech_bridge_service.dart';
import '../voice_command_model.dart';
import '../voice_command_service.dart';
import '../voice_speech_service.dart';

class VoiceConversationDock extends ConsumerStatefulWidget {
  const VoiceConversationDock({super.key});

  @override
  ConsumerState<VoiceConversationDock> createState() =>
      _VoiceConversationDockState();
}

class _VoiceConversationDockState extends ConsumerState<VoiceConversationDock> {
  final DesktopSpeechBridgeService _desktopSpeechBridgeService =
      DesktopSpeechBridgeService();
  final TextEditingController _followUpController = TextEditingController();
  final FocusNode _followUpFocusNode = FocusNode();
  bool _isCapturingFollowUp = false;
  String _followUpStatus = 'Speak a short follow-up or type it here.';

  @override
  void dispose() {
    _followUpController.dispose();
    _followUpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dock = ref.watch(voiceConversationDockProvider);
    if (!dock.visible) {
      return const SizedBox.shrink();
    }

    final voiceService = VoiceCommandService();
    final suggestion = dock.transcript.trim().isEmpty
        ? null
        : voiceService.suggestCommand(transcript: dock.transcript);
    final quickActions = dock.transcript.trim().isEmpty
        ? const <VoiceCommandQuickAction>[]
        : voiceService
              .suggestQuickActions(
                transcript: dock.transcript,
                suggestion: suggestion,
              )
              .take(4)
              .toList();
    final macroActions = voiceService
        .buildMacroActions(conversationContext: dock.conversationContext)
        .where((action) => action.id != 'continue-thread')
        .take(5)
        .toList();
    final followUpActions = <VoiceCommandQuickAction>[
      ...quickActions,
      if (dock.conversationContext != null)
        const VoiceCommandQuickAction(
          id: 'continue-thread',
          label: 'Continue Thread',
          description: 'Pick up the current thread from the dock.',
        ),
    ];

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: 1.0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height - 32,
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColours.darkSurface.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: dock.isWake
                      ? AppColours.darkSuccess.withValues(alpha: 0.35)
                      : AppColours.darkSecondary.withValues(alpha: 0.28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          dock.isWake ? Icons.graphic_eq_rounded : Icons.mic,
                          color: dock.isWake
                              ? AppColours.darkSuccess
                              : AppColours.darkSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dock.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColours.darkText,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => ref
                              .read(voiceConversationDockProvider.notifier)
                              .hide(),
                          icon: const Icon(Icons.close_rounded),
                          color: AppColours.darkMutedText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dock.summary,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkText,
                        height: 1.3,
                      ),
                    ),
                    if (dock.projectContext != null ||
                        dock.threadContext != null) ...[
                      const SizedBox(height: 12),
                      if (dock.projectContext != null) ...[
                        Text(
                          'Project context',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColours.darkSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dock.projectContext!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColours.darkText,
                                height: 1.35,
                              ),
                        ),
                      ],
                      if (dock.threadContext != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Thread context',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColours.darkSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dock.threadContext!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColours.darkText,
                                height: 1.35,
                              ),
                        ),
                      ],
                    ],
                    if (dock.transcript.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Captured transcript',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColours.darkSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColours.darkSurfaceAlt.withValues(
                            alpha: 0.92,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColours.darkOutline),
                        ),
                        child: Text(
                          dock.transcript,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColours.darkText,
                                height: 1.35,
                              ),
                        ),
                      ),
                    ],
                    if (dock.nextStep.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Next step',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColours.darkSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dock.nextStep,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColours.darkMutedText,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Text(
                      'Quick reply',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColours.darkSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      key: const Key('voiceConversationFollowUpField'),
                      controller: _followUpController,
                      focusNode: _followUpFocusNode,
                      minLines: 1,
                      maxLines: 2,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: dock.transcript.isEmpty
                            ? 'Ask Gaia what she can do...'
                            : 'Ask a short follow-up about this thread...',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          key: const Key('voiceConversationFollowUpSendButton'),
                          onPressed: () => _submitFollowUp(),
                          icon: const Icon(Icons.send_outlined),
                        ),
                      ),
                      onSubmitted: (_) => _submitFollowUp(),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          key: const Key(
                            'voiceConversationSpeakFollowUpButton',
                          ),
                          onPressed: _isCapturingFollowUp
                              ? null
                              : () => _captureFollowUp(),
                          icon: _isCapturingFollowUp
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.mic_rounded),
                          label: Text(
                            _isCapturingFollowUp
                                ? 'Listening'
                                : 'Speak Follow-up',
                          ),
                        ),
                        TextButton.icon(
                          key: const Key('voiceConversationSendReplyButton'),
                          onPressed: _submitFollowUp,
                          icon: const Icon(Icons.send_outlined),
                          label: const Text('Send Reply'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _followUpStatus,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                    ),
                    if (followUpActions.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Quick follow-up',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColours.darkSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: followUpActions
                            .map(
                              (action) => ActionChip(
                                avatar: Icon(
                                  _dockActionIcon(action),
                                  size: 18,
                                  color: AppColours.darkText,
                                ),
                                label: Text(action.label),
                                onPressed: () => _handleDockAction(
                                  context,
                                  action,
                                  dock,
                                  voiceService,
                                  suggestion,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    if (macroActions.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Action macros',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColours.darkSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: macroActions
                            .map(
                              (action) => ActionChip(
                                avatar: Icon(
                                  _dockActionIcon(action),
                                  size: 18,
                                  color: AppColours.darkText,
                                ),
                                label: Text(action.label),
                                onPressed: () => _handleDockAction(
                                  context,
                                  action,
                                  dock,
                                  voiceService,
                                  suggestion,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: dock.transcript.isEmpty
                              ? null
                              : () {
                                  _openVoiceAssistant(
                                    context,
                                    dock.conversationContext?.transcript ??
                                        dock.transcript,
                                    dock.isWake,
                                    dock.conversationContext?.type ??
                                        suggestion?.suggestedType,
                                  );
                                },
                          icon: const Icon(Icons.open_in_new_rounded),
                          label: const Text('Open Assistant'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => ref
                              .read(voiceConversationDockProvider.notifier)
                              .hide(),
                          icon: const Icon(Icons.visibility_off_outlined),
                          label: const Text('Hide'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleDockAction(
    BuildContext context,
    VoiceCommandQuickAction action,
    VoiceConversationDockState dock,
    VoiceCommandService service,
    VoiceCommandSuggestion? suggestion,
  ) {
    if (action.route != null) {
      context.go(action.route!);
      return;
    }

    if (action.templateId != null) {
      final template = service.getTemplateById(action.templateId!);
      if (template != null) {
        _openVoiceAssistant(
          context,
          template.transcript,
          dock.isWake,
          template.type,
        );
        return;
      }
    }

    if (action.id == 'continue-thread') {
      _openVoiceAssistant(
        context,
        dock.conversationContext?.transcript ?? dock.transcript,
        dock.isWake,
        dock.conversationContext?.type ?? suggestion?.suggestedType,
      );
    }
  }

  Future<void> _submitFollowUp() async {
    final reply = _followUpController.text.trim();
    if (reply.isEmpty) {
      return;
    }

    final dock = ref.read(voiceConversationDockProvider);
    final service = VoiceCommandService();
    final suggestion = service.suggestCommand(transcript: reply);
    ref
        .read(voiceSessionProvider.notifier)
        .beginProcessing(
          owner: VoiceSessionOwner.dock,
          label: 'Gaia processing',
          detail: 'Shaping the follow-up',
          opacity: 0.72,
        );
    final response = ref
        .read(voiceConversationDockProvider.notifier)
        .respondToFollowUp(reply);
    if (response == null) {
      return;
    }

    final action = service.resolveFollowUpAction(
      transcript: reply,
      conversationContext: dock.conversationContext,
    );

    _followUpController.clear();
    _followUpFocusNode.requestFocus();
    ref
        .read(voiceSessionProvider.notifier)
        .beginSpeaking(
          owner: VoiceSessionOwner.dock,
          label: 'Gaia speaking',
          detail: 'Answering the follow-up',
          opacity: 0.72,
        );
    await _speakResponse(response);

    if (!mounted) {
      return;
    }

    if (action != null) {
      if (mounted) {
        setState(() {
          _followUpStatus = 'Gaia is acting on that follow-up.';
        });
      }
      _handleDockAction(context, action, dock, service, suggestion);
      return;
    }

    if (mounted) {
      setState(() {
        _followUpStatus =
            'Follow-up captured. Ask another question or use a macro.';
      });
    }
    ref
        .read(voiceSessionProvider.notifier)
        .beginAwaitingFollowUp(
          owner: VoiceSessionOwner.dock,
          label: 'Gaia ready',
          detail: 'Ask another follow-up',
          opacity: 0.64,
        );
  }

  Future<void> _captureFollowUp() async {
    if (_isCapturingFollowUp) {
      return;
    }

    setState(() {
      _isCapturingFollowUp = true;
      _followUpStatus = 'Listening for a follow-up...';
    });

    try {
      final session = ref.read(voiceSessionProvider.notifier);
      if (!session.beginListening(
        owner: VoiceSessionOwner.dock,
        label: 'Gaia listening',
        detail: 'Listening for a follow-up',
        opacity: 0.72,
      )) {
        if (mounted) {
          setState(() {
            _followUpStatus = 'Another voice session is already active.';
          });
        }
        return;
      }
      await ref.read(voiceAssistantSpeechServiceProvider).stop();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      final capture = await _desktopSpeechBridgeService.captureOnce(
        durationSeconds: 6,
      );
      if (!mounted) {
        return;
      }

      final transcript = capture?.transcript.trim() ?? '';
      if (transcript.isEmpty) {
        setState(() {
          _followUpStatus = 'No follow-up heard. Try again or type it.';
        });
        ref
            .read(voiceSessionProvider.notifier)
            .beginAwaitingFollowUp(
              owner: VoiceSessionOwner.dock,
              label: 'Gaia ready',
              detail: 'Ask another follow-up',
              opacity: 0.64,
            );
        return;
      }

      _followUpController.text = transcript;
      _followUpController.selection = TextSelection.collapsed(
        offset: transcript.length,
      );
      setState(() {
        _followUpStatus = 'Follow-up captured. Processing it now.';
      });
      ref
          .read(voiceSessionProvider.notifier)
          .beginProcessing(
            owner: VoiceSessionOwner.dock,
            label: 'Gaia captured',
            detail: 'Processing the follow-up',
            opacity: 0.84,
          );
      await _submitFollowUp();
    } finally {
      if (mounted) {
        setState(() {
          _isCapturingFollowUp = false;
        });
      }
    }
  }

  Future<void> _speakResponse(VoiceCommandAssistantResponse response) async {
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
      // Best-effort only. The dock should still update even if speech fails.
    }
  }

  void _openVoiceAssistant(
    BuildContext context,
    String transcript,
    bool isWake,
    VoiceCommandType? type,
  ) {
    context.go(
      Uri(
        path: RouteNames.voiceAssistant,
        queryParameters: {
          if (transcript.trim().isNotEmpty) 'transcript': transcript.trim(),
          if (isWake) 'wake': '1',
          if (type != null) 'type': type.name,
        },
      ).toString(),
    );
  }

  IconData _dockActionIcon(VoiceCommandQuickAction action) {
    switch (action.id) {
      case 'open-tasks':
      case 'load-task':
      case 'open-tasks-next':
        return Icons.task_alt_outlined;
      case 'open-projects':
      case 'open-projects-next':
      case 'load-project':
        return Icons.folder_open_outlined;
      case 'open-planner':
      case 'open-planner-summary':
      case 'load-build-day':
      case 'start-build-day':
        return Icons.event_note_outlined;
      case 'whats-next':
        return Icons.alt_route_outlined;
      case 'summarize-today':
      case 'load-summarize-today':
        return Icons.summarize_outlined;
      case 'open-journal':
      case 'load-journal':
        return Icons.menu_book_outlined;
      case 'open-content':
      case 'load-content':
        return Icons.article_outlined;
      case 'open-business':
      case 'load-business':
        return Icons.work_outline;
      case 'open-inbox':
        return Icons.inbox_outlined;
      case 'continue-thread':
        return Icons.play_arrow_outlined;
      default:
        return Icons.arrow_forward_outlined;
    }
  }
}
