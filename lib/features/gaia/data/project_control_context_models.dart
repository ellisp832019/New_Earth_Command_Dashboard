enum ProjectControlSourceKind { canonical, derived, historicalEvidence }

class ProjectControlSourceDescriptor {
  const ProjectControlSourceDescriptor({
    required this.relativePath,
    required this.kind,
  });

  final String relativePath;
  final ProjectControlSourceKind kind;
}

class ProjectControlSourceInventory {
  ProjectControlSourceInventory(List<ProjectControlSourceDescriptor> sources)
    : sources = List.unmodifiable(sources);

  final List<ProjectControlSourceDescriptor> sources;

  List<ProjectControlSourceDescriptor> sourcesOfKind(
    ProjectControlSourceKind kind,
  ) {
    return sources
        .where((source) => source.kind == kind)
        .toList(growable: false);
  }
}

class ProjectControlContextBundle {
  const ProjectControlContextBundle({
    required this.canonical,
    required this.generated,
    required this.sourceInventory,
  });

  final ProjectControlCanonicalData canonical;
  final ProjectControlGeneratedEvidence generated;
  final ProjectControlSourceInventory sourceInventory;
}

class ProjectControlCanonicalData {
  const ProjectControlCanonicalData({
    required this.platformManifest,
    required this.modules,
    required this.dependencyMap,
    required this.releases,
    required this.risks,
    required this.verification,
    required this.statusDefinitions,
    required this.architectureBoundaries,
  });

  final ProjectControlPlatformManifestRecord platformManifest;
  final List<ProjectControlModuleRecord> modules;
  final ProjectControlDependencyMapRecord dependencyMap;
  final List<ProjectControlReleaseRecord> releases;
  final List<ProjectControlRiskRecord> risks;
  final List<ProjectControlVerificationRecord> verification;
  final ProjectControlStatusDefinitionsRecord statusDefinitions;
  final ProjectControlArchitectureBoundariesRecord architectureBoundaries;
}

class ProjectControlGeneratedEvidence {
  const ProjectControlGeneratedEvidence({
    required this.currentState,
    required this.repositoryHealth,
    required this.releaseReadiness,
  });

  final ProjectControlCurrentStateRecord currentState;
  final ProjectControlRepositoryHealthRecord repositoryHealth;
  final ProjectControlReleaseReadinessRecord releaseReadiness;
}

class ProjectControlPlatformManifestRecord {
  const ProjectControlPlatformManifestRecord({
    required this.schemaVersion,
    required this.platformId,
    required this.platformName,
    required this.description,
    required this.repositoryUrl,
    required this.repositoryRootHint,
    required this.currentBranch,
    required this.currentCommit,
    required this.applicationVersion,
    required this.platformMaturity,
    required this.supportedPlatforms,
    required this.primaryPlatform,
    required this.localFirst,
    required this.dataOwnership,
    required this.telemetryPolicy,
    required this.cloudDependency,
    required this.releasePolicy,
    required this.defaultBranchPolicy,
    required this.canonicalDocumentation,
    required this.lastVerifiedCommit,
    required this.lastVerifiedDate,
    required this.lastVerifiedBuild,
    required this.lastScan,
    required this.releaseReadiness,
    required this.knownLimitations,
  });

  final int schemaVersion;
  final String platformId;
  final String platformName;
  final String description;
  final String repositoryUrl;
  final String repositoryRootHint;
  final String currentBranch;
  final String currentCommit;
  final String applicationVersion;
  final String platformMaturity;
  final List<String> supportedPlatforms;
  final String primaryPlatform;
  final bool localFirst;
  final String dataOwnership;
  final String telemetryPolicy;
  final String cloudDependency;
  final String releasePolicy;
  final String defaultBranchPolicy;
  final List<String> canonicalDocumentation;
  final String lastVerifiedCommit;
  final String lastVerifiedDate;
  final ProjectControlPlatformBuildRecord lastVerifiedBuild;
  final ProjectControlPlatformScanRecord lastScan;
  final String releaseReadiness;
  final List<String> knownLimitations;

