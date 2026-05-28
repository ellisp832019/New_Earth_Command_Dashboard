import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/routing/route_names.dart';
import '../../assets/application/asset_treasury_links_controller.dart';
import '../application/treasury_monthly_summary_controller.dart';
import '../data/treasury_folder_service.dart';

class TreasuryMonthlySummaryScreen extends ConsumerWidget {
  const TreasuryMonthlySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(treasuryMonthlySummaryProvider);

    return summaryAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Monthly Summary'),
          leading: IconButton(
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(RouteNames.treasury),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: _SummaryErrorCard(
          message:
              'Treasury could not load the monthly summary right now. Please reload and try again.',
          onReload: () => ref.invalidate(treasuryMonthlySummaryProvider),
        ),
      ),
      data: (summary) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Monthly Summary'),
            leading: IconButton(
              onPressed: () => context.canPop()
                  ? context.pop()
                  : context.go(RouteNames.treasury),
              icon: const Icon(Icons.arrow_back),
            ),
            actions: [
              IconButton(
                onPressed: () => ref.invalidate(treasuryMonthlySummaryProvider),
                icon: const Icon(Icons.refresh),
                tooltip: 'Reload summary',
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _MonthlySummaryHeroCard(summary: summary),
                const SizedBox(height: 16),
                if (!summary.workspace.isReady) ...[
                  _SummarySetupNoticeCard(summary: summary),
                  const SizedBox(height: 16),
                ],
                _MonthlyOverviewGrid(summary: summary),
                const SizedBox(height: 16),
                _ProjectSpendSummaryCard(summary: summary),
                const SizedBox(height: 16),
                const _AssetLinkSummaryCard(),
                const SizedBox(height: 16),
                _SubscriptionSummaryCard(summary: summary),
                const SizedBox(height: 16),
                _DecisionSummaryCard(summary: summary),
                const SizedBox(height: 16),
                _WeeklyReviewSummaryCard(summary: summary),
                const SizedBox(height: 16),
                _SummaryFooterCard(summary: summary),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MonthlySummaryHeroCard extends StatelessWidget {
  const _MonthlySummaryHeroCard({required this.summary});

  final TreasuryMonthlySummarySnapshot summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pathLabel = summary.workspace.financeRootPath ?? 'Not linked yet';
    final generatedLabel = DateFormat(
      'EEEE, d MMMM y',
    ).format(summary.generatedAt);
    final moneyFormatter = NumberFormat.currency(symbol: '£', decimalDigits: 2);

    return Container(
      decoration: _cardDecoration(highlighted: true),
      padding: const EdgeInsets.all(22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useWideLayout = constraints.maxWidth >= 900;

          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Summary',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'A calm monthly read of Treasury so Hayley can see the shape of the money without opening every tracker.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StatusPill(
                    label: summary.workspace.isReady
                        ? 'Folder connected'
                        : 'Setup needed',
                    accent: summary.workspace.isReady
                        ? AppColours.darkSuccess
                        : AppColours.darkAmber,
                  ),
                  _StatusPill(
                    label: generatedLabel,
                    accent: AppColours.darkSecondary,
                  ),
                  _StatusPill(label: pathLabel, accent: AppColours.darkPrimary),
                ],
              ),
            ],
          );

          final right = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroMetricCard(
                label: 'Project spend',
                value: moneyFormatter.format(summary.projectSpendTotal),
                note: 'Tracked across the current project spend CSV.',
                accent: AppColours.darkPurple,
              ),
              const SizedBox(height: 12),
              _HeroMetricCard(
                label: 'Recurring costs',
                value: moneyFormatter.format(summary.subscriptionTotal),
                note: 'Sum of the subscription tracker entries.',
                accent: AppColours.darkAccent,
              ),
              const SizedBox(height: 12),
              _HeroMetricCard(
                label: 'Treasury rhythm',
                value: summary.weeklyReviewDate ?? 'No weekly review date yet',
                note: summary.weeklyReviewNote?.isNotEmpty == true
                    ? summary.weeklyReviewNote!
                    : 'The latest weekly note will appear here after the ritual is saved.',
                accent: AppColours.darkSecondary,
              ),
            ],
          );

          if (!useWideLayout) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [left, const SizedBox(height: 20), right],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: 20),
              SizedBox(width: 380, child: right),
            ],
          );
        },
      ),
    );
  }
}

class _MonthlyOverviewGrid extends StatelessWidget {
  const _MonthlyOverviewGrid({required this.summary});

