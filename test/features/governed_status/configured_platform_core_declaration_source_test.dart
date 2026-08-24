import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/features/governed_status/data/configured_platform_core_declaration_source.dart';
import 'package:new_earth_command_dashboard/features/governed_status/domain/governed_status.dart';

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('configured-platform-core-');
    _testRoot = root;
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  test('accepts a configured root and performs exactly three reads', () async {
    final access = _FakeAccess(_documents());
    final payload = await _source(access).read(scope: _scope());

    expect(payload, isNotNull);
    expect(access.reads, 3);
    expect(access.paths, [
      'registry/projects.yaml',
      'examples/contracts/COMMAND_DASHBOARD.NEW_EARTH_PROJECT.yaml',
      'schemas/project-contract.schema.json',
    ]);
    expect(access.verifications, 3);
  });

  test('preserves scope input and returns deeply copied maps', () async {
    final access = _FakeAccess(_documents());
    final payload = await _source(access).read(scope: _scope());
    final registry = payload!.registryDocument as Map<String, Object?>;
    final projects = registry['projects'] as List<Object?>;

    expect(projects.single, isA<Map<String, Object?>>());
    expect(payload.schemaVersion, '1.0');
    expect(payload.retrievedAt, DateTime.utc(2026, 8, 24, 12));
    expect(payload.provenanceReferences, everyElement(isNot(contains('D:'))));
    expect(
      payload.provenanceReferences,
      everyElement(isNot(contains('Users'))),
    );
    expect(() => payload.provenanceReferences.add('x'), throwsUnsupportedError);
  });

  test('missing configuration and root fail deterministically', () async {
    await expectLater(
      () => ConfiguredPlatformCoreDeclarationSource().read(scope: _scope()),
      throwsA(_code('platform_core_not_configured')),
    );
    await expectLater(
      () => ConfiguredPlatformCoreDeclarationSource(
        platformCoreRoot: '${root.path}-missing',
      ).read(scope: _scope()),
      throwsA(_code('platform_core_root_missing')),
    );
    await expectLater(
      () => ConfiguredPlatformCoreDeclarationSource(
        platformCoreRoot: 'relative-root',
      ).read(scope: _scope()),
      throwsA(_code('platform_core_root_invalid')),
    );
    final fileRoot = File('${root.path}-file')
      ..writeAsStringSync('not a directory');
    await expectLater(
      () => ConfiguredPlatformCoreDeclarationSource(
        platformCoreRoot: fileRoot.path,
      ).read(scope: _scope()),
      throwsA(_code('platform_core_root_invalid')),
    );
  });

  test('missing files and source changes do not retry', () async {
    final access = _FakeAccess(_documents())
      ..failurePath =
          'examples/contracts/COMMAND_DASHBOARD.NEW_EARTH_PROJECT.yaml'
      ..failureCode = 'platform_core_contract_missing';
    await expectLater(
      () => _source(access).read(scope: _scope()),
      throwsA(_code('platform_core_contract_missing')),
    );
    expect(access.reads, 2);

    final changed = _FakeAccess(_documents())..verificationFailure = true;
    await expectLater(
      () => _source(changed).read(scope: _scope()),
      throwsA(_code('platform_core_source_changed')),
    );
    expect(changed.reads, 3);
  });

  test('rejects invalid contract references before reading them', () async {
    for (final reference in [
      r'C:\outside.yaml',
      r'\\server\share\outside.yaml',
      '../outside.NEW_EARTH_PROJECT.yaml',
      'examples/contracts/nested/COMMAND_DASHBOARD.NEW_EARTH_PROJECT.yaml',
      'examples/contracts/COMMAND_DASHBOARD.NEW_EARTH_PROJECT.json',
      'examples/contracts/../COMMAND_DASHBOARD.NEW_EARTH_PROJECT.yaml',
    ]) {
      final access = _FakeAccess(_documents(contractReference: reference));
      await expectLater(
        () => _source(access).read(scope: _scope()),
        throwsA(_code('platform_core_contract_reference_invalid')),
        reason: reference,
      );
      expect(access.reads, 1, reason: reference);
    }
  });

  test('accepts root and approved example contract references', () async {
    for (final reference in [
      'NEW_EARTH_PROJECT.yaml',
      'examples/contracts/COMMAND_DASHBOARD.NEW_EARTH_PROJECT.yaml',
    ]) {
      final access = _FakeAccess(_documents(contractReference: reference));
      await _source(access).read(scope: _scope());
      expect(access.reads, 3, reason: reference);
    }
  });

  test('rejects malformed UTF-8, YAML, JSON, and non-map roots', () async {
    final invalidUtf8 = _FakeAccess(_documents())
      ..overrideBytes['registry/projects.yaml'] = [0xff];
    await _expectCode(
      () => _source(invalidUtf8).read(scope: _scope()),
      'platform_core_invalid_utf8',
    );

    final invalidYaml = _FakeAccess(_documents())
      ..overrideBytes['registry/projects.yaml'] = utf8.encode('[invalid');
    await expectLater(
      () => _source(invalidYaml).read(scope: _scope()),
      throwsA(_code('platform_core_invalid_yaml')),
    );

    final invalidJson = _FakeAccess(_documents())
      ..overrideBytes['schemas/project-contract.schema.json'] = utf8.encode(
        '{invalid',
      );
    await expectLater(
      () => _source(invalidJson).read(scope: _scope()),
      throwsA(_code('platform_core_invalid_schema')),
    );

    final nonMap = _FakeAccess(_documents())
      ..overrideBytes['registry/projects.yaml'] = utf8.encode('- one');
    await expectLater(
      () => _source(nonMap).read(scope: _scope()),
      throwsA(_code('platform_core_invalid_yaml')),
    );
  });

  test('enforces byte, depth, collection, and scalar limits', () async {
    final oversized = _FakeAccess(_documents())
      ..forceOversize = 'registry/projects.yaml';
    await expectLater(
      () => _source(oversized).read(scope: _scope()),
      throwsA(_code('platform_core_payload_too_large')),
    );

    final deep = <String, Object?>{'registry_version': '1.0', 'projects': []};
    Object value = 'x';
    for (var i = 0; i < 40; i++) {
      value = {'nested': value};
    }
    deep['projects'] = [value];
    final deepAccess = _FakeAccess(_documents())
      ..overrideBytes['registry/projects.yaml'] = utf8.encode(jsonEncode(deep));
    await expectLater(
      () => _source(deepAccess).read(scope: _scope()),
      throwsA(_code('platform_core_invalid_yaml')),
    );

    final longValue = 'x' * (64 * 1024 + 1);
    final longAccess = _FakeAccess(_documents())
      ..overrideBytes['registry/projects.yaml'] = utf8.encode(
        jsonEncode({'registry_version': longValue, 'projects': []}),
      );
    await expectLater(
      () => _source(longAccess).read(scope: _scope()),
      throwsA(_code('platform_core_invalid_yaml')),
    );
  });

  test('rejects unsupported versions and schema validation failures', () async {
    final registry = _FakeAccess(_documents())
      ..overrideBytes['registry/projects.yaml'] = utf8.encode(
        jsonEncode({..._registry(), 'registry_version': '2.0'}),
      );
    await expectLater(
      () => _source(registry).read(scope: _scope()),
      throwsA(_code('platform_core_unsupported_version')),
    );

    final invalidContract = _FakeAccess(_documents())
      ..overrideBytes['examples/contracts/COMMAND_DASHBOARD.NEW_EARTH_PROJECT.yaml'] =
          utf8.encode(jsonEncode({..._contract(), 'project': null}));
    await expectLater(
      () => _source(invalidContract).read(scope: _scope()),
      throwsA(_code('platform_core_invalid_schema')),
    );

    final unsupportedSchema = _FakeAccess(_documents())
      ..overrideBytes['schemas/project-contract.schema.json'] = utf8.encode(
        jsonEncode({..._schema(), r'$schema': 'https://example.invalid'}),
      );
    await expectLater(
      () => _source(unsupportedSchema).read(scope: _scope()),
      throwsA(_code('platform_core_unsupported_version')),
    );
  });

  test(
    'does not expose raw paths or perform writes/process/network work',
    () async {
      final access = _FakeAccess(_documents());
      final payload = await _source(access).read(scope: _scope());
      final text = payload!.provenanceReferences.join('|');
      expect(text, isNot(contains(root.path)));
      final username = Platform.environment['USERNAME'];
      if (username != null && username.isNotEmpty) {
        expect(text, isNot(contains(username)));
      }
      expect(access.writes, 0);
      expect(access.processes, 0);
      expect(access.networkCalls, 0);
    },
  );
}

