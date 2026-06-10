import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/routing/route_names.dart';
import '../application/treasury_monthly_summary_controller.dart';
import '../../../core/widgets/folder_bootstrap_wizard.dart';
import '../application/treasury_controller.dart';
import '../application/treasury_wizard_draft_controller.dart';
import '../data/treasury_folder_service.dart';
import '../data/treasury_wizard_flow.dart';

const _treasuryUnavailableSnapshot = TreasuryWorkspaceSnapshot(
  configPath: 'config/local_paths.json',
  financeRootPath: null,
  isReady: false,
  issues: <String>['Treasury could not be loaded right now.'],
  requiredFolders: TreasuryFolderService.requiredFolders,
  missingFolders: <String>[],
  missingFiles: <String>[],
  stateSummaries: <TreasuryStateSummary>[],
  receiptsToSortCount: 0,
  weeklyRitualSteps: TreasuryFolderService.weeklyRitualSteps,
  lowEnergySteps: TreasuryFolderService.lowEnergySteps,
  guidanceNote:
      'The Treasury area is waiting for the external Omega OS folder.',
);

class TreasuryScreen extends ConsumerWidget {
  const TreasuryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(treasuryWorkspaceProvider);

    return snapshot.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => _TreasurySetupScreen(
        title: 'Treasury needs a calm setup',
        body:
            'The Treasury folder could not be loaded right now. Check the local path and try again.',
        snapshot: _treasuryUnavailableSnapshot,
        onReload: () => ref.invalidate(treasuryWorkspaceProvider),
        onBack: () {
          if (context.canPop()) {
            context.pop();
            return;
          }

          context.go(RouteNames.dashboard);
        },
        onOpenSetupWizard: () =>
            _openSetupWizard(context, ref, _treasuryUnavailableSnapshot),
      ),
      data: (data) {
        if (!data.isReady) {
          return _TreasurySetupScreen(
            title: 'Treasury setup',
            body:
                'Hayley can use Treasury once the external Omega OS finance folder is linked and healthy.',
            snapshot: data,
            onReload: () => ref.invalidate(treasuryWorkspaceProvider),
            onBack: () {
              if (context.canPop()) {
                context.pop();
                return;
              }

              context.go(RouteNames.dashboard);
            },
            onOpenSetupWizard: () => _openSetupWizard(context, ref, data),
          );
        }

        return _TreasuryHomeScreen(
          snapshot: data,
          onReload: () => ref.invalidate(treasuryWorkspaceProvider),
        );
      },
    );
  }
}

class _TreasuryHomeScreen extends StatelessWidget {
  const _TreasuryHomeScreen({required this.snapshot, required this.onReload});

  final TreasuryWorkspaceSnapshot snapshot;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1060;
    final dateLabel = DateFormat('EEEE, d MMMM y').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            isWide ? 28 : 18,
            isWide ? 28 : 18,
            isWide ? 28 : 18,
            24,
          ),
          children: [
            _TreasuryHeroCard(
              snapshot: snapshot,
              dateLabel: dateLabel,
              onReload: onReload,
            ),
            const SizedBox(height: 18),
            const _WeeklyDraftStateCard(),
            const SizedBox(height: 18),
            const _TreasuryQuickActionsCard(),
            const SizedBox(height: 18),
            const _TreasuryEntryHubCard(),
            const SizedBox(height: 18),
            const _MonthlySummaryPreviewCard(),
            const SizedBox(height: 18),
            const _DecisionReviewCard(),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final useTwoColumns = constraints.maxWidth >= 960;

                final statusCards = snapshot.stateSummaries
                    .where(
                      (summary) =>
                          summary.kind == TreasuryStatusKind.safe ||
                          summary.kind == TreasuryStatusKind.watch ||
                          summary.kind == TreasuryStatusKind.pause ||
                          summary.kind == TreasuryStatusKind.decision,
                    )
                    .map((summary) => _TreasuryStateCard(summary: summary))
                    .toList();

                if (useTwoColumns) {
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: statusCards[0]),
                          const SizedBox(width: 14),
                          Expanded(child: statusCards[1]),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: statusCards[2]),
                          const SizedBox(width: 14),
                          Expanded(child: statusCards[3]),
                        ],
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    for (
                      var index = 0;
                      index < statusCards.length;
                      index++
                    ) ...[
                      statusCards[index],
                      if (index != statusCards.length - 1)
                        const SizedBox(height: 14),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final useTwoColumns = constraints.maxWidth >= 960;
                final cards = [
                  _ReceiptsCard(snapshot: snapshot),
                  _WeeklyRitualCard(snapshot: snapshot),
                ];

                if (useTwoColumns) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 14),
                      Expanded(child: cards[1]),
                    ],
                  );
                }

                return Column(
                  children: [cards[0], const SizedBox(height: 14), cards[1]],
                );
              },
            ),
            const SizedBox(height: 18),
            _TreasuryHealthCard(snapshot: snapshot, onReload: onReload),
            const SizedBox(height: 18),
            _TreasuryFooterCard(theme: theme, snapshot: snapshot),
          ],
        ),
      ),
    );
  }
}