  final TreasuryMonthlySummarySnapshot summary;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryMetricCard(
        title: 'Safe',
        value: summary.workspace.stateSummaries
            .firstWhere((summary) => summary.kind == TreasuryStatusKind.safe)
            .count
            .toString(),
        note: 'Clear enough to move ahead.',
        accent: AppColours.darkSuccess,
      ),
      _SummaryMetricCard(
        title: 'Watch',
        value: summary.workspace.stateSummaries
            .firstWhere((summary) => summary.kind == TreasuryStatusKind.watch)
            .count
            .toString(),
        note: 'Worth checking again soon.',
        accent: AppColours.darkAmber,
      ),
      _SummaryMetricCard(
        title: 'Pause',
        value: summary.workspace.stateSummaries
            .firstWhere((summary) => summary.kind == TreasuryStatusKind.pause)
            .count
            .toString(),
        note: 'Hold before spending.',
        accent: const Color(0xFFE26B6B),
      ),
      _SummaryMetricCard(
        title: 'Decision',
        value: summary.workspace.stateSummaries
            .firstWhere(
              (summary) => summary.kind == TreasuryStatusKind.decision,
            )
            .count
            .toString(),
        note: 'Waiting for a clear choice.',
        accent: AppColours.darkSecondary,
      ),
      _SummaryMetricCard(
        title: 'Receipts to sort',
        value: summary.workspace.receiptsToSortCount.toString(),
        note: 'Still waiting in the external pack.',
        accent: AppColours.darkAccent,
      ),
      _SummaryMetricCard(
        title: 'Decisions',
        value: summary.recentDecisions.length.toString(),
        note: 'Recent entries in the register.',
        accent: AppColours.darkPurple,
      ),
    ];

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.view_comfy_alt_outlined,
            title: 'At a glance',
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 1280
                  ? 3
                  : constraints.maxWidth >= 860
                  ? 2
                  : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: crossAxisCount == 1 ? 2.6 : 2.0,
                ),
                itemBuilder: (context, index) => cards[index],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProjectSpendSummaryCard extends StatelessWidget {
  const _ProjectSpendSummaryCard({required this.summary});

  final TreasuryMonthlySummarySnapshot summary;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Project spend',
      icon: Icons.work_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top projects',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (summary.topProjectSpends.isEmpty)
            Text(
              'No project spend rows have been logged yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.4,
              ),
            )
          else
            ...summary.topProjectSpends.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.project,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColours.darkText,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.entries} entries',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColours.darkMutedText),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      NumberFormat.currency(
                        symbol: '£',
                        decimalDigits: 2,
                      ).format(item.total),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColours.darkSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Divider(height: 24),
          Text(
            'Recent project spend lines',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (summary.recentProjectSpendEntries.isEmpty)
            Text(
              'Recent spend entries will appear here after the next save.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.4,
              ),
            )
          else
            ...summary.recentProjectSpendEntries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DetailRow(
                  title: '${entry.project} · ${entry.item}',
                  subtitle:
                      '${entry.date} · ${entry.category.isEmpty ? 'Uncategorised' : entry.category}',
                  trailing: entry.amount,
                  note:
                      '${entry.status.isEmpty ? 'Status pending' : entry.status}${entry.receiptSaved.isNotEmpty ? ' · receipt ${entry.receiptSaved}' : ''}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AssetLinkSummaryCard extends ConsumerWidget {
  const _AssetLinkSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(assetTreasuryLinkSummaryProvider);

    return summaryAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => _SectionCard(
        title: 'Asset links',
        icon: Icons.link_outlined,
        child: Text(
          'Asset links could not load right now.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.4,
              ),
        ),
      ),
      data: (summary) {
        final moneyFormatter = NumberFormat.currency(
          symbol: '£',
          decimalDigits: 2,
        );

        return _SectionCard(
          title: 'Asset links',
          icon: Icons.link_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Treasury only sees the link summary here. The item records stay in Assets, and the finance IDs keep the handoff tidy.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkMutedText,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 860;
                  final cards = [
                    _SummaryMetricCard(
                      title: 'Receipts missing',
                      value: summary.receiptsMissingCount.toString(),
                      note: 'Items that still need a receipt link.',
                      accent: AppColours.darkAmber,
                    ),
                    _SummaryMetricCard(
                      title: 'Purchase cost',
                      value: moneyFormatter.format(summary.purchaseCostTotal),
                      note: 'Equipment spend recorded in Assets.',
                      accent: AppColours.darkSecondary,
                    ),
                    _SummaryMetricCard(
                      title: 'Reorder estimate',
                      value: moneyFormatter.format(summary.reorderEstimatedSpend),
                      note: 'Low stock items that may need spending.',
                      accent: AppColours.darkSuccess,
                    ),
                    _SummaryMetricCard(
                      title: 'Linked finance IDs',
                      value: summary.linkedFinanceIdCount.toString(),
                      note: 'Order and maintenance records with IDs.',
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
                      for (var index = 0; index < cards.length; index++) ...[
                        cards[index],
                        if (index != cards.length - 1) const SizedBox(height: 12),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Broken equipment value at risk: ${moneyFormatter.format(summary.repairReplacementValueTotal)} across ${summary.brokenEquipmentCount} item${summary.brokenEquipmentCount == 1 ? '' : 's'}.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColours.darkMutedText,
                      height: 1.35,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SubscriptionSummaryCard extends StatelessWidget {
  const _SubscriptionSummaryCard({required this.summary});

  final TreasuryMonthlySummarySnapshot summary;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Recurring costs',
      icon: Icons.subscriptions_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summary.upcomingSubscriptions.isEmpty)
            Text(
              'No subscription rows have been logged yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.4,
              ),
            )
          else
            ...summary.upcomingSubscriptions.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DetailRow(
                  title: entry.serviceName.isEmpty
                      ? 'Unnamed service'
                      : entry.serviceName,
                  subtitle:
                      '${entry.renewalDate.isEmpty ? 'No renewal date' : entry.renewalDate} · ${entry.paymentSource.isEmpty ? 'No payment source' : entry.paymentSource}',
                  trailing: entry.cost,
                  note:
                      '${entry.status.isEmpty ? 'Status pending' : entry.status}${entry.keepCancelReview.isNotEmpty ? ' · ${entry.keepCancelReview}' : ''}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DecisionSummaryCard extends StatelessWidget {
  const _DecisionSummaryCard({required this.summary});

  final TreasuryMonthlySummarySnapshot summary;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Decisions register',
      icon: Icons.gavel_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summary.recentDecisions.isEmpty)
            Text(
              'The decisions register is waiting for the first calm entry.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.4,
              ),
            )
          else
            ...summary.recentDecisions.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DetailRow(
                  title: entry.decisionNeeded,
                  subtitle: '${entry.date} · ${entry.owner}',
                  trailing: entry.amount,
                  note:
                      '${entry.status.isEmpty ? 'No status' : entry.status}${entry.decision.isNotEmpty ? ' · ${entry.decision}' : ''}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeeklyReviewSummaryCard extends StatelessWidget {
  const _WeeklyReviewSummaryCard({required this.summary});

  final TreasuryMonthlySummarySnapshot summary;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Weekly rhythm',
      icon: Icons.auto_awesome_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
            title: summary.weeklyReviewDate ?? 'No weekly review saved yet',
            subtitle: 'Latest ritual snapshot',
            trailing: summary.workspace.stateSummaries
                .firstWhere(
                  (summary) => summary.kind == TreasuryStatusKind.decision,
                )
                .count
                .toString(),
            note: summary.weeklyReviewNote?.isNotEmpty == true
                ? summary.weeklyReviewNote!
                : 'The weekly note will appear here after the ritual is saved.',
          ),
        ],
      ),
    );
  }
}

