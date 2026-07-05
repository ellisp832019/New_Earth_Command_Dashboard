import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/assets_controller.dart';
import '../application/asset_treasury_links_controller.dart';
import '../data/asset_summary_report.dart';
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
      loading: () => WorkspaceShell(
        title: 'Assets',
        subtitle: 'Asset workspace',
        onBack: () => context.go(RouteNames.more),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => WorkspaceShell(
        title: 'Assets',
        subtitle: 'Asset workspace',
        onBack: () => context.go(RouteNames.more),
        child: _AssetsError(
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

    return WorkspaceShell(
      title: 'Assets',
      subtitle: 'Asset workspace',
      onBack: () => context.go(RouteNames.more),
      child: SafeArea(
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
                    _AssetPriorityCard(
                      snapshot: snapshot,
                      onOpenQuickCapture: () =>
                          context.push(RouteNames.assetQuickCapture),
                      onOpenVisualCapture: () =>
                          context.push(RouteNames.visualCapture),
                      onOpenEquipment: () =>
                          context.push(RouteNames.assetEquipment),
                      onOpenParts: () => context.push(RouteNames.assetParts),
                      onOpenLowStock: () =>
                          context.push(RouteNames.assetLowStock),
                      onOpenRepairSummary: () =>
                          context.push(RouteNames.assetRepairSummary),
                      onOpenQrLabels: () =>
                          context.push(RouteNames.assetQrLabelRegister),
                      onOpenQrStudio: () =>
                          context.push(RouteNames.assetQrLabelStudio),
                      onOpenQrHistory: () =>
                          context.push(RouteNames.assetQrLabelHistory),
                    ),
                    const SizedBox(height: 22),
                    _AssetDecisionBridgeCard(
                      onOpenLowStock: () =>
                          context.push(RouteNames.assetLowStock),
                      onOpenRepairSummary: () =>
                          context.push(RouteNames.assetRepairSummary),
                      onOpenValuationSummary: () =>
                          context.push(RouteNames.assetValuationSummary),
                    ),
                    const SizedBox(height: 22),
                    const _AssetSyncStatusCard(),
                    const SizedBox(height: 22),
                    const _AssetReportExportCard(),
                    const SizedBox(height: 22),
                    _AssetSummaryGrid(snapshot: snapshot),
                    const SizedBox(height: 22),
                    const _AssetTreasuryLinksCard(),
                    const SizedBox(height: 22),
                    _AssetRegisterLaunchCard(
                      onOpenEquipment: () =>
                          context.push(RouteNames.assetEquipment),
                      onOpenParts: () => context.push(RouteNames.assetParts),
                      onOpenLowStock: () =>
                          context.push(RouteNames.assetLowStock),
                      onOpenRepairSummary: () =>
                          context.push(RouteNames.assetRepairSummary),
                      onOpenProjectSummary: () =>
                          context.push(RouteNames.assetProjectSummary),
                      onOpenLocationRegister: () =>
                          context.push(RouteNames.assetLocationRegister),
                      onOpenBinMap: () => context.push(RouteNames.assetBinMap),
                      onOpenQrLifecycle: () =>
                          context.push(RouteNames.assetQrLifecycle),
                      onOpenEvidenceLibrary: () =>
                          context.push(RouteNames.assetEvidenceLibrary),
                      onOpenSupplierRegister: () =>
                          context.push(RouteNames.assetSupplierRegister),
                      onOpenMaintenanceLog: () =>
                          context.push(RouteNames.assetMaintenanceLog),
                      onOpenReorderList: () =>
                          context.push(RouteNames.assetReorderList),
                      onOpenOrdersTracker: () =>
                          context.push(RouteNames.assetOrdersTracker),
                      onOpenValuationSummary: () =>
                          context.push(RouteNames.assetValuationSummary),
                      onOpenQrLabelRegister: () =>
                          context.push(RouteNames.assetQrLabelRegister),
                      onOpenQrLabelStudio: () =>
                          context.push(RouteNames.assetQrLabelStudio),
                      onOpenQrHistory: () =>
                          context.push(RouteNames.assetQrLabelHistory),
                      onOpenQrPrintQueue: () =>
                          context.push(RouteNames.assetQrPrintQueue),
                      onOpenScanLookup: () =>
                          context.push(RouteNames.assetScanLookup),
                      onOpenInventorySession: () =>
                          context.push(RouteNames.assetInventorySession),
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
        ? 'Asset Intelligence is linked and ready'
        : 'Link the asset folder to begin tracking';
    final supportingCopy = snapshot.isReady
        ? 'Use this space to keep equipment, parts, locations, and repair decisions clear without turning it into warehouse software.'
        : 'This space stays local-first and becomes fully useful once the external Omega OS assets folder is connected.';
    final lowStockCount = _summaryCount(snapshot, AssetSummaryKind.lowStock);
    final brokenCount = _summaryCount(snapshot, AssetSummaryKind.brokenRepair);
    final projectSummaryCount = _summaryCount(
      snapshot,
      AssetSummaryKind.projectSummary,
    );

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
                const SizedBox(height: 6),
                Text(
                  'Dashboard / Assets',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                    letterSpacing: 0.2,
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
                label: 'Config',
                value: path.basename(snapshot.configPath),
                accentColor: AppColours.darkSecondary,
              ),
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
              _HeaderChip(
                label: 'Low stock',
                value: '$lowStockCount',
                accentColor: AppColours.darkAmber,
              ),
              _HeaderChip(
                label: 'Repair',
                value: '$brokenCount',
                accentColor: AppColours.darkAmber,
              ),
              _HeaderChip(
                label: 'Projects',
                value: '$projectSummaryCount',
                accentColor: AppColours.darkPurple,
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
              SizedBox(
                width: 520,
                child: Align(alignment: Alignment.topRight, child: chips),
              ),
            ],
          );
        },
      ),
    );
  }

  int _summaryCount(AssetWorkspaceSnapshot snapshot, AssetSummaryKind kind) {
    for (final card in snapshot.summaryCards) {
      if (card.kind == kind) {
        return card.count;
      }
    }
    return 0;
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
                'Configuration file',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                snapshot.configPath,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 6),
              Text(
                'The dashboard reads this path locally and checks it against the Omega OS asset folder.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
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
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _InlineTag(
                    label:
                        '${snapshot.requiredFolders.length} required folders',
                    accent: AppColours.darkSecondary,
                    foreground: AppColours.darkText,
                  ),
                  _InlineTag(
                    label: '${snapshot.missingFolders.length} missing folders',
                    accent: snapshot.missingFolders.isEmpty
                        ? AppColours.darkSuccess
                        : AppColours.darkAmber,
                    foreground: AppColours.darkText,
                  ),
                  _InlineTag(
                    label: '${snapshot.missingFiles.length} missing files',
                    accent: snapshot.missingFiles.isEmpty
                        ? AppColours.darkSuccess
                        : AppColours.darkAmber,
                    foreground: AppColours.darkText,
                  ),
                ],
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
              if (snapshot.missingFolders.isNotEmpty ||
                  snapshot.missingFiles.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Missing data',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Starter folders and tracker files are missing, so the setup helper can finish the structure cleanly.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (snapshot.missingFolders.isNotEmpty)
                      _InlineTag(
                        label:
                            '${snapshot.missingFolders.length} folder${snapshot.missingFolders.length == 1 ? '' : 's'} missing',
                        accent: AppColours.darkAmber,
                        foreground: AppColours.darkText,
                      ),
                    if (snapshot.missingFiles.isNotEmpty)
                      _InlineTag(
                        label:
                            '${snapshot.missingFiles.length} file${snapshot.missingFiles.length == 1 ? '' : 's'} missing',
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
                child: _SummaryCard(data: cards[index], accent: accents[index]),
              ),
          ],
        );
      },
    );
  }
}

