import 'dart:async';
import 'dart:io' show SocketException;

import 'package:http/http.dart' as http;

import '../domain/neos_read_transport.dart';

/// Localhost-only HTTP transport for read-only NEOS requests.
class HttpNeosReadTransport implements NeosReadTransport {
  HttpNeosReadTransport({
    required Uri baseUri,
    http.Client? client,
    this.timeout = const Duration(seconds: 5),
  }) : _baseUri = _validateBaseUri(baseUri),
       _client = client ?? http.Client(),
       _ownsClient = client == null;

  final Uri _baseUri;
  final http.Client _client;
  final bool _ownsClient;

  /// Five seconds keeps local reads responsive and mirrors the command-centre
  /// NEOS probe cap for interactive summary lookups.
  final Duration timeout;

  @override
  Future<NeosHttpResponse> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters: queryParameters);
    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(timeout);
      final headers = Map<String, String>.unmodifiable(response.headers);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw NeosTransportHttpException(
          'NEOS returned HTTP ${response.statusCode}',
          statusCode: response.statusCode,
          body: response.body,
          headers: headers,
          uri: uri,
        );
      }
      return NeosHttpResponse(
        statusCode: response.statusCode,
        body: response.body,
        headers: headers,
      );
    } on TimeoutException catch (error) {
      throw NeosTransportTimeoutException(
        'NEOS GET timed out after ${timeout.inMilliseconds}ms',
        uri: uri,
        cause: error,
      );
    } on http.ClientException catch (error) {
      throw NeosTransportConnectionException(
        'NEOS GET failed',
        uri: uri,
        cause: error,
      );
    } on SocketException catch (error) {
      throw NeosTransportConnectionException(
        'NEOS GET failed',
        uri: uri,
        cause: error,
      );
    }
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }

  Uri _buildUri(String path, {Map<String, String>? queryParameters}) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri(
      scheme: _baseUri.scheme,
      userInfo: _baseUri.userInfo,
      host: _baseUri.host,
      port: _baseUri.hasPort ? _baseUri.port : null,
      path: normalizedPath,
      queryParameters: queryParameters,
    );
  }

  static Uri _validateBaseUri(Uri baseUri) {
    if (!_isLocalHost(baseUri.host)) {
      throw ArgumentError.value(
        baseUri,
        'baseUri',
        'NEOS read transport must target localhost only.',
      );
    }
    return baseUri;
  }

  static bool _isLocalHost(String host) {
    return host == '127.0.0.1' || host == 'localhost' || host == '::1';
  }
}
