import 'package:flutter/foundation.dart';

@immutable
class NeosProjectSummaryResponse {
  const NeosProjectSummaryResponse({
    required this.projectId,
    required this.name,
    required this.repoPath,
    required this.lifecycle,
    required this.counts,
    required this.semanticCounts,
    required this.lastScan,
  });

  final String projectId;
  final String name;
  final String repoPath;
  final String lifecycle;
  final Map<String, int> counts;
  final Map<String, int> semanticCounts;
  final Map<String, dynamic>? lastScan;

  factory NeosProjectSummaryResponse.fromJson(Map<String, dynamic> json) {
    return NeosProjectSummaryResponse(
      projectId: _requireString(json, 'project_id'),
      name: _requireString(json, 'name'),
      repoPath: _requireString(json, 'repo_path'),
      lifecycle: _requireString(json, 'lifecycle'),
      counts: _requireIntMap(json, 'counts'),
      semanticCounts: _requireIntMap(json, 'semantic_counts'),
      lastScan: _optionalObjectMap(json['last_scan'], 'last_scan'),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NeosProjectSummaryResponse &&
        other.projectId == projectId &&
        other.name == name &&
        other.repoPath == repoPath &&
        other.lifecycle == lifecycle &&
        _intMapEquals(other.counts, counts) &&
        _intMapEquals(other.semanticCounts, semanticCounts) &&
        _nullableMapEquals(other.lastScan, lastScan);
  }

  @override
  int get hashCode => Object.hash(
    projectId,
    name,
    repoPath,
    lifecycle,
    _mapHash(counts),
    _mapHash(semanticCounts),
    _mapHash(lastScan),
  );
}

String _requireString(Map<String, dynamic> json, String fieldName) {
  final value = json[fieldName];
  if (value is String) {
    return value;
  }
  throw FormatException(
    'NEOS project summary field "$fieldName" must be a string.',
  );
}

Map<String, int> _requireIntMap(Map<String, dynamic> json, String fieldName) {
  final value = json[fieldName];
  if (value is! Map) {
    throw FormatException(
      'NEOS project summary field "$fieldName" must be a JSON object.',
    );
  }
  final result = <String, int>{};
  for (final entry in value.entries) {
    if (entry.value is! int) {
      throw FormatException(
        'NEOS project summary field "$fieldName.${entry.key}" must be an int.',
      );
    }
    result[entry.key.toString()] = entry.value as int;
  }
  return Map<String, int>.unmodifiable(result);
}

Map<String, dynamic>? _optionalObjectMap(Object? value, String fieldName) {
  if (value == null) {
    return null;
  }
  if (value is Map) {
    return Map<String, dynamic>.unmodifiable(Map<String, dynamic>.from(value));
  }
  throw FormatException(
    'NEOS project summary field "$fieldName" must be null or a JSON object.',
  );
}

bool _intMapEquals(Map<String, int> left, Map<String, int> right) {
  if (identical(left, right)) {
    return true;
  }
  if (left.length != right.length) {
    return false;
  }
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) {
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

int _mapHash(Map<String, dynamic>? map) {
  if (map == null) {
    return 0;
  }
  return Object.hashAll(
    map.entries.map((entry) => Object.hash(entry.key, entry.value)),
  );
}
