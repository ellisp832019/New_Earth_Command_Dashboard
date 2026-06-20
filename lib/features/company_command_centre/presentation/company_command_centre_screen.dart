import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
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
                      const _SimplePlaceholderTab(
                        title: 'IP & Asset Register',
                        body:
                            'Read-only placeholder for the IP register and asset ledger.',
                        chips: [
                          'Assets',
                          'IP',
                          'Read only',
                        ],
                      ),
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
                      const _SimplePlaceholderTab(
                        title: 'Evidence Library',
                        body:
                            'Read-only placeholder for source files, exports, and supporting evidence.',
                        chips: [
                          'Evidence',
                          'Source files',
                          'Read only',
                        ],
                      ),
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
          children: _complianceChecklistItems
              .map((item) => _ChecklistItemCard(item: item))
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
            const SizedBox(height: 10),
            ..._websiteNextSteps
                .map((item) => _ChecklistBulletCard(item: item))
                .toList(growable: false),
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
            const SizedBox(height: 10),
            ..._linkedinNextSteps
                .map((item) => _ChecklistBulletCard(item: item))
                .toList(growable: false),
            const SizedBox(height: 10),
            Text(
              'Marketing actions from the director board',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...marketingActions.map((item) => _ActionLine(item: item)),
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

    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: 'Director action board',
          body: 'Simple lane view for the next practical company moves.',
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: lanes.entries
                  .map(
                    (entry) => SizedBox(
                      width: 250,
                      child: Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.key, style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 8),
                              ...entry.value.map((item) => _ActionLine(item: item)),
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
          Text("${item.area} - ${item.priority}"),
        ],
      ),
    );
  }
}

class _SimpleChecklistRow extends StatelessWidget {
  const _SimpleChecklistRow({
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item, style: Theme.of(context).textTheme.titleSmall),
                ),
                Chip(label: Text(status)),
              ],
            ),
            const SizedBox(height: 6),
            Text(authority),
            Text('Due: $dueDate'),
            const SizedBox(height: 6),
            Text(notes),
            const SizedBox(height: 6),
            Text('Source: $sourceFile'),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItem {
  const _ChecklistItem({
    required this.title,
    required this.status,
    required this.detail,
    required this.source,
  });

  final String title;
  final String status;
  final String detail;
  final String source;
}

class _ChecklistItemCard extends StatelessWidget {
  const _ChecklistItemCard({required this.item});

  final _ChecklistItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Chip(label: Text(item.status)),
              ],
            ),
            const SizedBox(height: 6),
            Text(item.detail),
            const SizedBox(height: 6),
            Text('Source: ${item.source}'),
          ],
        ),
      ),
    );
  }
}

class _ChecklistBulletCard extends StatelessWidget {
  const _ChecklistBulletCard({required this.item});

  final String item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(item)),
        ],
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

class _SimplePlaceholderTab extends StatelessWidget {
  const _SimplePlaceholderTab({
    required this.title,
    required this.body,
    required this.chips,
  });

  final String title;
  final String body;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return _SectionScrollView(
      children: [
        _CalmSectionCard(
          title: title,
          body: body,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips.map((chip) => Chip(label: Text(chip))).toList(),
            ),
          ],
        ),
      ],
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
    title: 'Companies House account available',
    status: 'Tracked',
    detail: 'Company records are being kept in the admin trail.',
    source: 'UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    title: 'Authentication code stored securely',
    status: 'Tracked',
    detail: 'Sensitive registration access stays noted for future recovery.',
    source: 'UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    title: 'Certificate of incorporation saved',
    status: 'Tracked',
    detail: 'Core formation documents stay visible in the company record set.',
    source: 'UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    title: 'Articles of association saved',
    status: 'Tracked',
    detail: 'Foundational company documents are listed for review.',
    source: 'UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    title: 'Registered office details saved',
    status: 'Tracked',
    detail: 'Registered office history remains part of the local record.',
    source: 'UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
  _ChecklistItem(
    title: 'Tide account active',
    status: 'Finance',
    detail: 'Banking setup is tracked in the finance snapshot tab.',
    source: 'UK_COMPANY_ADMIN_CHECKLIST.md',
  ),
];

const List<String> _websiteNextSteps = [
  'Add company identity to homepage',
  'Create Technologies page',
  'Create Products page',
  'Create Projects/build log page',
  'Create Grants & Partnerships page',
  'Add MicroGrow product page',
  'Add BioCalm product page',
  'Add Omega Dashboard product page',
  'Add company contact form subjects',
  'Add LinkedIn company page link',
  'Add professional footer with company name and company number',
];

const List<String> _linkedinNextSteps = [
  'Update personal headline',
  'Add Founder & Director role',
  'Create New Earth Advanced Technologies Ltd company page',
  'Upload banner',
  'Add website link',
  'Pin MicroGrow/BioCalm/Omega posts',
  'Publish company launch post',
  'Create weekly engineering update rhythm',
];

