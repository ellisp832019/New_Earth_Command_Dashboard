import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, this.onTap});

  final Project project;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        key: Key('projectCard-${project.projectId}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        Text(project.name, style: theme.textTheme.titleMedium),
                        if (project.shortDescription != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            project.shortDescription!,
                            style: theme.textTheme.bodyMedium,
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
                Text('Current Milestone', style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  project.currentMilestone!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              if (project.nextAction != null) ...[
                const SizedBox(height: 14),
                Text('Next Action', style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(project.nextAction!, style: theme.textTheme.bodyMedium),
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
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label, style: theme.textTheme.bodySmall),
      ),
    );
  }
}
