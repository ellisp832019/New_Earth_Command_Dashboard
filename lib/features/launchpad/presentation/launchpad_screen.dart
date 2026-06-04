import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/launchpad_controller.dart';
import '../data/launchpad_calculator.dart';
import '../data/launchpad_phase2_models.dart';
import '../data/launchpad_models.dart';
import 'launchpad_phase2_sections.dart';

class LaunchpadOverviewScreen extends ConsumerWidget {
  const LaunchpadOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(launchpadWorkspaceProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to Dashboard',
          onPressed: () => context.go(RouteNames.dashboard),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Launchpad'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(launchpadWorkspaceProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _LaunchpadError(
          message: error.toString(),
          onRetry: () => ref.invalidate(launchpadWorkspaceProvider),
        ),
        data: (workspace) {
          final activeCampaign = workspace.campaigns.firstWhere(
            (campaign) => campaign.status != LaunchpadCampaignStatus.archived,
            orElse: () => workspace.campaigns.isEmpty
                ? _placeholderCampaign()
                : workspace.campaigns.first,
          );
          final readiness = calculateLaunchpadReadinessSummary(
            activeCampaign.readinessItems,
          );
          final finance = calculateLaunchpadFinancialSummary(activeCampaign);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _OverviewHero(
                workspace: workspace,
                activeCampaign: activeCampaign,
                readiness: readiness,
                finance: finance,
                onCreateCampaign: () => _showCampaignDialog(
                  context: context,
                  ref: ref,
                ),
              ),
              const SizedBox(height: 16),
              _SectionHeader(
                title: 'Campaigns',
                subtitle:
                    'Launchpad keeps campaign operations local-first and calmly editable.',
              ),
              const SizedBox(height: 12),
              if (workspace.campaigns.isEmpty)
                const _EmptyPanel(
                  title: 'No campaigns yet',
                  body: 'Create the first campaign from the Launchpad hero.',
                )
              else
                ...workspace.campaigns.map(
                  (campaign) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CampaignCard(
                      campaign: campaign,
                      onOpen: () => context.go(
                        RouteNames.launchpadCampaign(campaign.id),
                      ),
                      onEdit: () => _showCampaignDialog(
                        context: context,
                        ref: ref,
                        campaign: campaign,
                      ),
                      onArchive: campaign.status == LaunchpadCampaignStatus.archived
                          ? null
                          : () async {
                              await ref
                                  .read(launchpadRepositoryProvider)
                                  .archiveCampaign(campaign.id);
                              ref.invalidate(launchpadWorkspaceProvider);
                            },
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              _SectionHeader(
                title: 'Workspace snapshot',
                subtitle:
                    'Readiness and finance stay visible at a glance so the launch does not drift.',
              ),
              const SizedBox(height: 12),
              _WorkspaceSummaryGrid(
                readiness: readiness,
                finance: finance,
                campaignCount: workspace.campaigns.length,
                activeCount: workspace.campaigns
                    .where(
                      (campaign) =>
                          campaign.status != LaunchpadCampaignStatus.archived,
                    )
                    .length,
              ),
            ],
          );
        },
      ),
    );
  }
}

class LaunchpadCampaignScreen extends ConsumerStatefulWidget {
  const LaunchpadCampaignScreen({
    required this.campaignId,
    required this.section,
    super.key,
  });

  final String campaignId;
  final String section;

  @override
  ConsumerState<LaunchpadCampaignScreen> createState() =>
      _LaunchpadCampaignScreenState();
}

class _LaunchpadCampaignScreenState extends ConsumerState<LaunchpadCampaignScreen> {
  @override
  Widget build(BuildContext context) {
    final workspaceSnapshot = ref.watch(launchpadWorkspaceProvider);
    final sectionLabel = launchpadCampaignSectionLabel(widget.section);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to Launchpad',
          onPressed: () => context.go(RouteNames.launchpad),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(sectionLabel),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(launchpadWorkspaceProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: workspaceSnapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _LaunchpadError(
          message: error.toString(),
          onRetry: () => ref.invalidate(launchpadWorkspaceProvider),
        ),
        data: (workspace) {
          final campaign = workspace.campaignById(widget.campaignId);
          if (campaign == null) {
            return _LaunchpadError(
              message: 'Campaign not found: ${widget.campaignId}',
              onRetry: () => ref.invalidate(launchpadWorkspaceProvider),
            );
          }

          final sections = _launchpadSections(widget.campaignId);
          final readiness = calculateLaunchpadReadinessSummary(
            campaign.readinessItems,
          );
          final finance = calculateLaunchpadFinancialSummary(campaign);

          return LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1060;
              final content = _buildSectionContent(
                context: context,
                ref: ref,
                workspace: workspace,
                campaign: campaign,
                readiness: readiness,
                finance: finance,
              );

              final navigation = _LaunchpadSectionRail(
                sections: sections,
                selectedSection: widget.section,
                onSelected: (section) {
                  context.go(RouteNames.launchpadCampaignSection(
                    widget.campaignId,
                    section,
                  ));
                },
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 260, child: navigation),
                    const SizedBox(width: 18),
                    Expanded(child: content),
                  ],
                );
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  navigation,
                  const SizedBox(height: 16),
                  content,
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionContent({
    required BuildContext context,
    required WidgetRef ref,
    required LaunchpadWorkspace workspace,
    required LaunchpadCampaignRecord campaign,
    required LaunchpadReadinessSummary readiness,
    required LaunchpadFinancialSummary finance,
  }) {
    switch (widget.section) {
      case 'campaigns':
        return _CampaignManagerSection(
          campaign: campaign,
          readiness: readiness,
          finance: finance,
          onEdit: () => _showCampaignDialog(
            context: context,
            ref: ref,
            campaign: campaign,
          ),
          onArchive: campaign.status == LaunchpadCampaignStatus.archived
              ? null
              : () async {
                  await ref.read(launchpadRepositoryProvider).archiveCampaign(
                    campaign.id,
                  );
                  ref.invalidate(launchpadWorkspaceProvider);
                },
          onDelete: () async {
            await ref.read(launchpadRepositoryProvider).deleteCampaign(
              campaign.id,
            );
            ref.invalidate(launchpadWorkspaceProvider);
            if (context.mounted) {
              context.go(RouteNames.launchpad);
            }
          },
        );
      case 'rewards':
        return _RewardManagerSection(
          campaign: campaign,
          onChanged: (rewards) async {
            await ref.read(launchpadRepositoryProvider).saveRewards(
              campaign.id,
              rewards,
            );
            ref.invalidate(launchpadWorkspaceProvider);
          },
        );
      case 'story-builder':
        return _StoryBuilderSection(
          campaign: campaign,
          onSave: (blocks) async {
            await ref.read(launchpadRepositoryProvider).saveStoryBlocks(
              campaign.id,
              blocks,
            );
            ref.invalidate(launchpadWorkspaceProvider);
          },
          onExport: () async {
            final path = await ref
                .read(launchpadRepositoryProvider)
                .exportStoryMarkdown(campaign.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Exported to $path')),
              );
            }
          },
        );
      case 'financial-modeller':
        return _FinancialModellerSection(
          campaign: campaign,
          finance: finance,
          onSave: (updatedFinance) async {
            await ref.read(launchpadRepositoryProvider).saveFinanceModel(
              campaign.id,
              updatedFinance,
            );
            ref.invalidate(launchpadWorkspaceProvider);
          },
        );
      case 'risk-register':
        return _RiskRegisterSection(
          campaign: campaign,
          onChanged: (risks) async {
            await ref.read(launchpadRepositoryProvider).saveRisks(
              campaign.id,
              risks,
            );
            ref.invalidate(launchpadWorkspaceProvider);
          },
        );
      case 'readiness':
        return _ReadinessSection(
          campaign: campaign,
          readiness: readiness,
          onChanged: (items) async {
            await ref.read(launchpadRepositoryProvider).saveReadinessItems(
              campaign.id,
              items,
            );
            ref.invalidate(launchpadWorkspaceProvider);
          },
        );
      case 'archive':
        return _ArchiveSection(
          workspace: workspace,
          onRestore: (campaignId) async {
            await ref.read(launchpadRepositoryProvider).restoreCampaign(
              campaignId,
            );
            ref.invalidate(launchpadWorkspaceProvider);
          },
        );
      case 'media-studio':
      case 'manufacturing-planner':
      case 'community-builder':
      case 'grant-centre':
      case 'investor-crm':
      case 'partner-crm':
      case 'timeline-planner':
      case 'analytics':
        return LaunchpadPhase2SectionView(
          campaign: campaign,
          workspace: workspace,
          section: widget.section,
        );
      default:
        return _PhaseTwoPlaceholder(
          title: launchpadCampaignSectionLabel(widget.section),
          body:
              'This section is reserved for Phase 2. The route is present so the module navigation already feels complete.',
        );
    }
  }
}

