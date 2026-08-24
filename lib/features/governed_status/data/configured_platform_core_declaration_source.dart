import 'dart:convert';
import 'dart:io';

import 'package:json_schema/json_schema.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../domain/governed_status.dart';
import 'platform_core_governed_status_reader.dart';

const _registryPath = 'registry/projects.yaml';
const _schemaPath = 'schemas/project-contract.schema.json';
const _rootContractName = 'NEW_EARTH_PROJECT.yaml';
const _contractPrefix = 'examples/contracts/';
const _supportedVersion = '1.0';
const _maxRegistryBytes = 1024 * 1024;
const _maxContractBytes = 1024 * 1024;
const _maxSchemaBytes = 512 * 1024;
const _maxDepth = 32;
const _maxCollectionItems = 10000;
const _maxScalarLength = 64 * 1024;
const _maxNodeBudget = 100000;
const _draft202012 = 'https://json-schema.org/draft/2020-12/schema';

/// Stable, sanitized failure raised by the local Platform Core source.
class ConfiguredPlatformCoreDeclarationException implements Exception {
  const ConfiguredPlatformCoreDeclarationException(this.code);

  final String code;

  @override
  String toString() => code;
}

/// Metadata returned by a bounded source read.
class PlatformCoreDeclarationFileSnapshot {
  PlatformCoreDeclarationFileSnapshot({
    required List<int> bytes,
    required this.size,
    required this.modifiedAt,
  }) : bytes = List.unmodifiable(bytes);

  final List<int> bytes;
  final int size;
  final DateTime modifiedAt;
}

/// Narrow filesystem seam used by the configured source and deterministic tests.
abstract interface class PlatformCoreDeclarationFileAccess {
  Future<PlatformCoreDeclarationFileSnapshot> readRegistry({
    required int maxBytes,
  });

  Future<PlatformCoreDeclarationFileSnapshot> readSelectedContract({
    required String relativePath,
    required int maxBytes,
  });

  Future<PlatformCoreDeclarationFileSnapshot> readSchema({
    required int maxBytes,
  });

  Future<void> verifyRegistry(PlatformCoreDeclarationFileSnapshot snapshot);

  Future<void> verifySelectedContract(
    String relativePath,
    PlatformCoreDeclarationFileSnapshot snapshot,
  );

  Future<void> verifySchema(PlatformCoreDeclarationFileSnapshot snapshot);
}

