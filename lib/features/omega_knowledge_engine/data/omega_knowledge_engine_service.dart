import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

class OmegaKnowledgeEngineRepoProfile {
  const OmegaKnowledgeEngineRepoProfile({
    required this.key,
    required this.name,
    required this.pathWindows,
    required this.type,
  });

  final String key;
  final String name;
  final String pathWindows;
  final String type;

  factory OmegaKnowledgeEngineRepoProfile.fromJson(Map<String, dynamic> json) {
    return OmegaKnowledgeEngineRepoProfile(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      pathWindows: json['pathWindows']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'pathWindows': pathWindows,
      'type': type,
    };
  }
}

class OmegaKnowledgeEngineSettings {
  const OmegaKnowledgeEngineSettings({
    required this.safetyMode,
    required this.repoRootPath,
    required this.outputDir,
    required this.obsidianExportDir,
    required this.omegaOsRootWindows,
    required this.obsidianVaultWindows,
    required this.repoProfiles,
  });

  final String safetyMode;
  final String repoRootPath;
  final String outputDir;
  final String obsidianExportDir;
  final String omegaOsRootWindows;
  final String obsidianVaultWindows;
  final List<OmegaKnowledgeEngineRepoProfile> repoProfiles;

  factory OmegaKnowledgeEngineSettings.defaults({
    String? moduleRootPath,
  }) {
    final root = moduleRootPath ??
        path.join(Directory.current.path, 'modules', '26_OMEGA_KNOWLEDGE_ENGINE');
    return OmegaKnowledgeEngineSettings(
      safetyMode: 'scan_report_only',
      repoRootPath: path.join(Directory.current.path),
      outputDir: path.join(root, 'output'),
      obsidianExportDir: path.join(root, 'output', 'obsidian_export'),
      omegaOsRootWindows: r'D:\NEW_EARTH_OMEGA_OS_PACK',
      obsidianVaultWindows:
          r'D:\NEW_EARTH_OMEGA_OS_PACK\09_KNOWLEDGE_VAULT_OBSIDIAN',
      repoProfiles: const [
        OmegaKnowledgeEngineRepoProfile(
          key: 'dashboard',
          name: 'Dashboard repo',
          pathWindows: r'D:\Dev\Projects\New Earth - Command Dashboard',
          type: 'flutter_app',
        ),
        OmegaKnowledgeEngineRepoProfile(
          key: 'microgrow',
          name: 'MicroGrow repo',
          pathWindows: r'D:\Dev\Projects\MicroGrow',
          type: 'firmware_flutter',
        ),
        OmegaKnowledgeEngineRepoProfile(
          key: 'biocalm',
          name: 'BioCalm repo',
          pathWindows: r'D:\Dev\Projects\BioCalm',
          type: 'wearable_firmware',
        ),
        OmegaKnowledgeEngineRepoProfile(
          key: 'new_earth_living',
          name: 'New Earth Living repo',
          pathWindows: r'D:\Dev\Projects\New Earth Living',
          type: 'flutter_app',
        ),
        OmegaKnowledgeEngineRepoProfile(
          key: 'future_repos',
          name: 'Future repos',
          pathWindows: r'D:\Dev\Projects\Future New Earth Repos',
          type: 'future',
        ),
      ],
    );
  }

  factory OmegaKnowledgeEngineSettings.fromJson(
    Map<String, dynamic> json, {
    String? moduleRootPath,
  }) {
    final repoProfiles = <OmegaKnowledgeEngineRepoProfile>[];
    final rawProfiles = json['repoProfiles'];
    if (rawProfiles is List) {
      for (final item in rawProfiles) {
        if (item is Map<String, dynamic>) {
          repoProfiles.add(OmegaKnowledgeEngineRepoProfile.fromJson(item));
        }
      }
    }

    final defaults = OmegaKnowledgeEngineSettings.defaults(
      moduleRootPath: moduleRootPath,
    );

    return OmegaKnowledgeEngineSettings(
      safetyMode: json['safetyMode']?.toString() ?? defaults.safetyMode,
      repoRootPath: json['repoRootPath']?.toString() ?? defaults.repoRootPath,
      outputDir: json['outputDir']?.toString() ?? defaults.outputDir,
      obsidianExportDir:
          json['obsidianExportDir']?.toString() ?? defaults.obsidianExportDir,
      omegaOsRootWindows:
          json['omegaOsRootWindows']?.toString() ?? defaults.omegaOsRootWindows,
      obsidianVaultWindows: json['obsidianVaultWindows']?.toString() ??
          defaults.obsidianVaultWindows,
      repoProfiles: repoProfiles.isEmpty ? defaults.repoProfiles : repoProfiles,
    );
  }

