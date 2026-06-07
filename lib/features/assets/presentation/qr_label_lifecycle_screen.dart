import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';

class QrLabelLifecycleScreen extends ConsumerWidget {
  const QrLabelLifecycleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceAsync = ref.watch(assetWorkspaceProvider);
    final registerAsync = ref.watch(assetQrLabelRegisterProvider);
    final historyAsync = ref.watch(assetQrLabelTemplateRegisterProvider);
    final queueAsync = ref.watch(assetQrPrintQueueProvider);
    final templatesAsync = ref.watch(assetQrBulkTemplatesProvider);

    return workspaceAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => _LifecycleError(
        onReload: () => ref.invalidate(assetWorkspaceProvider),
      ),
      data: (workspace) {
        return registerAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => _LifecycleError(
            onReload: () => ref.invalidate(assetQrLabelRegisterProvider),
          ),
          data: (registerTable) {
            return historyAsync.when(
              loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => _LifecycleError(
                onReload: () =>
                    ref.invalidate(assetQrLabelTemplateRegisterProvider),
              ),
              data: (historyTable) {
                return queueAsync.when(
                  loading: () => const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => _LifecycleError(
                    onReload: () => ref.invalidate(assetQrPrintQueueProvider),
                  ),
                  data: (queueTable) {
                    return templatesAsync.when(
                      loading: () => const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stackTrace) => _LifecycleError(
                        onReload: () =>
                            ref.invalidate(assetQrBulkTemplatesProvider),
                      ),
                      data: (templatesTable) {
                        final readyRows = _rowsByStatus(queueTable.rows, {
                          'generated',
                          'queued',
                        });
                        final retryRows = _rowsByStatus(queueTable.rows, {
                          'reprint_needed',
                        });
                        final printedRows = _rowsByStatus(queueTable.rows, {
                          'printed',
                        });
                        final appliedRows = _rowsByStatus(queueTable.rows, {
                          'applied',
                        });

                        return Scaffold(
                          backgroundColor: Colors.transparent,
                          body: SafeArea(
                            child: CustomScrollView(
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.all(20),
                                  sliver: SliverToBoxAdapter(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _LifecycleHeader(
                                          assetPath: workspace.assetsRootPath,
                                          registerCount:
                                              registerTable.rows.length,
                                          historyCount:
                                              historyTable.rows.length,
                                          readyCount: readyRows.length,
                                          printedCount: printedRows.length,
                                          appliedCount: appliedRows.length,
                                        ),
                                        const SizedBox(height: 20),
                                        _LifecycleSummaryRow(
                                          registerCount:
                                              registerTable.rows.length,
                                          historyCount:
                                              historyTable.rows.length,
                                          readyCount: readyRows.length,
                                          retryCount: retryRows.length,
                                        ),
                                        const SizedBox(height: 20),
                                        _LifecycleFlowCard(
                                          registerCount:
                                              registerTable.rows.length,
                                          historyCount:
                                              historyTable.rows.length,
                                          readyCount: readyRows.length,
                                          retryCount: retryRows.length,
                                          printedCount: printedRows.length,
                                          appliedCount: appliedRows.length,
                                          templateCount:
                                              templatesTable.rows.length,
                                        ),
                                        const SizedBox(height: 20),
                                        _LifecycleActionStrip(
                                          onOpenRegister: () => context.push(
                                            RouteNames.assetQrLabelRegister,
                                          ),
                                          onOpenStudio: () => context.push(
                                            RouteNames.assetQrLabelStudio,
                                          ),
                                          onOpenQueue: () => context.push(
                                            RouteNames.assetQrPrintQueue,
                                          ),
                                          onOpenHistory: () => context.push(
                                            RouteNames.assetQrLabelHistory,
                                          ),
                                          onOpenInventorySession: () =>
                                              context.push(
                                                RouteNames
                                                    .assetInventorySession,
                                              ),
                                          onOpenScanLookup: () => context.push(
                                            RouteNames.assetScanLookup,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        _LifecycleFooter(
                                          registerCount:
                                              registerTable.rows.length,
                                          historyCount:
                                              historyTable.rows.length,
                                          retryCount: retryRows.length,
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
              },
            );
          },
        );
      },
    );
  }
}

class _LifecycleHeader extends StatelessWidget {
  const _LifecycleHeader({
    required this.assetPath,
    required this.registerCount,
    required this.historyCount,
    required this.readyCount,
    required this.printedCount,
    required this.appliedCount,
  });

  final String? assetPath;
  final int registerCount;
  final int historyCount;
  final int readyCount;
  final int printedCount;
  final int appliedCount;

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
                'QR Label Lifecycle',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColours.darkText,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Follow the label flow from register to queue to print, then back into history and application without making the path noisy.',
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
              _InfoChip(label: '$registerCount register labels'),
              _InfoChip(label: '$historyCount history rows'),
              _InfoChip(label: '$readyCount ready queue'),
              _InfoChip(label: '$printedCount printed'),
              _InfoChip(label: '$appliedCount applied'),
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

class _LifecycleSummaryRow extends StatelessWidget {
  const _LifecycleSummaryRow({
    required this.registerCount,
    required this.historyCount,
    required this.readyCount,
    required this.retryCount,
  });

  final int registerCount;
  final int historyCount;
  final int readyCount;
  final int retryCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final cards = [
          _MetricCard(
            label: 'Register labels',
            value: registerCount,
            accent: AppColours.darkSecondary,
          ),
          _MetricCard(
            label: 'History rows',
            value: historyCount,
            accent: AppColours.darkSuccess,
          ),
          _MetricCard(
            label: 'Ready queue',
            value: readyCount,
            accent: AppColours.darkAmber,
          ),
          _MetricCard(
            label: 'Retry items',
            value: retryCount,
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
            for (var index = 0; index < cards.length; index++) ...[
              cards[index],
              if (index != cards.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _LifecycleFlowCard extends StatelessWidget {
  const _LifecycleFlowCard({
    required this.registerCount,
    required this.historyCount,
    required this.readyCount,
    required this.retryCount,
    required this.printedCount,
    required this.appliedCount,
    required this.templateCount,
  });

  final int registerCount;
  final int historyCount;
  final int readyCount;
  final int retryCount;
  final int printedCount;
  final int appliedCount;
  final int templateCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stages = [
      _LifecycleStage(
        title: '1. Register',
        count: registerCount,
        subtitle: 'Labels tracked in the calm register.',
        accent: AppColours.darkSecondary,
      ),
      _LifecycleStage(
        title: '2. Generate',
        count: historyCount,
        subtitle: 'Generated records ready to move forward.',
        accent: AppColours.darkSuccess,
      ),
      _LifecycleStage(
        title: '3. Queue',
        count: readyCount,
        subtitle: 'Labels waiting on the printer.',
        accent: AppColours.darkAmber,
      ),
      _LifecycleStage(
        title: '4. Print',
        count: printedCount,
        subtitle: 'Printed rows waiting to be placed.',
        accent: AppColours.darkPurple,
      ),
      _LifecycleStage(
        title: '5. Apply',
        count: appliedCount,
        subtitle: 'Labels already placed on items or bins.',
        accent: const Color(0xFF67C08E),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            title: 'Lifecycle flow',
            icon: Icons.timeline_outlined,
          ),
          const SizedBox(height: 10),
          Text(
            'Use the sequence below to keep the label journey calm and easy to explain later.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final stage in stages)
                SizedBox(width: 240, child: _LifecycleStageCard(stage: stage)),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(label: '$retryCount retry items'),
              _InfoChip(label: '$templateCount templates'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LifecycleStageCard extends StatelessWidget {
  const _LifecycleStageCard({required this.stage});

  final _LifecycleStage stage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stage.accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stage.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusPill(label: '${stage.count}', accent: stage.accent),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            stage.subtitle,
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

class _LifecycleActionStrip extends StatelessWidget {
  const _LifecycleActionStrip({
    required this.onOpenRegister,
    required this.onOpenStudio,
    required this.onOpenQueue,
    required this.onOpenHistory,
    required this.onOpenInventorySession,
    required this.onOpenScanLookup,
  });

  final VoidCallback onOpenRegister;
  final VoidCallback onOpenStudio;
  final VoidCallback onOpenQueue;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenInventorySession;
  final VoidCallback onOpenScanLookup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 860;
          final actions = [
            FilledButton.icon(
              onPressed: onOpenRegister,
              icon: const Icon(Icons.qr_code_2_outlined),
              label: const Text('Open Register'),
            ),
            OutlinedButton.icon(
              onPressed: onOpenStudio,
              icon: const Icon(Icons.print_outlined),
              label: const Text('Open Studio'),
            ),
            OutlinedButton.icon(
              onPressed: onOpenQueue,
              icon: const Icon(Icons.playlist_add_check),
              label: const Text('Open Queue'),
            ),
            OutlinedButton.icon(
              onPressed: onOpenHistory,
              icon: const Icon(Icons.history_outlined),
              label: const Text('Open History'),
            ),
            OutlinedButton.icon(
              onPressed: onOpenInventorySession,
              icon: const Icon(Icons.checklist_rtl_outlined),
              label: const Text('Inventory Session'),
            ),
            OutlinedButton.icon(
              onPressed: onOpenScanLookup,
              icon: const Icon(Icons.search),
              label: const Text('Scan Lookup'),
            ),
          ];

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_forward_outlined,
                    color: AppColours.darkSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Quick links',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColours.darkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Jump straight to the exact QR surface you want without losing the lifecycle view.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 14),
                Wrap(spacing: 10, runSpacing: 10, children: actions),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: copy),
              const SizedBox(width: 16),
              SizedBox(
                width: 560,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(spacing: 10, runSpacing: 10, children: actions),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LifecycleFooter extends StatelessWidget {
  const _LifecycleFooter({
    required this.registerCount,
    required this.historyCount,
    required this.retryCount,
  });

  final int registerCount;
  final int historyCount;
  final int retryCount;

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
              '$registerCount register labels and $historyCount history rows are now easy to move through, with $retryCount retry items kept calm.',
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

class _LifecycleStage {
  const _LifecycleStage({
    required this.title,
    required this.count,
    required this.subtitle,
    required this.accent,
  });

  final String title;
  final int count;
  final String subtitle;
  final Color accent;
}

List<Map<String, String>> _rowsByStatus(
  List<Map<String, String>> rows,
  Set<String> statuses,
) {
  return rows
      .where((row) {
        final status =
            (row['status'] ?? row['print_status'] ?? row['label_status'] ?? '')
                .trim()
                .toLowerCase()
                .replaceAll(' ', '_');
        return statuses.contains(status);
      })
      .toList(growable: false);
}

BoxDecoration _panelDecoration(
  BuildContext context, {
  bool highlighted = false,
}) {
  return BoxDecoration(
    color: highlighted
        ? AppColours.darkSurface.withValues(alpha: 0.95)
        : AppColours.darkSurface.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.9)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
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

class _LifecycleError extends StatelessWidget {
  const _LifecycleError({required this.onReload});

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
                'QR label lifecycle could not load right now.',
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
