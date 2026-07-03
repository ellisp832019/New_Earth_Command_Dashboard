import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/omega_engineering_studio/presentation/engineering_studio_screen.dart';

import 'engineering_studio_test_fixtures.dart';

void main() {
  testWidgets('ctrl k opens the engineering command palette', (tester) async {
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

    expect(find.text('Command Palette'), findsOneWidget);
    expect(
      find.byKey(const Key('engineeringCommandPaletteSearchField')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('engineeringCommandPaletteSearchField')),
      'add project',
    );
    await tester.pumpAndSettle();

    expect(find.text('Add project'), findsOneWidget);
    expect(find.text('Export snapshot'), findsNothing);
  });
}
