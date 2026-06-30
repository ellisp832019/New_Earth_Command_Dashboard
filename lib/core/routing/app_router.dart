import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/assets/presentation/assets_screen.dart';
import '../../features/assets/presentation/equipment_register_screen.dart';
import '../../features/assets/presentation/low_stock_screen.dart';
import '../../features/assets/presentation/location_register_screen.dart';
import '../../features/assets/presentation/evidence_library_screen.dart';
import '../../features/assets/presentation/bin_map_screen.dart';
import '../../features/assets/presentation/qr_label_lifecycle_screen.dart';
import '../../features/assets/presentation/project_summary_screen.dart';
import '../../features/assets/presentation/parts_inventory_screen.dart';
import '../../features/assets/presentation/maintenance_log_screen.dart';
import '../../features/assets/presentation/repair_summary_screen.dart';
import '../../features/assets/presentation/quick_capture_screen.dart';
import '../../features/assets/presentation/orders_tracker_screen.dart';
import '../../features/assets/presentation/reorder_list_screen.dart';
import '../../features/assets/presentation/supplier_register_screen.dart';
import '../../features/assets/presentation/asset_conflicts_screen.dart';
import '../../features/assets/presentation/qr_label_register_screen.dart';
import '../../features/assets/presentation/qr_label_studio_screen.dart';
import '../../features/assets/presentation/qr_label_history_screen.dart';
import '../../features/assets/presentation/qr_print_queue_screen.dart';
import '../../features/assets/presentation/inventory_session_screen.dart';
import '../../features/assets/presentation/scan_lookup_screen.dart';
import '../../features/assets/presentation/valuation_summary_screen.dart';
import '../../features/visual_capture/presentation/visual_capture_screen.dart';
import '../../features/about_help/presentation/about_help_screen.dart';
import '../../features/business/presentation/add_business_opportunity_screen.dart';
import '../../features/business/presentation/business_screen.dart';
import '../../features/content/presentation/add_content_item_screen.dart';
import '../../features/dashboard/presentation/calm_ui_demo_screen.dart';
import '../../features/content/presentation/content_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/company_command_centre/presentation/company_command_centre_screen.dart';
import '../../features/dashboard/presentation/command_palette_screen.dart';
import '../../features/inbox/presentation/add_inbox_item_screen.dart';
import '../../features/inbox/presentation/inbox_screen.dart';
import '../../features/journal/presentation/add_edit_journal_entry_screen.dart';
import '../../features/journal/presentation/journal_screen.dart';
import '../../features/learning/presentation/add_learning_item_screen.dart';
import '../../features/learning/presentation/learning_screen.dart';
import '../../features/launchpad/presentation/launchpad_routes.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/knowledge_library/presentation/knowledge_library_screen.dart';
import '../../features/command_deck/presentation/command_deck_screen.dart';
import '../../features/funding_grants_command_centre/presentation/funding_grants_command_centre_screen.dart';
import '../../features/repo_research_engine/presentation/repo_research_engine_screen.dart';
import '../../features/systems/presentation/systems_screen.dart';
import '../../features/system_backup/presentation/backup_guardian_screen.dart';
import '../../features/meeting_system/presentation/all_meetings_screen.dart';
import '../../features/meeting_system/presentation/meeting_actions_screen.dart';
import '../../features/meeting_system/presentation/meeting_dashboard_screen.dart';
import '../../features/meeting_system/presentation/meeting_decisions_screen.dart';
import '../../features/meeting_system/presentation/meeting_detail_screen.dart';
import '../../features/meeting_system/presentation/meeting_follow_ups_screen.dart';
import '../../features/meeting_system/presentation/meeting_settings_screen.dart';
import '../../features/meeting_system/presentation/meeting_templates_screen.dart';
import '../../features/meeting_system/presentation/new_meeting_wizard_screen.dart';
import '../../features/alexa_voice_gateway/presentation/alexa_voice_gateway_screen.dart';
import '../../features/experiments/presentation/omega_experiment_screen.dart';
import '../../features/project_intelligence/presentation/projects_intelligence_screen.dart';
import '../../features/repo_intelligence_bridge/presentation/repo_intelligence_bridge_screen.dart';
import '../../features/repo_intelligence_bridge/presentation/repo_intelligence_bridge_settings_screen.dart';
import '../../features/modules/module_detail_screen.dart';
import '../../features/modules/module_docking_screen.dart';
import '../../features/modules/module_governance_screen.dart';
import '../../features/modules/module_operations_screen.dart';
import '../../features/modules/module_permissions_screen.dart';
import '../../features/modules/module_settings_screen.dart';
import '../../features/modules/modules_screen.dart';
import '../../features/omega_knowledge_engine/presentation/omega_knowledge_engine_screen.dart';
import '../../features/users_devices_control/presentation/users_devices_control_screen.dart';
import '../../features/users_devices_control/presentation/users_devices_pins_screen.dart';
import '../../features/planner/presentation/planner_screen.dart';
import '../../features/projects/presentation/add_edit_project_screen.dart';
import '../../features/projects/presentation/project_detail_screen.dart';
import '../../features/projects/presentation/projects_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/omega_os_folder_health_screen.dart';
import '../../features/security/presentation/security_lock_screen.dart';
import '../../features/security/presentation/security_startup_screen.dart';
import '../../features/security/application/security_session_controller.dart';
import '../../features/tasks/presentation/add_edit_task_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../../features/treasury/presentation/treasury_screen.dart';
import '../../features/treasury/presentation/treasury_decisions_board_screen.dart';
import '../../features/treasury/presentation/treasury_budget_pots_screen.dart';
import '../../features/treasury/presentation/treasury_monthly_summary_screen.dart';
import '../../features/treasury/presentation/treasury_settings_screen.dart';
import '../../features/treasury/presentation/treasury_wizard_screen.dart';
import '../../features/voice_intelligence/presentation/voice_module_screen.dart';
import '../../features/voice_intelligence/presentation/voice_conversation_screen.dart';
import '../../features/voice_assistant/voice_assistant_screen.dart';
import '../../features/voice_assistant/presentation/voice_startup_gate_route_screen.dart';
import '../../features/wellbeing/presentation/add_wellbeing_checkin_screen.dart';
import '../../features/wellbeing/presentation/wellbeing_screen.dart';
import '../widgets/app_shell.dart';
import 'security_route_policy.dart';
import 'router_keys.dart';
import 'route_names.dart';
import '../modules/module_loader.dart';

