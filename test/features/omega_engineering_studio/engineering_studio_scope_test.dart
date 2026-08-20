import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/application/engineering_studio_dependencies.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/data/engineering_repository.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_models.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/presentation/engineering_studio_screen.dart';
import 'package:new_earth_command_dashboard/features/project_intelligence/data/project_repo_bridge_models.dart';

import 'engineering_studio_test_fixtures.dart';

void main() {
  test('engineering project scope preserves explicit canonical identity', () {
    final scope = EngineeringProjectScope.fromDashboardProjectId(
      'project_microgrow',
      canonicalProjectId: 'microgrow',
      displayName: 'MicroGrow',
    );

    expect(scope.projectId, 'project_microgrow');
    expect(scope.canonicalProjectId, 'microgrow');
    expect(scope.displayName, 'MicroGrow');
    expect(scope.neosProjectId, 'microgrow');
  });

  test('engineering project scope leaves unmapped projects explicit', () {
    final scope = EngineeringProjectScope.fromDashboardProjectId(
      'project_future_ideas',
      displayName: 'Future Ideas',
    );

    expect(scope.projectId, 'project_future_ideas');
    expect(scope.canonicalProjectId, isNull);
    expect(scope.neosProjectId, isNull);
  });

  test('engineering studio route helpers preserve project scope', () {
    expect(
      RouteNames.omegaEngineeringStudioForProject(
        'project_microgrow',
        canonicalProjectId: 'microgrow',
      ),
      '/modules/omega-engineering-studio?projectId=project_microgrow&canonicalProjectId=microgrow',
    );
    expect(
      RouteNames.omegaEngineeringStudioSection(
        'projects',
        projectId: 'project_microgrow',
      ),
      '/modules/omega-engineering-studio/projects?projectId=project_microgrow',
    );
  });

  test('existing repo bridge records can supply the canonical project id', () {
    final projects = [
      UnifiedProjectRecord(
        projectId: 'project_microgrow',
        name: 'MicroGrow',
        dashboardStatus: 'Active',
        dashboardTasks: const [],
        repoLinked: true,
        repoId: 'microgrow',
        nextActions: const [],
        codexHandoffReady: false,
        lastMergedAt: '2026-06-07T10:00:00Z',
      ),
      UnifiedProjectRecord(
        projectId: 'project_future_ideas',
        name: 'Future Ideas',
        dashboardStatus: 'Idea',
        dashboardTasks: const [],
        repoLinked: false,
        nextActions: const [],
        codexHandoffReady: false,
        lastMergedAt: '2026-06-07T10:00:00Z',
      ),
    ];

    final resolved = _canonicalProjectIdFor(projects, 'project_microgrow');
    final unmapped = _canonicalProjectIdFor(projects, 'project_future_ideas');

    expect(resolved, 'microgrow');
    expect(unmapped, isNull);
  });

  test(
    'local engineering studio dependencies share one repository instance',
    () async {
      final snapshot = buildEngineeringStudioSnapshot();
      final repository = CountingEngineeringStudioRepository(snapshot);
      final dependencies = EngineeringStudioDependencies.local(
        projectScope: EngineeringProjectScope.fromDashboardProjectId(
          'project_microgrow',
        ),
        repository: repository,
      );

      final loaded = await dependencies.snapshotReader.loadSnapshot();

      expect(loaded, same(snapshot));
      expect(identical(dependencies.repository, repository), isTrue);
      expect(repository.loadSnapshotCalls, 1);
    },
  );

  testWidgets('EngineeringStudioScreen surfaces the supplied project scope', (
    tester,
  ) async {
    final snapshot = buildEngineeringStudioSnapshot();
    final repository = CountingEngineeringStudioRepository(snapshot);
    final dependencies = EngineeringStudioDependencies.local(
      projectScope: EngineeringProjectScope.fromDashboardProjectId(
        'project_microgrow',
      ),
      repository: repository,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: EngineeringStudioScreen(dependencies: dependencies),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('project_microgrow'), findsWidgets);
    expect(find.text('Recent activity'), findsOneWidget);
    expect(repository.loadSnapshotCalls, 1);
  });
}

String? _canonicalProjectIdFor(
  List<UnifiedProjectRecord> projects,
  String dashboardProjectId,
) {
  for (final project in projects) {
    if (project.projectId == dashboardProjectId) {
      return project.repoId;
    }
  }
  return null;
}

class CountingEngineeringStudioRepository extends EngineeringRepository {
  CountingEngineeringStudioRepository(this.snapshot);

  EngineeringSnapshot snapshot;
  int loadSnapshotCalls = 0;

  @override
  Future<EngineeringSnapshot> loadSnapshot() async {
    loadSnapshotCalls++;
    return snapshot;
  }

  @override
  Future<void> saveSnapshot(EngineeringSnapshot snapshot) async {
    this.snapshot = snapshot;
  }

  @override
  Future<void> resetLocalState() async {}

  @override
  Future<EngineeringProject> createProject({
    required String title,
    required String summary,
    required String status,
    required String priority,
    required int progressPercent,
    required String milestone,
    required String nextAction,
    required String system,
    DateTime? targetDate,
    required List<String> tags,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<EngineeringProject> updateProject(EngineeringProject project) async {
    throw UnimplementedError();
  }

  @override
  Future<CircuitBlock> upsertCircuitBlock(CircuitBlock block) async {
    throw UnimplementedError();
  }

  @override
  Future<PCBRevision> upsertPcbRevision(PCBRevision revision) async {
    throw UnimplementedError();
  }

  @override
  Future<FirmwareBuild> upsertFirmwareBuild(FirmwareBuild build) async {
    throw UnimplementedError();
  }

  @override
  Future<DeviceNode> upsertDeviceNode(DeviceNode device) async {
    throw UnimplementedError();
  }

  @override
  Future<EngineeringDocument> upsertDocument(
    EngineeringDocument document,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<EngineeringAttachment> upsertAttachment(
    EngineeringAttachment attachment,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> exportSnapshot(File destination) async {
    throw UnimplementedError();
  }

  @override
  Future<EngineeringSnapshot> importSnapshot(File source) async {
    throw UnimplementedError();
  }
}
