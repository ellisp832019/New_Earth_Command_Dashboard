import '../domain/governed_status.dart';

const _platformCoreSchemaVersion = '1.0';

/// The parsed, injected Platform Core declaration pair.
///
/// Discovery and serialization are deliberately outside this adapter. The
/// registry and contract objects are supplied by the composition layer.
class PlatformCoreDeclarationPayload {
  PlatformCoreDeclarationPayload({
    required this.registryDocument,
    required this.projectContractDocument,
    required this.schemaVersion,
    required this.retrievedAt,
    List<String> provenanceReferences = const [],
  }) : provenanceReferences = List.unmodifiable(provenanceReferences);

  final Object? registryDocument;
  final Object? projectContractDocument;
  final String schemaVersion;
  final DateTime retrievedAt;
  final List<String> provenanceReferences;
}

/// Narrow source seam for obtaining an already-supplied Platform Core pair.
abstract interface class PlatformCoreDeclarationSource {
  Future<PlatformCoreDeclarationPayload?> read({
    required GovernedStatusScope scope,
  });
}

class PlatformCoreGovernedStatusReader implements GovernedStatusReader {
  PlatformCoreGovernedStatusReader(this._source);

  final PlatformCoreDeclarationSource _source;

  @override
  Future<GovernedStatusEnvelope> load({
    required GovernedStatusScope scope,
  }) async {
    PlatformCoreDeclarationPayload? payload;
    try {
      payload = await _source.read(scope: scope);
    } catch (_) {
      return _failureEnvelope(
        scope: scope,
        category: GovernedStatusFailureCategory.unavailable,
        code: 'platform_core_source_unavailable',
      );
    }

    if (payload == null) {
      return _failureEnvelope(
        scope: scope,
        category: GovernedStatusFailureCategory.unavailable,
        code: 'platform_core_payload_unavailable',
      );
    }

    try {
      _validatePayloadMetadata(payload);
      final registry = _mapObject(payload.registryDocument, 'registry');
      final contract = _mapObject(
        payload.projectContractDocument,
        'project_contract',
      );
      final registryVersion = _requiredString(registry, 'registry_version');
      final contractVersion = _requiredString(contract, 'contract_version');
      if (payload.schemaVersion != _platformCoreSchemaVersion ||
          registryVersion != payload.schemaVersion ||
          contractVersion != payload.schemaVersion) {
        return _failureEnvelope(
          scope: scope,
          payload: payload,
          category: GovernedStatusFailureCategory.invalid,
          code: 'platform_core_unsupported_schema_version',
        );
      }

      final registryProjects = _requiredList(registry, 'projects');
      final registryRecords = registryProjects
          .map((project) {
            final record = _mapObjectValue(project);
            _validateRegistryProject(record);
            return record;
          })
          .toList(growable: false);
      final registryIds = registryRecords
          .map((project) => project['id'] as String)
          .toList();
      if (registryIds.toSet().length != registryIds.length) {
        return _failureEnvelope(
          scope: scope,
          payload: payload,
          category: GovernedStatusFailureCategory.invalid,
          code: 'platform_core_duplicate_project_id',
        );
      }
      final matchingProjects = registryRecords
          .where((project) => project['id'] == scope.canonicalId)
          .toList(growable: false);
      if (matchingProjects.isEmpty) {
        return _failureEnvelope(
          scope: scope,
          payload: payload,
          category: GovernedStatusFailureCategory.unsupportedScope,
          code: 'platform_core_project_not_found',
        );
      }
      if (matchingProjects.length > 1) {
        return _failureEnvelope(
          scope: scope,
          payload: payload,
          category: GovernedStatusFailureCategory.invalid,
          code: 'platform_core_duplicate_project_id',
        );
      }

      final registryProject = matchingProjects.single;
      final project = _requiredObject(contract, 'project');
      _validateProjectContract(contract, project);
      final projectId = _requiredString(project, 'id');
      if (projectId != scope.canonicalId ||
          registryProject['id'] != projectId ||
          registryProject['name'] != project['name'] ||
          registryProject['family'] != project['family'] ||
          registryProject['type'] != project['type'] ||
          registryProject['status'] != project['status']) {
        return _failureEnvelope(
          scope: scope,
          payload: payload,
          category: GovernedStatusFailureCategory.scopeMismatch,
          code: 'platform_core_scope_mismatch',
        );
      }

      final declared = DeclaredStatusLayer(
        canonicalId: projectId,
        displayName: _requiredString(project, 'name'),
        systemType: _requiredString(project, 'type'),
        owner: _requiredString(project, 'owner'),
        lifecycle: _requiredString(project, 'status'),
        repository: _requiredString(registryProject, 'repository'),
        contractVersion: contractVersion,
        interfaces: _sortedStrings(contract, 'provides'),
        dependencies: _sortedStrings(contract, 'consumes'),
      );

      final metadata = GovernedStatusSourceMetadata(
        source: GovernedStatusSource.platformCore,
        authority: GovernedStatusAuthority.platformCore,
        availability: GovernedStatusAvailability.available,
        scope: scope,
        schemaVersion: payload.schemaVersion,
        retrievedAt: payload.retrievedAt,
        partial: true,
        provenanceReferences: _safeProvenance(payload.provenanceReferences),
      );
      return GovernedStatusEnvelope(
        requestedScope: scope,
        records: [GovernedStatusRecord(scope: scope, declared: declared)],
        sourceMetadata: [metadata],
        partial: true,
      );
    } on _InvalidDeclaration {
      return _failureEnvelope(
        scope: scope,
        payload: payload,
        category: GovernedStatusFailureCategory.invalid,
        code: 'platform_core_invalid_declaration',
      );
    } on ArgumentError {
      return _failureEnvelope(
        scope: scope,
        payload: payload,
        category: GovernedStatusFailureCategory.invalid,
        code: 'platform_core_invalid_source_metadata',
      );
    }
  }

