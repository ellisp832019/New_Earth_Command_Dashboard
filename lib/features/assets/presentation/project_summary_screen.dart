import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';

class ProjectSummaryScreen extends ConsumerWidget {
  const ProjectSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(assetWorkspaceProvider);
    final summaries = ref.watch(assetProjectSummaryProvider);

    return workspace.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => _ProjectSummaryError(
        onReload: () => ref.invalidate(assetWorkspaceProvider),
      ),
      data: (workspaceData) {
        return summaries.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => _ProjectSummaryError(
            onReload: () => ref.invalidate(assetProjectSummaryProvider),
          ),
          data: (projects) {
            final totalEquipment = projects.fold<int>(
              0,
              (sum, project) => sum + project.equipmentCount,
            );
            final totalParts = projects.fold<int>(
              0,
              (sum, project) => sum + project.partsCount,
            );
            final attentionCount = projects.fold<int>(
              0,
              (sum, project) =>
                  sum +
                  project.brokenCount +
                  project.lowStockCount +
                  project.needsDecisionCount,
            );

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ProjectSummaryHeader(
                              assetPath: workspaceData.assetsRootPath,
                              projectCount: projects.length,
                              totalEquipment: totalEquipment,
                              totalParts: totalParts,
                              attentionCount: attentionCount,
                            ),
                            const SizedBox(height: 20),
                            _ProjectSummaryMetrics(
                              projectCount: projects.length,
                              totalEquipment: totalEquipment,
                              totalParts: totalParts,
                              attentionCount: attentionCount,
                            ),
                            const SizedBox(height: 20),
                            _ProjectSummaryListCard(projects: projects),
                            const SizedBox(height: 20),
                            _ProjectSummaryFooter(
                              projectCount: projects.length,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ProjectSummaryHeader extends StatelessWidget {
  const _ProjectSummaryHeader({
    required this.assetPath,
    required this.projectCount,
    required this.totalEquipment,
    required this.totalParts,
    required this.attentionCount,
  });

  final String? assetPath;
  final int projectCount;
  final int totalEquipment;
  final int totalParts;
  final int attentionCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(context, highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project Asset Summary',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColours.darkText,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'See how equipment and parts are distributed across projects without turning the tab into a warehouse view.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
            ],
          );

          final chips = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(label: assetPath ?? 'Asset folder not linked'),
              _InfoChip(label: '$projectCount projects'),
              _InfoChip(label: '$totalEquipment equipment'),
              _InfoChip(label: '$totalParts parts'),
              _InfoChip(label: '$attentionCount attention items'),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 16), chips],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: copy),
              const SizedBox(width: 20),
              SizedBox(
                width: 420,
                child: Align(alignment: Alignment.topRight, child: chips),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProjectSummaryMetrics extends StatelessWidget {
  const _ProjectSummaryMetrics({
    required this.projectCount,
    required this.totalEquipment,
    required this.totalParts,
    required this.attentionCount,
  });

  final int projectCount;
  final int totalEquipment;
  final int totalParts;
  final int attentionCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 840;
        final cards = [
          _MetricCard(
            label: 'Projects',
            value: projectCount,
            accent: AppColours.darkSecondary,
          ),
          _MetricCard(
            label: 'Equipment',
            value: totalEquipment,
            accent: AppColours.darkSuccess,
          ),
          _MetricCard(
            label: 'Parts',
            value: totalParts,
            accent: AppColours.darkAmber,
          ),
          _MetricCard(
            label: 'Attention Items',
            value: attentionCount,
            accent: const Color(0xFFE26B6B),
          ),
        ];

        if (wide) {
          return Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
              const SizedBox(width: 12),
              Expanded(child: cards[2]),
              const SizedBox(width: 12),
              Expanded(child: cards[3]),
            ],
          );
        }

        return Column(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              cards[i],
              if (i != cards.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _ProjectSummaryListCard extends StatelessWidget {
  const _ProjectSummaryListCard({required this.projects});

  final List<AssetProjectSummary> projects;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(title: 'Projects', icon: Icons.groups_2_outlined),
          const SizedBox(height: 12),
          if (projects.isEmpty)
            Text(
              'No project-linked assets yet. The summary will fill itself as records are added.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
              ),
            )
          else
            Column(
              children: [
                for (var index = 0; index < projects.length; index++) ...[
                  _ProjectSummaryCard(summary: projects[index]),
                  if (index != projects.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _ProjectSummaryCard extends StatelessWidget {
  const _ProjectSummaryCard({required this.summary});

  final AssetProjectSummary summary;

  @override
  Widget build(BuildContext context) {
    final hasAttention =
        summary.brokenCount > 0 ||
        summary.lowStockCount > 0 ||
        summary.needsDecisionCount > 0;
    final accent = hasAttention ? AppColours.darkAmber : AppColours.darkSuccess;
    final focus = summary.brokenCount > 0
        ? 'Repair attention first'
        : summary.lowStockCount > 0
        ? 'Check reorder pressure'
        : summary.needsDecisionCount > 0
        ? 'Needs a clear decision'
        : 'Looks settled';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  summary.projectName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusPill(label: focus, accent: accent),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: '${summary.equipmentCount} equipment'),
              _InfoChip(label: '${summary.partsCount} parts'),
              _InfoChip(label: '${summary.availableCount} ready'),
              if (summary.brokenCount > 0)
                _InfoChip(label: '${summary.brokenCount} broken'),
              if (summary.lowStockCount > 0)
                _InfoChip(label: '${summary.lowStockCount} low stock'),
              if (summary.needsDecisionCount > 0)
                _InfoChip(label: '${summary.needsDecisionCount} decisions'),
              if (summary.isMixedProject) _InfoChip(label: 'Mixed project'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Keep the project view simple: what exists, what needs attention, and what can wait.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectSummaryFooter extends StatelessWidget {
  const _ProjectSummaryFooter({required this.projectCount});

  final int projectCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.9),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_outlined, color: AppColours.darkSuccess),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$projectCount projects are represented in the summary. Keep the view short, useful, and easy to review.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectSummaryError extends StatelessWidget {
  const _ProjectSummaryError({required this.onReload});

  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Project summary could not load right now.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onReload,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColours.darkMutedText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

BoxDecoration _panelDecoration(
  BuildContext context, {
  bool highlighted = false,
}) {
  return BoxDecoration(
    color: highlighted
        ? AppColours.darkSurfaceAlt.withValues(alpha: 0.96)
        : AppColours.darkSurface.withValues(alpha: 0.93),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: highlighted
          ? AppColours.darkSecondary.withValues(alpha: 0.28)
          : AppColours.darkOutline,
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0x20000000),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
    ],
  );
}
