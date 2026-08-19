import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/omega_engineering_studio/data/http_neos_engineering_snapshot_reader.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_snapshot_metadata.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/neos_read_transport.dart';

void main() {
  test(
    'composite reader loads health and summary through injected transport',
    () async {
      final transport = FakeNeosReadTransport([
        NeosHttpResponse(
          statusCode: 200,
          body: jsonEncode(_healthPayload()),
          headers: const {'content-type': 'application/json'},
        ),
        NeosHttpResponse(
          statusCode: 200,
          body: jsonEncode(_summaryPayload()),
          headers: const {'content-type': 'application/json'},
        ),
      ]);
      final reader = HttpNeosEngineeringSnapshotReader(transport);

      final envelope = await reader.loadEngineeringSnapshot(
        projectScope: 'alpha/beta +1',
      );

      expect(transport.requestedPaths, <String>[
        '/health',
        '/projects/alpha%2Fbeta%20%2B1/summary',
      ]);
      expect(envelope.metadata.source, EngineeringSnapshotSource.neosLive);
      expect(envelope.metadata.authority, EngineeringSnapshotAuthority.neos);
      expect(envelope.metadata.projectScope, 'alpha/beta +1');
      expect(envelope.metadata.version, '1.3.0');
      expect(envelope.metadata.schemaVersion, 11);
      expect(envelope.metadata.partial, isTrue);
      expect(envelope.metadata.stale, isFalse);
      expect(envelope.metadata.capturedAt, DateTime.utc(2026, 8, 19, 8, 20));
      expect(envelope.metadata.refreshedAt, DateTime.utc(2026, 8, 19, 8, 20));

      expect(
        envelope.snapshot.settings.moduleRootPath,
        'modules/01_OMEGA_ENGINEERING_STUDIO_MODULE',
      );
      expect(envelope.snapshot.projects, hasLength(1));
      expect(envelope.snapshot.projects.single.id, 'microgrow');
      expect(envelope.snapshot.projects.single.title, 'MicroGrow');
      expect(envelope.snapshot.projects.single.summary, r'D:\Repos\MicroGrow');
      expect(envelope.snapshot.projects.single.status, 'active');
      expect(
        envelope.snapshot.projects.single.updatedAt,
        DateTime.utc(2026, 8, 19, 8, 20),
      );
      expect(envelope.snapshot.circuitBlocks, isEmpty);
      expect(envelope.snapshot.pcbRevisions, isEmpty);
      expect(envelope.snapshot.firmwareBuilds, isEmpty);
      expect(envelope.snapshot.deviceNodes, isEmpty);
      expect(envelope.snapshot.componentItems, isEmpty);
      expect(envelope.snapshot.experiments, isEmpty);
      expect(envelope.snapshot.testProcedures, isEmpty);
      expect(envelope.snapshot.validationResults, isEmpty);
      expect(envelope.snapshot.manufacturingSteps, isEmpty);
      expect(envelope.snapshot.documents, isEmpty);
      expect(envelope.snapshot.attachments, isEmpty);
      expect(envelope.snapshot.decisions, isEmpty);
    },
  );

  test(
    'composite reader uses the B4c2 parsers and rejects malformed payloads',
    () async {
      final malformedHealthTransport = FakeNeosReadTransport([
        NeosHttpResponse(
          statusCode: 200,
          body: jsonEncode({..._healthPayload(), 'service_version': 123}),
          headers: const {'content-type': 'application/json'},
        ),
      ]);
      final malformedHealthReader = HttpNeosEngineeringSnapshotReader(
        malformedHealthTransport,
      );

      await expectLater(
        malformedHealthReader.loadEngineeringSnapshot(
          projectScope: 'microgrow',
        ),
        throwsA(isA<FormatException>()),
      );
      expect(malformedHealthTransport.requestedPaths, ['/health']);

      final malformedSummaryTransport = FakeNeosReadTransport([
        NeosHttpResponse(
          statusCode: 200,
          body: jsonEncode(_healthPayload()),
          headers: const {'content-type': 'application/json'},
        ),
        NeosHttpResponse(
          statusCode: 200,
          body: jsonEncode({..._summaryPayload(), 'counts': []}),
          headers: const {'content-type': 'application/json'},
        ),
      ]);
      final malformedSummaryReader = HttpNeosEngineeringSnapshotReader(
        malformedSummaryTransport,
      );

      await expectLater(
        malformedSummaryReader.loadEngineeringSnapshot(
          projectScope: 'microgrow',
        ),
        throwsA(isA<FormatException>()),
      );
      expect(malformedSummaryTransport.requestedPaths, [
        '/health',
        '/projects/microgrow/summary',
      ]);
    },
  );

  test(
    'transport failures propagate and no fallback or cache path is used',
    () async {
      final transport = FakeNeosReadTransport([StateError('transport down')]);
      final reader = HttpNeosEngineeringSnapshotReader(transport);

      await expectLater(
        reader.loadEngineeringSnapshot(projectScope: 'microgrow'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'transport down',
          ),
        ),
      );
      expect(transport.requestedPaths, ['/health']);
    },
  );

  test(
    'reader source stays read-only and has no runtime wiring or write methods',
    () async {
      final source = await File(
        'lib/features/omega_engineering_studio/data/http_neos_engineering_snapshot_reader.dart',
      ).readAsString();

      expect(source, isNot(contains('Provider')));
      expect(source, isNot(contains('Widget')));
      expect(source, isNot(contains('go_router')));
      expect(source, isNot(contains('EngineeringLocalDatabase')));
      expect(source, isNot(contains('package:drift')));
      expect(source, isNot(contains('saveSnapshot')));
      expect(source, isNot(contains('insertOnConflictUpdate')));
      expect(source, isNot(contains('fallback')));
      expect(source, isNot(contains('cache')));
    },
  );
}

