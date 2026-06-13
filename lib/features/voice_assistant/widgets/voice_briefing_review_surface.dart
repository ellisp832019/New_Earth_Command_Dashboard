import 'package:flutter/material.dart';

class VoiceBriefingReviewSurface extends StatelessWidget {
  const VoiceBriefingReviewSurface({
    super.key,
    required this.isAiDraft,
    required this.summary,
    required this.nextStep,
    required this.rawTranscript,
    this.projectContext,
    this.threadContext,
  });

  final bool isAiDraft;
  final String summary;
  final String nextStep;
  final String rawTranscript;
  final String? projectContext;
  final String? threadContext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Briefing review', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          isAiDraft
              ? 'Compare the AI wording with the manual draft, then keep whichever version makes the next move clearest.'
              : 'Read the meaning, check the raw transcript, and then save it locally when it feels right.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 6),
        _BriefingPanelSection(
          label: 'What this means',
          body: summary,
          bodyStyle: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        _BriefingPanelSection(
          label: 'Next move',
          body: nextStep,
          bodyStyle: theme.textTheme.bodySmall,
        ),
        if (projectContext != null || threadContext != null) ...[
          const SizedBox(height: 8),
          Text(
            [
              if (projectContext != null) projectContext,
              if (threadContext != null) threadContext,
            ].join(' · '),
            style: theme.textTheme.bodySmall,
          ),
        ],
        if (rawTranscript.isNotEmpty) ...[
          const SizedBox(height: 10),
          _BriefingPanelSection(
            label: 'Raw transcript',
            body: rawTranscript,
            bodyStyle: theme.textTheme.bodySmall,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.42,
            ),
            borderColor: theme.colorScheme.outlineVariant,
          ),
        ],
      ],
    );
  }
}

class _BriefingPanelSection extends StatelessWidget {
  const _BriefingPanelSection({
    required this.label,
    required this.body,
    required this.bodyStyle,
    this.fillColor,
    this.borderColor,
  });

  final String label;
  final String body;
  final TextStyle? bodyStyle;
  final Color? fillColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            fillColor ??
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(body, style: bodyStyle),
        ],
      ),
    );
  }
}
