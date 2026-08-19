import 'package:flutter/foundation.dart';

enum EngineeringSnapshotSource {
  neosLive,
  neosCache,
  dashboardLocalCache,
  seededFallback,
  importedHistorical,
}

enum EngineeringSnapshotAuthority { neos, dashboardLocal, imported, fallback }

/// Architectural contract metadata for a future NEOS engineering snapshot read.
///
/// Field ownership intent:
/// - NEOS future authority: projects, circuitBlocks, pcbRevisions, firmwareBuilds,
///   deviceNodes, componentItems, experiments, testProcedures, validationResults,
///   manufacturingSteps, decisions
/// - Dashboard local: settings
/// - Review / not yet assigned: documents, attachments
///
/// Intended future read hierarchy:
/// NEOS live -> NEOS cached -> Dashboard local cache -> seeded/offline fallback
///
/// This model is intentionally immutable and carries only read-side provenance
/// and compatibility data. It does not implement any persistence, transport,
/// or fallback logic.
@immutable
class EngineeringSnapshotMetadata {
  const EngineeringSnapshotMetadata({
    required this.source,
    required this.authority,
    required this.capturedAt,
    required this.stale,
    required this.partial,
    required this.version,
    required this.schemaVersion,
    this.refreshedAt,
    this.projectScope,
    this.fallbackReason,
  });

  final EngineeringSnapshotSource source;
  final EngineeringSnapshotAuthority authority;
  final DateTime capturedAt;
  final DateTime? refreshedAt;
  final bool stale;
  final bool partial;
  final String version;
  final int schemaVersion;
  final String? projectScope;
  final String? fallbackReason;

  bool get isLive => source == EngineeringSnapshotSource.neosLive;

  bool get isFallback =>
      source == EngineeringSnapshotSource.seededFallback ||
      source == EngineeringSnapshotSource.dashboardLocalCache ||
      source == EngineeringSnapshotSource.importedHistorical;

  DateTime get _effectiveTimestamp => refreshedAt ?? capturedAt;

  Duration get age => DateTime.now().toUtc().difference(_effectiveTimestamp);

  static bool _sameMoment(DateTime? left, DateTime? right) {
    if (left == null || right == null) {
      return left == right;
    }
    return left.isAtSameMomentAs(right);
  }

  @override
  bool operator ==(Object other) {
    return other is EngineeringSnapshotMetadata &&
        other.source == source &&
        other.authority == authority &&
        _sameMoment(other.capturedAt, capturedAt) &&
        _sameMoment(other.refreshedAt, refreshedAt) &&
        other.stale == stale &&
        other.partial == partial &&
        other.version == version &&
        other.schemaVersion == schemaVersion &&
        other.projectScope == projectScope &&
        other.fallbackReason == fallbackReason;
  }

  @override
  int get hashCode => Object.hash(
    source,
    authority,
    capturedAt.toUtc().microsecondsSinceEpoch,
    refreshedAt?.toUtc().microsecondsSinceEpoch,
    stale,
    partial,
    version,
    schemaVersion,
    projectScope,
    fallbackReason,
  );
}
