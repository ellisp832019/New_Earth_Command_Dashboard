part of 'project_context.dart';

/// Read-only Project Context v1 supplied by adapters and assemblers in later slices.
///
/// The snapshot is a pure data contract: it stores structured state only and
/// performs no live observation, filesystem access, Git inspection, or network I/O.
class ProjectContextSnapshot {
  const ProjectContextSnapshot({
    required this.contractVersion,
    required this.snapshotId,
    required this.generatedAt,
    required this.repository,
    required this.platform,
    required this.baseline,
    required this.releaseReadiness,
    required this.repositoryHealth,
    required this.risks,
    required this.modules,
    required this.dependencies,
    required this.verification,
    required this.ci,
    required this.releases,
    required this.dataQuality,
    required this.provenance,
  });

  final String contractVersion;
  final String snapshotId;
  final DateTime generatedAt;
  final ProjectContextRepositoryContext repository;
  final ProjectContextPlatformContext platform;
  final ProjectContextBaselineContext baseline;
  final ProjectContextReleaseReadinessContext releaseReadiness;
  final ProjectContextRepositoryHealthContext repositoryHealth;
  final ProjectContextRisksContext risks;
  final ProjectContextModulesContext modules;
  final ProjectContextDependenciesContext dependencies;
  final ProjectContextVerificationContext verification;
  final ProjectContextCiContext ci;
  final ProjectContextReleasesContext releases;
  final ProjectContextDataQualityContext dataQuality;
  final ProjectContextProvenanceContext provenance;

  factory ProjectContextSnapshot.fromJson(Map<String, dynamic> json) {
    return ProjectContextParser().parse(json);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'contractVersion': contractVersion,
      'snapshotId': snapshotId,
      'generatedAt': generatedAt.toUtc().toIso8601String(),
      'repository': repository.toJson(),
      'platform': platform.toJson(),
      'baseline': baseline.toJson(),
      'releaseReadiness': releaseReadiness.toJson(),
      'repositoryHealth': repositoryHealth.toJson(),
      'risks': risks.toJson(),
      'modules': modules.toJson(),
      'dependencies': dependencies.toJson(),
      'verification': verification.toJson(),
      'ci': ci.toJson(),
      'releases': releases.toJson(),
      'dataQuality': dataQuality.toJson(),
      'provenance': provenance.toJson(),
    };
  }
}

enum ProjectContextDirtyState { clean, dirty, unknown }

extension ProjectContextDirtyStateJson on ProjectContextDirtyState {
  String get jsonValue => switch (this) {
    ProjectContextDirtyState.clean => 'clean',
    ProjectContextDirtyState.dirty => 'dirty',
    ProjectContextDirtyState.unknown => 'unknown',
  };
}

ProjectContextDirtyState projectContextDirtyStateFromJson(
  String value,
  String path,
) {
  return switch (value) {
    'clean' => ProjectContextDirtyState.clean,
    'dirty' => ProjectContextDirtyState.dirty,
    'unknown' => ProjectContextDirtyState.unknown,
    _ => throw ProjectContextParseException.unsupportedValue(
      path: path,
      actual: value,
      expected: 'clean | dirty | unknown',
    ),
  };
}

enum ProjectContextReleaseReadinessStatus {
  blocked,
  notReady,
  readyWithConditions,
  ready,
}

extension ProjectContextReleaseReadinessStatusJson
    on ProjectContextReleaseReadinessStatus {
  String get jsonValue => switch (this) {
    ProjectContextReleaseReadinessStatus.blocked => 'blocked',
    ProjectContextReleaseReadinessStatus.notReady => 'not_ready',
    ProjectContextReleaseReadinessStatus.readyWithConditions =>
      'ready_with_conditions',
    ProjectContextReleaseReadinessStatus.ready => 'ready',
  };
}

ProjectContextReleaseReadinessStatus
projectContextReleaseReadinessStatusFromJson(String value, String path) {
  return switch (value) {
    'blocked' => ProjectContextReleaseReadinessStatus.blocked,
    'not_ready' => ProjectContextReleaseReadinessStatus.notReady,
    'ready_with_conditions' =>
      ProjectContextReleaseReadinessStatus.readyWithConditions,
    'ready' => ProjectContextReleaseReadinessStatus.ready,
    _ => throw ProjectContextParseException.unsupportedValue(
      path: path,
      actual: value,
      expected: 'blocked | not_ready | ready_with_conditions | ready',
    ),
  };
}

enum ProjectContextRepositoryHealthStatus {
  good,
  degraded,
  stale,
  conflicting,
  missing,
}

