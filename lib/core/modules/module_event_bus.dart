import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ModuleEventType {
  enabledChanged,
  dockPositionChanged,
  registryReloaded,
}

class ModuleEvent {
  const ModuleEvent({
    required this.moduleId,
    required this.type,
    required this.timestamp,
    this.message = '',
    this.details = const <String, dynamic>{},
  });

  final String moduleId;
  final ModuleEventType type;
  final DateTime timestamp;
  final String message;
  final Map<String, dynamic> details;
}

class ModuleEventBus {
  ModuleEventBus() : _controller = StreamController<ModuleEvent>.broadcast();

  final StreamController<ModuleEvent> _controller;

  Stream<ModuleEvent> get events => _controller.stream;

  void publish(ModuleEvent event) {
    if (_controller.isClosed) {
      return;
    }
    _controller.add(event);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

final moduleEventBusProvider = Provider<ModuleEventBus>((ref) {
  final bus = ModuleEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});