class _OverviewHero extends StatelessWidget {
  const _OverviewHero({
    required this.workspace,
    required this.activeCampaign,
    required this.readiness,
    required this.finance,
    required this.onCreateCampaign,
  });

  final LaunchpadWorkspace workspace;
  final LaunchpadCampaignRecord activeCampaign;
  final LaunchpadReadinessSummary readiness;
  final LaunchpadFinancialSummary finance;
  final VoidCallback onCreateCampaign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final launchDateLabel = activeCampaign.launchDate == null
        ? 'Launch date not set'
        : DateFormat('d MMM y').format(activeCampaign.launchDate!.toLocal());

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(context, highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 960;

          final textBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Launchpad',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mission launch control for crowdfunding, grants, investors, and delivery planning.',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColours.darkText,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  'Keep each campaign grounded in proof, cost, risk, and a clear next step. The MicroGrow seed is ready as the first working example.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          );

          final chips = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricChip(label: 'Campaigns', value: '${workspace.campaigns.length}'),
              _MetricChip(
                label: 'Active',
                value: '${workspace.campaigns.where((campaign) => campaign.status != LaunchpadCampaignStatus.archived).length}',
                accent: AppColours.darkSuccess,
              ),
              _MetricChip(
                label: 'Readiness',
                value: '${readiness.overallPercent.toStringAsFixed(0)}%',
                accent: AppColours.darkPrimary,
              ),
              _MetricChip(
                label: 'Net Funds',
                value: '£${finance.netAvailableFundsGbp.toStringAsFixed(0)}',
                accent: finance.netAvailableFundsGbp >= 0
                    ? AppColours.darkSuccess
                    : AppColours.darkAmber,
              ),
              _MetricChip(label: 'Status', value: activeCampaign.status.label),
              _MetricChip(label: 'Launch', value: launchDateLabel),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onCreateCampaign,
                icon: const Icon(Icons.add),
                label: const Text('New Campaign'),
              ),
              TextButton.icon(
                onPressed: () => context.go(
                  RouteNames.launchpadCampaign(activeCampaign.id),
                ),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open MicroGrow'),
              ),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textBlock,
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
              Expanded(child: textBlock),
              const SizedBox(width: 20),
              SizedBox(
                width: 520,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    chips,
                    const SizedBox(height: 18),
                    actions,
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

class _WorkspaceSummaryGrid extends StatelessWidget {
  const _WorkspaceSummaryGrid({
    required this.readiness,
    required this.finance,
    required this.campaignCount,
    required this.activeCount,
  });

  final LaunchpadReadinessSummary readiness;
  final LaunchpadFinancialSummary finance;
  final int campaignCount;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1080
            ? 4
            : constraints.maxWidth >= 720
            ? 2
            : 1;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: crossAxisCount == 1 ? 2.9 : 2.15,
          children: [
            _SummaryCard(
              title: 'Hardware',
              value: '${readiness.hardwarePercent.toStringAsFixed(0)}%',
              accent: AppColours.darkSecondary,
            ),
            _SummaryCard(
              title: 'Firmware',
              value: '${readiness.firmwarePercent.toStringAsFixed(0)}%',
              accent: AppColours.darkSuccess,
            ),
            _SummaryCard(
              title: 'Software',
              value: '${readiness.softwarePercent.toStringAsFixed(0)}%',
              accent: AppColours.darkPrimary,
            ),
            _SummaryCard(
              title: 'Financial Model',
              value: '£${finance.netAvailableFundsGbp.toStringAsFixed(0)}',
              accent: finance.netAvailableFundsGbp >= 0
                  ? AppColours.darkSuccess
                  : AppColours.darkAmber,
            ),
            _SummaryCard(
              title: 'Campaigns',
              value: '$campaignCount',
              accent: AppColours.darkSecondary,
            ),
            _SummaryCard(
              title: 'Active',
              value: '$activeCount',
              accent: AppColours.darkSuccess,
            ),
            _SummaryCard(
              title: 'Break-even',
              value: '${finance.breakEvenBackers}',
              accent: AppColours.darkAmber,
            ),
            _SummaryCard(
              title: 'Readiness',
              value: '${readiness.overallPercent.toStringAsFixed(0)}%',
              accent: AppColours.darkPrimary,
            ),
          ],
        );
      },
    );
  }
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({
    required this.campaign,
    required this.onOpen,
    required this.onEdit,
    required this.onArchive,
  });

  final LaunchpadCampaignRecord campaign;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback? onArchive;

  @override
  Widget build(BuildContext context) {
    final readiness = calculateLaunchpadReadinessSummary(campaign.readinessItems);
    final launchLabel = campaign.launchDate == null
        ? 'Launch date not set'
        : DateFormat('d MMM y').format(campaign.launchDate!.toLocal());

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 920;
          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      campaign.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _StatusTag(label: campaign.status.label),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                campaign.summary,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Tag(label: campaign.project, accent: AppColours.darkSecondary),
                  _Tag(label: 'Goal £${campaign.fundingGoalGbp.toStringAsFixed(0)}'),
                  _Tag(
                    label: 'Readiness ${readiness.overallPercent.toStringAsFixed(0)}%',
                    accent: AppColours.darkSuccess,
                  ),
                  _Tag(label: launchLabel, accent: AppColours.darkPrimary),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                minHeight: 7,
                value: campaign.progressPercentage.clamp(0, 100) / 100,
                backgroundColor: AppColours.darkSurfaceAlt,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColours.darkSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _nextActionLabel(campaign),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: wide ? WrapAlignment.end : WrapAlignment.start,
            children: [
              FilledButton.tonalIcon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open'),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              if (onArchive != null)
                TextButton.icon(
                  onPressed: onArchive,
                  icon: const Icon(Icons.archive_outlined),
                  label: const Text('Archive'),
                ),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                left,
                const SizedBox(height: 14),
                actions,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: 18),
              SizedBox(width: 240, child: actions),
            ],
          );
        },
      ),
    );
  }
}