extension ProjectContextRepositoryHealthStatusJson
    on ProjectContextRepositoryHealthStatus {
  String get jsonValue => switch (this) {
    ProjectContextRepositoryHealthStatus.good => 'good',
    ProjectContextRepositoryHealthStatus.degraded => 'degraded',
    ProjectContextRepositoryHealthStatus.stale => 'stale',
    ProjectContextRepositoryHealthStatus.conflicting => 'conflicting',
    ProjectContextRepositoryHealthStatus.missing => 'missing',
  };
}

ProjectContextRepositoryHealthStatus
projectContextRepositoryHealthStatusFromJson(String value, String path) {
  return switch (value) {
    'good' => ProjectContextRepositoryHealthStatus.good,
    'degraded' => ProjectContextRepositoryHealthStatus.degraded,
    'stale' => ProjectContextRepositoryHealthStatus.stale,
    'conflicting' => ProjectContextRepositoryHealthStatus.conflicting,
    'missing' => ProjectContextRepositoryHealthStatus.missing,
    _ => throw ProjectContextParseException.unsupportedValue(
      path: path,
      actual: value,
      expected: 'good | degraded | stale | conflicting | missing',
    ),
  };
}

enum ProjectContextDataQualityStatus {
  good,
  degraded,
  stale,
  conflicting,
  missing,
}

extension ProjectContextDataQualityStatusJson
    on ProjectContextDataQualityStatus {
  String get jsonValue => switch (this) {
    ProjectContextDataQualityStatus.good => 'good',
    ProjectContextDataQualityStatus.degraded => 'degraded',
    ProjectContextDataQualityStatus.stale => 'stale',
    ProjectContextDataQualityStatus.conflicting => 'conflicting',
    ProjectContextDataQualityStatus.missing => 'missing',
  };
}

ProjectContextDataQualityStatus projectContextDataQualityStatusFromJson(
  String value,
  String path,
) {
  return switch (value) {
    'good' => ProjectContextDataQualityStatus.good,
    'degraded' => ProjectContextDataQualityStatus.degraded,
    'stale' => ProjectContextDataQualityStatus.stale,
    'conflicting' => ProjectContextDataQualityStatus.conflicting,
    'missing' => ProjectContextDataQualityStatus.missing,
    _ => throw ProjectContextParseException.unsupportedValue(
      path: path,
      actual: value,
      expected: 'good | degraded | stale | conflicting | missing',
    ),
  };
}

class ProjectContextRepositoryContext {
  const ProjectContextRepositoryContext({
    required this.repositoryId,
    required this.repositoryName,
    required this.remoteIdentity,
    required this.defaultBranch,
    this.observedBranch,
    required this.observedCommit,
    required this.protectedBranch,
    required this.dirtyState,
    required this.observedAt,
    this.aheadBehind,
  });

  final String repositoryId;
  final String repositoryName;
  final String remoteIdentity;
  final String defaultBranch;
  final String? observedBranch;
  final String observedCommit;
  final ProjectContextProtectedBranchContext protectedBranch;
  final ProjectContextDirtyState dirtyState;
  final ProjectContextAheadBehindContext? aheadBehind;
  final DateTime observedAt;

  factory ProjectContextRepositoryContext.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.repository',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {
        'repositoryId',
        'repositoryName',
        'remoteIdentity',
        'defaultBranch',
        'observedBranch',
        'observedCommit',
        'protectedBranch',
        'dirtyState',
        'aheadBehind',
        'observedAt',
      },
      requiredKeys: const {
        'repositoryId',
        'repositoryName',
        'remoteIdentity',
        'defaultBranch',
        'observedCommit',
        'protectedBranch',
        'dirtyState',
        'observedAt',
      },
    );
    return ProjectContextRepositoryContext(
      repositoryId: _ProjectContextJson.requiredString(
        data,
        'repositoryId',
        path: path,
      ),
      repositoryName: _ProjectContextJson.requiredString(
        data,
        'repositoryName',
        path: path,
      ),
      remoteIdentity: _ProjectContextJson.requiredString(
        data,
        'remoteIdentity',
        path: path,
      ),
      defaultBranch: _ProjectContextJson.requiredString(
        data,
        'defaultBranch',
        path: path,
      ),
      observedBranch: data.containsKey('observedBranch')
          ? _ProjectContextJson.optionalString(
              data,
              'observedBranch',
              path: path,
            )
          : null,
      observedCommit: _ProjectContextJson.requiredString(
        data,
        'observedCommit',
        path: path,
      ),
      protectedBranch: ProjectContextProtectedBranchContext.fromJson(
        _ProjectContextJson.requiredObject(
          data,
          'protectedBranch',
          path: path,
          allowedKeys: const {'name', 'commit', 'requiredChecks'},
          requiredKeys: const {'name', 'commit', 'requiredChecks'},
        ),
        path: '$path.protectedBranch',
      ),
      dirtyState: projectContextDirtyStateFromJson(
        _ProjectContextJson.requiredString(data, 'dirtyState', path: path),
        '$path.dirtyState',
      ),
      aheadBehind: (() {
        final rawAheadBehind = _ProjectContextJson.optionalObject(
          data,
          'aheadBehind',
          path: path,
          allowedKeys: const {'ahead', 'behind'},
          requiredKeys: const {},
        );
        if (rawAheadBehind == null) {
          return null;
        }
        return ProjectContextAheadBehindContext.fromJson(
          rawAheadBehind,
          path: '$path.aheadBehind',
        );
      })(),
      observedAt: _ProjectContextJson.requiredDateTime(
        data,
        'observedAt',
        path: path,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'repositoryId': repositoryId,
      'repositoryName': repositoryName,
      'remoteIdentity': remoteIdentity,
      'defaultBranch': defaultBranch,
      'observedCommit': observedCommit,
      'protectedBranch': protectedBranch.toJson(),
      'dirtyState': dirtyState.jsonValue,
      'observedAt': observedAt.toUtc().toIso8601String(),
    };
    if (observedBranch != null) {
      json['observedBranch'] = observedBranch;
    }
    if (aheadBehind != null) {
      json['aheadBehind'] = aheadBehind!.toJson();
    }
    return json;
  }
}

