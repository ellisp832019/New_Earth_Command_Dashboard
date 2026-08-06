import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ModuleEventType { enabledChanged, dockPositionChanged, registryReloaded }

extension ModuleEventTypeLabel on ModuleEventType {
  String get label {
    switch (this) {
      case ModuleEventType.enabledChanged:
        return 'Enabled state changed';
      case ModuleEventType.dockPositionChanged:
        return 'Dock position changed';
      case ModuleEventType.registryReloaded:
        return 'Registry reloaded';
    }
  }
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

class ModuleRecentEventsController extends Notifier<List<ModuleEvent>> {
  StreamSubscription<ModuleEvent>? _subscription;

  @override
  List<ModuleEvent> build() {
    final bus = ref.read(moduleEventBusProvider);
    _subscription = bus.events.listen(_handleEvent);
    ref.onDispose(() {
      unawaited(_subscription?.cancel());
    });
    return const <ModuleEvent>[];
  }

  void _handleEvent(ModuleEvent event) {
    state = <ModuleEvent>[event, ...state].take(5).toList(growable: false);
  }
}

final moduleEventBusProvider = Provider<ModuleEventBus>((ref) {
  final bus = ModuleEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});

final moduleRecentEventsProvider =
    NotifierProvider<ModuleRecentEventsController, List<ModuleEvent>>(
      ModuleRecentEventsController.new,
    );
