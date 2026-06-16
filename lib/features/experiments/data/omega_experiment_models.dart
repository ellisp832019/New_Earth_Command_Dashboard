import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

enum OmegaExperimentStatus {
  idea,
  planned,
  ready,
  running,
  blocked,
  analysing,
  complete,
  archived,
}

extension OmegaExperimentStatusLabel on OmegaExperimentStatus {
  String get label {
    switch (this) {
      case OmegaExperimentStatus.idea:
        return 'Idea';
      case OmegaExperimentStatus.planned:
        return 'Planned';
      case OmegaExperimentStatus.ready:
        return 'Ready';
      case OmegaExperimentStatus.running:
        return 'Running';
      case OmegaExperimentStatus.blocked:
        return 'Blocked';
      case OmegaExperimentStatus.analysing:
        return 'Analysing';
      case OmegaExperimentStatus.complete:
        return 'Complete';
      case OmegaExperimentStatus.archived:
        return 'Archived';
    }
  }
}

extension OmegaExperimentStatusLifecycle on OmegaExperimentStatus {
  String get lifecycleLabel {
    switch (this) {
      case OmegaExperimentStatus.idea:
      case OmegaExperimentStatus.planned:
        return 'Draft';
      case OmegaExperimentStatus.ready:
        return 'Ready';
      case OmegaExperimentStatus.running:
        return 'Running';
      case OmegaExperimentStatus.blocked:
      case OmegaExperimentStatus.analysing:
        return 'Review needed';
      case OmegaExperimentStatus.complete:
        return 'Lesson captured';
      case OmegaExperimentStatus.archived:
        return 'Parked';
    }
  }

  bool get isActiveLifecycle {
    switch (this) {
      case OmegaExperimentStatus.idea:
      case OmegaExperimentStatus.planned:
      case OmegaExperimentStatus.ready:
      case OmegaExperimentStatus.running:
      case OmegaExperimentStatus.blocked:
      case OmegaExperimentStatus.analysing:
        return true;
      case OmegaExperimentStatus.complete:
      case OmegaExperimentStatus.archived:
        return false;
    }
  }
}

enum OmegaExperimentCategory {
  sensorValidation,
  circuitBlock,
  proteusSimulation,
  pcbValidation,
  firmwareTest,
  mechanicalTest,
  enclosureTest,
  powerTest,
  communicationTest,
  softwareTest,
  aiModelTest,
  userTest,
  grantStrategyTest,
  generalValidation,
}

extension OmegaExperimentCategoryLabel on OmegaExperimentCategory {
  String get label {
    switch (this) {
      case OmegaExperimentCategory.sensorValidation:
        return 'Sensor Validation';
      case OmegaExperimentCategory.circuitBlock:
        return 'Circuit Block';
      case OmegaExperimentCategory.proteusSimulation:
        return 'Proteus Simulation';
      case OmegaExperimentCategory.pcbValidation:
        return 'PCB Validation';
      case OmegaExperimentCategory.firmwareTest:
        return 'Firmware Test';
      case OmegaExperimentCategory.mechanicalTest:
        return 'Mechanical Test';
      case OmegaExperimentCategory.enclosureTest:
        return 'Enclosure Test';
      case OmegaExperimentCategory.powerTest:
        return 'Power Test';
      case OmegaExperimentCategory.communicationTest:
        return 'Communication Test';
      case OmegaExperimentCategory.softwareTest:
        return 'Software Test';
      case OmegaExperimentCategory.aiModelTest:
        return 'AI Model Test';
      case OmegaExperimentCategory.userTest:
        return 'User Test';
      case OmegaExperimentCategory.grantStrategyTest:
        return 'Grant Strategy Test';
      case OmegaExperimentCategory.generalValidation:
        return 'General Validation';
    }
  }
}

enum OmegaExperimentEvidenceType {
  note,
  data,
  log,
  image,
  screenshot,
  file,
}

extension OmegaExperimentEvidenceTypeLabel on OmegaExperimentEvidenceType {
  String get label {
    switch (this) {
      case OmegaExperimentEvidenceType.note:
        return 'Note';
      case OmegaExperimentEvidenceType.data:
        return 'Data';
      case OmegaExperimentEvidenceType.log:
        return 'Log';
      case OmegaExperimentEvidenceType.image:
        return 'Image';
      case OmegaExperimentEvidenceType.screenshot:
        return 'Screenshot';
      case OmegaExperimentEvidenceType.file:
        return 'File';
    }
  }
}