  factory ProjectControlPlatformManifestRecord.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.platformManifest',
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {
        'schema_version',
        'platform_id',
        'platform_name',
        'description',
        'repository_url',
        'repository_root_hint',
        'current_branch',
        'current_commit',
        'application_version',
        'platform_maturity',
        'supported_platforms',
        'primary_platform',
        'local_first',
        'data_ownership',
        'telemetry_policy',
        'cloud_dependency',
        'release_policy',
        'default_branch_policy',
        'canonical_documentation',
        'last_verified_commit',
        'last_verified_date',
        'last_verified_build',
        'last_scan',
        'release_readiness',
        'known_limitations',
      },
      allowedKeys: const {
        'schema_version',
        'platform_id',
        'platform_name',
        'description',
        'repository_url',
        'repository_root_hint',
        'current_branch',
        'current_commit',
        'application_version',
        'platform_maturity',
        'supported_platforms',
        'primary_platform',
        'local_first',
        'data_ownership',
        'telemetry_policy',
        'cloud_dependency',
        'release_policy',
        'default_branch_policy',
        'canonical_documentation',
        'last_verified_commit',
        'last_verified_date',
        'last_verified_build',
        'last_scan',
        'release_readiness',
        'known_limitations',
      },
    );
    return ProjectControlPlatformManifestRecord(
      schemaVersion: _readInt(data, 'schema_version', path: path),
      platformId: _readString(data, 'platform_id', path: path),
      platformName: _readString(data, 'platform_name', path: path),
      description: _readString(data, 'description', path: path),
      repositoryUrl: _readString(data, 'repository_url', path: path),
      repositoryRootHint: _readString(data, 'repository_root_hint', path: path),
      currentBranch: _readString(data, 'current_branch', path: path),
      currentCommit: _readString(data, 'current_commit', path: path),
      applicationVersion: _readString(data, 'application_version', path: path),
      platformMaturity: _readString(data, 'platform_maturity', path: path),
      supportedPlatforms: _readStringList(
        data,
        'supported_platforms',
        path: path,
      ),
      primaryPlatform: _readString(data, 'primary_platform', path: path),
      localFirst: _readBool(data, 'local_first', path: path),
      dataOwnership: _readString(data, 'data_ownership', path: path),
      telemetryPolicy: _readString(data, 'telemetry_policy', path: path),
      cloudDependency: _readString(data, 'cloud_dependency', path: path),
      releasePolicy: _readString(data, 'release_policy', path: path),
      defaultBranchPolicy: _readString(
        data,
        'default_branch_policy',
        path: path,
      ),
      canonicalDocumentation: _readStringList(
        data,
        'canonical_documentation',
        path: path,
      ),
      lastVerifiedCommit: _readString(data, 'last_verified_commit', path: path),
      lastVerifiedDate: _readString(data, 'last_verified_date', path: path),
      lastVerifiedBuild: ProjectControlPlatformBuildRecord.fromJson(
        _readObject(
          data,
          'last_verified_build',
          path: path,
          requiredKeys: const {'windows_executable', 'sha256', 'size_bytes'},
          allowedKeys: const {'windows_executable', 'sha256', 'size_bytes'},
        ),
        path: '$path.last_verified_build',
      ),
      lastScan: ProjectControlPlatformScanRecord.fromJson(
        _readObject(
          data,
          'last_scan',
          path: path,
          requiredKeys: const {'scan_id', 'date', 'commit'},
          allowedKeys: const {'scan_id', 'date', 'commit'},
        ),
        path: '$path.last_scan',
      ),
      releaseReadiness: _readString(data, 'release_readiness', path: path),
      knownLimitations: _readStringList(data, 'known_limitations', path: path),
    );
  }
}

class ProjectControlPlatformBuildRecord {
  const ProjectControlPlatformBuildRecord({
    required this.windowsExecutable,
    required this.sha256,
    required this.sizeBytes,
  });

  final String windowsExecutable;
  final String sha256;
  final int sizeBytes;

  factory ProjectControlPlatformBuildRecord.fromJson(
    Map<String, dynamic> json, {
    required String path,
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {'windows_executable', 'sha256', 'size_bytes'},
      allowedKeys: const {'windows_executable', 'sha256', 'size_bytes'},
    );
    return ProjectControlPlatformBuildRecord(
      windowsExecutable: _readString(data, 'windows_executable', path: path),
      sha256: _readString(data, 'sha256', path: path),
      sizeBytes: _readInt(data, 'size_bytes', path: path),
    );
  }
}

class ProjectControlPlatformScanRecord {
  const ProjectControlPlatformScanRecord({
    required this.scanId,
    required this.date,
    required this.commit,
  });

  final String scanId;
  final String date;
  final String commit;

  factory ProjectControlPlatformScanRecord.fromJson(
    Map<String, dynamic> json, {
    required String path,
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {'scan_id', 'date', 'commit'},
      allowedKeys: const {'scan_id', 'date', 'commit'},
    );
    return ProjectControlPlatformScanRecord(
      scanId: _readString(data, 'scan_id', path: path),
      date: _readString(data, 'date', path: path),
      commit: _readString(data, 'commit', path: path),
    );
  }
}

class ProjectControlModuleRecord {
  const ProjectControlModuleRecord({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.maturity,
    required this.enabled,
    required this.route,
    required this.sourcePaths,
    required this.documentationPaths,
    required this.testPaths,
    required this.dataStorage,
    required this.dataOwner,
    required this.backupPolicy,
    required this.exportPolicy,
    required this.securityLevel,
    required this.permissions,
    required this.dependencies,
    required this.knownRisks,
    required this.lastVerifiedCommit,
    required this.lastVerifiedDate,
    required this.verificationStatus,
    required this.documentationStatus,
    required this.recommendedNextAction,
    required this.owner,
    required this.notes,
  });

  final String id;
  final String name;
  final String description;
  final String version;
  final String maturity;
  final bool enabled;
  final String route;
  final List<String> sourcePaths;
  final List<String> documentationPaths;
  final List<String> testPaths;
  final String dataStorage;
  final String dataOwner;
  final String backupPolicy;
  final String exportPolicy;
  final String securityLevel;
  final List<String> permissions;
  final List<String> dependencies;
  final List<String> knownRisks;
  final String lastVerifiedCommit;
  final String lastVerifiedDate;
  final String verificationStatus;
  final String documentationStatus;
  final String recommendedNextAction;
  final String owner;
  final String notes;

