import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';

class LowStockScreen extends ConsumerWidget {
  const LowStockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(assetWorkspaceProvider);
    final parts = ref.watch(assetPartsRegisterProvider);
    final lowStockParts = ref.watch(assetLowStockPartsProvider);
    final repository = ref.watch(assetRegisterRepositoryProvider);

    return workspace.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => _LowStockError(
        onReload: () => ref.invalidate(assetWorkspaceProvider),
      ),
      data: (workspaceData) {
        return parts.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => _LowStockError(
            onReload: () => ref.invalidate(assetPartsRegisterProvider),
          ),
          data: (partsTable) {
            return lowStockParts.when(
              loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => _LowStockError(
                onReload: () => ref.invalidate(assetLowStockPartsProvider),
              ),
              data: (lowStockRows) {
                final reorderRows = repository.filterReorderNeededParts(
                  partsTable.rows,
                );
                final estimatedSpend = repository.estimateReorderSpend(
                  partsTable.rows,
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
                                _LowStockHeader(
                                  title: 'Low Stock / Reorder',
                                  subtitle:
                                      'Keep parts calm, visible, and easy to reorder before they become a problem.',
                                  assetPath: workspaceData.assetsRootPath,
                                  lowStockCount: lowStockRows.length,
                                  reorderCount: reorderRows.length,
                                  estimatedSpend: estimatedSpend,
                                ),
                                const SizedBox(height: 20),
                                _LowStockSummaryRow(
                                  lowStockCount: lowStockRows.length,
                                  reorderCount: reorderRows.length,
                                  estimatedSpend: estimatedSpend,
                                ),
                                const SizedBox(height: 20),
                                const _LowStockActionStrip(),
                                const SizedBox(height: 20),
                                _LowStockListCard(rows: lowStockRows),
                                const SizedBox(height: 20),
                                _ReorderHintsCard(rows: reorderRows),
                                const SizedBox(height: 20),
                                _LowStockFooter(
                                  itemCount: partsTable.rows.length,
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
  }
}

class _LowStockActionStrip extends StatelessWidget {
  const _LowStockActionStrip();

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
              onPressed: () => context.push(RouteNames.assetParts),
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Open Parts Inventory'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push(RouteNames.assetOrdersTracker),
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Open Orders Tracker'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push(RouteNames.assetSupplierRegister),
              icon: const Icon(Icons.local_shipping_outlined),
              label: const Text('Open Supplier Register'),
            ),
          ];

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PanelTitle(
                title: 'Next actions',
                icon: Icons.arrow_forward_outlined,
              ),
              const SizedBox(height: 8),
              Text(
                'Move from stock pressure to the register or supplier view without losing the calm thread.',
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
                width: 480,
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

class _LowStockHeader extends StatelessWidget {
  const _LowStockHeader({
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.lowStockCount,
    required this.reorderCount,
    required this.estimatedSpend,
  });

  final String title;
  final String subtitle;
  final String? assetPath;
  final int lowStockCount;
  final int reorderCount;
  final int estimatedSpend;

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
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColours.darkText,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
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
              _InfoChip(label: '$lowStockCount low stock'),
              _InfoChip(label: '$reorderCount reorder needed'),
              _InfoChip(
                label:
                    'Spend ${NumberFormat.decimalPattern().format(estimatedSpend)}',
              ),
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

class _LowStockSummaryRow extends StatelessWidget {
  const _LowStockSummaryRow({
    required this.lowStockCount,
    required this.reorderCount,
    required this.estimatedSpend,
  });

  final int lowStockCount;
  final int reorderCount;
  final int estimatedSpend;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 840;
        final cards = [
          _MetricCard(
            label: 'Low Stock',
            value: lowStockCount,
            accent: AppColours.darkAmber,
          ),
          _MetricCard(
            label: 'Reorder Needed',
            value: reorderCount,
            accent: AppColours.darkSecondary,
          ),
          _MetricCard(
            label: 'Estimated Spend',
            value: estimatedSpend,
            accent: AppColours.darkSuccess,
            isCurrency: true,
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

class _LowStockListCard extends StatelessWidget {
  const _LowStockListCard({required this.rows});

  final List<Map<String, String>> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            title: 'Low stock items',
            icon: Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Text(
              'Everything is stocked well right now. Nothing needs attention.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
              ),
            )
          else
            Column(
              children: [
                for (var index = 0; index < rows.length; index++) ...[
                  _LowStockCard(row: rows[index]),
                  if (index != rows.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _LowStockCard extends StatelessWidget {
  const _LowStockCard({required this.row});

  final Map<String, String> row;

  @override
  Widget build(BuildContext context) {
    final quantity = int.tryParse((row['quantity'] ?? '').trim()) ?? 0;
    final minQuantity = int.tryParse((row['min_quantity'] ?? '').trim()) ?? 0;
    final needed = quantity < minQuantity ? minQuantity - quantity : 1;
    final status = (row['status'] ?? '').trim().toLowerCase();
    final accent = status == 'wishlist'
        ? AppColours.darkPurple
        : status == 'reorder_needed'
        ? AppColours.darkSecondary
        : AppColours.darkAmber;

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
                  row['name']?.trim().isNotEmpty == true
                      ? row['name']!.trim()
                      : 'Unnamed part',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusPill(
                label: status.isEmpty ? 'low_stock' : status,
                accent: accent,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: row['part_id'] ?? 'No ID'),
              _InfoChip(label: row['project'] ?? 'No project'),
              _InfoChip(label: row['supplier'] ?? 'No supplier'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Qty ${row['quantity'] ?? '0'}  •  Min ${row['min_quantity'] ?? '0'}  •  Need $needed',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
          ),
        ],
      ),
    );
  }
}

class _ReorderHintsCard extends StatelessWidget {
  const _ReorderHintsCard({required this.rows});

  final List<Map<String, String>> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            title: 'Reorder hints',
            icon: Icons.playlist_add_check_circle_outlined,
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Text(
              'No reorder pressure right now. The list stays light and quiet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
              ),
            )
          else
            Column(
              children: [
                for (var index = 0; index < rows.length; index++) ...[
                  _ReorderHintCard(row: rows[index]),
                  if (index != rows.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _ReorderHintCard extends StatelessWidget {
  const _ReorderHintCard({required this.row});

  final Map<String, String> row;

  @override
  Widget build(BuildContext context) {
    final quantity = int.tryParse((row['quantity'] ?? '').trim()) ?? 0;
    final minQuantity = int.tryParse((row['min_quantity'] ?? '').trim()) ?? 0;
    final quantityNeeded = minQuantity - quantity > 0
        ? minQuantity - quantity
        : 1;
    final lastCost = double.tryParse((row['last_cost'] ?? '').trim()) ?? 0;
    final estimatedCost = quantityNeeded * lastCost;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row['name']?.trim().isNotEmpty == true
                      ? row['name']!.trim()
                      : 'Unnamed part',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Need $quantityNeeded more • Project ${row['project'] ?? 'No project'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Est ${NumberFormat.decimalPattern().format(estimatedCost)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LowStockFooter extends StatelessWidget {
  const _LowStockFooter({required this.itemCount});

  final int itemCount;

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
              '$itemCount parts are in the current register. Keep the list short, useful, and easy to act on.',
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
    this.isCurrency = false,
  });

  final String label;
  final int value;
  final Color accent;
  final bool isCurrency;

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
            isCurrency ? NumberFormat.decimalPattern().format(value) : '$value',
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

class _LowStockError extends StatelessWidget {
  const _LowStockError({required this.onReload});

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
                'Low stock view could not load right now.',
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
        border: Border.all(color: accent.withValues(alpha: 0.25)),
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
        ? AppColours.darkSurface.withValues(alpha: 0.96)
        : AppColours.darkSurface.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: highlighted
          ? AppColours.darkSecondary.withValues(alpha: 0.22)
          : AppColours.darkOutline.withValues(alpha: 0.9),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 26,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
