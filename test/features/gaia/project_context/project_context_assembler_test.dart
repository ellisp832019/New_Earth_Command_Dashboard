import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/gaia/data/local_git_live_state_models.dart';
import 'package:new_earth_command_dashboard/features/gaia/data/project_control_context_models.dart'
    as project_control;
import 'package:new_earth_command_dashboard/features/gaia/domain/project_context.dart';

void main() {
  group('ProjectContextSnapshotAssembler', () {
    test('assembles a live snapshot with preserved provenance', () {
      final input = _input(
        liveCommit: _liveCommit,
        liveBranch: _liveBranch,
        canonicalCommit: _liveCommit,
        canonicalBranch: _liveBranch,
        currentStateCommit: _liveCommit,
        currentStateBranch: _liveBranch,
        repositoryHealthCommit: _liveCommit,
        repositoryHealthBranch: _liveBranch,
        verificationCommit: _liveCommit,
        ciRuns: <ProjectContextCiRun>[
          ProjectContextCiRun(
            name: 'Flutter Quality',
            runId: '1',
            status: 'success',
            headSha: _liveCommit,
            url: 'https://example.test/runs/1',
          ),
        ],
      );

      final snapshot = const ProjectContextSnapshotAssembler().assemble(input);

      expect(snapshot.repository.observedBranch, _liveBranch);
      expect(snapshot.repository.observedCommit, _liveCommit);
      expect(snapshot.repository.remoteIdentity, 'origin');
      expect(snapshot.repository.protectedBranch.commit, _liveCommit);
      expect(
        snapshot.releaseReadiness.status,
        ProjectContextReleaseReadinessStatus.readyWithConditions,
      );
      expect(
        snapshot.repositoryHealth.status,
        ProjectContextRepositoryHealthStatus.good,
      );
      expect(snapshot.dataQuality.status, ProjectContextDataQualityStatus.good);
      expect(snapshot.dataQuality.staleFields, isEmpty);
      expect(snapshot.dataQuality.missingFields, isEmpty);
      expect(
        snapshot.provenance.sourceAllowlist,
        contains('git rev-parse HEAD'),
      );
      expect(
        snapshot.provenance.evidenceReferences,
        contains(
          'docs/project_control/evidence/2026-08-08/GAIA_V0_9_SLICE_D_PROJECT_CONTEXT_ASSEMBLER_ACCEPTANCE.md',
        ),
      );
    });

    test('marks generated evidence as stale when live Git has moved on', () {
      final input = _input(
        liveCommit: _liveCommit,
        liveBranch: _liveBranch,
        canonicalCommit: _liveCommit,
        canonicalBranch: _liveBranch,
        currentStateCommit: _recordedCommit,
        currentStateBranch: _recordedBranch,
        repositoryHealthCommit: _recordedCommit,
        repositoryHealthBranch: _recordedBranch,
        verificationCommit: _recordedCommit,
        ciRuns: <ProjectContextCiRun>[
          ProjectContextCiRun(
            name: 'Flutter Quality',
            runId: '1',
            status: 'success',
            headSha: _recordedCommit,
            url: 'https://example.test/runs/1',
          ),
        ],
      );

      final snapshot = const ProjectContextSnapshotAssembler().assemble(input);

      expect(
        snapshot.dataQuality.status,
        ProjectContextDataQualityStatus.stale,
      );
      expect(
        snapshot.dataQuality.staleFields,
        contains('baseline.recordedManifestCommit'),
      );
      expect(
        snapshot.dataQuality.staleFields,
        contains('verification.items[0].commit'),
      );
      expect(
        snapshot.dataQuality.staleFields,
        contains('repositoryHealth.commit'),
      );
    });

    test('represents detached HEAD without inventing a branch name', () {
      final input = _input(
        liveCommit: _liveCommit,
        liveBranch: null,
        canonicalCommit: _liveCommit,
        canonicalBranch: _liveBranch,
        currentStateCommit: _liveCommit,
        currentStateBranch: _liveBranch,
        repositoryHealthCommit: _liveCommit,
        repositoryHealthBranch: _liveBranch,
        verificationCommit: _liveCommit,
        liveRemoteIdentity: null,
        upstreamBranch: null,
        aheadBehind: null,
        ciRuns: <ProjectContextCiRun>[
          ProjectContextCiRun(
            name: 'Flutter Quality',
            runId: '1',
            status: 'success',
            headSha: _liveCommit,
            url: 'https://example.test/runs/1',
          ),
        ],
      );

      final snapshot = const ProjectContextSnapshotAssembler().assemble(input);

      expect(snapshot.repository.observedBranch, isNull);
      expect(snapshot.repository.remoteIdentity, 'origin');
      expect(
        snapshot.dataQuality.missingFields,
        contains('repository.observedBranch'),
      );
      expect(
        snapshot.repositoryHealth.status,
        ProjectContextRepositoryHealthStatus.degraded,
      );
    });

    test('treats missing CI evidence as unavailable', () {
      final input = _input(
        liveCommit: _liveCommit,
        liveBranch: _liveBranch,
        canonicalCommit: _liveCommit,
        canonicalBranch: _liveBranch,
        currentStateCommit: _liveCommit,
        currentStateBranch: _liveBranch,
        repositoryHealthCommit: _liveCommit,
        repositoryHealthBranch: _liveBranch,
        verificationCommit: _liveCommit,
        ciRequiredChecks: const <String>[],
        ciRuns: const <ProjectContextCiRun>[],
      );

      final snapshot = const ProjectContextSnapshotAssembler().assemble(input);

      expect(snapshot.ci.requiredChecks, isEmpty);
      expect(snapshot.ci.runs, isEmpty);
      expect(
        snapshot.dataQuality.status,
        ProjectContextDataQualityStatus.missing,
      );
      expect(snapshot.dataQuality.missingFields, contains('ci.requiredChecks'));
      expect(snapshot.dataQuality.missingFields, contains('ci.runs'));
    });

    test('flags canonical and live divergence as conflicting', () {
      final input = _input(
        liveCommit: _liveCommit,
        liveBranch: _liveBranch,
        canonicalCommit: _conflictingCommit,
        canonicalBranch: _liveBranch,
        currentStateCommit: _liveCommit,
        currentStateBranch: _liveBranch,
        repositoryHealthCommit: _liveCommit,
        repositoryHealthBranch: _liveBranch,
        verificationCommit: _liveCommit,
        ciRuns: <ProjectContextCiRun>[
          ProjectContextCiRun(
            name: 'Flutter Quality',
            runId: '1',
            status: 'success',
            headSha: _liveCommit,
            url: 'https://example.test/runs/1',
          ),
        ],
      );

      final snapshot = const ProjectContextSnapshotAssembler().assemble(input);

      expect(
        snapshot.repositoryHealth.status,
        ProjectContextRepositoryHealthStatus.conflicting,
      );
      expect(
        snapshot.dataQuality.status,
        ProjectContextDataQualityStatus.conflicting,
      );
    });

    test('round-trips the assembled snapshot JSON', () {
      final snapshot = const ProjectContextSnapshotAssembler().assemble(
        _input(
          liveCommit: _liveCommit,
          liveBranch: _liveBranch,
          canonicalCommit: _liveCommit,
          canonicalBranch: _liveBranch,
          currentStateCommit: _liveCommit,
          currentStateBranch: _liveBranch,
          repositoryHealthCommit: _liveCommit,
          repositoryHealthBranch: _liveBranch,
          verificationCommit: _liveCommit,
          ciRuns: <ProjectContextCiRun>[
            ProjectContextCiRun(
              name: 'Flutter Quality',
              runId: '1',
              status: 'success',
              headSha: _liveCommit,
              url: 'https://example.test/runs/1',
            ),
          ],
        ),
      );

      final encoded = snapshot.toJson();
      final decoded = ProjectContextSnapshot.fromJson(_jsonRoundTrip(encoded));

      expect(decoded.toJson(), encoded);
    });
  });
}

