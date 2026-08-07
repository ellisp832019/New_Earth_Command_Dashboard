import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colours.dart';
import '../application/voice_startup_coordinator.dart';

class VoiceStartupStatusChip extends ConsumerWidget {
  const VoiceStartupStatusChip({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(voiceStartupCoordinatorProvider);
    final theme = Theme.of(context);
    final colors = _statusColors(state.status, theme);
    final label = state.status.label;
    final retry = state.canRetry
        ? () {
            unawaited(
              ref.read(voiceStartupCoordinatorProvider.notifier).retry(),
            );
          }
        : null;

    final chipLabel = state.canRetry
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Retry',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          )
        : Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w700,
            ),
          );

    final chip = state.canRetry
        ? ActionChip(
            avatar: Icon(colors.icon, size: compact ? 14 : 16),
            label: chipLabel,
            onPressed: retry,
            backgroundColor: colors.background,
            side: BorderSide(color: colors.border),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          )
        : Chip(
            avatar: Icon(colors.icon, size: compact ? 14 : 16),
            label: chipLabel,
            backgroundColor: colors.background,
            side: BorderSide(color: colors.border),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 240 : 320),
      child: Material(
        color: Colors.transparent,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.background.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colors.border.withValues(alpha: 0.4)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 2 : 4,
              vertical: compact ? 2 : 4,
            ),
            child: chip,
          ),
        ),
      ),
    );
  }

  _VoiceStartupChipColors _statusColors(
    VoiceStartupStatus status,
    ThemeData theme,
  ) {
    switch (status) {
      case VoiceStartupStatus.disabled:
        return _VoiceStartupChipColors(
          foreground: AppColours.darkMutedText,
          background: AppColours.darkSurfaceAlt,
          border: AppColours.darkMutedText,
          icon: Icons.volume_off_outlined,
        );
      case VoiceStartupStatus.initializing:
        return _VoiceStartupChipColors(
          foreground: theme.colorScheme.tertiary,
          background: theme.colorScheme.tertiaryContainer,
          border: theme.colorScheme.tertiary,
          icon: Icons.hourglass_top_outlined,
        );
      case VoiceStartupStatus.ready:
        return _VoiceStartupChipColors(
          foreground: AppColours.darkSuccess,
          background: AppColours.darkSuccess.withValues(alpha: 0.14),
          border: AppColours.darkSuccess,
          icon: Icons.check_circle_outline,
        );
      case VoiceStartupStatus.unavailable:
        return _VoiceStartupChipColors(
          foreground: AppColours.darkMutedText,
          background: AppColours.darkSurfaceAlt,
          border: AppColours.darkMutedText,
          icon: Icons.cloud_off_outlined,
        );
      case VoiceStartupStatus.permissionDenied:
        return _VoiceStartupChipColors(
          foreground: theme.colorScheme.error,
          background: theme.colorScheme.errorContainer,
          border: theme.colorScheme.error,
          icon: Icons.lock_outline,
        );
      case VoiceStartupStatus.hardwareMissing:
        return _VoiceStartupChipColors(
          foreground: theme.colorScheme.tertiary,
          background: theme.colorScheme.tertiaryContainer,
          border: theme.colorScheme.tertiary,
          icon: Icons.mic_off_outlined,
        );
      case VoiceStartupStatus.pluginUnavailable:
        return _VoiceStartupChipColors(
          foreground: theme.colorScheme.secondary,
          background: theme.colorScheme.secondaryContainer,
          border: theme.colorScheme.secondary,
          icon: Icons.extension_off_outlined,
        );
      case VoiceStartupStatus.failed:
        return _VoiceStartupChipColors(
          foreground: theme.colorScheme.error,
          background: theme.colorScheme.errorContainer,
          border: theme.colorScheme.error,
          icon: Icons.warning_amber_outlined,
        );
    }
  }
}

class _VoiceStartupChipColors {
  const _VoiceStartupChipColors({
    required this.foreground,
    required this.background,
    required this.border,
    required this.icon,
  });

  final Color foreground;
  final Color background;
  final Color border;
  final IconData icon;
}