  void _validatePayloadMetadata(PlatformCoreDeclarationPayload payload) {
    if (payload.schemaVersion.isEmpty ||
        payload.retrievedAt.isUtc == false ||
        payload.provenanceReferences.any(_isUnsafeProvenance)) {
      throw _InvalidDeclaration();
    }
  }

  GovernedStatusEnvelope _failureEnvelope({
    required GovernedStatusScope scope,
    required GovernedStatusFailureCategory category,
    required String code,
    PlatformCoreDeclarationPayload? payload,
  }) {
    final metadata = GovernedStatusSourceMetadata(
      source: GovernedStatusSource.platformCore,
      authority: GovernedStatusAuthority.platformCore,
      availability: category == GovernedStatusFailureCategory.unavailable
          ? GovernedStatusAvailability.unavailable
          : category == GovernedStatusFailureCategory.unsupportedScope
          ? GovernedStatusAvailability.unsupported
          : GovernedStatusAvailability.invalid,
      scope: scope,
      schemaVersion: payload?.schemaVersion,
      retrievedAt: payload?.retrievedAt,
      partial: true,
      failureCategory: category,
      provenanceReferences: payload == null
          ? const []
          : _safeProvenance(payload.provenanceReferences),
    );
    return GovernedStatusEnvelope(
      requestedScope: scope,
      sourceMetadata: [metadata],
      sourceFailures: [
        GovernedStatusSourceFailure(
          source: GovernedStatusSource.platformCore,
          category: category,
          scope: scope,
          description: code,
        ),
      ],
      partial: true,
    );
  }
}

class _InvalidDeclaration implements Exception {
  const _InvalidDeclaration();
}

Map<String, dynamic> _mapObject(Object? value, String name) {
  if (value is! Map) {
    throw _InvalidDeclaration();
  }
  return value.map((key, value) => MapEntry(key.toString(), value));
}

Map<String, dynamic> _mapObjectValue(Object? value) =>
    _mapObject(value, 'item');

Map<String, dynamic> _requiredObject(Map<String, dynamic> object, String key) {
  return _mapObject(object[key], key);
}

List<Object?> _requiredList(Map<String, dynamic> object, String key) {
  final value = object[key];
  if (value is! List) {
    throw _InvalidDeclaration();
  }
  return List<Object?>.from(value);
}

void _validateRegistryProject(Map<String, dynamic> project) {
  for (final key in [
    'id',
    'name',
    'family',
    'type',
    'repository',
    'status',
    'contract',
  ]) {
    _requiredString(project, key);
  }
}

void _validateProjectContract(
  Map<String, dynamic> contract,
  Map<String, dynamic> project,
) {
  for (final key in [
    'id',
    'name',
    'family',
    'type',
    'owner',
    'status',
    'maturity',
  ]) {
    _requiredString(project, key);
  }
  final repository = _requiredObject(contract, 'repository');
  for (final key in [
    'version',
    'versioning',
    'default_branch',
    'release_channel',
  ]) {
    _requiredString(repository, key);
  }
  _requiredObject(contract, 'design');
  _requiredObject(contract, 'engineering');
  _requiredObject(contract, 'integrations');
  _requiredObject(contract, 'governance');
  _requiredList(contract, 'provides');
  _requiredList(contract, 'consumes');
}

String _requiredString(Map<String, dynamic> object, String key) {
  final value = object[key];
  if (value is! String || value.isEmpty) {
    throw _InvalidDeclaration();
  }
  return value;
}

List<String> _sortedStrings(Map<String, dynamic> object, String key) {
  final value = object[key];
  if (value == null) {
    return const [];
  }
  if (value is! List || value.any((item) => item is! String)) {
    throw _InvalidDeclaration();
  }
  final result = value.cast<String>().toList(growable: false);
  return List<String>.from(result)..sort();
}

List<String> _safeProvenance(List<String> references) {
  return references
      .where((reference) => !_isUnsafeProvenance(reference))
      .toList(growable: false);
}

bool _isUnsafeProvenance(String reference) {
  return reference.isEmpty ||
      reference.length > 256 ||
      RegExp(r'^(?:[A-Za-z]:[\\/]|[\\/])').hasMatch(reference);
}
