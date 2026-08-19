import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/omega_engineering_studio/data/engineering_repository.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/data/engineering_snapshot_reader.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_models.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/presentation/engineering_studio_screen.dart';

import 'engineering_studio_test_fixtures.dart';

void main() {
  test('LocalEngineeringSnapshotReader delegates loadSnapshot only', () async {
    final snapshot = buildEngineeringStudioSnapshot();
    final repository = CountingEngineeringSnapshotRepository(snapshot);
    final reader = LocalEngineeringSnapshotReader(repository);

    final loaded = await reader.loadSnapshot();

    expect(identical(loaded, snapshot), isTrue);
    expect(repository.loadSnapshotCalls, 1);
    expect(reader, isNot(isA<EngineeringRepository>()));
  });

  testWidgets(
    'EngineeringStudioScreen reads through the snapshot reader seam',
    (tester) async {
      final snapshot = buildEngineeringStudioSnapshot();
      final reader = CountingEngineeringSnapshotReader(snapshot);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: EngineeringStudioScreen(
            repository: EngineeringStudioFakeRepository(snapshot),
            snapshotReader: reader,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Recent activity'), findsOneWidget);
      expect(find.text('Power cycle evidence pack'), findsOneWidget);
      expect(reader.loadSnapshotCalls, 1);
    },
  );
}

class CountingEngineeringSnapshotRepository extends EngineeringRepository {
  CountingEngineeringSnapshotRepository(this.snapshot);

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

class CountingEngineeringSnapshotReader extends EngineeringSnapshotReader {
  CountingEngineeringSnapshotReader(this._snapshot);

  final EngineeringSnapshot _snapshot;
  int loadSnapshotCalls = 0;

  @override
  Future<EngineeringSnapshot> loadSnapshot() async {
    loadSnapshotCalls++;
    return _snapshot;
  }
}
