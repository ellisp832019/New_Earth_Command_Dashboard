import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/assets/presentation/assets_screen.dart';
import '../../features/assets/presentation/equipment_register_screen.dart';
import '../../features/assets/presentation/low_stock_screen.dart';
import '../../features/assets/presentation/project_summary_screen.dart';
import '../../features/assets/presentation/parts_inventory_screen.dart';
import '../../features/assets/presentation/repair_summary_screen.dart';
import '../../features/business/presentation/add_business_opportunity_screen.dart';
import '../../features/business/presentation/business_screen.dart';
import '../../features/content/presentation/add_content_item_screen.dart';
import '../../features/dashboard/presentation/calm_ui_demo_screen.dart';
import '../../features/content/presentation/content_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/inbox/presentation/add_inbox_item_screen.dart';
import '../../features/inbox/presentation/inbox_screen.dart';
import '../../features/journal/presentation/add_edit_journal_entry_screen.dart';
import '../../features/journal/presentation/journal_screen.dart';
import '../../features/learning/presentation/add_learning_item_screen.dart';
import '../../features/learning/presentation/learning_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/planner/presentation/planner_screen.dart';
import '../../features/projects/presentation/add_edit_project_screen.dart';
import '../../features/projects/presentation/project_detail_screen.dart';
import '../../features/projects/presentation/projects_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/tasks/presentation/add_edit_task_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../../features/treasury/presentation/treasury_screen.dart';
import '../../features/treasury/presentation/treasury_decisions_board_screen.dart';
import '../../features/treasury/presentation/treasury_monthly_summary_screen.dart';
import '../../features/treasury/presentation/treasury_settings_screen.dart';
import '../../features/treasury/presentation/treasury_wizard_screen.dart';
import '../../features/voice_assistant/voice_assistant_screen.dart';
import '../../features/wellbeing/presentation/add_wellbeing_checkin_screen.dart';
import '../../features/wellbeing/presentation/wellbeing_screen.dart';
import '../widgets/app_shell.dart';
import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorDashboardKey = GlobalKey<NavigatorState>();
final _shellNavigatorAssetsKey = GlobalKey<NavigatorState>();
final _shellNavigatorTreasuryKey = GlobalKey<NavigatorState>();
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
          navigatorKey: _shellNavigatorAssetsKey,
          routes: [
            GoRoute(
              path: RouteNames.assets,
              builder: (context, state) => const AssetsScreen(),
              routes: [
                GoRoute(
                  path: 'equipment',
                  builder: (context, state) => const EquipmentRegisterScreen(),
                ),
                GoRoute(
                  path: 'parts',
                  builder: (context, state) => const PartsInventoryScreen(),
                ),
                GoRoute(
                  path: 'low-stock',
                  builder: (context, state) => const LowStockScreen(),
                ),
                GoRoute(
                  path: 'repair-summary',
                  builder: (context, state) => const RepairSummaryScreen(),
                ),
                GoRoute(
                  path: 'project-summary',
                  builder: (context, state) => const ProjectSummaryScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorTreasuryKey,
          routes: [
            GoRoute(
              path: RouteNames.treasury,
              builder: (context, state) => const TreasuryScreen(),
              routes: [
                GoRoute(
                  path: 'decisions',
                  builder: (context, state) =>
                      const TreasuryDecisionsBoardScreen(),
                ),
                GoRoute(
                  path: 'monthly-summary',
                  builder: (context, state) =>
                      const TreasuryMonthlySummaryScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const TreasurySettingsScreen(),
                ),
                GoRoute(
                  path: 'wizard',
                  builder: (context, state) => TreasuryWizardScreen(
                    initialFlow: state.uri.queryParameters['flow'],
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProjectsKey,
          routes: [
            GoRoute(
              path: RouteNames.projects,
              builder: (context, state) => const ProjectsScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const AddEditProjectScreen(),
                ),
                GoRoute(
                  path: ':projectId',
                  builder: (context, state) => ProjectDetailScreen(
                    projectId: state.pathParameters['projectId']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) => AddEditProjectScreen(
                        projectId: state.pathParameters['projectId']!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorTasksKey,
          routes: [
            GoRoute(
              path: RouteNames.tasks,
              builder: (context, state) => const TasksScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => AddEditTaskScreen(
                    projectId: state.uri.queryParameters['projectId'],
                  ),
                ),
                GoRoute(
                  path: ':taskId/edit',
                  builder: (context, state) => AddEditTaskScreen(
                    taskId: state.pathParameters['taskId']!,
                  ),
                ),
              ],
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
      path: '/dashboard/treasury',
      redirect: (context, state) {
        final location = Uri(
          path: RouteNames.treasury,
          queryParameters: state.uri.queryParameters,
        );
        return location.toString();
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/dashboard/treasury/wizard',
      redirect: (context, state) {
        final location = Uri(
          path: RouteNames.treasuryWizard,
          queryParameters: state.uri.queryParameters,
        );
        return location.toString();
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/dashboard/treasury/decisions',
      redirect: (context, state) => RouteNames.treasuryDecisions,
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.journal,
      builder: (context, state) => const JournalScreen(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => AddEditJournalEntryScreen(
            projectId: state.uri.queryParameters['projectId'],
          ),
        ),
        GoRoute(
          path: ':journalEntryId/edit',
          builder: (context, state) => AddEditJournalEntryScreen(
            journalEntryId: state.pathParameters['journalEntryId']!,
          ),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.learning,
      builder: (context, state) => const LearningScreen(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => AddLearningItemScreen(
            projectId: state.uri.queryParameters['projectId'],
          ),
        ),
        GoRoute(
          path: ':learningItemId/edit',
          builder: (context, state) => AddLearningItemScreen(
            learningItemId: state.pathParameters['learningItemId']!,
          ),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.content,
      builder: (context, state) => const ContentScreen(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => AddContentItemScreen(
            projectId: state.uri.queryParameters['projectId'],
          ),
        ),
        GoRoute(
          path: ':contentItemId/edit',
          builder: (context, state) => AddContentItemScreen(
            contentItemId: state.pathParameters['contentItemId']!,
          ),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.business,
      builder: (context, state) => const BusinessScreen(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => AddBusinessOpportunityScreen(
            projectId: state.uri.queryParameters['projectId'],
          ),
        ),
        GoRoute(
          path: ':businessId/edit',
          builder: (context, state) => AddBusinessOpportunityScreen(
            businessId: state.pathParameters['businessId']!,
          ),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.wellbeing,
      builder: (context, state) => const WellbeingScreen(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const AddWellbeingCheckinScreen(),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.inbox,
      builder: (context, state) => const InboxScreen(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const AddInboxItemScreen(),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.voiceAssistant,
      builder: (context, state) => VoiceAssistantScreen(
        initialTranscript: state.uri.queryParameters['transcript'],
        initialType: state.uri.queryParameters['type'],
        wakeTriggered: state.uri.queryParameters['wake'] == '1',
        handsfreeTriggered: state.uri.queryParameters['handsfree'] == '1',
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.calmUiDemo,
      builder: (context, state) => const CalmUiDemoScreen(),
    ),
  ],
);
