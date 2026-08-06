import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/modules/module_event_bus.dart';

void main() {
  test('recent events provider updates from bus', () async {
    final bus = ModuleEventBus();
    final container = ProviderContainer(
      overrides: [
        moduleEventBusProvider.overrideWithValue(bus),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(moduleRecentEventsProvider), isEmpty);

    bus.publish(
      ModuleEvent(
        moduleId: 'module_hub',
        type: ModuleEventType.registryReloaded,
        timestamp: DateTime.utc(2026, 6, 13, 10, 0, 0),
        message: 'Module registry refreshed.',
      ),
    );

    await Future<void>.delayed(Duration.zero);

    final events = container.read(moduleRecentEventsProvider);
    expect(events, hasLength(1));
    expect(events.first.moduleId, 'module_hub');
  });
}
