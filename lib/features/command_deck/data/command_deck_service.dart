import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

enum CommandDeckCommandType { openUrl, openFolder, script, unknown }

class CommandDeckCommand {
  const CommandDeckCommand({
    required this.id,
    required this.label,
    required this.type,
    required this.target,
    required this.source,
    this.targetKey,
    this.requiresConfirmation = false,
  });

  factory CommandDeckCommand.fromJson(
    Map<String, dynamic> json,
    String source,
  ) {
    final typeValue = json['type']?.toString().trim().toLowerCase() ?? '';
    return CommandDeckCommand(
      id: json['id']?.toString().trim() ?? '',
      label: json['label']?.toString().trim() ?? 'Untitled command',
      type: switch (typeValue) {
        'open_url' => CommandDeckCommandType.openUrl,
        'open_folder' => CommandDeckCommandType.openFolder,
        'script' => CommandDeckCommandType.script,
        _ => CommandDeckCommandType.unknown,
      },
      target: json['target']?.toString().trim() ?? '',
      targetKey: json['target_key']?.toString().trim(),
      requiresConfirmation: json['requires_confirmation'] == true,
      source: source,
    );
  }

  final String id;
  final String label;
  final CommandDeckCommandType type;
  final String target;
  final String? targetKey;
  final bool requiresConfirmation;
  final String source;

  bool get isSafe => !requiresConfirmation;

  String get typeLabel => switch (type) {
    CommandDeckCommandType.openUrl => 'Open URL',
    CommandDeckCommandType.openFolder => 'Open folder',
    CommandDeckCommandType.script => 'Run script',
    CommandDeckCommandType.unknown => 'Unknown',
  };
}

class CommandDeckConfig {
  const CommandDeckConfig({
    required this.dashboardUrl,
    required this.omegaOsRoot,
    required this.obsidianVaultPath,
    required this.meetingsPath,
    required this.commandDeckPath,
    required this.projects,
    required this.obsEnabled,
    required this.startRecordingHotkey,
    required this.stopRecordingHotkey,
    required this.source,
  });

  factory CommandDeckConfig.fromJson(Map<String, dynamic> json, String source) {
    return CommandDeckConfig(
      dashboardUrl:
          json['dashboard_url']?.toString().trim() ?? 'http://localhost:3000',
      omegaOsRoot: json['omega_os_root']?.toString().trim() ?? '',
      obsidianVaultPath: json['obsidian_vault_path']?.toString().trim() ?? '',
      meetingsPath: json['meetings_path']?.toString().trim() ?? '',
      commandDeckPath: json['command_deck_path']?.toString().trim() ?? '',
      projects: Map<String, String>.from(
        (json['projects'] as Map<String, dynamic>? ?? const {}).map(
          (key, value) => MapEntry(key, value?.toString() ?? ''),
        ),
      ),
      obsEnabled: json['obs'] is Map<String, dynamic>
          ? json['obs']['enabled'] == true
          : false,
      startRecordingHotkey: json['obs'] is Map<String, dynamic>
          ? json['obs']['start_recording_hotkey']?.toString().trim() ?? ''
          : '',
      stopRecordingHotkey: json['obs'] is Map<String, dynamic>
          ? json['obs']['stop_recording_hotkey']?.toString().trim() ?? ''
          : '',
      source: source,
    );
  }

  final String dashboardUrl;
  final String omegaOsRoot;
  final String obsidianVaultPath;
  final String meetingsPath;
  final String commandDeckPath;
  final Map<String, String> projects;
  final bool obsEnabled;
  final String startRecordingHotkey;
  final String stopRecordingHotkey;
  final String source;

