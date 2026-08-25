import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/features/governed_status/data/configured_platform_core_declaration_source.dart';
import 'package:new_earth_command_dashboard/features/governed_status/data/platform_core_runtime_configuration.dart';
import 'package:new_earth_command_dashboard/features/governed_status/domain/governed_status.dart';

void main() {
  test(
    'accepts an absolute Windows root with spaces without filesystem access',
    () async {
      const root = r'D:\New Earth\Platform Core';
      final resolver = PlatformCoreRuntimeConfigurationResolver(
        environment: {
          PlatformCoreRuntimeConfigurationResolver.defaultEnvironmentKey: root,
        },
        canonicalizeRoot: (normalized) async => normalized,
      );

      final configuration = await resolver.resolve();

      expect(configuration.isConfigured, isTrue);
      expect(configuration.canonicalRoot, root);
      expect(
        configuration.configurationSource,
        PlatformCoreRuntimeConfigurationResolver.defaultEnvironmentKey,
      );
    },
  );

  test('rejects relative and empty configuration without fallback', () async {
    final relative = PlatformCoreRuntimeConfigurationResolver(
      environment: const {'NEW_EARTH_PLATFORM_CORE_ROOT': 'relative-root'},
      canonicalizeRoot: (normalized) async => normalized,
    );
    final empty = PlatformCoreRuntimeConfigurationResolver(
      environment: const {'NEW_EARTH_PLATFORM_CORE_ROOT': '  '},
      canonicalizeRoot: (normalized) async => normalized,
    );

    expect(
      (await relative.resolve()).status,
      PlatformCoreRuntimeConfigurationStatus.invalidRoot,
    );
    expect(
      (await empty.resolve()).status,
      PlatformCoreRuntimeConfigurationStatus.notConfigured,
    );
  });

  test(
    'missing configured root is bounded and does not expose OS details',
    () async {
      final resolver = PlatformCoreRuntimeConfigurationResolver(
        environment: const {
          'NEW_EARTH_PLATFORM_CORE_ROOT': r'D:\missing\Platform Core',
        },
        canonicalizeRoot: (normalized) async => null,
      );

      final configuration = await resolver.resolve();

      expect(
        configuration.status,
        PlatformCoreRuntimeConfigurationStatus.unavailable,
      );
      expect(configuration.canonicalRoot, isNull);
      expect(configuration.reason, 'unavailable');
    },
  );

  test(
    'production canonicalizer accepts a real directory with spaces',
    () async {
      final root = await Directory.systemTemp.createTemp('platform core test ');
      addTearDown(() => root.delete(recursive: true));
      final resolver = PlatformCoreRuntimeConfigurationResolver(
        environment: {'NEW_EARTH_PLATFORM_CORE_ROOT': root.path},
      );

      final configuration = await resolver.resolve();

      expect(configuration.isConfigured, isTrue);
      expect(configuration.canonicalRoot, isNotEmpty);
      expect(configuration.canonicalRoot, isNot(contains('..')));
    },
  );

  test('resolved root can be passed to the declaration source seam', () async {
    final root = await Directory.systemTemp.createTemp('platform core source ');
    addTearDown(() => root.delete(recursive: true));
    final resolver = PlatformCoreRuntimeConfigurationResolver(
      environment: {'NEW_EARTH_PLATFORM_CORE_ROOT': root.path},
    );
    final configuration = await resolver.resolve();

    final source = ConfiguredPlatformCoreDeclarationSource(
      platformCoreRoot: configuration.canonicalRoot,
    );

    await expectLater(
      () => source.read(scope: _scope),
      throwsA(
        predicate<Object>(
          (error) =>
              error is ConfiguredPlatformCoreDeclarationException &&
              error.code == 'platform_core_registry_missing',
        ),
      ),
    );
  });
}

final _scope = GovernedStatusScope(
  canonicalId: 'new-earth-command-dashboard',
  displayName: 'New Earth Command Dashboard',
);