class OmegaExperimentConfig {
  const OmegaExperimentConfig({
    required this.omegaRoot,
    required this.experimentsRoot,
    required this.knowledgeRoot,
    required this.aiRoot,
    required this.visualRoot,
    required this.obsidianVault,
    required this.githubOwner,
    required this.githubRepo,
  });

  factory OmegaExperimentConfig.fromJson(Map<String, dynamic> data) {
    return OmegaExperimentConfig(
      omegaRoot: _string(data, const ['omega_root'], fallback: ''),
      experimentsRoot: _string(data, const ['experiments_root'], fallback: ''),
      knowledgeRoot: _string(data, const ['knowledge_root'], fallback: ''),
      aiRoot: _string(data, const ['ai_root'], fallback: ''),
      visualRoot: _string(data, const ['visual_root'], fallback: ''),
      obsidianVault: _string(data, const ['obsidian_vault'], fallback: ''),
      githubOwner: _string(data, const ['github_owner'], fallback: ''),
      githubRepo: _string(data, const ['github_repo'], fallback: ''),
    );
  }

  final String omegaRoot;
  final String experimentsRoot;
  final String knowledgeRoot;
  final String aiRoot;
  final String visualRoot;
  final String obsidianVault;
  final String githubOwner;
  final String githubRepo;

  List<String> get approvedRoots => [
    if (omegaRoot.isNotEmpty) omegaRoot,
    if (experimentsRoot.isNotEmpty) experimentsRoot,
    if (knowledgeRoot.isNotEmpty) knowledgeRoot,
    if (aiRoot.isNotEmpty) aiRoot,
    if (visualRoot.isNotEmpty) visualRoot,
    if (obsidianVault.isNotEmpty) obsidianVault,
  ];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'omega_root': omegaRoot,
      'experiments_root': experimentsRoot,
      'knowledge_root': knowledgeRoot,
      'ai_root': aiRoot,
      'visual_root': visualRoot,
      'obsidian_vault': obsidianVault,
      'github_owner': githubOwner,
      'github_repo': githubRepo,
    };
  }

  bool isSafePath(String rawPath) {
    if (rawPath.trim().isEmpty) {
      return false;
    }

    final normalized = p.normalize(rawPath);
    return approvedRoots.any((root) {
      if (root.trim().isEmpty) {
        return false;
      }
      final rootNormalized = p.normalize(root);
      if (normalized.toLowerCase() == rootNormalized.toLowerCase()) {
        return true;
      }
      return p.isWithin(rootNormalized, normalized);
    });
  }
}

class OmegaExperimentRecord {
  const OmegaExperimentRecord({
    required this.experimentId,
    required this.title,
    required this.project,
    required this.status,
    required this.category,
    required this.owner,
    required this.createdDate,
    required this.objective,
    required this.hypothesis,
    required this.testPlan,
    required this.setupNotes,
    required this.evidenceFiles,
    required this.measurements,
    required this.softwareUsed,
    required this.hardwareUsed,
    required this.results,
    required this.conclusion,
    required this.lessonLearned,
    required this.nextActions,
    required this.relatedRepoCommits,
    required this.relatedGithubIssues,
    required this.relatedObsidianNotes,
    this.projectLink = '',
  });