class _AssetPriorityCard extends StatelessWidget {
  const _AssetPriorityCard({
    required this.snapshot,
    required this.onOpenQuickCapture,
    required this.onOpenVisualCapture,
    required this.onOpenEquipment,
    required this.onOpenParts,
    required this.onOpenLowStock,
    required this.onOpenRepairSummary,
    required this.onOpenQrLabels,
    required this.onOpenQrStudio,
    required this.onOpenQrHistory,
  });

  final AssetWorkspaceSnapshot snapshot;
  final VoidCallback onOpenQuickCapture;
  final VoidCallback onOpenVisualCapture;
  final VoidCallback onOpenEquipment;
  final VoidCallback onOpenParts;
  final VoidCallback onOpenLowStock;
  final VoidCallback onOpenRepairSummary;
  final VoidCallback onOpenQrLabels;
  final VoidCallback onOpenQrStudio;
  final VoidCallback onOpenQrHistory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lowStockCount = _summaryCount(AssetSummaryKind.lowStock);
    final brokenCount = _summaryCount(AssetSummaryKind.brokenRepair);
    final needsDecisionCount = _summaryCount(AssetSummaryKind.needsDecision);
    final wishlistCount = _summaryCount(AssetSummaryKind.wishlist);

    final hasSetupWork = !snapshot.isReady;
    final headline = hasSetupWork
        ? 'Finish setup first'
        : lowStockCount > 0
        ? 'Low stock needs attention'
        : brokenCount > 0
        ? 'Broken / repair items need review'
        : needsDecisionCount > 0
        ? 'A few items need a clear decision'
        : wishlistCount > 0
        ? 'Wishlist items are parked for later'
        : 'The asset workflow is steady';
    final supportingCopy = hasSetupWork
        ? 'Create the starter structure first, then move into the registers.'
        : lowStockCount > 0
        ? '$lowStockCount part${lowStockCount == 1 ? '' : 's'} are at or below threshold. Start with stock, then move to the next clear step.'
        : brokenCount > 0
        ? '$brokenCount equipment item${brokenCount == 1 ? '' : 's'} need a repair or replacement check. Keep the next step short.'
        : needsDecisionCount > 0
        ? '$needsDecisionCount item${needsDecisionCount == 1 ? '' : 's'} are waiting for a decision.'
        : 'Use the registers below to keep the workflow moving without clutter.';

