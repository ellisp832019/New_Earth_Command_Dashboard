import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../assets/application/assets_controller.dart';
import '../data/company_command_centre_repository.dart';

class CompanyCommandCentreScreen extends ConsumerWidget {
  const CompanyCommandCentreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(companyCommandCentreSnapshotProvider);

    return snapshotAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          title: const Text('Company Command Centre'),
          leading: BackButton(onPressed: () => context.go(RouteNames.moduleHub)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Company Command Centre could not load right now.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (snapshot) {
        return DefaultTabController(
          length: _tabs.length,
          child: Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.go(RouteNames.moduleHub)),
              title: const Text('Company Command Centre'),
              bottom: TabBar(
                isScrollable: true,
                tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
              ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _HeaderSummaryCard(snapshot: snapshot),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    children: [
                      _OverviewTab(snapshot: snapshot),
                      _ComplianceTab(snapshot: snapshot),
                      _FinanceTab(snapshot: snapshot),
                      _WebsiteBrandTab(snapshot: snapshot),
                      _LinkedInTab(snapshot: snapshot),
                      _ProductPortfolioTab(snapshot: snapshot),
                      _AssetOverviewTab(snapshot: snapshot),
                      _GrantsTab(snapshot: snapshot),
                      const _SimplePlaceholderTab(
                        title: 'Partnerships',
                        body:
                            'Read-only placeholder for partner relationships and follow-ups.',
                        chips: [
                          'Partnerships',
                          'Relationships',
                          'Read only',
                        ],
                      ),
                      const _EvidenceLibraryTab(),
                      _ActionBoardTab(snapshot: snapshot),
                      _SettingsTab(snapshot: snapshot),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderSummaryCard extends StatelessWidget {
  const _HeaderSummaryCard({required this.snapshot});

  final CompanyCommandCentreSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final overview = snapshot.overview;
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.domain_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        overview.companyName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Company Command Centre',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(overview.status.replaceAll('_', ' ')),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _InfoPill(label: 'Company no.', value: overview.companyNumber),
                _InfoPill(label: 'Domain', value: overview.domain),
                _InfoPill(label: 'Bank', value: overview.bank),
                _InfoPill(
                  label: 'Omega OS path',
                  value: overview.omegaOsPathExists ? 'Available' : 'Missing',
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Next milestone: ${overview.nextMilestone}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: overview.focus
                  .map((item) => Chip(label: Text(item)))
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(value, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.snapshot});

  final CompanyCommandCentreSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final overview = snapshot.overview;
    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Company status',
          body: 'Live overview from the imported mock company data.',
          children: [
            _KeyValueRow(label: 'Status', value: overview.status),
            _KeyValueRow(label: 'Owner', value: 'New Earth Advanced Technologies Ltd'),
            _KeyValueRow(label: 'Omega OS source', value: overview.omegaOsPath),
          ],
        ),
        _CalmSectionCard(
          title: 'Focus',
          body: 'The company is currently aligned around these themes.',
          children: overview.focus
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('- $item'),
                  ))
              .toList(growable: false),
        ),
        _CalmSectionCard(
          title: 'Read-only note',
          body:
              'This shell is read-only for now. Changes will only be added after backup-aware write-back is designed.',
        ),
      ],
    );
  }
}

class _ComplianceTab extends StatelessWidget {
  const _ComplianceTab({required this.snapshot});

  final CompanyCommandCentreSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Compliance & deadlines',
          body: 'Read-only control list for core company obligations.',
          children: [
            _ComplianceTable(items: _complianceChecklistItems),
          ],
        ),
      ],
    );
  }
}

class _FinanceTab extends StatelessWidget {
  const _FinanceTab({required this.snapshot});

  final CompanyCommandCentreSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Finance snapshot',
          body: 'Track the current finance and admin state without editing it here.',
          children: [
            _KeyValueRow(label: 'Bank', value: snapshot.overview.bank),
            const _KeyValueRow(label: 'Bookkeeping', value: 'To be linked'),
            const _KeyValueRow(label: 'Receipts', value: 'Capture queue ready'),
            const _KeyValueRow(label: 'Monthly reconciliation', value: 'Pending'),
            const _KeyValueRow(label: 'Accountant', value: 'To be linked'),
            const _KeyValueRow(label: 'VAT / PAYE', value: 'Review later'),
          ],
        ),
      ],
    );
  }
}