  OmegaKnowledgeEngineSettings copyWith({
    String? safetyMode,
    String? repoRootPath,
    String? outputDir,
    String? obsidianExportDir,
    String? omegaOsRootWindows,
    String? obsidianVaultWindows,
    List<OmegaKnowledgeEngineRepoProfile>? repoProfiles,
  }) {
    return OmegaKnowledgeEngineSettings(
      safetyMode: safetyMode ?? this.safetyMode,
      repoRootPath: repoRootPath ?? this.repoRootPath,
      outputDir: outputDir ?? this.outputDir,
      obsidianExportDir: obsidianExportDir ?? this.obsidianExportDir,
      omegaOsRootWindows: omegaOsRootWindows ?? this.omegaOsRootWindows,
      obsidianVaultWindows: obsidianVaultWindows ?? this.obsidianVaultWindows,
      repoProfiles: repoProfiles ?? this.repoProfiles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'safetyMode': safetyMode,
      'repoRootPath': repoRootPath,
      'outputDir': outputDir,
      'obsidianExportDir': obsidianExportDir,
      'omegaOsRootWindows': omegaOsRootWindows,
      'obsidianVaultWindows': obsidianVaultWindows,
      'repoProfiles': repoProfiles.map((profile) => profile.toJson()).toList(),
    };
  }
}

class OmegaKnowledgeEngineSnapshot {
  const OmegaKnowledgeEngineSnapshot({
    required this.settings,
    required this.repositoryIndexText,
    required this.repositoryIndexJson,
    required this.learningNotesText,
    required this.commentSuggestionsText,
    required this.architectureMapText,
    required this.projectMemoryText,
    required this.obsidianExportFiles,
    required this.generatedAt,
    required this.repositoryCount,
    required this.filesScanned,
    required this.scanCommand,
  });

  final OmegaKnowledgeEngineSettings settings;
  final String repositoryIndexText;
  final Map<String, dynamic> repositoryIndexJson;
  final String learningNotesText;
  final String commentSuggestionsText;
  final String architectureMapText;
  final String projectMemoryText;
  final List<String> obsidianExportFiles;
  final String generatedAt;
  final int repositoryCount;
  final int filesScanned;
  final String scanCommand;
}

class OmegaKnowledgeEngineRunResult {
  const OmegaKnowledgeEngineRunResult({
    required this.exitCode,
    required this.command,
    required this.stdout,
    required this.stderr,
    required this.startedAt,
    required this.finishedAt,
  });

  final int exitCode;
  final String command;
  final String stdout;
  final String stderr;
  final DateTime startedAt;
  final DateTime finishedAt;

  bool get succeeded => exitCode == 0;

  String get summary {
    final trimmedStdout = stdout.trim();
    final trimmedStderr = stderr.trim();
    if (trimmedStdout.isNotEmpty) {
      return trimmedStdout;
    }
    if (trimmedStderr.isNotEmpty) {
      return trimmedStderr;
    }
    return succeeded ? 'Omega Knowledge Engine scan completed.' : 'Omega Knowledge Engine scan failed.';
  }
}

class OmegaKnowledgeEngineService {
  OmegaKnowledgeEngineService({String? moduleRootPath})
      : moduleRootPath = moduleRootPath ??
            path.join(Directory.current.path, 'modules', '26_OMEGA_KNOWLEDGE_ENGINE');

  final String moduleRootPath;

  String get _configPath =>
      path.join(moduleRootPath, 'config', 'knowledge_engine_settings.json');

  String get _outputRoot => path.join(moduleRootPath, 'output');

  String get _obsidianExportRoot => path.join(_outputRoot, 'obsidian_export');

  Future<OmegaKnowledgeEngineSettings> loadSettings() async {
    final file = File(_configPath);
    if (!file.existsSync()) {
      return OmegaKnowledgeEngineSettings.defaults(moduleRootPath: moduleRootPath);
    }

    try {
      final raw = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return OmegaKnowledgeEngineSettings.fromJson(
        raw,
        moduleRootPath: moduleRootPath,
      );
    } catch (_) {
      return OmegaKnowledgeEngineSettings.defaults(moduleRootPath: moduleRootPath);
    }
  }

