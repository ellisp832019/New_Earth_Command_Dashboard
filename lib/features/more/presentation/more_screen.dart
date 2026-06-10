import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const _items = [
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
      title: 'Systems',
      description:
          'Protect the full D: drive, review backup status, and keep recovery tools calm.',
      icon: Icons.shield_outlined,
      route: RouteNames.systems,
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
      title: 'Voice Assistant',
      description:
          'Review spoken commands safely before turning them into dashboard actions.',
      icon: Icons.mic_none_rounded,
      route: RouteNames.voiceAssistant,
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
                  'Journal, learning, content, business, wellbeing, inbox, voice, repo research, settings, projects intelligence, systems, and active system links all live here.',
                  // keep line under 120? okay
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
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
                              color: AppColours.darkSurfaceRaised.withValues(
                                alpha: 0.95,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              item.icon,
                              color: AppColours.darkSecondary,
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
  });

  final String title;
  final String description;
  final IconData icon;
  final String route;
}