  factory OmegaExperimentRecord.fromJson(Map<String, dynamic> data) {
    return OmegaExperimentRecord(
      experimentId: _string(data, const ['experiment_id'], fallback: ''),
      title: _string(data, const ['title'], fallback: ''),
      project: _string(data, const ['project'], fallback: ''),
      projectLink: _string(data, const ['project_link'], fallback: ''),
      status: _parseStatus(_string(data, const ['status'], fallback: 'IDEA')),
      category: _parseCategory(
        _string(data, const ['category'], fallback: 'GENERAL_VALIDATION'),
      ),
      owner: _string(data, const ['owner'], fallback: ''),
      createdDate: _string(data, const ['created_date'], fallback: ''),
      objective: _string(data, const ['objective'], fallback: ''),
      hypothesis: _string(data, const ['hypothesis'], fallback: ''),
      testPlan: _string(data, const ['test_plan'], fallback: ''),
      setupNotes: _string(data, const ['setup_notes'], fallback: ''),
      evidenceFiles: _parseStringList(
        data['evidence_files'] ?? data['evidence'],
      ),
      measurements: _parseStringList(data['measurements']),
      softwareUsed: _parseStringList(data['software_used']),
      hardwareUsed: _parseStringList(data['hardware_used']),
      results: _string(
        data,
        const ['results', 'results_summary'],
        fallback: '',
      ),
      conclusion: _string(data, const ['conclusion'], fallback: ''),
      lessonLearned: _string(
        data,
        const ['lesson_learned', 'lessons_learned'],
        fallback: '',
      ),
      nextActions: _parseStringList(data['next_actions']),
      relatedRepoCommits: _parseStringList(data['related_repo_commits']),
      relatedGithubIssues: _parseStringList(data['related_github_issues']),
      relatedObsidianNotes: _parseStringList(data['related_obsidian_notes']),
    );
  }

  final String experimentId;
  final String title;
  final String project;
  final String projectLink;
  final OmegaExperimentStatus status;
  final OmegaExperimentCategory category;
  final String owner;
  final String createdDate;
  final String objective;
  final String hypothesis;
  final String testPlan;
  final String setupNotes;
  final List<String> evidenceFiles;
  final List<String> measurements;
  final List<String> softwareUsed;
  final List<String> hardwareUsed;
  final String results;
  final String conclusion;
  final String lessonLearned;
  final List<String> nextActions;
  final List<String> relatedRepoCommits;
  final List<String> relatedGithubIssues;
  final List<String> relatedObsidianNotes;

  bool get hasEvidence => evidenceFiles.isNotEmpty;

  bool get needsEvidence => evidenceFiles.isEmpty;

  bool get hasLesson => lessonLearned.trim().isNotEmpty;

  List<OmegaExperimentEvidenceType> get evidenceTypes {
    return evidenceFiles
        .map(_inferEvidenceType)
        .toSet()
        .toList(growable: false);
  }

  List<String> get evidenceLabels {
    return evidenceFiles
        .map((entry) => '${_inferEvidenceType(entry).label}: $entry')
        .toList(growable: false);
  }

  String get lessonThemeKey {
    final words = lessonLearned
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]+'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(5)
        .toList(growable: false);

    return words.join(' ');
  }

  bool get hasProjectLink => projectLink.trim().isNotEmpty;

  String get linkedProjectId {
    final candidate = projectLink.trim();
    if (candidate.isNotEmpty) {
      final segments = p.posix.split(candidate.replaceAll('\\', '/'));
      if (segments.isNotEmpty && segments.last.trim().isNotEmpty) {
        return segments.last.trim();
      }
    }

    return project
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  bool get hasAllCoreFields =>
      experimentId.isNotEmpty &&
      title.isNotEmpty &&
      project.isNotEmpty &&
      objective.isNotEmpty &&
      hypothesis.isNotEmpty &&
      testPlan.isNotEmpty &&
      setupNotes.isNotEmpty &&
      results.isNotEmpty &&
      conclusion.isNotEmpty &&
      lessonLearned.isNotEmpty &&
      nextActions.isNotEmpty;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'experiment_id': experimentId,
      'title': title,
      'project': project,
      'project_link': projectLink,
      'status': status.name.toUpperCase(),
      'category': category.name.toUpperCase(),
      'owner': owner,
      'created_date': createdDate,
      'objective': objective,
      'hypothesis': hypothesis,
      'test_plan': testPlan,
      'setup_notes': setupNotes,
      'evidence_files': evidenceFiles,
      'measurements': measurements,
      'software_used': softwareUsed,
      'hardware_used': hardwareUsed,
      'results': results,
      'conclusion': conclusion,
      'lesson_learned': lessonLearned,
      'next_actions': nextActions,
      'related_repo_commits': relatedRepoCommits,
      'related_github_issues': relatedGithubIssues,
      'related_obsidian_notes': relatedObsidianNotes,
    };
  }

  static bool isValidExperimentId(String value) {
    return RegExp(r'^EXP-\d{4}$').hasMatch(value);
  }
}

