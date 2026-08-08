import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/gaia/domain/project_context.dart';

void main() {
  group('ProjectContextSnapshot', () {
    test('parses a minimal valid snapshot with empty arrays', () {
      final snapshot = ProjectContextParser().parse(
        _minimalSnapshotJson(includeOptionalFields: false),
      );

      expect(snapshot.contractVersion, 'v1');
      expect(snapshot.snapshotId, 'pcx-minimal');
      expect(snapshot.generatedAt, DateTime.parse('2026-08-08T12:00:00Z'));
      expect(snapshot.repository.protectedBranch.requiredChecks, isEmpty);
      expect(snapshot.ci.runs, isEmpty);
      expect(snapshot.releases.items, isEmpty);
      expect(snapshot.provenance.notes, isNull);
    });

    test('parses the approved example contract fixture', () {
      final examplePath = File(
        'docs/integrations/gaia/v0.9/contracts/project_context_v1.example.json',
      );
      final json =
          jsonDecode(examplePath.readAsStringSync()) as Map<String, dynamic>;

      final snapshot = ProjectContextParser().parse(json);

      expect(snapshot.contractVersion, 'v1');
      expect(snapshot.platform.dashboardVersion, '1.0.0+1');
      expect(
        snapshot.platform.gaiaDependencyRef,
        '9bbfa978e7d5a1c2cb30be27128691ce187e758f',
      );
      expect(snapshot.repository.dirtyState, ProjectContextDirtyState.clean);
      expect(snapshot.repository.protectedBranch.requiredChecks, [
        'Flutter Quality',
        'Project Control Validation',
        'Windows Release Build',
      ]);
      expect(snapshot.ci.runs, hasLength(3));
      expect(snapshot.ci.runs.first.name, 'Flutter Quality');
      expect(snapshot.releases.items.first.version, '1.0.0+1');
      expect(
        snapshot.dataQuality.status,
        ProjectContextDataQualityStatus.degraded,
      );
    });

    test('serializes deterministically and round-trips', () {
      final original = ProjectContextParser().parse(_minimalSnapshotJson());
      final encoded = original.toJson();
      final roundTrip = ProjectContextSnapshot.fromJson(
        jsonDecode(jsonEncode(encoded)) as Map<String, dynamic>,
      );

      expect(roundTrip.toJson(), encoded);
    });

    test('omits optional fields when they are not supplied', () {
      final snapshot = ProjectContextParser().parse(
        _minimalSnapshotJson(includeOptionalFields: false),
      );

      expect(snapshot.platform.liveStateLabel, isNull);
      expect(snapshot.baseline.recordedAt, isNull);
      expect(snapshot.modules.items.first.route, isNull);
      expect(snapshot.modules.items.first.knownRisks, isNull);
      expect(snapshot.verification.items.first.environment, isNull);
      expect(snapshot.verification.items.first.limitations, isNull);
      expect(snapshot.provenance.notes, isNull);

      final json = snapshot.toJson();
      expect(json['platform'], isA<Map<String, dynamic>>());
      expect(
        (json['platform'] as Map<String, dynamic>).containsKey(
          'liveStateLabel',
        ),
        isFalse,
      );
      expect(
        (json['baseline'] as Map<String, dynamic>).containsKey('recordedAt'),
        isFalse,
      );
      expect(
        (json['modules'] as Map<String, dynamic>)['items'],
        isA<List<dynamic>>(),
      );
      expect(
        ((json['modules'] as Map<String, dynamic>)['items'] as List<dynamic>)
            .first
            .containsKey('route'),
        isFalse,
      );
    });

    test('preserves immutability against external list mutation', () {
      final sourceChecks = <String>['Flutter Quality'];
      final branch = ProjectContextProtectedBranchContext(
        name: 'main',
        commit: 'abc123',
        requiredChecks: sourceChecks,
      );

      sourceChecks.add('Project Control Validation');

      expect(branch.requiredChecks, ['Flutter Quality']);
      expect(
        () => branch.requiredChecks.add('Windows Release Build'),
        throwsUnsupportedError,
      );
    });

    test('accepts contractVersion v1 and rejects v2', () {
      final snapshot = ProjectContextParser().parse(_minimalSnapshotJson());
      expect(snapshot.contractVersion, 'v1');

      expect(
        () => ProjectContextParser().parse(
          _minimalSnapshotJson(contractVersion: 'v2'),
        ),
        throwsA(
          isA<ProjectContextParseException>()
              .having((e) => e.path, 'path', r'$.contractVersion')
              .having(
                (e) => e.message,
                'message',
                contains('unsupported value'),
              ),
        ),
      );
    });

    test('rejects missing required top-level fields', () {
      final json = _minimalSnapshotJson()..remove('snapshotId');

      expect(
        () => ProjectContextParser().parse(json),
        throwsA(
          isA<ProjectContextParseException>()
              .having((e) => e.path, 'path', r'$.snapshotId')
              .having(
                (e) => e.message,
                'message',
                contains('required field missing'),
              ),
        ),
      );
    });

    test('rejects malformed date-time values', () {
      final json = _minimalSnapshotJson()..['generatedAt'] = 'not-a-date';

      expect(
        () => ProjectContextParser().parse(json),
        throwsA(
          isA<ProjectContextParseException>()
              .having((e) => e.path, 'path', r'$.generatedAt')
              .having(
                (e) => e.message,
                'message',
                contains('invalid date-time'),
              ),
        ),
      );
    });

    test('rejects unexpected top-level and nested properties', () {
      final topLevel = _minimalSnapshotJson()..['dangerousCommand'] = true;

      expect(
        () => ProjectContextParser().parse(topLevel),
        throwsA(
          isA<ProjectContextParseException>()
              .having((e) => e.path, 'path', r'$')
              .having(
                (e) => e.message,
                'message',
                contains('unexpected field'),
              ),
        ),
      );

      final nested = _minimalSnapshotJson();
      (nested['repository'] as Map<String, dynamic>)['dangerousCommand'] = true;

      expect(
        () => ProjectContextParser().parse(nested),
        throwsA(
          isA<ProjectContextParseException>()
              .having((e) => e.path, 'path', r'$.repository')
              .having(
                (e) => e.message,
                'message',
                contains('unexpected field'),
              ),
        ),
      );
    });

    test('rejects unsupported enum values and wrong types', () {
      final dirtyState = _minimalSnapshotJson();
      (dirtyState['repository'] as Map<String, dynamic>)['dirtyState'] =
          'maybe';
      expect(
        () => ProjectContextParser().parse(dirtyState),
        throwsA(
          isA<ProjectContextParseException>()
              .having((e) => e.path, 'path', r'$.repository.dirtyState')
              .having(
                (e) => e.message,
                'message',
                contains('unsupported value'),
              ),
        ),
      );

      final wrongArray = _minimalSnapshotJson();
      (wrongArray['modules'] as Map<String, dynamic>)['items'] = 'not-an-array';
      expect(
        () => ProjectContextParser().parse(wrongArray),
        throwsA(
          isA<ProjectContextParseException>()
              .having((e) => e.path, 'path', r'$.modules.items')
              .having((e) => e.message, 'message', contains('expected array')),
        ),
      );
    });

    test('rejects null and type mismatches on required fields', () {
      final nullString = _minimalSnapshotJson();
      (nullString['repository'] as Map<String, dynamic>)['repositoryName'] =
          null;

      expect(
        () => ProjectContextParser().parse(nullString),
        throwsA(
          isA<ProjectContextParseException>()
              .having((e) => e.path, 'path', r'$.repository.repositoryName')
              .having(
                (e) => e.message,
                'message',
                contains('required field missing'),
              ),
        ),
      );

      final wrongType = _minimalSnapshotJson();
      wrongType['snapshotId'] = 123;
      expect(
        () => ProjectContextParser().parse(wrongType),
        throwsA(
          isA<ProjectContextParseException>()
              .having((e) => e.path, 'path', r'$.snapshotId')
              .having((e) => e.message, 'message', contains('expected string')),
        ),
      );
    });
  });
}