class _CampaignManagerSection extends StatelessWidget {
  const _CampaignManagerSection({
    required this.campaign,
    required this.readiness,
    required this.finance,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
  });

  final LaunchpadCampaignRecord campaign;
  final LaunchpadReadinessSummary readiness;
  final LaunchpadFinancialSummary finance;
  final VoidCallback onEdit;
  final VoidCallback? onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final launchDateLabel = campaign.launchDate == null
        ? 'Not set'
        : DateFormat('d MMM y').format(campaign.launchDate!.toLocal());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Campaign Manager',
          subtitle:
              'Manage the core record: status, funding target, launch date, and progress.',
          actions: [
            TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
            ),
            if (onArchive != null)
              TextButton.icon(
                onPressed: onArchive,
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Archive'),
              ),
            TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _DetailPanel(
          title: campaign.name,
          body: campaign.summary,
          children: [
            _InlineStat(label: 'Project', value: campaign.project),
            _InlineStat(label: 'Owner', value: campaign.owner),
            _InlineStat(label: 'Status', value: campaign.status.label),
            _InlineStat(label: 'Funding target', value: '£${campaign.fundingGoalGbp.toStringAsFixed(0)}'),
            _InlineStat(label: 'Launch date', value: launchDateLabel),
            _InlineStat(label: 'Progress', value: '${campaign.progressPercentage}%'),
            _InlineStat(label: 'Readiness', value: '${readiness.overallPercent.toStringAsFixed(0)}%'),
            _InlineStat(label: 'Net funds', value: '£${finance.netAvailableFundsGbp.toStringAsFixed(0)}'),
            _InlineStat(label: 'Break-even', value: '${finance.breakEvenBackers} backers'),
          ],
        ),
        const SizedBox(height: 14),
        _RiskIndicatorsPanel(risks: finance.riskIndicators),
      ],
    );
  }
}

class _RewardManagerSection extends StatelessWidget {
  const _RewardManagerSection({
    required this.campaign,
    required this.onChanged,
  });

  final LaunchpadCampaignRecord campaign;
  final ValueChanged<List<LaunchpadRewardTier>> onChanged;

