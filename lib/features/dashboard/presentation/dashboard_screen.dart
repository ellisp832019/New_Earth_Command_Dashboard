import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../widgets/calm_guidance_card.dart';
import '../../company_command_centre/data/company_command_centre_config.dart';
import '../../company_command_centre/data/company_command_centre_local_settings_service.dart';
import '../../company_command_centre/data/company_command_centre_repository.dart';
import '../../assets/application/assets_controller.dart';
import '../../assets/data/qr_label_printing_service.dart';
import '../../inbox/application/inbox_controller.dart';
import '../../knowledge_library/data/knowledge_library_repository.dart';
import '../../launchpad/application/launchpad_controller.dart';
import '../../launchpad/data/launchpad_calculator.dart';
import '../../launchpad/data/launchpad_phase2_models.dart';
import '../../launchpad/data/launchpad_models.dart';
import '../../meeting_system/application/meeting_system_controller.dart';
import '../../meeting_system/data/meeting_folder_service.dart';
import '../../meeting_system/presentation/meeting_system_widgets.dart';
import '../../planner/application/planner_controller.dart';
import '../../tasks/application/tasks_controller.dart';
import '../../system_backup/application/backup_guardian_controller.dart';
import '../../system_backup/data/backup_guardian_service.dart';
import '../application/dashboard_controller.dart';
import '../data/dashboard_repository.dart';
import '../../treasury/application/treasury_controller.dart';
import '../../treasury/data/treasury_folder_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(dashboardSnapshotProvider);

    return snapshot.when(
      data: (data) => _DashboardContent(snapshot: data),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) =>
          Scaffold(body: _DashboardError(error: error)),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1100;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          key: const Key('dashboardScrollView'),
          cacheExtent: 3000,
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
                    _DashboardHero(snapshot: snapshot),
                    const SizedBox(height: 22),
                    _DashboardGuidanceCard(snapshot: snapshot),
                    const SizedBox(height: 22),
                    const _TreasuryOverviewCard(),
                    const SizedBox(height: 22),
                    const _CompanyCommandCentreCard(),
                    const SizedBox(height: 22),
                    _DashboardSectionHeader(
                      title: 'Primary work',
                      subtitle: 'Keep the next useful move, focus, and projects close together.',
                    ),
                    const SizedBox(height: 14),
                    _TopTaskShowcase(snapshot: snapshot),
                    const SizedBox(height: 22),
                    _SecondaryPanelGrid(snapshot: snapshot),
                    const SizedBox(height: 22),
                    _DashboardSectionHeader(
                      title: 'Support stack',
                      subtitle: 'Open these only when they help the day move more clearly.',
                    ),
                    const SizedBox(height: 14),
                    _SupportModuleGrid(snapshot: snapshot),
                    const SizedBox(height: 22),
                    _DashboardEveningReviewCard(snapshot: snapshot),
                    const SizedBox(height: 20),
                    _DashboardFooter(isDark: isDark),
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

class _DashboardHero extends ConsumerWidget {
  const _DashboardHero({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final weekday = DateFormat('EEEE').format(snapshot.date);
    final shortDate = DateFormat('d MMM y').format(snapshot.date);
    final hasFocus = snapshot.mainFocus?.isNotEmpty == true;
    final headline = hasFocus
        ? 'Your focus is set for today'
        : 'Choose one clear move for today';
    final supportingCopy = hasFocus
        ? 'Keep the rest parked until the next useful step is complete.'
        : 'Keep the day light and let the Top 3 guide the work.';
    final focusChip = hasFocus ? 'Ready' : 'Set Focus';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(context, highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useWideLayout = constraints.maxWidth >= 980;

          final brandAndCopy = [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today',
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
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Text(
                      supportingCopy,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColours.darkMutedText,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];

          final chips = Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeaderMetricChip(label: 'Focus', value: focusChip),
              _HeaderMetricChip(
                label: 'Top 3',
                value: '${snapshot.topTasks.length}/3',
                accentColor: AppColours.darkSuccess,
              ),
              _HeaderMetricChip(
                label: 'Projects',
                value: '${snapshot.activeProjectCount}',
                accentColor: AppColours.darkPrimary,
              ),
              _HeaderMetricChip(
                label: 'Energy',
                value: snapshot.energyLabel,
                accentColor: AppColours.darkSuccess,
              ),
              _HeaderMetricChip(label: 'Day', value: weekday),
              _HeaderMetricChip(label: 'Date', value: shortDate),
            ],
          );

          final coreActions = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                key: const Key('dashboardPrimaryNextStepButton'),
                onPressed: () => _openNextStep(ref, context),
                icon: Icon(_nextStepIcon(snapshot.nextStepActionType)),
                label: Text(snapshot.nextStepActionLabel),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.push(RouteNames.commandPalette),
                icon: const Icon(Icons.search),
                label: const Text('Quick Search'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.push(RouteNames.tasks),
                icon: const Icon(Icons.task_alt_outlined),
                label: const Text('Open Tasks'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.push(RouteNames.planner),
                icon: const Icon(Icons.event_note_outlined),
                label: const Text('Open Planner'),
              ),
            ],
          );

          final moduleActions = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              TextButton.icon(
                onPressed: () => context.push(RouteNames.treasury),
                icon: const Icon(Icons.account_balance_wallet_outlined),
                label: const Text('Open Treasury'),
              ),
              TextButton.icon(
                onPressed: () =>
                    context.push(RouteNames.fundingGrantsCommandCentre),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Open Grants'),
              ),
            ],
          );

          final actions = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              coreActions,
              const SizedBox(height: 10),
              moduleActions,
            ],
          );

          if (!useWideLayout) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...brandAndCopy,
                const SizedBox(height: 18),
                chips,
                const SizedBox(height: 18),
                actions,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...brandAndCopy,
                    const SizedBox(height: 18),
                    actions,
                  ],
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 580,
                child: Align(alignment: Alignment.topRight, child: chips),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openNextStep(WidgetRef ref, BuildContext context) {
    switch (snapshot.nextStepActionType) {
      case DashboardNextStepActionType.planner:
        context.push(RouteNames.planner);
        return;
      case DashboardNextStepActionType.tasks:
        ref.read(selectedTaskStatusFilterProvider.notifier).setFilter('All');
        ref.read(selectedTaskProjectFilterProvider.notifier).setFilter(null);
        ref.read(taskSearchQueryProvider.notifier).clear();
        context.push(RouteNames.tasks);
        return;
      case DashboardNextStepActionType.parkedTasks:
        ref.read(selectedTaskStatusFilterProvider.notifier).setFilter('Parked');
        ref.read(selectedTaskProjectFilterProvider.notifier).setFilter(null);
        ref.read(taskSearchQueryProvider.notifier).clear();
        context.push(RouteNames.tasks);
        return;
      case DashboardNextStepActionType.projectDetail:
        final projectId = snapshot.nextStepProjectId;
        if (projectId == null) {
          context.push(RouteNames.projectsWorkspace);
          return;
        }
        context.push(RouteNames.projectDetail(projectId));
        return;
    }
  }

  IconData _nextStepIcon(DashboardNextStepActionType actionType) {
    switch (actionType) {
      case DashboardNextStepActionType.planner:
        return Icons.event_note_outlined;
      case DashboardNextStepActionType.tasks:
        return Icons.task_alt_outlined;
      case DashboardNextStepActionType.parkedTasks:
        return Icons.inventory_2_outlined;
      case DashboardNextStepActionType.projectDetail:
        return Icons.folder_open_outlined;
    }
  }
}

