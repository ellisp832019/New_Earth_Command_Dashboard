import 'dart:async';

import '../data/engineering_repository.dart';
import '../data/http_neos_engineering_snapshot_reader.dart';
import '../data/http_neos_read_transport.dart';
import '../domain/engineering_models.dart';
import '../domain/engineering_snapshot_envelope.dart';
import '../domain/engineering_snapshot_metadata.dart';
import '../domain/neos_engineering_snapshot_reader.dart';
import 'fallback_engineering_snapshot_reader.dart';

/// Explicit engineering-studio project identity.
///
/// The dashboard project id stays in dashboard naming. A canonical project id
/// can be supplied by the mapping authority when one exists.
class EngineeringProjectScope {
  const EngineeringProjectScope({
    required this.projectId,
    this.canonicalProjectId,
    this.displayName,
  });

  factory EngineeringProjectScope.fromDashboardProjectId(
    String projectId, {
    String? canonicalProjectId,
    String? displayName,
  }) {
    return EngineeringProjectScope(
      projectId: projectId.trim(),
      canonicalProjectId: canonicalProjectId?.trim().isEmpty == true
          ? null
          : canonicalProjectId?.trim(),
      displayName: displayName?.trim().isEmpty == true
          ? null
          : displayName?.trim(),
    );
  }

  final String projectId;
  final String? canonicalProjectId;
  final String? displayName;

  String? get neosProjectId => canonicalProjectId;

  bool get hasCanonicalProjectId => canonicalProjectId != null;
}

/// Runtime read adapter for the Engineering Studio.
///
/// It keeps the write authority local while selecting the safest read source:
/// live NEOS for canonical identities, then persisted local snapshot, then the
/// seeded offline snapshot from the local repository.
class EngineeringStudioRuntimeSnapshotReader
    implements EngineeringSnapshotReader {
  EngineeringStudioRuntimeSnapshotReader({
    required this.projectScope,
    required this.localReader,
    required this.liveReader,
    required this.seededSnapshotBuilder,
  });

  final EngineeringProjectScope? projectScope;
  final PersistedEngineeringSnapshotReader localReader;
  final NeosEngineeringSnapshotReader liveReader;
  final FutureOr<EngineeringSnapshot> Function() seededSnapshotBuilder;

  EngineeringSnapshotEnvelope? _latestEnvelope;

  EngineeringSnapshotEnvelope? get latestEnvelope => _latestEnvelope;

  EngineeringSnapshotMetadata? get latestMetadata => _latestEnvelope?.metadata;

  @override
  Future<EngineeringSnapshot> loadSnapshot() async {
    final envelope = await loadEnvelope();
    return envelope.snapshot;
  }

  Future<EngineeringSnapshotEnvelope> loadEnvelope() async {
    final canonicalProjectId = projectScope?.neosProjectId?.trim();
    if (canonicalProjectId == null || canonicalProjectId.isEmpty) {
      final localSnapshot = await localReader.loadPersistedSnapshotIfPresent();
      if (localSnapshot != null) {
        return _cache(
          _fallbackEnvelope(
            snapshot: localSnapshot,
            source: EngineeringSnapshotSource.dashboardLocalCache,
            authority: EngineeringSnapshotAuthority.dashboardLocal,
            projectScope: projectScope?.projectId.trim().isEmpty == true
                ? null
                : projectScope?.projectId.trim(),
            fallbackReason: 'neos_unmapped',
          ),
        );
      }

      final seededSnapshot = await seededSnapshotBuilder();
      return _cache(
        _fallbackEnvelope(
          snapshot: seededSnapshot,
          source: EngineeringSnapshotSource.seededFallback,
          authority: EngineeringSnapshotAuthority.fallback,
          projectScope: projectScope?.projectId.trim().isEmpty == true
              ? null
              : projectScope?.projectId.trim(),
          fallbackReason: 'neos_unmapped',
        ),
      );
    }

    final fallbackReader = FallbackEngineeringSnapshotReader(
      liveReader: liveReader,
      localReader: localReader,
      seededSnapshotBuilder: (_) => seededSnapshotBuilder(),
    );
    return _cache(
      await fallbackReader.loadEngineeringSnapshot(
        projectScope: canonicalProjectId,
      ),
    );
  }

  EngineeringSnapshotEnvelope _cache(EngineeringSnapshotEnvelope envelope) {
    _latestEnvelope = envelope;
    return envelope;
  }

  EngineeringSnapshotEnvelope _fallbackEnvelope({
    required EngineeringSnapshot snapshot,
    required EngineeringSnapshotSource source,
    required EngineeringSnapshotAuthority authority,
    required String? projectScope,
    required String fallbackReason,
  }) {
    return EngineeringSnapshotEnvelope(
      snapshot: snapshot,
      metadata: EngineeringSnapshotMetadata(
        source: source,
        authority: authority,
        capturedAt: DateTime.now().toUtc(),
        refreshedAt: null,
        stale: true,
        partial: false,
        version: 'fallback',
        schemaVersion: 0,
        projectScope: projectScope,
        fallbackReason: fallbackReason,
      ),
    );
  }
}

class _RepositoryPersistedSnapshotReaderAdapter
    implements PersistedEngineeringSnapshotReader {
  const _RepositoryPersistedSnapshotReaderAdapter();

  @override
  Future<EngineeringSnapshot?> loadPersistedSnapshotIfPresent() async {
    return null;
  }
}

/// Composition owner for the engineering studio runtime contracts.
///
/// The read and write paths both share the same repository instance so the
/// local database lifecycle stays single-owner and predictable.
class EngineeringStudioDependencies {
  EngineeringStudioDependencies({
    required this.repository,
    required this.snapshotReader,
    this.projectScope,
  });

  factory EngineeringStudioDependencies.local({
    EngineeringProjectScope? projectScope,
    EngineeringRepository? repository,
    EngineeringSnapshotReader? snapshotReader,
    NeosEngineeringSnapshotReader? liveReader,
    Uri? neosBaseUri,
  }) {
    final EngineeringRepository resolvedRepository =
        repository ?? LocalEngineeringRepository();
    final PersistedEngineeringSnapshotReader persistedLocalReader =
        resolvedRepository is PersistedEngineeringSnapshotReader
        ? resolvedRepository as PersistedEngineeringSnapshotReader
        : const _RepositoryPersistedSnapshotReaderAdapter();
    final resolvedSnapshotReader =
        snapshotReader ??
        EngineeringStudioRuntimeSnapshotReader(
          projectScope: projectScope,
          localReader: persistedLocalReader,
          liveReader:
              liveReader ??
              HttpNeosEngineeringSnapshotReader(
                HttpNeosReadTransport(
                  baseUri: neosBaseUri ?? Uri.parse('http://127.0.0.1:8765'),
                ),
              ),
          seededSnapshotBuilder: () => resolvedRepository.loadSnapshot(),
        );
    return EngineeringStudioDependencies(
      repository: resolvedRepository,
      snapshotReader: resolvedSnapshotReader,
      projectScope: projectScope,
    );
  }

  final EngineeringProjectScope? projectScope;
  final EngineeringRepository repository;
  final EngineeringSnapshotReader snapshotReader;

  EngineeringSnapshotMetadata? get latestReadMetadata {
    final reader = snapshotReader;
    if (reader is EngineeringStudioRuntimeSnapshotReader) {
      return reader.latestMetadata;
    }
    return null;
  }

  EngineeringSnapshotEnvelope? get latestReadEnvelope {
    final reader = snapshotReader;
    if (reader is EngineeringStudioRuntimeSnapshotReader) {
      return reader.latestEnvelope;
    }
    return null;
  }
}
