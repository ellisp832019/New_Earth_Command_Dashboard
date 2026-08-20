import 'dart:async';

import '../data/engineering_repository.dart';
import '../domain/engineering_models.dart';
import '../domain/engineering_snapshot_envelope.dart';
import '../domain/engineering_snapshot_metadata.dart';
import '../domain/neos_engineering_snapshot_reader.dart';
import '../domain/neos_read_transport.dart';

/// Read-only fallback policy for engineering snapshot reads.
///
/// The wrapper only orchestrates read attempts. It does not write local cache
/// data, mutate settings, or alter runtime provider selection.
class FallbackEngineeringSnapshotReader
    implements NeosEngineeringSnapshotReader {
  FallbackEngineeringSnapshotReader({
    required this.liveReader,
    required this.localReader,
    required this.seededSnapshotBuilder,
    DateTime Function()? clock,
  }) : _clock = clock ?? _utcNow;

  final NeosEngineeringSnapshotReader liveReader;
  final PersistedEngineeringSnapshotReader localReader;
  final FutureOr<EngineeringSnapshot> Function(String? projectScope)
  seededSnapshotBuilder;
  final DateTime Function() _clock;

  @override
  Future<EngineeringSnapshotEnvelope> loadEngineeringSnapshot({
    String? projectScope,
  }) async {
    final scope = projectScope?.trim();
    try {
      return await liveReader.loadEngineeringSnapshot(projectScope: scope);
    } catch (error) {
      final failureReason = _failureCategory(error);

      EngineeringSnapshot? localSnapshot;
      try {
        localSnapshot = await localReader.loadPersistedSnapshotIfPresent();
      } catch (_) {
        localSnapshot = null;
      }
      if (localSnapshot != null) {
        return _fallbackEnvelope(
          snapshot: localSnapshot,
          source: EngineeringSnapshotSource.dashboardLocalCache,
          authority: EngineeringSnapshotAuthority.dashboardLocal,
          projectScope: scope,
          fallbackReason: failureReason,
          version: 'fallback',
          schemaVersion: 0,
        );
      }

      try {
        final seededSnapshot = await seededSnapshotBuilder(scope);
        return _fallbackEnvelope(
          snapshot: seededSnapshot,
          source: EngineeringSnapshotSource.seededFallback,
          authority: EngineeringSnapshotAuthority.fallback,
          projectScope: scope,
          fallbackReason: failureReason,
          version: 'fallback',
          schemaVersion: 0,
        );
      } catch (_) {
        throw StateError('engineering_snapshot_unavailable:$failureReason');
      }
    }
  }

  EngineeringSnapshotEnvelope _fallbackEnvelope({
    required EngineeringSnapshot snapshot,
    required EngineeringSnapshotSource source,
    required EngineeringSnapshotAuthority authority,
    required String? projectScope,
    required String fallbackReason,
    required String version,
    required int schemaVersion,
  }) {
    final capturedAt = _clock().toUtc();
    return EngineeringSnapshotEnvelope(
      snapshot: snapshot,
      metadata: EngineeringSnapshotMetadata(
        source: source,
        authority: authority,
        capturedAt: capturedAt,
        refreshedAt: null,
        stale: true,
        partial: false,
        version: version,
        schemaVersion: schemaVersion,
        projectScope: projectScope,
        fallbackReason: fallbackReason,
      ),
    );
  }

  String _failureCategory(Object error) {
    if (error is NeosTransportTimeoutException) {
      return 'neos_timeout';
    }
    if (error is NeosTransportConnectionException) {
      return 'neos_unavailable';
    }
    if (error is NeosTransportHttpException) {
      return 'neos_http_error';
    }
    if (error is FormatException) {
      return 'neos_invalid_payload';
    }
    return 'neos_read_failed';
  }
}

DateTime _utcNow() => DateTime.now().toUtc();