class ProjectContextProtectedBranchContext {
  ProjectContextProtectedBranchContext({
    required this.name,
    required this.commit,
    required List<String> requiredChecks,
  }) : requiredChecks = List<String>.unmodifiable(requiredChecks);

  final String name;
  final String commit;
  final List<String> requiredChecks;

  factory ProjectContextProtectedBranchContext.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.repository.protectedBranch',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {'name', 'commit', 'requiredChecks'},
      requiredKeys: const {'name', 'commit', 'requiredChecks'},
    );
    return ProjectContextProtectedBranchContext(
      name: _ProjectContextJson.requiredString(data, 'name', path: path),
      commit: _ProjectContextJson.requiredString(data, 'commit', path: path),
      requiredChecks: _ProjectContextJson.requiredStringList(
        data,
        'requiredChecks',
        path: path,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'commit': commit,
      'requiredChecks': requiredChecks,
    };
  }
}

class ProjectContextAheadBehindContext {
  const ProjectContextAheadBehindContext({this.ahead, this.behind});

  final int? ahead;
  final int? behind;

  factory ProjectContextAheadBehindContext.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.repository.aheadBehind',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {'ahead', 'behind'},
      requiredKeys: const {},
    );
    return ProjectContextAheadBehindContext(
      ahead: _ProjectContextJson.optionalInt(data, 'ahead', path: path),
      behind: _ProjectContextJson.optionalInt(data, 'behind', path: path),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (ahead != null) {
      json['ahead'] = ahead;
    }
    if (behind != null) {
      json['behind'] = behind;
    }
    return json;
  }
}

class ProjectContextPlatformContext {
  const ProjectContextPlatformContext({
    required this.dashboardVersion,
    required this.dashboardMaturity,
    required this.gaiaIntegrationVersion,
    required this.gaiaDependencyRef,
    this.liveStateLabel,
  });

  final String dashboardVersion;
  final String dashboardMaturity;
  final String gaiaIntegrationVersion;
  final String gaiaDependencyRef;
  final String? liveStateLabel;

  factory ProjectContextPlatformContext.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.platform',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {
        'dashboardVersion',
        'dashboardMaturity',
        'gaiaIntegrationVersion',
        'gaiaDependencyRef',
        'liveStateLabel',
      },
      requiredKeys: const {
        'dashboardVersion',
        'dashboardMaturity',
        'gaiaIntegrationVersion',
        'gaiaDependencyRef',
      },
    );
    return ProjectContextPlatformContext(
      dashboardVersion: _ProjectContextJson.requiredString(
        data,
        'dashboardVersion',
        path: path,
      ),
      dashboardMaturity: _ProjectContextJson.requiredString(
        data,
        'dashboardMaturity',
        path: path,
      ),
      gaiaIntegrationVersion: _ProjectContextJson.requiredString(
        data,
        'gaiaIntegrationVersion',
        path: path,
      ),
      gaiaDependencyRef: _ProjectContextJson.requiredString(
        data,
        'gaiaDependencyRef',
        path: path,
      ),
      liveStateLabel: _ProjectContextJson.optionalString(
        data,
        'liveStateLabel',
        path: path,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'dashboardVersion': dashboardVersion,
      'dashboardMaturity': dashboardMaturity,
      'gaiaIntegrationVersion': gaiaIntegrationVersion,
      'gaiaDependencyRef': gaiaDependencyRef,
    };
    if (liveStateLabel != null) {
      json['liveStateLabel'] = liveStateLabel;
    }
    return json;
  }
}

