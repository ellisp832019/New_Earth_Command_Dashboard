import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../dock/dock_layout_state.dart';
import '../dock/dock_position.dart';

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
    final payload = _readPayload();
    payload['enabledById'] = states;
    payload['updatedAt'] = DateTime.now().toIso8601String();

    final file = File(stateFilePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(JsonEncoder.withIndent('  ').convert(payload));
  }

  Map<String, dynamic> loadHubUiState() {
    final payload = _readPayload();
    final uiState = payload['hubUiState'];
    if (uiState is Map<String, dynamic>) {
      return uiState;
    }
    if (uiState is Map) {
      return uiState.map((key, value) => MapEntry(key.toString(), value));
    }
    return const <String, dynamic>{};
  }

  Future<void> saveHubUiState(Map<String, dynamic> state) async {
    final payload = _readPayload();
    payload['hubUiState'] = state;
    payload['updatedAt'] = DateTime.now().toIso8601String();

    final file = File(stateFilePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(JsonEncoder.withIndent('  ').convert(payload));
  }

  DockLayoutState loadDockLayoutState() {
    final payload = _readPayload();
    final dockLayoutState = payload['dockLayoutState'];
    if (dockLayoutState is Map<String, dynamic>) {
      return DockLayoutState.fromJson(dockLayoutState);
    }
    if (dockLayoutState is Map) {
      return DockLayoutState.fromJson(
        dockLayoutState.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    return const DockLayoutState();
  }

  Future<void> saveDockPosition(String moduleId, DockPosition position) async {
    final current = loadDockLayoutState();
    final updated = current.setPosition(moduleId, position);
    await saveDockLayoutState(updated);
  }

  Future<void> saveDockLayoutState(DockLayoutState state) async {
    final payload = _readPayload();
    payload['dockLayoutState'] = state.toJson();
    payload['updatedAt'] = DateTime.now().toIso8601String();

    final file = File(stateFilePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(JsonEncoder.withIndent('  ').convert(payload));
  }

  Map<String, dynamic> _readPayload() {
    final file = File(stateFilePath);
    if (!file.existsSync()) {
      return <String, dynamic>{};
    }

    try {
      final contents = file.readAsStringSync();
      final decoded = jsonDecode(contents);
      if (decoded is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded);
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{};
  }
}
