import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/project_intelligence/application/project_intelligence_controller.dart';
import 'package:new_earth_command_dashboard/features/project_intelligence/data/project_repo_bridge_models.dart';
import 'package:new_earth_command_dashboard/features/project_intelligence/presentation/projects_intelligence_screen.dart';
import 'package:new_earth_command_dashboard/features/projects/application/projects_controller.dart';
import 'package:new_earth_command_dashboard/features/settings/data/settings_repository.dart';
import 'package:new_earth_command_dashboard/features/settings/application/settings_controller.dart';

void main() {
  testWidgets('projects hub shows workflow spotlight and route', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final router = GoRouter(
      initialLocation: RouteNames.projectsIntelligence,
      routes: [
        GoRoute(
          path: RouteNames.projectsIntelligence,
          builder: (context, state) => const ProjectsIntelligenceScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) => database),
          databaseReadyProvider.overrideWith((ref) async {}),
          projectIntelligenceBundleProvider.overrideWith(
            (ref) async => _bundle,
          ),
          projectsProvider.overrideWith((ref) async => const []),
          settingsSnapshotProvider.overrideWith(
            (ref) async => SettingsSnapshot(
              settings: AppSetting(
                settingsId: 'settings-test',
                themeMode: 'Dark',
                defaultDashboardView: 'Dashboard',
                showWellbeingCard: true,
                showBusinessCard: true,
                showLearningCard: true,
                showContentCard: true,
                showProjectsWorkspaceSnapshot: false,
                showDockOverlays: true,
                showBackupGuardianDock: true,
                showTreasuryDock: true,
                showKnowledgeLibraryDock: true,
                showVoiceConversationDock: true,
                showVoicePresenceChip: true,
                showGaiaEmployeeSurface: false,
                dailyTopTaskLimit: 3,
                voiceRepliesEnabled: false,
                voiceAssistantEnabled: false,
                voiceStartupGateEnabled: false,
                preferredTtsVoiceName: null,
                preferredTtsVoiceLocale: null,
                preferredTtsVoiceGender: null,
                preferredTtsVoiceIdentifier: null,
                preferredTtsVoiceRate: 0.5,
                preferredTtsVoicePitch: 1.0,
                createdAt: DateTime(2026, 5, 2),
                updatedAt: DateTime(2026, 5, 2),
              ),
              appVersion: 'test',
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final projectsHubScrollView = find.byKey(
      const Key('projectsHubScrollView'),
    );

    for (
      var i = 0;
      i < 6 && find.text('Project workflow spotlight').evaluate().isEmpty;
      i++
    ) {
      await tester.drag(projectsHubScrollView, const Offset(0, -480));
      await tester.pumpAndSettle();
    }
    await tester.pump();

    expect(find.textContaining('Projects Hub'), findsWidgets);
    expect(find.text('Project workflow spotlight'), findsOneWidget);
    expect(find.text('MicroGrow'), findsAtLeastNWidgets(1));
    expect(find.text('Open detail'), findsOneWidget);
    expect(find.text('Add task'), findsOneWidget);
    expect(find.text('Add journal'), findsOneWidget);
    expect(find.text('Add learning'), findsOneWidget);
    expect(find.text('Add content'), findsOneWidget);
    expect(find.text('CODEX'), findsOneWidget);
    expect(find.textContaining('Ready'), findsWidgets);
  });
}

final _bundle = ProjectRepoBridgeBundle(
  mergedAt: '2026-06-07T10:00:00Z',
  outputPath:
      'D:/modules/project_repo_bridge/data/unified/unified_projects.json',
  projects: [
    UnifiedProjectRecord(
      projectId: 'project-microgrow',
      name: 'MicroGrow',
      dashboardStatus: 'Active',
      dashboardDescription: 'Calm diagnostics and field scanner work.',
      dashboardTasks: [
        UnifiedTaskRecord(
          id: 'task-1',
          title: 'Stabilise diagnostics',
          status: 'Today',
          projectId: 'project-microgrow',
          priority: 'High',
        ),
      ],
      repoLinked: true,
      repoId: 'microgrow',
      repoPath: 'D:/Dev/Projects/MicroGrow V1',
      omegaPath: 'D:/NEW_EARTH_OMEGA_OS_PACK/21_PROJECTS_AND_PROGRAMMES',
      currentPhase: 'Diagnostics',
      latestRepoStatus: RepoSnapshot(
        id: 'microgrow',
        name: 'MicroGrow',
        repoPath: 'D:/Dev/Projects/MicroGrow V1',
        exists: true,
        isGitRepo: true,
        tags: const ['active'],
        dirtyFiles: const ['lib/main.dart'],
        recentCommits: const ['abc123'],
        docsFound: const ['README.md'],
        todoMarkers: [
          RepoTodoMarker(
            file: 'lib/main.dart',
            line: 12,
            text: 'Refine the scanner status card.',
          ),
        ],
        scanWarnings: const [],
        scannedAt: '2026-06-07T10:00:00Z',
        dashboardProjectId: 'project-microgrow',
        currentPhase: 'Diagnostics',
        branch: 'main',
        latestCommit: 'abc123def456',
        latestCommitDate: '2026-06-06',
      ),
      nextActions: [
        'Refine the scanner status card.',
        'Capture the next build note.',
      ],
      codexHandoffReady: true,
      lastMergedAt: '2026-06-07T10:00:00Z',
    ),
    UnifiedProjectRecord(
      projectId: 'project-website',
      name: 'New Earth Website',
      dashboardStatus: 'Active',
      dashboardDescription: 'Founder journey and public presence work.',
      dashboardTasks: [],
      repoLinked: true,
      repoId: 'new-earth-website',
      repoPath: 'D:/Dev/Projects/New Earth Website',
      omegaPath: null,
      currentPhase: 'Content refresh',
      latestRepoStatus: RepoSnapshot(
        id: 'new-earth-website',
        name: 'New Earth Website',
        repoPath: 'D:/Dev/Projects/New Earth Website',
        exists: true,
        isGitRepo: true,
        tags: const ['active'],
        dirtyFiles: const [],
        recentCommits: const ['fedcba'],
        docsFound: const ['plan.md'],
        todoMarkers: const [],
        scanWarnings: const [],
        scannedAt: '2026-06-07T10:00:00Z',
        dashboardProjectId: 'project-website',
        currentPhase: 'Content refresh',
        branch: 'main',
        latestCommit: 'fedcba654321',
        latestCommitDate: '2026-06-06',
      ),
      nextActions: const ['Review the founder journey page.'],
      codexHandoffReady: false,
      lastMergedAt: '2026-06-07T10:00:00Z',
    ),
  ],
);
