import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'project_control_context_models.dart';

class ProjectControlContextAdapter {
  ProjectControlContextAdapter({required Directory repositoryRoot})
    : _repositoryRoot = repositoryRoot;

  final Directory _repositoryRoot;

  Future<ProjectControlContextBundle> load() async {
    final sourceDescriptors = <ProjectControlSourceDescriptor>[
      for (final spec in _allowlistedSources)
        ProjectControlSourceDescriptor(
          relativePath: spec.relativePath,
          kind: spec.kind,
        ),
    ];

    final platformManifest = await _readObjectSource(_allowlistedSources[0]);
    final modules = await _readListSource(
      _allowlistedSources[1],
      ProjectControlModuleRecord.fromJson,
    );
    final dependencyMap = await _readObjectSource(_allowlistedSources[2]);
    final releases = await _readListSource(
      _allowlistedSources[3],
      ProjectControlReleaseRecord.fromJson,
    );
    final risks = await _readListSource(
      _allowlistedSources[4],
      ProjectControlRiskRecord.fromJson,
    );
    final verification = await _readListSource(
      _allowlistedSources[5],
      ProjectControlVerificationRecord.fromJson,
    );
    final statusDefinitions = await _readObjectSource(_allowlistedSources[6]);
    final architectureBoundaries = await _readObjectSource(
      _allowlistedSources[7],
    );

    final currentState = await _readObjectSource(_allowlistedSources[8]);
    final releaseReadiness = await _readObjectSource(_allowlistedSources[9]);
    final repositoryHealth = await _readObjectSource(_allowlistedSources[10]);

    return ProjectControlContextBundle(
      canonical: ProjectControlCanonicalData(
        platformManifest: ProjectControlPlatformManifestRecord.fromJson(
          platformManifest,
          path: r'$.platformManifest',
        ),
        modules: modules,
        dependencyMap: ProjectControlDependencyMapRecord.fromJson(
          dependencyMap,
          path: r'$.dependencyMap',
        ),
        releases: releases,
        risks: risks,
        verification: verification,
        statusDefinitions: ProjectControlStatusDefinitionsRecord.fromJson(
          statusDefinitions,
          path: r'$.statusDefinitions',
        ),
        architectureBoundaries:
            ProjectControlArchitectureBoundariesRecord.fromJson(
              architectureBoundaries,
              path: r'$.architectureBoundaries',
            ),
      ),
      generated: ProjectControlGeneratedEvidence(
        currentState: ProjectControlCurrentStateRecord.fromJson(
          currentState,
          path: r'$.currentState',
        ),
        repositoryHealth: ProjectControlRepositoryHealthRecord.fromJson(
          repositoryHealth,
          path: r'$.repositoryHealth',
        ),
        releaseReadiness: ProjectControlReleaseReadinessRecord.fromJson(
          releaseReadiness,
          path: r'$.releaseReadiness',
        ),
      ),
      sourceInventory: ProjectControlSourceInventory(sourceDescriptors),
    );
  }

  Future<Map<String, dynamic>> _readObjectSource(
    _ProjectControlSourceSpec sourceSpec,
  ) async {
    final decoded = await _readJsonSource(sourceSpec);
    if (decoded is! Map<String, dynamic>) {
      throw ProjectControlContextAdapterException(
        message: 'Expected a JSON object at ${sourceSpec.relativePath}.',
        sourcePath: sourceSpec.relativePath,
      );
    }
    return decoded;
  }

  Future<List<T>> _readListSource<T>(
    _ProjectControlSourceSpec sourceSpec,
    T Function(Map<String, dynamic> json, {required String path}) parser,
  ) async {
    final decoded = await _readJsonSource(sourceSpec);
    if (decoded is! List) {
      throw ProjectControlContextAdapterException(
        message: 'Expected a JSON array at ${sourceSpec.relativePath}.',
        sourcePath: sourceSpec.relativePath,
      );
    }
    final records = <T>[];
    for (var index = 0; index < decoded.length; index++) {
      final item = decoded[index];
      if (item is! Map) {
        throw ProjectControlContextAdapterException(
          message:
              'Expected a JSON object at ${sourceSpec.relativePath}[$index].',
          sourcePath: sourceSpec.relativePath,
        );
      }
      final normalized = <String, dynamic>{
        for (final entry in item.entries) entry.key.toString(): entry.value,
      };
      records.add(
        parser(normalized, path: '${sourceSpec.relativePath}[$index]'),
      );
    }
    return List.unmodifiable(records);
  }