class _TreasurySetupScreen extends StatelessWidget {
  const _TreasurySetupScreen({
    required this.title,
    required this.body,
    required this.snapshot,
    required this.onReload,
    required this.onBack,
    required this.onOpenSetupWizard,
  });

  final String title;
  final String body;
  final TreasuryWorkspaceSnapshot snapshot;
  final VoidCallback onReload;
  final VoidCallback onBack;
  final VoidCallback onOpenSetupWizard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SetupHeaderCard(
              title: title,
              body: body,
              onReload: onReload,
              onBack: onBack,
            ),
            const SizedBox(height: 14),
            _SetupIssuesCard(snapshot: snapshot),
            const SizedBox(height: 14),
            _SetupPathCard(snapshot: snapshot),
            const SizedBox(height: 14),
            _SetupFilesCard(snapshot: snapshot),
            const SizedBox(height: 14),
            _SetupStepsCard(
              theme: theme,
              snapshot: snapshot,
              onReload: onReload,
              onOpenSetupWizard: onOpenSetupWizard,
            ),
          ],
        ),
      ),
    );
  }
}

class _TreasuryHeroCard extends StatelessWidget {
  const _TreasuryHeroCard({
    required this.snapshot,
    required this.dateLabel,
    required this.onReload,
  });

  final TreasuryWorkspaceSnapshot snapshot;
  final String dateLabel;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final financeRoot = snapshot.financeRootPath ?? 'Not linked yet';
    final stateCounts = {
      for (final summary in snapshot.stateSummaries)
        summary.kind: summary.count,
    };