    final topThreeActions = [
      _PriorityAction(
        label: '1. Open Equipment Register',
        detail: hasSetupWork
            ? 'Set up the starter files before reviewing equipment.'
            : 'Start with the main register so the asset list stays current.',
        icon: Icons.precision_manufacturing_outlined,
        onPressed: onOpenEquipment,
        accent: AppColours.darkSuccess,
      ),
      _PriorityAction(
        label: '2. Open Parts Inventory',
        detail: hasSetupWork
            ? 'Parts tracking becomes easier once the source folder is ready.'
            : 'Check stock and part links before anything gets crowded.',
        icon: Icons.inventory_2_outlined,
        onPressed: onOpenParts,
        accent: AppColours.darkSecondary,
      ),
      _PriorityAction(
        label: hasSetupWork
            ? '3. Create starter files'
            : lowStockCount > 0
            ? '3. Open Low Stock / Reorder'
            : brokenCount > 0
            ? '3. Open Broken / Repair'
            : '3. Open QR Labels',
        detail: hasSetupWork
            ? 'Finish the setup structure first, then move into tracking.'
            : lowStockCount > 0
            ? '$lowStockCount part${lowStockCount == 1 ? '' : 's'} are waiting for a reorder check.'
            : brokenCount > 0
            ? '$brokenCount equipment item${brokenCount == 1 ? '' : 's'} need a repair or replacement check.'
            : 'Labels are ready if you want to tag items without leaving the home page.',
        icon: hasSetupWork
            ? Icons.build_outlined
            : lowStockCount > 0
            ? Icons.trending_down_outlined
            : brokenCount > 0
            ? Icons.build_circle_outlined
            : Icons.qr_code_2_outlined,
        onPressed: hasSetupWork
            ? onOpenEquipment
            : lowStockCount > 0
            ? onOpenLowStock
            : brokenCount > 0
            ? onOpenRepairSummary
            : onOpenQrLabels,
        accent: hasSetupWork
            ? AppColours.darkAmber
            : lowStockCount > 0
            ? AppColours.darkAmber
            : brokenCount > 0
            ? const Color(0xFFE26B6B)
            : AppColours.darkPurple,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 980;

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PanelTitle(
                title: 'Priority focus',
                icon: Icons.priority_high_outlined,
              ),
              const SizedBox(height: 10),
              Text(
                headline,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                supportingCopy,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              _PriorityActionStrip(
                title: 'Top 3 focus',
                subtitle:
                    'Keep the first pass short: equipment, parts, then the next pressure point.',
                actions: topThreeActions,
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: wide ? WrapAlignment.end : WrapAlignment.start,
            children: [
              FilledButton.icon(
                onPressed: onOpenQuickCapture,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Quick Capture'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenVisualCapture,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Visual Capture'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenQrLabels,
                icon: const Icon(Icons.qr_code_2_outlined),
                label: const Text('Open QR Labels'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenQrStudio,
                icon: const Icon(Icons.print_outlined),
                label: const Text('Open QR Studio'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenQrHistory,
                icon: const Icon(Icons.history_outlined),
                label: const Text('QR History'),
              ),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 16), actions],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: copy),
              const SizedBox(width: 20),
              SizedBox(width: 420, child: actions),
            ],
          );
        },
      ),
    );
  }

  int _summaryCount(AssetSummaryKind kind) {
    for (final card in snapshot.summaryCards) {
      if (card.kind == kind) {
        return card.count;
      }
    }
    return 0;
  }
}