final _rootNavigatorKey = rootNavigatorKey;
final _shellNavigatorDashboardKey = GlobalKey<NavigatorState>();
final _shellNavigatorAssetsKey = GlobalKey<NavigatorState>();
final _shellNavigatorTreasuryKey = GlobalKey<NavigatorState>();
final _shellNavigatorProjectsKey = GlobalKey<NavigatorState>();
final _shellNavigatorTasksKey = GlobalKey<NavigatorState>();
final _shellNavigatorPlannerKey = GlobalKey<NavigatorState>();
final _shellNavigatorMoreKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteNames.startup,
  refreshListenable: SecuritySessionRouterBridge.refresh,
  redirect: (context, state) {
    final session = SecuritySessionRouterBridge.current;
    return SecurityRoutePolicy.redirectForSession(
      requestedUri: state.uri,
      session: session,
    );
  },
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
              routes: [
                GoRoute(
                  path: 'search',
                  builder: (context, state) => const CommandPaletteScreen(),
                ),
              ],
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
                  builder: (context, state) => EquipmentRegisterScreen(
                    initialSearch: state.uri.queryParameters['q'],
                    initialAssetId: state.uri.queryParameters['assetId'],
                  ),
                ),
                GoRoute(
                  path: 'parts',
                  builder: (context, state) => PartsInventoryScreen(
                    initialSearch: state.uri.queryParameters['q'],
                  ),
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
                GoRoute(
                  path: 'locations',
                  builder: (context, state) => const LocationRegisterScreen(),
                ),
                GoRoute(
                  path: 'bin-map',
                  builder: (context, state) => const BinMapScreen(),
                ),
                GoRoute(
                  path: 'qr-lifecycle',
                  builder: (context, state) => const QrLabelLifecycleScreen(),
                ),
                GoRoute(
                  path: 'evidence',
                  builder: (context, state) => const EvidenceLibraryScreen(),
                ),
                GoRoute(
                  path: 'valuation',
                  builder: (context, state) => const ValuationSummaryScreen(),
                ),
                GoRoute(
                  path: 'qr-labels',
                  builder: (context, state) => const QrLabelRegisterScreen(),
                ),
                GoRoute(
                  path: 'qr-studio',
                  builder: (context, state) => const QrLabelStudioScreen(),
                ),
                GoRoute(
                  path: 'qr-history',
                  builder: (context, state) => const QrLabelHistoryScreen(),
                ),
                GoRoute(
                  path: 'qr-print-queue',
                  builder: (context, state) => const QrPrintQueueScreen(),
                ),
                GoRoute(
                  path: 'scan-lookup',
                  builder: (context, state) => const ScanLookupScreen(),
                ),
                GoRoute(
                  path: 'inventory-session',
                  builder: (context, state) => const InventorySessionScreen(),
                ),
                GoRoute(
                  path: 'conflicts',
                  builder: (context, state) => const AssetConflictsScreen(),
                ),
                GoRoute(
                  path: 'quick-capture',
                  builder: (context, state) => const QuickCaptureScreen(),
                ),
                GoRoute(
                  path: 'suppliers',
                  builder: (context, state) => const SupplierRegisterScreen(),
                ),
                GoRoute(
                  path: 'maintenance',
                  builder: (context, state) => const MaintenanceLogScreen(),
                ),
                GoRoute(
                  path: 'reorder-list',
                  builder: (context, state) => const ReorderListScreen(),
                ),
                GoRoute(
                  path: 'orders',
                  builder: (context, state) => const OrdersTrackerScreen(),
                ),
                GoRoute(
                  path: 'visual-capture',
                  builder: (context, state) => const VisualCaptureScreen(),
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
              builder: (context, state) => const UsersDevicesRouteGateScreen(
                moduleId: '17_FINANCE_AND_TREASURY',
                title: 'Treasury Access Gate',
                subtitle:
                    'Confirm local identity and device trust before opening finance and treasury.',
                child: TreasuryScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'decisions',
                  builder: (context, state) => const UsersDevicesRouteGateScreen(
                    moduleId: '17_FINANCE_AND_TREASURY',
                    title: 'Treasury Decisions Gate',
                    subtitle:
                        'Confirm local identity and device trust before opening treasury decisions.',
                    child: TreasuryDecisionsBoardScreen(),
                  ),
                ),
                GoRoute(
                  path: 'budget-pots',
                  builder: (context, state) => const UsersDevicesRouteGateScreen(
                    moduleId: '17_FINANCE_AND_TREASURY',
                    title: 'Budget Pots Gate',
                    subtitle:
                        'Confirm local identity and device trust before opening budget pots.',
                    child: TreasuryBudgetPotsScreen(),
                  ),
                ),
                GoRoute(
                  path: 'monthly-summary',
                  builder: (context, state) => const UsersDevicesRouteGateScreen(
                    moduleId: '17_FINANCE_AND_TREASURY',
                    title: 'Monthly Summary Gate',
                    subtitle:
                        'Confirm local identity and device trust before opening the monthly summary.',
                    child: TreasuryMonthlySummaryScreen(),
                  ),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const UsersDevicesRouteGateScreen(
                    moduleId: '17_FINANCE_AND_TREASURY',
                    title: 'Treasury Settings Gate',
                    subtitle:
                        'Confirm local identity and device trust before opening treasury settings.',
                    child: TreasurySettingsScreen(),
                  ),
                ),
                GoRoute(
                  path: 'wizard',
                  builder: (context, state) => UsersDevicesRouteGateScreen(
                    moduleId: '17_FINANCE_AND_TREASURY',
                    title: 'Treasury Wizard Gate',
                    subtitle:
                        'Confirm local identity and device trust before opening the treasury wizard.',
                    child: TreasuryWizardScreen(
                      initialFlow: state.uri.queryParameters['flow'],
                      initialStepIndex: int.tryParse(
                        state.uri.queryParameters['step'] ?? '',
                      ),
                    ),
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
              path: RouteNames.projectsIntelligence,
              builder: (context, state) => const ProjectsIntelligenceScreen(),
              routes: [
                GoRoute(
                  path: 'repo-bridge',
                  builder: (context, state) => const UsersDevicesRouteGateScreen(
                    moduleId: 'repo_research_engine',
                    title: 'Repo Bridge Gate',
                    subtitle:
                        'Confirm local identity and device trust before opening the repo bridge.',
                    child: RepoIntelligenceBridgeScreen(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'settings',
                      builder: (context, state) =>
                          const UsersDevicesRouteGateScreen(
                            moduleId: 'repo_research_engine',
                            title: 'Repo Bridge Settings Gate',
                            subtitle:
                                'Confirm local identity and device trust before opening bridge settings.',
                            child: RepoIntelligenceBridgeSettingsScreen(),
                          ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'workspace',
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
                    initialTitle: state.uri.queryParameters['title'],
                    initialDescription:
                        state.uri.queryParameters['description'],
                    initialNotes: state.uri.queryParameters['notes'],
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
              routes: [
                GoRoute(
                  path: 'module-hub',
                  builder: (context, state) => const ModulesScreen(),
                  routes: [
                    GoRoute(
                      path: 'experiments',
                      builder: (context, state) =>
                          const OmegaExperimentScreen(),
                      routes: [
                        GoRoute(
                          path: 'new',
                          builder: (context, state) =>
                              const OmegaExperimentScreen(
                                initialSection:
                                    OmegaExperimentScreenSection.create,
                              ),
                        ),
                        GoRoute(
                          path: 'evidence',
                          builder: (context, state) =>
                              const OmegaExperimentScreen(
                                initialSection:
                                    OmegaExperimentScreenSection.evidence,
                              ),
                        ),
                        GoRoute(
                          path: 'results',
                          builder: (context, state) =>
                              const OmegaExperimentScreen(
                                initialSection:
                                    OmegaExperimentScreenSection.results,
                              ),
                        ),
                        GoRoute(
                          path: 'lessons',
                          builder: (context, state) =>
                              const OmegaExperimentScreen(
                                initialSection:
                                    OmegaExperimentScreenSection.lessons,
                              ),
                        ),
                        GoRoute(
                          path: 'reports',
                          builder: (context, state) =>
                              const OmegaExperimentScreen(
                                initialSection:
                                    OmegaExperimentScreenSection.reports,
                              ),
                        ),
                        GoRoute(
                          path: 'integrations',
                          builder: (context, state) =>
                              const OmegaExperimentScreen(
                                initialSection:
                                    OmegaExperimentScreenSection.integrations,
                              ),
                        ),
                        GoRoute(
                          path: 'ai-review',
                          builder: (context, state) =>
                              const OmegaExperimentScreen(
                                initialSection:
                                    OmegaExperimentScreenSection.aiReview,
                              ),
                        ),
                        GoRoute(
                          path: 'settings',
                          builder: (context, state) =>
                              const OmegaExperimentScreen(
                                initialSection:
                                    OmegaExperimentScreenSection.settings,
                              ),
                        ),
                        GoRoute(
                          path: ':experimentId',
                          builder: (context, state) => OmegaExperimentScreen(
                            initialExperimentId:
                                state.pathParameters['experimentId'],
                          ),
                        ),
                      ],
                    ),
                    GoRoute(
                      path: ':moduleId',
                      builder: (context, state) {
                        final registry = const ModuleLoader().load();
                        final module =
                            registry.byId(state.pathParameters['moduleId']!) ??
                            registry.all.first;
                        return ModuleDetailScreen(module: module);
                      },
                      routes: [
                        GoRoute(
                          path: 'operations',
                          builder: (context, state) {
                            final registry = const ModuleLoader().load();
                            final module =
                                registry.byId(
                                  state.pathParameters['moduleId']!,
                                ) ??
                                registry.all.first;
                            return ModuleOperationsScreen(module: module);
                          },
                        ),
                        GoRoute(
                          path: 'docking',
                          builder: (context, state) {
                            final registry = const ModuleLoader().load();
                            final module =
                                registry.byId(
                                  state.pathParameters['moduleId']!,
                                ) ??
                                registry.all.first;
                            return ModuleDockingScreen(module: module);
                          },
                        ),
                        GoRoute(
                          path: 'governance',
                          builder: (context, state) {
                            final registry = const ModuleLoader().load();
                            final module =
                                registry.byId(
                                  state.pathParameters['moduleId']!,
                                ) ??
                                registry.all.first;
                            return ModuleGovernanceScreen(module: module);
                          },
                        ),
                        GoRoute(
                          path: 'settings',
                          builder: (context, state) {
                            final registry = const ModuleLoader().load();
                            final module =
                                registry.byId(
                                  state.pathParameters['moduleId']!,
                                ) ??
                                registry.all.first;
                            return ModuleSettingsScreen(module: module);
                          },
                        ),
                        GoRoute(
                          path: 'permissions',
                          builder: (context, state) {
                            final registry = const ModuleLoader().load();
                            final module =
                                registry.byId(
                                  state.pathParameters['moduleId']!,
                                ) ??
                                registry.all.first;
                            return ModulePermissionsScreen(module: module);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                GoRoute(
                  path: 'about-help',
                  builder: (context, state) => AboutHelpScreen(
                    initialSectionId: state.uri.queryParameters['section'],
                    initialDocumentPath: state.uri.queryParameters['doc'],
                  ),
                ),
                GoRoute(
                  path: 'systems',
                  builder: (context, state) => const SystemsScreen(),
                  routes: [
                    GoRoute(
                      path: 'backup-guardian',
                      builder: (context, state) => const BackupGuardianScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'command-deck',
                  builder: (context, state) => const CommandDeckScreen(),
                ),
                GoRoute(
                  path: 'repo-research-engine',
                  builder: (context, state) => const UsersDevicesRouteGateScreen(
                    moduleId: 'repo_research_engine',
                    title: 'Repo Research Gate',
                    subtitle:
                        'Confirm local identity and device trust before opening repo research.',
                    child: RepoResearchEngineScreen(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'scanner',
                      builder: (context, state) =>
                          const UsersDevicesRouteGateScreen(
                            moduleId: 'repo_research_engine',
                            title: 'Repo Scanner Gate',
                            subtitle:
                                'Confirm local identity and device trust before opening the scanner.',
                            child: RepoResearchEngineScreen(
                              initialSection: 'scanner',
                            ),
                          ),
                    ),
                    GoRoute(
                      path: 'reports',
                      builder: (context, state) =>
                          const UsersDevicesRouteGateScreen(
                            moduleId: 'repo_research_engine',
                            title: 'Repo Reports Gate',
                            subtitle:
                                'Confirm local identity and device trust before opening reports.',
                            child: RepoResearchEngineScreen(
                              initialSection: 'reports',
                            ),
                          ),
                    ),
                    GoRoute(
                      path: 'profiles',
                      builder: (context, state) =>
                          const UsersDevicesRouteGateScreen(
                            moduleId: 'repo_research_engine',
                            title: 'Repo Profiles Gate',
                            subtitle:
                                'Confirm local identity and device trust before opening profiles.',
                            child: RepoResearchEngineScreen(
                              initialSection: 'profiles',
                            ),
                          ),
                    ),
                    GoRoute(
                      path: 'exports',
                      builder: (context, state) =>
                          const UsersDevicesRouteGateScreen(
                            moduleId: 'repo_research_engine',
                            title: 'Repo Exports Gate',
                            subtitle:
                                'Confirm local identity and device trust before opening exports.',
                            child: RepoResearchEngineScreen(
                              initialSection: 'exports',
                            ),
                          ),
                    ),
                    GoRoute(
                      path: 'prompts',
                      builder: (context, state) =>
                          const UsersDevicesRouteGateScreen(
                            moduleId: 'repo_research_engine',
                            title: 'Repo Prompts Gate',
                            subtitle:
                                'Confirm local identity and device trust before opening prompts.',
                            child: RepoResearchEngineScreen(
                              initialSection: 'prompts',
                            ),
                          ),
                    ),
                    GoRoute(
                      path: 'settings',
                      builder: (context, state) =>
                          const UsersDevicesRouteGateScreen(
                            moduleId: 'repo_research_engine',
                            title: 'Repo Settings Gate',
                            subtitle:
                                'Confirm local identity and device trust before opening settings.',
                            child: RepoResearchEngineScreen(
                              initialSection: 'settings',
                            ),
                          ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'meetings',
                  builder: (context, state) => const MeetingDashboardScreen(),
                  routes: [
                    GoRoute(
                      path: 'all',
                      builder: (context, state) => const AllMeetingsScreen(),
                    ),
                    GoRoute(
                      path: 'new',
                      builder: (context, state) =>
                          const NewMeetingWizardScreen(),
                    ),
                    GoRoute(
                      path: 'actions',
                      builder: (context, state) => const MeetingActionsScreen(),
                    ),
                    GoRoute(
                      path: 'decisions',
                      builder: (context, state) =>
                          const MeetingDecisionsScreen(),
                    ),
                    GoRoute(
                      path: 'follow-ups',
                      builder: (context, state) =>
                          const MeetingFollowUpsScreen(),
                    ),
                    GoRoute(
                      path: 'templates',
                      builder: (context, state) =>
                          const MeetingTemplatesScreen(),
                    ),
                    GoRoute(
                      path: 'settings',
                      builder: (context, state) =>
                          const MeetingSettingsScreen(),
                    ),
                    GoRoute(
                      path: ':meetingId',
                      builder: (context, state) => MeetingDetailScreen(
                        meetingId: state.pathParameters['meetingId']!,
                        initialTabIndex:
                            state.uri.queryParameters['tab'] == 'transcripts'
                            ? 5
                            : 0,
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'funding-grants',
                  builder: (context, state) =>
                      const FundingGrantsCommandCentreScreen(),
                ),
                GoRoute(
                  path: 'knowledge-library',
                  builder: (context, state) => const KnowledgeLibraryScreen(),
                ),
                GoRoute(
                  path: 'projects-intelligence',
                  builder: (context, state) =>
                      const ProjectsIntelligenceScreen(),
                ),
                GoRoute(
                  path: 'omega-os-health',
                  builder: (context, state) =>
                      const OmegaOsFolderHealthScreen(),
                ),
                GoRoute(
                  path: 'alexa-voice-gateway',
                  builder: (context, state) => const UsersDevicesRouteGateScreen(
                    moduleId: 'NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE',
                    title: 'Voice Gateway Gate',
                    subtitle:
                        'Confirm local identity and device trust before opening the Alexa gateway.',
                    child: AlexaVoiceGatewayScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    ...buildLaunchpadRoutes(),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.projectsIntelligenceLegacy,
      redirect: (context, state) => RouteNames.projectsIntelligence,
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.projects,
      redirect: (context, state) => Uri(
        path: RouteNames.projectsIntelligence,
        queryParameters: state.uri.queryParameters,
      ).toString(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.newProject,
      redirect: (context, state) => Uri(
        path: '${RouteNames.projectsWorkspace}/new',
        queryParameters: state.uri.queryParameters,
      ).toString(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/projects/:projectId/edit',
      redirect: (context, state) => Uri(
        path:
            '${RouteNames.projectsWorkspace}/${state.pathParameters['projectId']!}/edit',
        queryParameters: state.uri.queryParameters,
      ).toString(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/projects/:projectId',
      redirect: (context, state) => Uri(
        path:
            '${RouteNames.projectsWorkspace}/${state.pathParameters['projectId']!}',
        queryParameters: state.uri.queryParameters,
      ).toString(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.visualCapture,
      builder: (context, state) => const VisualCaptureScreen(),
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
      path: RouteNames.experimentWorkspace,
      redirect: (context, state) =>
          RouteNames.moduleHubModule(RouteNames.experimentModuleId),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/experiments/new',
      redirect: (context, state) =>
          '${RouteNames.moduleHubModule(RouteNames.experimentModuleId)}/new',
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/experiments/evidence',
      redirect: (context, state) =>
          '${RouteNames.moduleHubModule(RouteNames.experimentModuleId)}/evidence',
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/experiments/results',
      redirect: (context, state) =>
          '${RouteNames.moduleHubModule(RouteNames.experimentModuleId)}/results',
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/experiments/lessons',
      redirect: (context, state) =>
          '${RouteNames.moduleHubModule(RouteNames.experimentModuleId)}/lessons',
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/experiments/reports',
      redirect: (context, state) =>
          '${RouteNames.moduleHubModule(RouteNames.experimentModuleId)}/reports',
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/experiments/integrations',
      redirect: (context, state) =>
          '${RouteNames.moduleHubModule(RouteNames.experimentModuleId)}/integrations',
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/experiments/ai-review',
      redirect: (context, state) =>
          '${RouteNames.moduleHubModule(RouteNames.experimentModuleId)}/ai-review',
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/experiments/settings',
      redirect: (context, state) =>
          '${RouteNames.moduleHubModule(RouteNames.experimentModuleId)}/settings',
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/experiments/:experimentId',
      redirect: (context, state) =>
          '${RouteNames.moduleHubModule(RouteNames.experimentModuleId)}/${state.pathParameters['experimentId']!}',
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
            initialTitle: state.uri.queryParameters['title'],
            initialWhatIWorkedOn: state.uri.queryParameters['whatIWorkedOn'],
            initialWhatILearned: state.uri.queryParameters['whatILearned'],
            initialNextActions: state.uri.queryParameters['nextActions'],
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
            initialTopic: state.uri.queryParameters['topic'],
            initialReason: state.uri.queryParameters['reason'],
            initialResourceLink: state.uri.queryParameters['resourceLink'],
            initialNotes: state.uri.queryParameters['notes'],
            initialNextStep: state.uri.queryParameters['nextStep'],
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
            initialTitle: state.uri.queryParameters['title'],
            initialDraftText: state.uri.queryParameters['draftText'],
            initialImagePrompt: state.uri.queryParameters['imagePrompt'],
            initialNotes: state.uri.queryParameters['notes'],
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
      path: RouteNames.companyCommandCentre,
      builder: (context, state) => const CompanyCommandCentreScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.omegaKnowledgeEngine,
      builder: (context, state) => const OmegaKnowledgeEngineScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.securityLock,
      builder: (context, state) => const SecurityLockScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.startup,
      builder: (context, state) => const SecurityStartupScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.voiceStartupGate,
      builder: (context, state) => const VoiceStartupGateRouteScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.usersDevices,
      builder: (context, state) => const UsersDevicesRouteGateScreen(
        moduleId: '01_USERS_AND_DEVICES_CONTROL',
        child: UsersDevicesControlScreen(),
      ),
      routes: [
        GoRoute(
          path: 'users',
          builder: (context, state) => const UsersDevicesRouteGateScreen(
            moduleId: '01_USERS_AND_DEVICES_CONTROL',
            title: 'Users Access Gate',
            subtitle:
                'Confirm local identity and device trust before opening the user registry.',
            child: UsersDevicesUsersScreen(),
          ),
        ),
        GoRoute(
          path: 'devices',
          builder: (context, state) => const UsersDevicesRouteGateScreen(
            moduleId: '01_USERS_AND_DEVICES_CONTROL',
            title: 'Devices Access Gate',
            subtitle:
                'Confirm local identity and device trust before opening the device registry.',
            child: UsersDevicesDevicesScreen(),
          ),
        ),
        GoRoute(
          path: 'access-matrix',
          builder: (context, state) => const UsersDevicesRouteGateScreen(
            moduleId: '01_USERS_AND_DEVICES_CONTROL',
            title: 'Access Matrix Gate',
            subtitle:
                'Confirm local identity and device trust before opening the access matrix.',
            child: UsersDevicesAccessMatrixScreen(),
          ),
        ),
        GoRoute(
          path: 'onboarding',
          builder: (context, state) => const UsersDevicesRouteGateScreen(
            moduleId: '01_USERS_AND_DEVICES_CONTROL',
            title: 'Onboarding Gate',
            subtitle:
                'Confirm local identity and device trust before opening device onboarding.',
            child: UsersDevicesDeviceOnboardingScreen(),
          ),
        ),
        GoRoute(
          path: 'onboarding-report',
          builder: (context, state) => UsersDevicesRouteGateScreen(
            moduleId: '01_USERS_AND_DEVICES_CONTROL',
            title: 'Onboarding Report Gate',
            subtitle:
                'Confirm local identity and device trust before opening onboarding reporting.',
            child: UsersDevicesOnboardingReportScreen(
              initialUserId: state.uri.queryParameters['userId'],
              initialStatusFilter: state.uri.queryParameters['status'] ?? 'all',
            ),
          ),
        ),
        GoRoute(
          path: 'approvals',
          builder: (context, state) => const UsersDevicesRouteGateScreen(
            moduleId: '01_USERS_AND_DEVICES_CONTROL',
            title: 'Approvals Gate',
            subtitle:
                'Confirm local identity and device trust before opening the approval queue.',
            child: UsersDevicesApprovalQueueScreen(),
          ),
        ),
        GoRoute(
          path: 'audit',
          builder: (context, state) => UsersDevicesRouteGateScreen(
            moduleId: '01_USERS_AND_DEVICES_CONTROL',
            title: 'Audit Gate',
            subtitle:
                'Confirm local identity and device trust before opening the audit log.',
            child: UsersDevicesAuditLogScreen(
              highlightEventId: state.uri.queryParameters['eventId'],
            ),
          ),
        ),
        GoRoute(
          path: 'pins',
          builder: (context, state) => UsersDevicesRouteGateScreen(
            moduleId: '01_USERS_AND_DEVICES_CONTROL',
            title: 'PIN Registry Gate',
            subtitle:
                'Confirm local identity and device trust before opening PIN management.',
            child: UsersDevicesPinsScreen(
              initialUserId: state.uri.queryParameters['userId'],
            ),
          ),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.voice,
      redirect: (context, state) {
        if (state.uri.queryParameters['view'] == 'home') {
          return null;
        }
        return RouteNames.voiceConversation;
      },
      builder: (context, state) => const UsersDevicesRouteGateScreen(
        moduleId: 'gaia_voice_assistant',
        title: 'Voice Access Gate',
        subtitle:
            'Confirm local identity and device trust before opening the voice surface.',
        child: VoiceModuleScreen(section: VoiceModuleSection.home),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.voiceConversation,
      builder: (context, state) => const UsersDevicesRouteGateScreen(
        moduleId: 'gaia_voice_assistant',
        title: 'Voice Conversation Gate',
        subtitle:
            'Confirm local identity and device trust before opening voice conversation.',
        child: VoiceConversationScreen(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.voiceNotes,
      builder: (context, state) => const UsersDevicesRouteGateScreen(
        moduleId: 'gaia_voice_assistant',
        title: 'Voice Notes Gate',
        subtitle:
            'Confirm local identity and device trust before opening voice notes.',
        child: VoiceModuleScreen(section: VoiceModuleSection.notes),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.voiceMeetings,
      builder: (context, state) => const UsersDevicesRouteGateScreen(
        moduleId: 'gaia_voice_assistant',
        title: 'Voice Meetings Gate',
        subtitle:
            'Confirm local identity and device trust before opening voice meetings.',
        child: VoiceModuleScreen(section: VoiceModuleSection.meetings),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.voiceDashboardAssistant,
      builder: (context, state) => const UsersDevicesRouteGateScreen(
        moduleId: 'gaia_voice_assistant',
        title: 'Assistant Gate',
        subtitle:
            'Confirm local identity and device trust before opening the dashboard assistant.',
        child: VoiceModuleScreen(section: VoiceModuleSection.assistant),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.voiceMicrogrow,
      builder: (context, state) => const UsersDevicesRouteGateScreen(
        moduleId: 'gaia_voice_assistant',
        title: 'MicroGrow Voice Gate',
        subtitle:
            'Confirm local identity and device trust before opening MicroGrow voice control.',
        child: VoiceModuleScreen(section: VoiceModuleSection.microgrow),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.voiceAudit,
      builder: (context, state) => const UsersDevicesRouteGateScreen(
        moduleId: 'gaia_voice_assistant',
        title: 'Voice Audit Gate',
        subtitle:
            'Confirm local identity and device trust before opening the voice audit trail.',
        child: VoiceModuleScreen(section: VoiceModuleSection.audit),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.voiceSettings,
      builder: (context, state) => const UsersDevicesRouteGateScreen(
        moduleId: 'gaia_voice_assistant',
        title: 'Voice Settings Gate',
        subtitle:
            'Confirm local identity and device trust before opening voice settings.',
        child: VoiceModuleScreen(section: VoiceModuleSection.settings),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.voiceAssistant,
      builder: (context, state) => UsersDevicesRouteGateScreen(
        moduleId: 'gaia_voice_assistant',
        title: 'Voice Assistant Gate',
        subtitle:
            'Confirm local identity and device trust before opening voice assistant.',
        child: VoiceAssistantScreen(
          initialTranscript: state.uri.queryParameters['transcript'],
          initialType: state.uri.queryParameters['type'],
          startInWizardMode: state.uri.queryParameters['mode'] == 'wizard',
          wakeTriggered: state.uri.queryParameters['wake'] == '1',
          handsfreeTriggered: state.uri.queryParameters['handsfree'] == '1',
        ),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteNames.calmUiDemo,
      builder: (context, state) => const CalmUiDemoScreen(),
    ),
  ],
);
