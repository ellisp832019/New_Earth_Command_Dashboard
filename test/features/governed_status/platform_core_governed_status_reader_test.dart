import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/governed_status/data/platform_core_governed_status_reader.dart';
import 'package:new_earth_command_dashboard/features/governed_status/domain/governed_status.dart';

void main() {
  final scope = GovernedStatusScope(
    canonicalId: 'new-earth-command-dashboard',
    displayName: 'New Earth Command Dashboard',
  );
  final retrievedAt = DateTime.utc(2026, 8, 24, 10, 30);

  Future<GovernedStatusEnvelope> readPayload(
    PlatformCoreDeclarationPayload payload,
  ) {
    return PlatformCoreGovernedStatusReader(
      _FakeSource(payload),
    ).load(scope: scope);
  }

  test('maps the canonical Platform Core declaration', () async {
    final source = _FakeSource(_payload());
    final envelope = await PlatformCoreGovernedStatusReader(
      source,
    ).load(scope: scope);
    final declared = envelope.records.single.declared!;

    expect(declared.canonicalId, scope.canonicalId);
    expect(declared.displayName, 'New Earth Command Dashboard');
    expect(declared.systemType, 'operations-dashboard');
    expect(declared.owner, 'New Earth Advanced Technologies Ltd');
    expect(declared.lifecycle, 'active');
    expect(declared.repository, 'New_Earth_Command_Dashboard');
    expect(declared.interfaces, ['command-dashboard-views']);
    expect(declared.dependencies, ['command-centre-ui', 'neos-status-api']);
    expect(declared.contractVersion, '1.0');
  });

  test(
    'preserves Platform Core metadata and leaves other layers absent',
    () async {
      final envelope = await PlatformCoreGovernedStatusReader(
        _FakeSource(_payload()),
      ).load(scope: scope);
      final metadata = envelope.sourceMetadata.single;

      expect(metadata.source, GovernedStatusSource.platformCore);
      expect(metadata.authority, GovernedStatusAuthority.platformCore);
      expect(metadata.schemaVersion, '1.0');
      expect(metadata.retrievedAt, retrievedAt);
      expect(metadata.observedAt, isNull);
      expect(metadata.provenanceReferences, [
        'registry:projects',
        'revision:abc',
      ]);
      expect(envelope.contractVersion, GovernedStatusContract.version);
      expect(envelope.records.single.observed, isNull);
      expect(envelope.records.single.interpreted, isNull);
      expect(envelope.records.single.local, isNull);
      expect(envelope.records.single.approval, HumanApprovalState.unknown);
      expect(envelope.sourceFailures, isEmpty);
    },
  );

  test('receives the requested scope and calls source once', () async {
    final source = _FakeSource(_payload());
    await PlatformCoreGovernedStatusReader(source).load(scope: scope);
    expect(source.calls, 1);
    expect(source.receivedScope, scope);
  });

  test(
    'selects only the requested project from unrelated registry entries',
    () async {
      final payload = _payload(
        registryProjects: [
          _registryProject(),
          _registryProject(id: 'other-project', name: 'Other Project'),
        ],
      );
      final envelope = await PlatformCoreGovernedStatusReader(
        _FakeSource(payload),
      ).load(scope: scope);
      expect(envelope.records, hasLength(1));
      expect(envelope.records.single.scope, scope);
    },
  );

  test(
    'reports missing, duplicate, and mismatched projects deterministically',
    () async {
      final missing = await readPayload(
        _payload(registryProjects: [_registryProject(id: 'other-project')]),
      );
      expect(missing.records, isEmpty);
      expect(
        missing.sourceFailures.single.category,
        GovernedStatusFailureCategory.unsupportedScope,
      );
      expect(
        missing.sourceFailures.single.description,
        'platform_core_project_not_found',
      );

      final duplicate = await readPayload(
        _payload(registryProjects: [_registryProject(), _registryProject()]),
      );
      expect(duplicate.records, isEmpty);
      expect(
        duplicate.sourceFailures.single.description,
        'platform_core_duplicate_project_id',
      );

      final mismatch = await readPayload(
        _payload(contractProjectId: 'different-project'),
      );
      expect(mismatch.records, isEmpty);
      expect(
        mismatch.sourceFailures.single.category,
        GovernedStatusFailureCategory.scopeMismatch,
      );
    },
  );

  test(
    'reports malformed roots, required fields, and unsupported versions',
    () async {
      final malformed = await readPayload(
        _payload(registryDocument: 'not-a-map'),
      );
      expect(
        malformed.sourceFailures.single.description,
        'platform_core_invalid_declaration',
      );

      final missingId = await readPayload(
        _payload(contractProject: {..._project(), 'id': null}),
      );
      expect(
        missingId.sourceFailures.single.description,
        'platform_core_invalid_declaration',
      );

      final unsupported = await readPayload(_payload(schemaVersion: '2.0'));
      expect(
        unsupported.sourceFailures.single.description,
        'platform_core_unsupported_schema_version',
      );
    },
  );

  test(
    'reports unavailable source without fabricating a declaration',
    () async {
      final envelope = await PlatformCoreGovernedStatusReader(
        _FakeSource(null),
      ).load(scope: scope);
      expect(envelope.records, isEmpty);
      expect(
        envelope.sourceFailures.single.category,
        GovernedStatusFailureCategory.unavailable,
      );
      expect(
        envelope.sourceFailures.single.description,
        'platform_core_payload_unavailable',
      );
    },
  );

  test(
    'unknown compatible fields are ignored and optional fields stay absent',
    () async {
      final payload = _payload(
        contract: {
          ..._contract(),
          'unknown_future_field': {'safe': true},
          'provides': <String>[],
          'consumes': <String>[],
        },
      );
      final declared = (await readPayload(payload)).records.single.declared!;
      expect(declared.interfaces, isEmpty);
      expect(declared.dependencies, isEmpty);
      expect(declared.compatibility, isEmpty);
      expect(declared.classifications, isEmpty);
      expect(declared.plannedExtractions, isEmpty);
    },
  );

  test(
    'sorts non-authoritative interface and dependency collections',
    () async {
      final declared = (await readPayload(
        _payload(
          contract: {
            ..._contract(),
            'provides': ['z-interface', 'a-interface'],
            'consumes': ['z-dependency', 'a-dependency'],
          },
        ),
      )).records.single.declared!;
      expect(declared.interfaces, ['a-interface', 'z-interface']);
      expect(declared.dependencies, ['a-dependency', 'z-dependency']);
    },
  );

  test('rejects unsafe provenance without exposing a path', () async {
    final envelope = await readPayload(
      _payload(provenanceReferences: [r'C:\Users\secret\registry.yaml']),
    );
    expect(envelope.records, isEmpty);
    expect(
      envelope.sourceFailures.single.description,
      'platform_core_invalid_declaration',
    );
  });

  test(
    'rejects conflicting registry and contract metadata without precedence',
    () async {
      final envelope = await readPayload(
        _payload(
          registryProject: {
            ..._registryProject(),
            'name': 'Conflicting Registry Name',
          },
        ),
      );
      expect(envelope.records, isEmpty);
      expect(
        envelope.sourceFailures.single.category,
        GovernedStatusFailureCategory.scopeMismatch,
      );
    },
  );

  test('returned collections are immutable', () async {
    final envelope = await readPayload(_payload());
    expect(
      () => envelope.records.add(GovernedStatusRecord(scope: scope)),
      throwsUnsupportedError,
    );
    expect(
      () => envelope.records.single.declared!.interfaces.add('x'),
      throwsUnsupportedError,
    );
  });

  test('source failure does not expose raw exception details', () async {
    final envelope = await PlatformCoreGovernedStatusReader(
      _ThrowingSource(),
    ).load(scope: scope);
    final failure = envelope.sourceFailures.single;
    expect(failure.description, 'platform_core_source_unavailable');
    expect(failure.description, isNot(contains('secret')));
    expect(failure.description, isNot(contains('stack')));
  });
}

