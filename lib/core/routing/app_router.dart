import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/business/presentation/business_screen.dart';
import '../../features/content/presentation/content_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/inbox/presentation/inbox_screen.dart';
import '../../features/journal/presentation/journal_screen.dart';
import '../../features/learning/presentation/learning_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/planner/presentation/planner_screen.dart';
import '../../features/projects/presentation/projects_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../../features/voice_assistant/voice_assistant_screen.dart';
import '../../features/wellbeing/presentation/wellbeing_screen.dart';
import '../widgets/app_shell.dart';
import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorDashboardKey = GlobalKey<NavigatorState>();
final _shellNavigatorProjectsKey = GlobalKey<NavigatorState>();
final _shellNavigatorTasksKey = GlobalKey<NavigatorState>();
final _shellNavigatorPlannerKey = GlobalKey<NavigatorState>();
final _shellNavigatorMoreKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteNames.dashboard,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorDashboardKey,
          routes: [
            GoRoute(
              path: RouteNames.dashboard,
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProjectsKey,
          routes: [
            GoRoute(
              path: RouteNames.projects,
              builder: (context, state) => const ProjectsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorTasksKey,
          routes: [
            GoRoute(
              path: RouteNames.tasks,
              builder: (context, state) => const TasksScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorPlannerKey,
          routes: [
            GoRoute(
              path: RouteNames.planner,
              builder: (context, state) => PlannerScreen(
                initialSection: state.uri.queryParameters['section'],
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorMoreKey,
          routes: [
            GoRoute(
              path: RouteNames.more,
              builder: (context, state) => const MoreScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.journal,
      builder: (context, state) => const JournalScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.learning,
      builder: (context, state) => const LearningScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.content,
      builder: (context, state) => const ContentScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.business,
      builder: (context, state) => const BusinessScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.wellbeing,
      builder: (context, state) => const WellbeingScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.inbox,
      builder: (context, state) => const InboxScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.voiceAssistant,
      builder: (context, state) => const VoiceAssistantScreen(),
    ),
  ],
);