  factory ProjectControlModuleRecord.fromJson(
    Map<String, dynamic> json, {
    required String path,
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {
        'id',
        'name',
        'description',
        'version',
        'maturity',
        'enabled',
        'route',
        'source_paths',
        'documentation_paths',
        'test_paths',
        'data_storage',
        'data_owner',
        'backup_policy',
        'export_policy',
        'security_level',
        'permissions',
        'dependencies',
        'known_risks',
        'last_verified_commit',
        'last_verified_date',
        'verification_status',
        'documentation_status',
        'recommended_next_action',
        'owner',
        'notes',
      },
      allowedKeys: const {
        'id',
        'name',
        'description',
        'version',
        'maturity',
        'enabled',
        'route',
        'source_paths',
        'documentation_paths',
        'test_paths',
        'data_storage',
        'data_owner',
        'backup_policy',
        'export_policy',
        'security_level',
        'permissions',
        'dependencies',
        'known_risks',
        'last_verified_commit',
        'last_verified_date',
        'verification_status',
        'documentation_status',
        'recommended_next_action',
        'owner',
        'notes',
      },
    );
    return ProjectControlModuleRecord(
      id: _readString(data, 'id', path: path),
      name: _readString(data, 'name', path: path),
      description: _readString(data, 'description', path: path),
      version: _readString(data, 'version', path: path),
      maturity: _readString(data, 'maturity', path: path),
      enabled: _readBool(data, 'enabled', path: path),
      route: _readString(data, 'route', path: path),
      sourcePaths: _readStringList(data, 'source_paths', path: path),
      documentationPaths: _readStringList(
        data,
        'documentation_paths',
        path: path,
      ),
      testPaths: _readStringList(data, 'test_paths', path: path),
      dataStorage: _readString(data, 'data_storage', path: path),
      dataOwner: _readString(data, 'data_owner', path: path),
      backupPolicy: _readString(data, 'backup_policy', path: path),
      exportPolicy: _readString(data, 'export_policy', path: path),
      securityLevel: _readString(data, 'security_level', path: path),
      permissions: _readStringList(data, 'permissions', path: path),
      dependencies: _readStringList(data, 'dependencies', path: path),
      knownRisks: _readStringList(data, 'known_risks', path: path),
      lastVerifiedCommit: _readString(data, 'last_verified_commit', path: path),
      lastVerifiedDate: _readString(data, 'last_verified_date', path: path),
      verificationStatus: _readString(data, 'verification_status', path: path),
      documentationStatus: _readString(
        data,
        'documentation_status',
        path: path,
      ),
      recommendedNextAction: _readString(
        data,
        'recommended_next_action',
        path: path,
      ),
      owner: _readString(data, 'owner', path: path),
      notes: _readString(data, 'notes', path: path),
    );
  }
}

class ProjectControlDependencyMapRecord {
  const ProjectControlDependencyMapRecord({
    required this.schemaVersion,
    required this.moduleDependencies,
    required this.sharedServiceDependencies,
    required this.databaseDependencies,
    required this.fileSystemDependencies,
    required this.voiceDependencies,
    required this.hardwareDependencies,
    required this.windowsOnlyDependencies,
    required this.optionalDependencies,
    required this.blockingDependencies,
    required this.observations,
  });

  final int schemaVersion;
  final List<ProjectControlModuleDependencyRecord> moduleDependencies;
  final List<ProjectControlServiceDependencyRecord> sharedServiceDependencies;
  final List<ProjectControlDatabaseDependencyRecord> databaseDependencies;
  final List<ProjectControlFileSystemDependencyRecord> fileSystemDependencies;
  final List<ProjectControlModuleDependencyRecord> voiceDependencies;
  final List<ProjectControlModuleDependencyRecord> hardwareDependencies;
  final List<ProjectControlModuleDependencyRecord> windowsOnlyDependencies;
  final List<ProjectControlModuleDependencyRecord> optionalDependencies;
  final List<ProjectControlBlockingDependencyRecord> blockingDependencies;
  final List<String> observations;

