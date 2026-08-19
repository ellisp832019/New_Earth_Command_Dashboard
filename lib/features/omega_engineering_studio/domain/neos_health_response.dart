import 'package:flutter/foundation.dart';

@immutable
class NeosHealthResponse {
  const NeosHealthResponse({
    required this.status,
    required this.serviceName,
    required this.serviceVersion,
    required this.apiVersion,
    required this.schemaVersion,
    required this.host,
    required this.port,
    required this.instanceId,
    required this.ownerPid,
    required this.startedAt,
    required this.dbPath,
    required this.databaseSizeBytes,
    required this.registeredProjects,
    required this.projectRegistry,
    required this.portfolioHealth,
    required this.ai,
    required this.commandCentre,
    required this.python,
    required this.lastScan,
  });

  final String status;
  final String serviceName;
  final String serviceVersion;
  final String apiVersion;
  final int schemaVersion;
  final String host;
  final int port;
  final String instanceId;
  final int? ownerPid;
  final String startedAt;
  final String dbPath;
  final int databaseSizeBytes;
  final int registeredProjects;
  final Map<String, dynamic> projectRegistry;
  final Map<String, dynamic> portfolioHealth;
  final Map<String, dynamic> ai;
  final Map<String, dynamic> commandCentre;
  final String python;
  final Map<String, dynamic>? lastScan;

  factory NeosHealthResponse.fromJson(Map<String, dynamic> json) {
    return NeosHealthResponse(
      status: _requireString(json, 'status'),
      serviceName: _requireString(json, 'service_name'),
      serviceVersion: _requireString(json, 'service_version'),
      apiVersion: _requireString(json, 'api_version'),
      schemaVersion: _requireInt(json, 'schema_version'),
      host: _requireString(json, 'host'),
      port: _requireInt(json, 'port'),
      instanceId: _requireString(json, 'instance_id'),
      ownerPid: _optionalInt(json['owner_pid'], 'owner_pid'),
      startedAt: _requireString(json, 'started_at'),
      dbPath: _requireString(json, 'db_path'),
      databaseSizeBytes: _requireInt(json, 'database_size_bytes'),
      registeredProjects: _requireInt(json, 'registered_projects'),
      projectRegistry: _requireObjectMap(json, 'project_registry'),
      portfolioHealth: _requireObjectMap(json, 'portfolio_health'),
      ai: _requireObjectMap(json, 'ai'),
      commandCentre: _requireObjectMap(json, 'command_centre'),
      python: _requireString(json, 'python'),
      lastScan: _optionalObjectMap(json['last_scan'], 'last_scan'),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NeosHealthResponse &&
        other.status == status &&
        other.serviceName == serviceName &&
        other.serviceVersion == serviceVersion &&
        other.apiVersion == apiVersion &&
        other.schemaVersion == schemaVersion &&
        other.host == host &&
        other.port == port &&
        other.instanceId == instanceId &&
        other.ownerPid == ownerPid &&
        other.startedAt == startedAt &&
        other.dbPath == dbPath &&
        other.databaseSizeBytes == databaseSizeBytes &&
        other.registeredProjects == registeredProjects &&
        _shallowMapEquals(other.projectRegistry, projectRegistry) &&
        _shallowMapEquals(other.portfolioHealth, portfolioHealth) &&
        _shallowMapEquals(other.ai, ai) &&
        _shallowMapEquals(other.commandCentre, commandCentre) &&
        other.python == python &&
        _nullableMapEquals(other.lastScan, lastScan);
  }

  @override
  int get hashCode => Object.hash(
    status,
    serviceName,
    serviceVersion,
    apiVersion,
    schemaVersion,
    host,
    port,
    instanceId,
    ownerPid,
    startedAt,
    dbPath,
    databaseSizeBytes,
    registeredProjects,
    _mapHash(projectRegistry),
    _mapHash(portfolioHealth),
    _mapHash(ai),
    _mapHash(commandCentre),
    python,
    _mapHash(lastScan),
  );
}

String _requireString(Map<String, dynamic> json, String fieldName) {
  final value = json[fieldName];
  if (value is String) {
    return value;
  }
  throw FormatException('NEOS health field "$fieldName" must be a string.');
}

int _requireInt(Map<String, dynamic> json, String fieldName) {
  final value = json[fieldName];
  if (value is int) {
    return value;
  }
  throw FormatException('NEOS health field "$fieldName" must be an int.');
}

int? _optionalInt(Object? value, String fieldName) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  throw FormatException(
    'NEOS health field "$fieldName" must be null or an int.',
  );
}

Map<String, dynamic> _requireObjectMap(
  Map<String, dynamic> json,
  String fieldName,
) {
  final value = json[fieldName];
  if (value is Map) {
    return Map<String, dynamic>.unmodifiable(Map<String, dynamic>.from(value));
  }
  throw FormatException(
    'NEOS health field "$fieldName" must be a JSON object.',
  );
}

Map<String, dynamic>? _optionalObjectMap(Object? value, String fieldName) {
  if (value == null) {
    return null;
  }
  if (value is Map) {
    return Map<String, dynamic>.unmodifiable(Map<String, dynamic>.from(value));
  }
  throw FormatException(
    'NEOS health field "$fieldName" must be null or a JSON object.',
  );
}

bool _shallowMapEquals(Map<String, dynamic> left, Map<String, dynamic> right) {
  if (identical(left, right)) {
    return true;
  }
  if (left.length != right.length) {
    return false;
  }
  for (final entry in left.entries) {
    if (!right.containsKey(entry.key) || right[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}

bool _nullableMapEquals(
  Map<String, dynamic>? left,
  Map<String, dynamic>? right,
) {
  if (left == null || right == null) {
    return left == right;
  }
  return _shallowMapEquals(left, right);
}

int _mapHash(Map<String, dynamic>? map) {
  if (map == null) {
    return 0;
  }
  return Object.hashAll(
    map.entries.map((entry) => Object.hash(entry.key, entry.value)),
  );
}