class ProjectContextBaselineContext {
  const ProjectContextBaselineContext({
    required this.baselineTag,
    required this.baselineCommit,
    required this.recordedManifestCommit,
    required this.comparisonBase,
    required this.historicalOnly,
    this.recordedAt,
  });

  final String baselineTag;
  final String baselineCommit;
  final String recordedManifestCommit;
  final String comparisonBase;
  final bool historicalOnly;
  final DateTime? recordedAt;

  factory ProjectContextBaselineContext.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.baseline',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {
        'baselineTag',
        'baselineCommit',
        'recordedManifestCommit',
        'comparisonBase',
        'recordedAt',
        'historicalOnly',
      },
      requiredKeys: const {
        'baselineTag',
        'baselineCommit',
        'recordedManifestCommit',
        'comparisonBase',
        'historicalOnly',
      },
    );
    return ProjectContextBaselineContext(
      baselineTag: _ProjectContextJson.requiredString(
        data,
        'baselineTag',
        path: path,
      ),
      baselineCommit: _ProjectContextJson.requiredString(
        data,
        'baselineCommit',
        path: path,
      ),
      recordedManifestCommit: _ProjectContextJson.requiredString(
        data,
        'recordedManifestCommit',
        path: path,
      ),
      comparisonBase: _ProjectContextJson.requiredString(
        data,
        'comparisonBase',
        path: path,
      ),
      recordedAt: _ProjectContextJson.optionalDateTime(
        data,
        'recordedAt',
        path: path,
      ),
      historicalOnly: _ProjectContextJson.requiredBool(
        data,
        'historicalOnly',
        path: path,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'baselineTag': baselineTag,
      'baselineCommit': baselineCommit,
      'recordedManifestCommit': recordedManifestCommit,
      'comparisonBase': comparisonBase,
      'historicalOnly': historicalOnly,
    };
    if (recordedAt != null) {
      json['recordedAt'] = recordedAt!.toUtc().toIso8601String();
    }
    return json;
  }
}

class ProjectContextReleaseReadinessContext {
  ProjectContextReleaseReadinessContext({
    required this.status,
    required List<String> reasons,
  }) : reasons = List<String>.unmodifiable(reasons);

  final ProjectContextReleaseReadinessStatus status;
  final List<String> reasons;

  factory ProjectContextReleaseReadinessContext.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.releaseReadiness',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {'status', 'reasons'},
      requiredKeys: const {'status', 'reasons'},
    );
    return ProjectContextReleaseReadinessContext(
      status: projectContextReleaseReadinessStatusFromJson(
        _ProjectContextJson.requiredString(data, 'status', path: path),
        '$path.status',
      ),
      reasons: _ProjectContextJson.requiredStringList(
        data,
        'reasons',
        path: path,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'status': status.jsonValue, 'reasons': reasons};
  }
}

class ProjectContextRepositoryHealthContext {
  ProjectContextRepositoryHealthContext({
    required this.status,
    required this.workingTreeState,
    required List<String> warnings,
  }) : warnings = List<String>.unmodifiable(warnings);

  final ProjectContextRepositoryHealthStatus status;
  final ProjectContextDirtyState workingTreeState;
  final List<String> warnings;

  factory ProjectContextRepositoryHealthContext.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.repositoryHealth',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {'status', 'workingTreeState', 'warnings'},
      requiredKeys: const {'status', 'workingTreeState', 'warnings'},
    );
    return ProjectContextRepositoryHealthContext(
      status: projectContextRepositoryHealthStatusFromJson(
        _ProjectContextJson.requiredString(data, 'status', path: path),
        '$path.status',
      ),
      workingTreeState: projectContextDirtyStateFromJson(
        _ProjectContextJson.requiredString(
          data,
          'workingTreeState',
          path: path,
        ),
        '$path.workingTreeState',
      ),
      warnings: _ProjectContextJson.requiredStringList(
        data,
        'warnings',
        path: path,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'status': status.jsonValue,
      'workingTreeState': workingTreeState.jsonValue,
      'warnings': warnings,
    };
  }
}

class ProjectContextRisksContext {
  ProjectContextRisksContext({required List<ProjectContextRiskItem> items})
    : items = List<ProjectContextRiskItem>.unmodifiable(items);

  final List<ProjectContextRiskItem> items;

  factory ProjectContextRisksContext.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.risks',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {'items'},
      requiredKeys: const {'items'},
    );
    return ProjectContextRisksContext(
      items: _ProjectContextJson.requiredList<ProjectContextRiskItem>(
        data,
        'items',
        path: path,
        parseItem: (value, itemPath) =>
            ProjectContextRiskItem.fromJson(value, path: itemPath),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'items': items.map((item) => item.toJson()).toList(growable: false),
    };
  }
}

