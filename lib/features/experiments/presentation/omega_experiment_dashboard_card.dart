import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../data/omega_experiment_repository.dart';

class OmegaExperimentDashboardCard extends ConsumerWidget {
  const OmegaExperimentDashboardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceAsync = ref.watch(omegaExperimentWorkspaceProvider);

    return workspaceAsync.when(
      loading: () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: _panelDecoration(),
        child: const Row(
          children: [
            Icon(Icons.science_outlined, color: AppColours.darkSecondary),
            SizedBox(width: 12),
            Text('Omega Experiment Workspace is loading quietly.'),
          ],
        ),
      ),
      error: (error, stackTrace) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: _panelDecoration(),
        child: const Text(
          'Omega Experiment Workspace could not load right now.',
        ),
      ),
      data: (workspace) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _panelDecoration(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;

              final content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const _PanelTitle(
                        title: 'Omega Experiment Workspace',
                        icon: Icons.science_outlined,
                      ),
                      const Spacer(),
                      _InlineTag(
                        label: '${workspace.experimentCount} experiments',
                        accent: AppColours.darkSecondary,
                        foreground: AppColours.darkText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Test plans, evidence, and lessons learned stay connected to the local module tree.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkMutedText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _MetricChip(
                        label: 'Active',
                        value: '${workspace.activeExperimentCount}',
                      ),
                      _MetricChip(
                        label: 'Tools',
                        value: '${workspace.supportedTools.length}',
                      ),
                      _MetricChip(
                        label: 'Reports',
                        value: '${workspace.reportTemplates.length}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    workspace.experiments.isEmpty
                        ? 'No seeded experiments found yet.'
                        : 'Latest: ${workspace.experiments.last.title}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );

              final actions = Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.end,
                children: [
                  FilledButton.icon(
                    onPressed: () =>
                        context.push(RouteNames.experimentWorkspace),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open workspace'),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        context.push(RouteNames.experimentWorkspaceCreate),
                    icon: const Icon(Icons.add),
                    label: const Text('New draft'),
                  ),
                ],
              );

              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [content, const SizedBox(height: 12), actions],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: content),
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            },
          ),
        );
      },
    );
  }
}

BoxDecoration _panelDecoration() {
  return BoxDecoration(
    color: AppColours.darkSurface.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.9)),
  );
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColours.darkSecondary, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColours.darkText),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColours.darkMutedText),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppColours.darkText),
          ),
        ],
      ),
    );
  }
}

class _InlineTag extends StatelessWidget {
  const _InlineTag({
    required this.label,
    required this.accent,
    this.foreground,
  });

  final String label;
  final Color accent;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: foreground ?? accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
