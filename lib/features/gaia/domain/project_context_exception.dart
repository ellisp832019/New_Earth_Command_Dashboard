part of 'project_context.dart';

/// Describes a strict Project Context parse failure with JSON path context.
class ProjectContextParseException implements Exception {
  const ProjectContextParseException({
    required this.path,
    required this.message,
    this.expected,
    this.actual,
  });

  final String path;
  final String message;
  final Object? expected;
  final Object? actual;

  factory ProjectContextParseException.missingField(String path) {
    return ProjectContextParseException(
      path: path,
      message: 'required field missing',
      expected: 'present',
    );
  }

  factory ProjectContextParseException.unexpectedField({
    required String path,
    required String field,
  }) {
    return ProjectContextParseException(
      path: path,
      message: 'unexpected field "$field"',
      actual: field,
    );
  }

  factory ProjectContextParseException.expectedType({
    required String path,
    required String expected,
    Object? actual,
  }) {
    return ProjectContextParseException(
      path: path,
      message: 'expected $expected, got ${_describe(actual)}',
      expected: expected,
      actual: actual,
    );
  }

  factory ProjectContextParseException.unsupportedValue({
    required String path,
    required Object? actual,
    required String expected,
  }) {
    return ProjectContextParseException(
      path: path,
      message: 'unsupported value ${_describe(actual)}',
      expected: expected,
      actual: actual,
    );
  }

  factory ProjectContextParseException.invalidDateTime({
    required String path,
    required Object? actual,
  }) {
    return ProjectContextParseException(
      path: path,
      message: 'invalid date-time value ${_describe(actual)}',
      expected: 'ISO-8601 date-time string',
      actual: actual,
    );
  }

  @override
  String toString() => '$path: $message';
}

String _describe(Object? value) {
  if (value == null) {
    return 'null';
  }
  if (value is String) {
    return '"$value"';
  }
  return value.toString();
}