class ProjectContextRiskItem {
  ProjectContextRiskItem({
    required this.riskId,
    required this.title,
    required this.severity,
    required this.status,
    required List<String> affectedModules,
    required this.lastReviewed,
    required List<String> evidenceReferences,
    this.likelihood,
    this.owner,
    this.targetRelease,
  }) : affectedModules = List<String>.unmodifiable(affectedModules),
       evidenceReferences = List<String>.unmodifiable(evidenceReferences);

  final String riskId;
  final String title;
  final String severity;
  final String status;
  final List<String> affectedModules;
  final String lastReviewed;
  final List<String> evidenceReferences;
  final String? likelihood;
  final String? owner;
  final String? targetRelease;

  factory ProjectContextRiskItem.fromJson(
    Object? json, {
    String path = r'$.risks.items',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {
        'riskId',
        'title',
        'severity',
        'likelihood',
        'status',
        'affectedModules',
        'owner',
        'targetRelease',
        'lastReviewed',
        'evidenceReferences',
      },
      requiredKeys: const {
        'riskId',
        'title',
        'severity',
        'status',
        'affectedModules',
        'lastReviewed',
        'evidenceReferences',
      },
    );
    return ProjectContextRiskItem(
      riskId: _ProjectContextJson.requiredString(data, 'riskId', path: path),
      title: _ProjectContextJson.requiredString(data, 'title', path: path),
      severity: _ProjectContextJson.requiredString(
        data,
        'severity',
        path: path,
      ),
      status: _ProjectContextJson.requiredString(data, 'status', path: path),
      affectedModules: _ProjectContextJson.requiredStringList(
        data,
        'affectedModules',
        path: path,
      ),
      lastReviewed: _ProjectContextJson.requiredString(
        data,
        'lastReviewed',
        path: path,
      ),
      evidenceReferences: _ProjectContextJson.requiredStringList(
        data,
        'evidenceReferences',
        path: path,
      ),
      likelihood: _ProjectContextJson.optionalString(
        data,
        'likelihood',
        path: path,
      ),
      owner: _ProjectContextJson.optionalString(data, 'owner', path: path),
      targetRelease: _ProjectContextJson.optionalString(
        data,
        'targetRelease',
        path: path,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'riskId': riskId,
      'title': title,
      'severity': severity,
      'status': status,
      'affectedModules': affectedModules,
      'lastReviewed': lastReviewed,
      'evidenceReferences': evidenceReferences,
    };
    if (likelihood != null) {
      json['likelihood'] = likelihood;
    }
    if (owner != null) {
      json['owner'] = owner;
    }
    if (targetRelease != null) {
      json['targetRelease'] = targetRelease;
    }
    return json;
  }
}

class ProjectContextModulesContext {
  ProjectContextModulesContext({required List<ProjectContextModuleItem> items})
    : items = List<ProjectContextModuleItem>.unmodifiable(items);

  final List<ProjectContextModuleItem> items;

  factory ProjectContextModulesContext.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.modules',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {'items'},
      requiredKeys: const {'items'},
    );
    return ProjectContextModulesContext(
      items: _ProjectContextJson.requiredList<ProjectContextModuleItem>(
        data,
        'items',
        path: path,
        parseItem: (value, itemPath) =>
            ProjectContextModuleItem.fromJson(value, path: itemPath),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'items': items.map((item) => item.toJson()).toList(growable: false),
    };
  }
}

class ProjectContextModuleItem {
  ProjectContextModuleItem({
    required this.moduleId,
    required this.name,
    required this.version,
    required this.maturity,
    required this.verificationStatus,
    required this.documentationStatus,
    required this.lastVerifiedCommit,
    required List<String> dependencies,
    this.route,
    List<String>? knownRisks,
  }) : dependencies = List<String>.unmodifiable(dependencies),
       knownRisks = knownRisks == null
           ? null
           : List<String>.unmodifiable(knownRisks);

  final String moduleId;
  final String name;
  final String version;
  final String maturity;
  final String verificationStatus;
  final String documentationStatus;
  final String lastVerifiedCommit;
  final List<String> dependencies;
  final String? route;
  final List<String>? knownRisks;