Future<void> _expectCode(Future<Object?> Function() action, String code) async {
  try {
    await action();
    fail('Expected $code');
  } on ConfiguredPlatformCoreDeclarationException catch (error) {
    expect(error.code, code);
  }
}

Matcher _code(String code) => predicate<Object?>(
  (value) =>
      value is ConfiguredPlatformCoreDeclarationException && value.code == code,
);

ConfiguredPlatformCoreDeclarationSource _source(
  _FakeAccess access, {
  String? rootPath,
}) {
  return ConfiguredPlatformCoreDeclarationSource(
    platformCoreRoot: rootPath ?? _testRoot.path,
    fileAccess: access,
    clock: () => DateTime.utc(2026, 8, 24, 12),
  );
}

late Directory _testRoot;

GovernedStatusScope _scope() => GovernedStatusScope(
  canonicalId: 'new-earth-command-dashboard',
  displayName: 'New Earth Command Dashboard',
);

Map<String, List<int>> _documents({
  String contractReference =
      'examples/contracts/COMMAND_DASHBOARD.NEW_EARTH_PROJECT.yaml',
}) {
  return {
    'registry/projects.yaml': utf8.encode(
      jsonEncode({
        ..._registry(),
        'projects': [_registryProject(contractReference)],
      }),
    ),
    contractReference: utf8.encode(jsonEncode(_contract())),
    'schemas/project-contract.schema.json': utf8.encode(jsonEncode(_schema())),
  };
}

