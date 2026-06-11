import 'package:flutter/material.dart';

import '../voice_command_model.dart';

class VoiceConversationThreadCard extends StatelessWidget {
  const VoiceConversationThreadCard({
    super.key,
    required this.conversationContext,
    required this.onResumeThread,
    required this.onReuseLatestCapture,
    required this.onStartFresh,
    required this.onCopySummary,
    required this.onOpenSharedConversation,
  });

  final VoiceConversationContext conversationContext;
  final VoidCallback onResumeThread;
  final VoidCallback onReuseLatestCapture;
  final VoidCallback onStartFresh;
  final VoidCallback onCopySummary;
  final VoidCallback onOpenSharedConversation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      key: const Key('voiceConversationThreadCard'),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Resume remembered thread',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                  label: Text(
                    'Saved entries: ${conversationContext.entryCount}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'The latest capture is ready to continue. Reuse it, copy the summary, or start fresh if you want a new thread.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Resume state',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${conversationContext.entryCountLabel} · Latest capture: ${conversationContext.latestEntryLabel}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              conversationContext.summary,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  label: Text(
                    'Thread: ${conversationContext.threadScopeLabel}',
                  ),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  label: Text(
                    'Type: ${conversationContext.type?.label ?? 'Saved'}',
                  ),
                ),
                if (conversationContext.projectName != null &&
                    conversationContext.projectName!.isNotEmpty)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: Text('Project: ${conversationContext.projectName}'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Latest capture',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              conversationContext.latestEntryLabel,
              style: theme.textTheme.bodySmall,
            ),
            if (conversationContext.latestEntryPreview !=
                conversationContext.latestEntryLabel) ...[
              const SizedBox(height: 4),
              Text(
                conversationContext.latestEntryPreview,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  key: const Key('voiceReuseLatestCaptureButton'),
                  onPressed: onReuseLatestCapture,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reuse latest capture'),
                ),
                FilledButton.tonalIcon(
                  key: const Key('voiceContinueThreadButton'),
                  onPressed: onResumeThread,
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Continue thread'),
                ),
                FilledButton.icon(
                  key: const Key('voiceOpenSharedConversationButton'),
                  onPressed: onOpenSharedConversation,
                  icon: const Icon(Icons.forum_outlined),
                  label: const Text('Open shared conversation'),
                ),
                OutlinedButton.icon(
                  key: const Key('voiceCopyThreadSummaryButton'),
                  onPressed: onCopySummary,
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy summary'),
                ),
                TextButton.icon(
                  key: const Key('voiceNewThreadButton'),
                  onPressed: onStartFresh,
                  icon: const Icon(Icons.fiber_new_outlined),
                  label: const Text('Start fresh'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
