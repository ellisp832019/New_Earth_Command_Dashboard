import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colours.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, this.onTap});

  final Project project;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: AppColours.darkSurface.withValues(alpha: 0.94),
      child: InkWell(
        key: Key('projectCard-${project.projectId}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
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
                        Text(
                          project.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColours.darkText,
                          ),
                        ),
                        if (project.shortDescription != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            project.shortDescription!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColours.darkMutedText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _ProjectBadge(label: project.status),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ProjectBadge(label: 'Priority: ${project.priority}'),
                  _ProjectBadge(
                    label: 'Progress: ${project.progressPercentage}%',
                  ),
                ],
              ),
              if (project.currentMilestone != null) ...[
                const SizedBox(height: 14),
                Text(
                  'Current Milestone',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  project.currentMilestone!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkText,
                  ),
                ),
              ],
              if (project.nextAction != null) ...[
                const SizedBox(height: 14),
                Text(
                  'Next Action',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  project.nextAction!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectBadge extends StatelessWidget {
  const _ProjectBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColours.darkSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
