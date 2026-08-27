import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../../gaia/application/gaia_employee_providers.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  static final _items = [
    _MoreItem(
      title: 'About & Help',
      description:
          'Open the Dashboard guide centre, support links, templates, and helper pages.',
      icon: Icons.help_outline,
      route: RouteNames.aboutHelp,
      badge: 'Docs',
    ),
    _MoreItem(
      title: 'Command Deck',
      description:
          'Support the future physical control surface with bounded local commands and setup.',
      icon: Icons.space_dashboard_outlined,
      route: RouteNames.commandDeck,
    ),
    _MoreItem(
      title: 'Repo Research Engine',
      description:
          'Scan repositories safely, compare changes, and export research packs.',
      icon: Icons.travel_explore_outlined,
      route: RouteNames.repoResearchEngine,
    ),
    _MoreItem(
      title: 'Omega Knowledge Engine',
      description:
          'Scan repos, build learning notes, and review architecture maps locally.',
      icon: Icons.travel_explore_outlined,
      route: RouteNames.modulePackage('26_OMEGA_KNOWLEDGE_ENGINE'),
      badge: 'Scan',
    ),
    _MoreItem(
      title: 'Omega Engineering Studio',
      description:
          'Review technical evidence and workflows for circuits, boards, firmware, devices, and manufacturing.',
      icon: Icons.precision_manufacturing_outlined,
      route: RouteNames.modulePackage('01_OMEGA_ENGINEERING_STUDIO_MODULE'),
      badge: 'Build',
    ),
    _MoreItem(
      title: 'Company Command Centre',
      description:
          'Coordinate company operations, records, LinkedIn planning, and the company workspace.',
      icon: Icons.domain_outlined,
      route: RouteNames.companyCommandCentre,
      badge: 'Company',
    ),
    _MoreItem(
      title: 'GAIA AI Employee',
      description:
          'Open the read-only GAIA workspace for interpreted recommendations and controlled handoff.',
      icon: Icons.smart_toy_outlined,
      route: RouteNames.gaiaEmployee,
      badge: 'GAIA',
    ),
    _MoreItem(
      title: 'Education & Learning Hub',
      description:
          'Open lesson libraries, pathways, projects, progress, and tutor placeholders.',
      icon: Icons.school_outlined,
      route: RouteNames.educationLearningHub,
      badge: 'Learn',
    ),
    _MoreItem(
      title: 'Systems',
      description:
          'Review protected recovery state and local system safeguards.',
      icon: Icons.shield_outlined,
      route: RouteNames.systems,
    ),
    _MoreItem(
      title: 'Platform Core Status',
      description:
          'View Declared Platform Core architecture and source status; Dashboard does not edit it.',
      icon: Icons.account_tree_outlined,
      route: RouteNames.platformCoreGovernedStatus,
      badge: 'Read-only',
    ),
    _MoreItem(
      title: 'Module Hub',
      description:
          'Inspect, enable, dock, and review dashboard modules from one calm registry.',
      icon: Icons.extension_outlined,
      route: RouteNames.moduleHub,
    ),
    _MoreItem(
      title: 'Omega Experiment Workspace',
      description:
          'Open the experiment workspace for validation, evidence, results, and lessons.',
      icon: Icons.science_outlined,
      route: RouteNames.experimentWorkspace,
      badge: 'Lab',
    ),
    _MoreItem(
      title: 'Meeting System',
      description:
          'Plan meetings, capture actions, track decisions, and keep follow-ups in Omega OS.',
      icon: Icons.event_note_outlined,
      route: RouteNames.meetingDashboard,
    ),
    _MoreItem(
      title: 'Knowledge Library',
      description:
          'Search Indexed Omega OS knowledge and review extractable items.',
      icon: Icons.library_books_outlined,
      route: RouteNames.knowledgeLibrary,
    ),
    _MoreItem(
      title: 'Projects Intelligence',
      description:
          'Review Observed technical and repository insight from the bridge layer.',
      icon: Icons.account_tree_outlined,
      route: RouteNames.projectsIntelligence,
    ),
    _MoreItem(
      title: 'Launchpad',
      description:
          'Manage crowdfunding campaigns, rewards, readiness, finance, and launch risk.',
      icon: Icons.campaign_outlined,
      route: RouteNames.launchpad,
    ),
    _MoreItem(
      title: 'Funding & Grants',
      description:
          'Track grant applications, readiness, folder packs, and Omega OS tracker records.',
      icon: Icons.receipt_long_outlined,
      route: RouteNames.fundingGrantsCommandCentre,
    ),
    _MoreItem(
      title: 'Journal',
      description:
          'Capture build progress, lessons, decisions, and reflections.',
      icon: Icons.edit_note_outlined,
      route: RouteNames.journal,
    ),
    _MoreItem(
      title: 'Learning',
      description: 'Track skills that help build New Earth.',
      icon: Icons.school_outlined,
      route: RouteNames.learning,
    ),
    _MoreItem(
      title: 'Content',
      description:
          'Plan LinkedIn posts, website updates, videos, and book ideas.',
      icon: Icons.campaign_outlined,
      route: RouteNames.content,
    ),
    _MoreItem(
      title: 'Business',
      description:
          'Track funding, job applications, partnerships, and opportunities.',
      icon: Icons.handshake_outlined,
      route: RouteNames.business,
    ),
    _MoreItem(
      title: 'Wellbeing',
      description: 'Check energy, mood, stress, and balance.',
      icon: Icons.self_improvement_outlined,
      route: RouteNames.wellbeing,
    ),
    _MoreItem(
      title: 'Inbox',
      description: 'Process quick captured ideas and notes.',
      icon: Icons.inbox_outlined,
      route: RouteNames.inbox,
    ),
    _MoreItem(
      title: 'Voice Intelligence',
      description:
          'Open the new voice module with notes, meeting summaries, MicroGrow status, and the audit log.',
      icon: Icons.mic_none_rounded,
      route: RouteNames.voice,
    ),
    _MoreItem(
      title: 'Voice Assistant',
      description:
          'Review spoken commands safely before turning them into dashboard actions.',
      icon: Icons.mic_none_rounded,
      route: RouteNames.voiceAssistant,
    ),
    _MoreItem(
      title: 'Alexa Voice Gateway',
      description:
          'Review the guarded Alexa doorway, allowed commands, blocked commands, and audit trail.',
      icon: Icons.hub_outlined,
      route: RouteNames.alexaVoiceGateway,
      badge: 'Local',
    ),
    _MoreItem(
      title: 'Settings',
      description: 'Configure the dashboard.',
      icon: Icons.settings_outlined,
      route: RouteNames.settings,
    ),
    _MoreItem(
      title: 'Visual Capture',
      description:
          'Review receipt photos, asset photos, and capture inbox files.',
      icon: Icons.photo_library_outlined,
      route: RouteNames.visualCapture,
    ),
    _MoreItem(
      title: 'Folder Health',
      description:
          'Check Treasury, Assets, Visual Capture, and the reserved Omega OS folders.',
      icon: Icons.health_and_safety_outlined,
      route: RouteNames.omegaOsFolderHealth,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gaiaEnabled = ref.watch(gaiaEmployeeFeatureEnabledProvider);
    final items = [
      for (final item in _items)
        if (item.route != RouteNames.gaiaEmployee || gaiaEnabled) item,
    ];
    final groupedItems = <String, List<_MoreItem>>{};
    for (final item in items) {
      groupedItems.putIfAbsent(_groupFor(item), () => []).add(item);
    }
    final theme = Theme.of(context);

    return WorkspaceShell(
      title: 'More',
      subtitle: 'Supporting modules, reference tools, and adjacent workflows.',
      onBack: () => context.go(RouteNames.dashboard),
      child: ListView(
        key: const Key('moreScreenList'),
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: _morePanelDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explore by purpose',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: AppColours.darkText,
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Supporting modules',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColours.darkText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Choose a work area first, then open the tool that fits the moment.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColours.darkMutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const _OmegaKnowledgeEngineBanner(),
          const SizedBox(height: 14),
          for (final group in _moreGroupOrder)
            if (groupedItems[group] case final groupItems?
                when groupItems.isNotEmpty) ...[
              _MoreGroupHeading(title: group),
              const SizedBox(height: 10),
              _MoreGroupGrid(items: groupItems),
              const SizedBox(height: 18),
            ],
        ],
      ),
    );
  }
}