class FakeNeosReadTransport implements NeosReadTransport {
  FakeNeosReadTransport(List<Object> scriptedResponses)
    : _scriptedResponses = List<Object>.from(scriptedResponses);

  final List<Object> _scriptedResponses;
  final List<String> requestedPaths = [];

  @override
  Future<NeosHttpResponse> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    requestedPaths.add(path);
    if (_scriptedResponses.isEmpty) {
      throw StateError('No scripted response available for $path');
    }

    final next = _scriptedResponses.removeAt(0);
    if (next is NeosHttpResponse) {
      return next;
    }
    if (next is Exception) {
      throw next;
    }
    if (next is Error) {
      throw next;
    }
    throw StateError('Unsupported scripted response type: ${next.runtimeType}');
  }
}

Map<String, dynamic> _healthPayload() {
  return {
    'status': 'healthy',
    'service_name': 'NEOS Local Service',
    'service_version': '1.3.0',
    'api_version': 'v1',
    'schema_version': 11,
    'host': '127.0.0.1',
    'port': 8765,
    'instance_id': 'neos-123',
    'owner_pid': 321,
    'started_at': '2026-08-19T08:30:00Z',
    'db_path': r'D:\Data\neos.sqlite',
    'database_size_bytes': 2048,
    'registered_projects': 3,
    'project_registry': {
      'schema_version': 2,
      'project_count': 3,
      'projects': [
        {'project_id': 'microgrow', 'name': 'MicroGrow'},
      ],
    },
    'portfolio_health': {'score': 98.5, 'project_count': 3},
    'ai': {
      'settings': {'enabled': true},
      'provider_health': {'healthy': true},
    },
    'command_centre': {'status': 'healthy', 'summary': 'connected'},
    'python': '3.12.4',
    'last_scan': {
      'created_at': '2026-08-19T08:20:00Z',
      'project_id': 'microgrow',
      'scan_id': 'scan-123',
    },
    'unexpected_root': 'ignored',
  };
}

Map<String, dynamic> _summaryPayload() {
  return {
    'project_id': 'microgrow',
    'name': 'MicroGrow',
    'repo_path': r'D:\Repos\MicroGrow',
    'lifecycle': 'active',
    'counts': {'project': 1, 'module': 12, 'test': 7},
    'semantic_counts': {
      'symbols': 14,
      'features': 8,
      'decisions': 4,
      'api_endpoints': 3,
      'configuration_keys': 2,
      'relationships': 6,
      'dependencies': 3,
    },
    'last_scan': {
      'scan_id': 'scan-123',
      'project_id': 'microgrow',
      'created_at': '2026-08-19T08:20:00Z',
      'git_commit': 'abc123',
      'git_branch': 'main',
      'repo_path': r'D:\Repos\MicroGrow',
      'file_count': 1234,
    },
    'unexpected_root': 'ignored',
  };
}
