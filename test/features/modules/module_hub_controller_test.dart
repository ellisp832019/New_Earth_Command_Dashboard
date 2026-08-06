import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/core/modules/module_event_bus.dart';
import 'package:new_earth_command_dashboard/core/modules/module_hub_state_repository.dart';
import 'package:new_earth_command_dashboard/features/modules/application/module_hub_controller.dart';

void main() {
  test(
    'module hub controller publishes events for reload and enable changes',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'module-hub-controller-',
      );

      final repository = ModuleHubStateRepository(
        stateFilePath: path.join(tempRoot.path, 'module_hub_state.json'),
      );
      final bus = ModuleEventBus();
      addTearDown(bus.dispose);

      final container = ProviderContainer(
        overrides: [
          moduleHubStateRepositoryProvider.overrideWithValue(repository),
          moduleEventBusProvider.overrideWithValue(bus),
        ],
      );
      addTearDown(container.dispose);

      final events = <ModuleEvent>[];
      final subscription = bus.events.listen(events.add);
      addTearDown(subscription.cancel);

      await container.read(moduleHubModulesProvider.notifier).reload();
      await container
          .read(moduleHubModulesProvider.notifier)
          .setModuleEnabled('module_hub', false);

      await Future<void>.delayed(Duration.zero);

      expect(
        events.any(
          (event) =>
              event.moduleId == 'module_hub' &&
              event.type == ModuleEventType.registryReloaded,
        ),
        isTrue,
      );
      expect(
        events.any(
          (event) =>
              event.moduleId == 'module_hub' &&
              event.type == ModuleEventType.enabledChanged,
        ),
        isTrue,
      );

      await subscription.cancel();
      container.dispose();
      await bus.dispose();
    },
  );
}
