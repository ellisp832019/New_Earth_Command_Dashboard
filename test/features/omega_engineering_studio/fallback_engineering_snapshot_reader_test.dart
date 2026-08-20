import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/omega_engineering_studio/application/fallback_engineering_snapshot_reader.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/data/engineering_repository.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_models.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_snapshot_envelope.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_snapshot_metadata.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/neos_read_transport.dart';

import 'engineering_studio_test_fixtures.dart';
import 'fakes/fake_neos_engineering_snapshot_reader.dart';

void main() {
  test(
    'NEOS success returns the live result without calling fallback sources',
    () async {
      final liveEnvelope = _envelope(
        source: EngineeringSnapshotSource.neosLive,
        authority: EngineeringSnapshotAuthority.neos,
        capturedAt: DateTime.utc(2026, 8, 19, 8, 20),
        refreshedAt: DateTime.utc(2026, 8, 19, 8, 20),
        stale: false,
        partial: true,
        version: '1.3.0',
        schemaVersion: 11,
        projectScope: 'engineering',
      );
      final liveReader = FakeNeosEngineeringSnapshotReader(
        envelope: liveEnvelope,
      );
      final localReader = CountingPersistedSnapshotReader(
        buildEngineeringStudioSnapshot(),
      );
      var seededCalls = 0;

      final reader = FallbackEngineeringSnapshotReader(
        liveReader: liveReader,
        localReader: localReader,
        seededSnapshotBuilder: (_) {
          seededCalls++;
          return buildEngineeringStudioSnapshot();
        },
      );

      final envelope = await reader.loadEngineeringSnapshot(
        projectScope: 'engineering',
      );

      expect(envelope, same(liveEnvelope));
      expect(liveReader.loadEngineeringSnapshotCalls, 1);
      expect(localReader.loadPersistedSnapshotIfPresentCalls, 0);
      expect(seededCalls, 0);
      expect(envelope.metadata.source, EngineeringSnapshotSource.neosLive);
      expect(envelope.metadata.authority, EngineeringSnapshotAuthority.neos);
      expect(envelope.metadata.fallbackReason, isNull);
    },
  );

  test(
    'NEOS transport and payload failures fall back to dashboard local cache',
    () async {
      final scenarios = <_Scenario>[
        _Scenario(
          label: 'timeout',
          error: NeosTransportTimeoutException(
            'timeout',
            uri: Uri.parse('http://127.0.0.1/health'),
          ),
          expectedReason: 'neos_timeout',
        ),
        _Scenario(
          label: 'connection',
          error: NeosTransportConnectionException(
            'connection',
            uri: Uri.parse('http://127.0.0.1/health'),
          ),
          expectedReason: 'neos_unavailable',
        ),
        _Scenario(
          label: 'http',
          error: NeosTransportHttpException(
            'http error',
            statusCode: 503,
            body: '{}',
            headers: const {},
            uri: Uri.parse('http://127.0.0.1/health'),
          ),
          expectedReason: 'neos_http_error',
        ),
        _Scenario(
          label: 'payload',
          error: FormatException('malformed payload'),
          expectedReason: 'neos_invalid_payload',
        ),
      ];

      for (final scenario in scenarios) {
        final liveReader = FakeNeosEngineeringSnapshotReader(
          envelope: _envelope(
            source: EngineeringSnapshotSource.neosLive,
            authority: EngineeringSnapshotAuthority.neos,
            capturedAt: DateTime.utc(2026, 8, 19, 8, 20),
            stale: false,
            partial: true,
            version: '1.3.0',
            schemaVersion: 11,
            projectScope: 'engineering',
          ),
          error: scenario.error,
        );
        final localSnapshot = buildEngineeringStudioSnapshot();
        final localReader = CountingPersistedSnapshotReader(localSnapshot);
        var seededCalls = 0;

        final reader = FallbackEngineeringSnapshotReader(
          liveReader: liveReader,
          localReader: localReader,
          seededSnapshotBuilder: (_) {
            seededCalls++;
            return buildEngineeringStudioSnapshot();
          },
        );

        final envelope = await reader.loadEngineeringSnapshot(
          projectScope: 'engineering',
        );

        expect(envelope.snapshot, same(localSnapshot), reason: scenario.label);
        expect(
          envelope.metadata.source,
          EngineeringSnapshotSource.dashboardLocalCache,
          reason: scenario.label,
        );
        expect(
          envelope.metadata.authority,
          EngineeringSnapshotAuthority.dashboardLocal,
          reason: scenario.label,
        );
        expect(envelope.metadata.stale, isTrue, reason: scenario.label);
        expect(envelope.metadata.partial, isFalse, reason: scenario.label);
        expect(
          envelope.metadata.fallbackReason,
          scenario.expectedReason,
          reason: scenario.label,
        );
        expect(
          envelope.metadata.projectScope,
          'engineering',
          reason: scenario.label,
        );
        expect(
          liveReader.loadEngineeringSnapshotCalls,
          1,
          reason: scenario.label,
        );
        expect(
          localReader.loadPersistedSnapshotIfPresentCalls,
          1,
          reason: scenario.label,
        );
        expect(seededCalls, 0, reason: scenario.label);
      }
    },
  );

  test(
    'Seeded fallback is used when local cached state is unavailable',
    () async {
      final liveReader = FakeNeosEngineeringSnapshotReader(
        envelope: _envelope(
          source: EngineeringSnapshotSource.neosLive,
          authority: EngineeringSnapshotAuthority.neos,
          capturedAt: DateTime.utc(2026, 8, 19, 8, 20),
          stale: false,
          partial: true,
          version: '1.3.0',
          schemaVersion: 11,
          projectScope: 'microgrow',
        ),
        error: NeosTransportTimeoutException(
          'timeout',
          uri: Uri.parse('http://127.0.0.1/health'),
        ),
      );
      final localReader = ThrowingPersistedSnapshotReader(
        StateError('no local cache'),
      );
      String? seededScope;
      var seededCalls = 0;

      final reader = FallbackEngineeringSnapshotReader(
        liveReader: liveReader,
        localReader: localReader,
        seededSnapshotBuilder: (projectScope) {
          seededCalls++;
          seededScope = projectScope;
          return buildEngineeringStudioSnapshot();
        },
      );

      final envelope = await reader.loadEngineeringSnapshot(
        projectScope: 'microgrow',
      );

      expect(envelope.snapshot.projectCount, greaterThan(0));
      expect(
        envelope.metadata.source,
        EngineeringSnapshotSource.seededFallback,
      );
      expect(
        envelope.metadata.authority,
        EngineeringSnapshotAuthority.fallback,
      );
      expect(envelope.metadata.stale, isTrue);
      expect(envelope.metadata.partial, isFalse);
      expect(envelope.metadata.fallbackReason, 'neos_timeout');
      expect(envelope.metadata.projectScope, 'microgrow');
      expect(seededScope, 'microgrow');
      expect(liveReader.loadEngineeringSnapshotCalls, 1);
      expect(localReader.loadPersistedSnapshotIfPresentCalls, 1);
      expect(seededCalls, 1);
    },
  );

  test(
    'project scope is preserved and terminal failure is deterministic',
    () async {
      final liveReader = FakeNeosEngineeringSnapshotReader(
        envelope: _envelope(
          source: EngineeringSnapshotSource.neosLive,
          authority: EngineeringSnapshotAuthority.neos,
          capturedAt: DateTime.utc(2026, 8, 19, 8, 20),
          stale: false,
          partial: true,
          version: '1.3.0',
          schemaVersion: 11,
          projectScope: 'alpha/project',
        ),
        error: NeosTransportHttpException(
          'http error',
          statusCode: 503,
          body: '{}',
          headers: const {},
          uri: Uri.parse('http://127.0.0.1/health'),
        ),
      );
      final localReader = ThrowingPersistedSnapshotReader(
        StateError('no local cache'),
      );
      var seededCalls = 0;

      final reader = FallbackEngineeringSnapshotReader(
        liveReader: liveReader,
        localReader: localReader,
        seededSnapshotBuilder: (_) {
          seededCalls++;
          throw StateError('no seed available');
        },
      );

      await expectLater(
        reader.loadEngineeringSnapshot(projectScope: 'alpha/project'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'engineering_snapshot_unavailable:neos_http_error',
          ),
        ),
      );
      expect(liveReader.lastProjectScope, 'alpha/project');
      expect(liveReader.loadEngineeringSnapshotCalls, 1);
      expect(localReader.loadPersistedSnapshotIfPresentCalls, 1);
      expect(seededCalls, 1);
    },
  );

  test(
    'policy source stays read-only and has no runtime wiring or writes',
    () async {
      final source = await File(
        'lib/features/omega_engineering_studio/application/fallback_engineering_snapshot_reader.dart',
      ).readAsString();

      expect(source, isNot(contains('saveSnapshot')));
      expect(source, isNot(contains('insertOnConflictUpdate')));
      expect(source, isNot(contains('EngineeringLocalDatabase')));
      expect(source, isNot(contains('Provider')));
      expect(source, isNot(contains('Widget')));
      expect(source, isNot(contains('go_router')));
      expect(source, isNot(contains('poll')));
      expect(source, isNot(contains('retry')));
    },
  );
}