class _TopTaskShowcase extends StatelessWidget {
  const _TopTaskShowcase({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final tasks = snapshot.topTasks;
    final cards = tasks.isEmpty
        ? [
            const _ShowcaseTaskState(
              badge: '1',
              title: 'Choose your first priority task',
              subtitle: 'Your Top 3 will appear here once selected.',
              label: 'Today',
              accent: AppColours.darkSecondary,
            ),
            const _ShowcaseTaskState(
              badge: '2',
              title: 'Create momentum with one useful action',
              subtitle: 'Planner and Tasks stay in sync with this list.',
              label: 'Planner',
              accent: AppColours.darkSuccess,
            ),
            const _ShowcaseTaskState(
              badge: '3',
              title: 'Keep the dashboard clear',
              subtitle: 'Only three priorities live here at a time.',
              label: 'Focus',
              accent: AppColours.darkPurple,
            ),
          ]
        : List.generate(3, (index) {
            final task = index < tasks.length ? tasks[index] : null;
            return _ShowcaseTaskState.fromTask(index: index, task: task);
          });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 12),
          child: Text(
            'Today\'s Focus',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColours.darkText),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final useThreeColumns = constraints.maxWidth >= 860;
            if (useThreeColumns) {
              return Row(
                children: [
                  for (var index = 0; index < cards.length; index++) ...[
                    Expanded(
                      child: _ShowcaseTaskCard(
                        snapshotTask: index < tasks.length
                            ? tasks[index]
                            : null,
                        state: cards[index],
                      ),
                    ),
                    if (index != cards.length - 1) const SizedBox(width: 14),
                  ],
                ],
              );
            }

            return Column(
              children: [
                for (var index = 0; index < cards.length; index++) ...[
                  _ShowcaseTaskCard(
                    snapshotTask: index < tasks.length ? tasks[index] : null,
                    state: cards[index],
                  ),
                  if (index != cards.length - 1) const SizedBox(height: 14),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DashboardGuidanceCard extends StatelessWidget {
  const _DashboardGuidanceCard({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return CalmGuidanceCard(
      title: snapshot.nextStepTitle,
      summary: snapshot.nextStepSummary,
      reason: snapshot.nextStepReason,
    );
  }
}

class _TreasuryOverviewCard extends ConsumerWidget {
  const _TreasuryOverviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(treasuryWorkspaceProvider);

    return snapshot.when(
      loading: () => Container(
        padding: const EdgeInsets.all(20),
        decoration: _panelDecoration(context),
        child: Row(
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColours.darkSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              'Treasury is loading quietly.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            ),
          ],
        ),
      ),
      error: (error, stackTrace) => _TreasuryOverviewPanel(
        title: 'Treasury',
        subtitle:
            'The finance area needs a calm setup before it can show more.',
        body:
            'Hayley can still open Treasury, but the folder link needs attention first.',
        statusLabel: 'Setup needed',
        statusAccent: AppColours.darkAmber,
        receiptsLabel: 'Receipts are unavailable until the folder is linked.',
        onOpenTreasury: () => context.push(RouteNames.treasury),
        onReload: () => ref.invalidate(treasuryWorkspaceProvider),
        stateSummaries: const <TreasuryStateSummary>[],
      ),
      data: (data) => _TreasuryOverviewPanel(
        title: 'Treasury',
        subtitle: 'Hayley\'s private finance space inside the Dashboard.',
        body: data.isReady
            ? 'Safe, Watch, Pause, and Decision live in one calm place, with receipts and weekly ritual close by.'
            : 'The Treasury area is present, but the external Omega OS folder still needs a small setup check.',
        statusLabel: data.isReady ? 'Ready' : 'Setup needed',
        statusAccent: data.isReady
            ? AppColours.darkSuccess
            : AppColours.darkAmber,
        receiptsLabel: data.receiptsToSortCount == 0
            ? 'No receipts are waiting right now.'
            : '${data.receiptsToSortCount} receipt${data.receiptsToSortCount == 1 ? '' : 's'} to sort.',
        onOpenTreasury: () => context.push(RouteNames.treasury),
        onReload: () => ref.invalidate(treasuryWorkspaceProvider),
        stateSummaries: data.stateSummaries,
      ),
    );
  }
}

class _TreasuryOverviewPanel extends StatelessWidget {
  const _TreasuryOverviewPanel({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.statusLabel,
    required this.statusAccent,
    required this.receiptsLabel,
    required this.onOpenTreasury,
    required this.onReload,
    required this.stateSummaries,
  });

  final String title;
  final String subtitle;
  final String body;
  final String statusLabel;
  final Color statusAccent;
  final String receiptsLabel;
  final VoidCallback onOpenTreasury;
  final VoidCallback onReload;
  final List<TreasuryStateSummary> stateSummaries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summaryMap = {
      for (final summary in stateSummaries) summary.kind: summary.count,
    };

    final metricChips = [
      _TreasuryMetricChip(
        label: 'Safe',
        value: '${summaryMap[TreasuryStatusKind.safe] ?? 0}',
        accent: AppColours.darkSuccess,
      ),
      _TreasuryMetricChip(
        label: 'Watch',
        value: '${summaryMap[TreasuryStatusKind.watch] ?? 0}',
        accent: AppColours.darkAmber,
      ),
      _TreasuryMetricChip(
        label: 'Pause',
        value: '${summaryMap[TreasuryStatusKind.pause] ?? 0}',
        accent: const Color(0xFFE26B6B),
      ),
      _TreasuryMetricChip(
        label: 'Decision',
        value: '${summaryMap[TreasuryStatusKind.decision] ?? 0}',
        accent: AppColours.darkSecondary,
      ),
    ];

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
                    title: 'Treasury',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  const Spacer(),
                  _InlineTag(
                    label: statusLabel,
                    accent: statusAccent,
                    foreground: statusAccent,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColours.darkText,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 740),
                child: Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(spacing: 10, runSpacing: 10, children: metricChips),
              const SizedBox(height: 14),
              Text(
                receiptsLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColours.darkText,
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
                onPressed: onOpenTreasury,
                icon: const Icon(Icons.lock_open_outlined),
                label: const Text('Open Treasury'),
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
              SizedBox(width: 220, child: actions),
            ],
          );
        },
      ),
    );
  }
}

class _TreasuryMetricChip extends StatelessWidget {
  const _TreasuryMetricChip({
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
      constraints: const BoxConstraints(minWidth: 118),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyCommandCentreCard extends ConsumerWidget {
  const _CompanyCommandCentreCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(companyCommandCentreSnapshotProvider);
    final localSettings = ref.watch(companyCommandCentreLocalSettingsProvider);
    final linkedinCompanyUrl = localSettings.maybeWhen(
      data: (settings) => settings.linkedinCompanyUrl.isNotEmpty
          ? settings.linkedinCompanyUrl
          : companyCommandCentreLinkedInCompanyUrl,
      orElse: () => companyCommandCentreLinkedInCompanyUrl,
    );

    return snapshot.when(
      loading: () => Container(
        padding: const EdgeInsets.all(20),
        decoration: _panelDecoration(context),
        child: Row(
          children: [
            const Icon(Icons.domain_outlined, color: AppColours.darkSecondary),
            const SizedBox(width: 12),
            Text(
              'Company Command Centre is loading quietly.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            ),
          ],
        ),
      ),
      error: (error, stackTrace) => _CompanyCommandCentrePanel(
        title: 'Company Command Centre',
        subtitle: 'The company ops space is ready to open from the dashboard.',
        body:
            'Company records, website notes, LinkedIn planning, grants, and the action board stay together in one calm place.',
        statusLabel: 'Module ready',
        statusAccent: AppColours.darkAmber,
        onOpenModule: () => context.push(RouteNames.companyCommandCentre),
        onReload: () => ref.invalidate(companyCommandCentreSnapshotProvider),
        onOpenLinkedIn: linkedinCompanyUrl.trim().isEmpty
            ? null
            : () => _openExternalUrl(linkedinCompanyUrl),
        chips: const [
          _CompanyChip(label: 'Overview', value: 'Ready'),
          _CompanyChip(label: 'Compliance', value: 'Tracked'),
          _CompanyChip(label: 'Website', value: 'Planned'),
          _CompanyChip(label: 'LinkedIn', value: 'Planned'),
        ],
      ),
      data: (data) => _CompanyCommandCentrePanel(
        title: 'Company Command Centre',
        subtitle: data.overview.companyName,
        body:
            'Foundational company operations stay visible here without leaving the dashboard.',
        statusLabel: data.overview.status.replaceAll('_', ' '),
        statusAccent: data.overview.omegaOsPathExists
            ? AppColours.darkSuccess
            : AppColours.darkAmber,
        onOpenModule: () => context.push(RouteNames.companyCommandCentre),
        onReload: () => ref.invalidate(companyCommandCentreSnapshotProvider),
        onOpenLinkedIn: linkedinCompanyUrl.trim().isEmpty
            ? null
            : () => _openExternalUrl(linkedinCompanyUrl),
        chips: [
          _CompanyChip(
            label: 'Company no.',
            value: data.overview.companyNumber,
          ),
          _CompanyChip(
            label: 'Products',
            value: '${data.productPortfolio.length}',
          ),
          _CompanyChip(label: 'Grants', value: '${data.grantsPipeline.length}'),
          _CompanyChip(label: 'Actions', value: '${data.actionBoard.length}'),
        ],
      ),
    );
  }
}

class _CompanyCommandCentrePanel extends StatelessWidget {
  const _CompanyCommandCentrePanel({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.statusLabel,
    required this.statusAccent,
    required this.onOpenModule,
    required this.onReload,
    required this.onOpenLinkedIn,
    required this.chips,
  });

  final String title;
  final String subtitle;
  final String body;
  final String statusLabel;
  final Color statusAccent;
  final VoidCallback onOpenModule;
  final VoidCallback onReload;
  final VoidCallback? onOpenLinkedIn;
  final List<_CompanyChip> chips;

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
                    title: 'Company',
                    icon: Icons.domain_outlined,
                  ),
                  const Spacer(),
                  _InlineTag(
                    label: statusLabel,
                    accent: statusAccent,
                    foreground: statusAccent,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColours.darkText,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(spacing: 10, runSpacing: 10, children: chips),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: onOpenModule,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Company'),
              ),
              FilledButton.tonalIcon(
                onPressed: onOpenLinkedIn,
                icon: const Icon(Icons.cases_outlined),
                label: const Text('Open LinkedIn'),
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
              SizedBox(width: 220, child: actions),
            ],
          );
        },
      ),
    );
  }
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

class _CompanyChip extends StatelessWidget {
  const _CompanyChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 128),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.88),
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

class _SecondaryPanelGrid extends StatelessWidget {
  const _SecondaryPanelGrid({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useThreeColumns = constraints.maxWidth >= 980;

        if (useThreeColumns) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _DashboardFocusCard(snapshot: snapshot)),
              const SizedBox(width: 16),
              Expanded(child: _ActiveProjectsPanel(snapshot: snapshot)),
              const SizedBox(width: 16),
              const Expanded(child: _DashboardQuickCaptureCard()),
            ],
          );
        }

        return Column(
          children: [
            _DashboardFocusCard(snapshot: snapshot),
            const SizedBox(height: 16),
            _ActiveProjectsPanel(snapshot: snapshot),
            const SizedBox(height: 16),
            const _DashboardQuickCaptureCard(),
          ],
        );
      },
    );
  }
}

