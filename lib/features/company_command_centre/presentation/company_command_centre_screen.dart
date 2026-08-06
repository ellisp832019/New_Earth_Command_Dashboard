import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/local_pdf_screen.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../../assets/application/assets_controller.dart';
import '../../assets/data/assets_folder_service.dart';
import '../data/company_command_centre_config.dart';
import '../data/company_command_centre_local_settings_service.dart';
import '../data/company_command_centre_index_service.dart';
import '../data/company_command_centre_repository.dart';
import '../data/company_command_centre_report_service.dart';
import '../data/company_command_centre_write_service.dart';

const _companyFounderPackPdfPath =
    'output/pdf/company_command_centre_founder_pack.pdf';

class CompanyCommandCentreScreen extends ConsumerStatefulWidget {
  const CompanyCommandCentreScreen({super.key});

  @override
  ConsumerState<CompanyCommandCentreScreen> createState() =>
      _CompanyCommandCentreScreenState();
}

class _CompanyCommandCentreScreenState
    extends ConsumerState<CompanyCommandCentreScreen> {
  String _linkedinCompanyUrl = companyCommandCentreLinkedInCompanyUrl;
  final CompanyCommandCentreLocalSettingsService _localSettingsService =
      const CompanyCommandCentreLocalSettingsService();
  Timer? _linkedinSaveDebounce;

  @override
  void initState() {
    super.initState();
    _loadLocalSettings();
  }

  @override
  void dispose() {
    _linkedinSaveDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshotAsync = ref.watch(companyCommandCentreSnapshotProvider);

    return snapshotAsync.when(
      loading: () => WorkspaceShell(
        title: 'Company Command Centre',
        subtitle: 'Loading local company data',
        onBack: () => context.go(RouteNames.moduleHub),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => WorkspaceShell(
        title: 'Company Command Centre',
        subtitle: 'Local company registry unavailable',
        onBack: () => context.go(RouteNames.moduleHub),
        child: Center(
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
        return WorkspaceShell(
          title: 'Company Command Centre',
          subtitle: 'Local-first company operations',
          onBack: () => context.go(RouteNames.moduleHub),
          child: DefaultTabController(
            length: _tabs.length,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _HeaderSummaryCard(snapshot: snapshot),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    isScrollable: true,
                    tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    children: [
                      _OverviewTab(
                        snapshot: snapshot,
                        linkedinCompanyUrl: _linkedinCompanyUrl,
                      ),
                      _ComplianceTab(snapshot: snapshot),
                      _FinanceTab(snapshot: snapshot),
                      _WebsiteBrandTab(snapshot: snapshot),
                      _LinkedInTab(
                        snapshot: snapshot,
                        linkedinCompanyUrl: _linkedinCompanyUrl,
                      ),
                      _ProductPortfolioTab(snapshot: snapshot),
                      _AssetOverviewTab(snapshot: snapshot),
                      _GrantsTab(snapshot: snapshot),
                      _IndexExplorerTab(snapshot: snapshot),
                      const _PartnershipsTab(),
                      const _EvidenceLibraryTab(),
                      _ActionBoardTab(snapshot: snapshot),
                      _SettingsTab(
                        snapshot: snapshot,
                        linkedinCompanyUrl: _linkedinCompanyUrl,
                        onLinkedInCompanyUrlChanged: _setLinkedInCompanyUrl,
                      ),
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

  void _setLinkedInCompanyUrl(String url) {
    final normalized = url.trim().isEmpty
        ? companyCommandCentreLinkedInCompanyUrl
        : url.trim();
    setState(() {
      _linkedinCompanyUrl = normalized;
    });
    _scheduleLinkedInSave(normalized);
  }

  Future<void> _loadLocalSettings() async {
    final settings = await _localSettingsService.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _linkedinCompanyUrl = settings.linkedinCompanyUrl.isNotEmpty
          ? settings.linkedinCompanyUrl
          : companyCommandCentreLinkedInCompanyUrl;
    });
  }

  void _scheduleLinkedInSave(String url) {
    _linkedinSaveDebounce?.cancel();
    _linkedinSaveDebounce = Timer(const Duration(milliseconds: 500), () async {
      await _localSettingsService.save(
        CompanyCommandCentreLocalSettings(linkedinCompanyUrl: url),
      );
      if (mounted) {
        ref.invalidate(companyCommandCentreLocalSettingsProvider);
      }
    });
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
                Chip(label: Text(overview.status.replaceAll('_', ' '))),
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
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.42,
        ),
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
  const _OverviewTab({
    required this.snapshot,
    required this.linkedinCompanyUrl,
  });

  final CompanyCommandCentreSnapshot snapshot;
  final String linkedinCompanyUrl;

  @override
  Widget build(BuildContext context) {
    final overview = snapshot.overview;
    final indexRecords = snapshot.indexSnapshot.records;
    final actionCount = indexRecords
        .where((record) => record.checkboxCount > 0)
        .length;
    final deadlineCount = indexRecords
        .where((record) => record.dueDates.isNotEmpty)
        .length;
    final productCount = indexRecords
        .where((record) => record.labels.contains('product'))
        .length;
    final grantCount = indexRecords
        .where((record) => record.labels.contains('grant'))
        .length;
    final ipAssetCount = indexRecords
        .where((record) => record.labels.contains('ip_asset'))
        .length;
    final evidenceCount = indexRecords
        .where((record) => record.isEvidence)
        .length;
    final quickActions = [
      _OverviewAction(
        label: 'Website',
        tabIndex: 3,
        icon: Icons.language_outlined,
      ),
      _OverviewAction(
        label: 'LinkedIn',
        tabIndex: 4,
        icon: Icons.cases_outlined,
      ),
      _OverviewAction(
        label: 'Products',
        tabIndex: 5,
        icon: Icons.inventory_2_outlined,
      ),
      _OverviewAction(
        label: 'Grants',
        tabIndex: 7,
        icon: Icons.rocket_launch_outlined,
      ),
      _OverviewAction(
        label: 'Assets',
        tabIndex: 6,
        icon: Icons.precision_manufacturing_outlined,
      ),
    ];
    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Company status',
          body: 'Live overview from the imported mock company data.',
          children: [
            _KeyValueRow(label: 'Status', value: overview.status),
            _KeyValueRow(
              label: 'Owner',
              value: 'New Earth Advanced Technologies Ltd',
            ),
            _KeyValueRow(label: 'Omega OS source', value: overview.omegaOsPath),
          ],
        ),
        _CalmSectionCard(
          title: 'Today at a glance',
          body:
              'Keep the day calm by jumping directly to the most active company areas from one place.',
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: linkedinCompanyUrl.trim().isEmpty
                      ? null
                      : () => _openExternalUrl(linkedinCompanyUrl),
                  icon: const Icon(Icons.open_in_new_outlined),
                  label: const Text('Open LinkedIn'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _jumpToTab(context, 4),
                  icon: const Icon(Icons.cases_outlined),
                  label: const Text('LinkedIn tab'),
                ),
                OutlinedButton.icon(
                  onPressed: () => openLocalPdfDocument(
                    context,
                    title: 'Company Founder Pack PDF',
                    pdfPath: _companyFounderPackPdfPath,
                  ),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Founder Pack PDF'),
                ),
                _CompanyAssetMetric(label: 'Actions', value: '$actionCount'),
                _CompanyAssetMetric(
                  label: 'Deadlines',
                  value: '$deadlineCount',
                ),
                _CompanyAssetMetric(label: 'Products', value: '$productCount'),
                _CompanyAssetMetric(label: 'Grants', value: '$grantCount'),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: quickActions
                  .map(
                    (action) => FilledButton.tonalIcon(
                      onPressed: () => _jumpToTab(context, action.tabIndex),
                      icon: Icon(action.icon),
                      label: Text('Open ${action.label}'),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
        _CalmSectionCard(
          title: 'Focus',
          body: 'The company is currently aligned around these themes.',
          children: overview.focus
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('- $item'),
                ),
              )
              .toList(growable: false),
        ),
        _CalmSectionCard(
          title: 'Read-only note',
          body:
              'This shell is read-only for now. Changes will only be added after backup-aware write-back is designed.',
        ),
        _CalmSectionCard(
          title: 'Generated indexes',
          body:
              'The scanner keeps local JSON indexes refreshed from the company Markdown records.',
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InlineTag(
                  label: '$actionCount action files',
                  accent: AppColours.darkSuccess,
                  foreground: AppColours.darkText,
                ),
                _InlineTag(
                  label: '$deadlineCount deadline files',
                  accent: AppColours.darkAmber,
                  foreground: AppColours.darkText,
                ),
                _InlineTag(
                  label: '$productCount product files',
                  accent: AppColours.darkSecondary,
                  foreground: AppColours.darkText,
                ),
                _InlineTag(
                  label: '$grantCount grant files',
                  accent: AppColours.darkPurple,
                  foreground: AppColours.darkText,
                ),
                _InlineTag(
                  label: '$ipAssetCount IP / asset files',
                  accent: AppColours.darkGlow,
                  foreground: AppColours.darkText,
                ),
                _InlineTag(
                  label: '$evidenceCount evidence files',
                  accent: AppColours.darkSecondary,
                  foreground: AppColours.darkText,
                ),
                _InlineTag(
                  label:
                      '${snapshot.indexSnapshot.sourceMarkdownCount} markdown files',
                  accent: AppColours.darkSecondary,
                  foreground: AppColours.darkText,
                ),
                _InlineTag(
                  label: snapshot.indexSnapshot.sourceExists
                      ? 'Source available'
                      : 'Source missing',
                  accent: snapshot.indexSnapshot.sourceExists
                      ? AppColours.darkSuccess
                      : AppColours.darkAmber,
                  foreground: AppColours.darkText,
                ),
                _InlineTag(
                  label: 'company_index.generated.json',
                  accent: AppColours.darkSecondary,
                  foreground: AppColours.darkText,
                ),
                _InlineTag(
                  label: 'action_items_index.generated.json',
                  accent: AppColours.darkSecondary,
                  foreground: AppColours.darkText,
                ),
                _InlineTag(
                  label: 'deadlines_index.generated.json',
                  accent: AppColours.darkSecondary,
                  foreground: AppColours.darkText,
                ),
                _InlineTag(
                  label: 'products_index.generated.json',
                  accent: AppColours.darkSecondary,
                  foreground: AppColours.darkText,
                ),
                _InlineTag(
                  label: 'grants_index.generated.json',
                  accent: AppColours.darkSecondary,
                  foreground: AppColours.darkText,
                ),
                _InlineTag(
                  label: 'ip_assets_index.generated.json',
                  accent: AppColours.darkSecondary,
                  foreground: AppColours.darkText,
                ),
                _InlineTag(
                  label: 'evidence_index.generated.json',
                  accent: AppColours.darkSecondary,
                  foreground: AppColours.darkText,
                ),
              ],
            ),
          ],
        ),
        _CalmSectionCard(
          title: 'Linked files',
          body:
              'Files with actions, deadlines, products, grants, IP, or evidence signals are surfaced here.',
          children: [
            _LinkedFileTable(records: snapshot.indexSnapshot.recentFiles),
          ],
        ),
      ],
    );
  }
}

void _jumpToTab(BuildContext context, int index) {
  final controller = DefaultTabController.maybeOf(context);
  if (controller == null) {
    return;
  }

  controller.animateTo(index);
}

class _OverviewAction {
  const _OverviewAction({
    required this.label,
    required this.tabIndex,
    required this.icon,
  });

  final String label;
  final int tabIndex;
  final IconData icon;
}

class _ComplianceTab extends StatelessWidget {
  const _ComplianceTab({required this.snapshot});

  final CompanyCommandCentreSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final items = _complianceChecklistItems;
    final sections = const [
      'Company records',
      'Banking',
      'Tax/admin',
      'Public presence',
    ];
    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Compliance & deadlines',
          body:
              'Source-linked control list for core company obligations and public presence checks.',
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: sections
                  .map(
                    (section) => _CompanyAssetMetric(
                      label: section,
                      value:
                          '${items.where((item) => item.authority == section).length}',
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
        const SizedBox(height: 2),
        _ComplianceSectionCard(
          title: 'Company records',
          items: items
              .where((item) => item.authority == 'Company records')
              .toList(growable: false),
        ),
        _ComplianceSectionCard(
          title: 'Banking',
          items: items
              .where((item) => item.authority == 'Banking')
              .toList(growable: false),
        ),
        _ComplianceSectionCard(
          title: 'Tax/admin',
          items: items
              .where((item) => item.authority == 'Tax/admin')
              .toList(growable: false),
        ),
        _ComplianceSectionCard(
          title: 'Public presence',
          items: items
              .where((item) => item.authority == 'Public presence')
              .toList(growable: false),
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
    final items = _financeTrackerItems;
    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Finance task tracker',
          body:
              'Small finance follow-up list sourced from the company admin checklist and overview data.',
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _CompanyAssetMetric(label: 'Tasks', value: '${items.length}'),
                _CompanyAssetMetric(
                  label: 'Tracked',
                  value:
                      '${items.where((item) => item.status == 'Tracked').length}',
                ),
                _CompanyAssetMetric(
                  label: 'Review',
                  value:
                      '${items.where((item) => item.status == 'Review').length}',
                ),
                _CompanyAssetMetric(
                  label: 'Planned',
                  value:
                      '${items.where((item) => item.status == 'Planned').length}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _KeyValueRow(label: 'Bank', value: snapshot.overview.bank),
            const _KeyValueRow(label: 'Bookkeeping', value: 'To be linked'),
            const _KeyValueRow(label: 'Receipts', value: 'Capture queue ready'),
            const _KeyValueRow(
              label: 'Monthly reconciliation',
              value: 'Pending',
            ),
            const _KeyValueRow(label: 'Accountant', value: 'To be linked'),
            const _KeyValueRow(label: 'VAT / PAYE', value: 'Review later'),
            const SizedBox(height: 12),
            _TrackerSectionCard(title: 'Finance tasks', items: items),
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
    final items = _websiteTrackerItems;
    final drafting = items.where((item) => item.status == 'Drafting').length;
    final planned = items.where((item) => item.status == 'Planned').length;
    final ready = items.where((item) => item.status == 'Ready').length;
    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Website & brand',
          body:
              'Page-level tracker sourced from the website next steps note. Keep the public presence calm, clear, and consistent.',
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _CompanyAssetMetric(
                  label: 'Next steps',
                  value: '${items.length}',
                ),
                _CompanyAssetMetric(label: 'Drafting', value: '$drafting'),
                _CompanyAssetMetric(label: 'Planned', value: '$planned'),
                _CompanyAssetMetric(label: 'Ready', value: '$ready'),
              ],
            ),
            const SizedBox(height: 12),
            _KeyValueRow(label: 'Domain', value: snapshot.overview.domain),
            const _KeyValueRow(label: 'Email', value: 'To be linked'),
            const SizedBox(height: 12),
            _WebsitePageBoard(items: items),
          ],
        ),
      ],
    );
  }
}

