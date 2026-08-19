import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/omega_engineering_studio/data/engineering_repository.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/data/engineering_snapshot_reader.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_models.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_snapshot_envelope.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_snapshot_metadata.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/neos_engineering_snapshot_reader.dart';

import 'engineering_studio_test_fixtures.dart';

void main() {
  test('EngineeringSnapshotEnvelope carries snapshot and metadata', () {
    final snapshot = buildEngineeringStudioSnapshot();
    final metadata = EngineeringSnapshotMetadata(
      source: EngineeringSnapshotSource.neosLive,
      authority: EngineeringSnapshotAuthority.neos,
      capturedAt: DateTime.utc(2026, 8, 18, 12),
      refreshedAt: DateTime.utc(2026, 8, 19, 8),
      stale: false,
      partial: false,
      version: '1.0.0',
      schemaVersion: 1,
      projectScope: 'engineering',
    );
    final envelope = EngineeringSnapshotEnvelope(
      snapshot: snapshot,
      metadata: metadata,
    );

    expect(envelope.snapshot, same(snapshot));
    expect(envelope.metadata, same(metadata));
    expect(envelope.isLive, isTrue);
    expect(envelope.isFallback, isFalse);
  });

  test('EngineeringSnapshotMetadata is immutable and value-like', () {
    var capturedAt = DateTime.utc(2026, 8, 18, 12);
    var refreshedAt = DateTime.utc(2026, 8, 19, 8);

    final metadata = EngineeringSnapshotMetadata(
      source: EngineeringSnapshotSource.neosCache,
      authority: EngineeringSnapshotAuthority.neos,
      capturedAt: capturedAt,
      refreshedAt: refreshedAt,
      stale: true,
      partial: true,
      version: '1.0.0',
      schemaVersion: 2,
    );

    capturedAt = DateTime.utc(2030, 1, 1);
    refreshedAt = DateTime.utc(2030, 1, 2);

    expect(metadata.capturedAt, isNot(capturedAt));
    expect(metadata.refreshedAt, isNot(refreshedAt));
    expect(
      metadata,
      equals(
        EngineeringSnapshotMetadata(
          source: EngineeringSnapshotSource.neosCache,
          authority: EngineeringSnapshotAuthority.neos,
          capturedAt: DateTime.utc(2026, 8, 18, 12),
          refreshedAt: DateTime.utc(2026, 8, 19, 8),
          stale: true,
          partial: true,
          version: '1.0.0',
          schemaVersion: 2,
        ),
      ),
    );
  });

  test(
    'EngineeringSnapshotMetadata represents source and authority values',
    () {
      expect(
        EngineeringSnapshotSource.values,
        containsAll(<EngineeringSnapshotSource>[
          EngineeringSnapshotSource.neosLive,
          EngineeringSnapshotSource.neosCache,
          EngineeringSnapshotSource.dashboardLocalCache,
          EngineeringSnapshotSource.seededFallback,
          EngineeringSnapshotSource.importedHistorical,
        ]),
      );
      expect(
        EngineeringSnapshotAuthority.values,
        containsAll(<EngineeringSnapshotAuthority>[
          EngineeringSnapshotAuthority.neos,
          EngineeringSnapshotAuthority.dashboardLocal,
          EngineeringSnapshotAuthority.imported,
          EngineeringSnapshotAuthority.fallback,
        ]),
      );
    },
  );

  test(
    'EngineeringSnapshotMetadata exposes optional scope and fallback reason',
    () {
      final metadata = EngineeringSnapshotMetadata(
        source: EngineeringSnapshotSource.seededFallback,
        authority: EngineeringSnapshotAuthority.fallback,
        capturedAt: DateTime.utc(2026, 8, 19, 7),
        stale: true,
        partial: false,
        version: '1.0.0',
        schemaVersion: 1,
        fallbackReason: 'offline seed',
      );

      expect(metadata.projectScope, isNull);
      expect(metadata.fallbackReason, 'offline seed');
      expect(metadata.isFallback, isTrue);
      expect(metadata.stale, isTrue);
      expect(metadata.partial, isFalse);
    },
  );

  test('EngineeringSnapshotMetadata derives age from timestamps', () {
    final metadata = EngineeringSnapshotMetadata(
      source: EngineeringSnapshotSource.dashboardLocalCache,
      authority: EngineeringSnapshotAuthority.dashboardLocal,
      capturedAt: DateTime.now().toUtc().subtract(const Duration(hours: 4)),
      refreshedAt: DateTime.now().toUtc().subtract(const Duration(hours: 2)),
      stale: true,
      partial: false,
      version: '1.0.0',
      schemaVersion: 1,
    );

    expect(metadata.age, isA<Duration>());
    expect(metadata.age.inHours, greaterThanOrEqualTo(1));
  });

  test('NeosEngineeringSnapshotReader exposes read operations only', () async {
    final snapshot = buildEngineeringStudioSnapshot();
    final reader = CountingNeosEngineeringSnapshotReader(
      EngineeringSnapshotEnvelope(
        snapshot: snapshot,
        metadata: EngineeringSnapshotMetadata(
          source: EngineeringSnapshotSource.neosLive,
          authority: EngineeringSnapshotAuthority.neos,
          capturedAt: DateTime.utc(2026, 8, 19, 8),
          stale: false,
          partial: false,
          version: '1.0.0',
          schemaVersion: 1,
        ),
      ),
    );

    final envelope = await reader.loadEngineeringSnapshot(
      projectScope: 'engineering',
    );

    expect(envelope.snapshot, same(snapshot));
    expect(reader.readCalls, 1);
    expect(reader, isNot(isA<EngineeringRepository>()));
  });

  test('EngineeringSnapshotReader remains unchanged for local reads', () async {
    final snapshot = buildEngineeringStudioSnapshot();
    final repository = CountingEngineeringSnapshotRepository(snapshot);
    final reader = LocalEngineeringSnapshotReader(repository);

    final loaded = await reader.loadSnapshot();

    expect(loaded, same(snapshot));
    expect(repository.loadSnapshotCalls, 1);
    expect(reader, isNot(isA<NeosEngineeringSnapshotReader>()));
  });
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

class CountingNeosEngineeringSnapshotReader
    implements NeosEngineeringSnapshotReader {
  CountingNeosEngineeringSnapshotReader(this._envelope);

  final EngineeringSnapshotEnvelope _envelope;
  int readCalls = 0;

  @override
  Future<EngineeringSnapshotEnvelope> loadEngineeringSnapshot({
    String? projectScope,
  }) async {
    readCalls++;
    return _envelope;
  }
}
