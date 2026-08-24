import 'package:flutter/foundation.dart';

/// Stable identities for the sources that may contribute governed status.
enum GovernedStatusSource {
  platformCore,
  neos,
  gaia,
  dashboardLocal,
  seededFallback,
}

enum GovernedStatusAuthority {
  platformCore,
  neos,
  gaia,
  dashboardLocal,
  seededFallback,
}

abstract final class GovernedStatusContract {
  static const version = '1.0';
}

enum GovernedStatusAvailability {
  available,
  unavailable,
  partial,
  stale,
  invalid,
  unsupported,
}

enum GovernedStatusFailureCategory {
  unavailable,
  invalid,
  stale,
  unsupportedScope,
  missingProvenance,
  scopeMismatch,
  unknown,
}

enum HumanApprovalState {
  unknown,
  notRequired,
  required,
  pending,
  approved,
  rejected,
}

enum NeosFindingSeverity { unknown, info, warning, error, blocker }

enum GaiaOperationalPriority { unknown, low, normal, high, urgent }

enum GovernedStatusConflictCategory {
  declaredRepositoryMissingInObservation,
  unregisteredObservedRepository,
  ownerMismatch,
  dependencyMismatch,
  interfaceMismatch,
  staleSource,
  missingProvenance,
  scopeMismatch,
  gaiaRecommendationUsingStaleEvidence,
  declarationObservationDisagreement,
  sourceUnavailable,
}

/// The canonical identity requested by a governed status read.
@immutable
class GovernedStatusScope {
  GovernedStatusScope({
    required this.canonicalId,
    required this.displayName,
    this.systemId,
    this.projectId,
  }) {
    if (canonicalId.isEmpty) {
      throw ArgumentError.value(
        canonicalId,
        'canonicalId',
        'must not be empty',
      );
    }
    if (displayName.isEmpty) {
      throw ArgumentError.value(
        displayName,
        'displayName',
        'must not be empty',
      );
    }
  }

  final String canonicalId;
  final String displayName;
  final String? systemId;
  final String? projectId;

  String get canonicalProjectId => canonicalId;

  @override
  bool operator ==(Object other) =>
      other is GovernedStatusScope &&
      other.canonicalId == canonicalId &&
      other.displayName == displayName &&
      other.systemId == systemId &&
      other.projectId == projectId;

  @override
  int get hashCode =>
      Object.hash(canonicalId, displayName, systemId, projectId);
}

@immutable
class GovernedStatusSourceMetadata {
  GovernedStatusSourceMetadata({
    required this.source,
    required this.authority,
    required this.availability,
    required this.scope,
    this.schemaVersion,
    this.retrievedAt,
    this.observedAt,
    this.stale = false,
    this.partial = false,
    List<String> provenanceReferences = const [],
    this.failureCategory,
  }) : provenanceReferences = List.unmodifiable(provenanceReferences) {
    if (source.name != authority.name) {
      throw ArgumentError('source and authority must identify the same owner');
    }
  }

  final GovernedStatusSource source;
  final GovernedStatusAuthority authority;
  String get authorityIdentity => authority.name;
  final GovernedStatusAvailability availability;
  final GovernedStatusScope scope;
  final String? schemaVersion;
  final DateTime? retrievedAt;
  final DateTime? observedAt;
  final bool stale;
  final bool partial;
  final List<String> provenanceReferences;
  final GovernedStatusFailureCategory? failureCategory;
}

@immutable
class DeclaredStatusLayer {
  DeclaredStatusLayer({
    this.canonicalId,
    this.displayName,
    this.systemType,
    this.owner,
    this.lifecycle,
    this.repository,
    this.contractVersion,
    List<String> interfaces = const [],
    List<String> dependencies = const [],
    List<String> compatibility = const [],
    List<String> classifications = const [],
    List<String> plannedExtractions = const [],
  }) : interfaces = List.unmodifiable(interfaces),
       dependencies = List.unmodifiable(dependencies),
       compatibility = List.unmodifiable(compatibility),
       classifications = List.unmodifiable(classifications),
       plannedExtractions = List.unmodifiable(plannedExtractions);

  final String? canonicalId;
  final String? displayName;
  final String? systemType;
  final String? owner;
  final String? lifecycle;
  final String? repository;
  final String? contractVersion;
  final List<String> interfaces;
  final List<String> dependencies;
  final List<String> compatibility;
  final List<String> classifications;
  final List<String> plannedExtractions;
}

@immutable
class GovernedStatusFinding {
  const GovernedStatusFinding({
    required this.id,
    required this.severity,
    required this.description,
    this.evidenceReference,
  });

  final String id;
  final NeosFindingSeverity severity;
  final String description;
  final String? evidenceReference;
}

