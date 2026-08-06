import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import 'launchpad_screen.dart';

List<RouteBase> buildLaunchpadRoutes() {
  return [
    GoRoute(
      path: RouteNames.launchpad,
      builder: (context, state) => const LaunchpadOverviewScreen(),
      routes: [
        GoRoute(
          path: 'campaigns/:campaignId',
          builder: (context, state) => LaunchpadCampaignScreen(
            campaignId: state.pathParameters['campaignId']!,
            section: 'campaigns',
          ),
          routes: [
            GoRoute(
              path: 'campaigns',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'campaigns',
              ),
            ),
            GoRoute(
              path: 'rewards',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'rewards',
              ),
            ),
            GoRoute(
              path: 'story-builder',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'story-builder',
              ),
            ),
            GoRoute(
              path: 'readiness',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'readiness',
              ),
            ),
            GoRoute(
              path: 'financial-modeller',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'financial-modeller',
              ),
            ),
            GoRoute(
              path: 'risk-register',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'risk-register',
              ),
            ),
            GoRoute(
              path: 'media-studio',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'media-studio',
              ),
            ),
            GoRoute(
              path: 'manufacturing-planner',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'manufacturing-planner',
              ),
            ),
            GoRoute(
              path: 'community-builder',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'community-builder',
              ),
            ),
            GoRoute(
              path: 'grant-centre',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'grant-centre',
              ),
            ),
            GoRoute(
              path: 'investor-crm',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'investor-crm',
              ),
            ),
            GoRoute(
              path: 'partner-crm',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'partner-crm',
              ),
            ),
            GoRoute(
              path: 'timeline-planner',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'timeline-planner',
              ),
            ),
            GoRoute(
              path: 'analytics',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'analytics',
              ),
            ),
            GoRoute(
              path: 'launch-checklist',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'launch-checklist',
              ),
            ),
            GoRoute(
              path: 'backer-updates',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'backer-updates',
              ),
            ),
            GoRoute(
              path: 'fulfilment-tracker',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'fulfilment-tracker',
              ),
            ),
            GoRoute(
              path: 'impact-tracker',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'impact-tracker',
              ),
            ),
            GoRoute(
              path: 'archive',
              builder: (context, state) => LaunchpadCampaignScreen(
                campaignId: state.pathParameters['campaignId']!,
                section: 'archive',
              ),
            ),
          ],
        ),
      ],
    ),
  ];
}
