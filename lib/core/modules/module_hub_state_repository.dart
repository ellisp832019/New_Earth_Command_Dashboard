import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

class ModuleHubStateRepository {
  ModuleHubStateRepository({String? stateFilePath})
    : stateFilePath =
          stateFilePath ??
          path.join(Directory.current.path, 'modules', 'module_hub_state.json');

  final String stateFilePath;

  Map<String, bool> loadEnabledStates() {
    final file = File(stateFilePath);
    if (!file.existsSync()) {
      return const <String, bool>{};
    }

    try {
      final contents = file.readAsStringSync();
      final decoded = jsonDecode(contents);
      if (decoded is Map<String, dynamic>) {
        final enabledById = decoded['enabledById'];
        if (enabledById is Map) {
          return enabledById.map(
            (key, value) => MapEntry(key.toString(), value == true),
          );
        }
      }
    } catch (_) {
      return const <String, bool>{};
    }

    return const <String, bool>{};
  }

  Future<void> saveEnabledState(String moduleId, bool enabled) async {
    final states = Map<String, bool>.from(loadEnabledStates());
    states[moduleId] = enabled;
    await saveEnabledStates(states);
  }

  Future<void> saveEnabledStates(Map<String, bool> states) async {
    final file = File(stateFilePath);
    await file.parent.create(recursive: true);
    final payload = <String, dynamic>{
      'enabledById': states,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await file.writeAsString(JsonEncoder.withIndent('  ').convert(payload));
  }
}