class _SummaryFooterCard extends StatelessWidget {
  const _SummaryFooterCard({required this.summary});

  final TreasuryMonthlySummarySnapshot summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.info_outline,
            title: 'Notes and guidance',
          ),
          const SizedBox(height: 12),
          Text(
            summary.workspace.guidanceNote,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.45,
            ),
          ),
          if (summary.issues.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...summary.issues.map(
              (issue) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.radio_button_unchecked,
                      size: 18,
                      color: AppColours.darkAmber,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        issue,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColours.darkText,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummarySetupNoticeCard extends StatelessWidget {
  const _SummarySetupNoticeCard({required this.summary});

  final TreasuryMonthlySummarySnapshot summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.build_outlined,
            title: 'Setup still needs attention',
          ),
          const SizedBox(height: 12),
          Text(
            summary.workspace.issues.isEmpty
                ? 'Treasury is waiting for the external finance folder to be linked.'
                : summary.workspace.issues.join('\n'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'The summary stays available, but the full picture will be cleaner once the setup wizard has finished.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryErrorCard extends StatelessWidget {
  const _SummaryErrorCard({required this.message, required this.onReload});

  final String message;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.info_outline,
                title: 'Monthly summary',
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: icon, title: title),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SummaryMetricCard extends StatelessWidget {
  const _SummaryMetricCard({
    required this.title,
    required this.value,
    required this.note,
    required this.accent,
  });

  final String title;
  final String value;
  final String note;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.note,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  note,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            trailing,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.26)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HeroMetricCard extends StatelessWidget {
  const _HeroMetricCard({
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
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.9),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
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

BoxDecoration _cardDecoration({bool highlighted = false}) {
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
