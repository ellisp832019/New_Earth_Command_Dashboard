import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/omega_engineering_studio/data/engineering_repository.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_snapshot_envelope.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_snapshot_metadata.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/neos_engineering_snapshot_reader.dart';

import 'engineering_studio_test_fixtures.dart';
import 'fakes/fake_neos_engineering_snapshot_reader.dart';

void main() {
  test('FakeNeosEngineeringSnapshotReader implements the read contract', () {
    final fake = FakeNeosEngineeringSnapshotReader(
      envelope: _envelope(
        source: EngineeringSnapshotSource.neosLive,
        authority: EngineeringSnapshotAuthority.neos,
        capturedAt: DateTime.utc(2026, 8, 19, 8),
        version: '1.0.0',
        schemaVersion: 1,
      ),
    );

    expect(fake, isA<NeosEngineeringSnapshotReader>());
    expect(fake, isNot(isA<EngineeringRepository>()));
  });

  test(
    'FakeNeosEngineeringSnapshotReader returns a configured live envelope unchanged',
    () async {
      final envelope = _envelope(
        source: EngineeringSnapshotSource.neosLive,
        authority: EngineeringSnapshotAuthority.neos,
        capturedAt: DateTime.utc(2026, 8, 19, 8),
        refreshedAt: DateTime.utc(2026, 8, 19, 8, 15),
        stale: false,
        partial: false,
        version: '1.0.0',
        schemaVersion: 1,
        projectScope: 'engineering',
      );
      final fake = FakeNeosEngineeringSnapshotReader(envelope: envelope);

      final returned = await fake.loadEngineeringSnapshot(
        projectScope: 'engineering',
      );

      expect(returned, same(envelope));
      expect(fake.loadEngineeringSnapshotCalls, 1);
      expect(fake.lastProjectScope, 'engineering');
      expect(returned.metadata.source, EngineeringSnapshotSource.neosLive);
      expect(returned.metadata.authority, EngineeringSnapshotAuthority.neos);
      expect(returned.metadata.stale, isFalse);
      expect(returned.metadata.partial, isFalse);
    },
  );

  test(
    'FakeNeosEngineeringSnapshotReader preserves cached and fallback metadata states',
    () async {
      final scenarios = <_FakeScenario>[
        _FakeScenario(
          label: 'cached',
          envelope: _envelope(
            source: EngineeringSnapshotSource.neosCache,
            authority: EngineeringSnapshotAuthority.neos,
            capturedAt: DateTime.utc(2026, 8, 19, 7, 30),
            stale: false,
            partial: false,
            version: '1.0.1',
            schemaVersion: 2,
          ),
        ),
        _FakeScenario(
          label: 'stale cached',
          envelope: _envelope(
            source: EngineeringSnapshotSource.neosCache,
            authority: EngineeringSnapshotAuthority.neos,
            capturedAt: DateTime.utc(2026, 8, 18, 18),
            stale: true,
            partial: false,
            version: '1.0.1',
            schemaVersion: 2,
            fallbackReason: 'cache is older than live truth',
          ),
        ),
        _FakeScenario(
          label: 'partial response',
          envelope: _envelope(
            source: EngineeringSnapshotSource.neosLive,
            authority: EngineeringSnapshotAuthority.neos,
            capturedAt: DateTime.utc(2026, 8, 19, 8, 30),
            stale: false,
            partial: true,
            version: '1.1.0',
            schemaVersion: 3,
          ),
        ),
        _FakeScenario(
          label: 'dashboard local fallback',
          envelope: _envelope(
            source: EngineeringSnapshotSource.dashboardLocalCache,
            authority: EngineeringSnapshotAuthority.dashboardLocal,
            capturedAt: DateTime.utc(2026, 8, 18, 12),
            stale: true,
            partial: false,
            version: '1.0.0',
            schemaVersion: 1,
            fallbackReason: 'local cache only',
          ),
        ),
        _FakeScenario(
          label: 'seeded fallback',
          envelope: _envelope(
            source: EngineeringSnapshotSource.seededFallback,
            authority: EngineeringSnapshotAuthority.fallback,
            capturedAt: DateTime.utc(2026, 8, 19, 6),
            stale: true,
            partial: false,
            version: '1.0.0',
            schemaVersion: 1,
            fallbackReason: 'offline seed',
          ),
        ),
        _FakeScenario(
          label: 'imported historical',
          envelope: _envelope(
            source: EngineeringSnapshotSource.importedHistorical,
            authority: EngineeringSnapshotAuthority.imported,
            capturedAt: DateTime.utc(2026, 8, 17, 15),
            stale: false,
            partial: false,
            version: '0.9.0',
            schemaVersion: 1,
            projectScope: 'history',
            fallbackReason: 'imported from archived file',
          ),
        ),
      ];

      for (final scenario in scenarios) {
        final fake = FakeNeosEngineeringSnapshotReader(
          envelope: scenario.envelope,
        );
        final returned = await fake.loadEngineeringSnapshot(
          projectScope: scenario.envelope.metadata.projectScope,
        );

        expect(returned, same(scenario.envelope), reason: scenario.label);
        expect(
          returned.metadata.source,
          scenario.envelope.metadata.source,
          reason: scenario.label,
        );
        expect(
          returned.metadata.authority,
          scenario.envelope.metadata.authority,
          reason: scenario.label,
        );
        expect(
          returned.metadata.stale,
          scenario.envelope.metadata.stale,
          reason: scenario.label,
        );
        expect(
          returned.metadata.partial,
          scenario.envelope.metadata.partial,
          reason: scenario.label,
        );
        expect(
          returned.metadata.version,
          scenario.envelope.metadata.version,
          reason: scenario.label,
        );
        expect(
          returned.metadata.schemaVersion,
          scenario.envelope.metadata.schemaVersion,
          reason: scenario.label,
        );
        expect(
          returned.metadata.projectScope,
          scenario.envelope.metadata.projectScope,
          reason: scenario.label,
        );
        expect(
          returned.metadata.fallbackReason,
          scenario.envelope.metadata.fallbackReason,
          reason: scenario.label,
        );
        expect(
          fake.lastProjectScope,
          scenario.envelope.metadata.projectScope,
          reason: scenario.label,
        );
        expect(fake.loadEngineeringSnapshotCalls, 1, reason: scenario.label);
      }
    },
  );

  test(
    'FakeNeosEngineeringSnapshotReader propagates configured errors deterministically',
    () {
      final error = StateError('configured failure');
      final fake = FakeNeosEngineeringSnapshotReader(
        envelope: _envelope(
          source: EngineeringSnapshotSource.neosLive,
          authority: EngineeringSnapshotAuthority.neos,
          capturedAt: DateTime.utc(2026, 8, 19, 8),
          version: '1.0.0',
          schemaVersion: 1,
        ),
        error: error,
      );

      expect(
        () => fake.loadEngineeringSnapshot(projectScope: 'engineering'),
        throwsA(same(error)),
      );
      expect(fake.lastProjectScope, 'engineering');
      expect(fake.loadEngineeringSnapshotCalls, 1);
    },
  );

  test(
    'FakeNeosEngineeringSnapshotReader file has no HTTP or database dependencies',
    () async {
      final source = await File(
        'test/features/omega_engineering_studio/fakes/fake_neos_engineering_snapshot_reader.dart',
      ).readAsString();

      expect(source, isNot(contains('package:http')));
      expect(source, isNot(contains('dart:io')));
      expect(source, isNot(contains('HttpClient')));
      expect(source, isNot(contains('socket')));
      expect(source, isNot(contains('drift')));
      expect(source, isNot(contains('EngineeringLocalDatabase')));
    },
  );
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

class _FakeScenario {
  _FakeScenario({required this.label, required this.envelope});

  final String label;
  final EngineeringSnapshotEnvelope envelope;
}