  Future<dynamic> _readJsonSource(_ProjectControlSourceSpec sourceSpec) async {
    final file = _resolveAllowlistedSource(sourceSpec.relativePath);
    if (!await file.exists()) {
      throw ProjectControlContextAdapterException(
        message: 'Missing allowlisted Project Control source.',
        sourcePath: sourceSpec.relativePath,
      );
    }
    try {
      final content = await file.readAsString();
      return jsonDecode(content);
    } on FormatException catch (error) {
      throw ProjectControlContextAdapterException(
        message: 'Malformed JSON in allowlisted Project Control source.',
        sourcePath: sourceSpec.relativePath,
        cause: error,
      );
    } on FileSystemException catch (error) {
      throw ProjectControlContextAdapterException(
        message: 'Unable to read allowlisted Project Control source.',
        sourcePath: sourceSpec.relativePath,
        cause: error,
      );
    }
  }

  File _resolveAllowlistedSource(String relativePath) {
    if (path.isAbsolute(relativePath)) {
      throw ProjectControlContextAdapterException(
        message: 'Absolute paths are not allowed for Project Control sources.',
        sourcePath: relativePath,
      );
    }

    final resolved = path.normalize(
      path.join(_repositoryRoot.path, relativePath),
    );
    if (!path.isWithin(_repositoryRoot.path, resolved) &&
        path.normalize(_repositoryRoot.path) != resolved) {
      throw ProjectControlContextAdapterException(
        message: 'Path traversal is not allowed for Project Control sources.',
        sourcePath: relativePath,
      );
    }

    return File(resolved);
  }
}

class _ProjectControlSourceSpec {
  const _ProjectControlSourceSpec({
    required this.relativePath,
    required this.kind,
  });

  final String relativePath;
  final ProjectControlSourceKind kind;
}

const List<_ProjectControlSourceSpec> _allowlistedSources =
    <_ProjectControlSourceSpec>[
      _ProjectControlSourceSpec(
        relativePath: 'project_control/platform_manifest.yaml',
        kind: ProjectControlSourceKind.canonical,
      ),
      _ProjectControlSourceSpec(
        relativePath: 'project_control/module_registry.yaml',
        kind: ProjectControlSourceKind.canonical,
      ),
      _ProjectControlSourceSpec(
        relativePath: 'project_control/dependency_map.yaml',
        kind: ProjectControlSourceKind.canonical,
      ),
      _ProjectControlSourceSpec(
        relativePath: 'project_control/release_registry.yaml',
        kind: ProjectControlSourceKind.canonical,
      ),
      _ProjectControlSourceSpec(
        relativePath: 'project_control/risk_register.yaml',
        kind: ProjectControlSourceKind.canonical,
      ),
      _ProjectControlSourceSpec(
        relativePath: 'project_control/verification_registry.yaml',
        kind: ProjectControlSourceKind.canonical,
      ),
      _ProjectControlSourceSpec(
        relativePath: 'project_control/status_definitions.yaml',
        kind: ProjectControlSourceKind.canonical,
      ),
      _ProjectControlSourceSpec(
        relativePath: 'project_control/architecture_boundaries.yaml',
        kind: ProjectControlSourceKind.canonical,
      ),
      _ProjectControlSourceSpec(
        relativePath: 'project_control/generated/current_state.json',
        kind: ProjectControlSourceKind.historicalEvidence,
      ),
      _ProjectControlSourceSpec(
        relativePath: 'project_control/generated/release_readiness.json',
        kind: ProjectControlSourceKind.derived,
      ),
      _ProjectControlSourceSpec(
        relativePath: 'project_control/generated/repository_health.json',
        kind: ProjectControlSourceKind.derived,
      ),
    ];