OmegaExperimentEvidenceType _inferEvidenceType(String rawEntry) {
  final value = rawEntry.trim().toLowerCase();
  final extension = p.extension(value);

  if (value.contains('screenshot')) {
    return OmegaExperimentEvidenceType.screenshot;
  }

  if (extension == '.png' ||
      extension == '.jpg' ||
      extension == '.jpeg' ||
      extension == '.webp' ||
      value.contains('image') ||
      value.contains('photo')) {
    return OmegaExperimentEvidenceType.image;
  }

  if (extension == '.csv' ||
      extension == '.json' ||
      extension == '.xls' ||
      extension == '.xlsx' ||
      value.contains('data')) {
    return OmegaExperimentEvidenceType.data;
  }

  if (extension == '.log' ||
      value.contains('log') ||
      value.contains('trace') ||
      value.contains('err')) {
    return OmegaExperimentEvidenceType.log;
  }

  if (extension == '.md' ||
      extension == '.txt' ||
      value.contains('note') ||
      value.contains('readme')) {
    return OmegaExperimentEvidenceType.note;
  }

  return OmegaExperimentEvidenceType.file;
}

class OmegaExperimentWorkspace {
  const OmegaExperimentWorkspace({
    required this.config,
    required this.experiments,
    required this.moduleRootPath,
    required this.storageRootPath,
    required this.supportedTools,
    required this.reportTemplates,
    required this.moduleRoutes,
  });

  final OmegaExperimentConfig config;
  final List<OmegaExperimentRecord> experiments;
  final String moduleRootPath;
  final String storageRootPath;
  final List<String> supportedTools;
  final List<String> reportTemplates;
  final List<String> moduleRoutes;

  int get experimentCount => experiments.length;

  int get activeExperimentCount =>
      experiments.where((experiment) => experiment.status.isActiveLifecycle).length;

  int get evidenceReadyCount =>
      experiments.where((experiment) => experiment.hasEvidence).length;

  int get needsEvidenceCount =>
      experiments.where((experiment) => experiment.needsEvidence).length;

  Map<OmegaExperimentEvidenceType, int> get evidenceTypeCounts {
    final counts = <OmegaExperimentEvidenceType, int>{};
    for (final experiment in experiments) {
      for (final type in experiment.evidenceTypes) {
        counts[type] = (counts[type] ?? 0) + 1;
      }
    }
    return counts;
  }

  List<OmegaExperimentRecord> get experimentsWithLessons {
    return experiments
        .where((experiment) => experiment.hasLesson)
        .toList(growable: false);
  }

  Map<String, int> get lessonThemeCounts {
    final counts = <String, int>{};
    for (final experiment in experimentsWithLessons) {
      final theme = experiment.lessonThemeKey;
      if (theme.isEmpty) {
        continue;
      }
      counts[theme] = (counts[theme] ?? 0) + 1;
    }
    return counts;
  }

  List<OmegaExperimentRecord> experimentsForProject(String project) {
    return experiments
        .where(
          (experiment) =>
              experiment.project.toLowerCase() == project.toLowerCase(),
        )
        .toList(growable: false);
  }
}

class OmegaExperimentRepository {
  const OmegaExperimentRepository({
    this.moduleRootPath = 'modules/00_OMEGA_EXPERIMENT_VALIDATION_ENGINE',
  });

  final String moduleRootPath;

  static const String _configFileName =
      'automation/config/local_paths.example.json';

