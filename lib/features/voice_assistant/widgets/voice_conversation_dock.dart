import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/voice_conversation_dock_controller.dart';
import '../voice_command_model.dart';
import '../voice_command_service.dart';

class VoiceConversationDock extends ConsumerWidget {
  const VoiceConversationDock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final followUpActions = <VoiceCommandQuickAction>[
      ...quickActions,
      if (dock.threadContext != null)
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
                                    dock.transcript,
                                    dock.isWake,
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
        dock.transcript,
        dock.isWake,
        suggestion?.suggestedType,
      );
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
