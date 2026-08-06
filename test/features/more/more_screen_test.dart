import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_earth_command_dashboard/features/gaia/application/gaia_employee_providers.dart';
import 'package:new_earth_command_dashboard/features/more/presentation/more_screen.dart';

void main() {
  testWidgets('more screen hides the GAIA tile when disabled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gaiaEmployeeFeatureEnabledProvider.overrideWithValue(false),
        ],
        child: MaterialApp(home: MoreScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('About & Help'), findsOneWidget);
    expect(find.text('GAIA AI Employee'), findsNothing);
    expect(
      find.text(
        'Open the Dashboard guide centre, support links, templates, and helper pages.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('more screen shows the GAIA tile when enabled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [gaiaEmployeeFeatureEnabledProvider.overrideWithValue(true)],
        child: const MaterialApp(home: MoreScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('GAIA AI Employee'), findsOneWidget);
    expect(find.textContaining('read-only GAIA workspace'), findsOneWidget);
  });
}
