import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/features/governed_status/application/platform_core_composition.dart';
import 'package:new_earth_command_dashboard/features/governed_status/data/platform_core_runtime_configuration.dart';
import 'package:new_earth_command_dashboard/features/governed_status/domain/governed_status.dart';
import 'package:new_earth_command_dashboard/features/governed_status/presentation/platform_core_governed_status_screen.dart';

void main() {
  testWidgets('valid declaration is shown as Platform Core truth', (
    tester,
  ) async {
    await _pump(tester, _validStatus());

    expect(find.text('Declaration available'), findsOneWidget);
    expect(find.text('Source: Platform Core'), findsOneWidget);
    expect(find.text('Declaration authority'), findsOneWidget);
    expect(find.text('Read-only'), findsOneWidget);
    expect(find.text('New Earth Command Dashboard'), findsOneWidget);
    expect(find.text('Declarative project'), findsNothing);
  });

  testWidgets('configuration and source failures remain clearly bounded', (
    tester,
  ) async {
    await _pump(
      tester,
      _configurationStatus(
        const PlatformCoreRuntimeConfiguration(
          status: PlatformCoreRuntimeConfigurationStatus.unavailable,
        ),
      ),
    );
    expect(find.text('Not configured'), findsOneWidget);

    await _pump(
      tester,
      _configurationStatus(
        const PlatformCoreRuntimeConfiguration(
          status: PlatformCoreRuntimeConfigurationStatus.invalidRoot,
        ),
      ),
    );
    expect(find.text('Configuration issue'), findsOneWidget);

    await _pump(
      tester,
      _configurationStatus(
        const PlatformCoreRuntimeConfiguration(
          status: PlatformCoreRuntimeConfigurationStatus.unavailable,
          configurationSource: 'NEW_EARTH_PLATFORM_CORE_ROOT',
        ),
      ),
    );
    expect(find.text('Unavailable'), findsOneWidget);
  });

  testWidgets(
    'invalid declaration is shown without fabricated Dashboard data',
    (tester) async {
      final composition = _availableComposition();
      final envelope = GovernedStatusEnvelope(
        requestedScope: platformCoreDashboardScope,
        sourceMetadata: [
          GovernedStatusSourceMetadata(
            source: GovernedStatusSource.platformCore,
            authority: GovernedStatusAuthority.platformCore,
            availability: GovernedStatusAvailability.invalid,
            scope: platformCoreDashboardScope,
            failureCategory: GovernedStatusFailureCategory.invalid,
          ),
        ],
        sourceFailures: [
          GovernedStatusSourceFailure(
            source: GovernedStatusSource.platformCore,
            category: GovernedStatusFailureCategory.invalid,
            scope: platformCoreDashboardScope,
            description: 'platform_core_invalid_declaration',
          ),
        ],
      );

      await _pump(
        tester,
        PlatformCoreLiveStatus(composition: composition, envelope: envelope),
      );

      expect(find.text('Declaration issue'), findsOneWidget);
      expect(find.text('No tasks found'), findsNothing);
      expect(find.text('No projects found'), findsNothing);
    },
  );

  testWidgets('refresh remains manual and requests the live provider again', (
    tester,
  ) async {
    var reads = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          platformCoreLiveStatusProvider.overrideWith((ref) async {
            reads++;
            return _validStatus();
          }),
        ],
        child: const MaterialApp(home: PlatformCoreGovernedStatusScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(reads, 1);
    await tester.tap(
      find.byKey(const Key('platformCoreGovernedStatusRefreshButton')),
    );
    await tester.pumpAndSettle();
    expect(reads, 2);
  });
}

Future<void> _pump(WidgetTester tester, PlatformCoreLiveStatus status) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        platformCoreLiveStatusProvider.overrideWith((ref) async => status),
      ],
      child: const MaterialApp(home: PlatformCoreGovernedStatusScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

PlatformCoreLiveStatus _validStatus() {
  final composition = _availableComposition();
  final declared = DeclaredStatusLayer(
    canonicalId: platformCoreDashboardScope.canonicalId,
    displayName: platformCoreDashboardScope.displayName,
    systemType: 'operations-dashboard',
    owner: 'New Earth Advanced Technologies Ltd',
    lifecycle: 'active',
    repository: 'New_Earth_Command_Dashboard',
    contractVersion: '1.0',
  );
  final envelope = GovernedStatusEnvelope(
    requestedScope: platformCoreDashboardScope,
    records: [
      GovernedStatusRecord(
        scope: platformCoreDashboardScope,
        declared: declared,
      ),
    ],
    sourceMetadata: [
      GovernedStatusSourceMetadata(
        source: GovernedStatusSource.platformCore,
        authority: GovernedStatusAuthority.platformCore,
        availability: GovernedStatusAvailability.available,
        scope: platformCoreDashboardScope,
        schemaVersion: '1.0',
        retrievedAt: DateTime.utc(2026, 8, 26, 12),
      ),
    ],
    partial: true,
  );
  return PlatformCoreLiveStatus(composition: composition, envelope: envelope);
}

PlatformCoreLiveStatus _configurationStatus(
  PlatformCoreRuntimeConfiguration configuration,
) {
  return PlatformCoreLiveStatus(
    composition: PlatformCoreProductionComposition(
      configuration: configuration,
    ),
  );
}

PlatformCoreProductionComposition _availableComposition() {
  return const PlatformCoreProductionComposition(
    configuration: PlatformCoreRuntimeConfiguration(
      status: PlatformCoreRuntimeConfigurationStatus.configured,
      canonicalRoot: 'D:\\New Earth\\Platform Core',
      configurationSource: 'NEW_EARTH_PLATFORM_CORE_ROOT',
    ),
  );
}
