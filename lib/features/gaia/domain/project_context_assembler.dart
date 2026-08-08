part of 'project_context.dart';

/// Pure input bundle for assembling a Project Context snapshot.
class ProjectContextAssemblyInput {
  ProjectContextAssemblyInput({
    required this.projectControl,
    required this.localGit,
    required this.metadata,
  });

  final project_control.ProjectControlContextBundle projectControl;
  final LocalGitLiveState localGit;
  final ProjectContextAssemblyMetadata metadata;
}

/// Explicit assembly metadata that neither adapter owns.
class ProjectContextAssemblyMetadata {
  ProjectContextAssemblyMetadata({
    required this.snapshotId,
    required this.generatedAt,
    required this.repositoryId,
    required this.repositoryName,
    required this.remoteIdentity,
    required this.defaultBranch,
    required this.protectedBranchCommit,
    required List<String> ciRequiredChecks,
    required List<ProjectContextCiRun> ciRuns,
    required this.dashboardVersion,
    required this.dashboardMaturity,
    required this.gaiaIntegrationVersion,
    required this.gaiaDependencyRef,
    required this.baselineTag,
    required this.baselineCommit,
    required this.recordedManifestCommit,
    required this.comparisonBase,
    required List<String> sourceAllowlist,
    required List<String> evidenceReferences,
    this.baselineRecordedAt,
    this.liveStateLabel,
    List<String>? notes,
  }) : ciRequiredChecks = List<String>.unmodifiable(ciRequiredChecks),
       ciRuns = List<ProjectContextCiRun>.unmodifiable(ciRuns),
       sourceAllowlist = List<String>.unmodifiable(sourceAllowlist),
       evidenceReferences = List<String>.unmodifiable(evidenceReferences),
       notes = notes == null ? null : List<String>.unmodifiable(notes);

  final String snapshotId;
  final DateTime generatedAt;
  final String repositoryId;
  final String repositoryName;
  final String remoteIdentity;
  final String defaultBranch;
  final String protectedBranchCommit;
  final List<String> ciRequiredChecks;
  final List<ProjectContextCiRun> ciRuns;
  final String dashboardVersion;
  final String dashboardMaturity;
  final String gaiaIntegrationVersion;
  final String gaiaDependencyRef;
  final String baselineTag;
  final String baselineCommit;
  final String recordedManifestCommit;
  final String comparisonBase;
  final List<String> sourceAllowlist;
  final List<String> evidenceReferences;
  final DateTime? baselineRecordedAt;
  final String? liveStateLabel;
  final List<String>? notes;
}

/// Deterministically assembles the read-only Project Context snapshot.
class ProjectContextSnapshotAssembler {
  const ProjectContextSnapshotAssembler();

  ProjectContextSnapshot assemble(ProjectContextAssemblyInput input) {
    final bundle = input.projectControl;
    final live = input.localGit;
    final metadata = input.metadata;

    final repository = _assembleRepository(live, metadata);
    final platform = _assemblePlatform(metadata);
    final baseline = _assembleBaseline(metadata);
    final releaseReadiness = _assembleReleaseReadiness(
      bundle.generated.releaseReadiness,
    );
    final repositoryHealth = _assembleRepositoryHealth(
      bundle: bundle,
      live: live,
    );
    final risks = ProjectContextRisksContext(
      items: bundle.canonical.risks.map(_mapRisk).toList(growable: false),
    );
    final modules = ProjectContextModulesContext(
      items: bundle.canonical.modules.map(_mapModule).toList(growable: false),
    );
    final dependencies = _assembleDependencies(bundle.canonical.dependencyMap);
    final verification = ProjectContextVerificationContext(
      items: bundle.canonical.verification
          .map(_mapVerification)
          .toList(growable: false),
    );
    final ci = ProjectContextCiContext(
      observedHead: live.observedCommit,
      requiredChecks: metadata.ciRequiredChecks,
      runs: metadata.ciRuns,
    );
    final releases = ProjectContextReleasesContext(
      items: bundle.canonical.releases.map(_mapRelease).toList(growable: false),
    );
    final provenance = ProjectContextProvenanceContext(
      sourceAllowlist: _dedupe(metadata.sourceAllowlist),
      evidenceReferences: _dedupe(metadata.evidenceReferences),
      notes: metadata.notes,
    );
    final quality = _assembleDataQuality(
      bundle: bundle,
      live: live,
      metadata: metadata,
      repositoryHealth: repositoryHealth,
      ci: ci,
    );

    return ProjectContextSnapshot(
      contractVersion: 'v1',
      snapshotId: metadata.snapshotId,
      generatedAt: metadata.generatedAt,
      repository: repository,
      platform: platform,
      baseline: baseline,
      releaseReadiness: releaseReadiness,
      repositoryHealth: repositoryHealth,
      risks: risks,
      modules: modules,
      dependencies: dependencies,
      verification: verification,
      ci: ci,
      releases: releases,
      dataQuality: quality,
      provenance: provenance,
    );
  }

