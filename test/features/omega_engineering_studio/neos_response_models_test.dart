import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/neos_health_response.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/neos_project_summary_response.dart';

void main() {
  test('valid health payload parses', () {
    final response = NeosHealthResponse.fromJson(_healthPayload());

    expect(response.status, 'healthy');
    expect(response.serviceName, 'NEOS Local Service');
    expect(response.databaseSizeBytes, 2048);
    expect(response.registeredProjects, 3);
    expect(response.projectRegistry['schema_version'], 2);
    expect(response.ai['settings'], isA<Map>());
  });

  test('valid project summary parses', () {
    final response = NeosProjectSummaryResponse.fromJson(_summaryPayload());

    expect(response.projectId, 'microgrow');
    expect(response.name, 'MicroGrow');
    expect(response.repoPath, r'D:\Repos\MicroGrow');
    expect(response.lifecycle, 'active');
    expect(response.counts['project'], 1);
    expect(response.semanticCounts['dependencies'], 3);
    expect(response.lastScan?['scan_id'], 'scan-123');
  });

  test('optional fields may be absent', () {
    final health = NeosHealthResponse.fromJson({
      ..._healthPayload(),
      'owner_pid': null,
      'last_scan': null,
    });
    final summary = NeosProjectSummaryResponse.fromJson({
      ..._summaryPayload(),
      'last_scan': null,
    });

    expect(health.ownerPid, isNull);
    expect(health.lastScan, isNull);
    expect(summary.lastScan, isNull);
  });

  test('unknown additive fields are tolerated', () {
    final health = NeosHealthResponse.fromJson({
      ..._healthPayload(),
      'unexpected_root': {'any': 'value'},
    });
    final summary = NeosProjectSummaryResponse.fromJson({
      ..._summaryPayload(),
      'unexpected_root': 123,
    });

    expect(health.serviceVersion, '1.3.0');
    expect(summary.projectId, 'microgrow');
  });

  test('invalid mandatory structure fails deterministically', () {
    expect(
      () => NeosHealthResponse.fromJson({
        ..._healthPayload(),
        'service_version': 123,
      }),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => NeosProjectSummaryResponse.fromJson({
        ..._summaryPayload(),
        'counts': [],
      }),
      throwsA(isA<FormatException>()),
    );
  });

  test('service/API/schema versions preserved', () {
    final response = NeosHealthResponse.fromJson(_healthPayload());

    expect(response.serviceVersion, '1.3.0');
    expect(response.apiVersion, 'v1');
    expect(response.schemaVersion, 11);
  });

  test('project identity preserved', () {
    final response = NeosProjectSummaryResponse.fromJson(_summaryPayload());

    expect(response.projectId, 'microgrow');
    expect(response.name, 'MicroGrow');
    expect(response.repoPath, r'D:\Repos\MicroGrow');
    expect(response.lifecycle, 'active');
  });

  test('no HTTP dependency required by parser tests', () async {
    final healthSource = await File(
      'lib/features/omega_engineering_studio/domain/neos_health_response.dart',
    ).readAsString();
    final summarySource = await File(
      'lib/features/omega_engineering_studio/domain/neos_project_summary_response.dart',
    ).readAsString();

    expect(healthSource, isNot(contains('package:http')));
    expect(summarySource, isNot(contains('package:http')));
  });

  test('no EngineeringSnapshot created', () async {
    final healthSource = await File(
      'lib/features/omega_engineering_studio/domain/neos_health_response.dart',
    ).readAsString();
    final summarySource = await File(
      'lib/features/omega_engineering_studio/domain/neos_project_summary_response.dart',
    ).readAsString();

    expect(healthSource, isNot(contains('EngineeringSnapshot')));
    expect(healthSource, isNot(contains('EngineeringSnapshotEnvelope')));
    expect(summarySource, isNot(contains('EngineeringSnapshot')));
    expect(summarySource, isNot(contains('EngineeringSnapshotEnvelope')));
  });

  test('no runtime/provider wiring exists', () async {
    final healthSource = await File(
      'lib/features/omega_engineering_studio/domain/neos_health_response.dart',
    ).readAsString();
    final summarySource = await File(
      'lib/features/omega_engineering_studio/domain/neos_project_summary_response.dart',
    ).readAsString();

    expect(healthSource, isNot(contains('Provider')));
    expect(healthSource, isNot(contains('NeosEngineeringSnapshotReader')));
    expect(summarySource, isNot(contains('Provider')));
    expect(summarySource, isNot(contains('NeosEngineeringSnapshotReader')));
  });
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
