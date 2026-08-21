import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/omega_engineering_studio/application/engineering_studio_dependencies.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/data/engineering_repository.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_models.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_snapshot_envelope.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_snapshot_metadata.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/neos_read_transport.dart';

import 'engineering_studio_test_fixtures.dart';
import 'fakes/fake_neos_engineering_snapshot_reader.dart';

void main() {
  test(
    'EngineeringStudioDependencies.local accepts a fake snapshot reader',
    () async {
      final snapshot = buildEngineeringStudioSnapshot();
      final repository = EngineeringStudioFakeRepository(snapshot);
      final fakeReader = CountingEngineeringSnapshotReader(snapshot);
      final dependencies = EngineeringStudioDependencies.local(
        projectScope: EngineeringProjectScope.fromDashboardProjectId(
          'project_microgrow',
          canonicalProjectId: 'microgrow',
        ),
        repository: repository,
        snapshotReader: fakeReader,
      );

      final loaded = await dependencies.snapshotReader.loadSnapshot();

      expect(loaded, same(snapshot));
      expect(fakeReader.loadSnapshotCalls, 1);
    },
  );

  test(
    'mapped project scopes use the live NEOS read path and keep local cache idle',
    () async {
      final liveEnvelope = _envelope(
        source: EngineeringSnapshotSource.neosLive,
        authority: EngineeringSnapshotAuthority.neos,
        projectScope: 'microgrow',
        capturedAt: DateTime.utc(2026, 8, 19, 8, 20),
        refreshedAt: DateTime.utc(2026, 8, 19, 8, 20),
        stale: false,
        partial: false,
        version: '1.3.0',
        schemaVersion: 11,
      );
      final liveReader = FakeNeosEngineeringSnapshotReader(
        envelope: liveEnvelope,
      );
      final localReader = CountingPersistedSnapshotReader(
        buildEngineeringStudioSnapshot(),
      );
      var seededCalls = 0;

      final reader = EngineeringStudioRuntimeSnapshotReader(
        projectScope: EngineeringProjectScope.fromDashboardProjectId(
          'project_microgrow',
          canonicalProjectId: 'microgrow',
        ),
        localReader: localReader,
        liveReader: liveReader,
        seededSnapshotBuilder: () {
          seededCalls++;
          return buildEngineeringStudioSnapshot();
        },
      );

      final loaded = await reader.loadSnapshot();

      expect(loaded, same(liveEnvelope.snapshot));
      expect(reader.latestEnvelope, same(liveEnvelope));
      expect(reader.latestMetadata, same(liveEnvelope.metadata));
      expect(liveReader.loadEngineeringSnapshotCalls, 1);
      expect(liveReader.lastProjectScope, 'microgrow');
      expect(localReader.loadPersistedSnapshotIfPresentCalls, 0);
      expect(seededCalls, 0);
    },
  );

  test(
    'unmapped project scopes attempt NEOS once before falling back to the local cache',
    () async {
      final localSnapshot = buildEngineeringStudioSnapshot();
      final liveReader = FakeNeosEngineeringSnapshotReader(
        envelope: _envelope(
          source: EngineeringSnapshotSource.neosLive,
          authority: EngineeringSnapshotAuthority.neos,
          projectScope: 'project_future_ideas',
          capturedAt: DateTime.utc(2026, 8, 19, 8, 20),
          refreshedAt: DateTime.utc(2026, 8, 19, 8, 20),
          stale: false,
          partial: false,
          version: '1.3.0',
          schemaVersion: 11,
        ),
        error: NeosTransportTimeoutException(
          'timeout',
          uri: Uri.parse('http://127.0.0.1:8765/health'),
        ),
      );
      final localReader = CountingPersistedSnapshotReader(localSnapshot);
      var seededCalls = 0;

      final reader = EngineeringStudioRuntimeSnapshotReader(
        projectScope: EngineeringProjectScope.fromDashboardProjectId(
          'project_future_ideas',
        ),
        localReader: localReader,
        liveReader: liveReader,
        seededSnapshotBuilder: () {
          seededCalls++;
          return buildEngineeringStudioSnapshot();
        },
      );

      final envelope = await reader.loadEnvelope();

      expect(envelope.snapshot, same(localSnapshot));
      expect(
        envelope.metadata.source,
        EngineeringSnapshotSource.dashboardLocalCache,
      );
      expect(
        envelope.metadata.authority,
        EngineeringSnapshotAuthority.dashboardLocal,
      );
      expect(envelope.metadata.projectScope, 'project_future_ideas');
      expect(envelope.metadata.fallbackReason, 'neos_timeout');
      expect(reader.latestEnvelope, same(envelope));
      expect(reader.latestMetadata, same(envelope.metadata));
      expect(liveReader.loadEngineeringSnapshotCalls, 1);
      expect(liveReader.lastProjectScope, 'project_future_ideas');
      expect(localReader.loadPersistedSnapshotIfPresentCalls, 1);
      expect(seededCalls, 0);
    },
  );

  test(
    'unmapped project scopes fall back to the seeded snapshot when the cache is empty',
    () async {
      final liveReader = FakeNeosEngineeringSnapshotReader(
        envelope: _envelope(
          source: EngineeringSnapshotSource.neosLive,
          authority: EngineeringSnapshotAuthority.neos,
          projectScope: 'project_future_ideas',
          capturedAt: DateTime.utc(2026, 8, 19, 8, 20),
          refreshedAt: DateTime.utc(2026, 8, 19, 8, 20),
          stale: false,
          partial: false,
          version: '1.3.0',
          schemaVersion: 11,
        ),
        error: NeosTransportTimeoutException(
          'timeout',
          uri: Uri.parse('http://127.0.0.1:8765/health'),
        ),
      );
      final localReader = NullPersistedSnapshotReader();
      var seededCalls = 0;

      final reader = EngineeringStudioRuntimeSnapshotReader(
        projectScope: EngineeringProjectScope.fromDashboardProjectId(
          'project_future_ideas',
        ),
        localReader: localReader,
        liveReader: liveReader,
        seededSnapshotBuilder: () {
          seededCalls++;
          return buildEngineeringStudioSnapshot();
        },
      );

      final envelope = await reader.loadEnvelope();

      expect(
        envelope.metadata.source,
        EngineeringSnapshotSource.seededFallback,
      );
      expect(
        envelope.metadata.authority,
        EngineeringSnapshotAuthority.fallback,
      );
      expect(envelope.metadata.projectScope, 'project_future_ideas');
      expect(envelope.metadata.fallbackReason, 'neos_timeout');
      expect(liveReader.loadEngineeringSnapshotCalls, 1);
      expect(liveReader.lastProjectScope, 'project_future_ideas');
      expect(localReader.loadPersistedSnapshotIfPresentCalls, 1);
      expect(seededCalls, 1);
    },
  );

  test(
    'EngineeringStudioDependencies.local composes the runtime reader with the repository as the persisted read source',
    () async {
      final liveReader = FakeNeosEngineeringSnapshotReader(
        envelope: _envelope(
          source: EngineeringSnapshotSource.neosLive,
          authority: EngineeringSnapshotAuthority.neos,
          projectScope: 'project_microgrow',
          capturedAt: DateTime.utc(2026, 8, 19, 8, 20),
          refreshedAt: DateTime.utc(2026, 8, 19, 8, 20),
          stale: false,
          partial: false,
          version: '1.3.0',
          schemaVersion: 11,
        ),
        error: StateError('neos down'),
      );
      final repository = CountingRuntimeRepository(
        buildEngineeringStudioSnapshot(),
      );
      final dependencies = EngineeringStudioDependencies.local(
        projectScope: EngineeringProjectScope.fromDashboardProjectId(
          'project_microgrow',
          canonicalProjectId: 'microgrow',
        ),
        repository: repository,
        liveReader: liveReader,
      );

      final loaded = await dependencies.snapshotReader.loadSnapshot();

      expect(loaded, same(repository.snapshot));
      expect(
        dependencies.snapshotReader,
        isA<EngineeringStudioRuntimeSnapshotReader>(),
      );
      expect(liveReader.loadEngineeringSnapshotCalls, 1);
      expect(liveReader.lastProjectScope, 'microgrow');
      expect(repository.loadPersistedSnapshotIfPresentCalls, 1);
      expect(repository.loadSnapshotCalls, 0);
    },
  );
}

