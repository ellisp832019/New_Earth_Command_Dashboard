import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';

class ValuationSummaryScreen extends ConsumerWidget {
  const ValuationSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(assetWorkspaceProvider);
    final equipment = ref.watch(assetEquipmentRegisterProvider);
    final valuation = ref.watch(assetValuationSummaryProvider);
    final overview = ref.watch(assetValuationOverviewProvider);

    return workspace.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => _ValuationError(
        onReload: () => ref.invalidate(assetWorkspaceProvider),
      ),
      data: (workspaceData) {
        return equipment.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => _ValuationError(
            onReload: () => ref.invalidate(assetEquipmentRegisterProvider),
          ),
          data: (equipmentTable) {
            return valuation.when(
              loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => _ValuationError(
                onReload: () => ref.invalidate(assetValuationSummaryProvider),
              ),
              data: (valuationTable) {
                return overview.when(
                  loading: () => const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => _ValuationError(
                    onReload: () => ref.invalidate(assetValuationOverviewProvider),
                  ),
                  data: (overviewData) {
                    final moneyFormatter = NumberFormat.currency(
                      symbol: '£',
                      decimalDigits: 2,
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
                                    _ValuationHeader(
                                      assetPath: workspaceData.assetsRootPath,
                                      valuationCount: valuationTable.rows.length,
                                      purchaseCostTotal:
                                          overviewData.purchaseCostTotal,
                                      replacementValueTotal:
                                          overviewData.replacementValueTotal,
                                      brokenLostValueTotal:
                                          overviewData.brokenLostValueTotal,
                                    ),
                                    const SizedBox(height: 20),
                                    _ValuationSummaryRow(
                                      purchaseCostTotal:
                                          overviewData.purchaseCostTotal,
                                      replacementValueTotal:
                                          overviewData.replacementValueTotal,
                                      currentEstimatedValueTotal:
                                          overviewData.currentEstimatedValueTotal,
                                      brokenLostValueTotal:
                                          overviewData.brokenLostValueTotal,
                                    ),
                                    const SizedBox(height: 20),
                                    _ValuationEvidenceCard(
                                      valuationRows: valuationTable.rows,
                                      equipmentRows: equipmentTable.rows,
                                    ),
                                    const SizedBox(height: 20),
                                    _ProjectValuationCard(
                                      projectTotals: overviewData.projectTotals,
                                      moneyFormatter: moneyFormatter,
                                    ),
                                    const SizedBox(height: 20),
                                    _ValuationEntriesCard(
                                      valuationRows: valuationTable.rows,
                                      equipmentRows: equipmentTable.rows,
                                      moneyFormatter: moneyFormatter,
                                    ),
                                    const SizedBox(height: 20),
                                    _ValuationFooter(
                                      itemCount: valuationTable.rows.length,
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
  }
}

class _ValuationHeader extends StatelessWidget {
  const _ValuationHeader({
    required this.assetPath,
    required this.valuationCount,
    required this.purchaseCostTotal,
    required this.replacementValueTotal,
    required this.brokenLostValueTotal,
  });

  final String? assetPath;
  final int valuationCount;
  final double purchaseCostTotal;
  final double replacementValueTotal;
  final double brokenLostValueTotal;

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
                'Valuation Summary',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColours.darkText,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'See what New Earth owns, what it cost, and what it may be worth without turning the tab into a finance spreadsheet.',
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
              _InfoChip(label: '$valuationCount valuation rows'),
              _InfoChip(
                label: 'Cost ${NumberFormat.currency(symbol: '£', decimalDigits: 2).format(purchaseCostTotal)}',
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

class _ValuationSummaryRow extends StatelessWidget {
  const _ValuationSummaryRow({
    required this.purchaseCostTotal,
    required this.replacementValueTotal,
    required this.currentEstimatedValueTotal,
    required this.brokenLostValueTotal,
  });

  final double purchaseCostTotal;
  final double replacementValueTotal;
  final double currentEstimatedValueTotal;
  final double brokenLostValueTotal;

  @override
  Widget build(BuildContext context) {
    final moneyFormatter = NumberFormat.currency(
      symbol: '£',
      decimalDigits: 2,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 840;
        final cards = [
          _MetricCard(
            label: 'Purchase cost',
            value: moneyFormatter.format(purchaseCostTotal),
            accent: AppColours.darkSecondary,
          ),
          _MetricCard(
            label: 'Replacement value',
            value: moneyFormatter.format(replacementValueTotal),
            accent: AppColours.darkSuccess,
          ),
          _MetricCard(
            label: 'Current estimate',
            value: moneyFormatter.format(currentEstimatedValueTotal),
            accent: AppColours.darkAmber,
          ),
          _MetricCard(
            label: 'Broken / lost value',
            value: moneyFormatter.format(brokenLostValueTotal),
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

class _ValuationEvidenceCard extends StatelessWidget {
  const _ValuationEvidenceCard({
    required this.valuationRows,
    required this.equipmentRows,
  });

  final List<Map<String, String>> valuationRows;
  final List<Map<String, String>> equipmentRows;

  @override
  Widget build(BuildContext context) {
    final evidenceLinkedCount = _countNonEmptyValues(valuationRows, 'evidence_link');
    final linkedAssetCount = _countNonEmptyValues(valuationRows, 'asset_id');
    final missingEvidenceCount = valuationRows.length - evidenceLinkedCount;
    final brokenLinkedCount = _countBrokenLinkedEntries(valuationRows, equipmentRows);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            title: 'Evidence check',
            icon: Icons.verified_outlined,
          ),
          const SizedBox(height: 10),
          Text(
            'Valuation rows stay easier to trust when each one has a linked asset and an evidence trail.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(label: '$evidenceLinkedCount linked'),
              _InfoChip(label: '$missingEvidenceCount missing'),
              _InfoChip(label: '$linkedAssetCount tied to an asset'),
              _InfoChip(label: '$brokenLinkedCount broken linked'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectValuationCard extends StatelessWidget {
  const _ProjectValuationCard({
    required this.projectTotals,
    required this.moneyFormatter,
  });

  final List<AssetValuationProjectTotal> projectTotals;
  final NumberFormat moneyFormatter;

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
            title: 'Asset value by project',
            icon: Icons.account_tree_outlined,
          ),
          const SizedBox(height: 12),
          if (projectTotals.isEmpty)
            Text(
              'No valuation rows have been linked to projects yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
              ),
            )
          else
            Column(
              children: [
                for (var index = 0; index < projectTotals.length; index++) ...[
                  _ProjectValuationRow(
                    total: projectTotals[index],
                    moneyFormatter: moneyFormatter,
                  ),
                  if (index != projectTotals.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _ProjectValuationRow extends StatelessWidget {
  const _ProjectValuationRow({
    required this.total,
    required this.moneyFormatter,
  });

  final AssetValuationProjectTotal total;
  final NumberFormat moneyFormatter;

  @override
  Widget build(BuildContext context) {
    final hasBrokenValue = total.brokenLostValueTotal > 0;
    final accent = hasBrokenValue ? const Color(0xFFE26B6B) : AppColours.darkSuccess;

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
                  total.projectName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              _StatusPill(
                label: total.items == 1 ? '1 item' : '${total.items} items',
                accent: accent,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: 'Cost ${moneyFormatter.format(total.purchaseCostTotal)}'),
              _InfoChip(label: 'Value ${moneyFormatter.format(total.currentEstimatedValueTotal)}'),
              _InfoChip(label: 'Replacement ${moneyFormatter.format(total.replacementValueTotal)}'),
              if (hasBrokenValue)
                _InfoChip(label: 'Broken ${moneyFormatter.format(total.brokenLostValueTotal)}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValuationEntriesCard extends StatelessWidget {
  const _ValuationEntriesCard({
    required this.valuationRows,
    required this.equipmentRows,
    required this.moneyFormatter,
  });

  final List<Map<String, String>> valuationRows;
  final List<Map<String, String>> equipmentRows;
  final NumberFormat moneyFormatter;

  @override
  Widget build(BuildContext context) {
    final equipmentById = <String, Map<String, String>>{};
    for (final row in equipmentRows) {
      final assetId = (row['asset_id'] ?? '').trim();
      if (assetId.isNotEmpty) {
        equipmentById[assetId] = row;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            title: 'Valuation entries',
            icon: Icons.receipt_long_outlined,
          ),
          const SizedBox(height: 12),
          if (valuationRows.isEmpty)
            Text(
              'No valuation rows have been logged yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
              ),
            )
          else
            Column(
              children: [
                for (var index = 0; index < valuationRows.length; index++) ...[
                  _ValuationEntryCard(
                    row: valuationRows[index],
                    equipment: equipmentById[valuationRows[index]['asset_id']?.trim() ?? ''],
                    moneyFormatter: moneyFormatter,
                  ),
                  if (index != valuationRows.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _ValuationEntryCard extends StatelessWidget {
  const _ValuationEntryCard({
    required this.row,
    required this.equipment,
    required this.moneyFormatter,
  });

  final Map<String, String> row;
  final Map<String, String>? equipment;
  final NumberFormat moneyFormatter;

  @override
  Widget build(BuildContext context) {
    final assetId = (row['asset_id'] ?? '').trim().isNotEmpty
        ? row['asset_id']!.trim()
        : 'No asset ID';
    final project = (equipment?['project'] ?? '').trim().isNotEmpty
        ? equipment!['project']!.trim()
        : 'Unassigned';
    final currentValue = double.tryParse((row['current_estimated_value'] ?? '').trim()) ??
        double.tryParse((row['replacement_value'] ?? '').trim()) ??
        0;
    final purchaseCost = double.tryParse((row['purchase_cost'] ?? '').trim()) ?? 0;
    final isBroken = (equipment?['status'] ?? '').trim().toLowerCase() == 'broken' ||
        (equipment?['condition'] ?? '').trim().toLowerCase() == 'broken';
    final accent = isBroken ? const Color(0xFFE26B6B) : AppColours.darkSecondary;

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
                  row['item']?.trim().isNotEmpty == true
                      ? row['item']!.trim()
                      : 'Unnamed asset',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              _StatusPill(
                label: isBroken ? 'broken' : 'valued',
                accent: accent,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: assetId),
              _InfoChip(label: project),
              _InfoChip(label: moneyFormatter.format(purchaseCost)),
              _InfoChip(label: moneyFormatter.format(currentValue)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            row['valuation_reason']?.trim().isNotEmpty == true
                ? row['valuation_reason']!.trim()
                : 'No valuation note yet.',
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

int _countNonEmptyValues(
  List<Map<String, String>> rows,
  String key,
) {
  var count = 0;
  for (final row in rows) {
    if ((row[key] ?? '').trim().isNotEmpty) {
      count += 1;
    }
  }
  return count;
}

int _countBrokenLinkedEntries(
  List<Map<String, String>> valuationRows,
  List<Map<String, String>> equipmentRows,
) {
  final equipmentById = <String, Map<String, String>>{};
  for (final row in equipmentRows) {
    final assetId = (row['asset_id'] ?? '').trim();
    if (assetId.isNotEmpty) {
      equipmentById[assetId] = row;
    }
  }

  var count = 0;
  for (final row in valuationRows) {
    final assetId = (row['asset_id'] ?? '').trim();
    final equipment = equipmentById[assetId];
    final isBroken = (equipment?['status'] ?? '').trim().toLowerCase() == 'broken' ||
        (equipment?['condition'] ?? '').trim().toLowerCase() == 'broken';
    if (assetId.isNotEmpty && isBroken) {
      count += 1;
    }
  }
  return count;
}

class _ValuationFooter extends StatelessWidget {
  const _ValuationFooter({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_outlined, color: AppColours.darkSuccess),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$itemCount valuation rows are in the current register. Keep the evidence calm and easy to review.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValuationError extends StatelessWidget {
  const _ValuationError({required this.onReload});

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
                'Valuation summary could not load right now.',
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
  final String value;
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
            value,
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColours.darkText,
              ),
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