/// Reads the allowlisted Platform Core declaration files without runtime wiring.
class ConfiguredPlatformCoreDeclarationSource
    implements PlatformCoreDeclarationSource {
  ConfiguredPlatformCoreDeclarationSource({
    String? platformCoreRoot,
    PlatformCoreDeclarationFileAccess? fileAccess,
    DateTime Function()? clock,
  }) : _platformCoreRoot = platformCoreRoot,
       _injectedFileAccess = fileAccess,
       _fileAccess = fileAccess,
       _clock = clock ?? (() => DateTime.now().toUtc());

  final String? _platformCoreRoot;
  final PlatformCoreDeclarationFileAccess? _injectedFileAccess;
  final DateTime Function() _clock;

  PlatformCoreDeclarationFileAccess? _fileAccess;

  @override
  Future<PlatformCoreDeclarationPayload?> read({
    required GovernedStatusScope scope,
  }) async {
    final root = await _canonicalRoot();
    final access = _fileAccess ??=
        _injectedFileAccess ?? _LocalPlatformCoreFileAccess(root);

    final registrySnapshot = await access.readRegistry(
      maxBytes: _maxRegistryBytes,
    );
    final registry = _parseYamlMap(
      registrySnapshot,
      invalidCode: 'platform_core_invalid_yaml',
    );
    final registryVersion = _requiredVersion(
      registry,
      'registry_version',
      'platform_core_unsupported_version',
    );
    final contractReference = _selectContractReference(registry, scope);
    final contractPath = _contractPath(contractReference);
    final contractSnapshot = await access.readSelectedContract(
      relativePath: contractPath,
      maxBytes: _maxContractBytes,
    );
    final contract = _parseYamlMap(
      contractSnapshot,
      invalidCode: 'platform_core_invalid_yaml',
    );
    final contractVersion = _requiredVersion(
      contract,
      'contract_version',
      'platform_core_unsupported_version',
    );

    final schemaSnapshot = await access.readSchema(maxBytes: _maxSchemaBytes);
    final schema = _parseSchema(schemaSnapshot);
    if (schema[r'$schema'] != _draft202012) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_unsupported_version',
      );
    }
    if (registryVersion != _supportedVersion ||
        contractVersion != _supportedVersion) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_unsupported_version',
      );
    }
    _validateContract(contract, schema);

    await access.verifyRegistry(registrySnapshot);
    await access.verifySelectedContract(contractPath, contractSnapshot);
    await access.verifySchema(schemaSnapshot);

    final retrievedAt = _clock().toUtc();
    return PlatformCoreDeclarationPayload(
      registryDocument: registry,
      projectContractDocument: contract,
      schemaVersion: _supportedVersion,
      retrievedAt: retrievedAt,
      provenanceReferences: [
        'platform-core:$_registryPath',
        'platform-core:contract:$contractPath',
        'platform-core:$_schemaPath',
        'platform-core:registry-version:$registryVersion',
        'platform-core:contract-version:$contractVersion',
        _fingerprint('registry', registrySnapshot),
        _fingerprint('contract', contractSnapshot),
        _fingerprint('schema', schemaSnapshot),
      ],
    );
  }

  Future<String> _canonicalRoot() async {
    final configured = _platformCoreRoot;
    if (configured == null || configured.isEmpty) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_not_configured',
      );
    }
    if (!p.isAbsolute(configured)) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_root_invalid',
      );
    }
    final directory = Directory(configured);
    FileStat configuredStat;
    try {
      configuredStat = await FileStat.stat(configured);
    } catch (_) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_root_missing',
      );
    }
    if (configuredStat.type == FileSystemEntityType.notFound) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_root_missing',
      );
    }
    if (configuredStat.type != FileSystemEntityType.directory) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_root_invalid',
      );
    }
    try {
      final canonical = await directory.resolveSymbolicLinks();
      if ((await FileStat.stat(canonical)).type !=
          FileSystemEntityType.directory) {
        throw const ConfiguredPlatformCoreDeclarationException(
          'platform_core_root_invalid',
        );
      }
      return p.normalize(canonical);
    } on ConfiguredPlatformCoreDeclarationException {
      rethrow;
    } catch (_) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_root_invalid',
      );
    }
  }

  static String _fingerprint(
    String name,
    PlatformCoreDeclarationFileSnapshot snapshot,
  ) {
    return 'platform-core:fingerprint:$name:size=${snapshot.size};modified=${snapshot.modifiedAt.toUtc().millisecondsSinceEpoch}';
  }
}

