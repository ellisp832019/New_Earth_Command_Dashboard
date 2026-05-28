import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';
import '../application/asset_treasury_links_controller.dart';
import '../data/assets_folder_service.dart';

class AssetsScreen extends ConsumerStatefulWidget {
  const AssetsScreen({super.key});

  @override
  ConsumerState<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends ConsumerState<AssetsScreen> {
  bool _isCreatingStructure = false;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(assetWorkspaceProvider);

    return snapshot.when(
      data: (data) => _AssetsContent(
        snapshot: data,
        isCreatingStructure: _isCreatingStructure,
        onCreateStructure: _handleCreateStructure,
        onReload: () => ref.invalidate(assetWorkspaceProvider),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: _AssetsError(
          onReload: () => ref.invalidate(assetWorkspaceProvider),
        ),
      ),
    );
  }

  Future<void> _handleCreateStructure() async {
    if (_isCreatingStructure) {
      return;
    }

    setState(() => _isCreatingStructure = true);
    try {
      final result = await ref
          .read(assetFolderServiceProvider)
          .createMissingRequiredStructure();

      if (!mounted) {
        return;
      }

      ref.invalidate(assetWorkspaceProvider);

      final createdCount =
          result.createdFolders.length + result.createdFiles.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            createdCount == 0
                ? 'Asset folder structure was already in place.'
                : 'Created $createdCount asset starter item${createdCount == 1 ? '' : 's'}.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreatingStructure = false);
      }
    }
  }
}

class _AssetsContent extends StatelessWidget {
  const _AssetsContent({
    required this.snapshot,
    required this.isCreatingStructure,
    required this.onCreateStructure,
    required this.onReload,
  });

  final AssetWorkspaceSnapshot snapshot;
  final bool isCreatingStructure;
  final VoidCallback onCreateStructure;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1100;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          cacheExtent: 2400,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 28 : 18,
                isWide ? 28 : 18,
                isWide ? 28 : 18,
                24,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AssetHero(snapshot: snapshot),
                    const SizedBox(height: 22),
                    _AssetHealthCard(
                      snapshot: snapshot,
                      isCreatingStructure: isCreatingStructure,
                      onCreateStructure: onCreateStructure,
                      onReload: onReload,
                    ),
                    const SizedBox(height: 22),
                    _AssetSummaryGrid(snapshot: snapshot),
                    const SizedBox(height: 22),
                    const _AssetTreasuryLinksCard(),
                    const SizedBox(height: 22),
                    _AssetRegisterLaunchCard(
                      onOpenEquipment: () =>
                          context.push(RouteNames.assetEquipment),
                      onOpenParts: () => context.push(RouteNames.assetParts),
                      onOpenLowStock: () => context.push(RouteNames.assetLowStock),
                      onOpenRepairSummary: () =>
                          context.push(RouteNames.assetRepairSummary),
                      onOpenProjectSummary: () =>
                          context.push(RouteNames.assetProjectSummary),
                      onOpenLocationRegister: () =>
                          context.push(RouteNames.assetLocationRegister),
                      onOpenValuationSummary: () =>
                          context.push(RouteNames.assetValuationSummary),
                    ),
                    const SizedBox(height: 22),
                    _AssetFolderCheckCard(snapshot: snapshot),
                    const SizedBox(height: 20),
                    _AssetFooter(theme: theme, snapshot: snapshot),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetHero extends StatelessWidget {
  const _AssetHero({required this.snapshot});

  final AssetWorkspaceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = snapshot.isReady ? 'Ready' : 'Setup needed';
    final headline = snapshot.isReady
        ? 'Asset Intelligence is linked and calm'
        : 'Set up the asset folder to begin tracking';
    final supportingCopy = snapshot.isReady
        ? 'Use this tab to keep equipment, parts, locations, and repair decisions clear without turning it into warehouse software.'
        : 'This tab stays local-first and only becomes fully useful once the external Omega OS assets folder is connected.';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(context, highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useWideLayout = constraints.maxWidth >= 980;

          final copy = ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assets',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColours.darkSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  headline,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColours.darkText,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  supportingCopy,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          );

          final chips = Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeaderChip(label: 'Status', value: statusLabel),
              _HeaderChip(
                label: 'Equipment',
                value: '${snapshot.equipmentCount}',
                accentColor: AppColours.darkSuccess,
              ),
              _HeaderChip(
                label: 'Parts',
                value: '${snapshot.partsCount}',
                accentColor: AppColours.darkSecondary,
              ),
            ],
          );