  OmegaExperimentWorkspace loadWorkspace() {
    final config = loadConfig();
    final experiments = <OmegaExperimentRecord>[
      ..._loadSampleExperiments(),
      ..._loadStorageExperiments(),
    ];
    experiments.sort(
      (a, b) => a.experimentId.compareTo(b.experimentId),
    );

    return OmegaExperimentWorkspace(
      config: config,
      experiments: experiments,
      moduleRootPath: moduleRootPath,
      storageRootPath: p.join(moduleRootPath, 'storage'),
      supportedTools: const [
        'Obsidian',
        'GitHub',
        'VS Code',
        'Proteus',
        'KiCad',
        'Fusion 360',
        'PlatformIO',
        'Excel/CSV',
        'Python',
        'Ollama/local AI',
        'Flutter dashboard',
      ],
      reportTemplates: const [
        '00_EXPERIMENT_BRIEF.md',
        '01_TEST_PLAN.md',
        '02_RESULTS_REPORT.md',
        '03_LESSONS_LEARNED.md',
      ],
      moduleRoutes: const [
        '/experiments',
        '/experiments/new',
        '/experiments/evidence',
        '/experiments/results',
        '/experiments/reports',
        '/experiments/settings',
        '/experiments/integrations',
        '/experiments/ai-review',
      ],
    );
  }

  OmegaExperimentConfig loadConfig() {
    final paths = [
      p.join(moduleRootPath, 'automation', 'config', 'local_paths.json'),
      p.join(moduleRootPath, _configFileName),
    ];

    for (final candidate in paths) {
      final file = File(candidate);
      if (!file.existsSync()) {
        continue;
      }

      try {
        final decoded = jsonDecode(file.readAsStringSync());
        if (decoded is Map<String, dynamic>) {
          return OmegaExperimentConfig.fromJson(decoded);
        }
      } catch (_) {
        // Fall back to the next candidate or the default below.
      }
    }

    return OmegaExperimentConfig.fromJson(const <String, dynamic>{
      'omega_root': 'D:/NEW_EARTH_OMEGA_OS_PACK',
      'experiments_root':
          'D:/NEW_EARTH_OMEGA_OS_PACK/21_PROJECTS_AND_PROGRAMMES/_EXPERIMENTS',
      'knowledge_root':
          'D:/NEW_EARTH_OMEGA_OS_PACK/22_KNOWLEDGE_AND_LEARNING/EXPERIMENT_KNOWLEDGE_BASE',
      'ai_root':
          'D:/NEW_EARTH_OMEGA_OS_PACK/23_AI_AND_AUTOMATION/OMEGA_EXPERIMENT_ENGINE',
      'visual_root':
          'D:/NEW_EARTH_OMEGA_OS_PACK/99_VISUAL_INDEX_AND_MAPS/EXPERIMENT_VISUAL_LIBRARY',
      'obsidian_vault': 'D:/NEW_EARTH_OBSIDIAN_VAULT',
      'github_owner': 'ellisp832019',
      'github_repo': 'new-earth-dashboard',
    });
  }

  List<OmegaExperimentRecord> loadExperiments() {
    return [
      ..._loadSampleExperiments(),
      ..._loadStorageExperiments(),
    ]..sort((a, b) => a.experimentId.compareTo(b.experimentId));
  }

  List<OmegaExperimentRecord> _loadSampleExperiments() {
    final baseDir = Directory(p.join(moduleRootPath, 'sample_data', 'experiments'));
    if (!baseDir.existsSync()) {
      return const [];
    }

    final records = <OmegaExperimentRecord>[];
    for (final directory in baseDir
        .listSync(followLinks: false)
        .whereType<Directory>()) {
      final file = File(p.join(directory.path, 'experiment.json'));
      if (!file.existsSync()) {
        continue;
      }

      try {
        final decoded = jsonDecode(file.readAsStringSync());
        if (decoded is Map<String, dynamic>) {
          final record = OmegaExperimentRecord.fromJson(decoded);
          if (record.experimentId.isNotEmpty) {
            records.add(record);
          }
        }
      } catch (_) {
        // Ignore invalid sample records so the rest of the workspace still loads.
      }
    }

    return records;
  }

  List<OmegaExperimentRecord> _loadStorageExperiments() {
    final baseDir = Directory(p.join(moduleRootPath, 'storage', 'experiments'));
    if (!baseDir.existsSync()) {
      return const [];
    }

    final records = <OmegaExperimentRecord>[];
    for (final file in baseDir
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()) {
      if (!p.extension(file.path).toLowerCase().endsWith('.json')) {
        continue;
      }

      try {
        final decoded = jsonDecode(file.readAsStringSync());
        if (decoded is Map<String, dynamic>) {
          final record = OmegaExperimentRecord.fromJson(decoded);
          if (record.experimentId.isNotEmpty) {
            records.add(record);
          }
        }
      } catch (_) {
        // Ignore draft parsing issues and keep the safe-first load running.
      }
    }

    return records;
  }

