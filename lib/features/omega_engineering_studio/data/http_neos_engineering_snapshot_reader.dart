import 'dart:convert';

import '../domain/engineering_models.dart';
import '../domain/engineering_snapshot_envelope.dart';
import '../domain/engineering_snapshot_metadata.dart';
import '../domain/neos_engineering_snapshot_reader.dart';
import '../domain/neos_health_response.dart';
import '../domain/neos_project_summary_response.dart';
import '../domain/neos_read_transport.dart';

/// Read-only NEOS snapshot adapter built from the health and project summary endpoints.
///
/// The adapter preserves truthfulness by only mapping fields the current NEOS
/// payloads can actually support and by leaving unsupported collections empty
/// while marking the snapshot as partial.
class HttpNeosEngineeringSnapshotReader
    implements NeosEngineeringSnapshotReader {
  HttpNeosEngineeringSnapshotReader(this._transport);

  final NeosReadTransport _transport;

  @override
  Future<EngineeringSnapshotEnvelope> loadEngineeringSnapshot({
    String? projectScope,
  }) async {
    final scope = _requireProjectScope(projectScope);

    final health = await _loadHealth();
    final summary = await _loadProjectSummary(scope);
    final capturedAt = _capturedAt(health, summary);

    return EngineeringSnapshotEnvelope(
      snapshot: _buildSnapshot(
        health: health,
        summary: summary,
        capturedAt: capturedAt,
      ),
      metadata: EngineeringSnapshotMetadata(
        source: EngineeringSnapshotSource.neosLive,
        authority: EngineeringSnapshotAuthority.neos,
        capturedAt: capturedAt,
        refreshedAt: capturedAt,
        stale: false,
        partial: true,
        version: health.serviceVersion,
        schemaVersion: health.schemaVersion,
        projectScope: scope,
      ),
    );
  }

  Future<NeosHealthResponse> _loadHealth() async {
    final response = await _transport.get('/health');
    return NeosHealthResponse.fromJson(
      _decodeJsonObject(response.body, '/health'),
    );
  }

  Future<NeosProjectSummaryResponse> _loadProjectSummary(
    String projectScope,
  ) async {
    final encodedProjectId = Uri.encodeComponent(projectScope);
    final response = await _transport.get(
      '/projects/$encodedProjectId/summary',
    );
    return NeosProjectSummaryResponse.fromJson(
      _decodeJsonObject(response.body, '/projects/$encodedProjectId/summary'),
    );
  }

  EngineeringSnapshot _buildSnapshot({
    required NeosHealthResponse health,
    required NeosProjectSummaryResponse summary,
    required DateTime capturedAt,
  }) {
    final project = EngineeringProject(
      id: summary.projectId,
      title: summary.name,
      summary: summary.repoPath,
      status: summary.lifecycle,
      priority: 'Medium',
      progressPercent: 0,
      milestone: health.status,
      nextAction:
          'Review the live NEOS summary captured at ${capturedAt.toIso8601String()}',
      system: health.serviceName,
      updatedAt: _timestampFromScan(summary.lastScan) ?? capturedAt,
      openTaskCount: 0,
      blockedTaskCount: 0,
      tags: const [],
      targetDate: null,
    );

    // Dashboard-local settings remain authoritative; this adapter only supplies
    // a neutral, existing local module identity placeholder.
    return EngineeringSnapshot(
      settings: EngineeringModuleSettings.defaults(
        moduleRootPath: 'modules/01_OMEGA_ENGINEERING_STUDIO_MODULE',
      ),
      projects: [project],
      circuitBlocks: const [],
      pcbRevisions: const [],
      firmwareBuilds: const [],
      deviceNodes: const [],
      componentItems: const [],
      experiments: const [],
      testProcedures: const [],
      validationResults: const [],
      manufacturingSteps: const [],
      documents: const [],
      attachments: const [],
      decisions: const [],
    );
  }

  DateTime _capturedAt(
    NeosHealthResponse health,
    NeosProjectSummaryResponse summary,
  ) {
    return _timestampFromScan(health.lastScan) ??
        _timestampFromScan(summary.lastScan) ??
        DateTime.now().toUtc();
  }

  DateTime? _timestampFromScan(Map<String, dynamic>? scan) {
    if (scan == null) {
      return null;
    }
    final createdAt = scan['created_at']?.toString();
    if (createdAt == null || createdAt.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(createdAt)?.toUtc();
  }

  String _requireProjectScope(String? projectScope) {
    final value = projectScope?.trim();
    if (value == null || value.isEmpty) {
      throw ArgumentError.value(
        projectScope,
        'projectScope',
        'A project scope is required for the NEOS project summary request.',
      );
    }
    return value;
  }

  Map<String, dynamic> _decodeJsonObject(String rawBody, String endpoint) {
    final decoded = jsonDecode(rawBody);
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    throw FormatException('$endpoint response must be a JSON object.');
  }
}