class _LocalPlatformCoreFileAccess
    implements PlatformCoreDeclarationFileAccess {
  _LocalPlatformCoreFileAccess(this._root);

  final String _root;

  @override
  Future<PlatformCoreDeclarationFileSnapshot> readRegistry({
    required int maxBytes,
  }) => _readBounded(_registryPath, maxBytes, 'platform_core_registry_missing');

  @override
  Future<PlatformCoreDeclarationFileSnapshot> readSelectedContract({
    required String relativePath,
    required int maxBytes,
  }) => _readBounded(relativePath, maxBytes, 'platform_core_contract_missing');

  @override
  Future<PlatformCoreDeclarationFileSnapshot> readSchema({
    required int maxBytes,
  }) => _readBounded(_schemaPath, maxBytes, 'platform_core_schema_missing');

  Future<PlatformCoreDeclarationFileSnapshot> _readBounded(
    String relativePath,
    int maxBytes,
    String missingCode,
  ) async {
    final file = await _resolveFile(relativePath, missingCode);
    final before = await _statFile(file, missingCode);
    if (before.size > maxBytes) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_payload_too_large',
      );
    }

    RandomAccessFile? handle;
    final bytes = <int>[];
    try {
      handle = await file.open();
      while (bytes.length <= maxBytes) {
        final chunk = await handle.read(maxBytes + 1 - bytes.length);
        if (chunk.isEmpty) break;
        bytes.addAll(chunk);
      }
    } catch (_) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_unreadable',
      );
    } finally {
      if (handle != null) {
        try {
          await handle.close();
        } catch (_) {
          // Preserve the primary read or decoding failure.
        }
      }
    }
    if (bytes.length > maxBytes) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_payload_too_large',
      );
    }
    final after = await _statFile(file, missingCode);
    if (!_sameSnapshot(before, after)) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_source_changed',
      );
    }
    return PlatformCoreDeclarationFileSnapshot(
      bytes: List.unmodifiable(bytes),
      size: after.size,
      modifiedAt: after.modified.toUtc(),
    );
  }

  @override
  Future<void> verifyRegistry(PlatformCoreDeclarationFileSnapshot snapshot) =>
      _verifyUnchanged(_registryPath, snapshot);

  @override
  Future<void> verifySelectedContract(
    String relativePath,
    PlatformCoreDeclarationFileSnapshot snapshot,
  ) => _verifyUnchanged(relativePath, snapshot);

  @override
  Future<void> verifySchema(PlatformCoreDeclarationFileSnapshot snapshot) =>
      _verifyUnchanged(_schemaPath, snapshot);

  Future<void> _verifyUnchanged(
    String relativePath,
    PlatformCoreDeclarationFileSnapshot snapshot,
  ) async {
    final file = await _resolveFile(relativePath, 'platform_core_read_failed');
    final current = await _statFile(file, 'platform_core_read_failed');
    if (current.size != snapshot.size ||
        current.modified.toUtc() != snapshot.modifiedAt.toUtc()) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_source_changed',
      );
    }
  }

  Future<File> _resolveFile(String relativePath, String missingCode) async {
    final components = relativePath.split('/');
    if (components.any(
      (component) => component.isEmpty || component == '.' || component == '..',
    )) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_path_rejected',
      );
    }
    final candidate = p.normalize(p.joinAll([_root, ...components]));
    final lexicalRelative = p.relative(candidate, from: _root);
    if (_hasParentComponent(lexicalRelative)) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_path_rejected',
      );
    }
    final resolved = await File(candidate).resolveSymbolicLinks().catchError(
      (_) => throw ConfiguredPlatformCoreDeclarationException(missingCode),
    );
    final resolvedRelative = p.relative(p.normalize(resolved), from: _root);
    if (_hasParentComponent(resolvedRelative) ||
        p.isAbsolute(resolvedRelative)) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_path_rejected',
      );
    }
    return File(resolved);
  }

  Future<FileStat> _statFile(File file, String missingCode) async {
    try {
      final stat = await file.stat();
      if (stat.type != FileSystemEntityType.file) {
        throw const ConfiguredPlatformCoreDeclarationException(
          'platform_core_path_rejected',
        );
      }
      return stat;
    } on ConfiguredPlatformCoreDeclarationException {
      rethrow;
    } catch (_) {
      throw ConfiguredPlatformCoreDeclarationException(missingCode);
    }
  }

  bool _sameSnapshot(FileStat before, FileStat after) {
    return before.type == after.type &&
        before.size == after.size &&
        before.modified.toUtc() == after.modified.toUtc();
  }
}

bool _hasParentComponent(String path) {
  return p.split(path).any((component) => component == '..');
}

Map<String, Object?> _parseYamlMap(
  PlatformCoreDeclarationFileSnapshot snapshot, {
  required String invalidCode,
}) {
  try {
    final decoded = _strictUtf8(snapshot.bytes);
    final value = _copyYamlValue(loadYaml(decoded), invalidCode);
    if (value is! Map<String, Object?>) {
      throw ConfiguredPlatformCoreDeclarationException(invalidCode);
    }
    return value;
  } on ConfiguredPlatformCoreDeclarationException {
    rethrow;
  } catch (_) {
    throw ConfiguredPlatformCoreDeclarationException(invalidCode);
  }
}

Map<String, Object?> _parseSchema(
  PlatformCoreDeclarationFileSnapshot snapshot,
) {
  try {
    final decoded = _strictUtf8(snapshot.bytes);
    final value = _copyJsonValue(
      jsonDecode(decoded),
      'platform_core_invalid_schema',
    );
    if (value is! Map<String, Object?>) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_invalid_schema',
      );
    }
    return value;
  } on ConfiguredPlatformCoreDeclarationException {
    rethrow;
  } catch (_) {
    throw const ConfiguredPlatformCoreDeclarationException(
      'platform_core_invalid_schema',
    );
  }
}

String _strictUtf8(List<int> bytes) {
  try {
    return utf8.decode(bytes, allowMalformed: false);
  } on FormatException {
    throw const ConfiguredPlatformCoreDeclarationException(
      'platform_core_invalid_utf8',
    );
  }
}

Object? _copyYamlValue(Object? value, String invalidCode) {
  final budget = _CopyBudget();
  return _copyValue(value, invalidCode, budget, <Object>{});
}

