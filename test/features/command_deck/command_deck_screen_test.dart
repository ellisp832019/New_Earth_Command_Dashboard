import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/command_deck/presentation/command_deck_screen.dart';

void main() {
  testWidgets('command deck page shows the grouped virtual deck', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CommandDeckScreen()));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(
      find.text(
        'Development preview for a future physical, tactile hardware interface. Software-only today.',
      ),
      findsOneWidget,
    );
    expect(find.text('Live hardware control'), findsNothing);
    expect(find.text('Connected hardware'), findsNothing);
  });

  testWidgets('command deck remains usable in a small window', (tester) async {
    tester.view.physicalSize = const Size(420, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: CommandDeckScreen()));
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.text(
        'Development preview for a future physical, tactile hardware interface. Software-only today.',
      ),
      findsOneWidget,
    );
    expect(find.text('Command Deck'), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);
  });
}
