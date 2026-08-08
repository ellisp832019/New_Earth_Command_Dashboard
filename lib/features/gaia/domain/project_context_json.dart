part of 'project_context.dart';

class _ProjectContextJson {
  const _ProjectContextJson._();

  static Map<String, dynamic> object(
    Object? value, {
    required String path,
    required Set<String> allowedKeys,
    required Set<String> requiredKeys,
  }) {
    if (value is! Map) {
      throw ProjectContextParseException.expectedType(
        path: path,
        expected: 'object',
        actual: value,
      );
    }

    final raw = <String, dynamic>{};
    for (final entry in value.entries) {
      if (entry.key is! String) {
        throw ProjectContextParseException.expectedType(
          path: path,
          expected: 'object with string keys',
          actual: value,
        );
      }
      raw[entry.key as String] = entry.value;
    }

    for (final key in raw.keys) {
      if (!allowedKeys.contains(key)) {
        throw ProjectContextParseException.unexpectedField(
          path: path,
          field: key,
        );
      }
    }

    for (final key in requiredKeys) {
      if (!raw.containsKey(key) || raw[key] == null) {
        throw ProjectContextParseException.missingField('$path.$key');
      }
    }

    return raw;
  }

  static String requiredString(
    Map<String, dynamic> json,
    String key, {
    required String path,
  }) {
    if (!json.containsKey(key) || json[key] == null) {
      throw ProjectContextParseException.missingField('$path.$key');
    }
    final value = json[key];
    if (value is! String) {
      throw ProjectContextParseException.expectedType(
        path: '$path.$key',
        expected: 'string',
        actual: value,
      );
    }
    return value;
  }

  static String? optionalString(
    Map<String, dynamic> json,
    String key, {
    required String path,
  }) {
    if (!json.containsKey(key)) {
      return null;
    }
    final value = json[key];
    if (value == null) {
      throw ProjectContextParseException.expectedType(
        path: '$path.$key',
        expected: 'string',
        actual: value,
      );
    }
    if (value is! String) {
      throw ProjectContextParseException.expectedType(
        path: '$path.$key',
        expected: 'string',
        actual: value,
      );
    }
    return value;
  }

  static bool requiredBool(
    Map<String, dynamic> json,
    String key, {
    required String path,
  }) {
    if (!json.containsKey(key) || json[key] == null) {
      throw ProjectContextParseException.missingField('$path.$key');
    }
    final value = json[key];
    if (value is! bool) {
      throw ProjectContextParseException.expectedType(
        path: '$path.$key',
        expected: 'boolean',
        actual: value,
      );
    }
    return value;
  }

  static int? optionalInt(
    Map<String, dynamic> json,
    String key, {
    required String path,
  }) {
    if (!json.containsKey(key)) {
      return null;
    }
    final value = json[key];
    if (value == null || value is! int) {
      throw ProjectContextParseException.expectedType(
        path: '$path.$key',
        expected: 'integer',
        actual: value,
      );
    }
    return value;
  }

  static DateTime requiredDateTime(
    Map<String, dynamic> json,
    String key, {
    required String path,
  }) {
    final raw = requiredString(json, key, path: path);
    return _parseDateTime(raw, '$path.$key');
  }

  static DateTime? optionalDateTime(
    Map<String, dynamic> json,
    String key, {
    required String path,
  }) {
    final raw = optionalString(json, key, path: path);
    if (raw == null) {
      return null;
    }
    return _parseDateTime(raw, '$path.$key');
  }

  static Map<String, dynamic> requiredObject(
    Map<String, dynamic> json,
    String key, {
    required String path,
    required Set<String> allowedKeys,
    required Set<String> requiredKeys,
  }) {
    if (!json.containsKey(key) || json[key] == null) {
      throw ProjectContextParseException.missingField('$path.$key');
    }
    return object(
      json[key],
      path: '$path.$key',
      allowedKeys: allowedKeys,
      requiredKeys: requiredKeys,
    );
  }

  static Map<String, dynamic>? optionalObject(
    Map<String, dynamic> json,
    String key, {
    required String path,
    required Set<String> allowedKeys,
    required Set<String> requiredKeys,
  }) {
    if (!json.containsKey(key)) {
      return null;
    }
    final value = json[key];
    if (value == null) {
      throw ProjectContextParseException.expectedType(
        path: '$path.$key',
        expected: 'object',
        actual: value,
      );
    }
    return object(
      value,
      path: '$path.$key',
      allowedKeys: allowedKeys,
      requiredKeys: requiredKeys,
    );
  }

  static List<T> requiredList<T>(
    Map<String, dynamic> json,
    String key, {
    required String path,
    required T Function(Object? value, String path) parseItem,
  }) {
    if (!json.containsKey(key) || json[key] == null) {
      throw ProjectContextParseException.missingField('$path.$key');
    }
    final value = json[key];
    if (value is! List) {
      throw ProjectContextParseException.expectedType(
        path: '$path.$key',
        expected: 'array',
        actual: value,
      );
    }
    return List<T>.unmodifiable(
      List<T>.generate(value.length, (index) {
        return parseItem(value[index], '$path.$key[$index]');
      }),
    );
  }

  static List<T>? optionalList<T>(
    Map<String, dynamic> json,
    String key, {
    required String path,
    required T Function(Object? value, String path) parseItem,
  }) {
    if (!json.containsKey(key)) {
      return null;
    }
    final value = json[key];
    if (value == null) {
      throw ProjectContextParseException.expectedType(
        path: '$path.$key',
        expected: 'array',
        actual: value,
      );
    }
    if (value is! List) {
      throw ProjectContextParseException.expectedType(
        path: '$path.$key',
        expected: 'array',
        actual: value,
      );
    }
    return List<T>.unmodifiable(
      List<T>.generate(value.length, (index) {
        return parseItem(value[index], '$path.$key[$index]');
      }),
    );
  }

  static List<String> requiredStringList(
    Map<String, dynamic> json,
    String key, {
    required String path,
  }) {
    return requiredList<String>(
      json,
      key,
      path: path,
      parseItem: (value, itemPath) {
        if (value == null || value is! String) {
          throw ProjectContextParseException.expectedType(
            path: itemPath,
            expected: 'string',
            actual: value,
          );
        }
        return value;
      },
    );
  }

  static List<String>? optionalStringList(
    Map<String, dynamic> json,
    String key, {
    required String path,
  }) {
    return optionalList<String>(
      json,
      key,
      path: path,
      parseItem: (value, itemPath) {
        if (value == null || value is! String) {
          throw ProjectContextParseException.expectedType(
            path: itemPath,
            expected: 'string',
            actual: value,
          );
        }
        return value;
      },
    );
  }

  static DateTime _parseDateTime(String raw, String path) {
    try {
      return DateTime.parse(raw).toUtc();
    } on FormatException {
      throw ProjectContextParseException.invalidDateTime(
        path: path,
        actual: raw,
      );
    }
  }
}