class _LinkedInTab extends StatelessWidget {
  const _LinkedInTab({
    required this.snapshot,
    required this.linkedinCompanyUrl,
  });

  final CompanyCommandCentreSnapshot snapshot;
  final String linkedinCompanyUrl;

  @override
  Widget build(BuildContext context) {
    final items = _linkedinTrackerItems;
    final profile = items.where((item) => item.section == 'Profile').length;
    final companyPage = items
        .where((item) => item.section == 'Company Page')
        .length;
    final contentRhythm = items
        .where((item) => item.section == 'Content Rhythm')
        .length;
    final launchTasks = items
        .where((item) => item.section == 'Launch Tasks')
        .length;
    final linkedinUrl = linkedinCompanyUrl.trim();
    final linkedinConfigured = linkedinUrl.isNotEmpty;
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
          body:
              'Same calm page-board layout as Website. Keep public awareness connected to what is actually being built.',
          children: [
            _KeyValueRow(
              label: 'LinkedIn destination',
              value: linkedinConfigured ? linkedinUrl : 'Not configured',
            ),
            const _KeyValueRow(
              label: 'Connection mode',
              value: 'Manual browser launch',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: linkedinConfigured
                      ? () => _openExternalUrl(linkedinUrl)
                      : null,
                  icon: const Icon(Icons.open_in_new_outlined),
                  label: const Text('Open LinkedIn'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _jumpToTab(context, 12),
                  icon: const Icon(Icons.tune_outlined),
                  label: const Text('Open settings'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _revealSourceLocation(
                    'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
                  ),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Open checklist'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _KeyValueRow(
              label: 'Company page',
              value: 'Not yet published',
            ),
            const _KeyValueRow(
              label: 'Content rhythm',
              value: 'Build log / founder note',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _CompanyAssetMetric(label: 'Profile', value: '$profile'),
                _CompanyAssetMetric(
                  label: 'Company Page',
                  value: '$companyPage',
                ),
                _CompanyAssetMetric(
                  label: 'Content Rhythm',
                  value: '$contentRhythm',
                ),
                _CompanyAssetMetric(
                  label: 'Launch Tasks',
                  value: '$launchTasks',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _LinkedInPageBoard(items: items),
            const SizedBox(height: 12),
            const _LinkedInGuidanceCard(),
            const SizedBox(height: 12),
            _LinkedInProfileCopyCard(
              profileCopy: _buildLinkedInProfileCopy(snapshot),
            ),
            const SizedBox(height: 12),
            _LinkedInContentBankCard(
              items: _buildLinkedInContentBank(snapshot),
            ),
            const SizedBox(height: 12),
            const _LinkedInChecklistCard(),
            const SizedBox(height: 12),
            _LinkedInIdeaGeneratorCard(
              ideas: _buildLinkedInPostIdeas(snapshot, items),
            ),
            const SizedBox(height: 12),
            _LinkedInWeeklyTemplateCard(
              template: _buildWeeklyLinkedInTemplate(snapshot, items),
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
    final items = snapshot.productPortfolio;
    final ready = items
        .where((item) => item.status.toLowerCase() == 'ready')
        .length;
    final drafting = items
        .where((item) => item.status.toLowerCase() == 'drafting')
        .length;
    final planned = items
        .where((item) => item.status.toLowerCase() == 'planned')
        .length;
    final types = items.map((item) => item.type).toSet().length;
    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Product portfolio',
          body:
              'Calm product board for the mock portfolio, with status, readiness, and source context kept together.',
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _CompanyAssetMetric(
                  label: 'Products',
                  value: '${items.length}',
                ),
                _CompanyAssetMetric(label: 'Ready', value: '$ready'),
                _CompanyAssetMetric(label: 'Drafting', value: '$drafting'),
                _CompanyAssetMetric(label: 'Planned', value: '$planned'),
                _CompanyAssetMetric(label: 'Types', value: '$types'),
              ],
            ),
            const SizedBox(height: 12),
            _ProductPortfolioBoard(items: items),
          ],
        ),
      ],
    );
  }
}

class _ProductPortfolioBoard extends StatelessWidget {
  const _ProductPortfolioBoard({required this.items});