class _WebsiteBrandTab extends StatelessWidget {
  const _WebsiteBrandTab({required this.snapshot});

  final CompanyCommandCentreSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Website & brand',
          body: 'Keep the public presence calm, clear, and consistent.',
          children: [
            _KeyValueRow(label: 'Domain', value: snapshot.overview.domain),
            const _KeyValueRow(label: 'Email', value: 'To be linked'),
            const SizedBox(height: 12),
            _TrackerTable(items: _websiteTrackerItems),
          ],
        ),
      ],
    );
  }
}

class _LinkedInTab extends StatelessWidget {
  const _LinkedInTab({required this.snapshot});

  final CompanyCommandCentreSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final marketingActions = snapshot.actionBoard
        .where(
          (item) =>
              item.area.toLowerCase() == 'marketing' ||
              item.area.toLowerCase() == 'website',
        )
        .toList(growable: false);

    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'LinkedIn & marketing',
          body: 'Keep public awareness connected to what is actually being built.',
          children: [
            const _KeyValueRow(label: 'Company page', value: 'Not yet published'),
            const _KeyValueRow(label: 'Content rhythm', value: 'Build log / founder note'),
            const SizedBox(height: 12),
            _TrackerSectionCard(
              title: 'Profile',
              items: _linkedinTrackerItems
                  .where((item) => item.section == 'Profile')
                  .toList(growable: false),
            ),
            const SizedBox(height: 12),
            _TrackerSectionCard(
              title: 'Company Page',
              items: _linkedinTrackerItems
                  .where((item) => item.section == 'Company Page')
                  .toList(growable: false),
            ),
            const SizedBox(height: 12),
            _TrackerSectionCard(
              title: 'Content Rhythm',
              items: _linkedinTrackerItems
                  .where((item) => item.section == 'Content Rhythm')
                  .toList(growable: false),
            ),
            const SizedBox(height: 12),
            _TrackerSectionCard(
              title: 'Launch Tasks',
              items: _linkedinTrackerItems
                  .where((item) => item.section == 'Launch Tasks')
                  .toList(growable: false),
            ),
            if (marketingActions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Marketing actions from the director board',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...marketingActions.map((item) => _ActionLine(item: item)),
            ],
          ],
        ),
      ],
    );
  }
}

class _ProductPortfolioTab extends StatelessWidget {
  const _ProductPortfolioTab({required this.snapshot});

  final CompanyCommandCentreSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Product portfolio',
          body: 'Mock portfolio data for the first read-only shell.',
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: snapshot.productPortfolio
                  .map(
                    (item) => SizedBox(
                      width: 300,
                      child: Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(item.type),
                              const SizedBox(height: 8),
                              Text('Status: ${item.status}'),
                              Text('Readiness: ${item.commercialReadiness}'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ],
    );
  }
}

class _AssetOverviewTab extends StatelessWidget {
  const _AssetOverviewTab({required this.snapshot});

  final CompanyCommandCentreSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'IP & Asset Register',
          body:
              'This tab is a read-only summary and navigator. The live asset register stays in the Assets module.',
          children: [
            _AssetOverviewCard(snapshot: snapshot),
          ],
        ),
      ],
    );
  }
}

class _EvidenceLibraryTab extends StatelessWidget {
  const _EvidenceLibraryTab();

  @override
  Widget build(BuildContext context) {
    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Evidence Library',
          body:
              'Read-only index of the source documents, templates, and module artifacts that support the company record.',
          children: [
            _EvidenceSectionCard(
              title: 'Legal & finance',
              items: _evidenceItems
                  .where((item) => item.section == 'Legal & finance')
                  .toList(growable: false),
            ),
            const SizedBox(height: 12),
            _EvidenceSectionCard(
              title: 'Website & marketing',
              items: _evidenceItems
                  .where((item) => item.section == 'Website & marketing')
                  .toList(growable: false),
            ),
            const SizedBox(height: 12),
            _EvidenceSectionCard(
              title: 'Product & operations',
              items: _evidenceItems
                  .where((item) => item.section == 'Product & operations')
                  .toList(growable: false),
            ),
            const SizedBox(height: 12),
            _EvidenceSectionCard(
              title: 'Module source',
              items: _evidenceItems
                  .where((item) => item.section == 'Module source')
                  .toList(growable: false),
            ),
          ],
        ),
      ],
    );
  }
}