  ProjectContextRepositoryContext _assembleRepository(
    LocalGitLiveState live,
    ProjectContextAssemblyMetadata metadata,
  ) {
    return ProjectContextRepositoryContext(
      repositoryId: metadata.repositoryId,
      repositoryName: metadata.repositoryName,
      remoteIdentity: live.remoteIdentity?.name ?? metadata.remoteIdentity,
      defaultBranch: metadata.defaultBranch,
      observedBranch: live.observedBranch,
      observedCommit: live.observedCommit,
      protectedBranch: ProjectContextProtectedBranchContext(
        name: metadata.defaultBranch,
        commit: metadata.protectedBranchCommit,
        requiredChecks: metadata.ciRequiredChecks,
      ),
      dirtyState: _mapDirtyState(live.workingTreeState),
      aheadBehind: live.aheadBehind == null
          ? null
          : ProjectContextAheadBehindContext(
              ahead: live.aheadBehind!.ahead,
              behind: live.aheadBehind!.behind,
            ),
      observedAt: live.observedAt,
    );
  }

  ProjectContextPlatformContext _assemblePlatform(
    ProjectContextAssemblyMetadata metadata,
  ) {
    return ProjectContextPlatformContext(
      dashboardVersion: metadata.dashboardVersion,
      dashboardMaturity: metadata.dashboardMaturity,
      gaiaIntegrationVersion: metadata.gaiaIntegrationVersion,
      gaiaDependencyRef: metadata.gaiaDependencyRef,
      liveStateLabel: metadata.liveStateLabel,
    );
  }

  ProjectContextBaselineContext _assembleBaseline(
    ProjectContextAssemblyMetadata metadata,
  ) {
    return ProjectContextBaselineContext(
      baselineTag: metadata.baselineTag,
      baselineCommit: metadata.baselineCommit,
      recordedManifestCommit: metadata.recordedManifestCommit,
      comparisonBase: metadata.comparisonBase,
      recordedAt: metadata.baselineRecordedAt,
      historicalOnly: true,
    );
  }

  ProjectContextReleaseReadinessContext _assembleReleaseReadiness(
    project_control.ProjectControlReleaseReadinessRecord record,
  ) {
    return ProjectContextReleaseReadinessContext(
      status: switch (record.result) {
        'blocked' => ProjectContextReleaseReadinessStatus.blocked,
        'not_ready' => ProjectContextReleaseReadinessStatus.notReady,
        'ready_with_conditions' =>
          ProjectContextReleaseReadinessStatus.readyWithConditions,
        'ready' => ProjectContextReleaseReadinessStatus.ready,
        _ => ProjectContextReleaseReadinessStatus.notReady,
      },
      reasons: record.reasons,
    );
  }

  ProjectContextRepositoryHealthContext _assembleRepositoryHealth({
    required project_control.ProjectControlContextBundle bundle,
    required LocalGitLiveState live,
  }) {
    final warnings = <String>[
      ..._dedupe(bundle.generated.repositoryHealth.warnings),
      ...live.issues.map(_issueMessage),
    ];

    if (live.observedBranch == null) {
      warnings.add('Local Git is on a detached HEAD.');
    }
    if (live.headMode == LocalGitHeadMode.branch &&
        live.upstreamBranch == null) {
      warnings.add('No upstream branch was configured locally.');
    }
    if (live.remoteIdentity == null) {
      warnings.add('Local Git did not expose a remote identity.');
    }
    if (bundle.generated.currentState.branch != live.observedBranch &&
        live.observedBranch != null) {
      warnings.add('Recorded Project Control branch differs from live Git.');
    }
    if (bundle.generated.currentState.commit != live.observedCommit) {
      warnings.add('Recorded Project Control commit differs from live Git.');
    }

    return ProjectContextRepositoryHealthContext(
      status: _repositoryHealthStatus(bundle: bundle, live: live),
      workingTreeState: _mapDirtyState(live.workingTreeState),
      warnings: _dedupe(warnings),
    );
  }