class _FakeSource implements PlatformCoreDeclarationSource {
  _FakeSource(this.payload);

  final PlatformCoreDeclarationPayload? payload;
  int calls = 0;
  GovernedStatusScope? receivedScope;

  @override
  Future<PlatformCoreDeclarationPayload?> read({
    required GovernedStatusScope scope,
  }) async {
    calls++;
    receivedScope = scope;
    return payload;
  }
}

class _ThrowingSource implements PlatformCoreDeclarationSource {
  @override
  Future<PlatformCoreDeclarationPayload?> read({
    required GovernedStatusScope scope,
  }) async {
    throw StateError('secret stack details');
  }
}

PlatformCoreDeclarationPayload _payload({
  Object? registryDocument,
  Object? contract,
  Object? registryProjects,
  Map<String, dynamic>? registryProject,
  String schemaVersion = '1.0',
  String? contractProjectId,
  Map<String, dynamic>? contractProject,
  List<String> provenanceReferences = const [
    'registry:projects',
    'revision:abc',
  ],
}) {
  return PlatformCoreDeclarationPayload(
    registryDocument:
        registryDocument ??
        {
          'registry_version': schemaVersion,
          'projects':
              registryProjects ?? [registryProject ?? _registryProject()],
        },
    projectContractDocument:
        contract ??
        {
          ..._contract(),
          'project':
              contractProject ??
              _project(id: contractProjectId ?? 'new-earth-command-dashboard'),
        },
    schemaVersion: schemaVersion,
    retrievedAt: DateTime.utc(2026, 8, 24, 10, 30),
    provenanceReferences: provenanceReferences,
  );
}

Map<String, dynamic> _registryProject({
  String id = 'new-earth-command-dashboard',
  String name = 'New Earth Command Dashboard',
}) {
  return {
    'id': id,
    'name': name,
    'family': 'core',
    'type': 'operations-dashboard',
    'repository': 'New_Earth_Command_Dashboard',
    'status': 'active',
    'contract': 'examples/contracts/COMMAND_DASHBOARD.NEW_EARTH_PROJECT.yaml',
  };
}

Map<String, dynamic> _project({String id = 'new-earth-command-dashboard'}) {
  return {
    'id': id,
    'name': 'New Earth Command Dashboard',
    'family': 'core',
    'type': 'operations-dashboard',
    'owner': 'New Earth Advanced Technologies Ltd',
    'status': 'active',
    'maturity': 'development',
  };
}

Map<String, dynamic> _contract() {
  return {
    'contract_version': '1.0',
    'project': _project(),
    'repository': {
      'version': '0.1.0',
      'versioning': 'semver',
      'default_branch': 'main',
      'release_channel': 'development',
    },
    'design': {
      'system': 'NEDS',
      'version': '0.1',
      'shell': 'desktop-standard',
      'personality': 'core',
      'accessibility': 'required',
    },
    'engineering': {
      'local_first': true,
      'logging': 'standard',
      'security': 'baseline',
      'ci': 'required',
      'testing': 'required',
      'documentation': 'required',
    },
    'integrations': {'neos': true, 'gaia': true, 'command_centre': true},
    'provides': ['command-dashboard-views'],
    'consumes': ['neos-status-api', 'command-centre-ui'],
    'governance': {
      'owner_review': 'required',
      'architecture_review': 'required',
      'release_status': 'in-development',
    },
  };
}
