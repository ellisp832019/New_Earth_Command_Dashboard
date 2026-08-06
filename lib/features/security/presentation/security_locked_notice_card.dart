import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/security_route_policy.dart';

class SecurityLockedNoticeCard extends StatelessWidget {
  const SecurityLockedNoticeCard({
    super.key,
    required this.title,
    required this.message,
    this.detail,
    this.primaryActionLabel = 'Open Security Lock',
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final String title;
  final String message;
  final String? detail;
  final String primaryActionLabel;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text(message, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                Chip(label: Text('Security session locked')),
                Chip(label: Text('Protected actions paused')),
              ],
            ),
            if (detail != null && detail!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(detail!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () => context.go(
                    SecurityRoutePolicy.securityLockFrom(
                      GoRouterState.of(context).uri,
                    ),
                  ),
                  icon: const Icon(Icons.lock_outline),
                  label: Text(primaryActionLabel),
                ),
                if (secondaryActionLabel != null)
                  OutlinedButton.icon(
                    onPressed: onSecondaryAction,
                    icon: const Icon(Icons.arrow_back_outlined),
                    label: Text(secondaryActionLabel!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
