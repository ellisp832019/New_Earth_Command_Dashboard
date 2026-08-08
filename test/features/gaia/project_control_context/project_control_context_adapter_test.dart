import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/features/gaia/data/project_control_context_adapter.dart';
import 'package:new_earth_command_dashboard/features/gaia/data/project_control_context_models.dart';

void main() {
  group('ProjectControlContextAdapter', () {
    test(
      'loads canonical registries and generated evidence from allowlisted sources',
      () async {
        final root = await _createFixtureRepository();
        addTearDown(() => root.delete(recursive: true));

        final bundle = await ProjectControlContextAdapter(
          repositoryRoot: root,
        ).load();

        expect(
          bundle.canonical.platformManifest.platformName,
          'New Earth Command Dashboard',
        );
        expect(
          bundle.canonical.platformManifest.currentBranch,
          'feature/gaia-v0.9-project-control-context-adapter-2026-08-08',
        );
        expect(bundle.canonical.modules, hasLength(1));
        expect(bundle.canonical.modules.single.id, 'dashboard');
        expect(
          bundle
              .canonical
              .dependencyMap
              .sharedServiceDependencies
              .single
              .service,
          'window_manager',
        );
        expect(bundle.canonical.releases.single.releaseId, 'RLS-001');
        expect(bundle.canonical.risks.single.riskId, 'R-003');
        expect(bundle.canonical.verification.single.verificationId, 'V-010');
        expect(bundle.generated.currentState.branch, 'historic-branch');
        expect(bundle.generated.repositoryHealth.commit, 'deadbeef');
        expect(
          bundle.generated.releaseReadiness.result,
          'ready_with_conditions',
        );
        expect(
          bundle.sourceInventory.sourcesOfKind(
            ProjectControlSourceKind.canonical,
          ),
          hasLength(8),
        );
        expect(
          bundle.sourceInventory.sourcesOfKind(
            ProjectControlSourceKind.derived,
          ),
          hasLength(2),
        );
        expect(
          bundle.sourceInventory.sourcesOfKind(
            ProjectControlSourceKind.historicalEvidence,
          ),
          hasLength(1),
        );
      },
    );

    test(
      'keeps generated repository health as recorded evidence, not live git truth',
      () async {
        final root = await _createFixtureRepository(
          repositoryHealthBranch: 'integration/recorded-snapshot',
          repositoryHealthCommit: 'recorded-commit',
        );
        addTearDown(() => root.delete(recursive: true));

        final bundle = await ProjectControlContextAdapter(
          repositoryRoot: root,
        ).load();

        expect(
          bundle.generated.repositoryHealth.branch,
          'integration/recorded-snapshot',
        );
        expect(bundle.generated.repositoryHealth.commit, 'recorded-commit');
        expect(bundle.generated.currentState.commit, 'historic-commit');
        expect(bundle.generated.currentState.branch, 'historic-branch');
        expect(
          bundle.canonical.platformManifest.currentBranch,
          'feature/gaia-v0.9-project-control-context-adapter-2026-08-08',
        );
      },
    );

    test('rejects missing allowlisted sources explicitly', () async {
      final root = await _createFixtureRepository(
        includeReleaseReadiness: false,
      );
      addTearDown(() => root.delete(recursive: true));

      final adapter = ProjectControlContextAdapter(repositoryRoot: root);

      expect(
        adapter.load(),
        throwsA(
          isA<ProjectControlContextAdapterException>().having(
            (error) => error.sourcePath,
            'sourcePath',
            'project_control/generated/release_readiness.json',
          ),
        ),
      );
    });

    test('rejects malformed allowlisted sources explicitly', () async {
      final root = await _createFixtureRepository(
        corruptVerificationRegistry: true,
      );
      addTearDown(() => root.delete(recursive: true));

      final adapter = ProjectControlContextAdapter(repositoryRoot: root);

      expect(
        adapter.load(),
        throwsA(isA<ProjectControlContextAdapterException>()),
      );
    });

    test('exposes read-only collections', () async {
      final root = await _createFixtureRepository();
      addTearDown(() => root.delete(recursive: true));

      final bundle = await ProjectControlContextAdapter(
        repositoryRoot: root,
      ).load();

      expect(
        () => bundle.canonical.modules.add(bundle.canonical.modules.first),
        throwsUnsupportedError,
      );
      expect(
        () => bundle.generated.releaseReadiness.reasons.add('new reason'),
        throwsUnsupportedError,
      );
    });
  });
}