  factory ProjectControlDependencyMapRecord.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.dependencyMap',
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {
        'schema_version',
        'module_dependencies',
        'shared_service_dependencies',
        'database_dependencies',
        'file_system_dependencies',
        'voice_dependencies',
        'hardware_dependencies',
        'windows_only_dependencies',
        'optional_dependencies',
        'blocking_dependencies',
        'observations',
      },
      allowedKeys: const {
        'schema_version',
        'module_dependencies',
        'shared_service_dependencies',
        'database_dependencies',
        'file_system_dependencies',
        'voice_dependencies',
        'hardware_dependencies',
        'windows_only_dependencies',
        'optional_dependencies',
        'blocking_dependencies',
        'observations',
      },
    );
    return ProjectControlDependencyMapRecord(
      schemaVersion: _readInt(data, 'schema_version', path: path),
      moduleDependencies: _readTypedList(
        data,
        'module_dependencies',
        path: path,
        parser: ProjectControlModuleDependencyRecord.fromJson,
      ),
      sharedServiceDependencies: _readTypedList(
        data,
        'shared_service_dependencies',
        path: path,
        parser: ProjectControlServiceDependencyRecord.fromJson,
      ),
      databaseDependencies: _readTypedList(
        data,
        'database_dependencies',
        path: path,
        parser: ProjectControlDatabaseDependencyRecord.fromJson,
      ),
      fileSystemDependencies: _readTypedList(
        data,
        'file_system_dependencies',
        path: path,
        parser: ProjectControlFileSystemDependencyRecord.fromJson,
      ),
      voiceDependencies: _readTypedList(
        data,
        'voice_dependencies',
        path: path,
        parser: ProjectControlModuleDependencyRecord.fromJson,
      ),
      hardwareDependencies: _readTypedList(
        data,
        'hardware_dependencies',
        path: path,
        parser: ProjectControlModuleDependencyRecord.fromJson,
      ),
      windowsOnlyDependencies: _readTypedList(
        data,
        'windows_only_dependencies',
        path: path,
        parser: ProjectControlModuleDependencyRecord.fromJson,
      ),
      optionalDependencies: _readTypedList(
        data,
        'optional_dependencies',
        path: path,
        parser: ProjectControlModuleDependencyRecord.fromJson,
      ),
      blockingDependencies: _readTypedList(
        data,
        'blocking_dependencies',
        path: path,
        parser: ProjectControlBlockingDependencyRecord.fromJson,
      ),
      observations: _readStringList(data, 'observations', path: path),
    );
  }
}

class ProjectControlModuleDependencyRecord {
  const ProjectControlModuleDependencyRecord({
    required this.module,
    required this.dependsOn,
  });

  final String module;
  final List<String> dependsOn;

  factory ProjectControlModuleDependencyRecord.fromJson(
    Map<String, dynamic> json, {
    required String path,
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {'module', 'depends_on'},
      allowedKeys: const {'module', 'depends_on'},
    );
    return ProjectControlModuleDependencyRecord(
      module: _readString(data, 'module', path: path),
      dependsOn: _readStringList(data, 'depends_on', path: path),
    );
  }
}

class ProjectControlServiceDependencyRecord {
  const ProjectControlServiceDependencyRecord({
    required this.service,
    required this.usedBy,
  });

  final String service;
  final List<String> usedBy;

  factory ProjectControlServiceDependencyRecord.fromJson(
    Map<String, dynamic> json, {
    required String path,
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {'service', 'used_by'},
      allowedKeys: const {'service', 'used_by'},
    );
    return ProjectControlServiceDependencyRecord(
      service: _readString(data, 'service', path: path),
      usedBy: _readStringList(data, 'used_by', path: path),
    );
  }
}

class ProjectControlDatabaseDependencyRecord {
  const ProjectControlDatabaseDependencyRecord({
    required this.module,
    required this.database,
  });

  final String module;
  final String database;

  factory ProjectControlDatabaseDependencyRecord.fromJson(
    Map<String, dynamic> json, {
    required String path,
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {'module', 'database'},
      allowedKeys: const {'module', 'database'},
    );
    return ProjectControlDatabaseDependencyRecord(
      module: _readString(data, 'module', path: path),
      database: _readString(data, 'database', path: path),
    );
  }
}

class ProjectControlFileSystemDependencyRecord {
  const ProjectControlFileSystemDependencyRecord({
    required this.module,
    required this.paths,
  });

  final String module;
  final List<String> paths;

  factory ProjectControlFileSystemDependencyRecord.fromJson(
    Map<String, dynamic> json, {
    required String path,
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {'module', 'paths'},
      allowedKeys: const {'module', 'paths'},
    );
    return ProjectControlFileSystemDependencyRecord(
      module: _readString(data, 'module', path: path),
      paths: _readStringList(data, 'paths', path: path),
    );
  }
}

class ProjectControlBlockingDependencyRecord {
  const ProjectControlBlockingDependencyRecord({
    required this.module,
    required this.blockedBy,
  });

  final String module;
  final List<String> blockedBy;

  factory ProjectControlBlockingDependencyRecord.fromJson(
    Map<String, dynamic> json, {
    required String path,
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {'module', 'blocked_by'},
      allowedKeys: const {'module', 'blocked_by'},
    );
    return ProjectControlBlockingDependencyRecord(
      module: _readString(data, 'module', path: path),
      blockedBy: _readStringList(data, 'blocked_by', path: path),
    );
  }
}

class ProjectControlReleaseRecord {
  const ProjectControlReleaseRecord({
    required this.releaseId,
    required this.version,
    required this.maturity,
    required this.commit,
    required this.tag,
    required this.status,
    required this.includedModules,
    required this.verificationIds,
    required this.knownRisks,
    required this.buildArtifacts,
    required this.releaseDate,
    required this.notes,
  });

  final String releaseId;
  final String version;
  final String maturity;
  final String commit;
  final String tag;
  final String status;
  final List<String> includedModules;
  final List<String> verificationIds;
  final List<String> knownRisks;
  final List<String> buildArtifacts;
  final String releaseDate;
  final String notes;