  final List<CompanyProductItemData> items;

  @override
  Widget build(BuildContext context) {
    final sortedItems = [...items]
      ..sort((a, b) {
        final byStatus = a.status.compareTo(b.status);
        if (byStatus != 0) {
          return byStatus;
        }
        return a.name.compareTo(b.name);
      });

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Source-linked product board',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Each row stays close to the portfolio record and shows the current readiness at a glance.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
                    DataColumn(label: Text('Product')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Readiness')),
                    DataColumn(label: Text('Source file')),
                    DataColumn(label: Text('Open')),
                    DataColumn(label: Text('Reveal')),
                  ],
                  rows: sortedItems
                      .map(
                        (item) => DataRow(
                          cells: [
                            DataCell(
                              SizedBox(width: 260, child: Text(item.name)),
                            ),
                            DataCell(
                              SizedBox(width: 180, child: Text(item.type)),
                            ),
                            DataCell(Chip(label: Text(item.status))),
                            DataCell(
                              SizedBox(
                                width: 220,
                                child: Text(item.commercialReadiness),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 300,
                                child: Text(
                                  'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/mock/product_portfolio.json',
                                ),
                              ),
                            ),
                            DataCell(
                              TextButton.icon(
                                onPressed: () => _openSourceLocation(
                                  'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/mock/product_portfolio.json',
                                ),
                                icon: const Icon(Icons.open_in_new_outlined),
                                label: const Text('Open source'),
                              ),
                            ),
                            DataCell(
                              TextButton.icon(
                                onPressed: () => _revealSourceLocation(
                                  'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/mock/product_portfolio.json',
                                ),
                                icon: const Icon(Icons.folder_open_outlined),
                                label: const Text('Reveal'),
                              ),
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
              'This tab stays read-only and points into the live Assets module when you need to work with equipment, projects, or valuation.',
          children: [_AssetOverviewCard(snapshot: snapshot)],
        ),
      ],
    );
  }
}

class _EvidenceLibraryTab extends StatelessWidget {
  const _EvidenceLibraryTab();