class CountingEngineeringSnapshotReader extends EngineeringSnapshotReader {
  CountingEngineeringSnapshotReader(this.snapshot);

  final EngineeringSnapshot snapshot;
  int loadSnapshotCalls = 0;

  @override
  Future<EngineeringSnapshot> loadSnapshot() async {
    loadSnapshotCalls++;
    return snapshot;
  }
}

class CountingPersistedSnapshotReader
    implements PersistedEngineeringSnapshotReader {
  CountingPersistedSnapshotReader(this.snapshot);

  final EngineeringSnapshot snapshot;
  int loadPersistedSnapshotIfPresentCalls = 0;

  @override
  Future<EngineeringSnapshot?> loadPersistedSnapshotIfPresent() async {
    loadPersistedSnapshotIfPresentCalls++;
    return snapshot;
  }
}

class NullPersistedSnapshotReader
    implements PersistedEngineeringSnapshotReader {
  int loadPersistedSnapshotIfPresentCalls = 0;

  @override
  Future<EngineeringSnapshot?> loadPersistedSnapshotIfPresent() async {
    loadPersistedSnapshotIfPresentCalls++;
    return null;
  }
}

class CountingRuntimeRepository extends EngineeringRepository
    implements PersistedEngineeringSnapshotReader {
  CountingRuntimeRepository(this.snapshot);

  EngineeringSnapshot snapshot;
  int loadSnapshotCalls = 0;
  int loadPersistedSnapshotIfPresentCalls = 0;

  @override
  Future<EngineeringSnapshot> loadSnapshot() async {
    loadSnapshotCalls++;
    return snapshot;
  }

  @override
  Future<EngineeringSnapshot?> loadPersistedSnapshotIfPresent() async {
    loadPersistedSnapshotIfPresentCalls++;
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

EngineeringSnapshotEnvelope _envelope({
  required EngineeringSnapshotSource source,
  required EngineeringSnapshotAuthority authority,
  required String projectScope,
  required DateTime capturedAt,
  required DateTime refreshedAt,
  required bool stale,
  required bool partial,
  required String version,
  required int schemaVersion,
}) {
  return EngineeringSnapshotEnvelope(
    snapshot: buildEngineeringStudioSnapshot(),
    metadata: EngineeringSnapshotMetadata(
      source: source,
      authority: authority,
      capturedAt: capturedAt,
      refreshedAt: refreshedAt,
      stale: stale,
      partial: partial,
      version: version,
      schemaVersion: schemaVersion,
      projectScope: projectScope,
    ),
  );
}