  @override
  Widget build(BuildContext context) {
    final rewards = [...campaign.rewards]
      ..sort((a, b) => a.priceGbp.compareTo(b.priceGbp));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Reward Manager',
          subtitle:
              'Reward tiers stay editable so pricing, limits, and fulfilment estimates remain visible.',
          actions: [
            FilledButton.icon(
              onPressed: () async {
                final reward = await _showRewardDialog(context, campaign.id);
                if (reward == null) {
                  return;
                }
                onChanged([...rewards, reward]);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add reward'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (rewards.isEmpty)
          const _EmptyPanel(
            title: 'No reward tiers yet',
            body: 'Add the first tier before the campaign goes live.',
          )
        else
          ...rewards.map(
            (reward) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RewardCard(
                reward: reward,
                onEdit: () async {
                  final updated = await _showRewardDialog(
                    context,
                    campaign.id,
                    reward: reward,
                  );
                  if (updated == null) {
                    return;
                  }
                  final nextRewards = rewards
                      .map((item) => item.id == reward.id ? updated : item)
                      .toList(growable: false);
                  onChanged(nextRewards);
                },
                onDelete: () {
                  onChanged(
                    rewards.where((item) => item.id != reward.id).toList(),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _StoryBuilderSection extends StatefulWidget {
  const _StoryBuilderSection({
    required this.campaign,
    required this.onSave,
    required this.onExport,
  });

  final LaunchpadCampaignRecord campaign;
  final ValueChanged<List<LaunchpadStoryBlock>> onSave;
  final VoidCallback onExport;

  @override
  State<_StoryBuilderSection> createState() => _StoryBuilderSectionState();
}

class _StoryBuilderSectionState extends State<_StoryBuilderSection> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void didUpdateWidget(covariant _StoryBuilderSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.campaign.id != widget.campaign.id) {
      _controllers.clear();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blocks = [...widget.campaign.storyBlocks]
      ..sort((a, b) => a.order.compareTo(b.order));
    for (final block in blocks) {
      _controllers.putIfAbsent(
        block.id,
        () => TextEditingController(text: block.body),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Story Builder',
          subtitle:
              'Edit the campaign narrative in calm blocks and export it to markdown when ready.',
          actions: [
            TextButton.icon(
              onPressed: widget.onExport,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export markdown'),
            ),
            FilledButton.icon(
              onPressed: () {
                final nextBlocks = blocks
                    .map(
                      (block) => block.copyWith(
                        body: _controllers[block.id]?.text ?? block.body,
                      ),
                    )
                    .toList(growable: false);
                widget.onSave(nextBlocks);
              },
              icon: const Icon(Icons.save),
              label: const Text('Save story'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...blocks.map(
          (block) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _StoryBlockCard(
              block: block,
              controller: _controllers[block.id]!,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadinessSection extends StatefulWidget {
  const _ReadinessSection({
    required this.campaign,
    required this.readiness,
    required this.onChanged,
  });

  final LaunchpadCampaignRecord campaign;
  final LaunchpadReadinessSummary readiness;
  final ValueChanged<List<LaunchpadReadinessItem>> onChanged;

  @override
  State<_ReadinessSection> createState() => _ReadinessSectionState();
}

class _ReadinessSectionState extends State<_ReadinessSection> {
  final Map<String, String> _statuses = {};

  @override
  void didUpdateWidget(covariant _ReadinessSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.campaign.id != widget.campaign.id) {
      _statuses.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.campaign.readinessItems;
    for (final item in items) {
      _statuses.putIfAbsent(item.id, () => item.status);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Readiness Tracker',
          subtitle:
              'Track the six launch categories and watch the overall score move as proof is completed.',
          actions: [
            FilledButton.icon(
              onPressed: () {
                final updated = items
                    .map(
                      (item) => item.copyWith(status: _statuses[item.id] ?? item.status),
                    )
                    .toList(growable: false);
                widget.onChanged(updated);
              },
              icon: const Icon(Icons.save),
              label: const Text('Save changes'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ReadinessSummaryPanel(readiness: widget.readiness),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ReadinessItemCard(
              item: item,
              currentStatus: _statuses[item.id] ?? item.status,
              onChanged: (value) => setState(() {
                _statuses[item.id] = value;
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _FinancialModellerSection extends StatefulWidget {
  const _FinancialModellerSection({
    required this.campaign,
    required this.finance,
    required this.onSave,
  });

  final LaunchpadCampaignRecord campaign;
  final LaunchpadFinancialSummary finance;
  final ValueChanged<LaunchpadCampaignFinanceModel> onSave;

  @override
  State<_FinancialModellerSection> createState() =>
      _FinancialModellerSectionState();
}

class _FinancialModellerSectionState extends State<_FinancialModellerSection> {
  late final TextEditingController _fundingGoalController;
  late final TextEditingController _manufacturingController;
  late final TextEditingController _shippingController;
  late final TextEditingController _vatController;
  late final TextEditingController _kickstarterFeeController;
  late final TextEditingController _paymentFeeController;
  late final TextEditingController _contingencyController;
  late final TextEditingController _fixedCostsController;

  @override
  void initState() {
    super.initState();
    _loadControllers();
  }

  @override
  void didUpdateWidget(covariant _FinancialModellerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.campaign.id != widget.campaign.id) {
      _loadControllers();
    }
  }

  void _loadControllers() {
    _fundingGoalController = TextEditingController(
      text: widget.campaign.finance.fundingGoalGbp.toStringAsFixed(0),
    );
    _manufacturingController = TextEditingController(
      text: widget.campaign.finance.manufacturingCostsGbp.toStringAsFixed(0),
    );
    _shippingController = TextEditingController(
      text: widget.campaign.finance.shippingGbp.toStringAsFixed(0),
    );
    _vatController = TextEditingController(
      text: widget.campaign.finance.vatPercent.toStringAsFixed(0),
    );
    _kickstarterFeeController = TextEditingController(
      text: widget.campaign.finance.kickstarterFeePercent.toStringAsFixed(0),
    );
    _paymentFeeController = TextEditingController(
      text: widget.campaign.finance.paymentFeePercent.toStringAsFixed(0),
    );
    _contingencyController = TextEditingController(
      text: widget.campaign.finance.contingencyPercent.toStringAsFixed(0),
    );
    _fixedCostsController = TextEditingController(
      text: widget.campaign.finance.fixedCostsGbp.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _fundingGoalController.dispose();
    _manufacturingController.dispose();
    _shippingController.dispose();
    _vatController.dispose();
    _kickstarterFeeController.dispose();
    _paymentFeeController.dispose();
    _contingencyController.dispose();
    _fixedCostsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draftFinance = LaunchpadCampaignFinanceModel(
      fundingGoalGbp: _parseMoney(_fundingGoalController.text),
      manufacturingCostsGbp: _parseMoney(_manufacturingController.text),
      shippingGbp: _parseMoney(_shippingController.text),
      vatPercent: _parseMoney(_vatController.text),
      kickstarterFeePercent: _parseMoney(_kickstarterFeeController.text),
      paymentFeePercent: _parseMoney(_paymentFeeController.text),
      contingencyPercent: _parseMoney(_contingencyController.text),
      fixedCostsGbp: _parseMoney(_fixedCostsController.text),
    );
    final draftCampaign = widget.campaign.copyWith(
      fundingGoalGbp: draftFinance.fundingGoalGbp,
      finance: draftFinance,
    );
    final draftSummary = calculateLaunchpadFinancialSummary(draftCampaign);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Financial Modeller',
          subtitle:
              'Check the launch economics before the campaign goes public.',
          actions: [
            FilledButton.icon(
              onPressed: () {
                widget.onSave(draftFinance);
              },
              icon: const Icon(Icons.save),
              label: const Text('Save model'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _FinancialInputGrid(
          fundingGoalController: _fundingGoalController,
          manufacturingController: _manufacturingController,
          shippingController: _shippingController,
          vatController: _vatController,
          kickstarterFeeController: _kickstarterFeeController,
          paymentFeeController: _paymentFeeController,
          contingencyController: _contingencyController,
          fixedCostsController: _fixedCostsController,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _FinancialOutputPanel(summary: draftSummary),
      ],
    );
  }
}

class _RiskRegisterSection extends StatelessWidget {
  const _RiskRegisterSection({
    required this.campaign,
    required this.onChanged,
  });

  final LaunchpadCampaignRecord campaign;
  final ValueChanged<List<LaunchpadRiskRecord>> onChanged;

  @override
  Widget build(BuildContext context) {
    final risks = campaign.risks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Risk Register',
          subtitle:
              'Keep risks visible, calm, and honest so the public story stays grounded in reality.',
          actions: [
            FilledButton.icon(
              onPressed: () async {
                final record = await _showRiskDialog(context, campaign.id);
                if (record == null) {
                  return;
                }
                onChanged([...risks, record]);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add risk'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...risks.map(
          (risk) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RiskCard(
              risk: risk,
              onEdit: () async {
                final updated = await _showRiskDialog(
                  context,
                  campaign.id,
                  risk: risk,
                );
                if (updated == null) {
                  return;
                }
                onChanged(
                  risks.map((item) => item.id == risk.id ? updated : item).toList(),
                );
              },
              onDelete: () {
                onChanged(risks.where((item) => item.id != risk.id).toList());
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ArchiveSection extends StatelessWidget {
  const _ArchiveSection({
    required this.workspace,
    required this.onRestore,
  });

  final LaunchpadWorkspace workspace;
  final ValueChanged<String> onRestore;

  @override
  Widget build(BuildContext context) {
    final archived = workspace.campaigns
        .where((campaign) => campaign.status == LaunchpadCampaignStatus.archived)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Archive',
          subtitle: 'Archived campaigns stay local and can be restored later.',
        ),
        const SizedBox(height: 12),
        if (archived.isEmpty)
          const _EmptyPanel(
            title: 'Nothing archived yet',
            body: 'Archive a campaign from Campaign Manager when it is parked.',
          )
        else
          ...archived.map(
            (campaign) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CampaignCard(
                campaign: campaign,
                onOpen: () => context.go(RouteNames.launchpadCampaign(campaign.id)),
                onEdit: () => onRestore(campaign.id),
                onArchive: null,
              ),
            ),
          ),
      ],
    );
  }
}

class _PhaseTwoPlaceholder extends StatelessWidget {
  const _PhaseTwoPlaceholder({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _DetailPanel(
      title: title,
      body: body,
      children: const [
        _InlineStat(label: 'Phase', value: '2'),
        _InlineStat(label: 'Status', value: 'Planned'),
        _InlineStat(label: 'Purpose', value: 'Reserved for future build work'),
      ],
    );
  }
}

class _LaunchpadSectionRail extends StatelessWidget {
  const _LaunchpadSectionRail({
    required this.sections,
    required this.selectedSection,
    required this.onSelected,
  });

  final List<_LaunchpadSectionSpec> sections;
  final String selectedSection;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 240;
          if (!wide) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sections
                  .map(
                    (section) => ChoiceChip(
                      selected: section.routeSegment == selectedSection,
                      onSelected: (_) => onSelected(section.routeSegment),
                      avatar: Icon(
                        section.icon,
                        size: 18,
                        color: section.routeSegment == selectedSection
                            ? AppColours.darkBackground
                            : AppColours.darkMutedText,
                      ),
                      label: Text(section.label),
                    ),
                  )
                  .toList(growable: false),
            );
          }

          return NavigationRail(
            selectedIndex: mathMax(
              0,
              sections.indexWhere(
              (section) => section.routeSegment == selectedSection,
              ),
            ),
            onDestinationSelected: (index) => onSelected(sections[index].routeSegment),
            labelType: NavigationRailLabelType.all,
            minWidth: 72,
            destinations: sections
                .map(
                  (section) => NavigationRailDestination(
                    icon: Icon(section.icon),
                    selectedIcon: Icon(section.selectedIcon),
                    label: Text(section.label),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}

int mathMax(int a, int b) => a > b ? a : b;

class _LaunchpadSectionSpec {
  const _LaunchpadSectionSpec({
    required this.routeSegment,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String routeSegment;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

List<_LaunchpadSectionSpec> _launchpadSections(String campaignId) {
  return const [
    _LaunchpadSectionSpec(
      routeSegment: 'campaigns',
      label: 'Campaigns',
      icon: Icons.campaign_outlined,
      selectedIcon: Icons.campaign,
    ),
    _LaunchpadSectionSpec(
      routeSegment: 'rewards',
      label: 'Rewards',
      icon: Icons.card_giftcard_outlined,
      selectedIcon: Icons.card_giftcard,
    ),
    _LaunchpadSectionSpec(
      routeSegment: 'story-builder',
      label: 'Story',
      icon: Icons.text_snippet_outlined,
      selectedIcon: Icons.text_snippet,
    ),
    _LaunchpadSectionSpec(
      routeSegment: 'readiness',
      label: 'Readiness',
      icon: Icons.checklist_outlined,
      selectedIcon: Icons.checklist,
    ),
    _LaunchpadSectionSpec(
      routeSegment: 'financial-modeller',
      label: 'Finance',
      icon: Icons.calculate_outlined,
      selectedIcon: Icons.calculate,
    ),
    _LaunchpadSectionSpec(
      routeSegment: 'risk-register',
      label: 'Risks',
      icon: Icons.warning_amber_outlined,
      selectedIcon: Icons.warning_amber,
    ),
    _LaunchpadSectionSpec(
      routeSegment: 'media-studio',
      label: 'Media',
      icon: Icons.perm_media_outlined,
      selectedIcon: Icons.perm_media,
    ),
    _LaunchpadSectionSpec(
      routeSegment: 'manufacturing-planner',
      label: 'Manufacturing',
      icon: Icons.precision_manufacturing_outlined,
      selectedIcon: Icons.precision_manufacturing,
    ),
    _LaunchpadSectionSpec(
      routeSegment: 'community-builder',
      label: 'Community',
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups,
    ),
    _LaunchpadSectionSpec(
      routeSegment: 'grant-centre',
      label: 'Grants',
      icon: Icons.request_page_outlined,
      selectedIcon: Icons.request_page,
    ),
    _LaunchpadSectionSpec(
      routeSegment: 'investor-crm',
      label: 'Investors',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
    ),
    _LaunchpadSectionSpec(
      routeSegment: 'partner-crm',
      label: 'Partners',
      icon: Icons.handshake_outlined,
      selectedIcon: Icons.handshake,
    ),
    _LaunchpadSectionSpec(
      routeSegment: 'timeline-planner',
      label: 'Timeline',
      icon: Icons.timeline_outlined,
      selectedIcon: Icons.timeline,
    ),
    _LaunchpadSectionSpec(
      routeSegment: 'analytics',
      label: 'Analytics',
      icon: Icons.query_stats_outlined,
      selectedIcon: Icons.query_stats,
    ),
    _LaunchpadSectionSpec(
      routeSegment: 'launch-checklist',
      label: 'Checklist',
      icon: Icons.fact_check_outlined,
      selectedIcon: Icons.fact_check,
    ),
    _LaunchpadSectionSpec(
      routeSegment: 'backer-updates',
      label: 'Updates',
      icon: Icons.campaign_outlined,
      selectedIcon: Icons.campaign,
    ),
    _LaunchpadSectionSpec(
      routeSegment: 'fulfilment-tracker',
      label: 'Fulfilment',
      icon: Icons.local_shipping_outlined,
      selectedIcon: Icons.local_shipping,
    ),
    _LaunchpadSectionSpec(
      routeSegment: 'impact-tracker',
      label: 'Impact',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
    ),
    _LaunchpadSectionSpec(
      routeSegment: 'archive',
      label: 'Archive',
      icon: Icons.archive_outlined,
      selectedIcon: Icons.archive,
    ),
  ];
}

Future<void> _showCampaignDialog({
  required BuildContext context,
  required WidgetRef ref,
  LaunchpadCampaignRecord? campaign,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => _CampaignEditDialog(
      campaign: campaign,
      onSave: (draft) async {
        if (campaign == null) {
          await ref.read(launchpadRepositoryProvider).createCampaign(
                name: draft.name,
                project: draft.project,
                owner: draft.owner,
                summary: draft.summary,
                fundingGoalGbp: draft.fundingGoalGbp,
                type: draft.type,
              );
        } else {
          await ref.read(launchpadRepositoryProvider).updateCampaign(draft);
        }
        ref.invalidate(launchpadWorkspaceProvider);
      },
    ),
  );
}

Future<LaunchpadRewardTier?> _showRewardDialog(
  BuildContext context,
  String campaignId, {
  LaunchpadRewardTier? reward,
}) {
  return showDialog<LaunchpadRewardTier>(
    context: context,
    builder: (dialogContext) => _RewardEditDialog(
      campaignId: campaignId,
      reward: reward,
    ),
  );
}

Future<LaunchpadRiskRecord?> _showRiskDialog(
  BuildContext context,
  String campaignId, {
  LaunchpadRiskRecord? risk,
}) {
  return showDialog<LaunchpadRiskRecord>(
    context: context,
    builder: (dialogContext) => _RiskEditDialog(
      campaignId: campaignId,
      risk: risk,
    ),
  );
}

class _CampaignEditDialog extends StatefulWidget {
  const _CampaignEditDialog({
    required this.onSave,
    this.campaign,
  });

  final LaunchpadCampaignRecord? campaign;
  final Future<void> Function(LaunchpadCampaignRecord draft) onSave;

  @override
  State<_CampaignEditDialog> createState() => _CampaignEditDialogState();
}

class _CampaignEditDialogState extends State<_CampaignEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _projectController;
  late final TextEditingController _ownerController;
  late final TextEditingController _summaryController;
  late final TextEditingController _fundingGoalController;
  late final TextEditingController _launchDateController;
  late final TextEditingController _progressController;
  String _type = 'kickstarter';
  LaunchpadCampaignStatus _status = LaunchpadCampaignStatus.prototype;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final campaign = widget.campaign;
    _nameController = TextEditingController(text: campaign?.name ?? '');
    _projectController = TextEditingController(text: campaign?.project ?? '');
    _ownerController = TextEditingController(text: campaign?.owner ?? '');
    _summaryController = TextEditingController(text: campaign?.summary ?? '');
    _fundingGoalController = TextEditingController(
      text: (campaign?.fundingGoalGbp ?? 35000).toStringAsFixed(0),
    );
    _launchDateController = TextEditingController(
      text: campaign?.launchDate == null
          ? ''
          : DateFormat('yyyy-MM-dd').format(campaign!.launchDate!),
    );
    _progressController = TextEditingController(
      text: (campaign?.progressPercentage ?? 0).toStringAsFixed(0),
    );
    _type = campaign?.type ?? 'kickstarter';
    _status = campaign?.status ?? LaunchpadCampaignStatus.prototype;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _projectController.dispose();
    _ownerController.dispose();
    _summaryController.dispose();
    _fundingGoalController.dispose();
    _launchDateController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.campaign == null ? 'New Campaign' : 'Edit Campaign'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: SizedBox(
            width: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Campaign name'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Add a campaign name.'
                          : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _projectController,
                  decoration: const InputDecoration(labelText: 'Project'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ownerController,
                  decoration: const InputDecoration(labelText: 'Owner'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fundingGoalController,
                  decoration: const InputDecoration(labelText: 'Funding target (£)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _launchDateController,
                  decoration: const InputDecoration(
                    labelText: 'Launch date',
                    hintText: 'YYYY-MM-DD',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _progressController,
                  decoration: const InputDecoration(labelText: 'Progress (%)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'kickstarter', child: Text('Kickstarter')),
                    DropdownMenuItem(value: 'indiegogo', child: Text('Indiegogo')),
                    DropdownMenuItem(value: 'grant', child: Text('Grant')),
                    DropdownMenuItem(value: 'investor', child: Text('Investor')),
                    DropdownMenuItem(value: 'pilot', child: Text('Pilot')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) => setState(() => _type = value ?? 'other'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<LaunchpadCampaignStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: LaunchpadCampaignStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _status = value);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _summaryController,
                  decoration: const InputDecoration(labelText: 'Summary'),
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  final launchDateText = _launchDateController.text.trim();
                  final launchDate = launchDateText.isEmpty
                      ? null
                      : DateTime.tryParse(launchDateText);
                  final draft = LaunchpadCampaignRecord(
                    id: widget.campaign?.id ?? '',
                    name: _nameController.text.trim(),
                    project: _projectController.text.trim(),
                    type: _type,
                    status: _status,
                    fundingGoalGbp: _parseMoney(_fundingGoalController.text),
                    launchDate: launchDate,
                    owner: _ownerController.text.trim(),
                    summary: _summaryController.text.trim(),
                    createdAt: widget.campaign?.createdAt ?? DateTime.now(),
                    updatedAt: DateTime.now(),
                    progressPercentage: _parseMoney(_progressController.text).round().clamp(0, 100),
                    rewards: widget.campaign?.rewards ?? const <LaunchpadRewardTier>[],
                    storyBlocks: widget.campaign?.storyBlocks ?? const <LaunchpadStoryBlock>[],
                    readinessItems: widget.campaign?.readinessItems ?? const <LaunchpadReadinessItem>[],
                    risks: widget.campaign?.risks ?? const <LaunchpadRiskRecord>[],
                    phase2Records:
                        widget.campaign?.phase2Records ??
                        const <LaunchpadPhase2Record>[],
                    finance: (widget.campaign?.finance ??
                            LaunchpadCampaignFinanceModel(
                              fundingGoalGbp: _parseMoney(_fundingGoalController.text),
                              manufacturingCostsGbp: 0,
                              shippingGbp: 0,
                              vatPercent: 0,
                              kickstarterFeePercent: 5,
                              paymentFeePercent: 3,
                              contingencyPercent: 10,
                              fixedCostsGbp: 0,
                            ))
                        .copyWith(
                          fundingGoalGbp: _parseMoney(_fundingGoalController.text),
                        ),
                  );

                  setState(() => _saving = true);
                  try {
                    await widget.onSave(draft);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _saving = false);
                    }
                  }
                },
          child: Text(_saving ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }
}

class _RewardEditDialog extends StatefulWidget {
  const _RewardEditDialog({
    required this.campaignId,
    this.reward,
  });

  final String campaignId;
  final LaunchpadRewardTier? reward;

  @override
  State<_RewardEditDialog> createState() => _RewardEditDialogState();
}

class _RewardEditDialogState extends State<_RewardEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _limitController;
  late final TextEditingController _cogsController;
  late final TextEditingController _shippingController;
  late final TextEditingController _deliveryController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final reward = widget.reward;
    _nameController = TextEditingController(text: reward?.name ?? '');
    _priceController = TextEditingController(text: reward?.priceGbp.toStringAsFixed(0) ?? '');
    _limitController = TextEditingController(
      text: reward?.quantityLimit?.toString() ?? '',
    );
    _cogsController = TextEditingController(
      text: reward?.estimatedCogsGbp.toStringAsFixed(0) ?? '',
    );
    _shippingController = TextEditingController(
      text: reward?.estimatedShippingGbp.toStringAsFixed(0) ?? '',
    );
    _deliveryController = TextEditingController(text: reward?.deliveryEstimate ?? '');
    _notesController = TextEditingController(text: reward?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _limitController.dispose();
    _cogsController.dispose();
    _shippingController.dispose();
    _deliveryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reward == null ? 'Add Reward' : 'Edit Reward'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price (£)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _limitController,
                  decoration: const InputDecoration(labelText: 'Quantity limit'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cogsController,
                  decoration: const InputDecoration(labelText: 'COGS (£)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _shippingController,
                  decoration: const InputDecoration(labelText: 'Shipping (£)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _deliveryController,
                  decoration: const InputDecoration(labelText: 'Delivery estimate'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(context).pop(
              LaunchpadRewardTier(
                id: widget.reward?.id ??
                    _slugify(
                      '${widget.campaignId}-${_nameController.text}-${DateTime.now().millisecondsSinceEpoch}',
                    ),
                campaignId: widget.campaignId,
                name: _nameController.text.trim(),
                priceGbp: _parseMoney(_priceController.text),
                quantityLimit: _parseOptionalInt(_limitController.text),
                estimatedCogsGbp: _parseMoney(_cogsController.text),
                estimatedShippingGbp: _parseMoney(_shippingController.text),
                deliveryEstimate: _deliveryController.text.trim(),
                notes: _notesController.text.trim(),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _RiskEditDialog extends StatefulWidget {
  const _RiskEditDialog({
    required this.campaignId,
    this.risk,
  });

  final String campaignId;
  final LaunchpadRiskRecord? risk;

  @override
  State<_RiskEditDialog> createState() => _RiskEditDialogState();
}

class _RiskEditDialogState extends State<_RiskEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _mitigationController;
  late final TextEditingController _publicNoteController;
  String _severity = 'Medium';
  String _likelihood = 'Medium';

  @override
  void initState() {
    super.initState();
    final risk = widget.risk;
    _titleController = TextEditingController(text: risk?.title ?? '');
    _mitigationController = TextEditingController(text: risk?.mitigation ?? '');
    _publicNoteController = TextEditingController(text: risk?.publicNote ?? '');
    _severity = risk?.severity ?? 'Medium';
    _likelihood = risk?.likelihood ?? 'Medium';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _mitigationController.dispose();
    _publicNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.risk == null ? 'Add Risk' : 'Edit Risk'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _severity,
                  decoration: const InputDecoration(labelText: 'Severity'),
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                  ],
                  onChanged: (value) => setState(() => _severity = value ?? 'Medium'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _likelihood,
                  decoration: const InputDecoration(labelText: 'Likelihood'),
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                  ],
                  onChanged: (value) => setState(() => _likelihood = value ?? 'Medium'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _mitigationController,
                  decoration: const InputDecoration(labelText: 'Mitigation'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _publicNoteController,
                  decoration: const InputDecoration(labelText: 'Public note'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(context).pop(
              LaunchpadRiskRecord(
                id: widget.risk?.id ??
                    _slugify(
                      '${widget.campaignId}-${_titleController.text}-${DateTime.now().millisecondsSinceEpoch}',
                    ),
                campaignId: widget.campaignId,
                title: _titleController.text.trim(),
                severity: _severity,
                likelihood: _likelihood,
                mitigation: _mitigationController.text.trim(),
                publicNote: _publicNoteController.text.trim(),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _FinancialInputGrid extends StatelessWidget {
  const _FinancialInputGrid({
    required this.fundingGoalController,
    required this.manufacturingController,
    required this.shippingController,
    required this.vatController,
    required this.kickstarterFeeController,
    required this.paymentFeeController,
    required this.contingencyController,
    required this.fixedCostsController,
    required this.onChanged,
  });

  final TextEditingController fundingGoalController;
  final TextEditingController manufacturingController;
  final TextEditingController shippingController;
  final TextEditingController vatController;
  final TextEditingController kickstarterFeeController;
  final TextEditingController paymentFeeController;
  final TextEditingController contingencyController;
  final TextEditingController fixedCostsController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final fields = [
      _numberField('Funding goal (£)', fundingGoalController),
      _numberField('Manufacturing (£)', manufacturingController),
      _numberField('Shipping (£)', shippingController),
      _numberField('VAT (%)', vatController),
      _numberField('Kickstarter fee (%)', kickstarterFeeController),
      _numberField('Payment fee (%)', paymentFeeController),
      _numberField('Contingency (%)', contingencyController),
      _numberField('Fixed costs (£)', fixedCostsController),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 980
            ? 4
            : constraints.maxWidth >= 720
            ? 2
            : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: crossAxisCount == 1 ? 3.2 : 2.5,
          children: fields
              .map(
                (field) => TextField(
                  controller: field.controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: field.label),
                  onChanged: (_) => onChanged(),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  _FinancialFieldSpec _numberField(String label, TextEditingController controller) {
    return _FinancialFieldSpec(label: label, controller: controller);
  }
}

class _FinancialOutputPanel extends StatelessWidget {
  const _FinancialOutputPanel({required this.summary});

  final LaunchpadFinancialSummary summary;

  @override
  Widget build(BuildContext context) {
    return _DetailPanel(
      title: 'Financial Output',
      body: 'The finance model turns launch costs into a calm operating view.',
      children: [
        _InlineStat(label: 'Gross funding', value: '£${summary.grossFundingGbp.toStringAsFixed(0)}'),
        _InlineStat(label: 'Platform fees', value: '£${summary.platformFeesGbp.toStringAsFixed(0)}'),
        _InlineStat(label: 'Payment fees', value: '£${summary.paymentFeesGbp.toStringAsFixed(0)}'),
        _InlineStat(label: 'VAT reserve', value: '£${summary.vatReserveGbp.toStringAsFixed(0)}'),
        _InlineStat(label: 'Contingency', value: '£${summary.contingencyReserveGbp.toStringAsFixed(0)}'),
        _InlineStat(label: 'Manufacturing', value: '£${summary.manufacturingCostsGbp.toStringAsFixed(0)}'),
        _InlineStat(label: 'Shipping', value: '£${summary.shippingGbp.toStringAsFixed(0)}'),
        _InlineStat(label: 'Fixed costs', value: '£${summary.fixedCostsGbp.toStringAsFixed(0)}'),
        _InlineStat(label: 'Net available', value: '£${summary.netAvailableFundsGbp.toStringAsFixed(0)}'),
        _InlineStat(label: 'Profit margin', value: '${summary.profitMarginPercent.toStringAsFixed(1)}%'),
        _InlineStat(label: 'Break-even', value: '${summary.breakEvenBackers} backers'),
      ],
    );
  }
}

class _ReadinessSummaryPanel extends StatelessWidget {
  const _ReadinessSummaryPanel({required this.readiness});

  final LaunchpadReadinessSummary readiness;

  @override
  Widget build(BuildContext context) {
    return _DetailPanel(
      title: 'Readiness score',
      body: 'The six launch categories are scored from the current tracker items.',
      children: [
        _InlineStat(label: 'Hardware', value: '${readiness.hardwarePercent.toStringAsFixed(0)}%'),
        _InlineStat(label: 'Firmware', value: '${readiness.firmwarePercent.toStringAsFixed(0)}%'),
        _InlineStat(label: 'Software', value: '${readiness.softwarePercent.toStringAsFixed(0)}%'),
        _InlineStat(label: 'Manufacturing', value: '${readiness.manufacturingPercent.toStringAsFixed(0)}%'),
        _InlineStat(label: 'Documentation', value: '${readiness.documentationPercent.toStringAsFixed(0)}%'),
        _InlineStat(label: 'Marketing', value: '${readiness.marketingPercent.toStringAsFixed(0)}%'),
        _InlineStat(label: 'Overall', value: '${readiness.overallPercent.toStringAsFixed(0)}%'),
      ],
    );
  }
}

class _ReadinessItemCard extends StatelessWidget {
  const _ReadinessItemCard({
    required this.item,
    required this.currentStatus,
    required this.onChanged,
  });

  final LaunchpadReadinessItem item;
  final String currentStatus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          final row = [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColours.darkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColours.darkSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.notes,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                initialValue: currentStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'Todo', child: Text('Todo')),
                  DropdownMenuItem(value: 'Draft', child: Text('Draft')),
                  DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'Done', child: Text('Done')),
                  DropdownMenuItem(value: 'Blocked', child: Text('Blocked')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onChanged(value);
                  }
                },
              ),
            ),
          ];

          if (wide) {
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: row);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              row.first,
              const SizedBox(height: 14),
              SizedBox(width: double.infinity, child: row.last),
            ],
          );
        },
      ),
    );
  }
}

class _StoryBlockCard extends StatelessWidget {
  const _StoryBlockCard({
    required this.block,
    required this.controller,
  });

  final LaunchpadStoryBlock block;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            block.section,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            block.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Body',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.reward,
    required this.onEdit,
    required this.onDelete,
  });

  final LaunchpadRewardTier reward;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reward.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '£${reward.priceGbp.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(label: reward.quantityLimit == null ? 'Unlimited' : 'Limit ${reward.quantityLimit}', accent: AppColours.darkPrimary),
              _Tag(label: 'COGS £${reward.estimatedCogsGbp.toStringAsFixed(0)}'),
              _Tag(label: 'Ship £${reward.estimatedShippingGbp.toStringAsFixed(0)}'),
              _Tag(label: reward.deliveryEstimate, accent: AppColours.darkSuccess),
            ],
          ),
          if (reward.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              reward.notes,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({
    required this.risk,
    required this.onEdit,
    required this.onDelete,
  });

  final LaunchpadRiskRecord risk;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  risk.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _Tag(label: risk.severity, accent: AppColours.darkAmber),
              const SizedBox(width: 8),
              _Tag(label: risk.likelihood, accent: AppColours.darkSecondary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            risk.mitigation,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          if (risk.publicNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              risk.publicNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkSecondary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinancialFieldSpec {
  const _FinancialFieldSpec({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
    required this.title,
    required this.body,
    required this.children,
  });

  final String title;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(spacing: 10, runSpacing: 10, children: children),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.accent,
  });

  final String title;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
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

class _InlineStat extends StatelessWidget {
  const _InlineStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
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

class _RiskIndicatorsPanel extends StatelessWidget {
  const _RiskIndicatorsPanel({required this.risks});

  final List<String> risks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Risk indicators',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (risks.isEmpty)
            Text(
              'No immediate financial risk indicators are currently triggered.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
              ),
            )
          else
            ...risks.map(
              (risk) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $risk',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColours.darkPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColours.darkPrimary.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColours.darkPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    this.accent = AppColours.darkSecondary,
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
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

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    this.accent = AppColours.darkSecondary,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 128),
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
              color: accent,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 860;
        final header = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
          ],
        );

        if (actions.isEmpty) {
          return header;
        }

        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: header),
            const SizedBox(width: 16),
            Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.end, children: actions),
          ],
        );
      },
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _LaunchpadError extends StatelessWidget {
  const _LaunchpadError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.campaign_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              'Launchpad could not load right now.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
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

LaunchpadCampaignRecord _placeholderCampaign() {
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

String _nextActionLabel(LaunchpadCampaignRecord campaign) {
  final pendingReadiness = campaign.readinessItems.firstWhere(
    (item) => item.status.toLowerCase() != 'done',
    orElse: () => campaign.readinessItems.isEmpty
        ? const LaunchpadReadinessItem(
            id: '',
            campaignId: '',
            category: '',
            title: 'Review the launch plan',
            status: 'Done',
            proofLink: '',
            notes: '',
          )
        : campaign.readinessItems.first,
  );
  if (pendingReadiness.title.isNotEmpty &&
      pendingReadiness.status.toLowerCase() != 'done') {
    return 'Next: ${pendingReadiness.category} - ${pendingReadiness.title}';
  }
  if (campaign.rewards.isEmpty) {
    return 'Next: add the first reward tier';
  }
  return 'Next: review the story and finance model';
}

double _parseMoney(String value) {
  final cleaned = value.replaceAll(RegExp(r'[^0-9.\-]'), '');
  if (cleaned.isEmpty || cleaned == '-' || cleaned == '.') {
    return 0;
  }
  return double.tryParse(cleaned) ?? 0;
}

int? _parseOptionalInt(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return int.tryParse(trimmed);
}

String _slugify(String value) {
  final lower = value.trim().toLowerCase();
  final buffer = StringBuffer();
  var previousDash = false;
  for (final codeUnit in lower.codeUnits) {
    final char = String.fromCharCode(codeUnit);
    final isAlphaNumeric = RegExp(r'[a-z0-9]').hasMatch(char);
    if (isAlphaNumeric) {
      buffer.write(char);
      previousDash = false;
    } else if (!previousDash) {
      buffer.write('-');
      previousDash = true;
    }
  }
  return buffer
      .toString()
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}