  factory ProjectControlReleaseRecord.fromJson(
    Map<String, dynamic> json, {
    required String path,
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {
        'release_id',
        'version',
        'maturity',
        'commit',
        'tag',
        'status',
        'included_modules',
        'verification_ids',
        'known_risks',
        'build_artifacts',
        'release_date',
        'notes',
      },
      allowedKeys: const {
        'release_id',
        'version',
        'maturity',
        'commit',
        'tag',
        'status',
        'included_modules',
        'verification_ids',
        'known_risks',
        'build_artifacts',
        'release_date',
        'notes',
      },
    );
    return ProjectControlReleaseRecord(
      releaseId: _readString(data, 'release_id', path: path),
      version: _readString(data, 'version', path: path),
      maturity: _readString(data, 'maturity', path: path),
      commit: _readString(data, 'commit', path: path),
      tag: _readString(data, 'tag', path: path),
      status: _readString(data, 'status', path: path),
      includedModules: _readStringList(data, 'included_modules', path: path),
      verificationIds: _readStringList(data, 'verification_ids', path: path),
      knownRisks: _readStringList(data, 'known_risks', path: path),
      buildArtifacts: _readStringList(data, 'build_artifacts', path: path),
      releaseDate: _readString(data, 'release_date', path: path),
      notes: _readString(data, 'notes', path: path),
    );
  }
}

class ProjectControlRiskRecord {
  const ProjectControlRiskRecord({
    required this.riskId,
    required this.title,
    required this.severity,
    required this.likelihood,
    required this.affectedModules,
    required this.description,
    required this.evidence,
    required this.mitigation,
    required this.owner,
    required this.status,
    required this.targetRelease,
    required this.createdDate,
    required this.lastReviewedDate,
  });

  final String riskId;
  final String title;
  final String severity;
  final String likelihood;
  final List<String> affectedModules;
  final String description;
  final List<String> evidence;
  final String mitigation;
  final String owner;
  final String status;
  final String targetRelease;
  final String createdDate;
  final String lastReviewedDate;

  factory ProjectControlRiskRecord.fromJson(
    Map<String, dynamic> json, {
    required String path,
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {
        'risk_id',
        'title',
        'severity',
        'likelihood',
        'affected_modules',
        'description',
        'evidence',
        'mitigation',
        'owner',
        'status',
        'target_release',
        'created_date',
        'last_reviewed_date',
      },
      allowedKeys: const {
        'risk_id',
        'title',
        'severity',
        'likelihood',
        'affected_modules',
        'description',
        'evidence',
        'mitigation',
        'owner',
        'status',
        'target_release',
        'created_date',
        'last_reviewed_date',
      },
    );
    return ProjectControlRiskRecord(
      riskId: _readString(data, 'risk_id', path: path),
      title: _readString(data, 'title', path: path),
      severity: _readString(data, 'severity', path: path),
      likelihood: _readString(data, 'likelihood', path: path),
      affectedModules: _readStringList(data, 'affected_modules', path: path),
      description: _readString(data, 'description', path: path),
      evidence: _readStringList(data, 'evidence', path: path),
      mitigation: _readString(data, 'mitigation', path: path),
      owner: _readString(data, 'owner', path: path),
      status: _readString(data, 'status', path: path),
      targetRelease: _readString(data, 'target_release', path: path),
      createdDate: _readString(data, 'created_date', path: path),
      lastReviewedDate: _readString(data, 'last_reviewed_date', path: path),
    );
  }
}

class ProjectControlVerificationRecord {
  const ProjectControlVerificationRecord({
    required this.verificationId,
    required this.scope,
    required this.commit,
    required this.branch,
    required this.environment,
    required this.commands,
    required this.result,
    required this.warnings,
    required this.evidencePaths,
    required this.buildArtifacts,
    required this.buildHashes,
    required this.date,
    required this.limitations,
  });

  final String verificationId;
  final String scope;
  final String commit;
  final String branch;
  final String environment;
  final List<String> commands;
  final String result;
  final List<String> warnings;
  final List<String> evidencePaths;
  final List<String> buildArtifacts;
  final List<String> buildHashes;
  final String date;
  final List<String> limitations;

  factory ProjectControlVerificationRecord.fromJson(
    Map<String, dynamic> json, {
    required String path,
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {
        'verification_id',
        'scope',
        'commit',
        'branch',
        'environment',
        'commands',
        'result',
        'warnings',
        'evidence_paths',
        'build_artifacts',
        'build_hashes',
        'date',
        'limitations',
      },
      allowedKeys: const {
        'verification_id',
        'scope',
        'commit',
        'branch',
        'environment',
        'commands',
        'result',
        'warnings',
        'evidence_paths',
        'build_artifacts',
        'build_hashes',
        'date',
        'limitations',
      },
    );
    return ProjectControlVerificationRecord(
      verificationId: _readString(data, 'verification_id', path: path),
      scope: _readString(data, 'scope', path: path),
      commit: _readString(data, 'commit', path: path),
      branch: _readString(data, 'branch', path: path),
      environment: _readString(data, 'environment', path: path),
      commands: _readStringList(data, 'commands', path: path),
      result: _readString(data, 'result', path: path),
      warnings: _readStringList(data, 'warnings', path: path),
      evidencePaths: _readStringList(data, 'evidence_paths', path: path),
      buildArtifacts: _readStringList(data, 'build_artifacts', path: path),
      buildHashes: _readStringList(data, 'build_hashes', path: path),
      date: _readString(data, 'date', path: path),
      limitations: _readStringList(data, 'limitations', path: path),
    );
  }
}