class _AssetDecisionBridgeCard extends ConsumerWidget {
  const _AssetDecisionBridgeCard({
    required this.onOpenLowStock,
    required this.onOpenRepairSummary,
    required this.onOpenValuationSummary,
  });

  final VoidCallback onOpenLowStock;
  final VoidCallback onOpenRepairSummary;
  final VoidCallback onOpenValuationSummary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStock = ref.watch(assetLowStockPartsProvider);
    final broken = ref.watch(assetBrokenRepairEquipmentProvider);
    final valuation = ref.watch(assetValuationSummaryProvider);
    final overview = ref.watch(assetValuationOverviewProvider);

    return lowStock.when(
      loading: () => _DecisionBridgeShell(
        title: 'Decision bridge',
        subtitle:
            'Loading the asset-side decision signals so the next action stays clear.',
        chips: [
          _InlineTag(
            label: 'Loading',
            accent: AppColours.darkSecondary,
            foreground: AppColours.darkText,
          ),
        ],
        actions: const SizedBox.shrink(),
      ),
      error: (error, stackTrace) => _DecisionBridgeShell(
        title: 'Decision bridge',
        subtitle:
            'Asset decision signals could not load right now, but the rest of the tab is still usable.',
        chips: [
          _InlineTag(
            label: 'Try reload',
            accent: AppColours.darkAmber,
            foreground: AppColours.darkText,
          ),
        ],
        actions: const SizedBox.shrink(),
      ),
      data: (lowStockRows) {
        return broken.when(
          loading: () => _DecisionBridgeShell(
            title: 'Decision bridge',
            subtitle:
                'Loading the asset-side decision signals so the next action stays clear.',
            chips: [
              _InlineTag(
                label: 'Loading',
                accent: AppColours.darkSecondary,
                foreground: AppColours.darkText,
              ),
            ],
            actions: const SizedBox.shrink(),
          ),
          error: (error, stackTrace) => _DecisionBridgeShell(
            title: 'Decision bridge',
            subtitle:
                'Asset decision signals could not load right now, but the rest of the tab is still usable.',
            chips: [
              _InlineTag(
                label: 'Try reload',
                accent: AppColours.darkAmber,
                foreground: AppColours.darkText,
              ),
            ],
            actions: const SizedBox.shrink(),
          ),
          data: (brokenRows) {
            return valuation.when(
              loading: () => _DecisionBridgeShell(
                title: 'Decision bridge',
                subtitle:
                    'Loading the asset-side decision signals so the next action stays clear.',
                chips: [
                  _InlineTag(
                    label: 'Loading',
                    accent: AppColours.darkSecondary,
                    foreground: AppColours.darkText,
                  ),
                ],
                actions: const SizedBox.shrink(),
              ),
              error: (error, stackTrace) => _DecisionBridgeShell(
                title: 'Decision bridge',
                subtitle:
                    'Asset decision signals could not load right now, but the rest of the tab is still usable.',
                chips: [
                  _InlineTag(
                    label: 'Try reload',
                    accent: AppColours.darkAmber,
                    foreground: AppColours.darkText,
                  ),
                ],
                actions: const SizedBox.shrink(),
              ),
              data: (valuationTable) {
                return overview.when(
                  loading: () => _DecisionBridgeShell(
                    title: 'Decision bridge',
                    subtitle:
                        'Loading the asset-side decision signals so the next action stays clear.',
                    chips: [
                      _InlineTag(
                        label: 'Loading',
                        accent: AppColours.darkSecondary,
                        foreground: AppColours.darkText,
                      ),
                    ],
                    actions: const SizedBox.shrink(),
                  ),
                  error: (error, stackTrace) => _DecisionBridgeShell(
                    title: 'Decision bridge',
                    subtitle:
                        'Asset decision signals could not load right now, but the rest of the tab is still usable.',
                    chips: [
                      _InlineTag(
                        label: 'Try reload',
                        accent: AppColours.darkAmber,
                        foreground: AppColours.darkText,
                      ),
                    ],
                    actions: const SizedBox.shrink(),
                  ),
                  data: (overviewData) {
                    final linkedEvidenceCount = _countNonEmptyValues(
                      valuationTable.rows,
                      'evidence_link',
                    );
                    final missingEvidenceCount =
                        valuationTable.rows.length - linkedEvidenceCount;
                    final repairCount = brokenRows.length;
                    final lowStockCount = lowStockRows.length;
                    final decisionCount =
                        lowStockCount + repairCount + missingEvidenceCount;
                    final totalTrackedValue =
                        overviewData.currentEstimatedValueTotal;

                    final List<Widget> chips = [
                      _InlineTag(
                        label: '$lowStockCount low stock',
                        accent: AppColours.darkSecondary,
                        foreground: AppColours.darkText,
                      ),
                      _InlineTag(
                        label: '$repairCount repair',
                        accent: AppColours.darkAmber,
                        foreground: AppColours.darkText,
                      ),
                      _InlineTag(
                        label: '$linkedEvidenceCount linked',
                        accent: AppColours.darkSuccess,
                        foreground: AppColours.darkText,
                      ),
                      _InlineTag(
                        label: '$missingEvidenceCount missing evidence',
                        accent: const Color(0xFFE26B6B),
                        foreground: AppColours.darkText,
                      ),
                    ];

                    final subtitle = decisionCount == 0
                        ? 'No decision pressure is showing from the current asset registers. Keep the local records calm and easy to review.'
                        : '$decisionCount item${decisionCount == 1 ? '' : 's'} still need a clear next step across stock, repair, or valuation evidence.';

                    final actions = Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: onOpenLowStock,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Open Low Stock'),
                        ),
                        OutlinedButton.icon(
                          onPressed: onOpenRepairSummary,
                          icon: const Icon(Icons.build_outlined),
                          label: const Text('Open Repair'),
                        ),
                        OutlinedButton.icon(
                          onPressed: onOpenValuationSummary,
                          icon: const Icon(Icons.verified_outlined),
                          label: const Text('Open Valuation'),
                        ),
                      ],
                    );

                    return _DecisionBridgeShell(
                      title: 'Decision bridge',
                      subtitle: subtitle,
                      chips: chips,
                      trailingCopy:
                          'Estimated tracked value: ${NumberFormat.currency(symbol: '£', decimalDigits: 2).format(totalTrackedValue)}',
                      actions: actions,
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

class _DecisionBridgeShell extends StatelessWidget {
  const _DecisionBridgeShell({
    required this.title,
    required this.subtitle,
    required this.chips,
    required this.actions,
    this.trailingCopy,
  });

  final String title;
  final String subtitle;
  final List<Widget> chips;
  final Widget actions;
  final String? trailingCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 980;

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PanelTitle(title: title, icon: Icons.account_tree_outlined),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
              ),
              if (trailingCopy != null) ...[
                const SizedBox(height: 10),
                Text(
                  trailingCopy!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          );

          final chipWrap = Wrap(spacing: 10, runSpacing: 10, children: chips);

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 16),
                chipWrap,
                const SizedBox(height: 16),
                actions,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: copy),
              const SizedBox(width: 20),
              SizedBox(
                width: 450,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(alignment: Alignment.centerRight, child: chipWrap),
                    const SizedBox(height: 16),
                    Align(alignment: Alignment.centerRight, child: actions),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AssetSyncStatusCard extends ConsumerWidget {
  const _AssetSyncStatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(assetSyncStatusProvider);
    final theme = Theme.of(context);

    return syncStatus.when(
      loading: () => Container(
        padding: const EdgeInsets.all(20),
        decoration: _panelDecoration(context),
        child: const _PanelTitle(
          title: 'Asset sync',
          icon: Icons.sync_outlined,
        ),
      ),
      error: (error, stackTrace) => Container(
        padding: const EdgeInsets.all(20),
        decoration: _panelDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PanelTitle(
              title: 'Asset sync',
              icon: Icons.sync_problem_outlined,
            ),
            const SizedBox(height: 10),
            Text(
              'The journal status could not load right now.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
      data: (status) {
        final lastChangeLabel = status.lastChangeAt == null
            ? 'No journal entries yet'
            : DateFormat(
                'yMMMd, h:mm a',
              ).format(status.lastChangeAt!.toLocal());

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: _panelDecoration(context),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 980;

              final copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _PanelTitle(
                    title: 'Asset sync',
                    icon: Icons.sync_outlined,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    status.statusLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColours.darkText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status.isConnected
                        ? 'The journal is linked and ready for calm review across machines.'
                        : 'The journal is not linked yet, so the tab is still in single-machine mode.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkMutedText,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      ref.invalidate(assetChangeJournalEntriesProvider);
                      ref.invalidate(assetChangeConflictsProvider);
                      ref.invalidate(assetSyncStatusProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh journal'),
                  ),
                ],
              );

              final chips = Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _InlineTag(
                    label: '${status.entryCount} journal entries',
                    accent: AppColours.darkSecondary,
                    foreground: AppColours.darkText,
                  ),
                  _InlineTag(
                    label: '${status.conflictCount} conflicts',
                    accent: AppColours.darkAmber,
                    foreground: AppColours.darkText,
                  ),
                  _InlineTag(
                    label: status.lastWriterLabel,
                    accent: AppColours.darkSuccess,
                    foreground: AppColours.darkText,
                  ),
                  _InlineTag(
                    label: lastChangeLabel,
                    accent: const Color(0xFFE26B6B),
                    foreground: AppColours.darkText,
                  ),
                ],
              );

              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    copy,
                    const SizedBox(height: 16),
                    chips,
                    if (status.conflictCount > 0) ...[
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.push(RouteNames.assetConflictReview),
                          icon: const Icon(Icons.rule_folder_outlined),
                          label: const Text('Review Conflicts'),
                        ),
                      ),
                    ],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: copy),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 450,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Align(alignment: Alignment.topRight, child: chips),
                        if (status.conflictCount > 0) ...[
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.push(RouteNames.assetConflictReview),
                            icon: const Icon(Icons.rule_folder_outlined),
                            label: const Text('Review Conflicts'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _AssetReportExportCard extends ConsumerStatefulWidget {
  const _AssetReportExportCard();

  @override
  ConsumerState<_AssetReportExportCard> createState() =>
      _AssetReportExportCardState();
}

class _AssetReportExportCardState
    extends ConsumerState<_AssetReportExportCard> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref
        .watch(assetWorkspaceProvider)
        .maybeWhen(data: (data) => data, orElse: () => null);
    final syncStatus = ref
        .watch(assetSyncStatusProvider)
        .maybeWhen(data: (data) => data, orElse: () => null);
    final treasurySummary = ref
        .watch(assetTreasuryLinkSummaryProvider)
        .maybeWhen(data: (data) => data, orElse: () => null);
    final theme = Theme.of(context);
    final canExport =
        snapshot?.assetsRootPath != null &&
        syncStatus != null &&
        treasurySummary != null;

    return Container(
      decoration: _panelDecoration(context),
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useWideLayout = constraints.maxWidth >= 960;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PanelTitle(
                title: 'Asset summary report',
                icon: Icons.description_outlined,
              ),
              const SizedBox(height: 10),
              Text(
                'Create a calm local snapshot of the current asset counts, sync status, and Treasury link summary.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Saved to 00_ASSET_DASHBOARD/asset_intelligence_summary.md',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
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
                onPressed: _isExporting || !canExport ? null : _exportReport,
                icon: _isExporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_outlined),
                label: Text(
                  _isExporting ? 'Exporting' : 'Export summary report',
                ),
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
              SizedBox(width: 260, child: actions),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportReport() async {
    final snapshot = ref
        .read(assetWorkspaceProvider)
        .maybeWhen(data: (data) => data, orElse: () => null);
    final syncStatus = ref
        .read(assetSyncStatusProvider)
        .maybeWhen(data: (data) => data, orElse: () => null);
    final treasurySummary = ref
        .read(assetTreasuryLinkSummaryProvider)
        .maybeWhen(data: (data) => data, orElse: () => null);
    if (snapshot?.assetsRootPath == null ||
        syncStatus == null ||
        treasurySummary == null) {
      return;
    }

    setState(() => _isExporting = true);
    try {
      final report = _buildReport(
        snapshot: snapshot!,
        syncStatus: syncStatus,
        treasurySummary: treasurySummary,
      );
      final file = File(
        path.join(
          snapshot.assetsRootPath!,
          '00_ASSET_DASHBOARD',
          'asset_intelligence_summary.md',
        ),
      );
      await ref
          .read(assetFolderServiceProvider)
          .writeTextFileWithBackup(file, report);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asset summary report exported.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  String _buildReport({
    required AssetWorkspaceSnapshot snapshot,
    required AssetSyncStatus syncStatus,
    required AssetTreasuryLinkSummary treasurySummary,
  }) {
    return buildAssetSummaryReport(
      snapshot: snapshot,
      syncStatus: syncStatus,
      treasurySummary: treasurySummary,
    );
  }
}

int _countNonEmptyValues(List<Map<String, String>> rows, String key) {
  var count = 0;
  for (final row in rows) {
    if ((row[key] ?? '').trim().isNotEmpty) {
      count += 1;
    }
  }
  return count;
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

class _PriorityActionStrip extends StatelessWidget {
  const _PriorityActionStrip({
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final List<_PriorityAction> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 860;

        final strip = [
          for (final action in actions) _PriorityActionCard(action: action),
        ];

        return Column(
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            if (wide)
              Row(
                children: [
                  Expanded(child: strip[0]),
                  const SizedBox(width: 10),
                  Expanded(child: strip[1]),
                  const SizedBox(width: 10),
                  Expanded(child: strip[2]),
                ],
              )
            else
              Column(
                children: [
                  strip[0],
                  const SizedBox(height: 10),
                  strip[1],
                  const SizedBox(height: 10),
                  strip[2],
                ],
              ),
          ],
        );
      },
    );
  }
}

class _PriorityAction {
  const _PriorityAction({
    required this.label,
    required this.detail,
    required this.icon,
    required this.onPressed,
    required this.accent,
  });

  final String label;
  final String detail;
  final IconData icon;
  final VoidCallback onPressed;
  final Color accent;
}

class _PriorityActionCard extends StatelessWidget {
  const _PriorityActionCard({required this.action});

  final _PriorityAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColours.darkSurfaceAlt.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: action.onPressed,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: action.accent.withValues(alpha: 0.22)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: action.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(action.icon, color: action.accent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.detail,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: action.accent),
            ],
          ),
        ),
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
                    _InlineTag(label: file, accent: AppColours.darkSecondary),
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
    required this.onOpenBinMap,
    required this.onOpenQrLifecycle,
    required this.onOpenEvidenceLibrary,
    required this.onOpenSupplierRegister,
    required this.onOpenMaintenanceLog,
    required this.onOpenReorderList,
    required this.onOpenOrdersTracker,
    required this.onOpenValuationSummary,
    required this.onOpenQrLabelRegister,
    required this.onOpenQrLabelStudio,
    required this.onOpenQrHistory,
    required this.onOpenQrPrintQueue,
    required this.onOpenScanLookup,
    required this.onOpenInventorySession,
  });

  final VoidCallback onOpenEquipment;
  final VoidCallback onOpenParts;
  final VoidCallback onOpenLowStock;
  final VoidCallback onOpenRepairSummary;
  final VoidCallback onOpenProjectSummary;
  final VoidCallback onOpenLocationRegister;
  final VoidCallback onOpenBinMap;
  final VoidCallback onOpenQrLifecycle;
  final VoidCallback onOpenEvidenceLibrary;
  final VoidCallback onOpenSupplierRegister;
  final VoidCallback onOpenMaintenanceLog;
  final VoidCallback onOpenReorderList;
  final VoidCallback onOpenOrdersTracker;
  final VoidCallback onOpenValuationSummary;
  final VoidCallback onOpenQrLabelRegister;
  final VoidCallback onOpenQrLabelStudio;
  final VoidCallback onOpenQrHistory;
  final VoidCallback onOpenQrPrintQueue;
  final VoidCallback onOpenScanLookup;
  final VoidCallback onOpenInventorySession;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(title: 'Registers', icon: Icons.view_list_outlined),
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
                onPressed: onOpenBinMap,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Bin Map'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenQrLifecycle,
                icon: const Icon(Icons.timeline_outlined),
                label: const Text('QR Lifecycle'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenEvidenceLibrary,
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Receipts / Warranties / Manuals'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenSupplierRegister,
                icon: const Icon(Icons.local_shipping_outlined),
                label: const Text('Supplier Register'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenMaintenanceLog,
                icon: const Icon(Icons.build_outlined),
                label: const Text('Maintenance Log'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenReorderList,
                icon: const Icon(Icons.playlist_add_check_circle_outlined),
                label: const Text('Reorder List'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenOrdersTracker,
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Orders Tracker'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenValuationSummary,
                icon: const Icon(Icons.assessment_outlined),
                label: const Text('Valuation Summary'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenQrLabelRegister,
                icon: const Icon(Icons.qr_code_2_outlined),
                label: const Text('QR Labels'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenQrLabelStudio,
                icon: const Icon(Icons.print_outlined),
                label: const Text('QR Studio'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenQrHistory,
                icon: const Icon(Icons.history_outlined),
                label: const Text('QR History'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenQrPrintQueue,
                icon: const Icon(Icons.playlist_add_check),
                label: const Text('Print Queue'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenScanLookup,
                icon: const Icon(Icons.search),
                label: const Text('Scan Lookup'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenInventorySession,
                icon: const Icon(Icons.checklist_rtl_outlined),
                label: const Text('Inventory Session'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssetFooter extends StatelessWidget {
  const _AssetFooter({required this.theme, required this.snapshot});

  final ThemeData theme;
  final AssetWorkspaceSnapshot snapshot;

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
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
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
                      value: moneyFormatter.format(
                        summary.reorderEstimatedSpend,
                      ),
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
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColours.darkText),
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
