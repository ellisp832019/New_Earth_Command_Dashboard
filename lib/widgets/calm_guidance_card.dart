import 'package:flutter/material.dart';

import '../core/theme/app_colours.dart';

class CalmGuidanceCard extends StatelessWidget {
  const CalmGuidanceCard({
    super.key,
    required this.title,
    required this.summary,
    required this.reason,
    this.sectionLabel = 'Gentle guidance',
    this.icon = Icons.auto_awesome_outlined,
    this.iconColor = AppColours.darkSuccess,
    this.details = const [],
  });

  final String sectionLabel;
  final String title;
  final String summary;
  final String reason;
  final IconData icon;
  final Color iconColor;
  final List<String> details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sectionLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColours.darkSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  summary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: details
                        .map(
                          (detail) => Chip(
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            label: Text(detail),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Why this: $reason',
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