  factory ProjectContextModuleItem.fromJson(
    Object? json, {
    String path = r'$.modules.items',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {
        'moduleId',
        'name',
        'version',
        'maturity',
        'verificationStatus',
        'documentationStatus',
        'lastVerifiedCommit',
        'route',
        'knownRisks',
        'dependencies',
      },
      requiredKeys: const {
        'moduleId',
        'name',
        'version',
        'maturity',
        'verificationStatus',
        'documentationStatus',
        'lastVerifiedCommit',
        'dependencies',
      },
    );
    return ProjectContextModuleItem(
      moduleId: _ProjectContextJson.requiredString(
        data,
        'moduleId',
        path: path,
      ),
      name: _ProjectContextJson.requiredString(data, 'name', path: path),
      version: _ProjectContextJson.requiredString(data, 'version', path: path),
      maturity: _ProjectContextJson.requiredString(
        data,
        'maturity',
        path: path,
      ),
      verificationStatus: _ProjectContextJson.requiredString(
        data,
        'verificationStatus',
        path: path,
      ),
      documentationStatus: _ProjectContextJson.requiredString(
        data,
        'documentationStatus',
        path: path,
      ),
      lastVerifiedCommit: _ProjectContextJson.requiredString(
        data,
        'lastVerifiedCommit',
        path: path,
      ),
      dependencies: _ProjectContextJson.requiredStringList(
        data,
        'dependencies',
        path: path,
      ),
      route: _ProjectContextJson.optionalString(data, 'route', path: path),
      knownRisks: _ProjectContextJson.optionalStringList(
        data,
        'knownRisks',
        path: path,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'moduleId': moduleId,
      'name': name,
      'version': version,
      'maturity': maturity,
      'verificationStatus': verificationStatus,
      'documentationStatus': documentationStatus,
      'lastVerifiedCommit': lastVerifiedCommit,
      'dependencies': dependencies,
    };
    if (route != null) {
      json['route'] = route;
    }
    if (knownRisks != null) {
      json['knownRisks'] = knownRisks;
    }
    return json;
  }
}

class ProjectContextDependenciesContext {
  ProjectContextDependenciesContext({
    required List<ProjectContextModuleDependency> moduleDependencies,
    required List<ProjectContextSharedServiceDependency> sharedServices,
  }) : moduleDependencies = List<ProjectContextModuleDependency>.unmodifiable(
         moduleDependencies,
       ),
       sharedServices =
           List<ProjectContextSharedServiceDependency>.unmodifiable(
             sharedServices,
           );

  final List<ProjectContextModuleDependency> moduleDependencies;
  final List<ProjectContextSharedServiceDependency> sharedServices;

  factory ProjectContextDependenciesContext.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.dependencies',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {'moduleDependencies', 'sharedServices'},
      requiredKeys: const {'moduleDependencies', 'sharedServices'},
    );
    return ProjectContextDependenciesContext(
      moduleDependencies:
          _ProjectContextJson.requiredList<ProjectContextModuleDependency>(
            data,
            'moduleDependencies',
            path: path,
            parseItem: (value, itemPath) =>
                ProjectContextModuleDependency.fromJson(value, path: itemPath),
          ),
      sharedServices:
          _ProjectContextJson.requiredList<
            ProjectContextSharedServiceDependency
          >(
            data,
            'sharedServices',
            path: path,
            parseItem: (value, itemPath) =>
                ProjectContextSharedServiceDependency.fromJson(
                  value,
                  path: itemPath,
                ),
          ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'moduleDependencies': moduleDependencies
          .map((item) => item.toJson())
          .toList(growable: false),
      'sharedServices': sharedServices
          .map((item) => item.toJson())
          .toList(growable: false),
    };
  }
}

class ProjectContextModuleDependency {
  ProjectContextModuleDependency({
    required this.module,
    required List<String> dependsOn,
  }) : dependsOn = List<String>.unmodifiable(dependsOn);

  final String module;
  final List<String> dependsOn;

  factory ProjectContextModuleDependency.fromJson(
    Object? json, {
    String path = r'$.dependencies.moduleDependencies',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {'module', 'dependsOn'},
      requiredKeys: const {'module', 'dependsOn'},
    );
    return ProjectContextModuleDependency(
      module: _ProjectContextJson.requiredString(data, 'module', path: path),
      dependsOn: _ProjectContextJson.requiredStringList(
        data,
        'dependsOn',
        path: path,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'module': module, 'dependsOn': dependsOn};
  }
}

class ProjectContextSharedServiceDependency {
  ProjectContextSharedServiceDependency({
    required this.service,
    required List<String> usedBy,
  }) : usedBy = List<String>.unmodifiable(usedBy);

  final String service;
  final List<String> usedBy;

  factory ProjectContextSharedServiceDependency.fromJson(
    Object? json, {
    String path = r'$.dependencies.sharedServices',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {'service', 'usedBy'},
      requiredKeys: const {'service', 'usedBy'},
    );
    return ProjectContextSharedServiceDependency(
      service: _ProjectContextJson.requiredString(data, 'service', path: path),
      usedBy: _ProjectContextJson.requiredStringList(
        data,
        'usedBy',
        path: path,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'service': service, 'usedBy': usedBy};
  }
}

class ProjectContextVerificationContext {
  ProjectContextVerificationContext({
    required List<ProjectContextVerificationItem> items,
  }) : items = List<ProjectContextVerificationItem>.unmodifiable(items);

  final List<ProjectContextVerificationItem> items;