class _SupportModuleGrid extends StatelessWidget {
  const _SupportModuleGrid({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final summaryTiles = <_CompactModuleTile>[
      const _CompactModuleTile(
        title: 'Command Deck',
        description: 'Launch shortcuts.',
        icon: Icons.space_dashboard_outlined,
        route: RouteNames.commandDeck,
        accent: AppColours.darkSecondary,
      ),
      const _CompactModuleTile(
        title: 'Launchpad',
        description: 'Campaign readiness.',
        icon: Icons.rocket_launch_outlined,
        route: RouteNames.launchpad,
        accent: AppColours.darkSuccess,
      ),
      const _CompactModuleTile(
        title: 'Meetings',
        description: 'Notes and follow-ups.',
        icon: Icons.groups_outlined,
        route: RouteNames.meetingDashboard,
        accent: AppColours.darkAmber,
      ),
      const _CompactModuleTile(
        title: 'Knowledge',
        description: 'Local reference.',
        icon: Icons.menu_book_outlined,
        route: RouteNames.knowledgeLibrary,
        accent: AppColours.darkPurple,
      ),
      const _CompactModuleTile(
        title: 'Repo Bridge',
        description: 'Read-only intelligence.',
        icon: Icons.device_hub_outlined,
        route: RouteNames.repoIntelligenceBridge,
        accent: AppColours.darkPrimary,
      ),
      const _CompactModuleTile(
        title: 'Experiment',
        description: 'Validation workspace.',
        icon: Icons.science_outlined,
        route: RouteNames.experimentWorkspace,
        accent: AppColours.darkSecondary,
      ),
    ];

    final cards = <_MiniModuleState>[
      if (snapshot.showLearningCard)
        const _MiniModuleState(
          title: 'Learning Focus',
          description: '',
          icon: Icons.school_outlined,
          accent: AppColours.darkSuccess,
        ),
      if (snapshot.showContentCard)
        const _MiniModuleState(
          title: 'Content Focus',
          description: '',
          icon: Icons.campaign_outlined,
          accent: AppColours.darkSecondary,
        ),
      if (snapshot.showBusinessCard)
        const _MiniModuleState(
          title: 'Business Reminder',
          description: '',
          icon: Icons.handshake_outlined,
          accent: AppColours.darkAmber,
        ),
      if (snapshot.showWellbeingCard)
        const _MiniModuleState(
          title: 'Wellbeing',
          description: '',
          icon: Icons.favorite_border,
          accent: AppColours.darkPurple,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1120
            ? 4
            : constraints.maxWidth >= 740
            ? 2
            : 1;
        final summaryColumns = constraints.maxWidth >= 1080
            ? 3
            : constraints.maxWidth >= 700
            ? 2
            : 1;

        return Column(
          children: [
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final tile in summaryTiles)
                  SizedBox(
                    width:
                        (constraints.maxWidth - (summaryColumns - 1) * 14) /
                        summaryColumns,
                    child: tile,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            const BackupGuardianDashboardCard(),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: crossAxisCount == 1 ? 3.1 : 2.05,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) =>
                  _MiniModuleCard(state: cards[index]),
            ),
          ],
        );
      },
    );
  }
}