const String _liveCommit = 'a0880a136db7e9a6714e016d054e2a887e3f9475';
const String _recordedCommit = 'b0880a136db7e9a6714e016d054e2a887e3f9475';
const String _conflictingCommit = 'c0880a136db7e9a6714e016d054e2a887e3f9475';
const String _liveBranch =
    'feature/gaia-v0.9-project-context-assembler-2026-08-08';
const String _recordedBranch =
    'feature/gaia-v0.9-project-context-assembler-2026-08-07';

ProjectContextAssemblyInput _input({
  required String liveCommit,
  required String? liveBranch,
  required String canonicalCommit,
  required String canonicalBranch,
  required String currentStateCommit,
  required String currentStateBranch,
  required String repositoryHealthCommit,
  required String repositoryHealthBranch,
  required String verificationCommit,
  String metadataRemoteIdentity = 'origin',
  String? liveRemoteIdentity = 'origin',
  String? upstreamBranch = 'origin/feature/live-state',
  LocalGitAheadBehind? aheadBehind = const LocalGitAheadBehind(
    ahead: 0,
    behind: 0,
  ),
  List<String> ciRequiredChecks = const <String>[
    'Flutter Quality',
    'Project Control Validation',
    'Windows Release Build',
  ],
  List<ProjectContextCiRun> ciRuns = const <ProjectContextCiRun>[],
}) {
  return ProjectContextAssemblyInput(
    projectControl: _bundle(
      canonicalCommit: canonicalCommit,
      canonicalBranch: canonicalBranch,
      currentStateCommit: currentStateCommit,
      currentStateBranch: currentStateBranch,
      repositoryHealthCommit: repositoryHealthCommit,
      repositoryHealthBranch: repositoryHealthBranch,
      verificationCommit: verificationCommit,
    ),
    localGit: LocalGitLiveState(
      repositoryRoot: 'D:\\Dev\\Projects\\New Earth - Command Dashboard',
      observedAt: DateTime.parse('2026-08-08T12:00:00Z'),
      headMode: liveBranch == null
          ? LocalGitHeadMode.detached
          : LocalGitHeadMode.branch,
      observedCommit: liveCommit,
      observedBranch: liveBranch,
      workingTreeState: LocalGitWorkingTreeState.clean,
      upstreamBranch: upstreamBranch,
      aheadBehind: aheadBehind,
      remoteIdentity: liveRemoteIdentity == null || liveRemoteIdentity.isEmpty
          ? null
          : LocalGitRemoteIdentity(
              name: liveRemoteIdentity,
              url:
                  'https://redacted@github.com/ellisp832019/New_Earth_Command_Dashboard.git',
            ),
      issues: const <LocalGitObservationIssue>[],
    ),
    metadata: ProjectContextAssemblyMetadata(
      snapshotId: 'pcx-2026-08-08T12:00:00Z-$liveCommit',
      generatedAt: DateTime.parse('2026-08-08T12:00:00Z'),
      repositoryId: 'ellisp832019/New_Earth_Command_Dashboard',
      repositoryName: 'New Earth Command Dashboard',
      remoteIdentity: metadataRemoteIdentity,
      defaultBranch: 'main',
      protectedBranchCommit: liveCommit,
      ciRequiredChecks: ciRequiredChecks,
      ciRuns: ciRuns,
      dashboardVersion: '1.0.0+1',
      dashboardMaturity: 'beta',
      gaiaIntegrationVersion: '0.9.0',
      gaiaDependencyRef: '9bbfa978e7d5a1c2cb30be27128691ce187e758f',
      baselineTag: 'dashboard-controlled-baseline-2026-08-08',
      baselineCommit: '5e7ccbc7aa057dd393b72b4d19c8c6d48398ba8b',
      recordedManifestCommit: currentStateCommit,
      comparisonBase: 'origin/main',
      sourceAllowlist: const <String>[
        'git status',
        'git rev-parse HEAD',
        'git branch --show-current',
        'project_control/*.yaml',
      ],
      evidenceReferences: const <String>[
        'docs/project_control/evidence/2026-08-08/GAIA_V0_9_SLICE_D_CONTRACT_REPRESENTABILITY_REVIEW.md',
        'docs/project_control/evidence/2026-08-08/GAIA_V0_9_SLICE_D_PROJECT_CONTEXT_ASSEMBLER_ACCEPTANCE.md',
      ],
      baselineRecordedAt: DateTime.parse('2026-08-08T12:00:00Z'),
      liveStateLabel: 'read-only embedded operations workspace',
      notes: const <String>[
        'Project Context is assembled from live Git and recorded Project Control evidence.',
      ],
    ),
  );
}