Future<Directory> _createFixtureRepository({
  bool includeReleaseReadiness = true,
  bool corruptVerificationRegistry = false,
  String repositoryHealthBranch = 'integration/stale-baseline',
  String repositoryHealthCommit = 'deadbeef',
}) async {
  final root = await Directory.systemTemp.createTemp(
    'project_control_context_adapter_',
  );
  await _writeJsonFile(
    root,
    'project_control/platform_manifest.yaml',
    <String, dynamic>{
      'schema_version': 1,
      'platform_id': 'new_earth_command_dashboard',
      'platform_name': 'New Earth Command Dashboard',
      'description': 'Local-first dashboard',
      'repository_url':
          'https://github.com/ellisp832019/New_Earth_Command_Dashboard',
      'repository_root_hint': '.',
      'current_branch':
          'feature/gaia-v0.9-project-control-context-adapter-2026-08-08',
      'current_commit': '7b7f4fc485a505117c4b4911b7a30edc5498bf8d',
      'application_version': '1.0.0+1',
      'platform_maturity': 'beta',
      'supported_platforms': ['windows', 'desktop', 'local-development'],
      'primary_platform': 'windows',
      'local_first': true,
      'data_ownership': 'User-owned local data with repository-scoped storage.',
      'telemetry_policy': 'No telemetry by default.',
      'cloud_dependency': 'none',
      'release_policy':
          'Internal release evidence required before any wider rollout.',
      'default_branch_policy':
          'feature branches merge through reviewed checkpoints.',
      'canonical_documentation': <String>[
        'docs/project_control/START_HERE.md',
        'docs/project_control/HOW_TO_USE_PROJECT_CONTROL.md',
      ],
      'last_verified_commit': '7b7f4fc485a505117c4b4911b7a30edc5498bf8d',
      'last_verified_date': '2026-08-08',
      'last_verified_build': <String, dynamic>{
        'windows_executable':
            'build/windows/x64/runner/Release/new_earth_command_dashboard.exe',
        'sha256': 'ABC',
        'size_bytes': 123,
      },
      'last_scan': <String, dynamic>{
        'scan_id': 'scan-1',
        'date': '2026-08-08',
        'commit': '7b7f4fc485a505117c4b4911b7a30edc5498bf8d',
      },
      'release_readiness': 'ready_with_conditions',
      'known_limitations': <String>['No live Git observation in Slice B.'],
    },
  );
  await _writeJsonFile(
    root,
    'project_control/module_registry.yaml',
    <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'dashboard',
        'name': 'Dashboard',
        'description': 'Primary command dashboard and navigation hub.',
        'version': '1.0.0',
        'maturity': 'beta',
        'enabled': true,
        'route': '/dashboard',
        'source_paths': <String>[
          'lib/features/dashboard/presentation/dashboard_screen.dart',
        ],
        'documentation_paths': <String>['docs/fsd/04_screen_specification.md'],
        'test_paths': <String>['test/widget_test.dart'],
        'data_storage': 'memory',
        'data_owner': 'dashboard-core',
        'backup_policy': 'repository backups only',
        'export_policy': 'markdown and generated JSON summaries',
        'security_level': 'internal',
        'permissions': <String>['read', 'navigate'],
        'dependencies': <String>['voice_intelligence'],
        'known_risks': <String>['Large shared screen'],
        'last_verified_commit': '7b7f4fc485a505117c4b4911b7a30edc5498bf8d',
        'last_verified_date': '2026-08-08',
        'verification_status': 'passed',
        'documentation_status': 'partial',
        'recommended_next_action':
            'Capture a future dashboard-specific smoke report.',
        'owner': 'Dashboard team',
        'notes': 'Core landing surface.',
      },
    ],
  );
  await _writeJsonFile(
    root,
    'project_control/dependency_map.yaml',
    <String, dynamic>{
      'schema_version': 1,
      'module_dependencies': <Map<String, dynamic>>[
        <String, dynamic>{
          'module': 'dashboard',
          'depends_on': <String>['voice_intelligence'],
        },
      ],
      'shared_service_dependencies': <Map<String, dynamic>>[
        <String, dynamic>{
          'service': 'window_manager',
          'used_by': <String>['dashboard'],
        },
      ],
      'database_dependencies': <Map<String, dynamic>>[],
      'file_system_dependencies': <Map<String, dynamic>>[],
      'voice_dependencies': <Map<String, dynamic>>[],
      'hardware_dependencies': <Map<String, dynamic>>[],
      'windows_only_dependencies': <Map<String, dynamic>>[],
      'optional_dependencies': <Map<String, dynamic>>[],
      'blocking_dependencies': <Map<String, dynamic>>[],
      'observations': <String>[
        'Repository intelligence work should stay repository-relative.',
      ],
    },
  );
  await _writeJsonFile(
    root,
    'project_control/release_registry.yaml',
    <Map<String, dynamic>>[
      <String, dynamic>{
        'release_id': 'RLS-001',
        'version': '1.0.0+1',
        'maturity': 'beta',
        'commit': '7b7f4fc485a505117c4b4911b7a30edc5498bf8d',
        'tag': '',
        'status': 'unverified_historical',
        'included_modules': <String>['dashboard'],
        'verification_ids': <String>['V-010'],
        'known_risks': <String>['Project control CLI still under construction'],
        'build_artifacts': <String>[
          'build/windows/x64/runner/Release/new_earth_command_dashboard.exe',
        ],
        'release_date': '2026-08-08',
        'notes': 'Test fixture release record.',
      },
    ],
  );
  await _writeJsonFile(root, 'project_control/risk_register.yaml', <
    Map<String, dynamic>
  >[
    <String, dynamic>{
      'risk_id': 'R-003',
      'title': 'Missing or incomplete CI',
      'severity': 'P1',
      'likelihood': 'medium',
      'affected_modules': <String>['project_control', 'release'],
      'description':
          'The repository needs explicit CI evidence before a release candidate is trusted.',
      'evidence': <String>[
        'docs/project_control/evidence/2026-08-08/CI_REMOTE_VERIFICATION.md',
      ],
      'mitigation': 'Keep the verified GitHub Actions checks green.',
      'owner': 'Platform team',
      'status': 'resolved',
      'target_release': 'project_control_cli_baseline',
      'created_date': '2026-08-06',
      'last_reviewed_date': '2026-08-08',
    },
  ]);
  await _writeJsonFile(root, 'project_control/verification_registry.yaml', <
    Map<String, dynamic>
  >[
    <String, dynamic>{
      'verification_id': 'V-010',
      'scope': 'Slice B adapter validation',
      'commit': '7b7f4fc485a505117c4b4911b7a30edc5498bf8d',
      'branch': 'feature/gaia-v0.9-project-control-context-adapter-2026-08-08',
      'environment': 'local Windows development machine',
      'commands': <String>['flutter test'],
      'result': 'passed',
      'warnings': <String>[],
      'evidence_paths': <String>[
        'docs/project_control/evidence/2026-08-08/GAIA_V0_9_SLICE_B_PROJECT_CONTROL_CONTEXT_ADAPTER_ACCEPTANCE.md',
      ],
      'build_artifacts': <String>[],
      'build_hashes': <String>[],
      'date': '2026-08-08',
      'limitations': <String>['Adapter slice only'],
    },
  ]);
  await _writeJsonFile(
    root,
    'project_control/status_definitions.yaml',
    <String, dynamic>{
      'schema_version': 1,
      'module_maturity_values': <Map<String, dynamic>>[
        <String, dynamic>{
          'value': 'beta',
          'definition': 'Broad workflows work and are tested.',
        },
      ],
      'verification_states': <Map<String, dynamic>>[
        <String, dynamic>{
          'value': 'passed',
          'definition': 'Verification passed.',
        },
      ],
      'documentation_states': <Map<String, dynamic>>[
        <String, dynamic>{
          'value': 'partial',
          'definition': 'Documentation coverage is incomplete.',
        },
      ],
      'release_readiness_states': <Map<String, dynamic>>[
        <String, dynamic>{
          'value': 'ready_with_conditions',
          'definition':
              'Usable internally with documented conditions and risks.',
        },
      ],
      'risk_severities': <Map<String, dynamic>>[
        <String, dynamic>{'value': 'P1', 'definition': 'High-priority issue.'},
      ],
      'risk_status_values': <Map<String, dynamic>>[
        <String, dynamic>{
          'value': 'resolved',
          'definition': 'Evidence shows the risk has been addressed.',
        },
      ],
    },
  );
  await _writeJsonFile(
    root,
    'project_control/architecture_boundaries.yaml',
    <String, dynamic>{
      'schema_version': 1,
      'layers': <String>[
        'presentation',
        'application',
        'domain',
        'data',
        'infrastructure',
      ],
      'rules': <String>[
        'Presentation may depend on application and domain contracts.',
        'Generated reports must not become canonical source records.',
      ],
      'observations': <Map<String, dynamic>>[
        <String, dynamic>{
          'module': 'repo_intelligence_bridge',
          'issue':
              'Touches repository paths and should remain repository-relative.',
        },
      ],
    },
  );
  await _writeJsonFile(
    root,
    'project_control/generated/current_state.json',
    <String, dynamic>{
      'application_version': '1.0.0+1',
      'branch': 'historic-branch',
      'ci_status': 'present',
      'commit': 'historic-commit',
      'database_schema_version': '16',
      'documentation_counts': <String, dynamic>{'missing': 2, 'partial': 31},
      'documentation_files_found': <String>['docs/README.md'],
    },
  );
  if (includeReleaseReadiness) {
    await _writeJsonFile(
      root,
      'project_control/generated/release_readiness.json',
      <String, dynamic>{
        'reasons': <String>['All required gates are satisfied.'],
        'result': 'ready_with_conditions',
      },
    );
  }
  await _writeJsonFile(
    root,
    'project_control/generated/repository_health.json',
    <String, dynamic>{
      'branch': repositoryHealthBranch,
      'commit': repositoryHealthCommit,
      'risk_totals': <String, dynamic>{
        'by_severity': <String, dynamic>{'P1': 1},
        'by_status': <String, dynamic>{'resolved': 1},
        'total': 1,
      },
      'warnings': <String>['Working tree is dirty.'],
      'working_tree_state': 'dirty',
      'scan_id': 'scan-1',
    },
  );
  if (corruptVerificationRegistry) {
    final file = File(
      path.join(root.path, 'project_control', 'verification_registry.yaml'),
    );
    await file.writeAsString('{ not valid json }', flush: true);
  }
  return root;
}

Future<void> _writeJsonFile(
  Directory root,
  String relativePath,
  Object json,
) async {
  final file = File(path.join(root.path, relativePath));
  await file.parent.create(recursive: true);
  await file.writeAsString(jsonEncode(json), flush: true);
}
