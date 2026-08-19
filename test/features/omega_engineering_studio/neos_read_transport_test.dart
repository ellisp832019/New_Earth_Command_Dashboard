import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:new_earth_command_dashboard/features/omega_engineering_studio/data/http_neos_read_transport.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/neos_read_transport.dart';

void main() {
  test('NeosReadTransport can be replaced by a fake', () async {
    final fake = RecordingNeosReadTransport(
      response: const NeosHttpResponse(
        statusCode: 200,
        body: '{"summary":"ok"}',
        headers: {'content-type': 'application/json'},
      ),
    );

    final transport = fake as NeosReadTransport;
    final response = await _loadSummary(transport, 'microgrow');

    expect(response.statusCode, 200);
    expect(response.body, '{"summary":"ok"}');
    expect(fake.calls, hasLength(1));
    expect(fake.calls.single.path, '/projects/microgrow/summary');
    expect(fake.calls.single.queryParameters, {'detail': 'full'});
  });

  test('HttpNeosReadTransport performs read-only GET requests', () async {
    final client = RecordingHttpClient((request) async {
      return http.StreamedResponse(
        Stream.fromIterable([
          utf8.encode(
            jsonEncode({
              'path': request.url.path,
              'query': request.url.queryParameters,
            }),
          ),
        ]),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final transport = HttpNeosReadTransport(
      baseUri: Uri.parse('http://127.0.0.1:8765'),
      client: client,
    );

    addTearDown(() {
      transport.close();
    });

    final response = await transport.get(
      '/projects/microgrow/summary',
      queryParameters: {'detail': 'full'},
    );

    expect(client.requests, hasLength(1));
    expect(client.requests.single.method, 'GET');
    expect(client.requests.single.url.path, '/projects/microgrow/summary');
    expect(client.requests.single.url.queryParameters, {'detail': 'full'});
    expect(response.statusCode, 200);
    expect(response.body, contains('/projects/microgrow/summary'));
    expect(response.body, contains('"detail":"full"'));
    expect(response.headers['content-type'], contains('application/json'));
  });

  test(
    'HttpNeosReadTransport reports non-success HTTP responses distinctly',
    () async {
      final client = RecordingHttpClient((request) async {
        return http.StreamedResponse(
          Stream.fromIterable([utf8.encode('missing')]),
          HttpStatus.notFound,
          request: request,
          headers: {'content-type': 'text/plain; charset=utf-8'},
        );
      });
      final transport = HttpNeosReadTransport(
        baseUri: Uri.parse('http://127.0.0.1:8765'),
        client: client,
      );

      addTearDown(() async {
        transport.close();
      });

      try {
        await transport.get('/health');
        fail('Expected a NeosTransportHttpException');
      } on NeosTransportHttpException catch (error) {
        expect(error.statusCode, HttpStatus.notFound);
        expect(error.body, 'missing');
      }
    },
  );

  test('HttpNeosReadTransport enforces localhost-only base URIs', () {
    expect(
      () => HttpNeosReadTransport(baseUri: Uri.parse('http://example.com')),
      throwsArgumentError,
    );
  });

  test('HttpNeosReadTransport reports timeouts distinctly', () async {
    final client = RecordingHttpClient((request) async {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return http.StreamedResponse(
        Stream.fromIterable([utf8.encode('late')]),
        200,
        request: request,
      );
    });
    final transport = HttpNeosReadTransport(
      baseUri: Uri.parse('http://127.0.0.1:8765'),
      client: client,
      timeout: const Duration(milliseconds: 50),
    );

    addTearDown(() async {
      transport.close();
    });

    expect(
      () => transport.get('/health'),
      throwsA(isA<NeosTransportTimeoutException>()),
    );
  });

  test(
    'HttpNeosReadTransport reports connection failures distinctly',
    () async {
      final client = RecordingHttpClient((request) {
        throw http.ClientException('connection failed', request.url);
      });

      final transport = HttpNeosReadTransport(
        baseUri: Uri.parse('http://127.0.0.1:8765'),
        client: client,
      );

      addTearDown(() {
        transport.close();
      });

      expect(
        () => transport.get('/health'),
        throwsA(isA<NeosTransportConnectionException>()),
      );
    },
  );

  test('NeosReadTransport source stays read-only', () async {
    final source = await File(
      'lib/features/omega_engineering_studio/domain/neos_read_transport.dart',
    ).readAsString();

    expect(source, contains('Future<NeosHttpResponse> get('));
    expect(source, isNot(contains('post(')));
    expect(source, isNot(contains('put(')));
    expect(source, isNot(contains('patch(')));
    expect(source, isNot(contains('delete(')));
  });
}

Future<NeosHttpResponse> _loadSummary(
  NeosReadTransport transport,
  String projectId,
) {
  return transport.get(
    '/projects/$projectId/summary',
    queryParameters: const {'detail': 'full'},
  );
}

class RecordingNeosReadTransport implements NeosReadTransport {
  RecordingNeosReadTransport({required this.response});

  final NeosHttpResponse response;
  final List<RecordedNeosRequest> calls = <RecordedNeosRequest>[];

  @override
  Future<NeosHttpResponse> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    calls.add(
      RecordedNeosRequest(
        path: path,
        queryParameters: Map<String, String>.from(queryParameters ?? const {}),
      ),
    );
    return response;
  }
}

class RecordedNeosRequest {
  const RecordedNeosRequest({
    required this.path,
    required this.queryParameters,
  });

  final String path;
  final Map<String, String> queryParameters;
}

class RecordingHttpClient extends http.BaseClient {
  RecordingHttpClient(this._handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request)
  _handler;

  final List<http.BaseRequest> requests = <http.BaseRequest>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    requests.add(request);
    return _handler(request);
  }
}