  Future<void> saveSettings(OmegaKnowledgeEngineSettings settings) async {
    final file = File(_configPath);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(settings.toJson()),
    );
  }

  Future<OmegaKnowledgeEngineSnapshot> loadSnapshot() async {
    final settings = await loadSettings();
    final repositoryIndexText = await _readText(
      path.join(_outputRoot, 'repository_index.md'),
    );
    final repositoryIndexJson = await _readJson(
      path.join(_outputRoot, 'repository_index.json'),
    );
    final learningNotesText = await _readText(
      path.join(_outputRoot, 'code_learning_notes.md'),
    );
    final commentSuggestionsText = await _readText(
      path.join(_outputRoot, 'comment_suggestions.md'),
    );
    final architectureMapText = await _readText(
      path.join(_outputRoot, 'architecture_map.md'),
    );
    final projectMemoryText = await _readText(
      path.join(_outputRoot, 'project_memory.md'),
    );
    final obsidianExportFiles = await _listFiles(_obsidianExportRoot);

    return OmegaKnowledgeEngineSnapshot(
      settings: settings,
      repositoryIndexText: repositoryIndexText,
      repositoryIndexJson: repositoryIndexJson,
      learningNotesText: learningNotesText,
      commentSuggestionsText: commentSuggestionsText,
      architectureMapText: architectureMapText,
      projectMemoryText: projectMemoryText,
      obsidianExportFiles: obsidianExportFiles,
      generatedAt: repositoryIndexJson['generated_at']?.toString() ??
          'Not run yet',
      repositoryCount: repositoryIndexJson['repository_count'] is int
          ? repositoryIndexJson['repository_count'] as int
          : settings.repoProfiles.length,
      filesScanned: repositoryIndexJson['files_scanned'] is int
          ? repositoryIndexJson['files_scanned'] as int
          : 0,
      scanCommand: buildScanCommand(),
    );
  }

  String buildScanCommand() {
    return 'python scripts/omega_scan.py --config config/engine_config.yaml';
  }

  Future<OmegaKnowledgeEngineRunResult> runScan({
    OmegaKnowledgeEngineSettings? settings,
  }) async {
    final startedAt = DateTime.now();
    final scriptPath = path.join(moduleRootPath, 'scripts', 'omega_scan.py');
    final scriptFile = File(scriptPath);
    if (!scriptFile.existsSync()) {
      return OmegaKnowledgeEngineRunResult(
        exitCode: 1,
        command: buildScanCommand(),
        stdout: '',
        stderr: 'Scanner script not found at $scriptPath',
        startedAt: startedAt,
        finishedAt: DateTime.now(),
      );
    }

    try {
      final process = await Process.start(
        'python',
        <String>[scriptPath, '--config', 'config/engine_config.yaml'],
        workingDirectory: moduleRootPath,
        runInShell: true,
      );

      final stdoutBuffer = StringBuffer();
      final stderrBuffer = StringBuffer();
      final stdoutDone = process.stdout
          .transform(utf8.decoder)
          .listen(stdoutBuffer.write)
          .asFuture<void>();
      final stderrDone = process.stderr
          .transform(utf8.decoder)
          .listen(stderrBuffer.write)
          .asFuture<void>();
      final exitCode = await process.exitCode;
      await Future.wait([stdoutDone, stderrDone]);

      return OmegaKnowledgeEngineRunResult(
        exitCode: exitCode,
        command: buildScanCommand(),
        stdout: stdoutBuffer.toString(),
        stderr: stderrBuffer.toString(),
        startedAt: startedAt,
        finishedAt: DateTime.now(),
      );
    } on ProcessException catch (error) {
      return OmegaKnowledgeEngineRunResult(
        exitCode: 1,
        command: buildScanCommand(),
        stdout: '',
        stderr: error.message,
        startedAt: startedAt,
        finishedAt: DateTime.now(),
      );
    }
  }

  Future<String> _readText(String absolutePath) async {
    final file = File(absolutePath);
    if (!file.existsSync()) {
      return 'Sample output missing: ${path.relative(absolutePath, from: moduleRootPath)}';
    }

    return file.readAsString();
  }

  Future<Map<String, dynamic>> _readJson(String absolutePath) async {
    final file = File(absolutePath);
    if (!file.existsSync()) {
      return const <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Fall through to empty output.
    }
    return const <String, dynamic>{};
  }

  Future<List<String>> _listFiles(String absolutePath) async {
    final dir = Directory(absolutePath);
    if (!dir.existsSync()) {
      return const <String>[];
    }

    final entries = <String>[];
    await for (final entity in dir.list(recursive: false, followLinks: false)) {
      if (entity is File) {
        entries.add(path.basename(entity.path));
      }
    }
    entries.sort();
    return entries;
  }
}
