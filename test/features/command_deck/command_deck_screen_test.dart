import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/command_deck/presentation/command_deck_screen.dart';

void main() {
  testWidgets('command deck page shows the grouped virtual deck', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CommandDeckScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