class _DashboardSectionHeader extends StatelessWidget {
  const _DashboardSectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactModuleTile extends StatelessWidget {
  const _CompactModuleTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.accent,
  });

  final String title;
  final String description;
  final IconData icon;
  final String route;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: () => context.go(route),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(color: accent.withValues(alpha: 0.72), width: 2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, size: 20, color: accent),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_outlined,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BackupGuardianDashboardCard extends ConsumerWidget {
  const BackupGuardianDashboardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(backupGuardianSnapshotProvider);

    return snapshotAsync.when(
      loading: () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: _panelDecoration(context),
        child: Row(
          children: [
            const Icon(Icons.backup_outlined, color: AppColours.darkSecondary),
            const SizedBox(width: 12),
            Text(
              'Backup Guardian loading.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            ),
          ],
        ),
      ),
      error: (error, stackTrace) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: _panelDecoration(context),
        child: Row(
          children: [
            const Icon(Icons.backup_outlined, color: AppColours.darkAmber),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Backup Guardian unavailable.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
            ),
          ],
        ),
      ),
      data: (snapshot) {
        final targetLabel = snapshot.backupDriveExists
            ? snapshot.backupTarget
            : 'Backup drive not connected';
        final statusLabel = snapshot.backupDriveExists
            ? 'Drive visible'
            : 'Drive missing';
        final statusAccent = snapshot.backupDriveExists
            ? AppColours.darkSuccess
            : AppColours.darkAmber;
        final stripColor = statusAccent.withValues(alpha: 0.9);
        final bannerLabel = snapshot.backupDriveExists
            ? 'Ready to run'
            : 'Waiting for drive';
        final bannerIcon = snapshot.backupDriveExists
            ? Icons.check_circle_outline
            : Icons.schedule_outlined;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: _panelDecoration(context),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final useWideLayout = constraints.maxWidth >= 900;

              final content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusPulseStrip(
                    color: stripColor,
                    animate: !snapshot.backupDriveExists,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const _PanelTitle(
                        title: 'Backup Guardian',
                        icon: Icons.backup_outlined,
                      ),
                      const Spacer(),
                      _InlineTag(
                        label: snapshot.healthSummary,
                        accent: statusAccent,
                        foreground: statusAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: statusAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: statusAccent.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(bannerIcon, color: statusAccent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$bannerLabel: ${snapshot.backupTarget}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColours.darkText,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.notificationBanner,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColours.darkSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (snapshot.errors.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Mismatch: ${snapshot.verificationMismatchSummary}.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Text(
                      snapshot.backupDriveExists
                          ? 'Drive ready.'
                          : 'Waiting for drive.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InlineTag(
                        label: targetLabel,
                        accent: statusAccent,
                        foreground: AppColours.darkText,
                      ),
                      _InlineTag(
                        label: statusLabel,
                        accent: snapshot.backupDriveExists
                            ? AppColours.darkSuccess
                            : AppColours.darkAmber,
                        foreground: snapshot.backupDriveExists
                            ? AppColours.darkSuccess
                            : AppColours.darkAmber,
                      ),
                      _InlineTag(
                        label: snapshot.config.isLocalConfig
                            ? 'Local config'
                            : 'Example config',
                        accent: snapshot.config.isLocalConfig
                            ? AppColours.darkSuccess
                            : AppColours.darkAmber,
                      ),
                      _InlineTag(
                        label: snapshot.freshnessSummary,
                        accent: AppColours.darkSuccess,
                      ),
                    ],
                  ),
                ],
              );

              final actions = Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: useWideLayout
                    ? WrapAlignment.end
                    : WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.push(RouteNames.backupGuardian),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open Backup'),
                  ),
                  snapshot.errors.isNotEmpty
                      ? FilledButton.icon(
                          onPressed: () async {
                            await ref
                                .read(backupGuardianServiceProvider)
                                .runAction(BackupGuardianAction.rebaseline);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColours.darkAmber,
                            foregroundColor: AppColours.darkBackground,
                          ),
                          icon: const Icon(Icons.inventory_2_outlined),
                          label: const Text('Rebaseline'),
                        )
                      : OutlinedButton.icon(
                          onPressed: () async {
                            await ref
                                .read(backupGuardianServiceProvider)
                                .runAction(BackupGuardianAction.rebaseline);
                          },
                          icon: const Icon(Icons.inventory_2_outlined),
                          label: const Text('Rebaseline'),
                        ),
                  OutlinedButton.icon(
                    onPressed: () => context.push(RouteNames.systems),
                    icon: const Icon(Icons.apps_outlined),
                    label: const Text('Systems'),
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
                  SizedBox(width: 220, child: actions),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class CommandDeckDashboardCard extends StatelessWidget {
  const CommandDeckDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context, highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 980;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.space_dashboard_outlined,
                    color: AppColours.darkSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Command Deck',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _InlineTag(
                    label: 'Local-first',
                    accent: AppColours.darkSuccess,
                    foreground: AppColours.darkSuccess,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Software control centre for the Stream Deck pack, local scripts, meeting automation, and the future hardware bridge.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _InlineTag(
                    label: 'Registry',
                    accent: AppColours.darkSecondary,
                  ),
                  _InlineTag(
                    label: 'Meeting starter',
                    accent: AppColours.darkSuccess,
                  ),
                  _InlineTag(
                    label: 'Build session',
                    accent: AppColours.darkAmber,
                  ),
                  _InlineTag(
                    label: 'Codex handoff',
                    accent: AppColours.darkPurple,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'TODO: load the command registry from `modules/new_earth_command_deck/config/command_registry.example.json` and add persistent action logs.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: isWide ? WrapAlignment.end : WrapAlignment.start,
            children: [
              FilledButton.icon(
                onPressed: () => context.push(RouteNames.commandDeck),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Command Deck'),
              ),
              TextButton.icon(
                onPressed: () => context.push(RouteNames.meetingDashboard),
                icon: const Icon(Icons.event_note_outlined),
                label: const Text('Meeting System'),
              ),
            ],
          );

          if (!isWide) {
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
}

class LaunchpadDashboardCard extends ConsumerWidget {
  const LaunchpadDashboardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(launchpadWorkspaceProvider);

    return snapshot.when(
      loading: () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: _panelDecoration(context),
        child: Row(
          children: [
            const Icon(
              Icons.campaign_outlined,
              color: AppColours.darkSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              'Launchpad is loading quietly.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            ),
          ],
        ),
      ),
      error: (error, stackTrace) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: _panelDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Launchpad',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColours.darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Launchpad could not load right now.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => ref.invalidate(launchpadWorkspaceProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (workspace) {
        final activeCampaign = workspace.campaigns.firstWhere(
          (campaign) => campaign.status != LaunchpadCampaignStatus.archived,
          orElse: () => workspace.campaigns.isEmpty
              ? _launchpadFallbackCampaign()
              : workspace.campaigns.first,
        );
        final readiness = calculateLaunchpadReadinessSummary(
          activeCampaign.readinessItems,
        );
        final finance = calculateLaunchpadFinancialSummary(activeCampaign);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: _panelDecoration(context, highlighted: true),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 980;
              final summary = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.campaign_outlined,
                        color: AppColours.darkSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Launchpad',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColours.darkText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Campaign operations centre for crowdfunding, readiness, and launch planning.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkMutedText,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _DashboardMetricChip(
                        label: 'Campaigns',
                        value: '${workspace.campaigns.length}',
                      ),
                      _DashboardMetricChip(
                        label: 'Readiness',
                        value:
                            '${readiness.overallPercent.toStringAsFixed(0)}%',
                        accentColor: AppColours.darkSuccess,
                      ),
                      _DashboardMetricChip(
                        label: 'Net Funds',
                        value:
                            '£${finance.netAvailableFundsGbp.toStringAsFixed(0)}',
                        accentColor: finance.netAvailableFundsGbp >= 0
                            ? AppColours.darkSuccess
                            : AppColours.darkAmber,
                      ),
                      _DashboardMetricChip(
                        label: 'Status',
                        value: activeCampaign.status.label,
                        accentColor: AppColours.darkPrimary,
                      ),
                    ],
                  ),
                ],
              );

              final actions = Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: wide ? WrapAlignment.end : WrapAlignment.start,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => context.go(RouteNames.launchpad),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open Launchpad'),
                  ),
                  TextButton.icon(
                    onPressed: () => context.go(
                      RouteNames.launchpadCampaign(activeCampaign.id),
                    ),
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Open MicroGrow'),
                  ),
                ],
              );

              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [summary, const SizedBox(height: 16), actions],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: summary),
                  const SizedBox(width: 20),
                  SizedBox(width: 280, child: actions),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _DashboardMetricChip extends StatelessWidget {
  const _DashboardMetricChip({
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
      constraints: const BoxConstraints(minWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          const SizedBox(height: 6),
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

class MeetingSystemDashboardCard extends ConsumerStatefulWidget {
  const MeetingSystemDashboardCard({super.key});

  @override
  ConsumerState<MeetingSystemDashboardCard> createState() =>
      _MeetingSystemDashboardCardState();
}

class _MeetingSystemDashboardCardState
    extends ConsumerState<MeetingSystemDashboardCard> {
  bool _bootstrapping = false;
  bool _exportingLatestBundle = false;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(meetingDashboardSnapshotProvider);
    final latestMeetingSnapshot = ref.watch(meetingLatestMeetingProvider);
    final statusSummarySnapshot = ref.watch(meetingStatusSummaryProvider);

    return snapshot.when(
      loading: () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: _panelDecoration(context),
        child: const LinearProgressIndicator(),
      ),
      error: (error, stackTrace) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: _panelDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meeting System',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColours.darkText),
            ),
            const SizedBox(height: 8),
            Text(
              'Meeting System could not load right now.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => ref.invalidate(meetingDashboardSnapshotProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (data) {
        final workspace = data.workspace;
        final latestMeeting = latestMeetingSnapshot.asData?.value;
        final statusSummary = statusSummarySnapshot.asData?.value;
        final latestBundleReviewSnapshot = latestMeeting == null
            ? null
            : ref.watch(meetingLatestBundleReviewProvider(latestMeeting.id));
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: _panelDecoration(context, highlighted: true),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 1020;
                  final summary = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.event_note_outlined,
                            color: AppColours.darkSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Meeting System',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColours.darkText,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep meetings, actions, decisions, and follow-ups living in Omega OS.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColours.darkMutedText,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          MeetingStatChip(
                            label: 'Meetings',
                            value: '${workspace.meetingCount}',
                            accentColor: AppColours.darkPrimary,
                          ),
                          MeetingStatChip(
                            label: 'Actions',
                            value: '${workspace.actionCount}',
                            accentColor: AppColours.darkSuccess,
                          ),
                          MeetingStatChip(
                            label: 'Follow-ups',
                            value: '${workspace.followUpCount}',
                            accentColor: AppColours.darkPurple,
                          ),
                          MeetingStatChip(
                            label: 'Decisions',
                            value: '${workspace.decisionCount}',
                            accentColor: AppColours.darkAmber,
                          ),
                        ],
                      ),
                      if (latestMeeting != null) ...[
                        const SizedBox(height: 14),
                        latestBundleReviewSnapshot?.when(
                              loading: () => Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: _panelDecoration(context),
                                child: const Row(
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Loading latest bundle review...'),
                                  ],
                                ),
                              ),
                              error: (error, stackTrace) => Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: _panelDecoration(context),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Latest bundle review',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: AppColours.darkSecondary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'The latest exported bundle could not be reviewed right now.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColours.darkMutedText,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              data: (bundleReview) {
                                if (bundleReview == null) {
                                  return const SizedBox.shrink();
                                }

                                return _MeetingBundleReviewCard(
                                  latestMeeting: latestMeeting,
                                  bundleReview: bundleReview,
                                  onExportLatestBundle: _exportingLatestBundle
                                      ? null
                                      : () =>
                                            _exportLatestBundle(latestMeeting),
                                  onOpenBundleFolder: () => ref
                                      .read(meetingFolderServiceProvider)
                                      .openFolder(bundleReview.bundlePath),
                                  onOpenSummary: () => ref
                                      .read(meetingFolderServiceProvider)
                                      .openFile(bundleReview.summaryPath),
                                  onOpenManifest: () => ref
                                      .read(meetingFolderServiceProvider)
                                      .openFile(bundleReview.manifestPath),
                                );
                              },
                            ) ??
                            const SizedBox.shrink(),
                      ],
                      if (statusSummary != null) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            MeetingStatChip(
                              label: 'Planned',
                              value: '${statusSummary.plannedCount}',
                              accentColor: AppColours.darkAmber,
                            ),
                            MeetingStatChip(
                              label: 'Open',
                              value: '${statusSummary.openCount}',
                              accentColor: AppColours.darkPrimary,
                            ),
                            MeetingStatChip(
                              label: 'Waiting',
                              value: '${statusSummary.waitingCount}',
                              accentColor: AppColours.darkPurple,
                            ),
                            MeetingStatChip(
                              label: 'Complete',
                              value: '${statusSummary.completeCount}',
                              accentColor: AppColours.darkSuccess,
                            ),
                          ],
                        ),
                      ],
                    ],
                  );

                  final actions = Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: wide ? WrapAlignment.end : WrapAlignment.start,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () =>
                            context.push(RouteNames.meetingDashboard),
                        icon: const Icon(Icons.open_in_new_outlined),
                        label: const Text('Open Meetings'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () =>
                            context.push(RouteNames.meetingSettings),
                        icon: const Icon(Icons.account_tree_outlined),
                        label: const Text('Open Hub'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => context.push(RouteNames.meetingNew),
                        icon: const Icon(Icons.add),
                        label: const Text('New Meeting'),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            context.push(RouteNames.meetingActions),
                        icon: const Icon(Icons.checklist_outlined),
                        label: const Text('Actions'),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            context.push(RouteNames.meetingTemplates),
                        icon: const Icon(Icons.description_outlined),
                        label: const Text('Templates'),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            context.push(RouteNames.meetingSettings),
                        icon: const Icon(Icons.settings_outlined),
                        label: const Text('Settings'),
                      ),
                      TextButton.icon(
                        onPressed:
                            _exportingLatestBundle || latestMeeting == null
                            ? null
                            : () => _exportLatestBundle(latestMeeting),
                        icon: _exportingLatestBundle
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.archive_outlined),
                        label: const Text('Export latest bundle'),
                      ),
                      TextButton.icon(
                        onPressed: _bootstrapping ? null : _createStructure,
                        icon: _bootstrapping
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.create_new_folder_outlined),
                        label: const Text('Starter files'),
                      ),
                      TextButton.icon(
                        onPressed: workspace.meetingsRootPath == null
                            ? null
                            : () => ref
                                  .read(meetingFolderServiceProvider)
                                  .openFolder(workspace.meetingsRootPath!),
                        icon: const Icon(Icons.folder_open_outlined),
                        label: const Text('Open folder'),
                      ),
                    ],
                  );

                  if (!wide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [summary, const SizedBox(height: 16), actions],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: summary),
                      const SizedBox(width: 20),
                      Flexible(child: actions),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createStructure() async {
    setState(() {
      _bootstrapping = true;
    });

    try {
      await ref
          .read(meetingFolderServiceProvider)
          .createMissingRequiredStructure();
      ref.invalidate(meetingDashboardSnapshotProvider);
    } finally {
      if (mounted) {
        setState(() {
          _bootstrapping = false;
        });
      }
    }
  }

  Future<void> _exportLatestBundle(MeetingRecord meeting) async {
    setState(() {
      _exportingLatestBundle = true;
    });

    try {
      final service = ref.read(meetingFolderServiceProvider);
      final result = await service.exportMeetingBundle(meeting.id);
      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.of(context);
      await service.openFolder(result.bundlePath);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Exported latest meeting bundle to ${result.bundlePath}',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not export the latest bundle: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _exportingLatestBundle = false;
        });
      }
    }
  }
}