    return Container(
      decoration: _cardDecoration(highlighted: true),
      padding: const EdgeInsets.all(22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useWideLayout = constraints.maxWidth >= 880;

          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Treasury',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Hayley\'s Finance Centre',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColours.darkText,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  'A calm, local-first view of Safe / Watch / Pause / Decision so the money picture stays simple and kind.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StatusPill(
                    label: snapshot.isReady
                        ? 'Folder connected'
                        : 'Setup needed',
                    accent: snapshot.isReady
                        ? AppColours.darkSuccess
                        : AppColours.darkAmber,
                  ),
                  _StatusPill(
                    label: dateLabel,
                    accent: AppColours.darkSecondary,
                  ),
                  _StatusPill(
                    label: financeRoot,
                    accent: AppColours.darkPrimary,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusPill(
                    label: 'Safe ${stateCounts[TreasuryStatusKind.safe] ?? 0}',
                    accent: AppColours.darkSuccess,
                  ),
                  _StatusPill(
                    label:
                        'Watch ${stateCounts[TreasuryStatusKind.watch] ?? 0}',
                    accent: AppColours.darkAmber,
                  ),
                  _StatusPill(
                    label:
                        'Pause ${stateCounts[TreasuryStatusKind.pause] ?? 0}',
                    accent: const Color(0xFFE26B6B),
                  ),
                  _StatusPill(
                    label:
                        'Decision ${stateCounts[TreasuryStatusKind.decision] ?? 0}',
                    accent: AppColours.darkSecondary,
                  ),
                ],
              ),
            ],
          );

          final right = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroMetricCard(
                label: 'Receipts to Sort',
                value: '${snapshot.receiptsToSortCount}',
                note: 'Waiting in Omega OS, not inside the repo.',
                accent: AppColours.darkAmber,
              ),
              const SizedBox(height: 12),
              _HeroMetricCard(
                label: 'Source Folder',
                value: snapshot.financeRootPath ?? 'Unlinked',
                note:
                    'The app reads the external finance pack from local config.',
                accent: AppColours.darkSecondary,
              ),
              const SizedBox(height: 12),
              _HeroMetricCard(
                label: 'Config file',
                value: snapshot.configPath,
                note: 'Treasury reads the finance link from this local file.',
                accent: AppColours.darkPrimary,
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.end,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _showRitualPreview(
                        context,
                        title: 'Weekly ritual preview',
                        steps: snapshot.weeklyRitualSteps,
                      ),
                      icon: const Icon(Icons.view_agenda_outlined),
                      label: const Text('Weekly Ritual'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _showRitualPreview(
                        context,
                        title: 'Low-energy mode',
                        steps: snapshot.lowEnergySteps,
                        note:
                            'This is the short version for days when Hayley has less energy.',
                      ),
                      icon: const Icon(Icons.bolt_outlined),
                      label: const Text('Low-energy mode'),
                    ),
                    TextButton.icon(
                      onPressed: onReload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reload'),
                    ),
                  ],
                ),
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

class _TreasuryWizardEntry {
  const _TreasuryWizardEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.flow,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String flow;
  final Color accent;
}

