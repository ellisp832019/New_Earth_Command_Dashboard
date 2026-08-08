part of 'project_context.dart';

/// Strict parser for Project Context v1.
///
/// The parser accepts only the approved contractVersion and rejects unknown
/// fields or malformed contract values with path-aware errors.
class ProjectContextParser {
  const ProjectContextParser();

  /// Parses a strict Project Context v1 snapshot from JSON.
  ProjectContextSnapshot parse(Map<String, dynamic> json) {
    const path = r'$';
    final data = _ProjectContextJson.object(
      json,
      path: path,
      allowedKeys: const {
        'contractVersion',
        'snapshotId',
        'generatedAt',
        'repository',
        'platform',
        'baseline',
        'releaseReadiness',
        'repositoryHealth',
        'risks',
        'modules',
        'dependencies',
        'verification',
        'ci',
        'releases',
        'dataQuality',
        'provenance',
      },
      requiredKeys: const {
        'contractVersion',
        'snapshotId',
        'generatedAt',
        'repository',
        'platform',
        'baseline',
        'releaseReadiness',
        'repositoryHealth',
        'risks',
        'modules',
        'dependencies',
        'verification',
        'ci',
        'releases',
        'dataQuality',
        'provenance',
      },
    );
    final contractVersion = _ProjectContextJson.requiredString(
      data,
      'contractVersion',
      path: path,
    );
    if (contractVersion != 'v1') {
      throw ProjectContextParseException.unsupportedValue(
        path: '$path.contractVersion',
        actual: contractVersion,
        expected: 'v1',
      );
    }

    return ProjectContextSnapshot(
      contractVersion: contractVersion,
      snapshotId: _ProjectContextJson.requiredString(
        data,
        'snapshotId',
        path: path,
      ),
      generatedAt: _ProjectContextJson.requiredDateTime(
        data,
        'generatedAt',
        path: path,
      ),
      repository: ProjectContextRepositoryContext.fromJson(
        _ProjectContextJson.requiredObject(
          data,
          'repository',
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
        ),
        path: '$path.repository',
      ),
      platform: ProjectContextPlatformContext.fromJson(
        _ProjectContextJson.requiredObject(
          data,
          'platform',
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
        ),
        path: '$path.platform',
      ),
      baseline: ProjectContextBaselineContext.fromJson(
        _ProjectContextJson.requiredObject(
          data,
          'baseline',
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
        ),
        path: '$path.baseline',
      ),
      releaseReadiness: ProjectContextReleaseReadinessContext.fromJson(
        _ProjectContextJson.requiredObject(
          data,
          'releaseReadiness',
          path: path,
          allowedKeys: const {'status', 'reasons'},
          requiredKeys: const {'status', 'reasons'},
        ),
        path: '$path.releaseReadiness',
      ),
      repositoryHealth: ProjectContextRepositoryHealthContext.fromJson(
        _ProjectContextJson.requiredObject(
          data,
          'repositoryHealth',
          path: path,
          allowedKeys: const {'status', 'workingTreeState', 'warnings'},
          requiredKeys: const {'status', 'workingTreeState', 'warnings'},
        ),
        path: '$path.repositoryHealth',
      ),
      risks: ProjectContextRisksContext.fromJson(
        _ProjectContextJson.requiredObject(
          data,
          'risks',
          path: path,
          allowedKeys: const {'items'},
          requiredKeys: const {'items'},
        ),
        path: '$path.risks',
      ),
      modules: ProjectContextModulesContext.fromJson(
        _ProjectContextJson.requiredObject(
          data,
          'modules',
          path: path,
          allowedKeys: const {'items'},
          requiredKeys: const {'items'},
        ),
        path: '$path.modules',
      ),
      dependencies: ProjectContextDependenciesContext.fromJson(
        _ProjectContextJson.requiredObject(
          data,
          'dependencies',
          path: path,
          allowedKeys: const {'moduleDependencies', 'sharedServices'},
          requiredKeys: const {'moduleDependencies', 'sharedServices'},
        ),
        path: '$path.dependencies',
      ),
      verification: ProjectContextVerificationContext.fromJson(
        _ProjectContextJson.requiredObject(
          data,
          'verification',
          path: path,
          allowedKeys: const {'items'},
          requiredKeys: const {'items'},
        ),
        path: '$path.verification',
      ),
      ci: ProjectContextCiContext.fromJson(
        _ProjectContextJson.requiredObject(
          data,
          'ci',
          path: path,
          allowedKeys: const {'observedHead', 'requiredChecks', 'runs'},
          requiredKeys: const {'observedHead', 'requiredChecks', 'runs'},
        ),
        path: '$path.ci',
      ),
      releases: ProjectContextReleasesContext.fromJson(
        _ProjectContextJson.requiredObject(
          data,
          'releases',
          path: path,
          allowedKeys: const {'items'},
          requiredKeys: const {'items'},
        ),
        path: '$path.releases',
      ),
      dataQuality: ProjectContextDataQualityContext.fromJson(
        _ProjectContextJson.requiredObject(
          data,
          'dataQuality',
          path: path,
          allowedKeys: const {
            'status',
            'warnings',
            'staleFields',
            'missingFields',
          },
          requiredKeys: const {
            'status',
            'warnings',
            'staleFields',
            'missingFields',
          },
        ),
        path: '$path.dataQuality',
      ),
      provenance: ProjectContextProvenanceContext.fromJson(
        _ProjectContextJson.requiredObject(
          data,
          'provenance',
          path: path,
          allowedKeys: const {'sourceAllowlist', 'evidenceReferences', 'notes'},
          requiredKeys: const {'sourceAllowlist', 'evidenceReferences'},
        ),
        path: '$path.provenance',
      ),
    );
  }
}