Map<String, dynamic> _minimalSnapshotJson({
  String contractVersion = 'v1',
  bool includeOptionalFields = true,
}) {
  final repository = <String, dynamic>{
    'repositoryId': 'ellisp832019/New_Earth_Command_Dashboard',
    'repositoryName': 'New Earth Command Dashboard',
    'remoteIdentity': 'origin',
    'defaultBranch': 'main',
    'observedBranch': 'main',
    'observedCommit': 'a0880a136db7e9a6714e016d054e2a887e3f9475',
    'protectedBranch': <String, dynamic>{
      'name': 'main',
      'commit': 'a0880a136db7e9a6714e016d054e2a887e3f9475',
      'requiredChecks': <String>[],
    },
    'dirtyState': 'clean',
    'observedAt': '2026-08-08T12:00:00Z',
  };
  if (includeOptionalFields) {
    repository['aheadBehind'] = <String, dynamic>{'ahead': 0, 'behind': 0};
  }

  final platform = <String, dynamic>{
    'dashboardVersion': '1.0.0+1',
    'dashboardMaturity': 'beta',
    'gaiaIntegrationVersion': '0.7.0',
    'gaiaDependencyRef': '9bbfa978e7d5a1c2cb30be27128691ce187e758f',
  };
  if (includeOptionalFields) {
    platform['liveStateLabel'] = 'read-only embedded operations workspace';
  }

  final baseline = <String, dynamic>{
    'baselineTag': 'dashboard-controlled-baseline-2026-08-08',
    'baselineCommit': '5e7ccbc7aa057dd393b72b4d19c8c6d48398ba8b',
    'recordedManifestCommit': '26bbb9c717ac3c752bc0ea9723a6874aecd3326d',
    'comparisonBase': 'origin/main',
    'historicalOnly': true,
  };
  if (includeOptionalFields) {
    baseline['recordedAt'] = '2026-08-08T12:00:00Z';
  }

  final modulesItem = <String, dynamic>{
    'moduleId': 'gaia_employee_surface',
    'name': 'GAIA AI Employee',
    'version': '0.7.0',
    'maturity': 'beta',
    'verificationStatus': 'passed',
    'documentationStatus': 'partial',
    'lastVerifiedCommit': '9bbfa978e7d5a1c2cb30be27128691ce187e758f',
    'dependencies': <String>[
      'gaia_integration_client',
      'gaia_dashboard_module',
    ],
  };
  if (includeOptionalFields) {
    modulesItem['route'] = '/more/ai-employee';
    modulesItem['knownRisks'] = <String>[
      'Read-only boundary must remain intact.',
    ];
  }

  final verificationItem = <String, dynamic>{
    'verificationId': 'V-009',
    'scope': 'CI remote verification on latest PR head',
    'commit': '2344b1a25f6fd57d46d5cad09b55b4042e807191',
    'branch': 'ci/dashboard-github-actions-and-branch-controls-2026-08-07',
    'result': 'passed',
    'date': '2026-08-08',
    'evidencePaths': <String>[
      'docs/project_control/evidence/2026-08-08/CI_REMOTE_VERIFICATION.md',
      'docs/project_control/evidence/2026-08-08/BRANCH_CONTROL_REVIEW.md',
    ],
  };
  if (includeOptionalFields) {
    verificationItem['environment'] = 'GitHub Actions / PR #7';
    verificationItem['limitations'] = <String>[
      'GitHub verification records CI checks only.',
    ];
  }

  final provenance = <String, dynamic>{
    'sourceAllowlist': <String>[
      'git status',
      'git rev-parse HEAD',
      'git branch --show-current',
    ],
    'evidenceReferences': <String>[
      'docs/project_control/evidence/2026-08-08/SOURCE_OF_TRUTH_VERSION_RECONCILIATION.md',
    ],
  };
  if (includeOptionalFields) {
    provenance['notes'] = <String>[
      'This example illustrates distinct live and recorded state.',
    ];
  }

  return <String, dynamic>{
    'contractVersion': contractVersion,
    'snapshotId': 'pcx-minimal',
    'generatedAt': '2026-08-08T12:00:00Z',
    'repository': repository,
    'platform': platform,
    'baseline': baseline,
    'releaseReadiness': <String, dynamic>{
      'status': 'ready',
      'reasons': <String>[],
    },
    'repositoryHealth': <String, dynamic>{
      'status': 'good',
      'workingTreeState': 'clean',
      'warnings': <String>[],
    },
    'risks': <String, dynamic>{'items': <Map<String, dynamic>>[]},
    'modules': <String, dynamic>{
      'items': <Map<String, dynamic>>[modulesItem],
    },
    'dependencies': <String, dynamic>{
      'moduleDependencies': <Map<String, dynamic>>[],
      'sharedServices': <Map<String, dynamic>>[],
    },
    'verification': <String, dynamic>{
      'items': <Map<String, dynamic>>[verificationItem],
    },
    'ci': <String, dynamic>{
      'observedHead': 'a0880a136db7e9a6714e016d054e2a887e3f9475',
      'requiredChecks': <String>['Flutter Quality'],
      'runs': <Map<String, dynamic>>[],
    },
    'releases': <String, dynamic>{'items': <Map<String, dynamic>>[]},
    'dataQuality': <String, dynamic>{
      'status': 'good',
      'warnings': <String>[],
      'staleFields': <String>[],
      'missingFields': <String>[],
    },
    'provenance': provenance,
  };
}
