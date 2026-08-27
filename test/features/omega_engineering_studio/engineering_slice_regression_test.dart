import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_models.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/presentation/engineering_studio_screen.dart';

import 'engineering_studio_test_fixtures.dart';

void main() {
  testWidgets('engineering command palette shows category filters', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: EngineeringStudioScreen(
          repository: EngineeringStudioFakeRepository(
            buildEngineeringStudioSnapshot(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyK);
    await tester.pumpAndSettle();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

    expect(find.text('All'), findsWidgets);
    expect(find.text('Sections'), findsWidgets);
    expect(find.text('Create'), findsWidgets);
    expect(find.text('Utilities'), findsWidgets);
    expect(find.text('Integration'), findsWidgets);
    expect(find.text('Attachments'), findsWidgets);
  });

  testWidgets('dashboard surfaces recent activity', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: EngineeringStudioScreen(
          repository: EngineeringStudioFakeRepository(
            buildEngineeringStudioSnapshot(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.text('Power cycle evidence pack'), findsOneWidget);
    expect(find.text('BioCalm firmware artifact'), findsOneWidget);
    expect(
      find.text(
        'Specialist technical workspace for engineering evidence, project context, and technical workflows.',
      ),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('core engineering workspaces expose attachment actions', (
    tester,
  ) async {
    final cases = <EngineeringSection>[
      EngineeringSection.projects,
      EngineeringSection.pcbManager,
      EngineeringSection.firmwareCentre,
    ];

    for (final section in cases) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: EngineeringStudioScreen(
            repository: EngineeringStudioFakeRepository(
              buildEngineeringStudioSnapshot(),
            ),
            initialSection: section,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Add attachment'), findsOneWidget);
    }
  });
}
