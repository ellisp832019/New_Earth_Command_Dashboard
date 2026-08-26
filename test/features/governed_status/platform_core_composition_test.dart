import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/features/governed_status/application/platform_core_composition.dart';
import 'package:new_earth_command_dashboard/features/governed_status/data/configured_platform_core_declaration_source.dart';
import 'package:new_earth_command_dashboard/features/governed_status/data/platform_core_governed_status_reader.dart';
import 'package:new_earth_command_dashboard/features/governed_status/data/platform_core_runtime_configuration.dart';

void main() {
  test('valid configuration composes source and reader lazily', () async {
    final root = await Directory.systemTemp.createTemp(
      'platform core composition ',
    );
    addTearDown(() => root.delete(recursive: true));
    final container = ProviderContainer(
      overrides: [
        platformCoreRuntimeConfigurationResolverProvider.overrideWithValue(
          PlatformCoreRuntimeConfigurationResolver(
            environment: {
              PlatformCoreRuntimeConfigurationResolver.defaultEnvironmentKey:
                  root.path,
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final composition = await container.read(
      platformCoreProductionCompositionProvider.future,
    );

    expect(composition.isAvailable, isTrue);
    expect(
      composition.declarationSource,
      isA<ConfiguredPlatformCoreDeclarationSource>(),
    );
    expect(
      composition.governedStatusReader,
      isA<PlatformCoreGovernedStatusReader>(),
    );
    expect(await root.list().toList(), isEmpty);
  });

  test(
    'missing and invalid configuration remain safe and unavailable',
    () async {
      for (final environment in [
        const <String, String?>{},
        const <String, String?>{
          PlatformCoreRuntimeConfigurationResolver.defaultEnvironmentKey:
              'relative-root',
        },
      ]) {
        final container = ProviderContainer(
          overrides: [
            platformCoreRuntimeConfigurationResolverProvider.overrideWithValue(
              PlatformCoreRuntimeConfigurationResolver(
                environment: environment,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final composition = await container.read(
          platformCoreProductionCompositionProvider.future,
        );

        expect(composition.isAvailable, isFalse);
        expect(composition.declarationSource, isNull);
        expect(composition.governedStatusReader, isNull);
      }
    },
  );
}