@immutable
class ObservedStatusLayer {
  ObservedStatusLayer({
    this.repositoryIdentity,
    this.repositoryState,
    this.engineeringHealth,
    this.dependencyDrift,
    this.interfaceDrift,
    this.ownershipConflict,
    this.partialCoverage = false,
    List<GovernedStatusFinding> findings = const [],
    this.aggregateFindingCount,
    List<String> provenanceReferences = const [],
  }) : findings = List.unmodifiable(findings),
       provenanceReferences = List.unmodifiable(provenanceReferences);

  final String? repositoryIdentity;
  final String? repositoryState;
  final String? engineeringHealth;
  final bool? dependencyDrift;
  final bool? interfaceDrift;
  final bool? ownershipConflict;
  final bool partialCoverage;
  final List<GovernedStatusFinding> findings;
  final int? aggregateFindingCount;
  final List<String> provenanceReferences;
}

@immutable
class InterpretedStatusLayer {
  InterpretedStatusLayer({
    required this.operationalPriority,
    this.recommendation,
    this.briefing,
    this.workPackagePreviewReference,
    this.approvalPreparation,
    List<String> reviewQuestions = const [],
    List<String> provenanceReferences = const [],
  }) : reviewQuestions = List.unmodifiable(reviewQuestions),
       provenanceReferences = List.unmodifiable(provenanceReferences);

  final GaiaOperationalPriority operationalPriority;
  final String? recommendation;
  final String? briefing;
  final String? workPackagePreviewReference;
  final String? approvalPreparation;
  final List<String> reviewQuestions;
  final List<String> provenanceReferences;
}

@immutable
class LocalOperationalStatusLayer {
  LocalOperationalStatusLayer({
    this.userEnteredStatus,
    this.localPriority,
    this.localProgress,
    this.localNextAction,
    this.localNotes,
    List<String> localOperationalFlags = const [],
  }) : localOperationalFlags = List.unmodifiable(localOperationalFlags);

  final String? userEnteredStatus;
  final String? localPriority;
  final double? localProgress;
  final String? localNextAction;
  final String? localNotes;
  final List<String> localOperationalFlags;
}

@immutable
class GovernedStatusConflict {
  GovernedStatusConflict({
    required this.category,
    required this.affectedFieldOrScope,
    required List<GovernedStatusSource> participatingSources,
    required this.description,
    this.evidenceReference,
    this.blocking,
  }) : participatingSources = List.unmodifiable(participatingSources);

  final GovernedStatusConflictCategory category;
  final String affectedFieldOrScope;
  final List<GovernedStatusSource> participatingSources;
  final String description;
  final String? evidenceReference;
  final bool? blocking;
}

@immutable
class GovernedStatusSourceFailure {
  const GovernedStatusSourceFailure({
    required this.source,
    required this.category,
    required this.scope,
    this.description,
    this.evidenceReference,
  });

  final GovernedStatusSource source;
  final GovernedStatusFailureCategory category;
  final GovernedStatusScope scope;
  final String? description;
  final String? evidenceReference;
}

@immutable
class GovernedStatusRecord {
  GovernedStatusRecord({
    required this.scope,
    this.declared,
    this.observed,
    this.interpreted,
    this.local,
    this.approval = HumanApprovalState.unknown,
    List<GovernedStatusConflict> conflicts = const [],
  }) : conflicts = List.unmodifiable(conflicts);

  final GovernedStatusScope scope;
  final DeclaredStatusLayer? declared;
  final ObservedStatusLayer? observed;
  final InterpretedStatusLayer? interpreted;
  final LocalOperationalStatusLayer? local;
  final HumanApprovalState approval;
  final List<GovernedStatusConflict> conflicts;
}

@immutable
class GovernedStatusEnvelope {
  GovernedStatusEnvelope({
    required this.requestedScope,
    List<GovernedStatusRecord> records = const [],
    List<GovernedStatusSourceMetadata> sourceMetadata = const [],
    List<GovernedStatusSourceFailure> sourceFailures = const [],
    List<GovernedStatusConflict> conflicts = const [],
    this.composedAt,
    this.partial = false,
  }) : records = List.unmodifiable(records),
       sourceMetadata = List.unmodifiable(sourceMetadata),
       sourceFailures = List.unmodifiable(sourceFailures),
       conflicts = List.unmodifiable(conflicts) {
    if (!records.every((record) => record.scope == requestedScope)) {
      throw ArgumentError('record scope must match requested scope');
    }
    if (!sourceMetadata.every((metadata) => metadata.scope == requestedScope)) {
      throw ArgumentError('source metadata scope must match requested scope');
    }
  }

  String get contractVersion => GovernedStatusContract.version;
  final GovernedStatusScope requestedScope;
  final List<GovernedStatusRecord> records;
  final List<GovernedStatusSourceMetadata> sourceMetadata;
  final List<GovernedStatusSourceFailure> sourceFailures;
  final List<GovernedStatusConflict> conflicts;
  final DateTime? composedAt;
  final bool partial;
}

/// Read-only access to a governed status envelope.
abstract interface class GovernedStatusReader {
  Future<GovernedStatusEnvelope> load({required GovernedStatusScope scope});
}
