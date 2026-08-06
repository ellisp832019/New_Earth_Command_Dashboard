import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colours.dart';
import '../application/voice_session_controller.dart';
import '../application/voice_presence_controller.dart';

class VoicePresenceChip extends ConsumerWidget {
  const VoicePresenceChip({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presence = ref.watch(voicePresenceProvider);
    final session = ref.watch(voiceSessionProvider);
    final theme = Theme.of(context);
    final accent = presence.isActive
        ? AppColours.darkSuccess
        : AppColours.darkSecondary;
    final label = compact && session.owner != VoiceSessionOwner.none
        ? '${presence.label} · ${session.phase.displayLabel}'
        : presence.label;
    final detail = session.owner == VoiceSessionOwner.none
        ? presence.detail
        : '${session.owner.displayLabel} · ${session.phase.displayLabel}'
              ' · ${presence.detail}';

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: presence.opacity,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 14,
          vertical: compact ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: AppColours.darkSurfaceAlt.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: accent.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              presence.isActive ? Icons.mic_rounded : Icons.spa_outlined,
              size: compact ? 14 : 16,
              color: accent,
            ),
            SizedBox(width: compact ? 6 : 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColours.darkMutedText,
                      height: 1.0,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
