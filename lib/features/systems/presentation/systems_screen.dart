import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';

class SystemsScreen extends StatelessWidget {
  const SystemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: _panelDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Systems',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: AppColours.darkText,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Local protection and recovery tools live here.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColours.darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Backup Guardian starts the first V1 slice: safe manual backups, status, reports, and restore drills.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColours.darkMutedText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => context.push(RouteNames.backupGuardian),
              child: Ink(
                padding: const EdgeInsets.all(20),
                decoration: _panelDecoration(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColours.darkSurfaceRaised.withValues(
                          alpha: 0.96,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.backup_outlined,
                        color: AppColours.darkSecondary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Backup Guardian',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColours.darkText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Back up the full D: drive to the external drive, view status, open the backup folder, and keep restore work dry-run only in V1.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColours.darkMutedText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: const [
                              _InlineTag(label: 'Manual V1'),
                              _InlineTag(label: 'Local-first'),
                              _InlineTag(label: 'Reports'),
                              _InlineTag(label: 'Restore dry run'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColours.darkMutedText,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Planned systems',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColours.darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                final cards = const [
                  _PlannedSystemCard(
                    icon: Icons.monitor_heart_outlined,
                    title: 'Drive Health',
                    description:
                        'Check source drive space, backup drive presence, and simple recovery signals.',
                    tags: ['Planned', 'Health checks'],
                  ),
                  _PlannedSystemCard(
                    icon: Icons.restore_outlined,
                    title: 'Restore Lab',
                    description:
                        'Stage safe restore drills and review restore notes without touching live files.',
                    tags: ['Planned', 'Dry run only'],
                  ),
                  _PlannedSystemCard(
                    icon: Icons.devices_outlined,
                    title: 'Device Health',
                    description:
                        'Watch connected devices, printer readiness, and other local hardware signals.',
                    tags: ['Planned', 'Hardware'],
                  ),
                ];

                if (!wide) {
                  return Column(
                    children: [
                      for (final card in cards) ...[
                        card,
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: cards.first),
                    const SizedBox(width: 12),
                    Expanded(child: cards[1]),
                    const SizedBox(width: 12),
                    Expanded(child: cards.last),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: AppColours.darkSurface.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.85)),
    );
  }
}

class _PlannedSystemCard extends StatelessWidget {
  const _PlannedSystemCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.tags,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColours.darkSurfaceRaised.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColours.darkAmber),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColours.darkText,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColours.darkMutedText,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in tags) _InlineTag(label: tag),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColours.darkSurface.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.85)),
    );
  }
}

class _InlineTag extends StatelessWidget {
  const _InlineTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.75)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColours.darkText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