class ProjectControlStatusDefinitionRecord {
  const ProjectControlStatusDefinitionRecord({
    required this.value,
    required this.definition,
  });

  final String value;
  final String definition;

  factory ProjectControlStatusDefinitionRecord.fromJson(
    Map<String, dynamic> json, {
    required String path,
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {'value', 'definition'},
      allowedKeys: const {'value', 'definition'},
    );
    return ProjectControlStatusDefinitionRecord(
      value: _readString(data, 'value', path: path),
      definition: _readString(data, 'definition', path: path),
    );
  }
}

class ProjectControlStatusDefinitionsRecord {
  const ProjectControlStatusDefinitionsRecord({
    required this.schemaVersion,
    required this.moduleMaturityValues,
    required this.verificationStates,
    required this.documentationStates,
    required this.releaseReadinessStates,
    required this.riskSeverities,
    required this.riskStatusValues,
  });

  final int schemaVersion;
  final List<ProjectControlStatusDefinitionRecord> moduleMaturityValues;
  final List<ProjectControlStatusDefinitionRecord> verificationStates;
  final List<ProjectControlStatusDefinitionRecord> documentationStates;
  final List<ProjectControlStatusDefinitionRecord> releaseReadinessStates;
  final List<ProjectControlStatusDefinitionRecord> riskSeverities;
  final List<ProjectControlStatusDefinitionRecord> riskStatusValues;

  factory ProjectControlStatusDefinitionsRecord.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.statusDefinitions',
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {
        'schema_version',
        'module_maturity_values',
        'verification_states',
        'documentation_states',
        'release_readiness_states',
        'risk_severities',
        'risk_status_values',
      },
      allowedKeys: const {
        'schema_version',
        'module_maturity_values',
        'verification_states',
        'documentation_states',
        'release_readiness_states',
        'risk_severities',
        'risk_status_values',
      },
    );
    return ProjectControlStatusDefinitionsRecord(
      schemaVersion: _readInt(data, 'schema_version', path: path),
      moduleMaturityValues: _readTypedList(
        data,
        'module_maturity_values',
        path: path,
        parser: ProjectControlStatusDefinitionRecord.fromJson,
      ),
      verificationStates: _readTypedList(
        data,
        'verification_states',
        path: path,
        parser: ProjectControlStatusDefinitionRecord.fromJson,
      ),
      documentationStates: _readTypedList(
        data,
        'documentation_states',
        path: path,
        parser: ProjectControlStatusDefinitionRecord.fromJson,
      ),
      releaseReadinessStates: _readTypedList(
        data,
        'release_readiness_states',
        path: path,
        parser: ProjectControlStatusDefinitionRecord.fromJson,
      ),
      riskSeverities: _readTypedList(
        data,
        'risk_severities',
        path: path,
        parser: ProjectControlStatusDefinitionRecord.fromJson,
      ),
      riskStatusValues: _readTypedList(
        data,
        'risk_status_values',
        path: path,
        parser: ProjectControlStatusDefinitionRecord.fromJson,
      ),
    );
  }
}

class ProjectControlArchitectureBoundaryObservationRecord {
  const ProjectControlArchitectureBoundaryObservationRecord({
    required this.module,
    required this.issue,
  });

  final String module;
  final String issue;

  factory ProjectControlArchitectureBoundaryObservationRecord.fromJson(
    Map<String, dynamic> json, {
    required String path,
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {'module', 'issue'},
      allowedKeys: const {'module', 'issue'},
    );
    return ProjectControlArchitectureBoundaryObservationRecord(
      module: _readString(data, 'module', path: path),
      issue: _readString(data, 'issue', path: path),
    );
  }
}

class ProjectControlArchitectureBoundariesRecord {
  const ProjectControlArchitectureBoundariesRecord({
    required this.schemaVersion,
    required this.layers,
    required this.rules,
    required this.observations,
  });

  final int schemaVersion;
  final List<String> layers;
  final List<String> rules;
  final List<ProjectControlArchitectureBoundaryObservationRecord> observations;

  factory ProjectControlArchitectureBoundariesRecord.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.architectureBoundaries',
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {'schema_version', 'layers', 'rules', 'observations'},
      allowedKeys: const {'schema_version', 'layers', 'rules', 'observations'},
    );
    return ProjectControlArchitectureBoundariesRecord(
      schemaVersion: _readInt(data, 'schema_version', path: path),
      layers: _readStringList(data, 'layers', path: path),
      rules: _readStringList(data, 'rules', path: path),
      observations: _readTypedList(
        data,
        'observations',
        path: path,
        parser: ProjectControlArchitectureBoundaryObservationRecord.fromJson,
      ),
    );
  }
}

class ProjectControlDocumentationCountsRecord {
  const ProjectControlDocumentationCountsRecord({
    required this.missing,
    required this.partial,
  });

  final int missing;
  final int partial;

  factory ProjectControlDocumentationCountsRecord.fromJson(
    Map<String, dynamic> json, {
    required String path,
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {'missing', 'partial'},
      allowedKeys: const {'missing', 'partial'},
    );
    return ProjectControlDocumentationCountsRecord(
      missing: _readInt(data, 'missing', path: path),
      partial: _readInt(data, 'partial', path: path),
    );
  }
}

