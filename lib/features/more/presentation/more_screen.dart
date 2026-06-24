import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const _items = [
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
          'Run the local command centre for Stream Deck workflows, scripts, and setup.',
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
      route: RouteNames.omegaKnowledgeEngine,
      badge: 'Scan',
    ),
    _MoreItem(
      title: 'Systems',
      description:
          'Protect the full D: drive, review backup status, and keep recovery tools calm.',
      icon: Icons.shield_outlined,
      route: RouteNames.systems,
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
          'Search the Omega OS PDF catalogue and review extractable items.',
      icon: Icons.library_books_outlined,
      route: RouteNames.knowledgeLibrary,
    ),
    _MoreItem(
      title: 'Projects Intelligence',
      description:
          'Review read-only project and repo health from the bridge layer.',
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
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
                            'More',
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
                            'A calm home for supporting modules, reference tools, and dashboard-adjacent workflows.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColours.darkMutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    TextButton.icon(
                      onPressed: () => context.go(RouteNames.dashboard),
                      icon: const Icon(Icons.dashboard_outlined, size: 18),
                      label: const Text('Back to Dashboard'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 1000 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: crossAxisCount == 1 ? 3.2 : 2.7,
                ),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final isOmegaKnowledgeEngine =
                      item.route == RouteNames.omegaKnowledgeEngine;
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
                                        AppColours.darkSecondary
                                            .withValues(alpha: 0.22),
                                        AppColours.darkSurfaceRaised
                                            .withValues(alpha: 0.98),
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
                                    ? AppColours.darkSecondary
                                        .withValues(alpha: 0.4)
                                    : AppColours.darkOutline
                                        .withValues(alpha: 0.22),
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
                                      color: isOmegaKnowledgeEngine
                                          ? AppColours.darkSecondary
                                              .withValues(alpha: 0.22)
                                          : AppColours.darkSecondary
                                              .withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: isOmegaKnowledgeEngine
                                            ? AppColours.darkSecondary
                                                .withValues(alpha: 0.5)
                                            : AppColours.darkSecondary
                                                .withValues(alpha: 0.26),
                                      ),
                                    ),
                                    child: Text(
                                      isOmegaKnowledgeEngine
                                          ? 'Scan / report only'
                                          : item.badge!,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
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
          ),
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