  ProjectContextRepositoryHealthStatus _repositoryHealthStatus({
    required project_control.ProjectControlContextBundle bundle,
    required LocalGitLiveState live,
  }) {
    final canonicalBranch = bundle.canonical.platformManifest.currentBranch;
    final canonicalCommit = bundle.canonical.platformManifest.currentCommit;

    if (canonicalCommit != live.observedCommit ||
        (live.observedBranch != null &&
            canonicalBranch != live.observedBranch)) {
      return ProjectContextRepositoryHealthStatus.conflicting;
    }

    if (live.workingTreeState == LocalGitWorkingTreeState.dirty ||
        live.workingTreeState == LocalGitWorkingTreeState.unknown ||
        live.observedBranch == null ||
        (live.headMode == LocalGitHeadMode.branch &&
            live.upstreamBranch == null) ||
        live.remoteIdentity == null) {
      return ProjectContextRepositoryHealthStatus.degraded;
    }

    return ProjectContextRepositoryHealthStatus.good;
  }

  ProjectContextDataQualityContext _assembleDataQuality({
    required project_control.ProjectControlContextBundle bundle,
    required LocalGitLiveState live,
    required ProjectContextAssemblyMetadata metadata,
    required ProjectContextRepositoryHealthContext repositoryHealth,
    required ProjectContextCiContext ci,
  }) {
    final warnings = <String>[];
    final staleFields = <String>[];
    final missingFields = <String>[];

    if (live.observedBranch == null) {
      missingFields.add('repository.observedBranch');
      warnings.add(
        'Local Git is on a detached HEAD, so no live branch name was observed.',
      );
    }
    if (live.headMode == LocalGitHeadMode.branch &&
        live.upstreamBranch == null) {
      missingFields.add('repository.aheadBehind');
      warnings.add(
        'No upstream branch was configured, so ahead/behind was unavailable.',
      );
    }
    if (live.remoteIdentity == null) {
      warnings.add(
        'Local Git did not expose a remote identity; the approved metadata value was used.',
      );
    }

    if (bundle.generated.currentState.branch != live.observedBranch &&
        live.observedBranch != null) {
      staleFields.add('repository.observedBranch');
      warnings.add(
        'Recorded Project Control branch differs from the live Git branch.',
      );
    }
    if (bundle.generated.currentState.commit != live.observedCommit) {
      staleFields.add('baseline.recordedManifestCommit');
      warnings.add('Recorded Project Control commit differs from live Git.');
    }
    for (var index = 0; index < bundle.canonical.verification.length; index++) {
      final verification = bundle.canonical.verification[index];
      if (verification.commit != live.observedCommit) {
        staleFields.add('verification.items[$index].commit');
      }
    }
    if (bundle.generated.repositoryHealth.commit != live.observedCommit) {
      staleFields.add('repositoryHealth.commit');
    }
    if (bundle.generated.repositoryHealth.branch !=
        (live.observedBranch ?? bundle.generated.repositoryHealth.branch)) {
      staleFields.add('repositoryHealth.branch');
    }
    for (var index = 0; index < ci.runs.length; index++) {
      final run = ci.runs[index];
      if (run.headSha != live.observedCommit) {
        staleFields.add('ci.runs[$index].headSha');
      }
    }
    if (metadata.ciRuns.isEmpty) {
      missingFields.add('ci.runs');
      warnings.add('No CI runs were supplied for this snapshot.');
    }
    if (metadata.ciRequiredChecks.isEmpty) {
      missingFields.add('ci.requiredChecks');
      warnings.add('No required CI checks were supplied for this snapshot.');
    }

    final hasCriticalMissing =
        metadata.ciRequiredChecks.isEmpty && metadata.ciRuns.isEmpty;
    final status = hasCriticalMissing
        ? ProjectContextDataQualityStatus.missing
        : _dataQualityStatus(
            hasConflicts:
                repositoryHealth.status ==
                ProjectContextRepositoryHealthStatus.conflicting,
            hasStale: staleFields.isNotEmpty,
            hasWarnings: warnings.isNotEmpty,
          );

    return ProjectContextDataQualityContext(
      status: status,
      warnings: _dedupe(warnings),
      staleFields: _dedupe(staleFields),
      missingFields: _dedupe(missingFields),
    );
  }

