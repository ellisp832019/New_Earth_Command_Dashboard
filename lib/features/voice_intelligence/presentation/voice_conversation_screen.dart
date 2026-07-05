import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/voice_module_providers.dart';
import '../application/voice_session_controller.dart';
import '../application/voice_thread_controller.dart';
import '../data/voice_models.dart';
import 'voice_thread_summary_strip.dart';
import '../../voice_assistant/application/voice_session_controller.dart'
    as legacy_session;

class VoiceConversationScreen extends ConsumerStatefulWidget {
  const VoiceConversationScreen({super.key});

  @override
  ConsumerState<VoiceConversationScreen> createState() =>
      _VoiceConversationScreenState();
}

class _VoiceConversationScreenState
    extends ConsumerState<VoiceConversationScreen> {
  final TextEditingController _draftController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref
          .read(voiceConversationThreadProvider.notifier)
          .ensureConversationSeeded();
      final thread = ref.read(voiceConversationThreadProvider);
      if (_draftController.text.isEmpty && thread.draftText.isNotEmpty) {
        _draftController.text = thread.draftText;
      }
    });
  }

  @override
  void dispose() {
    _draftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(voiceSessionControllerProvider);
    final legacyVoiceSession = ref.watch(legacy_session.voiceSessionProvider);
    final thread = ref.watch(voiceConversationThreadProvider);
    final pinnedTurn = thread.pinnedTurnBody?.trim().isNotEmpty == true
        ? _PinnedTurnSnapshot(
            title: thread.pinnedTurnTitle ?? 'Current turn',
            body: thread.pinnedTurnBody!.trim(),
            note: thread.pinnedTurnNote?.trim(),
          )
        : null;
    final promptChips = thread.prompts.isEmpty
        ? _defaultPrompts()
        : thread.prompts;

    return WorkspaceShell(
      title: 'Voice Conversation',
      subtitle: 'Local voice conversation workspace',
      onBack: () => context.go(RouteNames.voiceHome()),
      trailingActions: [
        TextButton.icon(
          onPressed: () => context.go(RouteNames.voiceHome()),
          icon: const Icon(Icons.home_outlined),
          label: const Text('Home'),
        ),
      ],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 980;
              final timeline = _ConversationTimeline(thread: thread);
              final guide = _ConversationGuide(
                thread: thread,
                promptChips: promptChips,
                onPromptSelected: (prompt) {
                  if (prompt.route == null) {
                    _draftController.text = prompt.label;
                    _draftController.selection = TextSelection.collapsed(
                      offset: _draftController.text.length,
                    );
                    ref
                        .read(voiceConversationThreadProvider.notifier)
                        .setDraftText(_draftController.text);
                    return;
                  }

                  context.go(prompt.route!);
                },
                onContinueHere: () {
                  final threadLabel = thread.threadTitle == 'No thread yet'
                      ? 'the conversation'
                      : thread.threadTitle.toLowerCase();
                  final starter =
                      'Let us keep the conversation moving from $threadLabel.';
                  _draftController.text = starter;
                  _draftController.selection = TextSelection.collapsed(
                    offset: starter.length,
                  );
                  ref
                      .read(voiceConversationThreadProvider.notifier)
                      .setDraftText(starter);
                },
              );

              if (isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ConversationHeader(thread: thread, session: session),
                    const SizedBox(height: 16),
                    _LiveSessionBanner(session: legacyVoiceSession),
                    const SizedBox(height: 16),
                    if (pinnedTurn != null) ...[
                      _PinnedTurnReveal(
                        snapshot: pinnedTurn,
                        session: legacyVoiceSession,
                        accent: _legacySessionAccent(legacyVoiceSession),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (session.recordingActive) ...[
                      _RecordingBanner(session: session),
                      const SizedBox(height: 16),
                    ],
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: timeline),
                          const SizedBox(width: 16),
                          SizedBox(width: 340, child: guide),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ConversationComposer(
                      controller: _draftController,
                      isSending: thread.isSending,
                      onChanged: (value) {
                        ref
                            .read(voiceConversationThreadProvider.notifier)
                            .setDraftText(value);
                      },
                      onSend: () => _sendConversation(thread),
                    ),
                  ],
                );
              }

              return ListView(
                children: [
                  _ConversationHeader(thread: thread, session: session),
                  const SizedBox(height: 16),
                  _LiveSessionBanner(session: legacyVoiceSession),
                  const SizedBox(height: 16),
                  if (pinnedTurn != null) ...[
                    _PinnedTurnReveal(
                      snapshot: pinnedTurn,
                      session: legacyVoiceSession,
                      accent: _legacySessionAccent(legacyVoiceSession),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (session.recordingActive) ...[
                    _RecordingBanner(session: session),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(height: 420, child: timeline),
                  const SizedBox(height: 16),
                  guide,
                  const SizedBox(height: 16),
                  _ConversationComposer(
                    controller: _draftController,
                    isSending: thread.isSending,
                    onChanged: (value) {
                      ref
                          .read(voiceConversationThreadProvider.notifier)
                          .setDraftText(value);
                    },
                    onSend: () => _sendConversation(thread),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _sendConversation(VoiceConversationThreadState thread) async {
    final message = _draftController.text.trim();
    if (message.isEmpty || thread.isSending) {
      return;
    }

    final threadController = ref.read(voiceConversationThreadProvider.notifier);
    final assistant = ref.read(voiceAssistantServiceProvider);
    final logger = ref.read(voiceAuditLoggerProvider.notifier);

    threadController.setSending(true);
    threadController.appendUserMessage(message, title: 'You');
    _draftController.clear();
    threadController.setDraftText('');

    try {
      final response = await assistant.createMockResponse(message: message);
      final intent = response.intents.isEmpty
          ? 'dashboard.assistant.unknown'
          : response.intents.first;

      if (response.safetyDecision.allowed) {
        threadController.appendAssistantMessage(
          response.reply,
          title: 'Dashboard reply',
          intent: intent,
        );
      } else {
        threadController.appendSafetyMessage(
          response.reply,
          title: 'Safety gate',
          intent: intent,
        );
      }

      threadController.rememberThread(
        threadTitle: 'Voice Conversation',
        summary: response.reply,
        nextStep: response.safetyDecision.allowed
            ? 'Keep talking here, or branch into notes, meetings, assistant, or MicroGrow status.'
            : 'Review the blocked request and keep hardware writes out of V1.',
        resumeRoute: RouteNames.voiceConversation,
        latestCaptureLabel: 'Conversation reply',
        latestCapturePreview: response.reply,
        lastThingYouSaid: message,
        reviewPrompt: response.safetyDecision.allowed
            ? 'Review the reply before saving anything locally.'
            : 'Review the blocked request and stay in read-only mode.',
        prompts: _conversationPromptsFor(
          intent,
          response.safetyDecision.allowed,
        ),
        isFresh: false,
      );

      logger.record(
        VoiceAuditEntry(
          id: 'voice-conversation-${DateTime.now().millisecondsSinceEpoch}',
          timestamp: DateTime.now(),
          section: 'Voice Conversation',
          userText: message,
          intent: intent,
          safetyDecision: response.safetyDecision,
          resultSummary: response.reply,
        ),
      );
    } finally {
      threadController.setSending(false);
    }
  }

  List<VoiceConversationPrompt> _conversationPromptsFor(
    String intent,
    bool allowed,
  ) {
    if (!allowed) {
      return const [
        VoiceConversationPrompt(
          label: 'Review safety log',
          description:
              'Open the audit log and check why the request was blocked.',
          route: RouteNames.voiceAudit,
        ),
        VoiceConversationPrompt(
          label: 'Return home',
          description: 'Go back to the calm voice hub.',
          route: RouteNames.voiceHomeRoute,
        ),
      ];
    }

    return switch (intent) {
      'microgrow.status.read' => const [
        VoiceConversationPrompt(
          label: 'Check MicroGrow again',
          description: 'Open the read-only MicroGrow status view.',
          route: RouteNames.voiceMicrogrow,
        ),
        VoiceConversationPrompt(
          label: 'Review audit log',
          description: 'Check the voice audit entries.',
          route: RouteNames.voiceAudit,
        ),
        VoiceConversationPrompt(
          label: 'Return home',
          description: 'Go back to the calm voice hub.',
          route: RouteNames.voiceHomeRoute,
        ),
      ],
      'meeting.summary.create' => const [
        VoiceConversationPrompt(
          label: 'Open meetings',
          description: 'Move the conversation into the meeting transcriber.',
          route: RouteNames.voiceMeetings,
        ),
        VoiceConversationPrompt(
          label: 'Ask a follow-up',
          description: 'Stay in the conversation and keep talking.',
          route: RouteNames.voiceConversation,
        ),
        VoiceConversationPrompt(
          label: 'Return home',
          description: 'Go back to the calm voice hub.',
          route: RouteNames.voiceHomeRoute,
        ),
      ],
      'dashboard.task.create' => const [
        VoiceConversationPrompt(
          label: 'Open voice notes',
          description: 'Capture the idea as a note first.',
          route: RouteNames.voiceNotes,
        ),
        VoiceConversationPrompt(
          label: 'Ask a follow-up',
          description: 'Keep the dashboard conversation going.',
          route: RouteNames.voiceConversation,
        ),
        VoiceConversationPrompt(
          label: 'Return home',
          description: 'Go back to the calm voice hub.',
          route: RouteNames.voiceHomeRoute,
        ),
      ],
      _ => const [
        VoiceConversationPrompt(
          label: 'Open voice notes',
          description: 'Capture a calmer note from the conversation.',
          route: RouteNames.voiceNotes,
        ),
        VoiceConversationPrompt(
          label: 'Open MicroGrow',
          description: 'Check the read-only status snapshot.',
          route: RouteNames.voiceMicrogrow,
        ),
        VoiceConversationPrompt(
          label: 'Return home',
          description: 'Go back to the calm voice hub.',
          route: RouteNames.voiceHomeRoute,
        ),
      ],
    };
  }
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader({required this.thread, required this.session});

  final VoiceConversationThreadState thread;
  final VoiceSessionState session;

  @override
  Widget build(BuildContext context) {
    final displayTitle = thread.threadTitle == 'No thread yet'
        ? 'Voice Conversation'
        : thread.threadTitle;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.forum_outlined, color: AppColours.darkSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  displayTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            thread.summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          VoiceThreadSummaryStrip(thread: thread),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(
                label: session.recordingActive
                    ? 'Recording visible'
                    : 'Recording idle',
                accent: session.recordingActive
                    ? AppColours.darkSuccess
                    : AppColours.darkMutedText,
              ),
              _InfoChip(
                label: thread.reviewPrompt,
                accent: AppColours.darkSecondary,
              ),
              _InfoChip(
                label: thread.nextStep,
                accent: AppColours.darkMutedText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveSessionBanner extends StatelessWidget {
  const _LiveSessionBanner({required this.session});

  final legacy_session.VoiceSessionState session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = session.isActive;
    final isDock = session.owner == legacy_session.VoiceSessionOwner.dock;
    final isAssistant =
        session.owner == legacy_session.VoiceSessionOwner.assistant;
    final accent = _legacySessionAccent(session);

    final label = isActive
        ? '${session.owner.displayLabel} · ${session.phase.displayLabel}'
        : 'Legacy dock idle';
    final detail = isActive
        ? isDock
              ? 'The legacy dock is part of the same shared thread.'
              : isAssistant
              ? 'The assistant is working in the same voice session.'
              : 'The shared voice session is active.'
        : 'No voice session is active right now.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Icon(
            isDock
                ? Icons.hearing_outlined
                : isAssistant
                ? Icons.smart_toy_outlined
                : Icons.graphic_eq_outlined,
            color: accent,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTimeline extends StatelessWidget {
  const _ConversationTimeline({required this.thread});

  final VoiceConversationThreadState thread;

  @override
  Widget build(BuildContext context) {
    final entries = thread.conversationEntries;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conversation',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Start the conversation with a question, a task, or a status check. The reply stays mock-first and review-first.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColours.darkMutedText,
                          height: 1.45,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _ConversationBubble(entry: entry);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ConversationBubble extends StatelessWidget {
  const _ConversationBubble({required this.entry});

  final VoiceConversationMessage entry;

  @override
  Widget build(BuildContext context) {
    final isUser = entry.kind == VoiceConversationMessageKind.user;
    final isSafety = entry.kind == VoiceConversationMessageKind.safety;
    final isSystem = entry.kind == VoiceConversationMessageKind.system;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final background = switch (entry.kind) {
      VoiceConversationMessageKind.user => AppColours.darkSecondary.withValues(
        alpha: 0.14,
      ),
      VoiceConversationMessageKind.assistant =>
        AppColours.darkSurfaceRaised.withValues(alpha: 0.95),
      VoiceConversationMessageKind.system =>
        AppColours.darkSurfaceAlt.withValues(alpha: 0.95),
      VoiceConversationMessageKind.safety => AppColours.darkAmber.withValues(
        alpha: 0.12,
      ),
    };
    final border = switch (entry.kind) {
      VoiceConversationMessageKind.user => AppColours.darkSecondary.withValues(
        alpha: 0.25,
      ),
      VoiceConversationMessageKind.assistant => AppColours.darkOutline,
      VoiceConversationMessageKind.system => AppColours.darkOutline,
      VoiceConversationMessageKind.safety => AppColours.darkAmber.withValues(
        alpha: 0.28,
      ),
    };
    final titleColor = switch (entry.kind) {
      VoiceConversationMessageKind.user => AppColours.darkSecondary,
      VoiceConversationMessageKind.assistant => AppColours.darkText,
      VoiceConversationMessageKind.system => AppColours.darkMutedText,
      VoiceConversationMessageKind.safety => AppColours.darkAmber,
    };

    return Align(
      alignment: alignment,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUser
                      ? Icons.person_outline
                      : isSafety
                      ? Icons.shield_outlined
                      : isSystem
                      ? Icons.auto_awesome_outlined
                      : Icons.smart_toy_outlined,
                  size: 16,
                  color: titleColor,
                ),
                const SizedBox(width: 6),
                Text(
                  entry.title ?? _defaultTitle(entry.kind),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkText,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDateTime(entry.timestamp),
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColours.darkMutedText),
            ),
            if (entry.intent != null) ...[
              const SizedBox(height: 6),
              Text(
                'Intent: ${entry.intent}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _defaultTitle(VoiceConversationMessageKind kind) {
    return switch (kind) {
      VoiceConversationMessageKind.system => 'System',
      VoiceConversationMessageKind.user => 'You',
      VoiceConversationMessageKind.assistant => 'Dashboard',
      VoiceConversationMessageKind.safety => 'Safety Gateway',
    };
  }
}

class _ConversationGuide extends StatelessWidget {
  const _ConversationGuide({
    required this.thread,
    required this.promptChips,
    required this.onPromptSelected,
    required this.onContinueHere,
  });

  final VoiceConversationThreadState thread;
  final List<VoiceConversationPrompt> promptChips;
  final ValueChanged<VoiceConversationPrompt> onPromptSelected;
  final VoidCallback onContinueHere;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Guide the flow',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use the conversation to choose the next calm step. Branch into notes, meetings, MicroGrow status, or keep talking here.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              _InfoChip(
                label: 'Last thing you said: ${thread.lastThingYouSaid}',
                accent: AppColours.darkSecondary,
              ),
              const SizedBox(height: 10),
              _InfoChip(
                label: 'Latest capture: ${thread.latestCaptureLabel}',
                accent: AppColours.darkMutedText,
              ),
              const SizedBox(height: 14),
              FilledButton.tonalIcon(
                onPressed: onContinueHere,
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Continue here'),
              ),
              const SizedBox(height: 14),
              Text(
                'Next moves',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: promptChips
                    .map(
                      (prompt) => Tooltip(
                        message: prompt.description,
                        child: ActionChip(
                          label: Text(prompt.label),
                          avatar: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                          ),
                          onPressed: () => onPromptSelected(prompt),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          );

          if (!constraints.hasBoundedHeight) {
            return content;
          }

          return SingleChildScrollView(child: content);
        },
      ),
    );
  }
}

class _PinnedTurnSnapshot {
  const _PinnedTurnSnapshot({
    required this.title,
    required this.body,
    this.note,
  });

  final String title;
  final String body;
  final String? note;
}

class _PinnedTurnCard extends StatelessWidget {
  const _PinnedTurnCard({
    super.key,
    required this.snapshot,
    required this.highlighted,
    required this.accent,
  });

  final _PinnedTurnSnapshot snapshot;
  final bool highlighted;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = highlighted
        ? accent.withValues(alpha: 0.14)
        : AppColours.darkSurfaceRaised.withValues(alpha: 0.94);
    final borderColor = highlighted
        ? accent.withValues(alpha: 0.32)
        : accent.withValues(alpha: 0.24);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.16),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.push_pin_outlined,
                color: AppColours.darkSuccess,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                snapshot.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            snapshot.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkText,
              height: 1.35,
            ),
          ),
          if (snapshot.note != null && snapshot.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              snapshot.note!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PinnedTurnReveal extends StatelessWidget {
  const _PinnedTurnReveal({
    required this.snapshot,
    required this.session,
    required this.accent,
  });

  final _PinnedTurnSnapshot snapshot;
  final legacy_session.VoiceSessionState session;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final highlighted =
        session.phase == legacy_session.VoiceSessionPhase.speaking ||
        session.phase == legacy_session.VoiceSessionPhase.awaitingFollowUp;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final slide =
            Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: _PinnedTurnCard(
        key: ValueKey('${snapshot.title}|${snapshot.body}|${snapshot.note}'),
        snapshot: snapshot,
        highlighted: highlighted,
        accent: accent,
      ),
    );
  }
}

class _ConversationComposer extends StatelessWidget {
  const _ConversationComposer({
    required this.controller,
    required this.isSending,
    required this.onChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('voiceConversationReplyBox'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reply box',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            onChanged: onChanged,
            minLines: 2,
            maxLines: 4,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            decoration: const InputDecoration(
              labelText: 'Ask the dashboard something',
              hintText:
                  'Try: "Summarize what we have so far" or "Check MicroGrow status."',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: isSending ? null : onSend,
                icon: isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(isSending ? 'Sending' : 'Send'),
              ),
              TextButton(
                onPressed: isSending
                    ? null
                    : () {
                        controller.clear();
                        onChanged('');
                      },
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordingBanner extends StatelessWidget {
  const _RecordingBanner({required this.session});

  final VoiceSessionState session;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSuccess.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColours.darkSuccess.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.fiber_manual_record,
            color: AppColours.darkSuccess,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              session.recordingLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColours.darkText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

List<VoiceConversationPrompt> _defaultPrompts() {
  return [
    VoiceConversationPrompt(
      label: 'Open voice notes',
      description: 'Move the conversation into a note capture flow.',
      route: RouteNames.voiceNotes,
    ),
    VoiceConversationPrompt(
      label: 'Open meetings',
      description: 'Switch into meeting transcriber mode.',
      route: RouteNames.voiceMeetings,
    ),
    VoiceConversationPrompt(
      label: 'Check MicroGrow',
      description: 'Open the read-only MicroGrow status view.',
      route: RouteNames.voiceMicrogrow,
    ),
  ];
}

String _formatDateTime(DateTime timestamp) {
  final date = timestamp.toLocal();
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}

Color _legacySessionAccent(legacy_session.VoiceSessionState session) {
  return switch (session.phase) {
    legacy_session.VoiceSessionPhase.listening => AppColours.darkSecondary,
    legacy_session.VoiceSessionPhase.processing => AppColours.darkAmber,
    legacy_session.VoiceSessionPhase.speaking => AppColours.darkSuccess,
    legacy_session.VoiceSessionPhase.awaitingFollowUp =>
      AppColours.darkSecondary,
    legacy_session.VoiceSessionPhase.waking => AppColours.darkAccent,
    legacy_session.VoiceSessionPhase.error => AppColours.darkAmber,
    legacy_session.VoiceSessionPhase.idle => AppColours.darkMutedText,
  };
}
