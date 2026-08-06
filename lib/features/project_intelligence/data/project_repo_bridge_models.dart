import 'dart:convert';

class RepoTodoMarker {
  const RepoTodoMarker({
    required this.file,
    required this.line,
    required this.text,
  });

  final String file;
  final int line;
  final String text;

  factory RepoTodoMarker.fromJson(Map<String, dynamic> json) {
    return RepoTodoMarker(
      file: json['file']?.toString() ?? '',
      line: intValue(json['line']),
      text: json['text']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'file': file, 'line': line, 'text': text};
  }
}

class RepoSnapshot {
  const RepoSnapshot({
    required this.id,
    required this.name,
    required this.repoPath,
    required this.exists,
    required this.isGitRepo,
    required this.tags,
    required this.dirtyFiles,
    required this.recentCommits,
    required this.docsFound,
    required this.todoMarkers,
    required this.scanWarnings,
    required this.scannedAt,
    this.dashboardProjectId,
    this.omegaPath,
    this.status,
    this.type,
    this.currentPhase,
    this.branch,
    this.latestCommit,
    this.latestCommitDate,
  });

  final String id;
  final String name;
  final String repoPath;
  final String? dashboardProjectId;
  final String? omegaPath;
  final String? status;
  final String? type;
  final String? currentPhase;
  final bool exists;
  final bool isGitRepo;
  final String? branch;
  final String? latestCommit;
  final String? latestCommitDate;
  final List<String> tags;
  final List<String> dirtyFiles;
  final List<String> recentCommits;
  final List<String> docsFound;
  final List<RepoTodoMarker> todoMarkers;
  final List<String> scanWarnings;
  final String scannedAt;

  int get todoCount => todoMarkers.length;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'repo_path': repoPath,
      'dashboard_project_id': dashboardProjectId,
      'omega_path': omegaPath,
      'status': status,
      'type': type,
      'current_phase': currentPhase,
      'exists': exists,
      'is_git_repo': isGitRepo,
      'branch': branch,
      'latest_commit': latestCommit,
      'latest_commit_date': latestCommitDate,
      'tags': tags,
      'dirty_files': dirtyFiles,
      'recent_commits': recentCommits,
      'docs_found': docsFound,
      'todo_markers': todoMarkers.map((marker) => marker.toJson()).toList(),
      'scan_warnings': scanWarnings,
      'scanned_at': scannedAt,
    };
  }

  factory RepoSnapshot.fromJson(Map<String, dynamic> json) {
    return RepoSnapshot(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      repoPath: json['repo_path']?.toString() ?? '',
      dashboardProjectId: json['dashboard_project_id']?.toString(),
      omegaPath: json['omega_path']?.toString(),
      status: json['status']?.toString(),
      type: json['type']?.toString(),
      currentPhase: json['current_phase']?.toString(),
      exists: boolValue(json['exists']),
      isGitRepo: boolValue(json['is_git_repo']),
      branch: json['branch']?.toString(),
      latestCommit: json['latest_commit']?.toString(),
      latestCommitDate: json['latest_commit_date']?.toString(),
      tags: stringListValue(json['tags']),
      dirtyFiles: stringListValue(json['dirty_files']),
      recentCommits: stringListValue(json['recent_commits']),
      docsFound: stringListValue(json['docs_found']),
      todoMarkers: (json['todo_markers'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(RepoTodoMarker.fromJson)
          .toList(growable: false),
      scanWarnings: stringListValue(json['scan_warnings']),
      scannedAt: json['scanned_at']?.toString() ?? '',
    );
  }
}

class UnifiedTaskRecord {
  const UnifiedTaskRecord({
    required this.id,
    required this.title,
    required this.status,
    required this.projectId,
    required this.priority,
  });

  final String id;
  final String title;
  final String status;
  final String? projectId;
  final String? priority;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'status': status,
      'projectId': projectId,
      'priority': priority,
    };
  }
}

class UnifiedProjectRecord {
  const UnifiedProjectRecord({
    required this.projectId,
    required this.name,
    required this.dashboardStatus,
    required this.dashboardTasks,
    required this.repoLinked,
    required this.nextActions,
    required this.codexHandoffReady,
    required this.lastMergedAt,
    this.dashboardDescription,
    this.repoId,
    this.repoPath,
    this.omegaPath,
    this.currentPhase,
    this.latestRepoStatus,
  });

  final String projectId;
  final String name;
  final String dashboardStatus;
  final String? dashboardDescription;
  final List<UnifiedTaskRecord> dashboardTasks;
  final bool repoLinked;
  final String? repoId;
  final String? repoPath;
  final String? omegaPath;
  final String? currentPhase;
  final RepoSnapshot? latestRepoStatus;
  final List<String> nextActions;
  final bool codexHandoffReady;
  final String lastMergedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'projectId': projectId,
      'name': name,
      'dashboardStatus': dashboardStatus,
      'dashboardDescription': dashboardDescription,
      'dashboardTasks': dashboardTasks
          .map((task) => task.toJson())
          .toList(growable: false),
      'repoLinked': repoLinked,
      'repoId': repoId,
      'repoPath': repoPath,
      'omegaPath': omegaPath,
      'currentPhase': currentPhase,
      'latestRepoStatus': latestRepoStatus?.toJson(),
      'nextActions': nextActions,
      'codexHandoffReady': codexHandoffReady,
      'lastMergedAt': lastMergedAt,
    };
  }
}

class ProjectRepoBridgeBundle {
  const ProjectRepoBridgeBundle({
    required this.mergedAt,
    required this.projects,
    required this.outputPath,
  });

  final String mergedAt;
  final List<UnifiedProjectRecord> projects;
  final String outputPath;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'merged_at': mergedAt,
      'projects': projects.map((project) => project.toJson()).toList(),
    };
  }
}

int intValue(Object? value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool boolValue(Object? value) {
  if (value is bool) {
    return value;
  }
  final text = value?.toString().toLowerCase().trim();
  return text == 'true' || text == '1' || text == 'yes';
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