  factory ProjectContextVerificationContext.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.verification',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {'items'},
      requiredKeys: const {'items'},
    );
    return ProjectContextVerificationContext(
      items: _ProjectContextJson.requiredList<ProjectContextVerificationItem>(
        data,
        'items',
        path: path,
        parseItem: (value, itemPath) =>
            ProjectContextVerificationItem.fromJson(value, path: itemPath),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'items': items.map((item) => item.toJson()).toList(growable: false),
    };
  }
}

class ProjectContextVerificationItem {
  ProjectContextVerificationItem({
    required this.verificationId,
    required this.scope,
    required this.commit,
    required this.branch,
    required this.result,
    required this.date,
    required List<String> evidencePaths,
    this.environment,
    List<String>? limitations,
  }) : evidencePaths = List<String>.unmodifiable(evidencePaths),
       limitations = limitations == null
           ? null
           : List<String>.unmodifiable(limitations);

  final String verificationId;
  final String scope;
  final String commit;
  final String branch;
  final String result;
  final String date;
  final List<String> evidencePaths;
  final String? environment;
  final List<String>? limitations;

  factory ProjectContextVerificationItem.fromJson(
    Object? json, {
    String path = r'$.verification.items',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {
        'verificationId',
        'scope',
        'commit',
        'branch',
        'environment',
        'result',
        'date',
        'evidencePaths',
        'limitations',
      },
      requiredKeys: const {
        'verificationId',
        'scope',
        'commit',
        'branch',
        'result',
        'date',
        'evidencePaths',
      },
    );
    return ProjectContextVerificationItem(
      verificationId: _ProjectContextJson.requiredString(
        data,
        'verificationId',
        path: path,
      ),
      scope: _ProjectContextJson.requiredString(data, 'scope', path: path),
      commit: _ProjectContextJson.requiredString(data, 'commit', path: path),
      branch: _ProjectContextJson.requiredString(data, 'branch', path: path),
      result: _ProjectContextJson.requiredString(data, 'result', path: path),
      date: _ProjectContextJson.requiredString(data, 'date', path: path),
      evidencePaths: _ProjectContextJson.requiredStringList(
        data,
        'evidencePaths',
        path: path,
      ),
      environment: _ProjectContextJson.optionalString(
        data,
        'environment',
        path: path,
      ),
      limitations: _ProjectContextJson.optionalStringList(
        data,
        'limitations',
        path: path,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'verificationId': verificationId,
      'scope': scope,
      'commit': commit,
      'branch': branch,
      'result': result,
      'date': date,
      'evidencePaths': evidencePaths,
    };
    if (environment != null) {
      json['environment'] = environment;
    }
    if (limitations != null) {
      json['limitations'] = limitations;
    }
    return json;
  }
}

class ProjectContextCiContext {
  ProjectContextCiContext({
    required this.observedHead,
    required List<String> requiredChecks,
    required List<ProjectContextCiRun> runs,
  }) : requiredChecks = List<String>.unmodifiable(requiredChecks),
       runs = List<ProjectContextCiRun>.unmodifiable(runs);

  final String observedHead;
  final List<String> requiredChecks;
  final List<ProjectContextCiRun> runs;

  factory ProjectContextCiContext.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.ci',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {'observedHead', 'requiredChecks', 'runs'},
      requiredKeys: const {'observedHead', 'requiredChecks', 'runs'},
    );
    return ProjectContextCiContext(
      observedHead: _ProjectContextJson.requiredString(
        data,
        'observedHead',
        path: path,
      ),
      requiredChecks: _ProjectContextJson.requiredStringList(
        data,
        'requiredChecks',
        path: path,
      ),
      runs: _ProjectContextJson.requiredList<ProjectContextCiRun>(
        data,
        'runs',
        path: path,
        parseItem: (value, itemPath) =>
            ProjectContextCiRun.fromJson(value, path: itemPath),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'observedHead': observedHead,
      'requiredChecks': requiredChecks,
      'runs': runs.map((item) => item.toJson()).toList(growable: false),
    };
  }
}

class ProjectContextCiRun {
  const ProjectContextCiRun({
    required this.name,
    required this.runId,
    required this.status,
    required this.headSha,
    required this.url,
  });

  final String name;
  final String runId;
  final String status;
  final String headSha;
  final String url;

  factory ProjectContextCiRun.fromJson(
    Object? json, {
    String path = r'$.ci.runs',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {'name', 'runId', 'status', 'headSha', 'url'},
      requiredKeys: const {'name', 'runId', 'status', 'headSha', 'url'},
    );
    return ProjectContextCiRun(
      name: _ProjectContextJson.requiredString(data, 'name', path: path),
      runId: _ProjectContextJson.requiredString(data, 'runId', path: path),
      status: _ProjectContextJson.requiredString(data, 'status', path: path),
      headSha: _ProjectContextJson.requiredString(data, 'headSha', path: path),
      url: _ProjectContextJson.requiredString(data, 'url', path: path),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'runId': runId,
      'status': status,
      'headSha': headSha,
      'url': url,
    };
  }
}

class ProjectContextReleasesContext {
  ProjectContextReleasesContext({
    required List<ProjectContextReleaseItem> items,
  }) : items = List<ProjectContextReleaseItem>.unmodifiable(items);

