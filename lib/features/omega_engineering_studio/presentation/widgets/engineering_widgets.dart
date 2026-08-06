import 'package:flutter/material.dart';

class EngineeringSectionShell extends StatelessWidget {
  const EngineeringSectionShell({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.34,
        ),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              if (trailing != null) ...[trailing!],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class EngineeringMetricCard extends StatelessWidget {
  const EngineeringMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
    this.subtitle,
  });

  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surface.withValues(alpha: 0.96),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: theme.textTheme.headlineSmall),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class EngineeringTrendChart extends StatelessWidget {
  const EngineeringTrendChart({
    required this.title,
    required this.subtitle,
    required this.series,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<EngineeringTrendPoint> series;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = series.isEmpty
        ? 1.0
        : series
              .map((point) => point.value)
              .reduce((a, b) => a > b ? a : b)
              .clamp(1, double.infinity);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surface.withValues(alpha: 0.96),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          for (final point in series) ...[
            Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    point.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: point.value / maxValue,
                      minHeight: 12,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 54,
                  child: Text(
                    point.valueLabel,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (point != series.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class EngineeringTrendPoint {
  const EngineeringTrendPoint({
    required this.label,
    required this.value,
    required this.valueLabel,
  });

  final String label;
  final double value;
  final String valueLabel;
}

class EngineeringStatusChip extends StatelessWidget {
  const EngineeringStatusChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colour = _statusColour(label, theme.colorScheme);
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: colour.withValues(alpha: 0.32)),
      backgroundColor: colour.withValues(alpha: 0.10),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class EngineeringEmptyState extends StatelessWidget {
  const EngineeringEmptyState({
    required this.title,
    required this.subtitle,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.30,
        ),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(subtitle, style: theme.textTheme.bodyMedium),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class EngineeringErrorState extends StatelessWidget {
  const EngineeringErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.32),
            border: Border.all(
              color: theme.colorScheme.error.withValues(alpha: 0.28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Engineering data did not load',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(message, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EngineeringLoadingState extends StatelessWidget {
  const EngineeringLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading the engineering workspace...',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

BoxDecoration engineeringPanelDecoration(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    color: scheme.surface.withValues(alpha: 0.96),
    border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.65)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 22,
        offset: const Offset(0, 10),
      ),
    ],
  );
}

Color _statusColour(String label, ColorScheme scheme) {
  final value = label.toLowerCase();
  if (value.contains('ready') ||
      value.contains('pass') ||
      value.contains('online')) {
    return scheme.primary;
  }
  if (value.contains('active') ||
      value.contains('running') ||
      value.contains('building')) {
    return scheme.tertiary;
  }
  if (value.contains('block') ||
      value.contains('attention') ||
      value.contains('offline')) {
    return scheme.error;
  }
  if (value.contains('draft') ||
      value.contains('plan') ||
      value.contains('queued')) {
    return scheme.secondary;
  }
  return scheme.outline;
}