  String? lookupPath(String key) {
    if (key.isEmpty) {
      return null;
    }

    if (key == 'dashboard_url') {
      return dashboardUrl;
    }
    if (key == 'omega_os_root') {
      return omegaOsRoot;
    }
    if (key == 'obsidian_vault_path') {
      return obsidianVaultPath;
    }
    if (key == 'meetings_path') {
      return meetingsPath;
    }
    if (key == 'command_deck_path') {
      return commandDeckPath;
    }

    if (key.startsWith('projects.')) {
      return projects[key.substring('projects.'.length)];
    }

    return null;
  }
}

class CommandDeckRegistry {
  const CommandDeckRegistry({required this.commands, required this.source});

  factory CommandDeckRegistry.fromJson(
    Map<String, dynamic> json,
    String source,
  ) {
    final commands = (json['commands'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((item) => CommandDeckCommand.fromJson(item, source))
        .where((item) => item.id.isNotEmpty)
        .toList(growable: false);
    return CommandDeckRegistry(commands: commands, source: source);
  }

  final List<CommandDeckCommand> commands;
  final String source;
}

class CommandDeckWorkspace {
  const CommandDeckWorkspace({
    required this.moduleRoot,
    required this.config,
    required this.registry,
    required this.configPath,
    required this.registryPath,
  });

  final Directory moduleRoot;
  final CommandDeckConfig config;
  final CommandDeckRegistry registry;
  final String configPath;
  final String registryPath;
}

class CommandDeckService {
  CommandDeckService({Directory? workingDirectory})
    : _workingDirectory = workingDirectory ?? Directory.current;

  final Directory _workingDirectory;

  Directory moduleRootDirectory() {
    var current = _workingDirectory;
    while (true) {
      final candidate = Directory(
        path.join(current.path, 'modules', 'new_earth_command_deck'),
      );
      if (candidate.existsSync()) {
        return candidate;
      }

      final parent = current.parent;
      if (parent.path == current.path) {
        break;
      }
      current = parent;
    }

    return Directory(
      path.join(_workingDirectory.path, 'modules', 'new_earth_command_deck'),
    );
  }

  Future<CommandDeckWorkspace> loadWorkspace() async {
    final moduleRoot = moduleRootDirectory();
    final configFile = File(
      path.join(moduleRoot.path, 'config', 'command_deck.json'),
    );
    final configExampleFile = File(
      path.join(moduleRoot.path, 'config', 'command_deck.example.json'),
    );
    final registryFile = File(
      path.join(moduleRoot.path, 'config', 'command_registry.json'),
    );
    final registryExampleFile = File(
      path.join(moduleRoot.path, 'config', 'command_registry.example.json'),
    );

    final configSource = await _readFirstExistingFile([
      configFile,
      configExampleFile,
    ]);
    final registrySource = await _readFirstExistingFile([
      registryFile,
      registryExampleFile,
    ]);

    final config = CommandDeckConfig.fromJson(
      jsonDecode(configSource) as Map<String, dynamic>,
      configFile.existsSync() ? configFile.path : configExampleFile.path,
    );
    final registry = CommandDeckRegistry.fromJson(
      jsonDecode(registrySource) as Map<String, dynamic>,
      registryFile.existsSync() ? registryFile.path : registryExampleFile.path,
    );

    return CommandDeckWorkspace(
      moduleRoot: moduleRoot,
      config: config,
      registry: registry,
      configPath: configFile.existsSync()
          ? configFile.path
          : configExampleFile.path,
      registryPath: registryFile.existsSync()
          ? registryFile.path
          : registryExampleFile.path,
    );
  }

  Future<void> executeCommand(
    CommandDeckCommand command,
    CommandDeckConfig config,
  ) async {
    switch (command.type) {
      case CommandDeckCommandType.openUrl:
        await _openUrl(command.target);
        break;
      case CommandDeckCommandType.openFolder:
        await _openFolder(_resolveTarget(command, config));
        break;
      case CommandDeckCommandType.script:
        await _runScript(command, config);
        break;
      case CommandDeckCommandType.unknown:
        throw UnsupportedError('Unsupported command type: ${command.type}');
    }

    await _appendActionLog(command, config);
  }

  String? resolveTarget(CommandDeckCommand command, CommandDeckConfig config) {
    return _resolveTarget(command, config);
  }

  Future<String> _readFirstExistingFile(List<File> files) async {
    for (final file in files) {
      if (await file.exists()) {
        return file.readAsString();
      }
    }

    throw FileSystemException(
      'Could not find a Command Deck configuration file.',
      files.map((file) => file.path).join(', '),
    );
  }

  String? _resolveTarget(CommandDeckCommand command, CommandDeckConfig config) {
    if (command.type == CommandDeckCommandType.openUrl) {
      return command.target;
    }

    if (command.type == CommandDeckCommandType.script) {
      final target = command.target.trim();
      if (target.isEmpty) {
        return null;
      }
      final moduleRoot = moduleRootDirectory();
      final scriptPath = path.isAbsolute(target)
          ? target
          : path.join(moduleRoot.path, target);
      return scriptPath;
    }

    final key = command.targetKey?.trim() ?? command.target.trim();
    if (key.isEmpty) {
      return null;
    }

    final resolved = config.lookupPath(key);
    if (resolved != null && resolved.isNotEmpty) {
      return resolved;
    }

    final moduleRoot = moduleRootDirectory();
    final relativePath = path.join(moduleRoot.path, key);
    if (Directory(relativePath).existsSync() ||
        File(relativePath).existsSync()) {
      return relativePath;
    }

    return null;
  }

  Future<void> _openUrl(String url) async {
    if (url.trim().isEmpty) {
      return;
    }

    if (Platform.isWindows) {
      await Process.start('cmd.exe', [
        '/c',
        'start',
        '',
        url,
      ], runInShell: true);
      return;
    }

    if (Platform.isMacOS) {
      await Process.start('open', [url], runInShell: true);
      return;
    }

    await Process.start('xdg-open', [url], runInShell: true);
  }

  Future<void> _openFolder(String? folderPath) async {
    if (folderPath == null || folderPath.trim().isEmpty) {
      throw FileSystemException('Folder path could not be resolved.');
    }

    final normalizedPath = path.normalize(folderPath.trim());

    if (Platform.isWindows) {
      await Process.start('explorer.exe', [normalizedPath]);
      return;
    }

    if (Platform.isMacOS) {
      await Process.start('open', [normalizedPath]);
      return;
    }

    if (Platform.isLinux) {
      await Process.start('xdg-open', [normalizedPath]);
      return;
    }
  }

  Future<void> _runScript(
    CommandDeckCommand command,
    CommandDeckConfig config,
  ) async {
    final scriptPath = _resolveTarget(command, config);
    if (scriptPath == null) {
      throw FileSystemException('Script path could not be resolved.');
    }

    final scriptFile = File(scriptPath);
    if (!await scriptFile.exists()) {
      throw FileSystemException('Script file was not found.', scriptPath);
    }

    final pythonCommand = Platform.isWindows ? 'python' : 'python3';
    final workingDirectory = scriptFile.parent.path;
    final process = await Process.start(
      pythonCommand,
      [scriptFile.path],
      workingDirectory: workingDirectory,
      runInShell: true,
    );
    await process.exitCode;
  }

  Future<void> _appendActionLog(
    CommandDeckCommand command,
    CommandDeckConfig config,
  ) async {
    final moduleRoot = moduleRootDirectory();
    final runtimeDir = Directory(
      path.join(moduleRoot.path, 'dashboard_module', 'data', 'runtime'),
    );
    await runtimeDir.create(recursive: true);
    final logFile = File(
      path.join(runtimeDir.path, 'command_deck_action_log.jsonl'),
    );
    final entry = <String, Object?>{
      'timestamp': DateTime.now().toIso8601String(),
      'command_id': command.id,
      'label': command.label,
      'type': command.type.name,
      'source': command.source,
      'config_source': config.source,
    };
    await logFile.writeAsString(
      '${jsonEncode(entry)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}