class _MeetingBundleReviewCard extends StatelessWidget {
  const _MeetingBundleReviewCard({
    required this.latestMeeting,
    required this.bundleReview,
    required this.onExportLatestBundle,
    required this.onOpenBundleFolder,
    required this.onOpenSummary,
    required this.onOpenManifest,
  });

  final MeetingRecord latestMeeting;
  final MeetingBundleReviewSnapshot bundleReview;
  final VoidCallback? onExportLatestBundle;
  final VoidCallback onOpenBundleFolder;
  final VoidCallback onOpenSummary;
  final VoidCallback onOpenManifest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bundleFileName = path.basename(bundleReview.bundlePath);
    final summaryFileName = path.basename(bundleReview.summaryPath);
    final manifestFileName = path.basename(bundleReview.manifestPath);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          final header = wide
              ? Row(
                  children: [
                    const Icon(
                      Icons.folder_zip_outlined,
                      color: AppColours.darkAmber,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Latest bundle review',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColours.darkText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _InlineTag(
                      label: bundleReview.exists ? 'Ready' : 'Needs refresh',
                      accent: bundleReview.exists
                          ? AppColours.darkSuccess
                          : AppColours.darkAmber,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.folder_zip_outlined,
                          color: AppColours.darkAmber,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Latest bundle review',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColours.darkText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _InlineTag(
                      label: bundleReview.exists ? 'Ready' : 'Needs refresh',
                      accent: bundleReview.exists
                          ? AppColours.darkSuccess
                          : AppColours.darkAmber,
                    ),
                  ],
                );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 8),
              Text(
                latestMeeting.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _InlineTag(
                    label: '${bundleReview.fileCount} files',
                    accent: AppColours.darkPrimary,
                  ),
                  _InlineTag(
                    label: bundleReview.exists
                        ? 'Bundle found'
                        : 'Bundle missing',
                    accent: bundleReview.exists
                        ? AppColours.darkSuccess
                        : AppColours.darkAmber,
                  ),
                  _InlineTag(
                    label: bundleFileName,
                    accent: AppColours.darkSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Summary: $summaryFileName',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manifest: $manifestFileName',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (onExportLatestBundle != null)
                    FilledButton.tonalIcon(
                      onPressed: onExportLatestBundle,
                      icon: const Icon(Icons.archive_outlined),
                      label: const Text('Export latest bundle'),
                    ),
                  TextButton.icon(
                    onPressed: onOpenBundleFolder,
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const Text('Open bundle folder'),
                  ),
                  TextButton.icon(
                    onPressed: onOpenSummary,
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Open summary'),
                  ),
                  TextButton.icon(
                    onPressed: onOpenManifest,
                    icon: const Icon(Icons.article_outlined),
                    label: const Text('Open manifest'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class KnowledgeLibraryDashboardCard extends ConsumerStatefulWidget {
  const KnowledgeLibraryDashboardCard({super.key});

  @override
  ConsumerState<KnowledgeLibraryDashboardCard> createState() =>
      _KnowledgeLibraryDashboardCardState();
}

class _KnowledgeLibraryDashboardCardState
    extends ConsumerState<KnowledgeLibraryDashboardCard> {
  final KnowledgeLibraryRepository _repository = KnowledgeLibraryRepository();
  static const String _apiAddress = 'http://127.0.0.1:8787';

  KnowledgeLibraryHealth? _health;
  KnowledgeLibraryStats? _stats;
  KnowledgeLibraryExtractionStatus? _extractionStatus;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _repository.loadHealth(),
        _repository.loadStats(),
        _repository.loadExtractionStatus(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _health = results[0] as KnowledgeLibraryHealth;
        _stats = results[1] as KnowledgeLibraryStats;
        _extractionStatus = results[2] as KnowledgeLibraryExtractionStatus;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _refreshExtractionStatus() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final extractionStatus = await _repository.loadExtractionStatus();
      if (!mounted) {
        return;
      }

      setState(() {
        _extractionStatus = extractionStatus;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _openFailureReport() async {
    final extractionStatus = _extractionStatus;
    if (extractionStatus == null || extractionStatus.reportPath.isEmpty) {
      return;
    }

    try {
      await _repository.openFailureReport(extractionStatus.reportPath);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opened the extraction failure report.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the failure report: $error')),
      );
    }
  }

  Future<void> _copyModulePath() async {
    final moduleDirectory = _moduleDirectory();
    await Clipboard.setData(ClipboardData(text: moduleDirectory.path));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied module path: ${moduleDirectory.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final queueAsync = ref.watch(assetQrPrintQueueProvider);
    final bulkTemplatesAsync = ref.watch(assetQrBulkTemplatesProvider);
    final health = _health;
    final stats = _stats;
    final extractionStatus = _extractionStatus;
    final queueRows =
        queueAsync.asData?.value.rows ?? const <Map<String, String>>[];
    final queueCounts = _queueCounts(queueRows);
    final moduleDirectory = _moduleDirectory();
    final catalogueFile = File(
      '${moduleDirectory.path}${Platform.pathSeparator}08_LIBRARY_CATALOGUE'
      '${Platform.pathSeparator}pdf_catalogue.json',
    );
    final catalogueExists = catalogueFile.existsSync();
    final latestTemplateLabel = _latestBulkTemplateLabel(
      bulkTemplatesAsync.asData?.value.rows ?? const <Map<String, String>>[],
    );
    final isOffline = _error != null && _isApiConnectionIssue(_error);
    final qrHealthLabel = _qrHealthLabel(
      catalogueExists: catalogueExists,
      latestTemplateLabel: latestTemplateLabel,
      queueCounts: queueCounts,
      extractionStatus: extractionStatus,
      isOffline: isOffline,
    );
    final qrHealthAccent = _qrHealthAccent(
      latestTemplateLabel: latestTemplateLabel,
      queueCounts: queueCounts,
      catalogueExists: catalogueExists,
      extractionStatus: extractionStatus,
      isOffline: isOffline,
    );
    final statusColor = health?.isHealthy == true
        ? AppColours.darkSuccess
        : AppColours.darkAmber;
    final statusLabel = health?.isHealthy == true
        ? 'Ready'
        : isOffline
        ? 'Offline'
        : 'Needs attention';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context, highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 980;

          final overview = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.library_books_outlined,
                    color: AppColours.darkSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Knowledge Library',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _InlineTag(
                    label: statusLabel,
                    accent: statusColor,
                    foreground: statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Quick access to the Omega OS PDF archive with live health and catalogue counts.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _KnowledgeMetricChip(
                    label: 'PDFs',
                    value: stats == null ? '...' : '${stats.totalPdfs}',
                    accent: AppColours.darkSecondary,
                  ),
                  _KnowledgeMetricChip(
                    label: 'Text',
                    value: stats == null ? '...' : '${stats.textExtractable}',
                    accent: AppColours.darkSuccess,
                  ),
                  _KnowledgeMetricChip(
                    label: 'OCR',
                    value: stats == null ? '...' : '${stats.ocrRequired}',
                    accent: AppColours.darkAmber,
                  ),
                  _KnowledgeMetricChip(
                    label: 'Audio',
                    value: stats == null ? '...' : '${stats.audioGenerated}',
                    accent: AppColours.darkPurple,
                  ),
                  _KnowledgeMetricChip(
                    label: 'Extraction',
                    value: extractionStatus == null
                        ? '...'
                        : '${extractionStatus.extracted} / '
                              '${extractionStatus.ocrRequired} / '
                              '${extractionStatus.failed}',
                    accent: extractionStatus == null
                        ? AppColours.darkSecondary
                        : extractionStatus.hasFailures
                        ? AppColours.darkAmber
                        : AppColours.darkSuccess,
                  ),
                  _KnowledgeMetricChip(
                    label: 'Catalogue',
                    value: catalogueExists ? 'Ready' : 'Missing',
                    accent: catalogueExists
                        ? AppColours.darkSuccess
                        : AppColours.darkAmber,
                  ),
                  _KnowledgeMetricChip(
                    label: 'Print Queue',
                    value: queueAsync.isLoading
                        ? '...'
                        : '${queueCounts.ready} / ${queueCounts.printed} / ${queueCounts.applied}',
                    accent: queueCounts.hasAny
                        ? AppColours.darkSecondary
                        : AppColours.darkMutedText,
                  ),
                  _KnowledgeMetricChip(
                    label: 'Retry',
                    value: queueAsync.isLoading
                        ? '...'
                        : '${queueCounts.retry}',
                    accent: queueCounts.retry > 0
                        ? AppColours.darkAmber
                        : AppColours.darkMutedText,
                  ),
                  _KnowledgeMetricChip(
                    label: 'Template',
                    value: bulkTemplatesAsync.isLoading
                        ? '...'
                        : latestTemplateLabel,
                    accent: latestTemplateLabel == 'No saved template'
                        ? AppColours.darkMutedText
                        : AppColours.darkSecondary,
                  ),
                  _KnowledgeMetricChip(
                    label: 'QR Health',
                    value: qrHealthLabel,
                    accent: qrHealthAccent,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _loading
                    ? 'Refreshing local module status...'
                    : health?.message.isNotEmpty == true
                    ? health!.message
                    : isOffline
                    ? 'The Knowledge Library API is offline. Start it locally and refresh the card.'
                    : _error == null
                    ? 'Local module status loaded successfully.'
                    : 'Knowledge Library needs attention before it can report live status.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      queueCounts.hasAny
                          ? 'QR print queue: ${queueCounts.ready} ready, ${queueCounts.retry} retry, ${queueCounts.printed} printed, ${queueCounts.applied} applied.'
                          : 'QR print queue is empty right now.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: () => context.push(RouteNames.assetQrPrintQueue),
                    icon: const Icon(Icons.playlist_add_check),
                    label: const Text('Open Print Queue'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      catalogueExists
                          ? 'Catalogue JSON is ready at 08_LIBRARY_CATALOGUE/pdf_catalogue.json.'
                          : 'Catalogue JSON has not been built yet. Run the scanner and catalogue builder.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                        height: 1.35,
                      ),
                    ),
                  ),
                  if (extractionStatus != null) ...[
                    const SizedBox(width: 10),
                    TextButton.icon(
                      onPressed: _loading ? null : _refreshExtractionStatus,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Refresh Extraction'),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      'Module folder: ${moduleDirectory.path}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColours.darkSecondary,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: _copyModulePath,
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy Module Path'),
                  ),
                ],
              ),
              if (extractionStatus != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Extracted ${extractionStatus.extracted} PDFs, '
                  '${extractionStatus.ocrRequired} need OCR, '
                  '${extractionStatus.failed} failed so far.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
                  ),
                ),
              ],
              if (_error != null && !isOffline) ...[
                const SizedBox(height: 8),
                Text(
                  _error.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
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
                onPressed: () => context.push(RouteNames.knowledgeLibrary),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open Library'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go(RouteNames.dashboard),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back to Dashboard'),
              ),
              FilledButton.tonalIcon(
                onPressed: _openModuleFolder,
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Open Module Folder'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push(RouteNames.assetQrLabelHistory),
                icon: const Icon(Icons.history_outlined),
                label: const Text('Open QR History'),
              ),
              FilledButton.icon(
                onPressed: _runStartupScript,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Run Startup Script'),
              ),
              if (catalogueExists)
                OutlinedButton.icon(
                  onPressed: _openCatalogueFile,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Open Catalogue'),
                ),
              TextButton.icon(
                onPressed: _loading ? null : _refresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh'),
              ),
              OutlinedButton.icon(
                onPressed: _copySetupSequence,
                icon: const Icon(Icons.content_copy_rounded),
                label: const Text('Copy Setup'),
              ),
              if (extractionStatus != null)
                OutlinedButton.icon(
                  onPressed: _openFailureReport,
                  icon: const Icon(Icons.report_outlined),
                  label: const Text('Open Failure Report'),
                ),
              if (isOffline)
                OutlinedButton.icon(
                  onPressed: () async {
                    await _copyText(
                      text: _startCommand(moduleDirectory),
                      successMessage:
                          'Copied the Knowledge Library start command.',
                    );
                  },
                  icon: const Icon(Icons.content_copy_rounded),
                  label: const Text('Copy Start Command'),
                )
              else
                OutlinedButton.icon(
                  onPressed: () async {
                    await _copyText(
                      text: _apiAddress,
                      successMessage:
                          'Copied the Knowledge Library API address.',
                    );
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy API'),
                ),
            ],
          );

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [overview, const SizedBox(height: 16), actions],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: overview),
              const SizedBox(width: 20),
              SizedBox(width: 260, child: actions),
            ],
          );
        },
      ),
    );
  }

  bool _isApiConnectionIssue(Object? error) {
    final text = error.toString().toLowerCase();
    return text.contains('connection refused') ||
        text.contains('socketexception') ||
        text.contains('127.0.0.1') ||
        text.contains('localhost');
  }

  Directory _moduleDirectory() {
    final workspaceRoot = _workspaceRootDirectory();
    return Directory(
      '${workspaceRoot.path}${Platform.pathSeparator}modules${Platform.pathSeparator}knowledge_engine',
    );
  }

  Directory _workspaceRootDirectory() {
    var directory = Directory.current;

    while (true) {
      final candidate = Directory(
        '${directory.path}${Platform.pathSeparator}modules${Platform.pathSeparator}knowledge_engine',
      );
      if (candidate.existsSync()) {
        return directory;
      }

      final parent = directory.parent;
      if (parent.path == directory.path) {
        return Directory.current;
      }

      directory = parent;
    }
  }

  String _startCommandSequence(Directory moduleDirectory) {
    return [
      _startCommand(moduleDirectory),
      'python -m venv .venv',
      'Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass',
      '.\\.venv\\Scripts\\Activate.ps1',
      'python -m pip install -r requirements.txt',
      'python scripts\\setup_omega_folders.py',
      'python scripts\\scan_library.py',
      'python scripts\\extract_text.py',
      'python scripts\\build_catalogue.py',
      'uvicorn api.main:app --reload --port 8787',
    ].join('\n');
  }

  String _startCommand(Directory moduleDirectory) {
    return [
      'Set-Location "${moduleDirectory.path}"',
      'uvicorn api.main:app --reload --port 8787',
    ].join('\n');
  }

  Future<void> _copySetupSequence() async {
    await _copyText(
      text: _startCommandSequence(_moduleDirectory()),
      successMessage: 'Copied the full Knowledge Library setup sequence.',
    );
  }

  Future<void> _copyText({
    required String text,
    required String successMessage,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }

    messenger.showSnackBar(SnackBar(content: Text(successMessage)));
  }

  _QueueCounts _queueCounts(List<Map<String, String>> rows) {
    var ready = 0;
    var retry = 0;
    var printed = 0;
    var applied = 0;

    for (final row in rows) {
      final status = (row['status'] ?? '').trim().toLowerCase();
      switch (status) {
        case 'generated':
        case 'queued':
          ready += 1;
          break;
        case 'reprint_needed':
          retry += 1;
          break;
        case 'printed':
          printed += 1;
          break;
        case 'applied':
          applied += 1;
          break;
      }
    }

    return _QueueCounts(
      ready: ready,
      retry: retry,
      printed: printed,
      applied: applied,
    );
  }

  String _latestBulkTemplateLabel(List<Map<String, String>> rows) {
    if (rows.isEmpty) {
      return 'No saved template';
    }

    final templates =
        rows.map(QrBulkTemplate.fromCsvRow).toList(growable: false)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final latestName = templates.first.templateName.trim();
    return latestName.isEmpty ? 'No saved template' : latestName;
  }

  String _qrHealthLabel({
    required bool catalogueExists,
    required String latestTemplateLabel,
    required _QueueCounts queueCounts,
    required KnowledgeLibraryExtractionStatus? extractionStatus,
    required bool isOffline,
  }) {
    if (isOffline) {
      return 'Offline';
    }

    if (!catalogueExists) {
      return 'Setup needed';
    }

    if (extractionStatus?.hasFailures == true) {
      return 'Review failures';
    }

    if (queueCounts.retry > 0) {
      return 'Retry pending';
    }

    if (queueCounts.ready > 0) {
      return 'Ready to print';
    }

    if (latestTemplateLabel == 'No saved template') {
      return 'Template needed';
    }

    return 'Ready';
  }

  Color _qrHealthAccent({
    required bool catalogueExists,
    required String latestTemplateLabel,
    required _QueueCounts queueCounts,
    required KnowledgeLibraryExtractionStatus? extractionStatus,
    required bool isOffline,
  }) {
    if (isOffline || !catalogueExists) {
      return AppColours.darkAmber;
    }

    if (extractionStatus?.hasFailures == true || queueCounts.retry > 0) {
      return AppColours.darkAmber;
    }

    if (queueCounts.ready > 0 || latestTemplateLabel != 'No saved template') {
      return AppColours.darkSuccess;
    }

    return AppColours.darkSecondary;
  }

  Future<void> _openModuleFolder() async {
    final moduleDirectory = _moduleDirectory();
    if (!moduleDirectory.existsSync()) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not find the Knowledge Engine module folder.'),
        ),
      );
      return;
    }

    if (Platform.isWindows) {
      await Process.start('explorer.exe', [moduleDirectory.path]);
      return;
    }

    if (Platform.isMacOS) {
      await Process.start('open', [moduleDirectory.path]);
      return;
    }

    if (Platform.isLinux) {
      await Process.start('xdg-open', [moduleDirectory.path]);
    }
  }

  Future<void> _openCatalogueFile() async {
    final catalogueFile = File(
      '${_moduleDirectory().path}${Platform.pathSeparator}08_LIBRARY_CATALOGUE'
      '${Platform.pathSeparator}pdf_catalogue.json',
    );

    if (!catalogueFile.existsSync()) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The catalogue JSON is not available yet.'),
        ),
      );
      return;
    }

    if (Platform.isWindows) {
      await Process.start('explorer.exe', ['/select,${catalogueFile.path}']);
      return;
    }

    if (Platform.isMacOS) {
      await Process.start('open', [catalogueFile.path]);
      return;
    }

    if (Platform.isLinux) {
      await Process.start('xdg-open', [catalogueFile.path]);
    }
  }

  Future<void> _runStartupScript() async {
    if (!Platform.isWindows) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The startup script button is currently Windows-only.'),
        ),
      );
      return;
    }

    final scriptFile = File(
      '${_moduleDirectory().path}${Platform.pathSeparator}start_knowledge_engine.ps1',
    );

    if (!scriptFile.existsSync()) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not find start_knowledge_engine.ps1.'),
        ),
      );
      return;
    }

    try {
      await Process.start('cmd.exe', [
        '/c',
        'start',
        '""',
        'powershell.exe',
        '-NoLogo',
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-NoExit',
        '-File',
        scriptFile.path,
      ], workingDirectory: _moduleDirectory().path);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Knowledge Engine startup window opened.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch the startup script: $error')),
      );
    }
  }
}