BoxDecoration _morePanelDecoration() {
  return BoxDecoration(
    color: AppColours.darkSurface.withValues(alpha: 0.94),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.9)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ],
  );
}

class _MoreItem {
  const _MoreItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    this.badge,
  });

  final String title;
  final String description;
  final IconData icon;
  final String route;
  final String? badge;
}

const _moreGroupOrder = <String>[
  'WORK',
  'KNOWLEDGE',
  'SYSTEMS',
  'BUSINESS',
  'PERSONAL',
  'SPECIALIST',
  'HARDWARE / DEVELOPMENT',
  'ADMIN / SETTINGS',
];

String _groupFor(_MoreItem item) {
  switch (item.title) {
    case 'Treasury':
    case 'Assets':
    case 'Meeting System':
    case 'Inbox':
      return 'WORK';
    case 'About & Help':
    case 'Omega Knowledge Engine':
    case 'Education & Learning Hub':
    case 'Knowledge Library':
      return 'KNOWLEDGE';
    case 'Systems':
    case 'Platform Core Status':
    case 'Folder Health':
      return 'SYSTEMS';
    case 'Company Command Centre':
    case 'Launchpad':
    case 'Funding & Grants':
    case 'Business':
      return 'BUSINESS';
    case 'Journal':
    case 'Learning':
    case 'Content':
    case 'Wellbeing':
    case 'Visual Capture':
      return 'PERSONAL';
    case 'Repo Research Engine':
    case 'Omega Engineering Studio':
    case 'GAIA AI Employee':
    case 'Voice Intelligence':
    case 'Voice Assistant':
    case 'Alexa Voice Gateway':
    case 'Module Hub':
    case 'Omega Experiment Workspace':
    case 'Projects Intelligence':
      return 'SPECIALIST';
    case 'Command Deck':
      return 'HARDWARE / DEVELOPMENT';
    case 'Settings':
      return 'ADMIN / SETTINGS';
  }
  return 'SPECIALIST';
}

