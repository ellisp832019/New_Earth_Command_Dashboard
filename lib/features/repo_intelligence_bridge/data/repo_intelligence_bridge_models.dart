import 'dart:convert';

class RepoIntelligenceBridgeProfile {
  const RepoIntelligenceBridgeProfile({
    required this.fileName,
    required this.projectName,
    required this.projectType,
    required this.repoRoot,
    required this.sourceOfTruth,
    required this.obsidianVaultPath,
    required this.obsidianProjectFolder,
    required this.dashboardExportPath,
    required this.ignore,
    required this.lockedRules,
    required this.safeAiPermissions,
    required this.blockedAiPermissions,
  });

  final String fileName;
  final String projectName;
  final String projectType;
  final String repoRoot;
  final String sourceOfTruth;
  final String obsidianVaultPath;
  final String obsidianProjectFolder;
  final String dashboardExportPath;
  final List<String> ignore;
  final List<String> lockedRules;
  final List<String> safeAiPermissions;
  final List<String> blockedAiPermissions;

  RepoIntelligenceBridgeProfile copyWith({
    String? fileName,
    String? projectName,
    String? projectType,
    String? repoRoot,
    String? sourceOfTruth,
    String? obsidianVaultPath,
    String? obsidianProjectFolder,
    String? dashboardExportPath,
    List<String>? ignore,
    List<String>? lockedRules,
    List<String>? safeAiPermissions,
    List<String>? blockedAiPermissions,
  }) {
    return RepoIntelligenceBridgeProfile(
      fileName: fileName ?? this.fileName,
      projectName: projectName ?? this.projectName,
      projectType: projectType ?? this.projectType,
      repoRoot: repoRoot ?? this.repoRoot,
      sourceOfTruth: sourceOfTruth ?? this.sourceOfTruth,
      obsidianVaultPath: obsidianVaultPath ?? this.obsidianVaultPath,
      obsidianProjectFolder:
          obsidianProjectFolder ?? this.obsidianProjectFolder,
      dashboardExportPath: dashboardExportPath ?? this.dashboardExportPath,
      ignore: ignore ?? this.ignore,
      lockedRules: lockedRules ?? this.lockedRules,
      safeAiPermissions: safeAiPermissions ?? this.safeAiPermissions,
      blockedAiPermissions: blockedAiPermissions ?? this.blockedAiPermissions,
    );
  }

  factory RepoIntelligenceBridgeProfile.fromJson(
    Map<String, dynamic> json, {
    required String fileName,
  }) {
    return RepoIntelligenceBridgeProfile(
      fileName: fileName,
      projectName: json['project_name']?.toString() ?? fileName,
      projectType: json['project_type']?.toString() ?? '',
      repoRoot: json['repo_root']?.toString() ?? '.',
      sourceOfTruth: json['source_of_truth']?.toString() ?? '',
      obsidianVaultPath: json['obsidian_vault_path']?.toString() ?? '',
      obsidianProjectFolder: json['obsidian_project_folder']?.toString() ?? '',
      dashboardExportPath: json['dashboard_export_path']?.toString() ?? '',
      ignore: stringListValue(json['ignore']),
      lockedRules: stringListValue(json['locked_rules']),
      safeAiPermissions: stringListValue(json['safe_ai_permissions']),
      blockedAiPermissions: stringListValue(json['blocked_ai_permissions']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'project_name': projectName,
      'project_type': projectType,
      'repo_root': repoRoot,
      'source_of_truth': sourceOfTruth,
      'obsidian_vault_path': obsidianVaultPath,
      'obsidian_project_folder': obsidianProjectFolder,
      'dashboard_export_path': dashboardExportPath,
      'ignore': ignore,
      'locked_rules': lockedRules,
      'safe_ai_permissions': safeAiPermissions,
      'blocked_ai_permissions': blockedAiPermissions,
    };
  }
}

class RepoIntelligenceBridgeState {
  const RepoIntelligenceBridgeState({
    required this.activeProfileFile,
    required this.dashboardExportRoot,
    required this.obsidianVaultPath,
    required this.moduleHomePath,
    this.lastSyncAt,
  });

  final String activeProfileFile;
  final String dashboardExportRoot;
  final String obsidianVaultPath;
  final String moduleHomePath;
  final String? lastSyncAt;