  String nextExperimentId(Iterable<OmegaExperimentRecord> existing) {
    var highest = 0;
    for (final record in existing) {
      final match = RegExp(r'^EXP-(\d{4})$').firstMatch(record.experimentId);
      if (match == null) {
        continue;
      }
      final value = int.tryParse(match.group(1) ?? '');
      if (value != null && value > highest) {
        highest = value;
      }
    }

    return 'EXP-${(highest + 1).toString().padLeft(4, '0')}';
  }

  Future<String> createDraft(OmegaExperimentRecord draft) async {
    final draftDir = Directory(
      p.join(moduleRootPath, 'storage', 'experiments', 'drafts'),
    );
    if (!draftDir.existsSync()) {
      draftDir.createSync(recursive: true);
    }

    final baseName = '${draft.experimentId}_${_slug(draft.title)}.json';
    var outputPath = p.join(draftDir.path, baseName);
    if (File(outputPath).existsSync()) {
      outputPath = p.join(
        draftDir.path,
        '${draft.experimentId}_${DateTime.now().millisecondsSinceEpoch}.json',
      );
    }

    File(outputPath).writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(draft.toJson()),
    );
    return outputPath;
  }

  static String _slug(String value) {
    final slug = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return slug.isEmpty ? 'experiment' : slug;
  }
}

OmegaExperimentStatus _parseStatus(String rawValue) {
  switch (rawValue.trim().toUpperCase()) {
    case 'IDEA':
      return OmegaExperimentStatus.idea;
    case 'PLANNED':
      return OmegaExperimentStatus.planned;
    case 'READY':
      return OmegaExperimentStatus.ready;
    case 'RUNNING':
      return OmegaExperimentStatus.running;
    case 'BLOCKED':
      return OmegaExperimentStatus.blocked;
    case 'ANALYSING':
      return OmegaExperimentStatus.analysing;
    case 'COMPLETE':
      return OmegaExperimentStatus.complete;
    case 'ARCHIVED':
      return OmegaExperimentStatus.archived;
    default:
      return OmegaExperimentStatus.idea;
  }
}

OmegaExperimentCategory _parseCategory(String rawValue) {
  switch (rawValue.trim().toUpperCase()) {
    case 'SENSOR_VALIDATION':
      return OmegaExperimentCategory.sensorValidation;
    case 'CIRCUIT_BLOCK':
      return OmegaExperimentCategory.circuitBlock;
    case 'PROTEUS_SIMULATION':
      return OmegaExperimentCategory.proteusSimulation;
    case 'PCB_VALIDATION':
      return OmegaExperimentCategory.pcbValidation;
    case 'FIRMWARE_TEST':
      return OmegaExperimentCategory.firmwareTest;
    case 'MECHANICAL_TEST':
      return OmegaExperimentCategory.mechanicalTest;
    case 'ENCLOSURE_TEST':
      return OmegaExperimentCategory.enclosureTest;
    case 'POWER_TEST':
      return OmegaExperimentCategory.powerTest;
    case 'COMMUNICATION_TEST':
      return OmegaExperimentCategory.communicationTest;
    case 'SOFTWARE_TEST':
      return OmegaExperimentCategory.softwareTest;
    case 'AI_MODEL_TEST':
      return OmegaExperimentCategory.aiModelTest;
    case 'USER_TEST':
      return OmegaExperimentCategory.userTest;
    case 'GRANT_STRATEGY_TEST':
      return OmegaExperimentCategory.grantStrategyTest;
    default:
      return OmegaExperimentCategory.generalValidation;
  }
}

List<String> _parseStringList(dynamic rawValue) {
  if (rawValue is! List) {
    return const [];
  }

  return rawValue
      .whereType<Object?>()
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

String _string(
  Map<String, dynamic> data,
  List<String> keys, {
  required String fallback,
}) {
  for (final key in keys) {
    final value = data[key];
    if (value == null) {
      continue;
    }
    final text = value.toString().trim();
    if (text.isNotEmpty) {
      return text;
    }
  }
  return fallback;
}
