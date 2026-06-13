import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/modules/module_event_bus.dart';

void main() {
  test('module event bus publishes and streams module events', () async {
    final bus = ModuleEventBus();
    addTearDown(bus.dispose);

    final eventFuture = bus.events.first;
    final event = ModuleEvent(
      moduleId: 'alpha_module',
      type: ModuleEventType.registryReloaded,
      timestamp: DateTime.parse('2026-06-13T10:00:00Z'),
      message: 'Registry refreshed locally.',
      details: const <String, dynamic>{'source': 'test'},
    );

    bus.publish(event);

    final received = await eventFuture;
    expect(received.moduleId, 'alpha_module');
    expect(received.type, ModuleEventType.registryReloaded);
    expect(received.message, 'Registry refreshed locally.');
    expect(received.details['source'], 'test');
  });
}