class CountingPersistedSnapshotReader
    implements PersistedEngineeringSnapshotReader {
  CountingPersistedSnapshotReader(this.snapshot);

  EngineeringSnapshot snapshot;
  int loadPersistedSnapshotIfPresentCalls = 0;

  @override
  Future<EngineeringSnapshot?> loadPersistedSnapshotIfPresent() async {
    loadPersistedSnapshotIfPresentCalls++;
    return snapshot;
  }
}

class ThrowingPersistedSnapshotReader
    implements PersistedEngineeringSnapshotReader {
  ThrowingPersistedSnapshotReader(this.error);

  final Object error;
  int loadPersistedSnapshotIfPresentCalls = 0;

  @override
  Future<EngineeringSnapshot?> loadPersistedSnapshotIfPresent() async {
    loadPersistedSnapshotIfPresentCalls++;
    throw error;
  }
}

class _Scenario {
  _Scenario({
    required this.label,
    required this.error,
    required this.expectedReason,
  });

  final String label;
  final Object error;
  final String expectedReason;
}

EngineeringSnapshotEnvelope _envelope({
  required EngineeringSnapshotSource source,
  required EngineeringSnapshotAuthority authority,
  required DateTime capturedAt,
  required String version,
  required int schemaVersion,
  bool stale = false,
  bool partial = false,
  DateTime? refreshedAt,
  String? projectScope,
  String? fallbackReason,
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
      fallbackReason: fallbackReason,
    ),
  );
}