          if (!useWideLayout) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 18), chips],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: copy),
              const SizedBox(width: 24),
              SizedBox(width: 520, child: Align(alignment: Alignment.topRight, child: chips)),
            ],
          );
        },
      ),
    );
  }
}

class _AssetHealthCard extends StatelessWidget {
  const _AssetHealthCard({
    required this.snapshot,
    required this.isCreatingStructure,
    required this.onCreateStructure,
    required this.onReload,
  });

  final AssetWorkspaceSnapshot snapshot;
  final bool isCreatingStructure;
  final VoidCallback onCreateStructure;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: _panelDecoration(context),
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useWideLayout = constraints.maxWidth >= 960;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _PanelTitle(
                    title: 'Folder health',
                    icon: Icons.folder_open_outlined,
                  ),
                  const Spacer(),
                  _InlineTag(
                    label: snapshot.isReady ? 'Linked' : 'Needs setup',
                    accent: snapshot.isReady
                        ? AppColours.darkSuccess
                        : AppColours.darkAmber,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Source path',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                snapshot.assetsRootPath ?? 'Not linked yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                snapshot.guidanceNote,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
              ),
              if (snapshot.issues.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final issue in snapshot.issues)
                      _InlineTag(
                        label: issue,
                        accent: AppColours.darkAmber,
                        foreground: AppColours.darkText,
                      ),
                  ],
                ),
              ],
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: isCreatingStructure ? null : onCreateStructure,
                icon: isCreatingStructure
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.build_outlined),
                label: Text(
                  isCreatingStructure
                      ? 'Creating setup'
                      : 'Create starter files',
                ),
              ),
              TextButton.icon(
                onPressed: onReload,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
            ],
          );

          if (!useWideLayout) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [content, const SizedBox(height: 16), actions],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: content),
              const SizedBox(width: 20),
              SizedBox(width: 240, child: actions),
            ],
          );
        },
      ),
    );
  }
}

class _AssetSummaryGrid extends StatelessWidget {
  const _AssetSummaryGrid({required this.snapshot});

  final AssetWorkspaceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final cards = snapshot.summaryCards;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useThreeColumns = constraints.maxWidth >= 980;
        final cardWidth = useThreeColumns
            ? (constraints.maxWidth - 28) / 3
            : constraints.maxWidth;
        final accents = [
          AppColours.darkSuccess,
          AppColours.darkAmber,
          const Color(0xFFE26B6B),
          AppColours.darkSecondary,
          AppColours.darkPurple,
          AppColours.darkGlow,
        ];

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (var index = 0; index < cards.length; index++)
              SizedBox(
                width: useThreeColumns ? cardWidth : constraints.maxWidth,
                child: _SummaryCard(
                  data: cards[index],
                  accent: accents[index],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data, required this.accent});