Map<String, Object?> _registry({String? contractReference}) => {
  'registry_version': '1.0',
  'projects': [
    _registryProject(
      contractReference ??
          'examples/contracts/COMMAND_DASHBOARD.NEW_EARTH_PROJECT.yaml',
    ),
  ],
};

Map<String, Object?> _registryProject(String contractReference) => {
  'id': 'new-earth-command-dashboard',
  'name': 'New Earth Command Dashboard',
  'family': 'core',
  'type': 'operations-dashboard',
  'repository': 'New_Earth_Command_Dashboard',
  'status': 'active',
  'contract': contractReference,
};

Map<String, Object?> _contract() => {
  'contract_version': '1.0',
  'project': {
    'id': 'new-earth-command-dashboard',
    'name': 'New Earth Command Dashboard',
    'family': 'core',
    'type': 'operations-dashboard',
    'owner': 'New Earth Advanced Technologies Ltd',
    'status': 'active',
    'maturity': 'development',
  },
};

Map<String, Object?> _schema() => {
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'type': 'object',
  'required': ['contract_version', 'project'],
  'properties': {
    'contract_version': {
      'type': 'string',
      'enum': ['1.0'],
    },
    'project': {
      'type': 'object',
      'required': [
        'id',
        'name',
        'family',
        'type',
        'owner',
        'status',
        'maturity',
      ],
      'properties': {
        'id': {'type': 'string', 'minLength': 1},
        'name': {'type': 'string', 'minLength': 2},
        'family': {'type': 'string'},
        'type': {'type': 'string'},
        'owner': {'type': 'string'},
        'status': {
          'enum': ['active'],
        },
        'maturity': {'type': 'string'},
      },
      'additionalProperties': false,
    },
  },
  'additionalProperties': false,
};

class _FakeAccess implements PlatformCoreDeclarationFileAccess {
  _FakeAccess(this.documents);

  final Map<String, List<int>> documents;
  final Map<String, List<int>> overrideBytes = {};
  final paths = <String>[];
  int reads = 0;
  int verifications = 0;
  int writes = 0;
  int processes = 0;
  int networkCalls = 0;
  String? failurePath;
  String? failureCode;
  String? forceOversize;
  bool verificationFailure = false;

  Future<PlatformCoreDeclarationFileSnapshot> _read({
    required String relativePath,
    required int maxBytes,
    required String missingCode,
  }) async {
    reads++;
    paths.add(relativePath);
    if (relativePath == failurePath) {
      throw ConfiguredPlatformCoreDeclarationException(
        failureCode ?? missingCode,
      );
    }
    final bytes = overrideBytes[relativePath] ?? documents[relativePath];
    if (bytes == null) {
      throw ConfiguredPlatformCoreDeclarationException(missingCode);
    }
    if (relativePath == forceOversize || bytes.length > maxBytes) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_payload_too_large',
      );
    }
    return PlatformCoreDeclarationFileSnapshot(
      bytes: List.unmodifiable(bytes),
      size: bytes.length,
      modifiedAt: DateTime.utc(2026, 8, 24, 11),
    );
  }

  Future<void> _verify({
    required PlatformCoreDeclarationFileSnapshot snapshot,
  }) async {
    verifications++;
    if (verificationFailure) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_source_changed',
      );
    }
  }

  @override
  Future<PlatformCoreDeclarationFileSnapshot> readRegistry({
    required int maxBytes,
  }) => _read(
    relativePath: 'registry/projects.yaml',
    maxBytes: maxBytes,
    missingCode: 'platform_core_registry_missing',
  );

  @override
  Future<PlatformCoreDeclarationFileSnapshot> readSelectedContract({
    required String relativePath,
    required int maxBytes,
  }) => _read(
    relativePath: relativePath,
    maxBytes: maxBytes,
    missingCode: 'platform_core_contract_missing',
  );

  @override
  Future<PlatformCoreDeclarationFileSnapshot> readSchema({
    required int maxBytes,
  }) => _read(
    relativePath: 'schemas/project-contract.schema.json',
    maxBytes: maxBytes,
    missingCode: 'platform_core_schema_missing',
  );

  @override
  Future<void> verifyRegistry(PlatformCoreDeclarationFileSnapshot snapshot) =>
      _verify(snapshot: snapshot);

  @override
  Future<void> verifySelectedContract(
    String relativePath,
    PlatformCoreDeclarationFileSnapshot snapshot,
  ) => _verify(snapshot: snapshot);

  @override
  Future<void> verifySchema(PlatformCoreDeclarationFileSnapshot snapshot) =>
      _verify(snapshot: snapshot);
}