  ProjectContextDataQualityStatus _dataQualityStatus({
    required bool hasConflicts,
    required bool hasStale,
    required bool hasWarnings,
  }) {
    if (hasConflicts) {
      return ProjectContextDataQualityStatus.conflicting;
    }
    if (hasStale) {
      return ProjectContextDataQualityStatus.stale;
    }
    if (hasWarnings) {
      return ProjectContextDataQualityStatus.degraded;
    }
    return ProjectContextDataQualityStatus.good;
  }

  ProjectContextDependenciesContext _assembleDependencies(
    project_control.ProjectControlDependencyMapRecord dependencyMap,
  ) {
    return ProjectContextDependenciesContext(
      moduleDependencies: dependencyMap.moduleDependencies
          .map(
            (record) => ProjectContextModuleDependency(
              module: record.module,
              dependsOn: record.dependsOn,
            ),
          )
          .toList(growable: false),
      sharedServices: dependencyMap.sharedServiceDependencies
          .map(
            (record) => ProjectContextSharedServiceDependency(
              service: record.service,
              usedBy: record.usedBy,
            ),
          )
          .toList(growable: false),
    );
  }

  ProjectContextRiskItem _mapRisk(
    project_control.ProjectControlRiskRecord record,
  ) {
    return ProjectContextRiskItem(
      riskId: record.riskId,
      title: record.title,
      severity: record.severity,
      status: record.status,
      affectedModules: record.affectedModules,
      lastReviewed: record.lastReviewedDate,
      evidenceReferences: record.evidence,
      likelihood: _blankToNull(record.likelihood),
      owner: _blankToNull(record.owner),
      targetRelease: _blankToNull(record.targetRelease),
    );
  }

  ProjectContextModuleItem _mapModule(
    project_control.ProjectControlModuleRecord record,
  ) {
    return ProjectContextModuleItem(
      moduleId: record.id,
      name: record.name,
      version: record.version,
      maturity: record.maturity,
      verificationStatus: record.verificationStatus,
      documentationStatus: record.documentationStatus,
      lastVerifiedCommit: record.lastVerifiedCommit,
      dependencies: record.dependencies,
      route: _blankToNull(record.route),
      knownRisks: record.knownRisks.isEmpty ? null : record.knownRisks,
    );
  }

  ProjectContextVerificationItem _mapVerification(
    project_control.ProjectControlVerificationRecord record,
  ) {
    return ProjectContextVerificationItem(
      verificationId: record.verificationId,
      scope: record.scope,
      commit: record.commit,
      branch: record.branch,
      result: record.result,
      date: record.date,
      evidencePaths: record.evidencePaths,
      environment: _blankToNull(record.environment),
      limitations: record.limitations.isEmpty ? null : record.limitations,
    );
  }

  ProjectContextReleaseItem _mapRelease(
    project_control.ProjectControlReleaseRecord record,
  ) {
    return ProjectContextReleaseItem(
      releaseId: record.releaseId,
      version: record.version,
      maturity: record.maturity,
      commit: record.commit,
      status: record.status,
    );
  }

  ProjectContextDirtyState _mapDirtyState(
    LocalGitWorkingTreeState workingTreeState,
  ) {
    return switch (workingTreeState) {
      LocalGitWorkingTreeState.clean => ProjectContextDirtyState.clean,
      LocalGitWorkingTreeState.dirty => ProjectContextDirtyState.dirty,
      LocalGitWorkingTreeState.unknown => ProjectContextDirtyState.unknown,
    };
  }

  static String _issueMessage(LocalGitObservationIssue issue) {
    return issue.command == null || issue.command!.isEmpty
        ? issue.message
        : '${issue.message} (${issue.command})';
  }

  static String? _blankToNull(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value;
  }

  static List<String> _dedupe(Iterable<String> values) {
    final result = <String>{};
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      result.add(trimmed);
    }
    return result.toList(growable: false);
  }
}
