import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';
import '../data/asset_change_journal.dart';

class AssetConflictsScreen extends ConsumerWidget {
  const AssetConflictsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(assetWorkspaceProvider);
    final conflicts = ref.watch(assetChangeConflictsProvider);

    return workspace.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => _AssetConflictsError(
        onReload: () => ref.invalidate(assetWorkspaceProvider),
      ),
      data: (workspaceData) {
        return conflicts.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => _AssetConflictsError(
            onReload: () => ref.invalidate(assetChangeConflictsProvider),
          ),
          data: (conflictRows) {
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
                            _AssetConflictsHeader(
                              assetPath: workspaceData.assetsRootPath,
                              conflictCount: conflictRows.length,
                            ),
                            const SizedBox(height: 20),
                            _AssetConflictsSummaryRow(
                              conflictCount: conflictRows.length,
                            ),
                            const SizedBox(height: 20),
                            if (conflictRows.isNotEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: FilledButton.icon(
                                  onPressed: () async {
                                    final assetsRootPath =
                                        workspaceData.assetsRootPath;
                                    if (assetsRootPath == null) {
                                      return;
                                    }

                                    await ref
                                        .read(assetRegisterRepositoryProvider)
                                        .rebuildChangeJournalSnapshot(
                                          assetsRootPath,
                                        );
                                    ref.invalidate(
                                      assetChangeJournalEntriesProvider,
                                    );
                                    ref.invalidate(
                                      assetChangeConflictsProvider,
                                    );
                                    ref.invalidate(assetSyncStatusProvider);
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Asset journal compacted to the latest entry for each record.',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.cleaning_services_outlined),
                                  label: const Text('Compact journal to latest'),
                                ),
                              ),
                            if (conflictRows.isNotEmpty)
                              const SizedBox(height: 20),
                            if (conflictRows.isEmpty)
                              const _AssetConflictsEmptyState()
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: conflictRows.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return _AssetConflictCard(
                                    conflict: conflictRows[index],
                                  );
                                },
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

class _AssetConflictsHeader extends StatelessWidget {
  const _AssetConflictsHeader({
    required this.assetPath,
    required this.conflictCount,
  });

  final String? assetPath;
  final int conflictCount;

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
                'Asset Conflicts',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColours.darkText,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Review duplicate edits gently and keep the last clear record in view.',
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
              _InfoChip(label: '$conflictCount conflict${conflictCount == 1 ? '' : 's'}'),
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
                child: Align(
                  alignment: Alignment.topRight,
                  child: chips,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AssetConflictsSummaryRow extends StatelessWidget {
  const _AssetConflictsSummaryRow({required this.conflictCount});

  final int conflictCount;

  @override
  Widget build(BuildContext context) {
    return _MetricCard(
      label: 'Conflicts detected',
      value: conflictCount,
      accent: AppColours.darkAmber,
    );
  }
}

class _AssetConflictCard extends StatelessWidget {
  const _AssetConflictCard({required this.conflict});

  final AssetChangeConflict conflict;

  @override
  Widget build(BuildContext context) {
    final lastChangeLabel = DateFormat('yMMMd, h:mm a').format(
      conflict.lastChangeAt.toLocal(),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${conflict.recordType} ${conflict.recordId}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              _StatusPill(
                label: '${conflict.entryCount} edits',
                accent: AppColours.darkAmber,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: conflict.summary),
              _InfoChip(label: 'Last change $lastChangeLabel'),
              _InfoChip(label: conflict.machineIds.join(' · ')),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Review these edits before compacting the journal to the latest clean record.',
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

class _AssetConflictsEmptyState extends StatelessWidget {
  const _AssetConflictsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Text(
        'No conflicts are showing right now. Keep the journal calm and the changes easy to review.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
      ),
    );
  }
}

class _AssetConflictsError extends StatelessWidget {
  const _AssetConflictsError({required this.onReload});

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
                'Asset conflicts could not load right now.',
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

BoxDecoration _panelDecoration(BuildContext context, {bool highlighted = false}) {
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
