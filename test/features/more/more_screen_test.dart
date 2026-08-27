import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_earth_command_dashboard/features/gaia/application/gaia_employee_providers.dart';
import 'package:new_earth_command_dashboard/features/more/presentation/more_screen.dart';

void main() {
  testWidgets('more screen groups destinations by purpose', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 5000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [gaiaEmployeeFeatureEnabledProvider.overrideWithValue(true)],
        child: const MaterialApp(home: MoreScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final moreScreenList = find.byKey(const Key('moreScreenList'));
    for (final heading in [
      'WORK',
      'KNOWLEDGE',
      'SYSTEMS',
      'BUSINESS',
      'PERSONAL',
      'SPECIALIST',
      'HARDWARE / DEVELOPMENT',
      'ADMIN / SETTINGS',
    ]) {
      for (var i = 0; i < 12 && find.text(heading).evaluate().isEmpty; i++) {
        await tester.drag(moreScreenList, const Offset(0, -500));
        await tester.pumpAndSettle();
      }
      expect(find.text(heading), findsOneWidget);
    }
    expect(find.text('Command Deck'), findsOneWidget);
    expect(
      find.text(
        'Support the future physical control surface with bounded local commands and setup.',
      ),
      findsOneWidget,
    );
    expect(find.text('Platform Core Status'), findsOneWidget);
    expect(find.text('Knowledge Library'), findsOneWidget);
    expect(find.text('Company Command Centre'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('more screen shows the about and help tile', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gaiaEmployeeFeatureEnabledProvider.overrideWithValue(false),
        ],
        child: const MaterialApp(home: MoreScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Back'), findsAtLeastNWidgets(1));
    final moreScreenList = find.byKey(const Key('moreScreenList'));

    for (
      var i = 0;
      i < 6 && find.text('About & Help').evaluate().isEmpty;
      i++
    ) {
      await tester.drag(moreScreenList, const Offset(0, -480));
      await tester.pumpAndSettle();
    }
    await tester.pumpAndSettle();
    expect(find.text('About & Help'), findsAtLeastNWidgets(1));
    expect(
      find.text(
        'Open the Dashboard guide centre, support links, templates, and helper pages.',
      ),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('more screen hides the GAIA tile when disabled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 5000));
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
    await tester.binding.setSurfaceSize(const Size(1600, 5000));
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