  final AssetSummaryCard data;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${data.count}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetFolderCheckCard extends StatelessWidget {
  const _AssetFolderCheckCard({required this.snapshot});

  final AssetWorkspaceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: _panelDecoration(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            title: 'Required folders and files',
            icon: Icons.rule_folder_outlined,
          ),
          const SizedBox(height: 12),
          Text(
            'The dashboard only creates missing starter files. It never deletes user data.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          if (snapshot.missingFolders.isEmpty && snapshot.missingFiles.isEmpty)
            Text(
              'All required starter folders and files are present.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColours.darkSuccess,
                fontWeight: FontWeight.w600,
              ),
            )
          else ...[
            if (snapshot.missingFolders.isNotEmpty) ...[
              Text(
                'Missing folders',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final folder in snapshot.missingFolders)
                    _InlineTag(
                      label: folder,
                      accent: AppColours.darkAmber,
                      foreground: AppColours.darkText,
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (snapshot.missingFiles.isNotEmpty) ...[
              Text(
                'Missing files',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final file in snapshot.missingFiles)
                    _InlineTag(
                      label: file,
                      accent: AppColours.darkSecondary,
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _AssetRegisterLaunchCard extends StatelessWidget {
  const _AssetRegisterLaunchCard({
    required this.onOpenEquipment,
    required this.onOpenParts,
    required this.onOpenLowStock,
    required this.onOpenRepairSummary,
    required this.onOpenProjectSummary,
    required this.onOpenLocationRegister,
    required this.onOpenValuationSummary,
  });

  final VoidCallback onOpenEquipment;
  final VoidCallback onOpenParts;
  final VoidCallback onOpenLowStock;
  final VoidCallback onOpenRepairSummary;
  final VoidCallback onOpenProjectSummary;
  final VoidCallback onOpenLocationRegister;
  final VoidCallback onOpenValuationSummary;

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
            title: 'Registers',
            icon: Icons.view_list_outlined,
          ),
          const SizedBox(height: 10),
          Text(
            'Open the working registers for equipment and parts. These views stay calm and focused on the next useful action.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onOpenEquipment,
                icon: const Icon(Icons.precision_manufacturing_outlined),
                label: const Text('Equipment Register'),
              ),
              FilledButton.tonalIcon(
                onPressed: onOpenParts,
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Parts Inventory'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenLowStock,
                icon: const Icon(Icons.trending_down_outlined),
                label: const Text('Low Stock / Reorder'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenRepairSummary,
                icon: const Icon(Icons.build_circle_outlined),
                label: const Text('Broken / Repair'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenProjectSummary,
                icon: const Icon(Icons.groups_2_outlined),
                label: const Text('Project Summary'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenLocationRegister,
                icon: const Icon(Icons.place_outlined),
                label: const Text('Location Register'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenValuationSummary,
                icon: const Icon(Icons.assessment_outlined),
                label: const Text('Valuation Summary'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssetFooter extends StatelessWidget {
  const _AssetFooter({
    required this.theme,
    required this.snapshot,
  });

  final ThemeData theme;
  final AssetWorkspaceSnapshot snapshot;

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
          const Icon(Icons.inventory_2_outlined, color: AppColours.darkSuccess),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              snapshot.isReady
                  ? 'Asset Intelligence is connected and ready for the next register and CSV slice.'
                  : 'Connect the Omega OS assets folder to unlock the full asset workflow.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetTreasuryLinksCard extends ConsumerWidget {
  const _AssetTreasuryLinksCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(assetTreasuryLinkSummaryProvider);

    return summaryAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(20),
        decoration: _panelDecoration(context),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading Treasury links...'),
          ],
        ),
      ),
      error: (error, stackTrace) => Container(
        padding: const EdgeInsets.all(20),
        decoration: _panelDecoration(context),
        child: Text(
          'Treasury links could not load right now.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
              ),
        ),
      ),
      data: (summary) {
        final moneyFormatter = NumberFormat.currency(
          symbol: '£',
          decimalDigits: 2,
        );

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: _panelDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PanelTitle(
                title: 'Treasury links',
                icon: Icons.link_outlined,
              ),
              const SizedBox(height: 10),
              Text(
                'These cards stay summary-only. Treasury holds the money decisions, while Assets keeps the item records and link IDs tidy.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkMutedText,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 840;
                  final cards = [
                    _TreasuryLinkMetricCard(
                      label: 'Receipts missing',
                      value: summary.receiptsMissingCount.toString(),
                      note: 'Items waiting for a receipt link.',
                      accent: AppColours.darkAmber,
                    ),
                    _TreasuryLinkMetricCard(
                      label: 'Purchase cost',
                      value: moneyFormatter.format(summary.purchaseCostTotal),
                      note: 'Equipment spend already tracked in Assets.',
                      accent: AppColours.darkSecondary,
                    ),
                    _TreasuryLinkMetricCard(
                      label: 'Reorder estimate',
                      value: moneyFormatter.format(summary.reorderEstimatedSpend),
                      note: 'Low stock items that may need a calm reorder.',
                      accent: AppColours.darkSuccess,
                    ),
                    _TreasuryLinkMetricCard(
                      label: 'Linked finance IDs',
                      value: summary.linkedFinanceIdCount.toString(),
                      note: 'Order and maintenance records with finance links.',
                      accent: AppColours.darkPurple,
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
              ),
              const SizedBox(height: 16),
              Text(
                'Broken equipment value at risk: ${moneyFormatter.format(summary.repairReplacementValueTotal)} across ${summary.brokenEquipmentCount} item${summary.brokenEquipmentCount == 1 ? '' : 's'}.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkMutedText,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TreasuryLinkMetricCard extends StatelessWidget {
  const _TreasuryLinkMetricCard({
    required this.label,
    required this.value,
    required this.note,
    required this.accent,
  });

  final String label;
  final String value;
  final String note;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
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
          const SizedBox(height: 8),
          Text(
            note,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}

class _AssetsError extends StatelessWidget {
  const _AssetsError({required this.onReload});

  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Asset Intelligence could not load right now.',
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

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.label,
    required this.value,
    this.accentColor = AppColours.darkSecondary,
  });

  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w600,
                ),
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
              letterSpacing: 0.1,
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