class _TreasuryEntryHubCard extends StatelessWidget {
  const _TreasuryEntryHubCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final entries = [
      _TreasuryWizardEntry(
        title: 'Weekly Ritual',
        subtitle: 'Safe / Watch / Pause / Decision review',
        icon: Icons.auto_awesome_outlined,
        flow: 'weekly',
        accent: AppColours.darkSuccess,
      ),
      _TreasuryWizardEntry(
        title: 'Receipts',
        subtitle: 'Add a receipt or invoice in a calm flow',
        icon: Icons.receipt_long_outlined,
        flow: 'receipts',
        accent: AppColours.darkAmber,
      ),
      _TreasuryWizardEntry(
        title: 'Decisions',
        subtitle: 'Capture one choice that needs attention',
        icon: Icons.gavel_outlined,
        flow: 'decisions',
        accent: AppColours.darkSecondary,
      ),
      _TreasuryWizardEntry(
        title: 'Monthly Summary',
        subtitle: 'Review the bigger picture calmly',
        icon: Icons.assessment_outlined,
        flow: 'monthly_summary',
        accent: AppColours.darkPrimary,
      ),
      _TreasuryWizardEntry(
        title: 'Budget Pots',
        subtitle: 'Plan calm allocations and buffers',
        icon: Icons.account_balance_wallet_outlined,
        flow: 'budget_pots',
        accent: AppColours.darkSuccess,
      ),
      _TreasuryWizardEntry(
        title: 'Project Spend',
        subtitle: 'Log project money in a guided step flow',
        icon: Icons.work_outline,
        flow: 'project_spend',
        accent: AppColours.darkPurple,
      ),
      _TreasuryWizardEntry(
        title: 'Subscriptions',
        subtitle: 'Review recurring costs one by one',
        icon: Icons.subscriptions_outlined,
        flow: 'subscriptions',
        accent: AppColours.darkAccent,
      ),
    ];

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(icon: Icons.route_outlined, title: 'Start here'),
          const SizedBox(height: 10),
          Text(
            'Choose one guided flow. Hayley can stay in the front end the whole time.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 1280
                  ? 3
                  : constraints.maxWidth >= 760
                  ? 2
                  : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: crossAxisCount == 1 ? 2.8 : 1.55,
                ),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => entry.flow == 'decisions'
                        ? context.push(RouteNames.treasuryDecisions)
                        : entry.flow == 'monthly_summary'
                        ? context.push(RouteNames.treasuryMonthlySummary)
                        : entry.flow == 'budget_pots'
                        ? context.push(RouteNames.treasuryBudgetPots)
                        : context.push(
                            RouteNames.treasuryWizardFor(entry.flow),
                          ),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: entry.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: entry.accent.withValues(alpha: 0.24),
                        ),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(entry.icon, color: entry.accent),
                          const SizedBox(height: 10),
                          Text(
                            entry.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColours.darkText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry.subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColours.darkMutedText,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TreasuryQuickActionsCard extends StatelessWidget {
  const _TreasuryQuickActionsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.quickreply_outlined,
            title: 'Quick moves',
          ),
          const SizedBox(height: 10),
          Text(
            'These are the calm next places Hayley usually needs without having to scroll much.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                onPressed: () =>
                    context.push(RouteNames.treasuryMonthlySummary),
                icon: const Icon(Icons.assessment_outlined),
                label: const Text('Monthly Summary'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.push(RouteNames.treasuryBudgetPots),
                icon: const Icon(Icons.account_balance_wallet_outlined),
                label: const Text('Budget Pots overview'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.push(RouteNames.treasurySettings),
                icon: const Icon(Icons.tune_outlined),
                label: const Text('Settings'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.push(RouteNames.treasuryDecisions),
                icon: const Icon(Icons.gavel_outlined),
                label: const Text('Decisions'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthlySummaryPreviewCard extends ConsumerWidget {
  const _MonthlySummaryPreviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(treasuryMonthlySummaryProvider);
    final theme = Theme.of(context);

    return summaryAsync.when(
      loading: () => Container(
        decoration: _cardDecoration(),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircularProgressIndicator(strokeWidth: 2.5),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Preparing the monthly picture...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
      error: (error, stackTrace) => Container(
        decoration: _cardDecoration(),
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppColours.darkAmber),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'The monthly summary will appear once Treasury can read the external finance folder again.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
      data: (summary) {
        final currency = NumberFormat.currency(symbol: '£', decimalDigits: 2);
        final topProject = summary.topProjectSpends.isEmpty
            ? 'No project spend yet'
            : summary.topProjectSpends.first.project;

        return Container(
          decoration: _cardDecoration(highlighted: true),
          padding: const EdgeInsets.all(18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final useWideLayout = constraints.maxWidth >= 900;

              final left = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    icon: Icons.assessment_outlined,
                    title: 'Monthly picture',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'A calm monthly read of the bigger finance picture without opening the detailed screen.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkMutedText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    summary.workspace.isReady
                        ? 'Treasury is ready and the monthly summary is being read from the live finance pack.'
                        : 'Treasury can still show the monthly shape, but the setup state needs attention.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColours.darkMutedText,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _StatusPill(
                        label:
                            'Spend ${currency.format(summary.projectSpendTotal)}',
                        accent: AppColours.darkPurple,
                      ),
                      _StatusPill(
                        label:
                            'Recurring ${currency.format(summary.subscriptionTotal)}',
                        accent: AppColours.darkAccent,
                      ),
                      _StatusPill(
                        label: 'Top project $topProject',
                        accent: AppColours.darkSecondary,
                      ),
                      _StatusPill(
                        label:
                            'Recent decisions ${summary.recentDecisions.length}',
                        accent: AppColours.darkPurple,
                      ),
                    ],
                  ),
                ],
              );

              final right = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroMetricCard(
                    label: 'Safe / Watch / Pause / Decision',
                    value:
                        '${summary.workspace.stateSummaries.firstWhere((summary) => summary.kind == TreasuryStatusKind.safe).count} / '
                        '${summary.workspace.stateSummaries.firstWhere((summary) => summary.kind == TreasuryStatusKind.watch).count} / '
                        '${summary.workspace.stateSummaries.firstWhere((summary) => summary.kind == TreasuryStatusKind.pause).count} / '
                        '${summary.workspace.stateSummaries.firstWhere((summary) => summary.kind == TreasuryStatusKind.decision).count}',
                    note: 'The current calm status balance across Treasury.',
                    accent: AppColours.darkSuccess,
                  ),
                  const SizedBox(height: 12),
                  _HeroMetricCard(
                    label: 'Latest weekly rhythm',
                    value: summary.weeklyReviewDate ?? 'No weekly review yet',
                    note: summary.weeklyReviewNote?.isNotEmpty == true
                        ? summary.weeklyReviewNote!
                        : 'The weekly note will show once the ritual has been saved.',
                    accent: AppColours.darkSecondary,
                  ),
                  const SizedBox(height: 12),
                  _HeroMetricCard(
                    label: 'Latest decision',
                    value: summary.recentDecisions.isEmpty
                        ? 'No decisions yet'
                        : summary.recentDecisions.first.decisionNeeded,
                    note: summary.recentDecisions.isNotEmpty
                        ? '${summary.recentDecisions.first.date} • ${summary.recentDecisions.first.status}'
                        : 'The next decision will appear here after it is saved.',
                    accent: AppColours.darkPurple,
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => context.push(RouteNames.dashboard),
                          icon: const Icon(Icons.dashboard_outlined),
                          label: const Text('Back to Dashboard'),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              context.push(RouteNames.treasuryBudgetPots),
                          icon: const Icon(
                            Icons.account_balance_wallet_outlined,
                          ),
                          label: const Text('Open Budget Pots'),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              context.push(RouteNames.treasuryDecisions),
                          icon: const Icon(Icons.rule_outlined),
                          label: const Text('Open Decisions'),
                        ),
                        FilledButton.icon(
                          onPressed: () =>
                              context.push(RouteNames.treasuryMonthlySummary),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open Monthly Summary'),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              ref.invalidate(treasuryMonthlySummaryProvider),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reload'),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              if (!useWideLayout) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [left, const SizedBox(height: 18), right],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: left),
                  const SizedBox(width: 20),
                  SizedBox(width: 420, child: right),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _WeeklyDraftStateCard extends ConsumerWidget {
  const _WeeklyDraftStateCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(
      treasuryWizardDraftsProvider.select(
        (drafts) => drafts[TreasuryWizardFlow.weeklyRitual],
      ),
    );

    if (draft == null || !draft.hasContent) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useWide = constraints.maxWidth >= 860;
          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.bookmark_added_outlined,
                title: 'Weekly ritual draft',
              ),
              const SizedBox(height: 10),
              Text(
                'Hayley has a saved draft for the weekly review.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                draft.firstSummary,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                draft.savedAt == null
                    ? 'Draft updated ${DateFormat('h:mm a').format(draft.updatedAt)}'
                    : 'Saved ${DateFormat('h:mm a').format(draft.savedAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
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
                onPressed: () => context.push(
                  RouteNames.treasuryWizardFor(
                    TreasuryWizardFlow.weeklyRitual.routeValue,
                  ),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Continue'),
              ),
              TextButton(
                onPressed: () => ref
                    .read(treasuryWizardDraftsProvider.notifier)
                    .markSaved(TreasuryWizardFlow.weeklyRitual),
                child: const Text('Mark saved'),
              ),
            ],
          );

          if (!useWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [info, const SizedBox(height: 14), actions],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: info),
              const SizedBox(width: 20),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _DecisionReviewCard extends ConsumerWidget {
  const _DecisionReviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(treasuryMonthlySummaryProvider);
    final theme = Theme.of(context);

    return summaryAsync.when(
      loading: () => Container(
        decoration: _cardDecoration(),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircularProgressIndicator(strokeWidth: 2.5),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Gathering the latest decisions...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
      error: (error, stackTrace) => Container(
        decoration: _cardDecoration(),
        padding: const EdgeInsets.all(18),
        child: Text(
          'Decision review will appear once Treasury can read the finance folder again.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColours.darkMutedText,
            height: 1.4,
          ),
        ),
      ),
      data: (summary) {
        final recentDecisions = summary.recentDecisions;

        return Container(
          decoration: _cardDecoration(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.gavel_outlined,
                title: 'Decision review',
              ),
              const SizedBox(height: 10),
              Text(
                'A compact scan of the latest finance decisions so the next choice stays easy to see.',
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
                  _StatusPill(
                    label: '${recentDecisions.length} recent decisions',
                    accent: AppColours.darkSecondary,
                  ),
                  _StatusPill(
                    label: summary.weeklyReviewDate ?? 'No weekly review yet',
                    accent: AppColours.darkSuccess,
                  ),
                ],
              ),
              if (recentDecisions.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: AppColours.darkSurfaceAlt.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColours.darkOutline),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latest decision',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColours.darkSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        recentDecisions.first.decisionNeeded,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColours.darkText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatusPill(
                            label: recentDecisions.first.date,
                            accent: AppColours.darkSecondary,
                          ),
                          _StatusPill(
                            label: recentDecisions.first.status,
                            accent: AppColours.darkPurple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              if (recentDecisions.isEmpty)
                Text(
                  'No decision records have been logged yet.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                )
              else
                ...recentDecisions
                    .take(3)
                    .map(
                      (decision) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColours.darkSurfaceAlt.withValues(
                              alpha: 0.9,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColours.darkOutline),
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                decision.decisionNeeded,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColours.darkText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${decision.date} • ${decision.status}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColours.darkSecondary,
                                ),
                              ),
                              if (decision.decision.trim().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  decision.decision,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColours.darkMutedText,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  TextButton.icon(
                    onPressed: () => context.push(RouteNames.treasuryDecisions),
                    icon: const Icon(Icons.gavel_outlined),
                    label: const Text('Open Decisions'),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        context.push(RouteNames.treasuryMonthlySummary),
                    icon: const Icon(Icons.assessment_outlined),
                    label: const Text('Open Monthly Summary'),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        ref.invalidate(treasuryMonthlySummaryProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reload'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TreasuryStateCard extends StatelessWidget {
  const _TreasuryStateCard({required this.summary});

  final TreasuryStateSummary summary;

  @override
  Widget build(BuildContext context) {
    final accent = _stateAccent(summary.kind);
    final icon = _stateIcon(summary.kind);
    final theme = Theme.of(context);

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: 0.26)),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColours.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${summary.count} item${summary.count == 1 ? '' : 's'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            summary.subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          if (summary.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...summary.items
                .take(3)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.circle, size: 7, color: accent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColours.darkText,
                              height: 1.3,
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

class _ReceiptsCard extends StatelessWidget {
  const _ReceiptsCard({required this.snapshot});

  final TreasuryWorkspaceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.receipt_long_outlined,
            title: 'Receipts to Sort',
          ),
          const SizedBox(height: 14),
          Text(
            snapshot.receiptsToSortCount == 0
                ? 'No receipts are waiting in the 00_TO_SORT folder.'
                : '${snapshot.receiptsToSortCount} receipt${snapshot.receiptsToSortCount == 1 ? '' : 's'} are waiting to be logged and filed.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Keep this light: capture the receipt, mark the category, and move on.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkText,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyRitualCard extends StatelessWidget {
  const _WeeklyRitualCard({required this.snapshot});

  final TreasuryWorkspaceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.event_note_outlined,
            title: 'Weekly Ritual',
          ),
          const SizedBox(height: 14),
          Text(
            'A short, guided finance reset that keeps the dashboard calm and clear.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ...snapshot.weeklyRitualSteps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: AppColours.darkSuccess,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      step,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColours.darkText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TreasuryHealthCard extends StatelessWidget {
  const _TreasuryHealthCard({required this.snapshot, required this.onReload});

  final TreasuryWorkspaceSnapshot snapshot;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useWideLayout = constraints.maxWidth >= 900;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.folder_open_outlined,
                title: 'Folder health',
              ),
              const SizedBox(height: 12),
              Text(
                snapshot.guidanceNote,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusPill(
                    label: '${snapshot.requiredFolders.length} folders watched',
                    accent: AppColours.darkSecondary,
                  ),
                  _StatusPill(
                    label: '${snapshot.missingFolders.length} missing folders',
                    accent: snapshot.missingFolders.isEmpty
                        ? AppColours.darkSuccess
                        : AppColours.darkAmber,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextButton.icon(
                onPressed: onReload,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload folder health'),
              ),
              TextButton.icon(
                onPressed: () => context.push(RouteNames.treasurySettings),
                icon: const Icon(Icons.tune_outlined),
                label: const Text('Open settings'),
              ),
            ],
          );

          if (useWideLayout) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: content),
                const SizedBox(width: 16),
                Expanded(
                  child: _MiniChecklist(
                    title: 'What Treasury is looking for',
                    items: snapshot.requiredFolders,
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              content,
              const SizedBox(height: 14),
              _MiniChecklist(
                title: 'What Treasury is looking for',
                items: snapshot.requiredFolders,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TreasuryFooterCard extends StatelessWidget {
  const _TreasuryFooterCard({required this.theme, required this.snapshot});

  final ThemeData theme;
  final TreasuryWorkspaceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.eco_outlined, color: AppColours.darkSuccess),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              snapshot.isReady
                  ? 'Small, local reviews keep money stewardship steady and kind.'
                  : 'Treasury is ready to calm down as soon as the folder link is healthy.',
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

class _SetupHeaderCard extends StatelessWidget {
  const _SetupHeaderCard({
    required this.title,
    required this.body,
    required this.onReload,
    required this.onBack,
  });

  final String title;
  final String body;
  final VoidCallback onReload;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: _cardDecoration(highlighted: true),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Treasury',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColours.darkText,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Text(
              body,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Dashboard'),
              ),
              FilledButton.icon(
                onPressed: onReload,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
              const _StatusPill(
                label: 'Local-first only',
                accent: AppColours.darkSuccess,
              ),
              const _StatusPill(
                label: 'No finance copy inside repo',
                accent: AppColours.darkSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SetupIssuesCard extends StatelessWidget {
  const _SetupIssuesCard({required this.snapshot});

  final TreasuryWorkspaceSnapshot snapshot;

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
            title: 'What needs attention',
          ),
          const SizedBox(height: 14),
          if (snapshot.issues.isEmpty)
            Text(
              'No blocking issues are showing right now.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            )
          else
            ...snapshot.issues.map(
              (issue) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
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
      ),
    );
  }
}

class _SetupPathCard extends StatelessWidget {
  const _SetupPathCard({required this.snapshot});

  final TreasuryWorkspaceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.link_outlined,
            title: 'Configured path',
          ),
          const SizedBox(height: 12),
          Text(
            snapshot.financeRootPath ?? 'No finance path has been saved yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            snapshot.configPath,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
          ),
        ],
      ),
    );
  }
}

class _SetupFilesCard extends StatelessWidget {
  const _SetupFilesCard({required this.snapshot});

  final TreasuryWorkspaceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.description_outlined,
            title: 'Missing files',
          ),
          const SizedBox(height: 12),
          if (snapshot.missingFiles.isEmpty)
            Text(
              'All required Treasury files are present.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkText,
                height: 1.4,
              ),
            )
          else
            ...snapshot.missingFiles.map(
              (file) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
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
                        file,
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
      ),
    );
  }
}

class _SetupStepsCard extends StatelessWidget {
  const _SetupStepsCard({
    required this.theme,
    required this.snapshot,
    required this.onReload,
    required this.onOpenSetupWizard,
  });

  final ThemeData theme;
  final TreasuryWorkspaceSnapshot snapshot;
  final VoidCallback onReload;
  final VoidCallback onOpenSetupWizard;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.checklist_rtl_outlined,
            title: 'Calm setup steps',
          ),
          const SizedBox(height: 14),
          ...[
            'Make sure `config/local_paths.json` exists in the dashboard repo.',
            'Set `finance_treasury_path` to the external Omega OS folder.',
            'Open the setup wizard to create any missing folders and starter templates.',
            'Return here and reload Treasury after the wizard finishes.',
          ].map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.arrow_right_rounded,
                    size: 18,
                    color: AppColours.darkSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                onPressed:
                    snapshot.missingFiles.isEmpty &&
                        snapshot.missingFolders.isEmpty
                    ? null
                    : onOpenSetupWizard,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('Open setup wizard'),
              ),
              TextButton.icon(
                onPressed: onReload,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload Treasury'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _openSetupWizard(
  BuildContext context,
  WidgetRef ref,
  TreasuryWorkspaceSnapshot snapshot,
) {
  final service = ref.read(treasuryFolderServiceProvider);

  return showFolderBootstrapWizard(
    context: context,
    plan: FolderBootstrapWizardPlan(
      title: 'Treasury setup wizard',
      subtitle:
          'This calm pipeline checks the external finance folder and creates only what is missing. It can be reused for future business areas later.',
      steps: const [
        FolderBootstrapWizardStep(
          title: 'Review the link',
          body:
              'Confirm the external Omega OS folder is the source of truth before any file changes happen.',
          icon: Icons.link_outlined,
        ),
        FolderBootstrapWizardStep(
          title: 'Create missing structure',
          body:
              'Only the missing folders and starter templates are added. Existing finance data stays untouched.',
          icon: Icons.auto_awesome_outlined,
        ),
        FolderBootstrapWizardStep(
          title: 'Reload and confirm',
          body:
              'Treasury rechecks the folder after creation and moves into the home view when everything is healthy.',
          icon: Icons.refresh_outlined,
        ),
      ],
      missingFolders: snapshot.missingFolders,
      missingFiles: snapshot.missingFiles,
    ),
    onCreateMissingStructure: () async {
      final result = await service.createMissingRequiredStructure();
      ref.invalidate(treasuryWorkspaceProvider);
      return result;
    },
    onReload: () => ref.invalidate(treasuryWorkspaceProvider),
  );
}

class _MiniChecklist extends StatelessWidget {
  const _MiniChecklist({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
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
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppColours.darkText),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.fiber_manual_record,
                    size: 8,
                    color: AppColours.darkSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (items.isEmpty)
            Text(
              'Nothing is missing from this check right now.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            ),
        ],
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

void _showRitualPreview(
  BuildContext context, {
  required String title,
  required List<String> steps,
  String? note,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Container(
        decoration: BoxDecoration(
          color: AppColours.darkSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: AppColours.darkOutline.withValues(alpha: 0.9),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: AppColours.darkText),
              ),
              const SizedBox(height: 10),
              Text(
                note ??
                    'The full guided flow will arrive in the next Treasury task, but the calm sequence is already defined.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              ...steps.map(
                (step) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: AppColours.darkSuccess,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          step,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColours.darkText),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Color _stateAccent(TreasuryStatusKind kind) {
  switch (kind) {
    case TreasuryStatusKind.safe:
      return AppColours.darkSuccess;
    case TreasuryStatusKind.watch:
      return AppColours.darkAmber;
    case TreasuryStatusKind.pause:
      return const Color(0xFFE26B6B);
    case TreasuryStatusKind.decision:
      return AppColours.darkSecondary;
    case TreasuryStatusKind.future:
      return AppColours.darkPurple;
    case TreasuryStatusKind.archived:
      return AppColours.darkMutedText;
  }
}

IconData _stateIcon(TreasuryStatusKind kind) {
  switch (kind) {
    case TreasuryStatusKind.safe:
      return Icons.check_circle_outline;
    case TreasuryStatusKind.watch:
      return Icons.visibility_outlined;
    case TreasuryStatusKind.pause:
      return Icons.pause_circle_outline;
    case TreasuryStatusKind.decision:
      return Icons.gavel_outlined;
    case TreasuryStatusKind.future:
      return Icons.auto_awesome_outlined;
    case TreasuryStatusKind.archived:
      return Icons.archive_outlined;
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
