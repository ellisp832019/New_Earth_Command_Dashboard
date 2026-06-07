import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';

class EvidenceLibraryScreen extends ConsumerWidget {
  const EvidenceLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(assetWorkspaceProvider);
    final equipment = ref.watch(assetEquipmentRegisterProvider);
    final orders = ref.watch(assetOrdersTrackerProvider);

    return workspace.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => _EvidenceError(
        onReload: () => ref.invalidate(assetWorkspaceProvider),
      ),
      data: (workspaceData) {
        return equipment.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => _EvidenceError(
            onReload: () => ref.invalidate(assetEquipmentRegisterProvider),
          ),
          data: (equipmentTable) {
            return orders.when(
              loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => _EvidenceError(
                onReload: () => ref.invalidate(assetOrdersTrackerProvider),
              ),
              data: (ordersTable) {
                final equipmentReceiptRows = equipmentTable.rows.where((row) {
                  return _hasValue(row['receipt_link']);
                }).toList(growable: false);
                final warrantyRows = equipmentTable.rows.where((row) {
                  return _hasValue(row['warranty_until']);
                }).toList(growable: false);
                final manualRows = equipmentTable.rows.where((row) {
                  return _looksLikeManualPointer(row);
                }).toList(growable: false);
                final orderReceiptRows = ordersTable.rows.where((row) {
                  return _hasValue(row['receipt_link']);
                }).toList(growable: false);

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
                                _EvidenceHeader(
                                  assetPath: workspaceData.assetsRootPath,
                                  receiptCount:
                                      equipmentReceiptRows.length +
                                      orderReceiptRows.length,
                                  warrantyCount: warrantyRows.length,
                                  manualCount: manualRows.length,
                                ),
                                const SizedBox(height: 20),
                                _EvidenceSummaryRow(
                                  receiptCount:
                                      equipmentReceiptRows.length +
                                      orderReceiptRows.length,
                                  warrantyCount: warrantyRows.length,
                                  manualCount: manualRows.length,
                                ),
                                const SizedBox(height: 20),
                                _EvidenceActionStrip(
                                  onOpenEquipment: () =>
                                      context.push(RouteNames.assetEquipment),
                                  onOpenOrders: () =>
                                      context.push(RouteNames.assetOrdersTracker),
                                  onOpenValuation: () => context.push(
                                    RouteNames.assetValuationSummary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _EvidenceSection(
                                  title: 'Equipment receipts',
                                  icon: Icons.receipt_long_outlined,
                                  emptyText:
                                      'No equipment receipts are linked yet.',
                                  rows: equipmentReceiptRows,
                                  buildCard: (row) => _EvidenceRowCard(
                                    title: _firstNonEmpty(
                                      row,
                                      const ['name', 'asset_id'],
                                      fallback: 'Unnamed equipment',
                                    ),
                                    subtitle:
                                        'Receipt: ${_firstNonEmpty(row, const ['receipt_link'], fallback: 'No receipt link')}',
                                    chips: [
                                      _InfoChip(label: row['asset_id'] ?? 'No ID'),
                                      _InfoChip(
                                        label: _firstNonEmpty(
                                          row,
                                          const ['project'],
                                          fallback: 'No project',
                                        ),
                                      ),
                                      _InfoChip(
                                        label: _warrantyLabel(row['warranty_until']),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _EvidenceSection(
                                  title: 'Warranty dates',
                                  icon: Icons.verified_outlined,
                                  emptyText:
                                      'No warranty dates are linked yet.',
                                  rows: warrantyRows,
                                  buildCard: (row) => _EvidenceRowCard(
                                    title: _firstNonEmpty(
                                      row,
                                      const ['name', 'asset_id'],
                                      fallback: 'Unnamed equipment',
                                    ),
                                    subtitle:
                                        'Warranty until: ${row['warranty_until']?.trim() ?? ''}',
                                    chips: [
                                      _InfoChip(label: row['asset_id'] ?? 'No ID'),
                                      _InfoChip(
                                        label: _firstNonEmpty(
                                          row,
                                          const ['location'],
                                          fallback: 'No location',
                                        ),
                                      ),
                                      _InfoChip(
                                        label:
                                            _receiptLabel(row['receipt_link']),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _EvidenceSection(
                                  title: 'Manual pointers',
                                  icon: Icons.menu_book_outlined,
                                  emptyText:
                                      'No manual pointers were found in the current notes yet.',
                                  rows: manualRows,
                                  buildCard: (row) => _EvidenceRowCard(
                                    title: _firstNonEmpty(
                                      row,
                                      const ['name', 'asset_id'],
                                      fallback: 'Unnamed equipment',
                                    ),
                                    subtitle:
                                        'Notes: ${_manualHint(row['notes'])}',
                                    chips: [
                                      _InfoChip(label: row['asset_id'] ?? 'No ID'),
                                      _InfoChip(
                                        label: _firstNonEmpty(
                                          row,
                                          const ['type'],
                                          fallback: 'No type',
                                        ),
                                      ),
                                      _InfoChip(
                                        label:
                                            _receiptLabel(row['receipt_link']),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _EvidenceSection(
                                  title: 'Order receipts',
                                  icon: Icons.shopping_bag_outlined,
                                  emptyText:
                                      'No order receipts are linked yet.',
                                  rows: orderReceiptRows,
                                  buildCard: (row) => _EvidenceRowCard(
                                    title: _firstNonEmpty(
                                      row,
                                      const ['item', 'order_id'],
                                      fallback: 'Untitled order',
                                    ),
                                    subtitle:
                                        'Receipt: ${_firstNonEmpty(row, const ['receipt_link'], fallback: 'No receipt link')}',
                                    chips: [
                                      _InfoChip(label: row['order_id'] ?? 'No ID'),
                                      _InfoChip(
                                        label: _firstNonEmpty(
                                          row,
                                          const ['supplier'],
                                          fallback: 'No supplier',
                                        ),
                                      ),
                                      _InfoChip(
                                        label: _firstNonEmpty(
                                          row,
                                          const ['status'],
                                          fallback: 'No status',
                                        ),
                                      ),
                                    ],
                                  ),
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

class _EvidenceHeader extends StatelessWidget {
  const _EvidenceHeader({
    required this.assetPath,
    required this.receiptCount,
    required this.warrantyCount,
    required this.manualCount,
  });

  final String? assetPath;
  final int receiptCount;
  final int warrantyCount;
  final int manualCount;

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
                'Receipts / Warranties / Manuals',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColours.darkText,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Keep item evidence visible and calm so you can review proof, warranty timing, and manual pointers without hunting through folders.',
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
              _InfoChip(
                label: _countLabel(receiptCount, 'receipt linked', 'receipts linked'),
              ),
              _InfoChip(
                label: _countLabel(
                  warrantyCount,
                  'warranty dated',
                  'warranties dated',
                ),
              ),
              _InfoChip(
                label: _countLabel(
                  manualCount,
                  'manual pointer',
                  'manual pointers',
                ),
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

class _EvidenceSummaryRow extends StatelessWidget {
  const _EvidenceSummaryRow({
    required this.receiptCount,
    required this.warrantyCount,
    required this.manualCount,
  });

  final int receiptCount;
  final int warrantyCount;
  final int manualCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 840;
        final cards = [
          _MetricCard(
            label: 'Receipts linked',
            value: receiptCount,
            accent: AppColours.darkSecondary,
          ),
          _MetricCard(
            label: 'Warranties dated',
            value: warrantyCount,
            accent: AppColours.darkSuccess,
          ),
          _MetricCard(
            label: 'Manual pointers',
            value: manualCount,
            accent: AppColours.darkAmber,
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

class _EvidenceActionStrip extends StatelessWidget {
  const _EvidenceActionStrip({
    required this.onOpenEquipment,
    required this.onOpenOrders,
    required this.onOpenValuation,
  });

  final VoidCallback onOpenEquipment;
  final VoidCallback onOpenOrders;
  final VoidCallback onOpenValuation;

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
              onPressed: onOpenEquipment,
              icon: const Icon(Icons.precision_manufacturing_outlined),
              label: const Text('Open Equipment Register'),
            ),
            OutlinedButton.icon(
              onPressed: onOpenOrders,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Open Orders Tracker'),
            ),
            OutlinedButton.icon(
              onPressed: onOpenValuation,
              icon: const Icon(Icons.assessment_outlined),
              label: const Text('Open Valuation Summary'),
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
                    'Next actions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColours.darkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Jump straight to the registers that hold the source evidence instead of hunting through the dashboard.',
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
                width: 520,
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

class _EvidenceSection extends StatelessWidget {
  const _EvidenceSection({
    required this.title,
    required this.icon,
    required this.emptyText,
    required this.rows,
    required this.buildCard,
  });

  final String title;
  final IconData icon;
  final String emptyText;
  final List<Map<String, String>> rows;
  final Widget Function(Map<String, String> row) buildCard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColours.darkSecondary, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Text(
              emptyText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            )
          else
            Column(
              children: [
                for (var index = 0; index < rows.length; index++) ...[
                  buildCard(rows[index]),
                  if (index != rows.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _EvidenceRowCard extends StatelessWidget {
  const _EvidenceRowCard({
    required this.title,
    required this.subtitle,
    required this.chips,
  });

  final String title;
  final String subtitle;
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
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
            NumberFormat.decimalPattern().format(value),
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

class _EvidenceError extends StatelessWidget {
  const _EvidenceError({required this.onReload});

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
                'Evidence library could not load right now.',
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

bool _hasValue(String? value) {
  return value?.trim().isNotEmpty == true;
}

bool _looksLikeManualPointer(Map<String, String> row) {
  final notes = (row['notes'] ?? '').trim().toLowerCase();
  final receiptLink = (row['receipt_link'] ?? '').trim().toLowerCase();
  return notes.contains('manual') ||
      notes.contains('.pdf') ||
      receiptLink.contains('manual') ||
      receiptLink.contains('.pdf');
}

String _receiptLabel(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'No receipt link';
  }
  return 'Receipt linked';
}

String _warrantyLabel(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'No warranty date';
  }
  return 'Warranty dated';
}

String _firstNonEmpty(
  Map<String, String> row,
  List<String> keys, {
  required String fallback,
}) {
  for (final key in keys) {
    final value = row[key]?.trim() ?? '';
    if (value.isNotEmpty) {
      return value;
    }
  }
  return fallback;
}

String _manualHint(String? notes) {
  final trimmed = (notes ?? '').trim();
  if (trimmed.isEmpty) {
    return 'No manual pointer note yet.';
  }
  return trimmed;
}

String _countLabel(int count, String singular, String plural) {
  return count == 1 ? '1 $singular' : '$count $plural';
}