class _GrantsTab extends StatelessWidget {
  const _GrantsTab({required this.snapshot});

  final CompanyCommandCentreSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Grants pipeline',
          body: 'Read-only grant research and application tracking.',
          children: snapshot.grantsPipeline
              .map((grant) => _GrantCard(item: grant))
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _ActionBoardTab extends StatelessWidget {
  const _ActionBoardTab({required this.snapshot});

  final CompanyCommandCentreSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final lanes = <String, List<CompanyActionItemData>>{};
    for (final item in snapshot.actionBoard) {
      lanes.putIfAbsent(item.lane, () => <CompanyActionItemData>[]).add(item);
    }
    final orderedLanes = <String>[
      'Today',
      'This Week',
      'This Month',
      'Waiting',
      'Done',
    ];

    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Director action board',
          body:
              'Simple lane view for the next practical company moves. Keep the board calm, short, and current.',
          children: [
            _ActionBoardSummaryRow(
              lanes: orderedLanes,
              laneMap: lanes,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: orderedLanes
                  .map(
                    (lane) => SizedBox(
                      width: 260,
                      child: _ActionLaneCard(
                        title: lane,
                        items: lanes[lane] ?? const <CompanyActionItemData>[],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab({required this.snapshot});

  final CompanyCommandCentreSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final omegaPathExists = Directory(snapshot.configuredOmegaPath).existsSync();
    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Settings',
          body: 'Read-only configuration and source path visibility.',
          children: [
            _KeyValueRow(label: 'Omega OS source path', value: snapshot.configuredOmegaPath),
            _KeyValueRow(
              label: 'Source path status',
              value: omegaPathExists ? 'Available' : 'Missing',
            ),
            _KeyValueRow(label: 'Module config', value: snapshot.moduleConfigPath),
            _KeyValueRow(
              label: 'Module config status',
              value: snapshot.moduleConfigExists ? 'Available' : 'Missing',
            ),
            const _KeyValueRow(label: 'Write mode', value: 'Read only'),
            const _KeyValueRow(label: 'Backup before write', value: 'Required later'),
            const _KeyValueRow(label: 'Route', value: '/modules/company-command-centre'),
          ],
        ),
      ],
    );
  }
}

class _GrantCard extends StatelessWidget {
  const _GrantCard({required this.item});

  final CompanyGrantItemData item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.name, style: Theme.of(context).textTheme.titleSmall),
                ),
                Chip(label: Text(item.stage)),
              ],
            ),
            const SizedBox(height: 6),
            Text(item.fit),
            const SizedBox(height: 4),
            Text('Next: ${item.nextAction}'),
          ],
        ),
      ),
    );
  }
}

class _ActionLine extends StatelessWidget {
  const _ActionLine({required this.item});