class ProjectControlCurrentStateRecord {
  const ProjectControlCurrentStateRecord({
    required this.applicationVersion,
    required this.branch,
    required this.ciStatus,
    required this.commit,
    required this.databaseSchemaVersion,
    required this.documentationCounts,
    required this.documentationFilesFound,
  });

  final String applicationVersion;
  final String branch;
  final String ciStatus;
  final String commit;
  final String databaseSchemaVersion;
  final ProjectControlDocumentationCountsRecord documentationCounts;
  final List<String> documentationFilesFound;

  factory ProjectControlCurrentStateRecord.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.currentState',
  }) {
    _requireFields(
      json,
      path: path,
      requiredKeys: const {
        'application_version',
        'branch',
        'ci_status',
        'commit',
        'database_schema_version',
        'documentation_counts',
        'documentation_files_found',
      },
    );
    return ProjectControlCurrentStateRecord(
      applicationVersion: _readString(json, 'application_version', path: path),
      branch: _readString(json, 'branch', path: path),
      ciStatus: _readString(json, 'ci_status', path: path),
      commit: _readString(json, 'commit', path: path),
      databaseSchemaVersion: _readString(
        json,
        'database_schema_version',
        path: path,
      ),
      documentationCounts: ProjectControlDocumentationCountsRecord.fromJson(
        _readObject(
          json,
          'documentation_counts',
          path: path,
          requiredKeys: const {'missing', 'partial'},
          allowedKeys: const {'missing', 'partial'},
        ),
        path: '$path.documentation_counts',
      ),
      documentationFilesFound: _readStringList(
        json,
        'documentation_files_found',
        path: path,
      ),
    );
  }
}

class ProjectControlRepositoryHealthRecord {
  const ProjectControlRepositoryHealthRecord({
    required this.branch,
    required this.commit,
    required this.riskTotals,
    required this.warnings,
    required this.workingTreeState,
    required this.scanId,
  });

  final String branch;
  final String commit;
  final ProjectControlRepositoryRiskTotalsRecord riskTotals;
  final List<String> warnings;
  final String workingTreeState;
  final String scanId;

  factory ProjectControlRepositoryHealthRecord.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.repositoryHealth',
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {
        'branch',
        'commit',
        'risk_totals',
        'warnings',
        'working_tree_state',
        'scan_id',
      },
      allowedKeys: const {
        'branch',
        'commit',
        'risk_totals',
        'warnings',
        'working_tree_state',
        'scan_id',
      },
    );
    return ProjectControlRepositoryHealthRecord(
      branch: _readString(data, 'branch', path: path),
      commit: _readString(data, 'commit', path: path),
      riskTotals: ProjectControlRepositoryRiskTotalsRecord.fromJson(
        _readObject(
          data,
          'risk_totals',
          path: path,
          requiredKeys: const {'by_severity', 'by_status', 'total'},
          allowedKeys: const {'by_severity', 'by_status', 'total'},
        ),
        path: '$path.risk_totals',
      ),
      warnings: _readStringList(data, 'warnings', path: path),
      workingTreeState: _readString(data, 'working_tree_state', path: path),
      scanId: _readString(data, 'scan_id', path: path),
    );
  }
}

class ProjectControlReleaseReadinessRecord {
  const ProjectControlReleaseReadinessRecord({
    required this.reasons,
    required this.result,
  });

  final List<String> reasons;
  final String result;

  factory ProjectControlReleaseReadinessRecord.fromJson(
    Map<String, dynamic> json, {
    String path = r'$.releaseReadiness',
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {'reasons', 'result'},
      allowedKeys: const {'reasons', 'result'},
    );
    return ProjectControlReleaseReadinessRecord(
      reasons: _readStringList(data, 'reasons', path: path),
      result: _readString(data, 'result', path: path),
    );
  }
}

Map<String, dynamic> _strictObject(
  Map<String, dynamic> json, {
  required String path,
  required String sourcePath,
  required Set<String> requiredKeys,
  required Set<String> allowedKeys,
}) {
  final unexpected = json.keys
      .where((key) => !allowedKeys.contains(key))
      .toList(growable: false);
  if (unexpected.isNotEmpty) {
    throw ProjectControlContextAdapterException(
      message: 'Unexpected field at $path: ${unexpected.join(', ')}.',
      sourcePath: sourcePath,
    );
  }
  final missing = requiredKeys
      .where((key) => !json.containsKey(key))
      .toList(growable: false);
  if (missing.isNotEmpty) {
    throw ProjectControlContextAdapterException(
      message: 'Missing field at $path: ${missing.join(', ')}.',
      sourcePath: sourcePath,
    );
  }
  return Map.unmodifiable(json);
}

void _requireFields(
  Map<String, dynamic> json, {
  required String path,
  required Set<String> requiredKeys,
}) {
  final missing = requiredKeys
      .where((key) => !json.containsKey(key))
      .toList(growable: false);
  if (missing.isNotEmpty) {
    throw ProjectControlContextAdapterException(
      message: 'Missing field at $path: ${missing.join(', ')}.',
      sourcePath: path,
    );
  }
}