  factory RepoIntelligenceBridgeState.fromJson(Map<String, dynamic> json) {
    return RepoIntelligenceBridgeState(
      activeProfileFile: json['active_profile_file']?.toString() ?? '',
      dashboardExportRoot: json['dashboard_export_root']?.toString() ?? '',
      obsidianVaultPath: json['obsidian_vault_path']?.toString() ?? '',
      moduleHomePath: json['module_home_path']?.toString() ?? '',
      lastSyncAt: json['last_sync_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'active_profile_file': activeProfileFile,
      'dashboard_export_root': dashboardExportRoot,
      'obsidian_vault_path': obsidianVaultPath,
      'module_home_path': moduleHomePath,
      'last_sync_at': lastSyncAt,
    };
  }
}

class RepoIntelligenceBridgeProjectStatus {
  const RepoIntelligenceBridgeProjectStatus({
    required this.project,
    required this.type,
    required this.status,
    required this.phase,
    required this.health,
    required this.healthScore,
    required this.currentFocus,
    required this.generatedAt,
    required this.repoRoot,
  });

  final String project;
  final String type;
  final String status;
  final String phase;
  final String health;
  final int healthScore;
  final String currentFocus;
  final String generatedAt;
  final String repoRoot;

  factory RepoIntelligenceBridgeProjectStatus.fromJson(
    Map<String, dynamic> json,
  ) {
    return RepoIntelligenceBridgeProjectStatus(
      project: json['project']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      phase: json['phase']?.toString() ?? '',
      health: json['health']?.toString() ?? '',
      healthScore: intValue(json['health_score']),
      currentFocus: json['current_focus']?.toString() ?? '',
      generatedAt: json['generated_at']?.toString() ?? '',
      repoRoot: json['repo_root']?.toString() ?? '',
    );
  }
}

class RepoIntelligenceBridgeNextAction {
  const RepoIntelligenceBridgeNextAction({
    required this.title,
    required this.priority,
    required this.status,
  });

  final String title;
  final String priority;
  final String status;

