import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/configured_platform_core_declaration_source.dart';
import '../data/platform_core_governed_status_reader.dart';
import '../data/platform_core_runtime_configuration.dart';
import '../domain/governed_status.dart';

final platformCoreRuntimeConfigurationResolverProvider =
    Provider<PlatformCoreRuntimeConfigurationResolver>((ref) {
      return PlatformCoreRuntimeConfigurationResolver();
    });

final platformCoreProductionCompositionProvider =
    FutureProvider<PlatformCoreProductionComposition>((ref) async {
      final resolver = ref.watch(
        platformCoreRuntimeConfigurationResolverProvider,
      );
      final configuration = await resolver.resolve();
      if (!configuration.isConfigured) {
        return PlatformCoreProductionComposition(configuration: configuration);
      }

      final source = ConfiguredPlatformCoreDeclarationSource(
        platformCoreRoot: configuration.canonicalRoot,
      );
      return PlatformCoreProductionComposition(
        configuration: configuration,
        declarationSource: source,
        governedStatusReader: PlatformCoreGovernedStatusReader(source),
      );
    });

final platformCoreLiveStatusProvider =
    FutureProvider.autoDispose<PlatformCoreLiveStatus>((ref) async {
      final composition = await ref.watch(
        platformCoreProductionCompositionProvider.future,
      );
      final reader = composition.governedStatusReader;
      if (reader == null) {
        return PlatformCoreLiveStatus(composition: composition);
      }
      final envelope = await reader.load(scope: platformCoreDashboardScope);
      return PlatformCoreLiveStatus(
        composition: composition,
        envelope: envelope,
      );
    });

final platformCoreDashboardScope = GovernedStatusScope(
  canonicalId: 'new-earth-command-dashboard',
  displayName: 'New Earth Command Dashboard',
);

/// Lazily composed, read-only Platform Core dependencies for future consumers.
class PlatformCoreProductionComposition {
  const PlatformCoreProductionComposition({
    required this.configuration,
    this.declarationSource,
    this.governedStatusReader,
  });

  final PlatformCoreRuntimeConfiguration configuration;
  final PlatformCoreDeclarationSource? declarationSource;
  final PlatformCoreGovernedStatusReader? governedStatusReader;

  bool get isAvailable =>
      configuration.isConfigured &&
      declarationSource != null &&
      governedStatusReader != null;
}

class PlatformCoreLiveStatus {
  const PlatformCoreLiveStatus({required this.composition, this.envelope});

  final PlatformCoreProductionComposition composition;
  final GovernedStatusEnvelope? envelope;
}