Map<String, dynamic> _readObject(
  Map<String, dynamic> json,
  String key, {
  required String path,
  required Set<String> requiredKeys,
  required Set<String> allowedKeys,
}) {
  final value = json[key];
  if (value is! Map) {
    throw ProjectControlContextAdapterException(
      message: 'Expected an object at $path.$key.',
      sourcePath: path,
    );
  }
  final normalized = <String, dynamic>{
    for (final entry in value.entries) entry.key.toString(): entry.value,
  };
  return _strictObject(
    normalized,
    path: '$path.$key',
    sourcePath: path,
    requiredKeys: requiredKeys,
    allowedKeys: allowedKeys,
  );
}

String _readString(
  Map<String, dynamic> json,
  String key, {
  required String path,
}) {
  final value = json[key];
  if (value is! String) {
    throw ProjectControlContextAdapterException(
      message: 'Expected a string at $path.$key.',
      sourcePath: path,
    );
  }
  return value;
}

bool _readBool(Map<String, dynamic> json, String key, {required String path}) {
  final value = json[key];
  if (value is! bool) {
    throw ProjectControlContextAdapterException(
      message: 'Expected a boolean at $path.$key.',
      sourcePath: path,
    );
  }
  return value;
}

int _readInt(Map<String, dynamic> json, String key, {required String path}) {
  final value = json[key];
  if (value is! int) {
    throw ProjectControlContextAdapterException(
      message: 'Expected an integer at $path.$key.',
      sourcePath: path,
    );
  }
  return value;
}

List<String> _readStringList(
  Map<String, dynamic> json,
  String key, {
  required String path,
}) {
  final value = json[key];
  if (value is! List) {
    throw ProjectControlContextAdapterException(
      message: 'Expected an array at $path.$key.',
      sourcePath: path,
    );
  }
  final result = <String>[];
  for (var index = 0; index < value.length; index++) {
    final item = value[index];
    if (item is! String) {
      throw ProjectControlContextAdapterException(
        message: 'Expected a string at $path.$key[$index].',
        sourcePath: path,
      );
    }
    result.add(item);
  }
  return List.unmodifiable(result);
}

List<T> _readTypedList<T>(
  Map<String, dynamic> json,
  String key, {
  required String path,
  required T Function(Map<String, dynamic> json, {required String path}) parser,
}) {
  final value = json[key];
  if (value is! List) {
    throw ProjectControlContextAdapterException(
      message: 'Expected an array at $path.$key.',
      sourcePath: path,
    );
  }
  final result = <T>[];
  for (var index = 0; index < value.length; index++) {
    final item = value[index];
    if (item is! Map) {
      throw ProjectControlContextAdapterException(
        message: 'Expected an object at $path.$key[$index].',
        sourcePath: path,
      );
    }
    final normalized = <String, dynamic>{
      for (final entry in item.entries) entry.key.toString(): entry.value,
    };
    result.add(parser(normalized, path: '$path.$key[$index]'));
  }
  return List.unmodifiable(result);
}

class ProjectControlContextAdapterException implements Exception {
  const ProjectControlContextAdapterException({
    required this.message,
    required this.sourcePath,
    this.cause,
  });

  final String message;
  final String sourcePath;
  final Object? cause;

  @override
  String toString() {
    final buffer = StringBuffer('ProjectControlContextAdapterException: ');
    buffer.write(message);
    if (sourcePath.isNotEmpty) {
      buffer.write(' [source: $sourcePath]');
    }
    if (cause != null) {
      buffer.write(' [cause: $cause]');
    }
    return buffer.toString();
  }
}

class ProjectControlRepositoryRiskTotalsRecord {
  const ProjectControlRepositoryRiskTotalsRecord({
    required this.bySeverity,
    required this.byStatus,
    required this.total,
  });

  final Map<String, int> bySeverity;
  final Map<String, int> byStatus;
  final int total;

  factory ProjectControlRepositoryRiskTotalsRecord.fromJson(
    Map<String, dynamic> json, {
    required String path,
  }) {
    final data = _strictObject(
      json,
      path: path,
      sourcePath: path,
      requiredKeys: const {'by_severity', 'by_status', 'total'},
      allowedKeys: const {'by_severity', 'by_status', 'total'},
    );
    return ProjectControlRepositoryRiskTotalsRecord(
      bySeverity: _readIntMapObject(data, 'by_severity', path: path),
      byStatus: _readIntMapObject(data, 'by_status', path: path),
      total: _readInt(data, 'total', path: path),
    );
  }
}

Map<String, int> _readIntMapObject(
  Map<String, dynamic> json,
  String key, {
  required String path,
}) {
  final value = json[key];
  if (value is! Map) {
    throw ProjectControlContextAdapterException(
      message: 'Expected an object at $path.$key.',
      sourcePath: path,
    );
  }
  final result = <String, int>{};
  for (final entry in value.entries) {
    final entryKey = entry.key.toString();
    final entryValue = entry.value;
    if (entryValue is! int) {
      throw ProjectControlContextAdapterException(
        message: 'Expected an integer at $path.$key.$entryKey.',
        sourcePath: path,
      );
    }
    result[entryKey] = entryValue;
  }
  return Map.unmodifiable(result);
}