  factory RepoIntelligenceBridgeNextAction.fromJson(Map<String, dynamic> json) {
    return RepoIntelligenceBridgeNextAction(
      title: json['title']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

class RepoIntelligenceBridgeTask {
  const RepoIntelligenceBridgeTask({
    required this.file,
    required this.line,
    required this.text,
  });

  final String file;
  final int line;
  final String text;

  factory RepoIntelligenceBridgeTask.fromJson(Map<String, dynamic> json) {
    return RepoIntelligenceBridgeTask(
      file: json['file']?.toString() ?? '',
      line: intValue(json['line']),
      text: json['text']?.toString() ?? '',
    );
  }
}

class RepoIntelligenceBridgeRisk {
  const RepoIntelligenceBridgeRisk({
    required this.title,
    required this.severity,
    required this.mitigation,
  });

  final String title;
  final String severity;
  final String mitigation;

  factory RepoIntelligenceBridgeRisk.fromJson(Map<String, dynamic> json) {
    return RepoIntelligenceBridgeRisk(
      title: json['title']?.toString() ?? '',
      severity: json['severity']?.toString() ?? '',
      mitigation: json['mitigation']?.toString() ?? '',
    );
  }
}

class RepoIntelligenceBridgeDecision {
  const RepoIntelligenceBridgeDecision({
    required this.decision,
    required this.status,
  });

  final String decision;
  final String status;

  factory RepoIntelligenceBridgeDecision.fromJson(Map<String, dynamic> json) {
    return RepoIntelligenceBridgeDecision(
      decision: json['decision']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

class RepoIntelligenceBridgeTimelineItem {
  const RepoIntelligenceBridgeTimelineItem({
    required this.stage,
    required this.status,
  });

  final String stage;
  final String status;

  factory RepoIntelligenceBridgeTimelineItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return RepoIntelligenceBridgeTimelineItem(
      stage: json['stage']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

class RepoIntelligenceBridgeRepoHealthCheck {
  const RepoIntelligenceBridgeRepoHealthCheck({
    required this.name,
    required this.status,
  });

  final String name;
  final String status;

  factory RepoIntelligenceBridgeRepoHealthCheck.fromJson(
    Map<String, dynamic> json,
  ) {
    return RepoIntelligenceBridgeRepoHealthCheck(
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

class RepoIntelligenceBridgeRepoHealth {
  const RepoIntelligenceBridgeRepoHealth({
    required this.health,
    required this.score,
    required this.totalScannedFiles,
    required this.todoMarkers,
    required this.checks,
    required this.generatedAt,
  });

  final String health;
  final int score;
  final int totalScannedFiles;
  final int todoMarkers;
  final List<RepoIntelligenceBridgeRepoHealthCheck> checks;
  final String generatedAt;

  factory RepoIntelligenceBridgeRepoHealth.fromJson(Map<String, dynamic> json) {
    return RepoIntelligenceBridgeRepoHealth(
      health: json['health']?.toString() ?? '',
      score: intValue(json['score']),
      totalScannedFiles: intValue(json['total_scanned_files']),
      todoMarkers: intValue(json['todo_markers']),
      checks: mapListValue(json['checks'])
          .map(RepoIntelligenceBridgeRepoHealthCheck.fromJson)
          .toList(growable: false),
      generatedAt: json['generated_at']?.toString() ?? '',
    );
  }
}

class RepoIntelligenceBridgeAiContext {
  const RepoIntelligenceBridgeAiContext({
    required this.projectName,
    required this.sourceOfTruth,
    required this.generatedAt,
    required this.lockedRules,
    required this.safeAiPermissions,
    required this.blockedAiPermissions,
    required this.humanApprovalRequired,
  });

  final String projectName;
  final String sourceOfTruth;
  final String generatedAt;
  final List<String> lockedRules;
  final List<String> safeAiPermissions;
  final List<String> blockedAiPermissions;
  final List<String> humanApprovalRequired;

  factory RepoIntelligenceBridgeAiContext.fromJson(Map<String, dynamic> json) {
    return RepoIntelligenceBridgeAiContext(
      projectName: json['project_name']?.toString() ?? '',
      sourceOfTruth: json['source_of_truth']?.toString() ?? '',
      generatedAt: json['generated_at']?.toString() ?? '',
      lockedRules: stringListValue(json['locked_rules']),
      safeAiPermissions: stringListValue(json['safe_ai_permissions']),
      blockedAiPermissions: stringListValue(json['blocked_ai_permissions']),
      humanApprovalRequired: stringListValue(json['human_approval_required']),
    );
  }
}

class RepoIntelligenceBridgeSyncManifest {
  const RepoIntelligenceBridgeSyncManifest({
    required this.generatedAt,
    required this.project,
    required this.exports,
  });

  final String generatedAt;
  final String project;
  final List<String> exports;

  factory RepoIntelligenceBridgeSyncManifest.fromJson(
    Map<String, dynamic> json,
  ) {
    return RepoIntelligenceBridgeSyncManifest(
      generatedAt: json['generated_at']?.toString() ??
          json['last_sync']?.toString() ??
          '',
      project: json['project']?.toString() ?? '',
      exports: stringListValue(json['exports']),
    );
  }
}

class RepoIntelligenceBridgeExportBundle {
  const RepoIntelligenceBridgeExportBundle({
    required this.projectStatus,
    required this.nextActions,
    required this.tasks,
    required this.risks,
    required this.decisions,
    required this.timeline,
    required this.repoHealth,
    required this.aiContext,
    required this.syncManifest,
  });

  final RepoIntelligenceBridgeProjectStatus? projectStatus;
  final List<RepoIntelligenceBridgeNextAction> nextActions;
  final List<RepoIntelligenceBridgeTask> tasks;
  final List<RepoIntelligenceBridgeRisk> risks;
  final List<RepoIntelligenceBridgeDecision> decisions;
  final List<RepoIntelligenceBridgeTimelineItem> timeline;
  final RepoIntelligenceBridgeRepoHealth? repoHealth;
  final RepoIntelligenceBridgeAiContext? aiContext;
  final RepoIntelligenceBridgeSyncManifest? syncManifest;
}

class RepoIntelligenceBridgeWorkspace {
  const RepoIntelligenceBridgeWorkspace({
    required this.profiles,
    required this.state,
    required this.activeProfile,
    required this.bundle,
    required this.syncLogLines,
    required this.lastSyncTime,
    required this.exportsDirectory,
    required this.moduleHomePath,
    required this.obsidianVaultPath,
  });

  final List<RepoIntelligenceBridgeProfile> profiles;
  final RepoIntelligenceBridgeState state;
  final RepoIntelligenceBridgeProfile activeProfile;
  final RepoIntelligenceBridgeExportBundle bundle;
  final List<String> syncLogLines;
  final DateTime? lastSyncTime;
  final String exportsDirectory;
  final String moduleHomePath;
  final String obsidianVaultPath;
}

int intValue(Object? value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

List<String> stringListValue(Object? value) {
  if (value is List) {
    return value.map((entry) => entry.toString()).toList(growable: false);
  }
  if (value is String && value.trim().isNotEmpty) {
    return const LineSplitter()
        .convert(value)
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
  }
  return const <String>[];
}

List<Map<String, dynamic>> mapListValue(Object? value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }

  return value
      .whereType<Map>()
      .map((entry) => Map<String, dynamic>.from(entry.cast<dynamic, dynamic>()))
      .toList(growable: false);
}
