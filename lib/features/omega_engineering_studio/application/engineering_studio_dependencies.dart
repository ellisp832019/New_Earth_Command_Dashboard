import '../data/engineering_snapshot_reader.dart';
import '../data/engineering_repository.dart';

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
  }) {
    final resolvedRepository = repository ?? LocalEngineeringRepository();
    return EngineeringStudioDependencies(
      repository: resolvedRepository,
      snapshotReader:
          snapshotReader ?? LocalEngineeringSnapshotReader(resolvedRepository),
      projectScope: projectScope,
    );
  }

  final EngineeringProjectScope? projectScope;
  final EngineeringRepository repository;
  final EngineeringSnapshotReader snapshotReader;
}