class _MoreGroupHeading extends StatelessWidget {
  const _MoreGroupHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColours.darkSecondary,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _MoreGroupGrid extends StatelessWidget {
  const _MoreGroupGrid({required this.items});

  final List<_MoreItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1000 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: crossAxisCount == 1 ? 3.2 : 2.7,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final isOmegaKnowledgeEngine =
                item.route ==
                RouteNames.modulePackage('26_OMEGA_KNOWLEDGE_ENGINE');
            return InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => context.push(item.route),
              child: Ink(
                decoration: _morePanelDecoration(),
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: isOmegaKnowledgeEngine
                            ? LinearGradient(
                                colors: [
                                  AppColours.darkSecondary.withValues(
                                    alpha: 0.22,
                                  ),
                                  AppColours.darkSurfaceRaised.withValues(
                                    alpha: 0.98,
                                  ),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isOmegaKnowledgeEngine
                            ? null
                            : AppColours.darkSurfaceRaised.withValues(
                                alpha: 0.95,
                              ),
                        border: Border.all(
                          color: isOmegaKnowledgeEngine
                              ? AppColours.darkSecondary.withValues(alpha: 0.4)
                              : AppColours.darkOutline.withValues(alpha: 0.22),
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        item.icon,
                        color: isOmegaKnowledgeEngine
                            ? AppColours.darkText
                            : AppColours.darkSecondary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColours.darkText,
                            ),
                          ),
                          if (item.badge != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColours.darkSecondary.withValues(
                                  alpha: 0.14,
                                ),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AppColours.darkSecondary.withValues(
                                    alpha: 0.26,
                                  ),
                                ),
                              ),
                              child: Text(
                                isOmegaKnowledgeEngine
                                    ? 'Scan / report only'
                                    : item.badge!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColours.darkText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            item.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColours.darkMutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColours.darkMutedText,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _OmegaKnowledgeEngineBanner extends StatelessWidget {
  const _OmegaKnowledgeEngineBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () =>
          context.push(RouteNames.modulePackage('26_OMEGA_KNOWLEDGE_ENGINE')),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColours.darkSecondary.withValues(alpha: 0.2),
              AppColours.darkSurfaceRaised.withValues(alpha: 0.98),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColours.darkSecondary.withValues(alpha: 0.38),
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColours.darkSecondary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.travel_explore_outlined,
                color: AppColours.darkText,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _OmegaChip(label: 'Scan / report only'),
                      _OmegaChip(label: 'Local knowledge engine'),
                      _OmegaChip(label: 'Read only'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Omega Knowledge Engine',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColours.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Open the local learning and scan workspace for repository indexes, architecture maps, comment suggestions, and export previews.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkMutedText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () => context.push(
                          RouteNames.modulePackage('26_OMEGA_KNOWLEDGE_ENGINE'),
                        ),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open module home'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.push(
                          '${RouteNames.omegaKnowledgeEngine}?tab=scan-results',
                        ),
                        icon: const Icon(Icons.table_view_outlined),
                        label: const Text('Open outputs'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.push(
                          '${RouteNames.omegaKnowledgeEngine}?tab=settings',
                        ),
                        icon: const Icon(Icons.settings_outlined),
                        label: const Text('Open settings'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OmegaChip extends StatelessWidget {
  const _OmegaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColours.darkSecondary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColours.darkSecondary.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColours.darkText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