  final List<ProjectContextReleaseItem> items;

  factory ProjectContextReleasesContext.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.releases',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {'items'},
      requiredKeys: const {'items'},
    );
    return ProjectContextReleasesContext(
      items: _ProjectContextJson.requiredList<ProjectContextReleaseItem>(
        data,
        'items',
        path: path,
        parseItem: (value, itemPath) =>
            ProjectContextReleaseItem.fromJson(value, path: itemPath),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'items': items.map((item) => item.toJson()).toList(growable: false),
    };
  }
}

class ProjectContextReleaseItem {
  const ProjectContextReleaseItem({
    required this.releaseId,
    required this.version,
    required this.maturity,
    required this.commit,
    required this.status,
  });

  final String releaseId;
  final String version;
  final String maturity;
  final String commit;
  final String status;

  factory ProjectContextReleaseItem.fromJson(
    Object? json, {
    String path = r'$.releases.items',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {
        'releaseId',
        'version',
        'maturity',
        'commit',
        'status',
      },
      requiredKeys: const {
        'releaseId',
        'version',
        'maturity',
        'commit',
        'status',
      },
    );
    return ProjectContextReleaseItem(
      releaseId: _ProjectContextJson.requiredString(
        data,
        'releaseId',
        path: path,
      ),
      version: _ProjectContextJson.requiredString(data, 'version', path: path),
      maturity: _ProjectContextJson.requiredString(
        data,
        'maturity',
        path: path,
      ),
      commit: _ProjectContextJson.requiredString(data, 'commit', path: path),
      status: _ProjectContextJson.requiredString(data, 'status', path: path),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'releaseId': releaseId,
      'version': version,
      'maturity': maturity,
      'commit': commit,
      'status': status,
    };
  }
}

class ProjectContextDataQualityContext {
  ProjectContextDataQualityContext({
    required this.status,
    required List<String> warnings,
    required List<String> staleFields,
    required List<String> missingFields,
  }) : warnings = List<String>.unmodifiable(warnings),
       staleFields = List<String>.unmodifiable(staleFields),
       missingFields = List<String>.unmodifiable(missingFields);

  final ProjectContextDataQualityStatus status;
  final List<String> warnings;
  final List<String> staleFields;
  final List<String> missingFields;

  factory ProjectContextDataQualityContext.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.dataQuality',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {'status', 'warnings', 'staleFields', 'missingFields'},
      requiredKeys: const {
        'status',
        'warnings',
        'staleFields',
        'missingFields',
      },
    );
    return ProjectContextDataQualityContext(
      status: projectContextDataQualityStatusFromJson(
        _ProjectContextJson.requiredString(data, 'status', path: path),
        '$path.status',
      ),
      warnings: _ProjectContextJson.requiredStringList(
        data,
        'warnings',
        path: path,
      ),
      staleFields: _ProjectContextJson.requiredStringList(
        data,
        'staleFields',
        path: path,
      ),
      missingFields: _ProjectContextJson.requiredStringList(
        data,
        'missingFields',
        path: path,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'status': status.jsonValue,
      'warnings': warnings,
      'staleFields': staleFields,
      'missingFields': missingFields,
    };
  }
}

class ProjectContextProvenanceContext {
  ProjectContextProvenanceContext({
    required List<String> sourceAllowlist,
    required List<String> evidenceReferences,
    List<String>? notes,
  }) : sourceAllowlist = List<String>.unmodifiable(sourceAllowlist),
       evidenceReferences = List<String>.unmodifiable(evidenceReferences),
       notes = notes == null ? null : List<String>.unmodifiable(notes);

  final List<String> sourceAllowlist;
  final List<String> evidenceReferences;
  final List<String>? notes;

  factory ProjectContextProvenanceContext.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.provenance',
  }) {
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {'sourceAllowlist', 'evidenceReferences', 'notes'},
      requiredKeys: const {'sourceAllowlist', 'evidenceReferences'},
    );
    return ProjectContextProvenanceContext(
      sourceAllowlist: _ProjectContextJson.requiredStringList(
        data,
        'sourceAllowlist',
        path: path,
      ),
      evidenceReferences: _ProjectContextJson.requiredStringList(
        data,
        'evidenceReferences',
        path: path,
      ),
      notes: _ProjectContextJson.optionalStringList(data, 'notes', path: path),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'sourceAllowlist': sourceAllowlist,
      'evidenceReferences': evidenceReferences,
    };
    if (notes != null) {
      json['notes'] = notes;
    }
    return json;
  }
}