  final CompanyActionItemData item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 2),
          Text('${item.area} • ${item.priority}'),
          const SizedBox(height: 2),
          Text(
            item.id,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBoardSummaryRow extends StatelessWidget {
  const _ActionBoardSummaryRow({
    required this.lanes,
    required this.laneMap,
  });

  final List<String> lanes;
  final Map<String, List<CompanyActionItemData>> laneMap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: lanes
          .map(
            (lane) => _CompanyAssetMetric(
              label: lane,
              value: '${laneMap[lane]?.length ?? 0}',
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ActionLaneCard extends StatelessWidget {
  const _ActionLaneCard({
    required this.title,
    required this.items,
  });

  final String title;
  final List<CompanyActionItemData> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: Theme.of(context).textTheme.titleSmall),
                ),
                _InlineTag(
                  label: '${items.length}',
                  accent: AppColours.darkSecondary,
                  foreground: AppColours.darkText,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (items.isEmpty)
              Text(
                'No actions in this lane yet.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              )
            else
              Column(
                children: [
                  for (var index = 0; index < items.length; index++) ...[
                    _ActionLine(item: items[index]),
                    if (index != items.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AssetOverviewCard extends ConsumerWidget {
  const _AssetOverviewCard({required this.snapshot});

  final CompanyCommandCentreSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceAsync = ref.watch(assetWorkspaceProvider);
    final projectSummaryAsync = ref.watch(assetProjectSummaryProvider);
    final valuationAsync = ref.watch(assetValuationOverviewProvider);
    final syncStatusAsync = ref.watch(assetSyncStatusProvider);

    return workspaceAsync.when(
      loading: () => const _LoadingAssetSummary(),
      error: (error, stackTrace) => _AssetSummaryError(
        onOpenAssets: () => context.push(RouteNames.assets),
      ),
      data: (workspace) {
        return projectSummaryAsync.when(
          loading: () => const _LoadingAssetSummary(),
          error: (error, stackTrace) => _AssetSummaryError(
            onOpenAssets: () => context.push(RouteNames.assets),
          ),
          data: (projects) {
            return valuationAsync.when(
              loading: () => const _LoadingAssetSummary(),
              error: (error, stackTrace) => _AssetSummaryError(
                onOpenAssets: () => context.push(RouteNames.assets),
              ),
              data: (valuation) {
                return syncStatusAsync.when(
                  loading: () => const _LoadingAssetSummary(),
                  error: (error, stackTrace) => _AssetSummaryError(
                    onOpenAssets: () => context.push(RouteNames.assets),
                  ),
                  data: (syncStatus) {
                    final readyProjects = projects
                        .where((project) => project.availableCount > 0)
                        .length;
                    final mixedProjects = projects
                        .where((project) => project.isMixedProject)
                        .length;
                    final lowStockProjects = projects
                        .where((project) => project.lowStockCount > 0)
                        .length;

                    return Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Asset overview',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                _InlineTag(
                                  label: syncStatus.statusLabel,
                                  accent: syncStatus.isConnected
                                      ? Colors.green.shade400
                                      : Colors.amber.shade600,
                                  foreground: AppColours.darkText,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              workspace.assetsRootPath ??
                                  snapshot.overview.omegaOsPath,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _CompanyAssetMetric(
                                  label: 'Equipment',
                                  value: '${workspace.equipmentCount}',
                                ),
                                _CompanyAssetMetric(
                                  label: 'Parts',
                                  value: '${workspace.partsCount}',
                                ),
                                _CompanyAssetMetric(
                                  label: 'Projects',
                                  value: '${projects.length}',
                                ),
                                _CompanyAssetMetric(
                                  label: 'Ready projects',
                                  value: '$readyProjects',
                                ),
                                _CompanyAssetMetric(
                                  label: 'Mixed projects',
                                  value: '$mixedProjects',
                                ),
                                _CompanyAssetMetric(
                                  label: 'Low stock projects',
                                  value: '$lowStockProjects',
                                ),
                                _CompanyAssetMetric(
                                  label: 'Valuation rows',
                                  value: '${valuation.valuationRowCount}',
                                ),
                                _CompanyAssetMetric(
                                  label: 'Estimated value',
                                  value: valuation.currentEstimatedValueTotal
                                      .toStringAsFixed(2),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                FilledButton.icon(
                                  onPressed: () => context.push(RouteNames.assets),
                                  icon: const Icon(Icons.inventory_2_outlined),
                                  label: const Text('Open Assets'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      context.push(RouteNames.assetEquipment),
                                  icon: const Icon(Icons.precision_manufacturing_outlined),
                                  label: const Text('Open Equipment'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      context.push(RouteNames.assetProjectSummary),
                                  icon: const Icon(Icons.groups_2_outlined),
                                  label: const Text('Open Project Summary'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      context.push(RouteNames.assetValuationSummary),
                                  icon: const Icon(Icons.assessment_outlined),
                                  label: const Text('Open Valuation'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _InlineTag(
                                  label: 'Assets + Treasury linked',
                                  accent: AppColours.darkSecondary,
                                  foreground: AppColours.darkText,
                                ),
                                _InlineTag(
                                  label: '${syncStatus.entryCount} journal entries',
                                  accent: AppColours.darkSecondary,
                                  foreground: AppColours.darkText,
                                ),
                                _InlineTag(
                                  label: '${syncStatus.conflictCount} conflicts',
                                  accent: syncStatus.conflictCount == 0
                                      ? AppColours.darkSuccess
                                      : AppColours.darkAmber,
                                  foreground: AppColours.darkText,
                                ),
                                _InlineTag(
                                  label: '${valuation.projectTotals.length} value groups',
                                  accent: AppColours.darkSecondary,
                                  foreground: AppColours.darkText,
                                ),
                              ],
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

class _EvidenceItem {
  const _EvidenceItem({
    required this.section,
    required this.title,
    required this.kind,
    required this.status,
    required this.notes,
    required this.sourceFile,
  });

  final String section;
  final String title;
  final String kind;
  final String status;
  final String notes;
  final String sourceFile;
}

class _EvidenceSectionCard extends StatelessWidget {
  const _EvidenceSectionCard({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_EvidenceItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 44,
                  dataRowMinHeight: 52,
                  dataRowMaxHeight: 88,
                  columns: const [
                    DataColumn(label: Text('Artifact')),
                    DataColumn(label: Text('Kind')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Notes')),
                    DataColumn(label: Text('Source file')),
                  ],
                  rows: items
                      .map(
                        (item) => DataRow(
                          cells: [
                            DataCell(SizedBox(width: 260, child: Text(item.title))),
                            DataCell(SizedBox(width: 150, child: Text(item.kind))),
                            DataCell(Chip(label: Text(item.status))),
                            DataCell(
                              SizedBox(
                                width: 360,
                                child: Text(
                                  item.notes,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(width: 280, child: Text(item.sourceFile)),
                            ),
                          ],
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyAssetMetric extends StatelessWidget {
  const _CompanyAssetMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

const List<_EvidenceItem> _evidenceItems = [
  _EvidenceItem(
    section: 'Legal & finance',
    title: 'UK company admin checklist',
    kind: 'Checklist',
    status: 'Tracked',
    notes: 'Core companies, banking, tax, and public presence items in one support list.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _EvidenceItem(
    section: 'Legal & finance',
    title: 'Company overview template',
    kind: 'Template',
    status: 'Tracked',
    notes: 'Reusable template for the company overview record and public-facing summary.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/templates/company_overview_template.md',
  ),
  _EvidenceItem(
    section: 'Legal & finance',
    title: 'Capability statement template',
    kind: 'Template',
    status: 'Tracked',
    notes: 'Drafting support for capability and services positioning.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/templates/capability_statement_template.md',
  ),
  _EvidenceItem(
    section: 'Website & marketing',
    title: 'Website next steps',
    kind: 'Checklist',
    status: 'Tracked',
    notes: 'Planned public website work, tracked as a calm next-step list.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _EvidenceItem(
    section: 'Website & marketing',
    title: 'LinkedIn next steps',
    kind: 'Checklist',
    status: 'Tracked',
    notes: 'Company profile and launch actions for LinkedIn presence.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
  ),
  _EvidenceItem(
    section: 'Website & marketing',
    title: 'Product page template',
    kind: 'Template',
    status: 'Tracked',
    notes: 'Structure for future product pages and evidence-backed product descriptions.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/templates/product_page_template.md',
  ),
  _EvidenceItem(
    section: 'Product & operations',
    title: 'Roadmap',
    kind: 'Roadmap',
    status: 'Tracked',
    notes: 'The company module roadmap provides the longer-term evidence trail.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/roadmap/ROADMAP.md',
  ),
  _EvidenceItem(
    section: 'Product & operations',
    title: 'Operating manual',
    kind: 'Manual',
    status: 'Tracked',
    notes: 'Operational guidance for how the company module is meant to be used.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/operations/OPERATING_MANUAL.md',
  ),
  _EvidenceItem(
    section: 'Product & operations',
    title: 'Module test plan',
    kind: 'Plan',
    status: 'Tracked',
    notes: 'Testing outline for module shell, data, and safety checks.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/tests/MODULE_TEST_PLAN.md',
  ),
  _EvidenceItem(
    section: 'Module source',
    title: 'Module manifest',
    kind: 'JSON',
    status: 'Tracked',
    notes: 'Module registration details used by the dashboard module system.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/module_manifest.json',
  ),
  _EvidenceItem(
    section: 'Module source',
    title: 'Module shell config',
    kind: 'JSON',
    status: 'Tracked',
    notes: 'Local shell configuration for the module scaffold.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/src/module_shell/module_config.json',
  ),
  _EvidenceItem(
    section: 'Module source',
    title: 'Overview wireframe',
    kind: 'SVG',
    status: 'Tracked',
    notes: 'Design reference for the module shell and layout decisions.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/assets/wireframes/overview_wireframe.svg',
  ),
];

class _LoadingAssetSummary extends StatelessWidget {
  const _LoadingAssetSummary();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _AssetSummaryError extends StatelessWidget {
  const _AssetSummaryError({required this.onOpenAssets});

  final VoidCallback onOpenAssets;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Asset summary could not load right now.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onOpenAssets,
          icon: const Icon(Icons.inventory_2_outlined),
          label: const Text('Open Assets'),
        ),
      ],
    );
  }
}

class _ChecklistItem {
  const _ChecklistItem({
    required this.item,
    required this.authority,
    required this.dueDate,
    required this.status,
    required this.notes,
    required this.sourceFile,
  });

  final String item;
  final String authority;
  final String dueDate;
  final String status;
  final String notes;
  final String sourceFile;
}

class _ComplianceTable extends StatelessWidget {
  const _ComplianceTable({required this.items});

  final List<_ChecklistItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 44,
          dataRowMinHeight: 52,
          dataRowMaxHeight: 84,
          columns: const [
            DataColumn(label: Text('Item')),
            DataColumn(label: Text('Authority')),
            DataColumn(label: Text('Due date')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Notes')),
            DataColumn(label: Text('Source file')),
          ],
          rows: items
              .map(
                (item) => DataRow(
                  cells: [
                    DataCell(SizedBox(width: 240, child: Text(item.item))),
                    DataCell(SizedBox(width: 140, child: Text(item.authority))),
                    DataCell(SizedBox(width: 100, child: Text(item.dueDate))),
                    DataCell(Chip(label: Text(item.status))),
                    DataCell(
                      SizedBox(
                        width: 320,
                        child: Text(item.notes, style: theme.textTheme.bodyMedium),
                      ),
                    ),
                    DataCell(SizedBox(width: 220, child: Text(item.sourceFile))),
                  ],
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _TrackerItem {
  const _TrackerItem({
    required this.section,
    required this.item,
    required this.status,
    required this.notes,
    required this.sourceFile,
  });

  final String section;
  final String item;
  final String status;
  final String notes;
  final String sourceFile;
}

class _TrackerTable extends StatelessWidget {
  const _TrackerTable({required this.items});

  final List<_TrackerItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 44,
          dataRowMinHeight: 52,
          dataRowMaxHeight: 88,
          columns: const [
            DataColumn(label: Text('Item')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Notes')),
            DataColumn(label: Text('Source file')),
          ],
          rows: items
              .map(
                (item) => DataRow(
                  cells: [
                    DataCell(SizedBox(width: 280, child: Text(item.item))),
                    DataCell(Chip(label: Text(item.status))),
                    DataCell(
                      SizedBox(
                        width: 360,
                        child: Text(item.notes, style: theme.textTheme.bodyMedium),
                      ),
                    ),
                    DataCell(SizedBox(width: 260, child: Text(item.sourceFile))),
                  ],
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _TrackerSectionCard extends StatelessWidget {
  const _TrackerSectionCard({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_TrackerItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            _TrackerTable(items: items),
          ],
        ),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _CalmSectionCard extends StatelessWidget {
  const _CalmSectionCard({
    required this.title,
    required this.body,
    this.children = const [],
  });

  final String title;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(body, style: theme.textTheme.bodyMedium),
            if (children.isNotEmpty) ...[
              const SizedBox(height: 14),
              ...children,
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionScrollView extends StatelessWidget {
  const _SectionScrollView({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => children[index],
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemCount: children.length,
    );
  }
}

const List<String> _tabs = [
  'Overview',
  'Compliance & Deadlines',
  'Finance Snapshot',
  'Website & Brand',
  'LinkedIn & Marketing',
  'Product Portfolio',
  'IP & Asset Register',
  'Grants Pipeline',
  'Partnerships',
  'Evidence Library',
  'Director Action Board',
  'Settings',
];
const List<_ChecklistItem> _complianceChecklistItems = [
  _ChecklistItem(
    item: 'Companies House account available',
    authority: 'Companies House',
    dueDate: 'Ongoing',
    status: 'Tracked',
    notes: 'Company records are being kept in the admin trail.',
    sourceFile: 'UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Authentication code stored securely',
    authority: 'Companies House',
    dueDate: 'Ongoing',
    status: 'Tracked',
    notes: 'Sensitive registration access stays noted for future recovery.',
    sourceFile: 'UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Certificate of incorporation saved',
    authority: 'Company records',
    dueDate: 'Ongoing',
    status: 'Tracked',
    notes: 'Core formation documents stay visible in the company record set.',
    sourceFile: 'UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Articles of association saved',
    authority: 'Company records',
    dueDate: 'Ongoing',
    status: 'Tracked',
    notes: 'Foundational company documents are listed for review.',
    sourceFile: 'UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Registered office details saved',
    authority: 'Company records',
    dueDate: 'Ongoing',
    status: 'Tracked',
    notes: 'Registered office history remains part of the local record.',
    sourceFile: 'UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Tide account active',
    authority: 'Banking',
    dueDate: 'Ongoing',
    status: 'Finance',
    notes: 'Banking setup is tracked in the finance snapshot tab.',
    sourceFile: 'UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
];

const List<_TrackerItem> _websiteTrackerItems = [
  _TrackerItem(
    section: 'Website',
    item: 'Add company identity to homepage',
    status: 'Drafting',
    notes: 'Surface the legal name and founder identity clearly on the landing page.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Create Technologies page',
    status: 'Planned',
    notes: 'Reserve a calm page for the company technology overview.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Create Products page',
    status: 'Planned',
    notes: 'List the product family in one clear place.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Create Projects/build log page',
    status: 'Planned',
    notes: 'Use this for progress notes and visible build momentum.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Create Grants & Partnerships page',
    status: 'Planned',
    notes: 'Provide a single destination for opportunities and collaborators.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Add MicroGrow product page',
    status: 'Planned',
    notes: 'Draft the first product-specific page for MicroGrow.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Add BioCalm product page',
    status: 'Planned',
    notes: 'Reserve a product page for the BioCalm concept.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Add Omega Dashboard product page',
    status: 'Planned',
    notes: 'Keep the dashboard product visible for future customers and partners.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Add company contact form subjects',
    status: 'Drafting',
    notes: 'Define the calm subject options before the form goes live.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Add LinkedIn company page link',
    status: 'Ready',
    notes: 'This can point straight at the new LinkedIn company profile.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Add professional footer with company name and company number',
    status: 'Drafting',
    notes: 'Keep the legal footer visible and consistent across pages.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
];

const List<_TrackerItem> _linkedinTrackerItems = [
  _TrackerItem(
    section: 'Profile',
    item: 'Update personal headline',
    status: 'Drafting',
    notes: 'Keep the profile headline clear and founder-focused.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
  ),
  _TrackerItem(
    section: 'Profile',
    item: 'Add Founder & Director role',
    status: 'Planned',
    notes: 'Make the public role reflect the company position accurately.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
  ),
  _TrackerItem(
    section: 'Company Page',
    item: 'Create New Earth Advanced Technologies Ltd company page',
    status: 'Planned',
    notes: 'Create the official company page before launch content starts.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
  ),
  _TrackerItem(
    section: 'Company Page',
    item: 'Upload banner',
    status: 'Planned',
    notes: 'Use the banner to keep the page visually aligned with the website.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
  ),
  _TrackerItem(
    section: 'Company Page',
    item: 'Add website link',
    status: 'Ready',
    notes: 'Link the public profile back to the website once the page exists.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
  ),
  _TrackerItem(
    section: 'Content Rhythm',
    item: 'Create weekly engineering update rhythm',
    status: 'Drafting',
    notes: 'Keep the cadence steady and low pressure.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
  ),
  _TrackerItem(
    section: 'Content Rhythm',
    item: 'Pin MicroGrow/BioCalm/Omega posts',
    status: 'Planned',
    notes: 'Pin the most representative posts once the launch content is ready.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
  ),
  _TrackerItem(
    section: 'Launch Tasks',
    item: 'Publish company launch post',
    status: 'Ready',
    notes: 'Draft the first launch update when the company page is live.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
  ),
];