class _DashboardFocusCard extends ConsumerStatefulWidget {
  const _DashboardFocusCard({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  ConsumerState<_DashboardFocusCard> createState() =>
      _DashboardFocusCardState();
}

class _DashboardFocusCardState extends ConsumerState<_DashboardFocusCard> {
  late final TextEditingController _mainFocusController;
  late final TextEditingController _focusReasonController;
  late final TextEditingController _morningIntentionController;

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _mainFocusController = TextEditingController(
      text: widget.snapshot.mainFocus ?? '',
    );
    _focusReasonController = TextEditingController(
      text: widget.snapshot.focusReason ?? '',
    );
    _morningIntentionController = TextEditingController(
      text: widget.snapshot.morningIntention ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _DashboardFocusCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.snapshot.mainFocus != widget.snapshot.mainFocus) {
      _mainFocusController.text = widget.snapshot.mainFocus ?? '';
    }
    if (oldWidget.snapshot.focusReason != widget.snapshot.focusReason) {
      _focusReasonController.text = widget.snapshot.focusReason ?? '';
    }
    if (oldWidget.snapshot.morningIntention !=
        widget.snapshot.morningIntention) {
      _morningIntentionController.text = widget.snapshot.morningIntention ?? '';
    }
  }

  @override
  void dispose() {
    _mainFocusController.dispose();
    _focusReasonController.dispose();
    _morningIntentionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFocus = widget.snapshot.mainFocus?.isNotEmpty == true;
    final hasReason = widget.snapshot.focusReason?.isNotEmpty == true;
    final hasIntention = widget.snapshot.morningIntention?.isNotEmpty == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final actions = [
                TextButton.icon(
                  key: const Key('dashboardFocusEditButton'),
                  onPressed: _isSaving
                      ? null
                      : () {
                          setState(() {
                            _isEditing = !_isEditing;
                            if (!_isEditing) {
                              _mainFocusController.text =
                                  widget.snapshot.mainFocus ?? '';
                              _focusReasonController.text =
                                  widget.snapshot.focusReason ?? '';
                              _morningIntentionController.text =
                                  widget.snapshot.morningIntention ?? '';
                            }
                          });
                        },
                  icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
                  label: Text(_isEditing ? 'Close' : 'Quick Edit'),
                ),
                TextButton.icon(
                  key: const Key('dashboardFocusClearButton'),
                  onPressed: _isSaving ? null : () => _clearFocus(context),
                  icon: const Icon(Icons.clear_outlined),
                  label: const Text('Clear Focus'),
                ),
              ];

              if (constraints.maxWidth < 360) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _PanelTitle(
                      title: 'Today\'s Focus',
                      icon: Icons.flag_outlined,
                    ),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: actions),
                  ],
                );
              }

              return Row(
                children: [
                  const _PanelTitle(
                    title: 'Today\'s Focus',
                    icon: Icons.flag_outlined,
                  ),
                  const Spacer(),
                  Wrap(spacing: 8, runSpacing: 8, children: actions),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          if (_isEditing) ...[
            TextField(
              key: const Key('dashboardMainFocusField'),
              controller: _mainFocusController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Main Focus'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('dashboardFocusReasonField'),
              controller: _focusReasonController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Why It Matters'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('dashboardMorningIntentionField'),
              controller: _morningIntentionController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Morning Intention'),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              key: const Key('dashboardFocusSaveButton'),
              onPressed: _isSaving ? null : () => _save(context),
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Save Focus'),
            ),
          ] else ...[
            Text(
              hasFocus
                  ? widget.snapshot.mainFocus!
                  : 'A blank daily plan is ready. One calm choice will start the day.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColours.darkText,
              ),
            ),
            const SizedBox(height: 16),
            _FocusDetailRow(
              label: 'Why It Matters',
              value: hasReason
                  ? widget.snapshot.focusReason!
                  : 'Add one short reason to keep the day grounded.',
            ),
            const SizedBox(height: 12),
            _FocusDetailRow(
              label: 'Morning Intention',
              value: hasIntention
                  ? widget.snapshot.morningIntention!
                  : 'A short intention can make the morning feel steadier.',
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    setState(() => _isSaving = true);

    try {
      final plannerController = ref.read(plannerControllerProvider);
      await plannerController.saveMainFocus(_mainFocusController.text);
      await plannerController.saveFocusReason(_focusReasonController.text);
      await plannerController.saveMorningIntention(
        _morningIntentionController.text,
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Today\'s focus saved.')));
      setState(() => _isEditing = false);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _clearFocus(BuildContext context) async {
    setState(() => _isSaving = true);

    try {
      await ref.read(plannerControllerProvider).clearFocus();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Today\'s focus cleared.')));
      setState(() => _isEditing = false);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _ActiveProjectsPanel extends StatelessWidget {
  const _ActiveProjectsPanel({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final projects = snapshot.activeProjects;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _PanelTitle(
                title: 'Active Projects',
                icon: Icons.folder_copy_outlined,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go(RouteNames.projectsWorkspace),
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (projects.isEmpty)
            Text(
              '${snapshot.activeProjectCount} projects are available.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            )
          else
            Column(
              children: [
                for (var index = 0; index < projects.length; index++) ...[
                  _ProjectProgressRow(project: projects[index]),
                  if (index != projects.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _DashboardEveningReviewCard extends ConsumerWidget {
  const _DashboardEveningReviewCard({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCarryForward =
        snapshot.carryForwardNotes?.trim().isNotEmpty == true;
    final hasTomorrowFocus = snapshot.tomorrowFocus?.trim().isNotEmpty == true;
    final hasReview = snapshot.hasEveningReview;
    final headline = hasReview
        ? 'The day-close handoff is already in motion.'
        : 'Record what moved forward before the day ends.';
    final buttonLabel = hasReview || hasCarryForward || hasTomorrowFocus
        ? 'Continue Planner'
        : 'Start Evening Review';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.nightlight_round, color: AppColours.darkPurple),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Evening Review',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColours.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      headline,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                key: const Key('dashboardStartEveningReviewButton'),
                onPressed: () =>
                    context.go('${RouteNames.planner}?section=review'),
                icon: const Icon(Icons.nightlight_round),
                label: Text(buttonLabel),
              ),
            ],
          ),
          if (hasReview || hasCarryForward || hasTomorrowFocus) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (hasReview)
                  const _InlineTag(
                    label: 'Review saved',
                    accent: AppColours.darkSuccess,
                    foreground: AppColours.darkSuccess,
                  ),
                if (hasCarryForward)
                  const _InlineTag(
                    label: 'Carry forward noted',
                    accent: AppColours.darkAmber,
                    foreground: AppColours.darkAmber,
                  ),
                if (hasTomorrowFocus)
                  const _InlineTag(
                    label: 'Tomorrow queued',
                    accent: AppColours.darkSecondary,
                    foreground: AppColours.darkSecondary,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasTomorrowFocus)
              _DashboardReviewLine(
                label: 'Tomorrow\'s likely focus',
                value: snapshot.tomorrowFocus!,
              ),
            if (hasCarryForward) ...[
              const SizedBox(height: 10),
              _DashboardReviewLine(
                label: 'Carry forward',
                value: snapshot.carryForwardNotes!,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (hasCarryForward)
                  FilledButton.tonalIcon(
                    key: const Key('dashboardReviewParkedButton'),
                    onPressed: () => _openParkedTasks(ref, context),
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: const Text('Review Parked'),
                  ),
                TextButton.icon(
                  key: const Key('dashboardOpenTasksHandoffButton'),
                  onPressed: () => _openTasks(ref, context),
                  icon: const Icon(Icons.task_alt_outlined),
                  label: const Text('Open Tasks'),
                ),
                TextButton.icon(
                  key: const Key('dashboardOpenProjectsHandoffButton'),
                  onPressed: () => context.go(RouteNames.projectsWorkspace),
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Open Projects'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _openParkedTasks(WidgetRef ref, BuildContext context) {
    ref.read(selectedTaskStatusFilterProvider.notifier).setFilter('Parked');
    ref.read(selectedTaskProjectFilterProvider.notifier).setFilter(null);
    ref.read(taskSearchQueryProvider.notifier).clear();
    context.go(RouteNames.tasks);
  }

  void _openTasks(WidgetRef ref, BuildContext context) {
    ref.read(selectedTaskStatusFilterProvider.notifier).setFilter('All');
    ref.read(selectedTaskProjectFilterProvider.notifier).setFilter(null);
    ref.read(taskSearchQueryProvider.notifier).clear();
    context.go(RouteNames.tasks);
  }
}

class _DashboardReviewLine extends StatelessWidget {
  const _DashboardReviewLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColours.darkText),
          ),
        ],
      ),
    );
  }
}

class _DashboardQuickCaptureCard extends ConsumerStatefulWidget {
  const _DashboardQuickCaptureCard();

  @override
  ConsumerState<_DashboardQuickCaptureCard> createState() =>
      _DashboardQuickCaptureCardState();
}

class _DashboardQuickCaptureCardState
    extends ConsumerState<_DashboardQuickCaptureCard> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _PanelTitle(
                title: 'Quick Capture',
                icon: Icons.add_circle_outline,
              ),
              const Spacer(),
              _InlineTag(
                label: 'Fast lane',
                accent: AppColours.darkSecondary,
                foreground: AppColours.darkSecondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Capture one thought quickly, then return to the day.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            decoration: BoxDecoration(
              color: AppColours.darkSurfaceAlt.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColours.darkOutline),
            ),
            child: Text(
              'Add a task, note, or idea...',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _CaptureTypeChip(label: 'Task'),
              _CaptureTypeChip(label: 'Note'),
              _CaptureTypeChip(label: 'Idea', selected: true),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('dashboardQuickCaptureButton'),
            onPressed: _isSaving ? null : () => _openQuickCapture(),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Open Capture'),
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            key: const Key('dashboardVoiceCaptureButton'),
            onPressed: () => context.push(RouteNames.voice),
            icon: const Icon(Icons.mic_none_rounded),
            label: const Text('Open Voice'),
          ),
        ],
      ),
    );
  }

  Future<void> _openQuickCapture() async {
    final result = await showDialog<_QuickCaptureDraft>(
      context: context,
      builder: (dialogContext) => const _QuickCaptureDialog(),
    );

    if (result == null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final item = await ref
          .read(inboxActionsControllerProvider)
          .createItem(
            title: result.title,
            body: result.body,
            type: result.type,
            status: 'New',
          );

      if (!mounted) {
        return;
      }

      final label = item.title ?? item.body ?? 'Inbox item saved.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$label saved to Inbox.')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _QuickCaptureDraft {
  const _QuickCaptureDraft({this.title, this.body, this.type});

  final String? title;
  final String? body;
  final String? type;
}

class _QuickCaptureDialog extends StatefulWidget {
  const _QuickCaptureDialog();

  @override
  State<_QuickCaptureDialog> createState() => _QuickCaptureDialogState();
}

class _QuickCaptureDialogState extends State<_QuickCaptureDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  String? _type;

  static const _typeOptions = [
    'Task',
    'Idea',
    'Journal Note',
    'Content Idea',
    'Learning Note',
    'Business Opportunity',
    'Future Idea',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quick Capture'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('dashboardQuickCaptureTitleField'),
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'What is it?',
                  hintText: 'Task title, idea, or note',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('dashboardQuickCaptureBodyField'),
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Add a note',
                  hintText: 'A short detail is enough',
                ),
                minLines: 3,
                maxLines: 5,
                validator: (value) {
                  final title = _titleController.text.trim();
                  final body = value?.trim() ?? '';
                  if (title.isEmpty && body.isEmpty) {
                    return 'Please enter a title or body.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                key: const Key('dashboardQuickCaptureTypeField'),
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Capture type'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No type selected'),
                  ),
                  ..._typeOptions.map(
                    (type) => DropdownMenuItem<String?>(
                      value: type,
                      child: Text(type),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _type = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('dashboardQuickCaptureSaveButton'),
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            Navigator.of(context).pop(
              _QuickCaptureDraft(
                title: _optionalText(_titleController.text),
                body: _optionalText(_bodyController.text),
                type: _type,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  String? _optionalText(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}

class _ShowcaseTaskCard extends ConsumerWidget {
  const _ShowcaseTaskCard({required this.snapshotTask, required this.state});

  final DashboardTopTask? snapshotTask;
  final _ShowcaseTaskState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasTask = snapshotTask != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.94),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: state.accent.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: state.accent.withValues(alpha: 0.86),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  state.badge,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkBackground,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              if (hasTask)
                Row(
                  children: [
                    IconButton(
                      key: Key('dashboardTopTaskDone-${snapshotTask!.taskId}'),
                      onPressed: () async {
                        await ref
                            .read(tasksControllerProvider)
                            .markTaskDone(snapshotTask!.taskId);
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      color: AppColours.darkText,
                      tooltip: 'Mark done',
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      key: Key(
                        'dashboardTopTaskRemove-${snapshotTask!.taskId}',
                      ),
                      onPressed: () async {
                        await ref
                            .read(tasksControllerProvider)
                            .removeFromTopThree(snapshotTask!.taskId);
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColours.darkMutedText,
                      tooltip: 'Remove from Top 3',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            state.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InlineTag(label: state.label, accent: state.accent),
              if (hasTask && snapshotTask!.projectName != null) ...[
                _InlineTag(
                  label: snapshotTask!.projectName!,
                  accent: AppColours.darkSurfaceRaised,
                  foreground: AppColours.darkText,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectProgressRow extends StatelessWidget {
  const _ProjectProgressRow({required this.project});

  final DashboardProjectSummary project;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(RouteNames.projectDetail(project.projectId)),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${project.progressPercentage}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: project.progressPercentage / 100,
                backgroundColor: AppColours.darkSurfaceAlt,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColours.darkSecondary,
                ),
              ),
            ),
            if ((project.nextAction ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                project.nextAction!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniModuleCard extends StatelessWidget {
  const _MiniModuleCard({required this.state});

  final _MiniModuleState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.94),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: state.accent.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: state.accent.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: state.accent.withValues(alpha: 0.32),
                  ),
                ),
                child: Icon(state.icon, size: 14, color: state.accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  state.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (state.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              state.description,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _KnowledgeMetricChip extends StatelessWidget {
  const _KnowledgeMetricChip({
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
      constraints: const BoxConstraints(minWidth: 116),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardFooter extends StatelessWidget {
  const _DashboardFooter({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColours.darkSurface.withValues(alpha: 0.94)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_outlined, color: AppColours.darkSuccess),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Small steps move the mission forward without adding pressure.',
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

class _HeaderMetricChip extends StatelessWidget {
  const _HeaderMetricChip({
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
      constraints: const BoxConstraints(minWidth: 118),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
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

class _FocusDetailRow extends StatelessWidget {
  const _FocusDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColours.darkSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: foreground ?? accent,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueCounts {
  const _QueueCounts({
    required this.ready,
    required this.retry,
    required this.printed,
    required this.applied,
  });

  final int ready;
  final int retry;
  final int printed;
  final int applied;

  bool get hasAny => ready + retry + printed + applied > 0;
}

class _CaptureTypeChip extends StatelessWidget {
  const _CaptureTypeChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final accent = selected ? AppColours.darkPrimary : AppColours.darkMutedText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: selected
            ? AppColours.darkPrimary.withValues(alpha: 0.14)
            : AppColours.darkSurfaceAlt.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? AppColours.darkPrimary : AppColours.darkOutline,
        ),
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

class _ShowcaseTaskState {
  const _ShowcaseTaskState({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.label,
    required this.accent,
  });

  factory _ShowcaseTaskState.fromTask({
    required int index,
    required DashboardTopTask? task,
  }) {
    const accents = [
      AppColours.darkSecondary,
      AppColours.darkSuccess,
      AppColours.darkPurple,
    ];
    final accent = accents[index];
    if (task == null) {
      return _ShowcaseTaskState(
        badge: '${index + 1}',
        title: 'Choose another priority task',
        subtitle: 'There is still room in your Top 3 for today.',
        label: 'Open slot',
        accent: accent,
      );
    }

    return _ShowcaseTaskState(
      badge: '${index + 1}',
      title: task.title,
      subtitle: '${task.status} • Priority ${task.priority}',
      label: task.projectName ?? 'Top 3 Task',
      accent: accent,
    );
  }

  final String badge;
  final String title;
  final String subtitle;
  final String label;
  final Color accent;
}

class _MiniModuleState {
  const _MiniModuleState({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accent;
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          'Dashboard could not be loaded. Try again in a moment.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

LaunchpadCampaignRecord _launchpadFallbackCampaign() {
  final now = DateTime.now();
  return LaunchpadCampaignRecord(
    id: '',
    name: 'No campaigns',
    project: '',
    type: 'other',
    status: LaunchpadCampaignStatus.idea,
    fundingGoalGbp: 0,
    launchDate: null,
    owner: '',
    summary: '',
    createdAt: now,
    updatedAt: now,
    progressPercentage: 0,
    rewards: const <LaunchpadRewardTier>[],
    storyBlocks: const <LaunchpadStoryBlock>[],
    readinessItems: const <LaunchpadReadinessItem>[],
    risks: const <LaunchpadRiskRecord>[],
    phase2Records: const <LaunchpadPhase2Record>[],
    finance: const LaunchpadCampaignFinanceModel(
      fundingGoalGbp: 0,
      manufacturingCostsGbp: 0,
      shippingGbp: 0,
      vatPercent: 0,
      kickstarterFeePercent: 0,
      paymentFeePercent: 0,
      contingencyPercent: 0,
      fixedCostsGbp: 0,
    ),
  );
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

class _StatusPulseStrip extends StatefulWidget {
  const _StatusPulseStrip({required this.color, required this.animate});

  final Color color;
  final bool animate;

  @override
  State<_StatusPulseStrip> createState() => _StatusPulseStripState();
}

class _StatusPulseStripState extends State<_StatusPulseStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _StatusPulseStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = Tween<double>(begin: 0.55, end: 1.0).animate(_controller);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = widget.animate ? animation.value : 1.0;
        return Container(
          height: 6,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: opacity * 0.18),
                blurRadius: widget.animate ? 10 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
      },
    );
  }
}
