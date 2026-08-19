import 'package:flutter/foundation.dart';

/// Transport-level response for read-only NEOS HTTP calls.
@immutable
class NeosHttpResponse {
  const NeosHttpResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;
}

/// Minimal read-only transport contract for NEOS HTTP access.
abstract class NeosReadTransport {
  const NeosReadTransport();

  Future<NeosHttpResponse> get(
    String path, {
    Map<String, String>? queryParameters,
  });
}

/// Base class for transport-level failures.
class NeosTransportException implements Exception {
  const NeosTransportException(this.message, {this.uri, this.cause});

  final String message;
  final Uri? uri;
  final Object? cause;

  @override
  String toString() {
    final buffer = StringBuffer('NeosTransportException: $message');
    if (uri != null) {
      buffer.write(' (uri: $uri)');
    }
    if (cause != null) {
      buffer.write(' (cause: $cause)');
    }
    return buffer.toString();
  }
}

class NeosTransportTimeoutException extends NeosTransportException {
  const NeosTransportTimeoutException(super.message, {super.uri, super.cause});
}

class NeosTransportConnectionException extends NeosTransportException {
  const NeosTransportConnectionException(
    super.message, {
    super.uri,
    super.cause,
  });
}

class NeosTransportHttpException extends NeosTransportException {
  const NeosTransportHttpException(
    super.message, {
    required this.statusCode,
    required this.body,
    required this.headers,
    super.uri,
    super.cause,
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;
}