project_control.ProjectControlContextBundle _bundle({
  required String canonicalCommit,
  required String canonicalBranch,
  required String currentStateCommit,
  required String currentStateBranch,
  required String repositoryHealthCommit,
  required String repositoryHealthBranch,
  required String verificationCommit,
}) {
  return project_control.ProjectControlContextBundle(
    canonical: project_control.ProjectControlCanonicalData(
      platformManifest: project_control.ProjectControlPlatformManifestRecord(
        schemaVersion: 1,
        platformId: 'new_earth_command_dashboard',
        platformName: 'New Earth Command Dashboard',
        description: 'Local-first dashboard',
        repositoryUrl:
            'https://github.com/ellisp832019/New_Earth_Command_Dashboard',
        repositoryRootHint: '.',
        currentBranch: canonicalBranch,
        currentCommit: canonicalCommit,
        applicationVersion: '1.0.0+1',
        platformMaturity: 'beta',
        supportedPlatforms: const <String>[
          'windows',
          'desktop',
          'local-development',
        ],
        primaryPlatform: 'windows',
        localFirst: true,
        dataOwnership: 'User-owned local data with repository-scoped storage.',
        telemetryPolicy: 'No telemetry by default.',
        cloudDependency: 'none',
        releasePolicy:
            'Internal release evidence required before any wider rollout.',
        defaultBranchPolicy:
            'feature branches merge through reviewed checkpoints.',
        canonicalDocumentation: const <String>[
          'docs/project_control/START_HERE.md',
          'docs/project_control/HOW_TO_USE_PROJECT_CONTROL.md',
        ],
        lastVerifiedCommit: canonicalCommit,
        lastVerifiedDate: '2026-08-08',
        lastVerifiedBuild: project_control.ProjectControlPlatformBuildRecord(
          windowsExecutable:
              'build/windows/x64/runner/Release/new_earth_command_dashboard.exe',
          sha256: 'ABC',
          sizeBytes: 123,
        ),
        lastScan: project_control.ProjectControlPlatformScanRecord(
          scanId: 'scan-1',
          date: '2026-08-08',
          commit: canonicalCommit,
        ),
        releaseReadiness: 'ready_with_conditions',
        knownLimitations: const <String>[
          'No live Git observation in this slice.',
        ],
      ),
      modules: <project_control.ProjectControlModuleRecord>[
        project_control.ProjectControlModuleRecord(
          id: 'dashboard',
          name: 'Dashboard',
          description: 'Primary command dashboard and navigation hub.',
          version: '1.0.0',
          maturity: 'beta',
          enabled: true,
          route: '/dashboard',
          sourcePaths: const <String>[
            'lib/features/dashboard/presentation/dashboard_screen.dart',
          ],
          documentationPaths: const <String>[
            'docs/fsd/04_screen_specification.md',
          ],
          testPaths: const <String>['test/widget_test.dart'],
          dataStorage: 'memory',
          dataOwner: 'dashboard-core',
          backupPolicy: 'repository backups only',
          exportPolicy: 'markdown and generated JSON summaries',
          securityLevel: 'internal',
          permissions: const <String>['read', 'navigate'],
          dependencies: const <String>['voice_intelligence'],
          knownRisks: const <String>['Large shared screen'],
          lastVerifiedCommit: canonicalCommit,
          lastVerifiedDate: '2026-08-08',
          verificationStatus: 'passed',
          documentationStatus: 'partial',
          recommendedNextAction:
              'Capture a future dashboard-specific smoke report.',
          owner: 'Dashboard team',
          notes: 'Core landing surface.',
        ),
      ],
      dependencyMap: project_control.ProjectControlDependencyMapRecord(
        schemaVersion: 1,
        moduleDependencies:
            <project_control.ProjectControlModuleDependencyRecord>[
              project_control.ProjectControlModuleDependencyRecord(
                module: 'dashboard',
                dependsOn: const <String>['voice_intelligence'],
              ),
            ],
        sharedServiceDependencies:
            <project_control.ProjectControlServiceDependencyRecord>[
              project_control.ProjectControlServiceDependencyRecord(
                service: 'window_manager',
                usedBy: const <String>['dashboard'],
              ),
            ],
        databaseDependencies:
            const <project_control.ProjectControlDatabaseDependencyRecord>[],
        fileSystemDependencies:
            const <project_control.ProjectControlFileSystemDependencyRecord>[],
        voiceDependencies:
            const <project_control.ProjectControlModuleDependencyRecord>[],
        hardwareDependencies:
            const <project_control.ProjectControlModuleDependencyRecord>[],
        windowsOnlyDependencies:
            const <project_control.ProjectControlModuleDependencyRecord>[],
        optionalDependencies:
            const <project_control.ProjectControlModuleDependencyRecord>[],
        blockingDependencies:
            const <project_control.ProjectControlBlockingDependencyRecord>[],
        observations: const <String>[
          'Repository intelligence work should stay repository-relative.',
        ],
      ),
      releases: <project_control.ProjectControlReleaseRecord>[
        project_control.ProjectControlReleaseRecord(
          releaseId: 'RLS-001',
          version: '1.0.0+1',
          maturity: 'beta',
          commit: canonicalCommit,
          tag: '',
          status: 'unverified_historical',
          includedModules: const <String>['dashboard'],
          verificationIds: const <String>['V-010'],
          knownRisks: const <String>[
            'Project control CLI still under construction',
          ],
          buildArtifacts: const <String>[
            'build/windows/x64/runner/Release/new_earth_command_dashboard.exe',
          ],
          releaseDate: '2026-08-08',
          notes: 'Test fixture release record.',
        ),
      ],
      risks: <project_control.ProjectControlRiskRecord>[
        project_control.ProjectControlRiskRecord(
          riskId: 'R-003',
          title: 'Missing or incomplete CI',
          severity: 'P1',
          likelihood: 'medium',
          affectedModules: const <String>['project_control', 'release'],
          description:
              'The repository needs explicit CI evidence before a release candidate is trusted.',
          evidence: const <String>[
            'docs/project_control/evidence/2026-08-08/CI_REMOTE_VERIFICATION.md',
          ],
          mitigation: 'Keep the verified GitHub Actions checks green.',
          owner: 'Platform team',
          status: 'resolved',
          targetRelease: 'project_control_cli_baseline',
          createdDate: '2026-08-06',
          lastReviewedDate: '2026-08-08',
        ),
      ],
      verification: <project_control.ProjectControlVerificationRecord>[
        project_control.ProjectControlVerificationRecord(
          verificationId: 'V-010',
          scope: 'Slice B adapter validation',
          commit: verificationCommit,
          branch: canonicalBranch,
          environment: 'local Windows development machine',
          commands: const <String>['flutter test'],
          result: 'passed',
          warnings: const <String>[],
          evidencePaths: const <String>[
            'docs/project_control/evidence/2026-08-08/GAIA_V0_9_SLICE_B_PROJECT_CONTROL_CONTEXT_ADAPTER_ACCEPTANCE.md',
          ],
          buildArtifacts: const <String>[],
          buildHashes: const <String>[],
          date: '2026-08-08',
          limitations: const <String>['Adapter slice only'],
        ),
      ],
      statusDefinitions: project_control.ProjectControlStatusDefinitionsRecord(
        schemaVersion: 1,
        moduleMaturityValues:
            const <project_control.ProjectControlStatusDefinitionRecord>[
              project_control.ProjectControlStatusDefinitionRecord(
                value: 'beta',
                definition: 'Broad workflows work and are tested.',
              ),
            ],
        verificationStates:
            const <project_control.ProjectControlStatusDefinitionRecord>[
              project_control.ProjectControlStatusDefinitionRecord(
                value: 'passed',
                definition: 'Verification passed.',
              ),
            ],
        documentationStates:
            const <project_control.ProjectControlStatusDefinitionRecord>[
              project_control.ProjectControlStatusDefinitionRecord(
                value: 'partial',
                definition: 'Documentation coverage is incomplete.',
              ),
            ],
        releaseReadinessStates:
            const <project_control.ProjectControlStatusDefinitionRecord>[
              project_control.ProjectControlStatusDefinitionRecord(
                value: 'ready_with_conditions',
                definition:
                    'Usable internally with documented conditions and risks.',
              ),
            ],
        riskSeverities:
            const <project_control.ProjectControlStatusDefinitionRecord>[
              project_control.ProjectControlStatusDefinitionRecord(
                value: 'P1',
                definition: 'High-priority issue.',
              ),
            ],
        riskStatusValues:
            const <project_control.ProjectControlStatusDefinitionRecord>[
              project_control.ProjectControlStatusDefinitionRecord(
                value: 'resolved',
                definition: 'Evidence shows the risk has been addressed.',
              ),
            ],
      ),
      architectureBoundaries: project_control.ProjectControlArchitectureBoundariesRecord(
        schemaVersion: 1,
        layers: const <String>[
          'presentation',
          'application',
          'domain',
          'data',
          'infrastructure',
        ],
        rules: const <String>[
          'Presentation may depend on application and domain contracts.',
          'Generated reports must not become canonical source records.',
        ],
        observations:
            const <
              project_control.ProjectControlArchitectureBoundaryObservationRecord
            >[
              project_control.ProjectControlArchitectureBoundaryObservationRecord(
                module: 'repo_intelligence_bridge',
                issue:
                    'Touches repository paths and should remain repository-relative.',
              ),
            ],
      ),
    ),
    generated: project_control.ProjectControlGeneratedEvidence(
      currentState: project_control.ProjectControlCurrentStateRecord(
        applicationVersion: '1.0.0+1',
        branch: currentStateBranch,
        ciStatus: 'present',
        commit: currentStateCommit,
        databaseSchemaVersion: '16',
        documentationCounts:
            project_control.ProjectControlDocumentationCountsRecord(
              missing: 2,
              partial: 31,
            ),
        documentationFilesFound: const <String>['docs/README.md'],
      ),
      repositoryHealth: project_control.ProjectControlRepositoryHealthRecord(
        branch: repositoryHealthBranch,
        commit: repositoryHealthCommit,
        riskTotals: project_control.ProjectControlRepositoryRiskTotalsRecord(
          bySeverity: const <String, int>{'P1': 1},
          byStatus: const <String, int>{'resolved': 1},
          total: 1,
        ),
        warnings: const <String>['Working tree is clean.'],
        workingTreeState: 'clean',
        scanId: 'scan-1',
      ),
      releaseReadiness: project_control.ProjectControlReleaseReadinessRecord(
        reasons: const <String>['All required gates are satisfied.'],
        result: 'ready_with_conditions',
      ),
    ),
    sourceInventory: project_control.ProjectControlSourceInventory(<
      project_control.ProjectControlSourceDescriptor
    >[
      project_control.ProjectControlSourceDescriptor(
        relativePath: 'project_control/platform_manifest.yaml',
        kind: project_control.ProjectControlSourceKind.canonical,
      ),
      project_control.ProjectControlSourceDescriptor(
        relativePath: 'project_control/generated/current_state.json',
        kind: project_control.ProjectControlSourceKind.historicalEvidence,
      ),
      project_control.ProjectControlSourceDescriptor(
        relativePath:
            'docs/project_control/evidence/2026-08-08/GAIA_V0_9_SLICE_D_PROJECT_CONTEXT_ASSEMBLER_ACCEPTANCE.md',
        kind: project_control.ProjectControlSourceKind.historicalEvidence,
      ),
    ]),
  );
}

Map<String, dynamic> _jsonRoundTrip(Map<String, dynamic> json) {
  return jsonDecode(jsonEncode(json)) as Map<String, dynamic>;
}