Object? _copyJsonValue(Object? value, String invalidCode) {
  final budget = _CopyBudget();
  return _copyValue(value, invalidCode, budget, <Object>{});
}

Object? _copyValue(
  Object? value,
  String invalidCode,
  _CopyBudget budget,
  Set<Object> active, [
  int depth = 0,
]) {
  budget.nodes++;
  if (budget.nodes > _maxNodeBudget || depth > _maxDepth) {
    throw ConfiguredPlatformCoreDeclarationException(invalidCode);
  }
  if (value is String) {
    if (value.length > _maxScalarLength) {
      throw ConfiguredPlatformCoreDeclarationException(invalidCode);
    }
    return value;
  }
  if (value == null || value is bool || value is num) return value;
  if (value is YamlMap || value is Map) {
    final map = value as Map;
    if (!active.add(value)) {
      throw ConfiguredPlatformCoreDeclarationException(invalidCode);
    }
    try {
      if (map.length > _maxCollectionItems) {
        throw ConfiguredPlatformCoreDeclarationException(invalidCode);
      }
      final result = <String, Object?>{};
      for (final entry in map.entries) {
        if (entry.key is! String ||
            (entry.key as String).length > _maxScalarLength) {
          throw ConfiguredPlatformCoreDeclarationException(invalidCode);
        }
        result[entry.key as String] = _copyValue(
          entry.value,
          invalidCode,
          budget,
          active,
          depth + 1,
        );
      }
      return result;
    } finally {
      active.remove(value);
    }
  }
  if (value is YamlList || value is List) {
    final list = value as List;
    if (!active.add(value)) {
      throw ConfiguredPlatformCoreDeclarationException(invalidCode);
    }
    try {
      if (list.length > _maxCollectionItems) {
        throw ConfiguredPlatformCoreDeclarationException(invalidCode);
      }
      return [
        for (final item in list)
          _copyValue(item, invalidCode, budget, active, depth + 1),
      ];
    } finally {
      active.remove(value);
    }
  }
  throw ConfiguredPlatformCoreDeclarationException(invalidCode);
}

class _CopyBudget {
  int nodes = 0;
}

String _requiredVersion(Map<String, Object?> object, String key, String code) {
  final value = object[key];
  if (value is! String || value.isEmpty) {
    throw ConfiguredPlatformCoreDeclarationException(code);
  }
  return value;
}

String _selectContractReference(
  Map<String, Object?> registry,
  GovernedStatusScope scope,
) {
  final projects = registry['projects'];
  if (projects is! List) {
    throw const ConfiguredPlatformCoreDeclarationException(
      'platform_core_invalid_yaml',
    );
  }
  String? selected;
  final ids = <String>{};
  for (final value in projects) {
    if (value is! Map) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_invalid_yaml',
      );
    }
    final id = value['id'];
    final contract = value['contract'];
    if (id is! String ||
        id.isEmpty ||
        contract is! String ||
        contract.isEmpty) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_invalid_yaml',
      );
    }
    if (!ids.add(id)) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_invalid_yaml',
      );
    }
    if (id == scope.canonicalId) selected = contract;
  }
  if (selected == null) {
    throw const ConfiguredPlatformCoreDeclarationException(
      'platform_core_project_missing',
    );
  }
  return selected;
}

String _contractPath(String reference) {
  if (reference == _rootContractName) return _rootContractName;
  if (!reference.startsWith(_contractPrefix)) {
    throw const ConfiguredPlatformCoreDeclarationException(
      'platform_core_contract_reference_invalid',
    );
  }
  final basename = reference.substring(_contractPrefix.length);
  if (!RegExp(
    r'^[A-Za-z0-9_-]+\.NEW_EARTH_PROJECT\.yaml$',
  ).hasMatch(basename)) {
    throw const ConfiguredPlatformCoreDeclarationException(
      'platform_core_contract_reference_invalid',
    );
  }
  return reference;
}

void _validateContract(
  Map<String, Object?> contract,
  Map<String, Object?> schema,
) {
  try {
    final validator = JsonSchema.create(
      schema,
      schemaVersion: SchemaVersion.draft2020_12,
    );
    if (!validator.validate(contract).isValid) {
      throw const ConfiguredPlatformCoreDeclarationException(
        'platform_core_invalid_schema',
      );
    }
  } on ConfiguredPlatformCoreDeclarationException {
    rethrow;
  } catch (_) {
    throw const ConfiguredPlatformCoreDeclarationException(
      'platform_core_invalid_schema',
    );
  }
}
