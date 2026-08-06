import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../application/voice_thread_controller.dart';

class VoiceThreadSummaryStrip extends StatelessWidget {
  const VoiceThreadSummaryStrip({
    super.key,
    required this.thread,
  });

  final VoiceConversationThreadState thread;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            thread.threadTitle,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Next: ${thread.nextStep}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkText,
              height: 1.2,
            ),
          ),
          Text(
            'Review: ${thread.reviewPrompt}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