  @override
  Widget build(BuildContext context) {
    final sections = _evidenceItems.map((item) => item.section).toSet().toList()
      ..sort();
    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Evidence Library',
          body:
              'Read-only source index of the documents, templates, and module artifacts that support the company record.',
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sections
                  .map(
                    (section) => _InlineTag(
                      label: section,
                      accent: AppColours.darkSecondary,
                      foreground: AppColours.darkText,
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 14),
            _EvidenceIndexCard(items: _evidenceItems),
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
    final stages =
        snapshot.grantsPipeline.map((item) => item.stage).toSet().toList()
          ..sort();
    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Grants pipeline',
          body:
              'Calm source-linked board for grant research, fit, and the next practical action.',
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: stages
                  .map(
                    (stage) => _CompanyAssetMetric(
                      label: stage,
                      value:
                          '${snapshot.grantsPipeline.where((item) => item.stage == stage).length}',
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 14),
            _GrantsPipelineTable(items: snapshot.grantsPipeline),
          ],
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
              'Calm lane board for the next practical company moves. Keep each lane short, current, and easy to scan.',
          children: [
            _ActionBoardSummaryRow(lanes: orderedLanes, laneMap: lanes),
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

class _SettingsTab extends ConsumerStatefulWidget {
  const _SettingsTab({
    required this.snapshot,
    required this.linkedinCompanyUrl,
    required this.onLinkedInCompanyUrlChanged,
  });

  final CompanyCommandCentreSnapshot snapshot;
  final String linkedinCompanyUrl;
  final ValueChanged<String> onLinkedInCompanyUrlChanged;

  @override
  ConsumerState<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<_SettingsTab> {
  bool _busy = false;
  late final TextEditingController _linkedinController;

  @override
  void initState() {
    super.initState();
    _linkedinController = TextEditingController(
      text: widget.linkedinCompanyUrl,
    );
  }

  @override
  void didUpdateWidget(covariant _SettingsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.linkedinCompanyUrl != widget.linkedinCompanyUrl &&
        _linkedinController.text != widget.linkedinCompanyUrl) {
      _linkedinController.text = widget.linkedinCompanyUrl;
    }
  }

  @override
  void dispose() {
    _linkedinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.snapshot;
    final omegaPathExists = Directory(
      snapshot.configuredOmegaPath,
    ).existsSync();
    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Settings',
          body:
              'Read-only configuration, source path visibility, and the backup-first write plan.',
          children: [
            _KeyValueRow(
              label: 'Omega OS source path',
              value: snapshot.configuredOmegaPath,
            ),
            _KeyValueRow(
              label: 'LinkedIn destination',
              value: widget.linkedinCompanyUrl,
            ),
            _KeyValueRow(
              label: 'Source path status',
              value: omegaPathExists ? 'Available' : 'Missing',
            ),
            _KeyValueRow(
              label: 'Module config',
              value: snapshot.moduleConfigPath,
            ),
            _KeyValueRow(
              label: 'Module config status',
              value: snapshot.moduleConfigExists ? 'Available' : 'Missing',
            ),
            _KeyValueRow(
              label: 'Write mode',
              value: snapshot.moduleReadOnly ? 'Read only' : 'Write enabled',
            ),
            _KeyValueRow(
              label: 'Backup before write',
              value: snapshot.moduleBackupBeforeWrite ? 'Enabled' : 'Disabled',
            ),
            _KeyValueRow(label: 'Backup root', value: snapshot.backupRootPath),
            _KeyValueRow(label: 'Audit log', value: snapshot.auditLogPath),
            const _KeyValueRow(
              label: 'Summary report',
              value:
                  'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/omega_os_bridge/reports/company_command_centre_summary.md',
            ),
            const _KeyValueRow(
              label: 'Write policy',
              value: 'Copy first, then overwrite',
            ),
            const _KeyValueRow(
              label: 'Route',
              value: '/modules/company-command-centre',
            ),
          ],
        ),
        _CalmSectionCard(
          title: 'LinkedIn connection',
          body:
              'The dashboard links to the LinkedIn destination in the browser while the module stays read-only.',
          children: [
            const _KeyValueRow(label: 'Launch mode', value: 'External browser'),
            _KeyValueRow(
              label: 'LinkedIn destination',
              value: widget.linkedinCompanyUrl,
            ),
            TextFormField(
              controller: _linkedinController,
              decoration: const InputDecoration(
                labelText: 'LinkedIn URL',
                helperText:
                    'Paste the live company page here, or leave the search link in place for now.',
              ),
              onChanged: widget.onLinkedInCompanyUrlChanged,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _openExternalUrl(widget.linkedinCompanyUrl),
                  icon: const Icon(Icons.open_in_new_outlined),
                  label: const Text('Open LinkedIn'),
                ),
                OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _revealSourceLocation(
                          'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
                        ),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Open LinkedIn checklist'),
                ),
                TextButton.icon(
                  onPressed: _busy
                      ? null
                      : () {
                          _linkedinController.text =
                              companyCommandCentreLinkedInCompanyUrl;
                          widget.onLinkedInCompanyUrlChanged(
                            companyCommandCentreLinkedInCompanyUrl,
                          );
                        },
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
        _CalmSectionCard(
          title: 'Write controls',
          body:
              'Keep the module read-only by default. Turn write mode on only when you are ready to save local changes with backups.',
          children: [
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: !snapshot.moduleReadOnly,
              onChanged: _busy ? null : (value) => _setReadOnlyMode(!value),
              title: const Text('Write mode'),
              subtitle: Text(
                snapshot.moduleReadOnly ? 'Read only' : 'Write enabled',
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : _exportAuditSummary,
                  icon: const Icon(Icons.summarize_outlined),
                  label: const Text('Export audit summary'),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _exportCompanySummary,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Export company summary'),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _openLatestReport,
                  icon: const Icon(Icons.open_in_new_outlined),
                  label: const Text('Open latest report'),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _refreshIndexes,
                  icon: const Icon(Icons.refresh_outlined),
                  label: const Text('Refresh indexes'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _setReadOnlyMode(bool readOnly) async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    final result = await ref
        .read(companyCommandCentreWriteServiceProvider)
        .setReadOnlyMode(
          readOnly: readOnly,
          actorLabel: 'Peter Ellis',
          note: readOnly
              ? 'Disable company write mode from settings.'
              : 'Enable company write mode from settings.',
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _busy = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
    if (result.success) {
      ref.invalidate(companyCommandCentreSnapshotProvider);
    }
  }

  Future<void> _exportAuditSummary() async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    final result = await ref
        .read(companyCommandCentreWriteServiceProvider)
        .exportAuditSummaryReport(
          actorLabel: 'Peter Ellis',
          note: 'Export the company audit summary from settings.',
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _busy = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
    if (result.success) {
      ref.invalidate(companyCommandCentreSnapshotProvider);
    }
  }

  Future<void> _exportCompanySummary() async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    final result = await ref
        .read(companyCommandCentreReportServiceProvider)
        .exportSummaryReport(snapshot: widget.snapshot);

    if (!mounted) {
      return;
    }

    setState(() {
      _busy = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _openLatestReport() async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    final result = await ref
        .read(companyCommandCentreReportServiceProvider)
        .openLatestReport();

    if (!mounted) {
      return;
    }

    setState(() {
      _busy = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _refreshIndexes() async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    final result = await ref
        .read(companyCommandCentreIndexServiceProvider)
        .scanAndGenerate();

    if (!mounted) {
      return;
    }

    setState(() {
      _busy = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Refreshed ${result.sourceMarkdownCount} markdown files into local indexes.',
        ),
      ),
    );
    ref.invalidate(companyCommandCentreSnapshotProvider);
  }
}

class _GrantsPipelineTable extends StatelessWidget {
  const _GrantsPipelineTable({required this.items});

  final List<CompanyGrantItemData> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        'No grants are being tracked yet.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final sortedItems = [...items]
      ..sort((a, b) {
        final byStage = a.stage.compareTo(b.stage);
        if (byStage != 0) {
          return byStage;
        }
        return a.name.compareTo(b.name);
      });

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Source-linked grant board',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Each row shows the grant fit and the next practical action to take.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 44,
                  dataRowMinHeight: 52,
                  dataRowMaxHeight: 96,
                  columns: const [
                    DataColumn(label: Text('Grant')),
                    DataColumn(label: Text('Stage')),
                    DataColumn(label: Text('Fit')),
                    DataColumn(label: Text('Next action')),
                    DataColumn(label: Text('Source file')),
                    DataColumn(label: Text('Open')),
                    DataColumn(label: Text('Reveal')),
                  ],
                  rows: sortedItems
                      .map(
                        (item) => DataRow(
                          cells: [
                            DataCell(
                              SizedBox(width: 260, child: Text(item.name)),
                            ),
                            DataCell(Chip(label: Text(item.stage))),
                            DataCell(
                              SizedBox(width: 240, child: Text(item.fit)),
                            ),
                            DataCell(
                              SizedBox(
                                width: 240,
                                child: Text(item.nextAction),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 260,
                                child: Text(
                                  'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/mock/grants_pipeline.json',
                                ),
                              ),
                            ),
                            DataCell(
                              TextButton.icon(
                                onPressed: () => _openSourceLocation(
                                  'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/mock/grants_pipeline.json',
                                ),
                                icon: const Icon(Icons.open_in_new_outlined),
                                label: const Text('Open'),
                              ),
                            ),
                            DataCell(
                              TextButton.icon(
                                onPressed: () => _revealSourceLocation(
                                  'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/mock/grants_pipeline.json',
                                ),
                                icon: const Icon(Icons.folder_open_outlined),
                                label: const Text('Reveal'),
                              ),
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
          ),
        ],
      ),
    );
  }
}

class _ActionBoardSummaryRow extends StatelessWidget {
  const _ActionBoardSummaryRow({required this.lanes, required this.laneMap});

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
  const _ActionLaneCard({required this.title, required this.items});

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
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
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

                    return _AssetRegistryBoard(
                      snapshot: snapshot,
                      workspace: workspace,
                      projects: projects,
                      valuation: valuation,
                      syncStatus: syncStatus,
                      readyProjects: readyProjects,
                      mixedProjects: mixedProjects,
                      lowStockProjects: lowStockProjects,
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

class _AssetRegistryBoard extends StatelessWidget {
  const _AssetRegistryBoard({
    required this.snapshot,
    required this.workspace,
    required this.projects,
    required this.valuation,
    required this.syncStatus,
    required this.readyProjects,
    required this.mixedProjects,
    required this.lowStockProjects,
  });

  final CompanyCommandCentreSnapshot snapshot;
  final AssetWorkspaceSnapshot workspace;
  final List<AssetProjectSummary> projects;
  final AssetValuationOverview valuation;
  final AssetSyncStatus syncStatus;
  final int readyProjects;
  final int mixedProjects;
  final int lowStockProjects;

  @override
  Widget build(BuildContext context) {
    final rows = [
      _AssetRegistryRow(
        name: 'Live workspace',
        summary:
            '${workspace.equipmentCount} equipment, ${workspace.partsCount} parts',
        status: syncStatus.statusLabel,
        sourceFile: 'lib/features/assets/presentation/assets_screen.dart',
        route: RouteNames.assets,
      ),
      _AssetRegistryRow(
        name: 'Equipment register',
        summary: '${workspace.equipmentCount} tracked equipment items',
        status: 'Working register',
        sourceFile:
            'lib/features/assets/presentation/equipment_register_screen.dart',
        route: RouteNames.assetEquipment,
      ),
      _AssetRegistryRow(
        name: 'Project summary',
        summary:
            '${projects.length} projects, $readyProjects ready, $mixedProjects mixed, $lowStockProjects low stock',
        status: 'Read only summary',
        sourceFile:
            'lib/features/assets/presentation/project_summary_screen.dart',
        route: RouteNames.assetProjectSummary,
      ),
      _AssetRegistryRow(
        name: 'Valuation summary',
        summary:
            '${valuation.valuationRowCount} rows, ${valuation.currentEstimatedValueTotal.toStringAsFixed(2)} estimated value',
        status: 'Tracked',
        sourceFile:
            'lib/features/assets/presentation/valuation_summary_screen.dart',
        route: RouteNames.assetValuationSummary,
      ),
      _AssetRegistryRow(
        name: 'Sync journal',
        summary:
            '${syncStatus.entryCount} entries, ${syncStatus.conflictCount} conflicts',
        status: syncStatus.isConnected ? 'Connected' : 'Needs attention',
        sourceFile: 'lib/features/assets/application/assets_controller.dart',
        route: RouteNames.assets,
      ),
    ];

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
                    style: Theme.of(context).textTheme.titleMedium,
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
              workspace.assetsRootPath ?? snapshot.overview.omegaOsPath,
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
                  label: 'Conflicts',
                  value: '${syncStatus.conflictCount}',
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Source-linked asset registry',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'This stays read-only and points into the live Assets module when you need to work the actual register.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 44,
                  dataRowMinHeight: 54,
                  dataRowMaxHeight: 92,
                  columns: const [
                    DataColumn(label: Text('Area')),
                    DataColumn(label: Text('Summary')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Source file')),
                    DataColumn(label: Text('Open')),
                    DataColumn(label: Text('Reveal')),
                  ],
                  rows: rows
                      .map(
                        (row) => DataRow(
                          cells: [
                            DataCell(
                              SizedBox(width: 220, child: Text(row.name)),
                            ),
                            DataCell(
                              SizedBox(width: 360, child: Text(row.summary)),
                            ),
                            DataCell(
                              SizedBox(width: 160, child: Text(row.status)),
                            ),
                            DataCell(
                              SizedBox(width: 350, child: Text(row.sourceFile)),
                            ),
                            DataCell(
                              TextButton.icon(
                                onPressed: () => context.push(row.route),
                                icon: const Icon(Icons.open_in_new_outlined),
                                label: const Text('Open'),
                              ),
                            ),
                            DataCell(
                              TextButton.icon(
                                onPressed: () =>
                                    _revealSourceLocation(row.sourceFile),
                                icon: const Icon(Icons.folder_open_outlined),
                                label: const Text('Reveal'),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
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
                  onPressed: () => context.push(RouteNames.assetEquipment),
                  icon: const Icon(Icons.precision_manufacturing_outlined),
                  label: const Text('Open Equipment Register'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push(RouteNames.assetProjectSummary),
                  icon: const Icon(Icons.groups_2_outlined),
                  label: const Text('Open Project Summary'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.push(RouteNames.assetValuationSummary),
                  icon: const Icon(Icons.assessment_outlined),
                  label: const Text('Open Valuation Summary'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Read-only summary only. The live Assets module remains the working register.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetRegistryRow {
  const _AssetRegistryRow({
    required this.name,
    required this.summary,
    required this.status,
    required this.sourceFile,
    required this.route,
  });

  final String name;
  final String summary;
  final String status;
  final String sourceFile;
  final String route;
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

class _EvidenceIndexCard extends StatelessWidget {
  const _EvidenceIndexCard({required this.items});

  final List<_EvidenceItem> items;

  @override
  Widget build(BuildContext context) {
    final sortedItems = [...items]
      ..sort((a, b) {
        final bySection = a.section.compareTo(b.section);
        if (bySection != 0) {
          return bySection;
        }
        return a.title.compareTo(b.title);
      });

    final counts = <String, int>{};
    for (final item in sortedItems) {
      counts[item.section] = (counts[item.section] ?? 0) + 1;
    }

    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Source-linked file index', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              'Each row shows the supporting artifact and the file that anchors it.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: counts.entries
                  .map(
                    (entry) => _InlineTag(
                      label: '${entry.key} - ${entry.value}',
                      accent: AppColours.darkSecondary,
                      foreground: AppColours.darkText,
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 14),
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
                    DataColumn(label: Text('Section')),
                    DataColumn(label: Text('Kind')),
                    DataColumn(label: Text('Source file')),
                    DataColumn(label: Text('Open')),
                    DataColumn(label: Text('Reveal')),
                  ],
                  rows: sortedItems
                      .map(
                        (item) => DataRow(
                          cells: [
                            DataCell(
                              SizedBox(width: 280, child: Text(item.title)),
                            ),
                            DataCell(
                              SizedBox(width: 180, child: Text(item.section)),
                            ),
                            DataCell(
                              SizedBox(width: 140, child: Text(item.kind)),
                            ),
                            DataCell(
                              SizedBox(
                                width: 340,
                                child: Text(item.sourceFile),
                              ),
                            ),
                            DataCell(
                              TextButton.icon(
                                onPressed: () =>
                                    _openSourceLocation(item.sourceFile),
                                icon: const Icon(Icons.open_in_new_outlined),
                                label: const Text('Open source'),
                              ),
                            ),
                            DataCell(
                              TextButton.icon(
                                onPressed: () =>
                                    _revealSourceLocation(item.sourceFile),
                                icon: const Icon(Icons.folder_open_outlined),
                                label: const Text('Reveal'),
                              ),
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
    notes:
        'Core companies, banking, tax, and public presence items in one support list.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _EvidenceItem(
    section: 'Legal & finance',
    title: 'Company overview template',
    kind: 'Template',
    status: 'Tracked',
    notes:
        'Reusable template for the company overview record and public-facing summary.',
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
    notes:
        'Structure for future product pages and evidence-backed product descriptions.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/templates/product_page_template.md',
  ),
  _EvidenceItem(
    section: 'Product & operations',
    title: 'Roadmap',
    kind: 'Roadmap',
    status: 'Tracked',
    notes:
        'The company module roadmap provides the longer-term evidence trail.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/roadmap/ROADMAP.md',
  ),
  _EvidenceItem(
    section: 'Product & operations',
    title: 'Operating manual',
    kind: 'Manual',
    status: 'Tracked',
    notes:
        'Operational guidance for how the company module is meant to be used.',
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
    title: 'Company module folder',
    kind: 'Folder',
    status: 'Tracked',
    notes:
        'Open the module root to review the company command centre source bundle.',
    sourceFile: 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE',
  ),
  _EvidenceItem(
    section: 'Module source',
    title: 'Module manifest',
    kind: 'JSON',
    status: 'Tracked',
    notes: 'Module registration details used by the dashboard module system.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/module_manifest.json',
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

class _ComplianceSectionCard extends StatelessWidget {
  const _ComplianceSectionCard({required this.title, required this.items});

  final String title;
  final List<_ChecklistItem> items;

  @override
  Widget build(BuildContext context) {
    return _CalmSectionCard(
      title: title,
      body: 'Read-only checklist rows sourced from the company admin notes.',
      children: [_ComplianceTable(items: items)],
    );
  }
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
                        child: Text(
                          item.notes,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(width: 220, child: Text(item.sourceFile)),
                    ),
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
                        child: Text(
                          item.notes,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(width: 260, child: Text(item.sourceFile)),
                    ),
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
  const _TrackerSectionCard({required this.title, required this.items});

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

class _WebsitePageBoard extends StatelessWidget {
  const _WebsitePageBoard({required this.items});

  final List<_TrackerItem> items;

  @override
  Widget build(BuildContext context) {
    final sortedItems = [...items]
      ..sort((a, b) {
        final byStatus = a.status.compareTo(b.status);
        if (byStatus != 0) {
          return byStatus;
        }
        return a.item.compareTo(b.item);
      });

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Page-level tracker',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Each row maps directly to the website next steps list and keeps the public pages calm and visible.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
                    DataColumn(label: Text('Page')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Notes')),
                    DataColumn(label: Text('Source file')),
                    DataColumn(label: Text('Open')),
                  ],
                  rows: sortedItems
                      .map(
                        (item) => DataRow(
                          cells: [
                            DataCell(
                              SizedBox(width: 260, child: Text(item.item)),
                            ),
                            DataCell(Chip(label: Text(item.status))),
                            DataCell(
                              SizedBox(width: 360, child: Text(item.notes)),
                            ),
                            DataCell(
                              SizedBox(
                                width: 320,
                                child: Text(item.sourceFile),
                              ),
                            ),
                            DataCell(
                              TextButton.icon(
                                onPressed: () =>
                                    _openSourceLocation(item.sourceFile),
                                icon: const Icon(Icons.open_in_new_outlined),
                                label: const Text('Open source'),
                              ),
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

class _LinkedInPageBoard extends StatelessWidget {
  const _LinkedInPageBoard({required this.items});

  final List<_TrackerItem> items;

  @override
  Widget build(BuildContext context) {
    final sortedItems = [...items]
      ..sort((a, b) {
        final bySection = a.section.compareTo(b.section);
        if (bySection != 0) {
          return bySection;
        }
        final byStatus = a.status.compareTo(b.status);
        if (byStatus != 0) {
          return byStatus;
        }
        return a.item.compareTo(b.item);
      });

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Page-level tracker',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Each row keeps the profile, company page, content rhythm, and launch tasks in one calm view.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
                    DataColumn(label: Text('Page')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Notes')),
                    DataColumn(label: Text('Source file')),
                    DataColumn(label: Text('Open')),
                  ],
                  rows: sortedItems
                      .map(
                        (item) => DataRow(
                          cells: [
                            DataCell(
                              SizedBox(width: 260, child: Text(item.item)),
                            ),
                            DataCell(Chip(label: Text(item.status))),
                            DataCell(
                              SizedBox(width: 360, child: Text(item.notes)),
                            ),
                            DataCell(
                              SizedBox(
                                width: 320,
                                child: Text(item.sourceFile),
                              ),
                            ),
                            DataCell(
                              TextButton.icon(
                                onPressed: () =>
                                    _openSourceLocation(item.sourceFile),
                                icon: const Icon(Icons.open_in_new_outlined),
                                label: const Text('Open source'),
                              ),
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

class _LinkedInGuidanceCard extends StatelessWidget {
  const _LinkedInGuidanceCard();

  @override
  Widget build(BuildContext context) {
    return _CalmSectionCard(
      title: 'How the dashboard enriches LinkedIn',
      body:
          'Use the company workspace as your content engine: keep the profile current, turn the action board into weekly posts, and pull evidence from the website and product tabs.',
      children: const [
        _LinkedInBullet(
          text:
              'Keep the LinkedIn destination saved in Settings so you always open the right page quickly.',
        ),
        _LinkedInBullet(
          text:
              'Use the Overview quick actions to jump between company work and LinkedIn planning.',
        ),
        _LinkedInBullet(
          text:
              'Turn director actions and product progress into a weekly engineering update.',
        ),
        _LinkedInBullet(
          text:
              'Use the Website and Evidence tabs to pull proof, screenshots, and polished wording into posts.',
        ),
      ],
    );
  }
}

class _LinkedInProfileCopyCard extends StatelessWidget {
  const _LinkedInProfileCopyCard({required this.profileCopy});

  final _LinkedInProfileCopy profileCopy;

  @override
  Widget build(BuildContext context) {
    return _CalmSectionCard(
      title: 'Profile headline and about copy',
      body:
          'Copy-ready text for the personal LinkedIn profile and the company-facing about section.',
      children: [
        _CopyBlock(label: 'Headline', text: profileCopy.headline),
        const SizedBox(height: 12),
        _CopyBlock(label: 'About', text: profileCopy.about, maxLines: 6),
      ],
    );
  }
}

class _LinkedInContentBankCard extends StatelessWidget {
  const _LinkedInContentBankCard({required this.items});

  final List<_LinkedInContentBankItem> items;

  @override
  Widget build(BuildContext context) {
    return _CalmSectionCard(
      title: 'LinkedIn content bank',
      body:
          'Turn company milestones into post prompts with one short source-backed angle for each.',
      children: [
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CopyBlock(
              label: item.label,
              text: item.prompt,
              footerTags: item.tags,
            ),
          ),
        ),
      ],
    );
  }
}

class _LinkedInChecklistCard extends StatelessWidget {
  const _LinkedInChecklistCard();

  @override
  Widget build(BuildContext context) {
    return _CalmSectionCard(
      title: 'LinkedIn checklist',
      body:
          'Use this short checklist before you post or update the company page.',
      children: const [
        _LinkedInBullet(
          text: 'Keep the LinkedIn destination saved in Settings.',
        ),
        _LinkedInBullet(
          text: 'Choose one clear company milestone or product angle.',
        ),
        _LinkedInBullet(
          text: 'Pull one proof point from the evidence or website tabs.',
        ),
        _LinkedInBullet(
          text: 'Copy the weekly template or a content bank prompt.',
        ),
        _LinkedInBullet(
          text: 'Post, then note the next follow-up task in the action board.',
        ),
      ],
    );
  }
}

class _CopyBlock extends StatelessWidget {
  const _CopyBlock({
    required this.label,
    required this.text,
    this.maxLines = 4,
    this.footerTags = const [],
  });

  final String label;
  final String text;
  final int maxLines;
  final List<String> footerTags;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: text));
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Copied $label')));
                  },
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              text,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            if (footerTags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: footerTags
                    .map(
                      (tag) => _InlineTag(
                        label: tag,
                        accent: AppColours.darkSecondary,
                        foreground: AppColours.darkText,
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LinkedInProfileCopy {
  const _LinkedInProfileCopy({required this.headline, required this.about});

  final String headline;
  final String about;
}

class _LinkedInContentBankItem {
  const _LinkedInContentBankItem({
    required this.label,
    required this.prompt,
    required this.tags,
  });

  final String label;
  final String prompt;
  final List<String> tags;
}

class _LinkedInBullet extends StatelessWidget {
  const _LinkedInBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 8),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _LinkedInIdeaGeneratorCard extends StatelessWidget {
  const _LinkedInIdeaGeneratorCard({required this.ideas});

  final List<_LinkedInPostIdea> ideas;

  @override
  Widget build(BuildContext context) {
    return _CalmSectionCard(
      title: 'LinkedIn post ideas',
      body:
          'Short, source-backed angles you can use for the next company update.',
      children: [
        ...ideas.map(
          (idea) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            idea.title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => Clipboard.setData(
                            ClipboardData(text: idea.copyText),
                          ),
                          icon: const Icon(Icons.copy_outlined),
                          label: const Text('Copy'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(idea.hook),
                    const SizedBox(height: 8),
                    Text(
                      idea.copyText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InlineTag(
                          label: idea.sourceLabel,
                          accent: AppColours.darkSecondary,
                          foreground: AppColours.darkText,
                        ),
                        _InlineTag(
                          label: idea.angle,
                          accent: AppColours.darkGlow,
                          foreground: AppColours.darkText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LinkedInWeeklyTemplateCard extends StatelessWidget {
  const _LinkedInWeeklyTemplateCard({required this.template});

  final _LinkedInWeeklyTemplate template;

  @override
  Widget build(BuildContext context) {
    return _CalmSectionCard(
      title: 'Weekly LinkedIn template',
      body:
          'A repeatable structure for the weekly engineering update and company progress post.',
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                template.summary,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            TextButton.icon(
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: template.copyText)),
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copy template'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColours.darkSurface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColours.darkOutline),
          ),
          child: SelectableText(
            template.copyText,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: template.closesWith
              .map(
                (item) => _InlineTag(
                  label: item,
                  accent: AppColours.darkSecondary,
                  foreground: AppColours.darkText,
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _LinkedInPostIdea {
  const _LinkedInPostIdea({
    required this.title,
    required this.hook,
    required this.copyText,
    required this.sourceLabel,
    required this.angle,
  });

  final String title;
  final String hook;
  final String copyText;
  final String sourceLabel;
  final String angle;
}

class _LinkedInWeeklyTemplate {
  const _LinkedInWeeklyTemplate({
    required this.summary,
    required this.copyText,
    required this.closesWith,
  });

  final String summary;
  final String copyText;
  final List<String> closesWith;
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

List<_LinkedInPostIdea> _buildLinkedInPostIdeas(
  CompanyCommandCentreSnapshot snapshot,
  List<_TrackerItem> linkedInItems,
) {
  final companyName = snapshot.overview.companyName.isNotEmpty
      ? snapshot.overview.companyName
      : 'New Earth Advanced Technologies Ltd';
  final nextMilestone = snapshot.overview.nextMilestone.isNotEmpty
      ? snapshot.overview.nextMilestone
      : 'the next company milestone';
  final firstProduct = snapshot.productPortfolio.isNotEmpty
      ? snapshot.productPortfolio.first.name
      : 'the next product';
  final firstAction = snapshot.actionBoard.isNotEmpty
      ? snapshot.actionBoard.first.title
      : 'the next practical move';
  final launchTaskCount = linkedInItems
      .where((item) => item.section == 'Launch Tasks')
      .length;

  return [
    _LinkedInPostIdea(
      title: 'Weekly progress update',
      hook: 'Share what moved this week and why it matters.',
      copyText:
          'This week at $companyName we moved $nextMilestone.\n\nWhat changed:\n- One clear milestone moved forward.\n- One practical action from the company board was completed.\n- One proof point can now be shared publicly.\n\nWhy it matters:\nIt keeps the work visible, calm, and grounded in real progress.\n\nNext step: $firstAction',
      sourceLabel: 'Overview + Action Board',
      angle: 'Progress',
    ),
    _LinkedInPostIdea(
      title: 'Product spotlight',
      hook: 'Introduce a product in one calm, useful post.',
      copyText:
          'Product spotlight: $firstProduct\n\nWhy it exists:\nIt supports the wider New Earth mission.\n\nWhat it does:\n- Keep it simple and practical.\n- Explain the user benefit in one line.\n- Link the product back to the company direction.\n\nIf you are following the build, this is where the idea becomes a working product.',
      sourceLabel: 'Product Portfolio',
      angle: 'Product',
    ),
    _LinkedInPostIdea(
      title: 'Founder note',
      hook: 'Use this for a short personal update or lesson learned.',
      copyText:
          'Founder note from $companyName\n\nThis week I focused on clarity, evidence, and the next practical move.\n\nWhat I learned:\n- Small steps make the work easier to share.\n- Calm structure makes the system easier to trust.\n- Good documentation makes public updates easier.\n\nIf you are building something similar, keep the next step small and visible.',
      sourceLabel: '$launchTaskCount launch tasks',
      angle: 'Founder',
    ),
  ];
}

_LinkedInProfileCopy _buildLinkedInProfileCopy(
  CompanyCommandCentreSnapshot snapshot,
) {
  final companyName = snapshot.overview.companyName.isNotEmpty
      ? snapshot.overview.companyName
      : 'New Earth Advanced Technologies Ltd';
  final companyNumber = snapshot.overview.companyNumber.isNotEmpty
      ? snapshot.overview.companyNumber
      : '17286202';
  final domain = snapshot.overview.domain.isNotEmpty
      ? snapshot.overview.domain
      : 'www.new-earth.uk';
  final focusLine = snapshot.overview.focus.isNotEmpty
      ? snapshot.overview.focus.take(3).join(' · ')
      : 'Embedded systems · IoT · sustainability technology';

  return _LinkedInProfileCopy(
    headline:
        'Founder & Director at $companyName | Building calm technology for useful real-world systems',
    about:
        'I lead $companyName, where we build practical technology across embedded systems, IoT, wellbeing, and regenerative tools.\n\nCurrent focus: $focusLine.\n\nCompany number: $companyNumber\nWebsite: $domain\n\nI use this space to share evidence-backed progress, product milestones, and useful lessons from the build.',
  );
}

List<_LinkedInContentBankItem> _buildLinkedInContentBank(
  CompanyCommandCentreSnapshot snapshot,
) {
  final companyName = snapshot.overview.companyName.isNotEmpty
      ? snapshot.overview.companyName
      : 'New Earth Advanced Technologies Ltd';
  final productNames = snapshot.productPortfolio
      .map((item) => item.name)
      .toList();
  final firstProduct = productNames.isNotEmpty
      ? productNames.first
      : 'MicroGrow';
  final secondProduct = productNames.length > 1 ? productNames[1] : 'BioCalm';
  final nextMilestone = snapshot.overview.nextMilestone.isNotEmpty
      ? snapshot.overview.nextMilestone
      : 'the next company milestone';

  return [
    _LinkedInContentBankItem(
      label: 'Milestone update',
      prompt:
          'Prompt: Share how $companyName moved $nextMilestone and why it matters to the wider mission.',
      tags: const ['Overview', 'Progress', 'Mission'],
    ),
    _LinkedInContentBankItem(
      label: '$firstProduct spotlight',
      prompt:
          'Prompt: Explain $firstProduct in simple language, what problem it solves, and how it fits the company direction.',
      tags: const ['Product', 'Simple', 'Useful'],
    ),
    _LinkedInContentBankItem(
      label: '$secondProduct tease',
      prompt:
          'Prompt: Share one reason $secondProduct exists, what stage it is at, and one thing you have learned while building it.',
      tags: const ['Product', 'Learning', 'Build log'],
    ),
    _LinkedInContentBankItem(
      label: 'Founder reflection',
      prompt:
          'Prompt: Share a short lesson learned this week and connect it to how you are building $companyName.',
      tags: const ['Founder', 'Reflection', 'Trust'],
    ),
    _LinkedInContentBankItem(
      label: 'Website proof',
      prompt:
          'Prompt: Show one piece of proof from the website, evidence, or product tabs that supports a public update.',
      tags: const ['Website', 'Evidence', 'Proof'],
    ),
  ];
}

_LinkedInWeeklyTemplate _buildWeeklyLinkedInTemplate(
  CompanyCommandCentreSnapshot snapshot,
  List<_TrackerItem> linkedInItems,
) {
  final companyName = snapshot.overview.companyName.isNotEmpty
      ? snapshot.overview.companyName
      : 'New Earth Advanced Technologies Ltd';
  final milestone = snapshot.overview.nextMilestone.isNotEmpty
      ? snapshot.overview.nextMilestone
      : 'the next milestone';
  final profileCount = linkedInItems
      .where((item) => item.section == 'Profile')
      .length;
  final companyPageCount = linkedInItems
      .where((item) => item.section == 'Company Page')
      .length;
  final rhythmCount = linkedInItems
      .where((item) => item.section == 'Content Rhythm')
      .length;

  return _LinkedInWeeklyTemplate(
    summary: 'Copy-ready weekly post structure',
    copyText:
        '''
Weekly update from $companyName

One line win:
$milestone

What I built:
- A clear company action moved forward.
- A product or website step became more visible.
- The record now has better proof and better structure.

Why it matters:
It helps keep the company work calm, local, and easy to understand.

What is next:
- Keep the LinkedIn profile aligned.
- Keep the company page current.
- Keep the weekly rhythm steady.

Follow along for more practical build updates.
'''
            .trim(),
    closesWith: [
      '$profileCount profile tasks',
      '$companyPageCount company page tasks',
      '$rhythmCount rhythm tasks',
    ],
  );
}

Future<void> _openSourceLocation(String sourcePath) async {
  final trimmedPath = sourcePath.trim();
  if (trimmedPath.isEmpty) {
    return;
  }

  final entityType = FileSystemEntity.typeSync(trimmedPath, followLinks: false);
  final isDirectory = entityType == FileSystemEntityType.directory;

  if (Platform.isWindows) {
    if (isDirectory) {
      await Process.start('explorer.exe', [trimmedPath]);
    } else {
      await Process.start('cmd.exe', ['/c', 'start', '', trimmedPath]);
    }
    return;
  }

  if (Platform.isMacOS) {
    await Process.start('open', [trimmedPath]);
    return;
  }

  await Process.start('xdg-open', [trimmedPath]);
}

Future<void> _openExternalUrl(String url) async {
  final trimmedUrl = url.trim();
  if (trimmedUrl.isEmpty) {
    return;
  }

  if (Platform.isWindows) {
    await Process.start('explorer.exe', [trimmedUrl]);
    return;
  }

  if (Platform.isMacOS) {
    await Process.start('open', [trimmedUrl]);
    return;
  }

  await Process.start('xdg-open', [trimmedUrl]);
}

Future<void> _revealSourceLocation(String sourcePath) async {
  final trimmedPath = sourcePath.trim();
  if (trimmedPath.isEmpty) {
    return;
  }

  final entityType = FileSystemEntity.typeSync(trimmedPath, followLinks: false);
  final isDirectory = entityType == FileSystemEntityType.directory;

  if (Platform.isWindows) {
    if (isDirectory) {
      await Process.start('explorer.exe', [trimmedPath]);
    } else {
      await Process.start('explorer.exe', ['/select,$trimmedPath']);
    }
    return;
  }

  if (Platform.isMacOS) {
    if (isDirectory) {
      await Process.start('open', [trimmedPath]);
    } else {
      await Process.start('open', ['-R', trimmedPath]);
    }
    return;
  }

  final folderPath = isDirectory ? trimmedPath : File(trimmedPath).parent.path;
  await Process.start('xdg-open', [folderPath]);
}

class _LinkedFileTable extends StatelessWidget {
  const _LinkedFileTable({required this.records});

  final List<CompanyCommandCentreMarkdownRecord> records;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (records.isEmpty) {
      return Text(
        'No linked company Markdown files were found yet.',
        style: theme.textTheme.bodyMedium,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 44,
          dataRowMinHeight: 52,
          dataRowMaxHeight: 88,
          columns: const [
            DataColumn(label: Text('Title')),
            DataColumn(label: Text('Signals')),
            DataColumn(label: Text('Source file')),
          ],
          rows: records
              .map(
                (record) => DataRow(
                  cells: [
                    DataCell(SizedBox(width: 280, child: Text(record.title))),
                    DataCell(
                      SizedBox(
                        width: 250,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (record.checkboxCount > 0)
                              _InlineTag(
                                label: '${record.checkboxCount} tasks',
                                accent: AppColours.darkSecondary,
                                foreground: AppColours.darkText,
                              ),
                            if (record.dueDates.isNotEmpty)
                              _InlineTag(
                                label: '${record.dueDates.length} due dates',
                                accent: AppColours.darkAmber,
                                foreground: AppColours.darkText,
                              ),
                            if (record.labels.contains('product'))
                              _InlineTag(
                                label: 'Product',
                                accent: AppColours.darkSuccess,
                                foreground: AppColours.darkText,
                              ),
                            if (record.labels.contains('grant'))
                              _InlineTag(
                                label: 'Grant',
                                accent: AppColours.darkPurple,
                                foreground: AppColours.darkText,
                              ),
                            if (record.labels.contains('ip_asset'))
                              _InlineTag(
                                label: 'IP / Asset',
                                accent: AppColours.darkGlow,
                                foreground: AppColours.darkText,
                              ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(width: 320, child: Text(record.relativePath)),
                    ),
                  ],
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _IndexExplorerTab extends StatefulWidget {
  const _IndexExplorerTab({required this.snapshot});

  final CompanyCommandCentreSnapshot snapshot;

  @override
  State<_IndexExplorerTab> createState() => _IndexExplorerTabState();
}

class _IndexExplorerTabState extends State<_IndexExplorerTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.snapshot.indexSnapshot;
    final records = _filteredRecords(snapshot.records);
    final filters = const [
      'All',
      'Action',
      'Deadline',
      'Product',
      'Grant',
      'IP / Asset',
      'Evidence',
    ];

    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Index Explorer',
          body:
              'Search the generated company indexes by title, label, or source path.',
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InlineTag(
                  label: 'Generated ${snapshot.generatedAt.toLocal()}',
                  accent: AppColours.darkSecondary,
                  foreground: AppColours.darkText,
                ),
                _InlineTag(
                  label: snapshot.sourceExists
                      ? 'Source available'
                      : 'Source missing',
                  accent: snapshot.sourceExists
                      ? AppColours.darkSuccess
                      : AppColours.darkAmber,
                  foreground: AppColours.darkText,
                ),
                _InlineTag(
                  label: '${snapshot.sourceMarkdownCount} markdown files',
                  accent: AppColours.darkSecondary,
                  foreground: AppColours.darkText,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Search indexes',
                hintText: 'Search title, source path, label, or due date',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filters
                  .map(
                    (filter) => ChoiceChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (_) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 14),
            _IndexSummaryRow(records: snapshot.records),
            const SizedBox(height: 14),
            _IndexExplorerTable(records: records),
          ],
        ),
      ],
    );
  }

  List<CompanyCommandCentreMarkdownRecord> _filteredRecords(
    List<CompanyCommandCentreMarkdownRecord> records,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    return records
        .where((record) {
          final matchesQuery =
              query.isEmpty ||
              record.title.toLowerCase().contains(query) ||
              record.relativePath.toLowerCase().contains(query) ||
              record.labels.any(
                (label) => label.toLowerCase().contains(query),
              ) ||
              record.dueDates.any((date) => date.contains(query));

          final matchesFilter = switch (_selectedFilter) {
            'Action' => record.checkboxCount > 0,
            'Deadline' => record.dueDates.isNotEmpty,
            'Product' => record.labels.contains('product'),
            'Grant' => record.labels.contains('grant'),
            'IP / Asset' => record.labels.contains('ip_asset'),
            'Evidence' => record.isEvidence,
            _ => true,
          };

          return matchesQuery && matchesFilter;
        })
        .toList(growable: false);
  }
}

class _IndexSummaryRow extends StatelessWidget {
  const _IndexSummaryRow({required this.records});

  final List<CompanyCommandCentreMarkdownRecord> records;

  @override
  Widget build(BuildContext context) {
    final actionCount = records
        .where((record) => record.checkboxCount > 0)
        .length;
    final deadlineCount = records
        .where((record) => record.dueDates.isNotEmpty)
        .length;
    final productCount = records
        .where((record) => record.labels.contains('product'))
        .length;
    final grantCount = records
        .where((record) => record.labels.contains('grant'))
        .length;
    final ipAssetCount = records
        .where((record) => record.labels.contains('ip_asset'))
        .length;
    final evidenceCount = records.where((record) => record.isEvidence).length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _InlineTag(
          label: '$actionCount action files',
          accent: AppColours.darkSuccess,
          foreground: AppColours.darkText,
        ),
        _InlineTag(
          label: '$deadlineCount deadline files',
          accent: AppColours.darkAmber,
          foreground: AppColours.darkText,
        ),
        _InlineTag(
          label: '$productCount product files',
          accent: AppColours.darkSecondary,
          foreground: AppColours.darkText,
        ),
        _InlineTag(
          label: '$grantCount grant files',
          accent: AppColours.darkPurple,
          foreground: AppColours.darkText,
        ),
        _InlineTag(
          label: '$ipAssetCount IP / asset files',
          accent: AppColours.darkGlow,
          foreground: AppColours.darkText,
        ),
        _InlineTag(
          label: '$evidenceCount evidence files',
          accent: AppColours.darkSecondary,
          foreground: AppColours.darkText,
        ),
      ],
    );
  }
}

class _IndexExplorerTable extends StatelessWidget {
  const _IndexExplorerTable({required this.records});

  final List<CompanyCommandCentreMarkdownRecord> records;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (records.isEmpty) {
      return Text(
        'No records match the current search or filter.',
        style: theme.textTheme.bodyMedium,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 44,
          dataRowMinHeight: 56,
          dataRowMaxHeight: 96,
          columns: const [
            DataColumn(label: Text('Title')),
            DataColumn(label: Text('Labels')),
            DataColumn(label: Text('Due dates')),
            DataColumn(label: Text('Source file')),
          ],
          rows: records
              .map(
                (record) => DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 260,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(record.title),
                            const SizedBox(height: 4),
                            Text(
                              record.excerpt,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColours.darkMutedText,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 280,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: record.labels
                              .map(
                                (label) => _InlineTag(
                                  label: label,
                                  accent: _labelAccent(label),
                                  foreground: AppColours.darkText,
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 160,
                        child: Text(
                          record.dueDates.isEmpty
                              ? '-'
                              : record.dueDates.join(', '),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(width: 340, child: Text(record.relativePath)),
                    ),
                  ],
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }

  Color _labelAccent(String label) {
    switch (label) {
      case 'action':
        return AppColours.darkSuccess;
      case 'deadline':
        return AppColours.darkAmber;
      case 'product':
        return AppColours.darkSecondary;
      case 'grant':
        return AppColours.darkPurple;
      case 'ip_asset':
        return AppColours.darkGlow;
      case 'evidence':
        return AppColours.darkPrimary;
      default:
        return AppColours.darkSecondary;
    }
  }
}

class _PartnershipsTab extends StatelessWidget {
  const _PartnershipsTab();

  @override
  Widget build(BuildContext context) {
    final items = _partnershipTrackerItems;
    final planned = items.where((item) => item.status == 'Planned').length;
    final drafting = items.where((item) => item.status == 'Drafting').length;
    final ready = items.where((item) => item.status == 'Ready').length;

    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Partnerships',
          body:
              'Source-linked tracker for the grants and partnerships page noted in the website next steps.',
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _CompanyAssetMetric(label: 'Planned', value: '$planned'),
                _CompanyAssetMetric(label: 'Drafting', value: '$drafting'),
                _CompanyAssetMetric(label: 'Ready', value: '$ready'),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _InlineTag(
                  label: 'Website next steps',
                  accent: AppColours.darkSecondary,
                  foreground: AppColours.darkText,
                ),
                _InlineTag(
                  label: 'Module spec',
                  accent: AppColours.darkSecondary,
                  foreground: AppColours.darkText,
                ),
                _InlineTag(
                  label: 'Read only',
                  accent: AppColours.darkSuccess,
                  foreground: AppColours.darkText,
                ),
              ],
            ),
          ],
        ),
        _TrackerSectionCard(title: 'Partnership tracker', items: items),
      ],
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

const List<String> _tabs = [
  'Overview',
  'Compliance & Deadlines',
  'Finance Snapshot',
  'Website & Brand',
  'LinkedIn & Marketing',
  'Product Portfolio',
  'IP & Asset Register',
  'Grants Pipeline',
  'Index Explorer',
  'Partnerships',
  'Evidence Library',
  'Director Action Board',
  'Settings',
];
const List<_ChecklistItem> _complianceChecklistItems = [
  _ChecklistItem(
    item: 'Companies House account available',
    authority: 'Company records',
    dueDate: 'Ongoing',
    status: 'Tracked',
    notes: 'Core registry access stays visible in the local admin trail.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Authentication code stored securely',
    authority: 'Company records',
    dueDate: 'Ongoing',
    status: 'Tracked',
    notes: 'Sensitive filing access is kept ready for recovery and follow-up.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Certificate of incorporation saved',
    authority: 'Company records',
    dueDate: 'Ongoing',
    status: 'Tracked',
    notes: 'Formation paperwork remains easy to find.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Articles of association saved',
    authority: 'Company records',
    dueDate: 'Ongoing',
    status: 'Tracked',
    notes: 'Foundational company rules stay in the local record.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Shareholder/director records saved',
    authority: 'Company records',
    dueDate: 'Ongoing',
    status: 'Tracked',
    notes: 'Ownership and director details stay available for admin checks.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Registered office details saved',
    authority: 'Company records',
    dueDate: 'Ongoing',
    status: 'Tracked',
    notes: 'Registered office history remains part of the local record.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Tide account active',
    authority: 'Banking',
    dueDate: 'Ongoing',
    status: 'Tracked',
    notes: 'Banking setup is tracked in the finance snapshot tab.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Debit card received/activated',
    authority: 'Banking',
    dueDate: 'Ongoing',
    status: 'Tracked',
    notes: 'Card handling stays visible until the banking flow is settled.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Bank details saved securely',
    authority: 'Banking',
    dueDate: 'Ongoing',
    status: 'Tracked',
    notes: 'Bank details are kept in the local company record.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Business-only spending rule followed',
    authority: 'Banking',
    dueDate: 'Ongoing',
    status: 'Tracked',
    notes: 'Company spending stays separate and easy to audit.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Corporation Tax activation reviewed',
    authority: 'Tax/admin',
    dueDate: 'Review soon',
    status: 'Review',
    notes: 'Tax setup is tracked before it becomes urgent.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Bookkeeping process chosen',
    authority: 'Tax/admin',
    dueDate: 'Review soon',
    status: 'Drafting',
    notes: 'The bookkeeping path should stay simple and repeatable.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Receipt capture process created',
    authority: 'Tax/admin',
    dueDate: 'Review soon',
    status: 'Drafting',
    notes: 'Receipt capture is the first step before automation later.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Accountant shortlist created',
    authority: 'Tax/admin',
    dueDate: 'Review soon',
    status: 'Planned',
    notes: 'Keep a short list ready for later finance support.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'PAYE reviewed if paying salary',
    authority: 'Tax/admin',
    dueDate: 'When needed',
    status: 'Planned',
    notes: 'Only activate PAYE when salary plans make it relevant.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'VAT reviewed when revenue grows or strategically useful',
    authority: 'Tax/admin',
    dueDate: 'When needed',
    status: 'Planned',
    notes: 'VAT should stay a staged decision, not a rush job.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Website live',
    authority: 'Public presence',
    dueDate: 'Launch',
    status: 'Planned',
    notes: 'Public presence work stays aligned with the website plan.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Company email live',
    authority: 'Public presence',
    dueDate: 'Launch',
    status: 'Planned',
    notes: 'Use a company email before public release is widened.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'LinkedIn profile updated',
    authority: 'Public presence',
    dueDate: 'Launch',
    status: 'Drafting',
    notes: 'Founder profile and company presence should stay aligned.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'LinkedIn company page created',
    authority: 'Public presence',
    dueDate: 'Launch',
    status: 'Planned',
    notes: 'Create the company page once the public identity is ready.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    item: 'Product pages drafted',
    authority: 'Public presence',
    dueDate: 'Launch',
    status: 'Drafting',
    notes: 'Keep product pages aligned with the product portfolio tracker.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
];

const List<_TrackerItem> _websiteTrackerItems = [
  _TrackerItem(
    section: 'Website',
    item: 'Add company identity to homepage',
    status: 'Drafting',
    notes:
        'Surface the legal name and founder identity clearly on the landing page.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Create Technologies page',
    status: 'Planned',
    notes: 'Reserve a calm page for the company technology overview.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Create Products page',
    status: 'Planned',
    notes: 'List the product family in one clear place.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Create Projects/build log page',
    status: 'Planned',
    notes: 'Use this for progress notes and visible build momentum.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Create Grants & Partnerships page',
    status: 'Planned',
    notes: 'Provide a single destination for opportunities and collaborators.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Add MicroGrow product page',
    status: 'Planned',
    notes: 'Draft the first product-specific page for MicroGrow.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Add BioCalm product page',
    status: 'Planned',
    notes: 'Reserve a product page for the BioCalm concept.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Add Omega Dashboard product page',
    status: 'Planned',
    notes:
        'Keep the dashboard product visible for future customers and partners.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Add company contact form subjects',
    status: 'Drafting',
    notes: 'Define the calm subject options before the form goes live.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Add LinkedIn company page link',
    status: 'Ready',
    notes: 'This can point straight at the new LinkedIn company profile.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Website',
    item: 'Add professional footer with company name and company number',
    status: 'Drafting',
    notes: 'Keep the legal footer visible and consistent across pages.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
];

const List<_TrackerItem> _financeTrackerItems = [
  _TrackerItem(
    section: 'Finance',
    item: 'Confirm bank account details',
    status: 'Tracked',
    notes: 'Keep the active bank reference visible in the finance snapshot.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/mock/company_overview.json',
  ),
  _TrackerItem(
    section: 'Finance',
    item: 'Choose bookkeeping process',
    status: 'Drafting',
    notes: 'Decide the simplest repeatable bookkeeping route.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _TrackerItem(
    section: 'Finance',
    item: 'Create receipt capture routine',
    status: 'Drafting',
    notes: 'Receipt capture should be simple before any automation is added.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _TrackerItem(
    section: 'Finance',
    item: 'Review monthly reconciliation',
    status: 'Planned',
    notes: 'Use the monthly review to keep the books calm and up to date.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _TrackerItem(
    section: 'Finance',
    item: 'Shortlist accountant',
    status: 'Planned',
    notes: 'Keep a shortlist ready for when external help is needed.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _TrackerItem(
    section: 'Finance',
    item: 'Review VAT / PAYE timing',
    status: 'Review',
    notes:
        'Only step into VAT or PAYE when the company situation makes it useful.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
];

const List<_TrackerItem> _linkedinTrackerItems = [
  _TrackerItem(
    section: 'Profile',
    item: 'Update personal headline',
    status: 'Drafting',
    notes: 'Keep the profile headline clear and founder-focused.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
  ),
  _TrackerItem(
    section: 'Profile',
    item: 'Add Founder & Director role',
    status: 'Planned',
    notes: 'Make the public role reflect the company position accurately.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
  ),
  _TrackerItem(
    section: 'Company Page',
    item: 'Create New Earth Advanced Technologies Ltd company page',
    status: 'Planned',
    notes: 'Create the official company page before launch content starts.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
  ),
  _TrackerItem(
    section: 'Company Page',
    item: 'Upload banner',
    status: 'Planned',
    notes: 'Use the banner to keep the page visually aligned with the website.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
  ),
  _TrackerItem(
    section: 'Company Page',
    item: 'Add website link',
    status: 'Ready',
    notes: 'Link the public profile back to the website once the page exists.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
  ),
  _TrackerItem(
    section: 'Content Rhythm',
    item: 'Create weekly engineering update rhythm',
    status: 'Drafting',
    notes: 'Keep the cadence steady and low pressure.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
  ),
  _TrackerItem(
    section: 'Content Rhythm',
    item: 'Pin MicroGrow/BioCalm/Omega posts',
    status: 'Planned',
    notes:
        'Pin the most representative posts once the launch content is ready.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
  ),
  _TrackerItem(
    section: 'Launch Tasks',
    item: 'Publish company launch post',
    status: 'Ready',
    notes: 'Draft the first launch update when the company page is live.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
  ),
];

const List<_TrackerItem> _partnershipTrackerItems = [
  _TrackerItem(
    section: 'Planning',
    item: 'Create Grants & Partnerships page shell',
    status: 'Planned',
    notes:
        'Turn the website next step into a calm, source-linked tracking page.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
  ),
  _TrackerItem(
    section: 'Planning',
    item: 'List priority partner types',
    status: 'Drafting',
    notes: 'Keep the first partner map small and easy to review.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/MODULE_SPEC.md',
  ),
  _TrackerItem(
    section: 'Outreach',
    item: 'Draft partner intro pack',
    status: 'Drafting',
    notes:
        'Use the company and capability templates to keep outreach consistent.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/templates/capability_statement_template.md',
  ),
  _TrackerItem(
    section: 'Evidence',
    item: 'Link partner evidence files',
    status: 'Ready',
    notes: 'Attach the supporting documents once partnerships start moving.',
    sourceFile:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/MODULE_SPEC.md',
  ),
];
